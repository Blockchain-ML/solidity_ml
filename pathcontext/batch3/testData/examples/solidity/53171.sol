pragma solidity ^0.4.24;

contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
    constructor () public {
        owner = 0x019E713834eed11644946E3123057Fb8759B7363;
    }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

 
}


contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

   
  modifier whenPaused() {
    require(paused);
    _;
  }

   
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}
 
 
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

 
contract TokenERC20 {
    function balanceOf(address who) public constant returns (uint);
    function allowance(address owner, address spender) public constant returns (uint);
    
    function transfer(address to, uint value) public  returns (bool ok);
    function transferFrom(address from, address to, uint value) public  returns (bool ok);
    
    function approve(address spender, uint value) public returns (bool ok);
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
} 

contract TokenERC20Standart is TokenERC20, Pausable{
    
        using SafeMath for uint256;
            
            
         
        mapping(address => uint) public balances;
        mapping(address => mapping(address => uint)) public allowed;
        
         
        modifier onlyPayloadSize(uint size) {
            require(msg.data.length >= size + 4) ;
            _;
        }
            
       
        function balanceOf(address tokenOwner) public constant whenNotPaused  returns (uint balance) {
             return balances[tokenOwner];
        }
 
        function transfer(address to, uint256 tokens) public  whenNotPaused onlyPayloadSize(2*32) returns (bool success) {
            _transfer(msg.sender, to, tokens);
            return true;
        }
 

        function approve(address spender, uint tokens) public whenNotPaused returns (bool success) {
            allowed[msg.sender][spender] = tokens;
            emit Approval(msg.sender, spender, tokens);
            return true;
        }
 
        function transferFrom(address from, address to, uint tokens) public whenNotPaused onlyPayloadSize(3*32) returns (bool success) {
            balances[from] = balances[from].sub(tokens);
            allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
            balances[to] = balances[to].add(tokens);
            emit Transfer(from, to, tokens);
            return true;
        }

        function allowance(address tokenOwner, address spender) public  whenNotPaused constant returns (uint remaining) {
            return allowed[tokenOwner][spender];
        }

        function sell(address _recipient, uint256 _value) internal whenNotPaused returns (bool success) {
            _transfer (owner, _recipient, _value);
            return true;
        }
        
        function _transfer(address _from, address _to, uint _value) internal {
            assert(_value > 0);
            require (_to != 0x0);                              
            require (balances[_from] >= _value);               
            require (balances[_to] + _value >= balances[_to]);
            balances[_from] = balances[_from].sub(_value);                        
            balances[_to] = balances[_to].add(_value);                           
            emit Transfer(_from, _to, _value);
        }

 

}


contract BeringiaContract is TokenERC20Standart{
    
    using SafeMath for uint256;
    
    string public name;                          
    uint256 public decimals;                     
    string public symbol;                        
    string public version;                       

    uint256 public _totalSupply = 0;                     
    uint256 public constant RATE = 2900;                 
    uint256 public fundingEndTime  = 1538179200000;      
    uint256 public minContribution = 350000000000000;    
    uint256 public oneTokenInWei = 1000000000000000000;
    uint256 public tokenCreationCap;                     

        
    address public owner;

     
    uint256 firstPeriodEND = 1532217600000;
    uint256 secondPeriodEND = 1534896000000;
    uint256 thirdPeriodEND = 1537574400000;
    
    uint256 firstPeriodDis = 25;
    uint256 secondPeriodDis = 20;
    uint256 thirdPeriodDis = 15;  
  
    constructor () public {
        name = "Beringia";                  
        decimals = 0;                        
        symbol = "BER";                      
        owner = msg.sender;                  
        version = "0.0.1_BETA_5";            
        tokenCreationCap = 1500000 * 10 ** uint256(decimals);
        balances[msg.sender] = tokenCreationCap;  
        emit Transfer(address(0x0), msg.sender, tokenCreationCap);
    }
    
    function transfer(address _to, uint _value) public  returns (bool) {
        require (now <= fundingEndTime);
        _totalSupply = _totalSupply.add(_value);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        require (now <= fundingEndTime);
        return super.transferFrom(_from, _to, _value);
    }
    
    function () public payable {
        createTokens(msg.sender, msg.value);
    }
    
    function createTokens(address _sender, uint256 _value) public whenNotPaused {
        require(_value > 0);
        require (now <= fundingEndTime);
        require(_value >= minContribution);
        uint256 tokens = (_value * RATE) / oneTokenInWei;
        require(tokens > 0);
        if (now <= firstPeriodEND){
            tokens =  ((tokens * 100) * (firstPeriodDis + 100))/10000;
        }else if (now > firstPeriodEND && now <= secondPeriodEND){
            tokens =  ((tokens * 100) *(secondPeriodDis + 100))/10000;
        }else if (now > secondPeriodEND && now <= thirdPeriodEND){
            tokens = ((tokens * 100) * (thirdPeriodDis + 100))/10000;
        }
        require(_totalSupply.add(tokens) <= tokenCreationCap);
        _totalSupply = _totalSupply.add(tokens);
        require(sell(_sender, tokens)); 
        owner.transfer(_value);
    }
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply - balances[address(0)];
    }
    
    function getBalance(address _sender) public view returns (uint256) {
        return _sender.balance;
    }
}