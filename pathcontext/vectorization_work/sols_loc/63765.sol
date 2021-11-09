pragma solidity ^0.4.24;

 
 
 
 
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }
   
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));
    role.bearer[account] = true;
  }
   
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));
    role.bearer[account] = false;
  }
   
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

contract ProxyManagerRole {
  using Roles for Roles.Role;
  event ProxyManagerAdded(address indexed account);
  event ProxyManagerRemoved(address indexed account);
  Roles.Role private proxyManagers;
  constructor() public {
    proxyManagers.add(msg.sender);
  }
  modifier onlyProxyManager() {
    require(isProxyManager(msg.sender));
    _;
  }
  function isProxyManager(address account) public view returns (bool) {
    return proxyManagers.has(account);
  }
  function addProxyManager(address account) public onlyProxyManager {
    proxyManagers.add(account);
    emit ProxyManagerAdded(account);
  }
  function renounceProxyManager() public {
    proxyManagers.remove(msg.sender);
  }
  function _removeProxyManager(address account) internal {
    proxyManagers.remove(account);
    emit ProxyManagerRemoved(account);
  }
}

 
contract Proxiable is ProxyManagerRole {
  mapping(address => bool) private _globalProxies;  
  mapping(address => mapping(address => bool)) private _senderProxies;  
  event ProxyAdded(address indexed proxy, uint256 updatedAtUtcSec);
  event ProxyRemoved(address indexed proxy, uint256 updatedAtUtcSec);
  event ProxyForSenderAdded(address indexed proxy, address indexed sender, uint256 updatedAtUtcSec);
  event ProxyForSenderRemoved(address indexed proxy, address indexed sender, uint256 updatedAtUtcSec);
  modifier proxyOrSender(address claimedSender) {
    require(isProxyOrSender(claimedSender));
    _;
  }
  function isProxyOrSender(address claimedSender) public view returns (bool) {
    return msg.sender == claimedSender ||
    _globalProxies[msg.sender] ||
    _senderProxies[claimedSender][msg.sender];
  }
  function isProxy(address proxy) public view returns (bool) {
    return _globalProxies[proxy];
  }
  function isProxyForSender(address proxy, address sender) public view returns (bool) {
    return _senderProxies[sender][proxy];
  }
  function addProxy(address proxy) public onlyProxyManager {
    require(!_globalProxies[proxy]);
    _globalProxies[proxy] = true;
    emit ProxyAdded(proxy, now);  
  }
  function removeProxy(address proxy) public onlyProxyManager {
    require(_globalProxies[proxy]);
    delete _globalProxies[proxy];
    emit ProxyRemoved(proxy, now);  
  }
  function addProxyForSender(address proxy, address sender) public proxyOrSender(sender) {
    require(!_senderProxies[sender][proxy]);
    _senderProxies[sender][proxy] = true;
    emit ProxyForSenderAdded(proxy, sender, now);  
  }
  function removeProxyForSender(address proxy, address sender) public proxyOrSender(sender) {
    require(_senderProxies[sender][proxy]);
    delete _senderProxies[sender][proxy];
    emit ProxyForSenderRemoved(proxy, sender, now);  
  }
}

 
 
 
  
contract ContractReceiver {
  function tokenFallback(address _from, uint256 _value, bytes _data) public;
}

 
  
contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) public view returns (uint);
  function name() public view returns (string _name);
  function symbol() public view returns (string _symbol);
  function decimals() public view returns (uint8 _decimals);
  function totalSupply() public view returns (uint256 _supply);
  function transfer(address to, uint value) public returns (bool ok);
  function transfer(address to, uint value, bytes data) public returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) public returns (bool ok);
   
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}

  
  
