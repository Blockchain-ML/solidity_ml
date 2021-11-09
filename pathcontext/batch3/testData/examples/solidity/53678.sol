pragma solidity 0.4.19;


contract Owned {
    address public owner;
    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    function Owned() { owner = msg.sender; }

    function isOwner(address addr) public returns(bool) { return addr == owner; }

    function transfer(address newOwner) public onlyOwner {
        if (newOwner != address(this)) {
            owner = newOwner;
        }
    }
}



contract Proxy is Owned {
    event Forwarded (address indexed destination, uint value, bytes data);
    event Received (address indexed sender, uint value);

    function () payable { Received(msg.sender, msg.value); }

    function forward(address destination, uint value, bytes data) public onlyOwner {
        require(executeCall(destination, value, data));
        Forwarded(destination, value, data);
    }

     
     
    function executeCall(address to, uint256 value, bytes data) internal returns (bool success) {
        assembly {
            success := call(gas, to, value, add(data, 0x20), mload(data), 0, 0)
        }
    }
}


contract IdentityManager {
    uint adminTimeLock;
    uint userTimeLock;
    uint adminRate;

    event LogIdentityCreated(
        address indexed identity,
        address indexed creator,
        address owner,
        address indexed recoveryKey);

    event LogOwnerAdded(
        address indexed identity,
        address indexed owner,
        address instigator);

    event LogOwnerRemoved(
        address indexed identity,
        address indexed owner,
        address instigator);

    event LogRecoveryChanged(
        address indexed identity,
        address indexed recoveryKey,
        address instigator);

    event LogMigrationInitiated(
        address indexed identity,
        address indexed newIdManager,
        address instigator);

    event LogMigrationCanceled(
        address indexed identity,
        address indexed newIdManager,
        address instigator);

    event LogMigrationFinalized(
        address indexed identity,
        address indexed newIdManager,
        address instigator);

    mapping(address => mapping(address => uint)) owners;
    mapping(address => address) recoveryKeys;
    mapping(address => mapping(address => uint)) limiter;
    mapping(address => uint) public migrationInitiated;
    mapping(address => address) public migrationNewAddress;

    modifier onlyOwner(address identity) {
        require(isOwner(identity, msg.sender));
        _;
    }

    modifier onlyOlderOwner(address identity) {
        require(isOlderOwner(identity, msg.sender));
        _;
    }

    modifier onlyRecovery(address identity) {
        require(recoveryKeys[identity] == msg.sender);
        _;
    }

    modifier rateLimited(address identity) {
        require(limiter[identity][msg.sender] < (now - adminRate));
        limiter[identity][msg.sender] = now;
        _;
    }

    modifier validAddress(address addr) {  
        require(addr != address(0));
        _;
    }

     
     
     
     
    function IdentityManager(uint _userTimeLock, uint _adminTimeLock, uint _adminRate) {
        require(_adminTimeLock >= _userTimeLock);
        adminTimeLock = _adminTimeLock;
        userTimeLock = _userTimeLock;
        adminRate = _adminRate;
    }

     
     
     
     
    function createIdentity(address owner, address recoveryKey) public validAddress(recoveryKey) {
        Proxy identity = new Proxy();
        owners[identity][owner] = now - adminTimeLock;  
        recoveryKeys[identity] = recoveryKey;
        LogIdentityCreated(identity, msg.sender, owner,  recoveryKey);
    }

     
     
     
     
     
    function createIdentityWithCall(address owner, address recoveryKey, address destination, bytes data) public validAddress(recoveryKey) {
        Proxy identity = new Proxy();
        owners[identity][owner] = now - adminTimeLock;  
        recoveryKeys[identity] = recoveryKey;
        LogIdentityCreated(identity, msg.sender, owner,  recoveryKey);
        identity.forward(destination, 0, data);
    }

     
     
     
     
    function registerIdentity(address owner, address recoveryKey) public validAddress(recoveryKey) {
        require(recoveryKeys[msg.sender] == 0);  
        owners[msg.sender][owner] = now - adminTimeLock;  
        recoveryKeys[msg.sender] = recoveryKey;
        LogIdentityCreated(msg.sender, msg.sender, owner, recoveryKey);
    }

     
    function forwardTo(Proxy identity, address destination, uint value, bytes data) public onlyOwner(identity) {
        identity.forward(destination, value, data);
    }

     
    function addOwner(Proxy identity, address newOwner) public onlyOlderOwner(identity) rateLimited(identity) {
        require(!isOwner(identity, newOwner));
        owners[identity][newOwner] = now - userTimeLock;
        LogOwnerAdded(identity, newOwner, msg.sender);
    }

     
    function addOwnerFromRecovery(Proxy identity, address newOwner) public onlyRecovery(identity) rateLimited(identity) {
        require(!isOwner(identity, newOwner));
        owners[identity][newOwner] = now;
        LogOwnerAdded(identity, newOwner, msg.sender);
    }

     
    function removeOwner(Proxy identity, address owner) public onlyOlderOwner(identity) rateLimited(identity) {
         
        require(msg.sender != owner);
        delete owners[identity][owner];
        LogOwnerRemoved(identity, owner, msg.sender);
    }

     
    function changeRecovery(Proxy identity, address recoveryKey) public
        onlyOlderOwner(identity)
        rateLimited(identity)
        validAddress(recoveryKey)
    {
        recoveryKeys[identity] = recoveryKey;
        LogRecoveryChanged(identity, recoveryKey, msg.sender);
    }

     
    function initiateMigration(Proxy identity, address newIdManager) public
        onlyOlderOwner(identity)
        validAddress(newIdManager)
    {
        migrationInitiated[identity] = now;
        migrationNewAddress[identity] = newIdManager;
        LogMigrationInitiated(identity, newIdManager, msg.sender);
    }

     
    function cancelMigration(Proxy identity) public onlyOwner(identity) {
        address canceledManager = migrationNewAddress[identity];
        delete migrationInitiated[identity];
        delete migrationNewAddress[identity];
        LogMigrationCanceled(identity, canceledManager, msg.sender);
    }

     
     
     
    function finalizeMigration(Proxy identity) public onlyOlderOwner(identity) {
        require(migrationInitiated[identity] != 0 && migrationInitiated[identity] + adminTimeLock < now);
        address newIdManager = migrationNewAddress[identity];
        delete migrationInitiated[identity];
        delete migrationNewAddress[identity];
        identity.transfer(newIdManager);
        delete recoveryKeys[identity];
         
         
        delete owners[identity][msg.sender];
        LogMigrationFinalized(identity, newIdManager, msg.sender);
    }

    function isOwner(address identity, address owner) public constant returns (bool) {
        return (owners[identity][owner] > 0 && (owners[identity][owner] + userTimeLock) <= now);
    }

    function isOlderOwner(address identity, address owner) public constant returns (bool) {
        return (owners[identity][owner] > 0 && (owners[identity][owner] + adminTimeLock) <= now);
    }

    function isRecovery(address identity, address recoveryKey) public constant returns (bool) {
        return recoveryKeys[identity] == recoveryKey;
    }
}

