pragma solidity ^0.4.24;


 
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


 
contract ERC20 is ERC20Basic {
    function allowance(address _owner, address _spender)
        public view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value)
        public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

 
library SafeMath {

   
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
         
         
         
        if (_a == 0) {
            return 0;
        }

        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

     
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
         
         
         
        return _a / _b;
    }

     
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

     
    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }
}

 
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) internal balances;

    uint256 internal totalSupply_;

     
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

     
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender],"Value is over than balance");
        require(_to != address(0),"Invalid address");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

     
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

}


 
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


     
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(_value <= balances[_from],"Value over than balance");
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

     
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

     
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
        public
        returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}


 
contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
       address indexed previousOwner,
       address indexed newOwner
    );


   
    constructor() public {
        owner = msg.sender;
    }

   
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

   
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

   
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

   
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


contract YourToken is StandardToken, Ownable {
    string public name = "Your Token";
    string public symbol = "YOUR";
    uint32 public decimals = 18;
    uint256 public dateStartTransfer;

    constructor(string _name, string _symbol, uint32 _decimals, uint256 _maxSupply, uint256 _dateStartTransfer, address _owner) public {
        
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply_ = _maxSupply;
        balances[_owner] = _maxSupply; 
        owner = _owner;
        dateStartTransfer = _dateStartTransfer; 
    }
    
    modifier allowTransfer() {
        if (msg.sender != owner){
            require(now > dateStartTransfer, "All transfers are locked now.");
        }
        _;
    }
    
     
    function setDateStartTransfer(uint256 _newDate) public onlyOwner {
        dateStartTransfer = _newDate;
    }
    
     
    function transfer(address _to, uint256 _value) public allowTransfer returns(bool){
        return super.transfer(_to,_value);
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public allowTransfer returns(bool){
        return super.transferFrom(_from,_to,_value);
    }

}
contract TokenFactory {
    address[] public deployedTokens;
    
    function createToken(string _name, string _symbol, uint32 _decimals, uint256 _maxSupply, uint256 _dateStartTransfer) public {
         
        address newToken = new YourToken(_name, _symbol, _decimals, _maxSupply, _dateStartTransfer, msg.sender);   
                                                         
        deployedTokens.push(newToken);             
    }
    
    function getDeployedTokens() public view returns(address[]) {
        return deployedTokens;
    }
    
}