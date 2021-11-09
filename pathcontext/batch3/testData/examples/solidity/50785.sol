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




contract Whitelist is Ownable {

  mapping (address => mapping (address => bool)) public list;

  event LogWhitelistAdded(address indexed participant, uint256 timestamp);
  event LogWhitelistDeleted(address indexed participant, uint256 timestamp);

  constructor() public {}

  function isWhite(address _contract, address addr) public view returns (bool) {
    return list[_contract][addr];
  }

  function addWhitelist(address _contract, address[] addrs) public onlyOwner returns (bool) {
    for (uint256 i = 0; i < addrs.length; i++) {
      list[_contract][addrs[i]] = true;

      emit LogWhitelistAdded(addrs[i], now);
    }

    return true;
  }

  function delWhitelist(address _contract, address[] addrs) public onlyOwner returns (bool) {
    for (uint256 i = 0; i < addrs.length; i++) {
      list[_contract][addrs[i]] = false;

      emit LogWhitelistDeleted(addrs[i], now);
    }

    return true;
  }
}