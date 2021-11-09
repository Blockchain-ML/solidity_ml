pragma solidity ^0.4.13;

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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

contract Pausable is Ownable {
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

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract Destructible is Ownable {

  constructor() public payable { }

   
  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
  }
}

contract LinniaPermissions is Ownable, Pausable, Destructible {
    struct Permission {
        bool canAccess;
         
        string dataUri;
    }

    event LinniaAccessGranted(bytes32 indexed dataHash, address indexed owner,
        address indexed viewer
    );
    event LinniaAccessRevoked(bytes32 indexed dataHash, address indexed owner,
        address indexed viewer
    );

    LinniaHub public hub;
     
    mapping(bytes32 => mapping(address => Permission)) public permissions;

     
    modifier onlyUser() {
        require(hub.usersContract().isUser(msg.sender) == true);
        _;
    }

    modifier onlyRecordOwnerOf(bytes32 dataHash) {
        require(hub.recordsContract().recordOwnerOf(dataHash) == msg.sender);
        _;
    }

     
    constructor(LinniaHub _hub) public {
        hub = _hub;
    }

     
    function () public { }

     

     
     
     
    function checkAccess(bytes32 dataHash, address viewer)
    view
    external
    returns (bool)
    {
        return permissions[dataHash][viewer].canAccess;
    }

     
     
     
     
     
    function grantAccess(bytes32 dataHash, address viewer, string dataUri)
    onlyUser
    onlyRecordOwnerOf(dataHash)
    whenNotPaused
    external
    returns (bool)
    {
         
        require(viewer != address(0));
        require(bytes(dataUri).length != 0);

         
         
         
        permissions[dataHash][viewer] = Permission({
            canAccess: true,
            dataUri: dataUri
            });
        emit LinniaAccessGranted(dataHash, msg.sender, viewer);
        return true;
    }

     
     
     
     
    function revokeAccess(bytes32 dataHash, address viewer)
    onlyUser
    onlyRecordOwnerOf(dataHash)
    whenNotPaused
    external
    returns (bool)
    {
         
        require(permissions[dataHash][viewer].canAccess);
        permissions[dataHash][viewer] = Permission({
            canAccess: false,
            dataUri: ""
            });
        emit LinniaAccessRevoked(dataHash, msg.sender, viewer);
        return true;
    }
}

contract LinniaRecords is Ownable, Pausable, Destructible {
    using SafeMath for uint;

     
     
     
    struct Record {
         
        address owner;
         
        bytes32 metadataHash;
         
        mapping (address => bool) sigs;
         
        uint sigCount;
         
        uint irisScore;
         
        string dataUri;
         
        uint timestamp;
    }

    event LinniaRecordAdded(
        bytes32 indexed dataHash, address indexed owner, string metadata
    );
    event LinniaRecordSigAdded(
        bytes32 indexed dataHash, address indexed attestator, uint irisScore
    );

    event LinniaReward (bytes32 indexed dataHash, address indexed owner, uint256 value, address tokenContract);

    LinniaHub public hub;
     
     
    mapping(bytes32 => Record) public records;

     

    modifier onlyUser() {
        require(hub.usersContract().isUser(msg.sender) == true);
        _;
    }

    modifier hasProvenance(address user) {
        require(hub.usersContract().provenanceOf(user) > 0);
        _;
    }

     
    constructor(LinniaHub _hub) public {
        hub = _hub;
    }

     
    function () public { }

     

    function addRecordByAdmin(
        bytes32 dataHash, address owner, address attestator,
        string metadata, string dataUri)
        onlyOwner
        whenNotPaused
        external
        returns (bool)
    {
        require(_addRecord(dataHash, owner, metadata, dataUri) == true);
        if (attestator != address(0)) {
            require(_addSig(dataHash, attestator));
        }
        return true;
    }

     

     
     
     
     
    function addRecord(
        bytes32 dataHash, string metadata, string dataUri)
        onlyUser
        whenNotPaused
        public
        returns (bool)
    {
        require(
            _addRecord(dataHash, msg.sender, metadata, dataUri) == true
        );
        return true;
    }

     
     
     
     
     
     
    function addRecordwithReward (
        bytes32 dataHash, string metadata, string dataUri, address token)
        onlyUser
        whenNotPaused
        public
    returns  (bool)
    {
         
        uint256 reward = 1 finney;
        require (token != address (0));
        require (token != address (this));
        ERC20 tokenInstance = ERC20 (token);
        require (
            _addRecord (dataHash, msg.sender, metadata, dataUri) == true
        );
         
        require(tokenInstance.transfer (msg.sender, reward));
        emit LinniaReward (dataHash, msg.sender, reward, token);
        return true;
    }

     
     
     
     
     
    function addRecordByProvider(
        bytes32 dataHash, address owner, string metadata, string dataUri)
        onlyUser
        hasProvenance(msg.sender)
        whenNotPaused
        public
        returns (bool)
    {
         
        require(_addRecord(dataHash, owner, metadata, dataUri) == true);
         
        require(_addSig(dataHash, msg.sender));
        return true;
    }

     
     
     
     
    function addSigByProvider(bytes32 dataHash)
        hasProvenance(msg.sender)
        whenNotPaused
        public
        returns (bool)
    {
        require(_addSig(dataHash, msg.sender));
        return true;
    }

     
     
     
     
     
     
     
     
     
     
    function addSig(bytes32 dataHash, bytes32 r, bytes32 s, uint8 v)
        public
        whenNotPaused
        returns (bool)
    {
         
        bytes32 rootHash = rootHashOf(dataHash);
         
        address provider = recover(rootHash, r, s, v);
         
        require(_addSig(dataHash, provider));
        return true;
    }

    function recover(bytes32 message, bytes32 r, bytes32 s, uint8 v)
        public pure returns (address)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, message));
        return ecrecover(prefixedHash, v, r, s);
    }

    function recordOwnerOf(bytes32 dataHash)
        public view returns (address)
    {
        return records[dataHash].owner;
    }

    function rootHashOf(bytes32 dataHash)
        public view returns (bytes32)
    {
        return keccak256(abi.encodePacked(dataHash, records[dataHash].metadataHash));
    }

    function sigExists(bytes32 dataHash, address provider)
        public view returns (bool)
    {
        return records[dataHash].sigs[provider];
    }

     

    function _addRecord(
        bytes32 dataHash, address owner, string metadata, string dataUri)
        internal
        returns (bool)
    {
         
        require(dataHash != 0);
        require(bytes(dataUri).length != 0);
        bytes32 metadataHash = keccak256(abi.encodePacked(metadata));

         
        require(records[dataHash].timestamp == 0);
         
        require(hub.usersContract().isUser(owner) == true);
         
        records[dataHash] = Record({
            owner: owner,
            metadataHash: metadataHash,
            sigCount: 0,
            irisScore: 0,
            dataUri: dataUri,
             
            timestamp: block.timestamp
        });
         
        emit LinniaRecordAdded(dataHash, owner, metadata);
        return true;
    }

    function _addSig(bytes32 dataHash, address provider)
        hasProvenance(provider)
        internal
        returns (bool)
    {
        Record storage record = records[dataHash];
         
        require(record.timestamp != 0);
         
        require(!record.sigs[provider]);
        uint provenanceScore = hub.usersContract().provenanceOf(provider);
         
        record.sigCount = record.sigCount.add(1);
        record.sigs[provider] = true;
         
        record.irisScore = record.irisScore.add(provenanceScore);
         
        emit LinniaRecordSigAdded(dataHash, provider, record.irisScore);
        return true;
    }
}

