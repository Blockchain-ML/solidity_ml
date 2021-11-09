pragma solidity ^0.4.24;


library SafeMath{
    
    function mul256(uint256 a,uint256 b) pure internal returns(uint256){
        uint256 c = a * b;
        assert(a == 0 || c/a == b);
        return c;
    }
    
    function div256(uint256 a, uint256 b) pure internal returns(uint256){
        require(b > 0);  
        uint256 c = a/b;
        return c;
    }
    
    function sub256(uint256 a, uint256 b) pure internal returns(uint256){
        require(b <= a);
        return a -b;
    }
    
    function add256(uint256 a,uint256 b) pure internal returns(uint256){
        uint256 c= a+b;
        assert(c>=a);
        return c;
    }
}

  
contract ERC20Basic{
    function totalSupply() public view returns(uint256);
    function balanceOf(address who) public view returns(uint256);
    function transfer(address to, uint256 value) public;
    
    event Transfer(address indexed from,address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic{
    function allowance(address owner, address spender) view public returns(uint256);
    function transferFrom(address from, address to, uint256 value) public;
    function approve(address spender,uint256 value) public;
    
    event Approval(address indexed owner,address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic{
    using SafeMath for uint256;
    
    mapping(address=>uint256) balances;

     
    modifier onlyPayloadSixe(uint size){
        require(msg.data.length >= size+4);_;
    }
    
    
     
    function transfer(address _to, uint256 _value) onlyPayloadSixe(2*32) public{
        balances[msg.sender] = balances[msg.sender].sub256(_value);
        balances[_to] = balances[_to].add256(_value);
        emit Transfer(msg.sender,_to,_value);
    }
    
     
    function balanceOf(address _owner) constant public returns(uint256 balance){
         return balances[_owner];
    }
}

contract StarndardToken is BasicToken, ERC20{
    mapping(address => mapping(address=>uint256)) allowed;
    address public owner;
    
    modifier onlyOwner(){
        require(msg.sender == owner);_;
    }
    
     
    function transferFrom(address _from, address _to, uint256 _value) public{
        uint256 _allowance = allowed[_from][msg.sender];
         
        balances[_to] = balances[_to].add256(_value);
        balances[_from] = balances[_from].sub256(_value);
        allowed[_from][msg.sender] = _allowance.sub256(_value);
         
        emit Transfer(_from,_to,_value);
     }
     
     
    function approve(address _spender, uint256 _value) public {
         
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }
      
}

contract PeaceAngelToken is StarndardToken {
    string public name="Peace Angel Token";
    string public symbol="PATO";
    uint8 public decimals = 0;
    uint256 public totalSupply=60000000;
    
    event TokenBurned(uint256 value);
    
    constructor() public {
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
    }
    
     
    function burn(uint256 _value) onlyOwner() public{
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub256(_value);
        totalSupply = totalSupply.sub256(_value);
        emit TokenBurned(_value);
    }
    
     
    function totalSupply() public view returns(uint256){
        return totalSupply;
    }
    
    function allowance(address _owner,address _spender) view public returns (uint256){
        return allowed[_owner][_spender];
    }
}