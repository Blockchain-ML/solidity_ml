pragma solidity ^0.4.25;

 

 

pragma solidity ^0.4.25;

 
contract Ownable {

   
  address private _owner;

   
  event OwnershipTransferred(address previousOwner, address newOwner);

   
  constructor() public {
    setOwner(msg.sender);
  }

   
  function owner() public view returns (address) {
    return _owner;
  }

   
  function setOwner(address newOwner) internal {
    _owner = newOwner;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner());
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner(), newOwner);
    setOwner(newOwner);
  }
}

 

contract DelegateContract is Ownable {
  address delegate_;

   
  modifier onlyFromAccpet() {
    require(msg.sender == delegate_);
    _;
  }

  function setLogicContractAddress(address _addr) public onlyOwner {
    delegate_ = _addr;
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

 

 
contract AllowanceSheet is DelegateContract {
  using SafeMath for uint256;

  mapping (address => mapping (address => uint256)) public allowanceOf;

  function addAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyFromAccpet {
    allowanceOf[_tokenHolder][_spender] = allowanceOf[_tokenHolder][_spender].add(_value);
  }

  function subAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyFromAccpet {
    allowanceOf[_tokenHolder][_spender] = allowanceOf[_tokenHolder][_spender].sub(_value);
  }

  function setAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyFromAccpet {
    allowanceOf[_tokenHolder][_spender] = _value;
  }
}

 

 
contract BalanceSheet is DelegateContract, AllowanceSheet {
  using SafeMath for uint256;

  mapping (address => uint256) public balanceOf;

  function addBalance(address _addr, uint256 _value) public onlyFromAccpet {
    balanceOf[_addr] = balanceOf[_addr].add(_value);
  }

  function subBalance(address _addr, uint256 _value) public onlyFromAccpet {
    balanceOf[_addr] = balanceOf[_addr].sub(_value);
  }

  function setBalance(address _addr, uint256 _value) public onlyFromAccpet {
    balanceOf[_addr] = _value;
  }

}