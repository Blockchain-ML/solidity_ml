pragma solidity ^0.4.24;


 
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


contract IAmRich is Ownable {
  using SafeMath for uint;

  event richPersonChanged(
    address indexed _addr,
    string _name,
    string _msg,
    uint indexed _amount
  );

  struct Person {
    address addr;
    string name;
    string msg;
    uint amount;
  }

  Person public richPerson;
  uint amountIncrease;
  uint public nextAmount;

  constructor(string _name, string _msg, uint _incr) public {
    richPerson = Person(msg.sender, _name, _msg, 1 ether);
    amountIncrease = _incr;
    _updateNextAmount();
  }

  function proofOfRich(string _name, string _msg) external payable {
    require(msg.value > nextAmount, "You are not rich enough.");
    richPerson = Person(msg.sender, _name, _msg, msg.value);
    emit richPersonChanged(msg.sender, _name, _msg, msg.value);
    _updateNextAmount();
  }

  function updateAmountIncrease(uint _incr) external onlyOwner {
    require(_incr > 100, "Amount increase should be more than 100.");
    amountIncrease = _incr;
    _updateNextAmount();
  }

  function claim() external onlyOwner {
    owner.transfer(address(this).balance);
  }

  function _updateNextAmount() private {
    nextAmount = richPerson.amount.mul(amountIncrease).div(100);
  }
}