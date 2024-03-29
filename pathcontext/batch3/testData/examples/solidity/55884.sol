pragma solidity 0.4.24;

 

 
 
 
 
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function burn(uint _amount) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

 

 

 
 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
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

   
  function getFractionalAmount(uint256 _amount, uint256 _percentage)
  internal
  pure
  returns (uint256) {
    return div(mul(_amount, _percentage), 100);
  }

}

 

interface ApproveAndCallFallBack { function receiveApproval(address, uint256, address, bytes) external; }
 
 
 
 
contract ERC20 is ERC20Interface{
    using SafeMath for uint;

     
     
     
    uint internal supply;
    mapping (address => uint) internal balances;
    mapping (address => mapping (address => uint)) internal allowed;

     
     
     
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  


     
     
     
    constructor(uint _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol)
    public {
        balances[msg.sender] = _initialAmount;                
        supply = _initialAmount;                         
        name = _tokenName;                                    
        decimals = _decimalUnits;                             
        symbol = _tokenSymbol;                                
        emit Transfer(address(0), msg.sender, _initialAmount);     
    }


     
     
     
     
    function transfer(address _to, uint _amount)
    public
    returns (bool success) {
        require(_to != address(0));          
        require(_to != address(this));
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

     
     
     
     
    function transferFrom(address _from, address _to, uint _amount)
    public
    returns (bool success) {
        require(_to != address(0));
        require(_to != address(this));
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

     
     
     
     
    function approve(address _spender, uint _amount)
    public
    returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }


     
     
     
     
    function approveAndCall(address _spender, uint _amount, bytes _data)
    public
    returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _amount, this, _data);
        return true;
    }

     
     
     
     
    function burn(uint _amount)
    public
    returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        supply = supply.sub(_amount);
        emit LogBurn(msg.sender, _amount);
        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }

     
     
     
     
    function burnFrom(address _from, uint _amount)
    public
    returns (bool success) {
        balances[_from] = balances[_from].sub(_amount);                          
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);              
        supply = supply.sub(_amount);                               
        emit LogBurn(_from, _amount);
        emit Transfer(_from, address(0), _amount);
        return true;
    }

     
     
     
    function totalSupply()
    public
    view
    returns (uint tokenSupply) {
        return supply;
    }

     
     
     
    function balanceOf(address _tokenHolder)
    public
    view
    returns (uint balance) {
        return balances[_tokenHolder];
    }

     
     
     
    function allowance(address _tokenHolder, address _spender)
    public
    view
    returns (uint remaining) {
        return allowed[_tokenHolder][_spender];
    }


     
     
     
     
    function ()
    public
    payable {
        revert();
    }

     
     
     
    event LogBurn(address indexed _burner, uint indexed _amountBurned);
}