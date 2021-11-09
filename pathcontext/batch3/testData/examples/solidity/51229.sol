pragma solidity ^0.4.24;

 
 
contract Ownable {
  address private _owner;
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );
   
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }
   
  function owner() public view returns(address) {
    return _owner;
  }
   
  modifier onlyOwner() {
    require(isOwner());
    _;
  }
   
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }
   
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
   
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }
   
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
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

contract OCPTokenExchange is Ownable {
  OCPToken public oct;
  uint256 public ethToOCTNumerator;
  uint256 public ethToOCTDenominator;
  mapping(address => uint256) public pendingOCT;
  constructor(address _oct) public {
    oct = OCPToken(_oct);
    ethToOCTNumerator = 1;
    ethToOCTDenominator = 1;
  }
  function () external payable {
    pendingOCT[msg.sender] += (msg.value * ethToOCTNumerator) / ethToOCTDenominator;
  }
  function setRates(uint256 _ethToOCTNumerator, uint256 _ethToOCTDenominator) public onlyOwner {
    ethToOCTNumerator = _ethToOCTNumerator;
    ethToOCTDenominator = _ethToOCTDenominator;
  }
  function collectOCT() public {
    uint256 value = pendingOCT[msg.sender];
    pendingOCT[msg.sender] = 0;
    owner().transfer(address(this).balance);
    oct.transfer(msg.sender, value);
  }
}