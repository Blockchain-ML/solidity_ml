pragma solidity ^0.4.24;


 
 
 
 
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
}

 
contract Claimable is Ownable {
  address public pendingOwner;

  event OwnershipTransferPending(address indexed owner, address indexed pendingOwner);

   
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

   
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferPending(owner, pendingOwner);
    pendingOwner = newOwner;
  }

   
  function claimOwnership() onlyPendingOwner public {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

 
 
 
 
contract Pausable is Claimable {
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

 
 
 
 
contract Administratable is Claimable {
  mapping(address => bool) public admins;

  event AdminAddressAdded(address indexed addr);
  event AdminAddressRemoved(address indexed addr);

   
  modifier onlyAdmin() {
    require(admins[msg.sender] || msg.sender == owner);
    _;
  }

   
  function addAddressToAdmin(address addr) onlyOwner public returns(bool success) {
    if (!admins[addr]) {
      admins[addr] = true;
      emit AdminAddressAdded(addr);
      success = true;
    }
  }

   
  function removeAddressFromAdmin(address addr) onlyOwner public returns(bool success) {
    if (admins[addr]) {
      admins[addr] = false;
      emit AdminAddressRemoved(addr);
      success = true;
    }
  }
}

 
contract Callable is Claimable {
  mapping(address => bool) public callers;

  event CallerAddressAdded(address indexed addr);
  event CallerAddressRemoved(address indexed addr);


   
  modifier onlyCaller() {
    require(callers[msg.sender] || msg.sender == owner);
    _;
  }

   
  function addAddressToCaller(address addr) onlyOwner public returns(bool success) {
    if (!callers[addr]) {
      callers[addr] = true;
      emit CallerAddressAdded(addr);
      success = true;
    }
  }

   
  function removeAddressFromCaller(address addr) onlyOwner public returns(bool success) {
    if (callers[addr]) {
      callers[addr] = false;
      emit CallerAddressRemoved(addr);
      success = true;
    }
  }
}
 
 
 
 
contract Blacklist is Callable {
  mapping(address => bool) public blacklist;

  function addAddressToBlacklist(address addr) onlyCaller public returns (bool success) {
    if (!blacklist[addr]) {
      blacklist[addr] = true;
      success = true;
    }
  }

  function removeAddressFromBlacklist(address addr) onlyCaller public returns (bool success) {
    if (blacklist[addr]) {
      blacklist[addr] = false;
      success = true;
    }
  }
}

 
 
 
 
contract Verified is Callable {
  mapping(address => bool) public verifiedList;

  function verifyAddress(address addr) onlyCaller public returns (bool success) {
    if (!verifiedList[addr]) {
      verifiedList[addr] = true;
      success = true;
    }
  }

  function unverifyAddress(address addr) onlyCaller public returns (bool success) {
    if (verifiedList[addr]) {
      verifiedList[addr] = false;
      success = true;
    }
  }
}



 
 
 
contract Allowance is Callable {
  using SafeMath for uint256;

  mapping (address => mapping (address => uint256)) public allowanceOf;

  function addAllowance(address _holder, address _spender, uint256 _value) onlyCaller public {
    allowanceOf[_holder][_spender] = allowanceOf[_holder][_spender].add(_value);
  }

  function subAllowance(address _holder, address _spender, uint256 _value) onlyCaller public {
    uint256 oldValue = allowanceOf[_holder][_spender];
    if (_value > oldValue) {
      allowanceOf[_holder][_spender] = 0;
    } else {
      allowanceOf[_holder][_spender] = oldValue.sub(_value);
    }
  }

  function setAllowance(address _holder, address _spender, uint256 _value) onlyCaller public {
    allowanceOf[_holder][_spender] = _value;
  }
}

 
 
 
contract Balance is Callable {
  using SafeMath for uint256;

  mapping (address => uint256) public balanceOf;

  uint256 public totalSupply;

  function addBalance(address _addr, uint256 _value) onlyCaller public {
    balanceOf[_addr] = balanceOf[_addr].add(_value);
  }

  function subBalance(address _addr, uint256 _value) onlyCaller public {
    balanceOf[_addr] = balanceOf[_addr].sub(_value);
  }

  function setBalance(address _addr, uint256 _value) onlyCaller public {
    balanceOf[_addr] = _value;
  }

  function addTotalSupply(uint256 _value) onlyCaller public {
    totalSupply = totalSupply.add(_value);
  }

  function subTotalSupply(uint256 _value) onlyCaller public {
    totalSupply = totalSupply.sub(_value);
  }
}

contract UserContract {
  Blacklist internal _blacklist;
  Verified internal _verifiedList;

  constructor(
    Blacklist _blacklistContract, Verified _verifiedListContract
  ) public {
    _blacklist = _blacklistContract;
    _verifiedList = _verifiedListContract;
  }


   
  modifier onlyNotBlacklistedAddr(address addr) {
    require(!_blacklist.blacklist(addr));
    _;
  }

   
  modifier onlyNotBlacklistedAddrs(address[] addrs) {
    for (uint256 i = 0; i < addrs.length; i++) {
      require(!_blacklist.blacklist(addrs[i]));
    }
    _;
  }

   
  modifier onlyVerifiedAddr(address addr) {
    require(_verifiedList.verifiedList(addr));
    _;
  }

   
  modifier onlyVerifiedAddrs(address[] addrs) {
    for (uint256 i = 0; i < addrs.length; i++) {
      require(_verifiedList.verifiedList(addrs[i]));
    }
    _;
  }

  function blacklist(address addr) public view returns (bool) {
    return _blacklist.blacklist(addr);
  }

  function verifiedlist(address addr) public view returns (bool) {
    return _verifiedList.verifiedList(addr);
  }
}

contract AdminContract is Pausable, Administratable, UserContract {

  Balance internal _balances;

  uint256 constant maxBLBatch = 100;

  constructor(
    Balance _balanceContract, Blacklist _blacklistContract, Verified _verifiedListContract
  ) UserContract(_blacklistContract, _verifiedListContract) public {
    _balances = _balanceContract;
  }

   
  event Burn(address indexed from, uint256 value);
   
  event Mint(address indexed to, uint256 value);

  event VerifiedAddressAdded(address indexed addr);
  event VerifiedAddressRemoved(address indexed addr);

  event BlacklistedAddressAdded(address indexed addr);
  event BlacklistedAddressRemoved(address indexed addr);

   
  function _addToBlacklist(address addr) internal returns (bool success) {
    success = _blacklist.addAddressToBlacklist(addr);
    if (success) {
      emit BlacklistedAddressAdded(addr);
    }
  }

  function _removeFromBlacklist(address addr) internal returns (bool success) {
    success = _blacklist.removeAddressFromBlacklist(addr);
    if (success) {
      emit BlacklistedAddressRemoved(addr);
    }
  }

   
  function addAddressToBlacklist(address addr) onlyAdmin whenNotPaused public returns (bool) {
    return _addToBlacklist(addr);
  }

   
  function addAddressesToBlacklist(address[] addrs) onlyAdmin whenNotPaused public returns (bool success) {
    uint256 cnt = uint256(addrs.length);
    require(cnt <= maxBLBatch);
    success = true;
    for (uint256 i = 0; i < addrs.length; i++) {
      if (!_addToBlacklist(addrs[i])) {
        success = false;
      }
    }
  }

   
  function removeAddressFromBlacklist(address addr) onlyAdmin whenNotPaused public returns (bool) {
    return _removeFromBlacklist(addr);
  }

   
  function removeAddressesFromBlacklist(address[] addrs) onlyAdmin whenNotPaused public returns (bool success) {
    success = true;
    for (uint256 i = 0; i < addrs.length; i++) {
      if (!_removeFromBlacklist(addrs[i])) {
        success = false;
      }
    }
  }

   
  function _verifyAddress(address addr) internal returns (bool success) {
    success = _verifiedList.verifyAddress(addr);
    if (success) {
      emit VerifiedAddressAdded(addr);
    }
  }

  function _unverifyAddress(address addr) internal returns (bool success) {
    success = _verifiedList.unverifyAddress(addr);
    if (success) {
      emit VerifiedAddressRemoved(addr);
    }
  }

   
  function verifyAddress(address addr) onlyAdmin onlyNotBlacklistedAddr(addr) whenNotPaused public returns (bool) {
    return _verifyAddress(addr);
  }

   
  function verifyAddresses(address[] addrs) onlyAdmin onlyNotBlacklistedAddrs(addrs) whenNotPaused public returns (bool success) {
    success = true;
    for (uint256 i = 0; i < addrs.length; i++) {
      if (!_verifyAddress(addrs[i])) {
        success = false;
      }
    }
  }


   
  function unverifyAddress(address addr) onlyAdmin whenNotPaused public returns (bool) {
    return _unverifyAddress(addr);
  }


   
  function unverifyAddresses(address[] addrs) onlyAdmin whenNotPaused public returns (bool success) {
    success = true;
    for (uint256 i = 0; i < addrs.length; i++) {
      if (!_unverifyAddress(addrs[i])) {
        success = false;
      }
    }
  }

   
  function burnFrom(address _from, uint256 _value) onlyOwner whenNotPaused
  public returns (bool success) {
    require(_balances.balanceOf(_from) >= _value);     
    _balances.subBalance(_from, _value);               
    _balances.subTotalSupply(_value);
    emit Burn(_from, _value);
    return true;
  }

   
  function mint(address _to, uint256 _amount)
  onlyOwner whenNotPaused onlyNotBlacklistedAddr(_to) onlyVerifiedAddr(_to)
  public returns (bool success) {
    _balances.addBalance(_to, _amount);
    _balances.addTotalSupply(_amount);
    emit Mint(_to, _amount);
    return true;
  }
}