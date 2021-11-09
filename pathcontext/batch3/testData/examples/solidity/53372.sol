pragma solidity ^0.4.24;

 

 
contract Initializable {

   
  bool private initialized;

   
  bool private initializing;

   
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

   
  function isConstructor() private view returns (bool) {
     
     
     
     
     
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

   
  uint256[50] private ______gap;
}

 

 
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

   
  function add(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = true;
  }

   
  function remove(Role storage role, address account) internal {
    require(account != address(0));
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

 

contract PauserRole is Initializable {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  function initialize(address sender) public initializer {
    if (!isPauser(sender)) {
      _addPauser(sender);
    }
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }

  uint256[50] private ______gap;
}

 

 
contract Pausable is Initializable, PauserRole {
  event Paused();
  event Unpaused();

  bool private _paused = false;

  function initialize(address sender) public initializer {
    PauserRole.initialize(sender);
  }

   
  function paused() public view returns(bool) {
    return _paused;
  }

   
  modifier whenNotPaused() {
    require(!_paused);
    _;
  }

   
  modifier whenPaused() {
    require(_paused);
    _;
  }

   
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused();
  }

   
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused();
  }

  uint256[50] private ______gap;
}

 

contract HODL_0 is Pausable {

    modifier hashDoesNotExist(string _hash){
        if(hashExistsMap[_hash] == true) revert();
        _;
    }

    mapping (string => address) hashToSender;
    mapping (string => uint) hashToTimestamp;
    mapping (string => bool) hashExistsMap;
    mapping (address => mapping (address => bool)) userOptOut;

    string[] public hashes;

    event AddedBatch(address indexed from, string hash, uint256 timestamp);
    event UserOptOut(address user, address appAddress, uint256 timestamp);
    event UserOptIn(address user, address appAddress, uint256 timestamp);

    function initialize() initializer public {
        hashes.push("hodl-genesis");
        hashToSender["hodl-genesis"] = msg.sender;
        hashToTimestamp["hodl-genesis"] = now;
        hashExistsMap["hodl-genesis"] = true;
    }

    function storeBatch(string _hash) public whenNotPaused hashDoesNotExist(_hash) {
        hashes.push(_hash);
        hashToSender[_hash] = msg.sender;
        hashToTimestamp[_hash] = now;
        hashExistsMap[_hash] = true;
        emit AddedBatch(msg.sender, _hash, now);
    }

    
    function opt(address appAddress) public whenNotPaused {
        bool userOptState = userOptOut[msg.sender][appAddress];
        if(userOptState == false){
            userOptOut[msg.sender][appAddress] = true;
            emit UserOptIn(msg.sender, appAddress, now);
        }
        else{
            userOptOut[msg.sender][appAddress] = false;
            emit UserOptOut(msg.sender, appAddress, now);
        }
    }

    function getSenderByHash(string _hash) public view returns (address) {
        return hashToSender[_hash];
    }
    
    function getTimestampByHash(string _hash) public view returns (uint) {
        return hashToTimestamp[_hash];
    }

    function getUserOptState(address userAddress, address appAddress) public view returns (bool){
        return userOptOut[userAddress][appAddress];
    }

}