contract SafeMathERC223 {
  uint256 constant public MAX_UINT256 =
  0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
  function safeAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
    if (x > MAX_UINT256 - y) revert();
    return x + y;
  }
  function safeSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
    if (x < y) revert();
    return x - y;
  }
  function safeMul(uint256 x, uint256 y) internal pure returns (uint256 z) {
    if (y == 0) return 0;
    if (x > MAX_UINT256 / y) revert();
    return x * y;
  }
}
contract ERC223Token is ERC223, SafeMathERC223 {
  mapping(address => uint) public balances;
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
   
  function name() public view returns (string _name) {
    return name;
  }
   
  function symbol() public view returns (string _symbol) {
    return symbol;
  }
   
  function decimals() public view returns (uint8 _decimals) {
    return decimals;
  }
   
  function totalSupply() public view returns (uint256 _totalSupply) {
    return totalSupply;
  }
   
  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
    if (isContract(_to)) {
      return transferToContractCustom(msg.sender, _to, _value, _data, _custom_fallback);
    } else {
      return transferToAddress(msg.sender, _to, _value, _data);
    }
  }
   
  function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
    if (isContract(_to)) {
      return transferToContract(msg.sender, _to, _value, _data);
    } else {
      return transferToAddress(msg.sender, _to, _value, _data);
    }
  }
   
   
  function transfer(address _to, uint _value) public returns (bool success) {
     
     
    bytes memory empty;
    if (isContract(_to)) {
      return transferToContract(msg.sender, _to, _value, empty);
    } else {
      return transferToAddress(msg.sender, _to, _value, empty);
    }
  }
  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
   
  function isContract(address _addr) internal view returns (bool is_contract) {
    uint length;
    assembly {  
           
          length := extcodesize(_addr)
    }
    return (length > 0);
  }
   
  function transferToAddress(address _from, address _to, uint _value, bytes _data) internal returns (bool success) {
    if (balanceOf(_from) < _value) revert();
    balances[_from] = safeSub(balanceOf(_from), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    emit Transfer(_from, _to, _value, _data);
    return true;
  }
   
  function transferToContract(address _from, address _to, uint _value, bytes _data) internal returns (bool success) {
    if (balanceOf(_from) < _value) revert();
    balances[_from] = safeSub(balanceOf(_from), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(_from, _value, _data);
    emit Transfer(_from, _to, _value, _data);
    return true;
  }
   
  function transferToContractCustom(address _from, address _to, uint _value, bytes _data, string _custom_fallback) internal returns (bool success) {
    if (balanceOf(_from) < _value) revert();
    balances[_from] = safeSub(balanceOf(_from), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
     
    assert(_to.call.value(0)(abi.encodeWithSignature(_custom_fallback, _from, _value, _data)));
    emit Transfer(_from, _to, _value, _data);
    return true;
  }
}

contract OCPToken is ERC223Token {
  constructor() public {
    name = "Open City Token";
    symbol = "OCT";  
    decimals = 18;
    totalSupply = 0xc9f2c9cd04674edea40000000;  
    balances[msg.sender] = totalSupply;
  }
}

 
contract IOCPTokenProxiable is ERC223 {
  function proxyTransfer(address from, address to, uint value) public returns (bool ok);
  function proxyTransfer(address from, address to, uint value, bytes data) public returns (bool ok);
  function proxyTransfer(address from, address to, uint value, bytes data, string custom_fallback) public returns (bool ok);
}

contract OCPTokenProxiable is OCPToken, IOCPTokenProxiable, Proxiable {
   
  function proxyTransfer(
    address _from,
    address _to,
    uint _value,
    bytes _data,
    string _custom_fallback
  ) public proxyOrSender(_from) returns (bool success) {
    if (isContract(_to)) {
      return transferToContractCustom(_from, _to, _value, _data, _custom_fallback);
    } else {
      return transferToAddress(_from, _to, _value, _data);
    }
  }
   
  function proxyTransfer(
    address _from,
    address _to,
    uint _value,
    bytes _data
  ) public proxyOrSender(_from) returns (bool success) {
    if (isContract(_to)) {
      return transferToContract(_from, _to, _value, _data);
    } else {
      return transferToAddress(_from, _to, _value, _data);
    }
  }
   
   
  function proxyTransfer(
    address _from,
    address _to,
    uint _value
  ) public proxyOrSender(_from) returns (bool success) {
     
     
    bytes memory empty;
    if (isContract(_to)) {
      return transferToContract(_from, _to, _value, empty);
    } else {
      return transferToAddress(_from, _to, _value, empty);
    }
  }
}