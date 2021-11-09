pragma solidity ^0.4.11;

  
  
  
  
  

 
 
interface ERC20 {
     
    function totalSupply() constant returns (uint totalSupply);
     
    function balanceOf(address _owner) constant returns (uint balance);
     
    function transfer(address _to, uint _value) returns (bool success);
     
    function transferFrom(address _from, address _to, uint _value) returns (bool success);
     
     
     
    function approve(address _spender, uint _value) returns (bool success);
     
    function allowance(address _owner, address _spender) constant returns (uint remaining);
     
    event Transfer(address indexed _from, address indexed _to, uint _value);
     
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b > 0);  
    uint256 c = a / b;
    assert(a == b * c + a % b);  
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

 
contract MyToken is ERC20 {
    
    string public constant name  = "MyToken";
    string public constant  symbol = "MT";
    uint8 public constant decimals = 18;
    uint public _totalSupply = 39000000;
    uint256 public constant RATE = 500;
    
    using SafeMath for uint256;
    address public owner;
    
      
     modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
         _;
     }
     
     
    mapping(address => uint256) balances;
     
    mapping(address => mapping(address=>uint256)) allowed;

     
    function () payable{
        createTokens();
    }

     
    function MyToken(){
        owner = msg.sender; 
    }

     
     function createTokens() payable {
        require(msg.value > 0);
        uint256  tokens = msg.value.mul(RATE);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        owner.transfer(msg.value);
    }
    
    function totalSupply() constant returns(uint256){
        return _totalSupply;
    }
     
    function balanceOf(address _owner) constant returns(uint256){
        return balances[_owner];
    }

      
    function transfer(address _to, uint _value) returns(bool){
        require(balances[msg.sender] >= _value && _value > 0 );
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    
     
     
     
     
     
     
    function transferFrom(address _from, address _to, uint _value) returns(bool){
        require(allowed[_from][msg.sender] >= _value && balances[_from] >= _value && _value > 0);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    
     
     
    function approve(address _spender, uint _value) returns(bool){
        allowed[msg.sender][_spender] = _value; 
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
     
    function allowance(address _owner, address _spender) constant returns(uint256){
        return allowed[_owner][_spender];
    }
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}