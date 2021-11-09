pragma solidity ^0.4.21;

 
contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address previousOwner, address newOwner);

     
    constructor(address _owner) public {
        owner = _owner == address(0) ? msg.sender : _owner;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

     
    function confirmOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
}


 
contract IERC20Token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value)  public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value)  public returns (bool success);
    function approve(address _spender, uint256 _value)  public returns (bool success);
    function allowance(address _owner, address _spender)  public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

 
contract SafeMath {
     
    constructor() public {
    }

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}



 
contract ERC20Token is IERC20Token, SafeMath {
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value);

        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        balances[_to] = safeAdd(balances[_to], _value);
        balances[_from] = safeSub(balances[_from], _value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return allowed[_owner][_spender];
    }
}

 
interface ITokenEventListener {
     
    function onTokenTransfer(address _from, address _to, uint256 _value) external;
}

 
contract ManagedToken is ERC20Token, Ownable {
    bool public allowTransfers = false;                                          
    bool public issuanceFinished = false;                                        

    ITokenEventListener public eventListener;                                    

    event AllowTransfersChanged(bool _newState);                                 
    event Issue(address indexed _to, uint256 _value);                            
    event Destroy(address indexed _from, uint256 _value);                        
    event IssuanceFinished();                                                    

     
    modifier transfersAllowed() {
        require(allowTransfers);
        _;
    }

     
    modifier canIssue() {
        require(!issuanceFinished);
        _;
    }

     
    constructor(address _listener, address _owner) public Ownable(_owner) {
        if(_listener != address(0)) {
            eventListener = ITokenEventListener(_listener);
        }
    }

     
    function setAllowTransfers(bool _allowTransfers) external onlyOwner {
        allowTransfers = _allowTransfers;

         
        emit AllowTransfersChanged(_allowTransfers);
    }

     
    function setListener(address _listener) public onlyOwner {
        if(_listener != address(0)) {
            eventListener = ITokenEventListener(_listener);
        } else {
            delete eventListener;
        }
    }

    function transfer(address _to, uint256 _value) public transfersAllowed returns (bool) {
        bool success = super.transfer(_to, _value);
         
        return success;
    }

    function transferFrom(address _from, address _to, uint256 _value) public transfersAllowed returns (bool) {
        bool success = super.transferFrom(_from, _to, _value);

         
         
        return success;
    }

    function hasListener() internal view returns(bool) {
        if(eventListener == address(0)) {
            return false;
        }
        return true;
    }

     
    function issue(address _to, uint256 _value) external onlyOwner canIssue {
        require(totalSupply >= _value);
        totalSupply = safeSub(totalSupply, _value);
        balances[_to] = safeAdd(balances[_to], _value);
         
        emit Issue(_to, _value);
        emit Transfer(address(0), _to, _value);
    }

     
    function destroy(address _from, uint256 _value) external onlyOwner {
        require(balances[_from] >= _value);

        totalSupply = safeAdd(totalSupply, _value);
        balances[_from] = safeSub(balances[_from], _value);

        emit Transfer(_from, address(0), _value);
         
        emit Destroy(_from, _value);
    }

     
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = safeAdd(allowed[msg.sender][_spender], _addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

     
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = safeSub(oldValue, _subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

     
    function finishIssuance() public onlyOwner returns (bool) {
        issuanceFinished = true;
         
        emit IssuanceFinished();
        return true;
    }
}


 
contract DCF is ManagedToken {
    uint256 public minDeposit;                                                   
    uint256 public coinPrice;                                                    
    bool public isPause = false;                                                 

    event WithdrawMoney(address _address, uint256 _value);

     
    constructor(uint256 _coinPrice) public ManagedToken(msg.sender, msg.sender) {
        name = "DCF";
        symbol = "DCF";
        decimals = 18;
        totalSupply = 500000000 ether;                                           
        minDeposit = 0.01 ether;                                                 
        coinPrice = _coinPrice;                                                  
    }

     
    modifier canDeposit() {
        require(!isPause, "Deposit to issue token is paused.");
        require(msg.value >= minDeposit, "Deposit is required greater value of minDeposit");
        _;
    }

     
    function() payable public  {
        Deposit();
    }

     
    function Deposit() private canDeposit {
         
        uint256 value = safeDiv(safeMul(msg.value, 1 ether), coinPrice);
         
        require(totalSupply >= value, "Not enough token to issue.");
         
        totalSupply = safeSub(totalSupply, value);

         
        if(balances[msg.sender] == 0){
            balances[msg.sender] = value;
        }else{
            balances[msg.sender] = safeAdd(balances[msg.sender], value);
        }

         
        emit Transfer(address(0), msg.sender, value);
    }

     

    function paused(bool pause) external onlyOwner {
        isPause = pause;
    }

    function setPriceToken(uint256 _coinPrice) external onlyOwner {
        coinPrice = _coinPrice;
    }

    function setMinDeposit(uint256 _minDeposit) external onlyOwner {
        minDeposit = _minDeposit;
    }

     

     
    function withdraw(address _address, uint256 _value) external onlyOwner {
        require(_address != address(0));
        require(_value <= address(this).balance);
        _address.transfer(_value);
        emit WithdrawMoney(_address, _value);
    }
}