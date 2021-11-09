pragma solidity ^0.4.26;

 

 
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 

 
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

contract LockableToken is Ownable {

  event Lock(address indexed spender, uint256 value);

  using SafeMath for uint256;

  mapping(address => uint256) internal locked;

  function lock(address _spender, uint256 _value) public onlyOwner returns (bool) {
    if ((_value != 0) && (locked[_spender] != 0)) revert();

    locked[_spender] = _value;
    emit Lock(_spender, _value);
    return true;
  }

  function locking(address _spender) public view returns (uint256) {
    return locked[_spender];
  }

  function increaseLocking(address _spender, uint _addedValue) public onlyOwner returns (bool) {
    locked[_spender] = locked[_spender].add(_addedValue);
    emit Lock(_spender, locked[_spender]);
    return true;
  }

  function decreaseLocking(address _spender, uint _subtractedValue) public onlyOwner returns (bool) {
    uint oldValue = locked[_spender];
    if (_subtractedValue > oldValue) {
      locked[_spender] = 0;
    } else {
      locked[_spender] = oldValue.sub(_subtractedValue);
    }
    emit Lock(_spender, locked[_spender]);
    return true;
  }

}

 

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

 
contract BasicToken is ERC20Basic, LockableToken {

  mapping(address => uint256) balances;

  uint256 totalSupply_;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    require(locked[msg.sender] <= balances[msg.sender].sub(_value));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

 

 
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

   
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
     
     

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

 

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

 
contract StandardToken is ERC20, BasicToken {

  mapping(address => mapping(address => uint256)) internal allowed;


   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(locked[_from] <= balances[_from].sub(_value));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
     
     
     
     
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) revert();

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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

}

contract MintableToken is StandardToken {
   
  function mint(
    address _to,
    uint256 _amount
  )
  public
  onlyOwner
  returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }
}

contract VIE is StandardToken, BurnableToken, MintableToken {
   
  string  public constant name = "Viecology";
  string  public constant symbol = "VIE";
  uint8   public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 1899000000 * (10 ** uint256(decimals));
  address constant holder = 0xBC878377b22FADD7Edcd7e6CCB6334038a4Ef8Ec;

  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[holder] = INITIAL_SUPPLY;
    emit Transfer(address(0), holder, INITIAL_SUPPLY);
  }

  function() external payable {
    revert();
  }

}