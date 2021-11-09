pragma solidity ^0.4.18;

 

 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  function Ownable() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 

 
contract HasNoEther is Ownable {

   
  function HasNoEther() public payable {
    require(msg.value == 0);
  }

   
  function() external {
  }

   
  function reclaimEther() external onlyOwner {
    assert(owner.send(this.balance));
  }
}

 

contract Pausable {

  bool public paused;
}


 


contract TweedentityRegistry
is HasNoEther
{

  string public version = "1.4.0";

  uint public totalStores;
  mapping (bytes32 => address) private stores;

  address public manager;
  address public claimer;

  event ContractRegistered(
    bytes32 indexed key,
    string spec,
    address addr
  );


  function setManager(
    address _manager
  )
  external
  onlyOwner
  {
    require(_manager != address(0));
    manager = _manager;
    ContractRegistered(keccak256("manager"), "", _manager);
  }


  function setClaimer(
    address _claimer
  )
  external
  onlyOwner
  {
    require(_claimer != address(0));
    claimer = _claimer;
    ContractRegistered(keccak256("claimer"), "", _claimer);
  }


  function setManagerAndClaimer(
    address _manager,
    address _claimer
  )
  external
  onlyOwner
  {
    require(_manager != address(0));
    require(_claimer != address(0));
    manager = _manager;
    claimer = _claimer;
    ContractRegistered(keccak256("manager"), "", _manager);
    ContractRegistered(keccak256("claimer"), "", _claimer);
  }


  function setAStore(
    string _appNickname,
    address _store
  )
  external
  onlyOwner
  {
    require(_store != address(0));
    if (getStore(_appNickname) == address(0)) {
      totalStores++;
    }
    stores[keccak256(_appNickname)] = _store;
    ContractRegistered(keccak256("store"), _appNickname, _store);
  }


   
  function getStore(
    string _appNickname
  )
  public
  constant returns(address)
  {
    return stores[keccak256(_appNickname)];
  }


   
  function isReady()
  external
  constant returns(bool)
  {
    Pausable pausable = Pausable(manager);
    return totalStores > 0 && manager != address(0) && claimer != address(0) && pausable.paused() == false;
  }

}