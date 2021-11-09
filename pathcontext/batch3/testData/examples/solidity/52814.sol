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

 

contract RVContractDB is Ownable {
  uint TYPE_CROWDSALE = 1;
  uint TYPE_TOKEN = 2;
  uint TYPE_MULTISIGWALLET = 3;

  struct UserContract {
    address ownerAddress;
    address contractAddress;
    uint contractType;
    string contractName;
    bool isUse;
  }

  mapping (address => UserContract[]) public userContract;

  event ContractAddtion();
  event ContractRemoval();

  modifier hasContract(address _ownerAddress) {
    require(userContract[_ownerAddress].length > 0, "The address has no contracts.");
    _;
  }

  function addContract(address _ownerAddress, address _contractAddress, uint _contractType, string _contractName) public onlyOwner {
    userContract[_ownerAddress].push(UserContract({
      ownerAddress : _ownerAddress,
      contractAddress : _contractAddress,
      contractType : _contractType,
      contractName : _contractName,
      isUse : true
    }));

    emit ContractAddtion();
  }

  function removeContract(address _ownerAddress, address _contractAddress) public onlyOwner hasContract(_ownerAddress) {
    for (uint i=0 ; i<userContract[_ownerAddress].length ; i++) {
      if( userContract[_ownerAddress][i].contractAddress == _contractAddress ) {
        userContract[_ownerAddress][i].isUse = false;
      }
    }

    emit ContractRemoval();
  }

  function getUserContract(address _ownerAddress, uint index) public view hasContract(_ownerAddress) returns (address, uint, bool, string) {
    require(index < userContract[_ownerAddress].length, "");

    return (userContract[_ownerAddress][index].contractAddress, userContract[_ownerAddress][index].contractType, userContract[_ownerAddress][index].isUse, userContract[_ownerAddress][index].contractName);
  }

  function getUserContractCount(address _ownerAddress) public view returns (uint) {
    return userContract[_ownerAddress].length;
  }
}