contract ClaimManager {

    event ClaimAdded(address indexed identity, bytes32 indexed claimId, uint256 indexed claimType, uint256 scheme, address issuer, bytes signature, bytes data, string uri);
    event ClaimRemoved(address indexed identity, bytes32 indexed claimId, uint256 indexed claimType, uint256 scheme, address issuer, bytes signature, bytes data, string uri);

    struct Claim {
        uint256 claimType;
        uint256 scheme;
        address issuer;  
        bytes signature;  
        bytes data;
        string uri;
    }
    mapping (address => mapping(bytes32 => Claim)) claims;
    mapping (uint256 => bytes32[]) claimsByType;

    IdentityManager manager;

     
    function ClaimManager(IdentityManager managerAddr) public {
        manager = managerAddr;
    }

    function addClaim(
        address identity,
        uint256 _claimType,
        uint256 _scheme,
        bytes _signature,
        bytes _data,
        string _uri
    )
        public
        returns (bytes32 claimRequestId)
    { 
        bytes32 claimId = keccak256(msg.sender, _claimType);

        if (claims[identity][claimId].issuer != msg.sender) {
            claimsByType[_claimType].push(claimId);
        }

        claims[identity][claimId].claimType = _claimType;
        claims[identity][claimId].scheme = _scheme;
        claims[identity][claimId].issuer = msg.sender;
        claims[identity][claimId].signature = _signature;
        claims[identity][claimId].data = _data;
        claims[identity][claimId].uri = _uri;
  
        ClaimAdded(
            identity,
            claimId,
            _claimType,
            _scheme,
            msg.sender,
            _signature,
            _data,
            _uri
        );

        return claimId;
    }

    function removeClaim(address identity, bytes32 _claimId) public returns (bool success) {
        require(manager.isOwner(identity, msg.sender) || claims[identity][_claimId].issuer == msg.sender);

        ClaimRemoved(
            identity,
            _claimId,
            claims[identity][_claimId].claimType,
            claims[identity][_claimId].scheme,
            claims[identity][_claimId].issuer,
            claims[identity][_claimId].signature,
            claims[identity][_claimId].data,
            claims[identity][_claimId].uri
        );

        delete claims[identity][_claimId];
        return true;
    }

    function getClaim(address identity, bytes32 _claimId)
        public
        constant
        returns(
            uint256 claimType,
            uint256 scheme,
            address issuer,
            bytes signature,
            bytes data,
            string uri
        )
    {
        return (
            claims[identity][_claimId].claimType,
            claims[identity][_claimId].scheme,
            claims[identity][_claimId].issuer,
            claims[identity][_claimId].signature,
            claims[identity][_claimId].data,
            claims[identity][_claimId].uri
        );
    }


   
}