 

 

pragma solidity ^0.5.0;

 
contract SafeMath {
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;

    return c;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function safeMod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");

    return a % b;
  }
}

contract Ownable {
    address public _owner;

     
    constructor () public {
        _owner = msg.sender;
    }

     
    modifier onlyOwner() {
        if (msg.sender != _owner) {
            revert("Error: sender is not same owner");
        }
        _;
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            _owner = newOwner;
        }
    }

     
    function owner() public view returns (address) {
        return _owner;
    }
}


contract StandardToken is SafeMath, Ownable{
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) private deactivatedList;

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Burn(address indexed from, uint256 value);
    
     
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyActivatedList() {
        require(deactivatedList[msg.sender] != true, "Error: sender is in deactivatedList.");
        _;
    }

    function addDeactivatedList(address _deactivatedAccount) public onlyOwner {
        deactivatedList[_deactivatedAccount] = true;
    }

    function getDeactivatedList(address _deactivatedAccount) public onlyOwner view returns(bool) {
        return deactivatedList[_deactivatedAccount];
    }

    function removeDeactivatedList(address _deactivatedAccount) public onlyOwner {
        deactivatedList[_deactivatedAccount] = false;
    }

     
    function transfer(address _to, uint256 _value) public onlyActivatedList returns (bool) {
        require(_to != address(0x0), "");    
        require(balanceOf[msg.sender] >= _value, "");
        require(balanceOf[_to] + _value >= balanceOf[_to], ""); 

        if (balanceOf[msg.sender] >= _value && balanceOf[_to] + _value > balanceOf[_to]) {
            balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);
            balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);
            emit Transfer(msg.sender, _to, _value);

            return true;
        } else {
            return false;
        }
    }

     
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function increaseAllowance(address _spender, uint256 _value) public returns (bool) {
        approve(_spender, SafeMath.safeAdd(allowance[msg.sender][_spender], _value));
        return true;
    }

     
    function decreaseAllowance(address _spender, uint256 _value) public returns (bool) {
        approve(_spender, SafeMath.safeSub(allowance[msg.sender][_spender], _value));
        return true;
    }
       
     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0x0), "");    
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender], "TokenTransferFromError");

        require(msg.sender == _owner || deactivatedList[_from] != true, "From is in deactivatedList");

        if (balanceOf[_from] >= _value && allowance[_from][msg.sender] >= _value && balanceOf[_to] + _value > balanceOf[_to]) {
            balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                           
             
            balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                             
             
            allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function burn() public pure {
        require(false, "This function is not supported");
    }

    function withdrawEther() public pure {
        require(false, "This function is not supported");
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

     
    modifier whenNotPaused() {
        if (paused) revert("Error: paused");
        _;
    }

     
    modifier whenPaused() {
        if (!paused) revert("Error: not paused");
        _;
    }

     
    function pause() public onlyOwner whenNotPaused returns (bool) {
        paused = true;
        emit Pause();
        return true;
    }

     
    function unpause() public onlyOwner whenPaused returns (bool) {
        paused = false;
        emit Unpause();
        return true;
    }
}


 
contract PausableToken is Pausable, StandardToken {
    function transfer(address _to, uint _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}

contract PBToken is PausableToken{
    string public name;
    string public symbol;
    uint8 public decimals;
     
    string public version = "1.1.0";

    mapping (address => uint256) public freezeOf;

     
    event Freeze(address indexed from, uint256 value);
    
     
    event Unfreeze(address indexed from, uint256 value);

     
    constructor (
        uint256 initialSupply,
        string memory tokenName,
        uint8 decimalUnits,
        string memory tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimalUnits);                         
        balanceOf[msg.sender] = totalSupply;               
        name = tokenName;                                    
        symbol = tokenSymbol;                                
        decimals = decimalUnits;                             
        _owner = msg.sender;
    }

    function freeze(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "");    
        require(_value > 0);
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                       
        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value);                                 
        emit Freeze(msg.sender, _value);
        return true;
    }
    
    function unfreeze(uint256 _value) public returns (bool success) {
        require(freezeOf[msg.sender] >= _value);      
        require(_value > 0);
        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);                       
        balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);
        emit Unfreeze(msg.sender, _value);
        return true;
    }

     
    function () external payable { revert("error"); }
}