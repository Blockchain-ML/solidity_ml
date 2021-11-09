pragma solidity 0.4.25;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

 function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0);  
    uint256 c = a / b;
    assert(a == b * c + a % b);  
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public manager;


  event OwnershipTransferred(address indexed previousManager, address indexed newManager);


   
   constructor() public payable {
    manager = msg.sender;
  }


   
  modifier onlyManager() {
    require(msg.sender == manager);
    _;
  }


   
  function transferOwnership(address newManager) onlyManager public {
    require(newManager != address(0));
    emit OwnershipTransferred(manager, newManager);
    manager = newManager;
  }

}

contract ERC20Interface {
     function totalSupply() public constant returns (uint);
     function balanceOf(address tokenOwner) public constant returns (uint balance);
     function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
     function transfer(address to, uint tokens) public returns (bool success);
     function approve(address spender, uint tokens) public returns (bool success);
     function transferFrom(address from, address to, uint tokens) public returns (bool success);
     event Transfer(address indexed from, address indexed to, uint tokens);
     event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Taxi is Ownable,ERC20Interface{
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint256 public decimals;
    
    
     
    string public taxi_driver;
    string public car_dealer;
    uint public contract_balance=0;
    uint256 public fixed_expenses;
    uint256 public participation_fee=1;
 
   
    struct OwnedCar {  
        uint256   CarID;  
    }
    
    struct ProposedCar {  
        uint256  CarID;
        uint256  price; 
        uint256  offer_valid_time;
    }
    
    struct ProposedPurchase{
        uint256 CarID;
        uint256 price;
        uint256 offer_valid_time;
        bool approval_state;
    }
     
    
    mapping(address=>uint256) participants;
    
    mapping(address => uint256) tokenBalances; 
     
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public _totalSupply;
    
     
     event Receive(uint value);
    
    constructor() public payable {
        manager = msg.sender;
        name  = "Feed";
        symbol = "FEED";
        decimals = 18;
        _totalSupply = 1000000000 * 10 ** uint(decimals);
        tokenBalances[ msg.sender] = _totalSupply;    
    }
    
     
     
     
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - tokenBalances[address(0)];
    }
      
      
      
      
     function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
         return allowed[tokenOwner][spender];
     }
     
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
         return tokenBalances[tokenOwner];
     }
    
     
    function transfer(address to, uint tokens) public returns (bool success) {
         require(to != address(0));
         require(tokens <= tokenBalances[msg.sender]);
          
         tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(tokens);
         tokenBalances[to] = tokenBalances[to].add(tokens);
         emit Transfer(msg.sender, to, tokens);
         return true;
     }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= tokenBalances[_from]);
    require(_value <= allowed[_from][msg.sender]);
     
    tokenBalances[_from] = tokenBalances[_from].sub(_value);
    tokenBalances[_to] = tokenBalances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }
    
     
    function approve(address _spender, uint256 _value) public returns (bool) {
       allowed[msg.sender][_spender] = _value;
       emit Approval(msg.sender, _spender, _value);
       return true;
    }
    
     
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
     
    
    function joinFunction() public payable returns(bool success){
        require(msg.value>0);
        require(msg.value>=participation_fee);
        msg.sender.transfer(participation_fee);
        return true; 
        
    }
    
     
    
}