contract LinniaHub is Ownable, Destructible {
    LinniaUsers public usersContract;
    LinniaRecords public recordsContract;
    LinniaPermissions public permissionsContract;

    event LinniaUsersContractSet(address from, address to);
    event LinniaRecordsContractSet(address from, address to);
    event LinniaPermissionsContractSet(address from, address to);

    constructor() public { }

    function () public { }

    function setUsersContract(LinniaUsers _usersContract)
        onlyOwner
        external
        returns (bool)
    {
        address prev = address(usersContract);
        usersContract = _usersContract;
        emit LinniaUsersContractSet(prev, _usersContract);
        return true;
    }

    function setRecordsContract(LinniaRecords _recordsContract)
        onlyOwner
        external
        returns (bool)
    {
        address prev = address(recordsContract);
        recordsContract = _recordsContract;
        emit LinniaRecordsContractSet(prev, _recordsContract);
        return true;
    }

    function setPermissionsContract(LinniaPermissions _permissionsContract)
        onlyOwner
        external
        returns (bool)
    {
        address prev = address(permissionsContract);
        permissionsContract = _permissionsContract;
        emit LinniaPermissionsContractSet(prev, _permissionsContract);
        return true;
    }
}

contract LinniaUsers is Ownable, Pausable, Destructible {
    struct User {
        bool exists;
        uint registerBlocktime;
        uint provenance;
    }

    event LinniaUserRegistered(address indexed user);
    event LinniaProvenanceChanged(address indexed user, uint provenance);

    LinniaHub public hub;
    mapping(address => User) public users;

    constructor(LinniaHub _hub) public {
        hub = _hub;
    }

     
    function () public { }

     

     
    function register()
        whenNotPaused
        external
        returns (bool)
    {
        require(!isUser(msg.sender));
        users[msg.sender] = User({
            exists: true,
            registerBlocktime: block.number,
            provenance: 0
        });
        emit LinniaUserRegistered(msg.sender);
        return true;
    }

     
    function setProvenance(address user, uint provenance)
        onlyOwner
        external
        returns (bool)
    {
        require(isUser(user));
        users[user].provenance = provenance;
        emit LinniaProvenanceChanged(user, provenance);
        return true;
    }

     

    function isUser(address user)
        public
        view
        returns (bool)
    {
        return users[user].exists;
    }

    function provenanceOf(address user)
        public
        view
        returns (uint)
    {
        if (users[user].exists) {
            return users[user].provenance;
        } else {
            return 0;
        }
    }
}