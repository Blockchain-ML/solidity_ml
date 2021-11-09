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

 

contract Parent1 is Ownable {
    uint internal value1;

    constructor(uint _value) public {
        setValue1(_value);
    }

    function setValue1(uint _value) public onlyOwner {
        value1 = _value;
    }

    function getValue1() public view returns (uint) {
        return value1;
    }
}

contract Parent2 is Ownable {
    uint internal value2;

    constructor(uint _value) public {
        setValue2(_value);
    }

    function setValue2(uint _value) public onlyOwner {
        value2 = _value;
    }

    function getValue2() public view returns (uint) {
        return value2;
    }
}

contract TestMultipleInheritance is Parent1(1), Parent2(2) {}