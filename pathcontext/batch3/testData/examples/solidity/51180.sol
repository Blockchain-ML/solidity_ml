pragma solidity 0.4.25;

 
 
contract SafeMath {

  function safeSub (uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd (uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert (bool assertion) public {
    if (!assertion) {
      revert();
    }
  }
}

contract BNB is SafeMath{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
	address public owner;

     
    mapping (address => uint256) public balanceOf;
	mapping (address => uint256) public freezeOf;
    mapping (address => mapping (address => uint256)) public allowance;

     
    event Transfer (address indexed from, address indexed to, uint256 value);

     
    event Burn (address indexed from, uint256 value);
	
	 
    event Freeze (address indexed from, uint256 value);
	
	 
    event Unfreeze (address indexed from, uint256 value);

     
    constructor(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol) public{
            
        balanceOf[msg.sender] = initialSupply;               
        totalSupply = initialSupply;                         
        name = tokenName;                                    
        symbol = tokenSymbol;                                
        decimals = decimalUnits;                             
		owner = msg.sender;
    
        }

     
    function transfer (address _to, uint256 _value) public {
        if (_to == 0x0) revert();                                
		if (_value <= 0) revert(); 
        if (balanceOf[msg.sender] < _value) revert();            
        if (balanceOf[_to] + _value < balanceOf[_to]) revert();  
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                             
        emit Transfer(msg.sender, _to, _value);                    
    }

     
    function approve (address _spender, uint256 _value) public returns (bool success) {
		if (_value <= 0) revert(); 
        allowance[msg.sender][_spender] = _value;
        return true;
    }
       

     
    function transferFrom (address _from, address _to, uint256 _value)public returns (bool success) {
        if (_to == 0x0) revert();                                 
		if (_value <= 0) revert(); 
        if (balanceOf[_from] < _value) revert();                                 
        if (balanceOf[_to] + _value < balanceOf[_to]) revert();                  
        if (_value > allowance[_from][msg.sender]) revert();                     
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);           
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);               
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
     

    function burn (uint256 _value) public returns (bool success) {
        if (balanceOf[msg.sender] < _value) revert();                                     
		if (_value <= 0) revert(); 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);           
        totalSupply = SafeMath.safeSub(totalSupply,_value);                                
        emit Burn(msg.sender, _value);
        return true;
    }
	
	 
	
	function freeze (uint256 _value) public returns (bool success) {
        if (balanceOf[msg.sender] < _value) revert();             
		if (_value <= 0) revert(); 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                       
        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value);                                 
        emit Freeze(msg.sender, _value);
        return true;
    }
	
	 
	
	function unfreeze (uint256 _value) public returns (bool success) {
        if (freezeOf[msg.sender] < _value) revert();             
		if (_value <= 0) revert(); 
        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);                       
		balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);
        emit Unfreeze(msg.sender, _value);
        return true;
    }
	
	 
	 
	function withdrawEther (uint256 amount) public {
		if(msg.sender != owner) revert();
		owner.transfer(amount);
	}
	
	 
	function()public payable {
    }
}