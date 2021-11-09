pragma solidity ^0.5.0;


 
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

contract EucxToken {
	using SafeMath for uint256;

    string public name;
    string public symbol;
    string public standard;
    uint8 public decimals;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    address internal owner;
    uint256 internal supply;
    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    constructor() public {
        owner = msg.sender;
        name = "EUCX Token";
        symbol = "EUCX";
        standard = "EUCX Token v1.0";
        decimals = 18;
    	supply = 1000000000 * 10**uint(decimals);
    	balances[owner] = supply;
        emit Transfer(address(0), owner, supply);
    }

    function totalSupply() public view returns (uint256) {
    	return supply.sub(balances[owner]);
    }

    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "owner is 0");
    	return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        require(_owner != address(0), "owner is 0");
        require(_spender != address(0), "spender is 0");
    	return allowed[_owner][_spender];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool) {
    	require(_to != address(0), "to is 0");
        require(balances[msg.sender] >= _value, "tnsufficient balance");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
         
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        require(_spender != address(0), "spender is 0");
        require(_addedValue != 0, "addedValue is 0");
        require(balances[msg.sender] >= _addedValue, "insufficient balance");

	    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

	    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

	    return true;
	}

	function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        require(_spender != address(0), "spender is 0");
        require(_subtractedValue != 0, "subtractedValue is 0");
        require(allowed[msg.sender][_spender] >= _subtractedValue, "insufficient allowance");

	    uint256 oldValue = allowed[msg.sender][_spender];
	    if (_subtractedValue >= oldValue) {
	      allowed[msg.sender][_spender] = 0;
	    } else {
	      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
	    }

	    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
	    return true;
	}

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    	 
        require(balances[_from] >= _value, "insufficient balance");
        balances[_from] = balances[_from].sub(_value);

        require(allowed[_from][msg.sender] >= _value, "insufficient allowance");
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function() external payable {
        revert();
    }
}