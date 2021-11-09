pragma solidity ^0.4.24;


 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



 
library Math {
  function max64(uint64 _a, uint64 _b) internal pure returns (uint64) {
    return _a >= _b ? _a : _b;
  }

  function min64(uint64 _a, uint64 _b) internal pure returns (uint64) {
    return _a < _b ? _a : _b;
  }

  function max256(uint256 _a, uint256 _b) internal pure returns (uint256) {
    return _a >= _b ? _a : _b;
  }

  function min256(uint256 _a, uint256 _b) internal pure returns (uint256) {
    return _a < _b ? _a : _b;
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












 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

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
    require(_value <= balances[_from]);
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



 
contract JinToken is StandardToken, Ownable {
  using SafeMath for uint256;
  using Math for uint256;

   
  string public name = "JINYITONG";
  string public symbol = "JIN";
   
  uint8 public decimals = 5;
   
  uint256 public INITIAL_SUPPLY =
    314000000
  * (10 ** uint256(decimals));
   

  enum LockingType {
    PRESALE1, PRESALE2, PRESALE3, PRESALE4, PRESALE5,
    CROWDSALE,
    STARTUP, ANGELFUND, TECHTEAM,
    COUNT
  }

  mapping (uint256 => mapping (address => uint256)) private lockedAmount;
  mapping (uint256 => mapping (address => uint256)) private alreadyClaim;

  mapping (uint256 => uint256) private cliffs;
   
   
  uint256 fullRatio = 100;
  uint256 aMonth = 30 days;

  constructor () public {
     
    balances[msg.sender] = INITIAL_SUPPLY;
    totalSupply_ = INITIAL_SUPPLY;

    cliffs[uint256(LockingType.PRESALE1)] = 1543622400;  
    cliffs[uint256(LockingType.PRESALE2)] = 1548979200;  
    cliffs[uint256(LockingType.PRESALE3)] = 1554076800;  
    cliffs[uint256(LockingType.PRESALE4)] = 1559347200;  
    cliffs[uint256(LockingType.PRESALE5)] = 1564617600;  
    cliffs[uint256(LockingType.CROWDSALE)] = 1567296000;  
    cliffs[uint256(LockingType.STARTUP)] = 1577836800;  
    cliffs[uint256(LockingType.ANGELFUND)] = 1567296000;  
    cliffs[uint256(LockingType.TECHTEAM)] = 1567296000;  

     
     
     
     
     
     
     
     
     
  }

  event TransferToLock(
    address indexed from,
    address indexed to,
    uint256 value,
    uint256 lockingType,
    uint256 totalLocked
  );

  modifier hasTransferToLockPermission() {
    require(msg.sender == owner);
    _;
  }

  function transferToLock (
    address receiver,
    uint256 amount,
    uint256 lockingType
  ) public hasTransferToLockPermission returns (bool) {
    address _from = msg.sender;
    address _to = receiver;
    uint256 _value = amount;
    mapping (address => uint256) locked = lockedAmount[lockingType];

     
     
    require(lockingType < uint256(LockingType.COUNT));

    balances[_from] = balances[_from].sub(_value);
    locked[_to] = locked[_to].add(_value);

    emit TransferToLock(_from, _to, _value, lockingType, locked[_to]);

    return true;

     
     
     
     
     

     
     
     
     
     

     
  }

  function claimToken (address user, uint256 lockingType) public returns (bool) {
    uint256 _now = getTime();
    uint256 _cliff = cliffs[lockingType];

    require(lockingType < uint256(LockingType.COUNT));
    require(_now >= _cliff);

    if (lockingType == uint256(LockingType.CROWDSALE)) {
      require (amountInLock(user, lockingType) > 0);
      balances[user] = balances[user].add(lockedAmount[lockingType][user]);
      alreadyClaim[lockingType][user] = lockedAmount[lockingType][user];
      return true;
    } else if (lockingType == uint256(LockingType.PRESALE1)
      || lockingType == uint256(LockingType.PRESALE2)
      || lockingType == uint256(LockingType.PRESALE3)
      || lockingType == uint256(LockingType.PRESALE4)
      || lockingType == uint256(LockingType.PRESALE5)) {
      uint256 approved = approvedRatio(_now, _cliff, 20, 10);
      uint256 availableToClaim =
        lockedAmount[lockingType][user].mul(approved).div(fullRatio);
      uint256 amountToClaim = availableToClaim.sub(alreadyClaim[lockingType][user]);
      require (amountToClaim > 0);

      balances[user] = balances[user].add(amountToClaim);
      alreadyClaim[lockingType][user] = availableToClaim;

      return true;
    }

    return false;
  }

  function approvedRatio (
    uint256 _now,
    uint256 _cliff,
    uint256 baseRatio,
    uint256 incrRatio
  ) public view returns (uint256) {
      baseRatio = 20;
      incrRatio = 10;
      return Math.min256(
        fullRatio,
        _now
        .sub( _cliff )
        .div( aMonth )
        .mul( incrRatio )
        .add( baseRatio )
      );
  }

  function amountInLock (address user, uint256 lockType) public view returns (uint256) {
    return lockedAmount[lockType][user].sub(alreadyClaim[lockType][user]);
  }

  function getTime () public view returns (uint256) {
    return now;
  }

  function getLockingTypeCount () public pure returns (uint256) {
    return uint256(LockingType.COUNT);
  }
}