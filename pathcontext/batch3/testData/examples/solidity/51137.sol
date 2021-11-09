pragma solidity ^0.4.4;

library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
     
     
     
    if (a == 0) {
      return 0;
    }

    c = a * b;
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

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Token {

     
    function totalSupply() public constant returns (uint256 supply) {}

     
     
    function balanceOf(address _owner) public constant returns (uint256 balance) {}

     
     
     
     
    function transfer(address _to, uint256 _value) public returns (bool success) {}

     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {}

     
     
     
     
    function approve(address _spender, uint256 _value) public returns (bool success) {}

     
     
     
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}



contract ChargingPoint is Token {
	address public owner; 
	uint256 public priceForTime;
	string public pointIdentifier;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply = 50000000;
	
	modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    event enablePoint(string pointIdentifier,uint256 time);
	event updateBalance(string pointIdentifier);
	event updatePrice(string pointIdentifier);
	
    constructor(string _pointIdentifier,uint256 _priceForTime) public {
		owner= msg.sender;
		priceForTime=_priceForTime; 
		pointIdentifier=_pointIdentifier;
		balances[msg.sender] = totalSupply;
	}

	function setPrice(uint256 _priceForTime) public onlyOwner {
			priceForTime=_priceForTime;
			emit updatePrice(pointIdentifier);
	} 
	
    function setPointIdentifier(string _pointIdentifier) public onlyOwner {
			pointIdentifier=_pointIdentifier;
	} 	
	
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
			if (priceForTime!=0 && this == _to)
			{
    			uint chargeTime=SafeMath.div(_value, priceForTime);
    			emit enablePoint(pointIdentifier,chargeTime);
			}
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
         
         
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
}