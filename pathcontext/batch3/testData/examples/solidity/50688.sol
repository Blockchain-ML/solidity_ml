pragma solidity ^0.4.24;

 

 
contract OwnableProxy {
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

     
    bytes32 private constant OWNER_SLOT = 0x3ca57e4b51fc2e18497b219410298879868edada7e6fe5132c8feceb0a080d22;

     
    constructor() public {
        assert(OWNER_SLOT == keccak256("org.monetha.proxy.owner"));

        _setOwner(msg.sender);
    }

     
    modifier onlyOwner() {
        require(msg.sender == _getOwner());
        _;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_getOwner());
        _setOwner(address(0));
    }

     
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

     
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(_getOwner(), _newOwner);
        _setOwner(_newOwner);
    }

     
    function owner() public view returns (address) {
        return _getOwner();
    }

     
    function _getOwner() internal view returns (address own) {
        bytes32 slot = OWNER_SLOT;
        assembly {
            own := sload(slot)
        }
    }

     
    function _setOwner(address _newOwner) internal {
        bytes32 slot = OWNER_SLOT;

        assembly {
            sstore(slot, _newOwner)
        }
    }
}

 

 
contract ClaimableProxy is OwnableProxy {
     
    bytes32 private constant PENDING_OWNER_SLOT = 0xcfd0c6ea5352192d7d4c5d4e7a73c5da12c871730cb60ff57879cbe7b403bb52;

     
    constructor() public {
        assert(PENDING_OWNER_SLOT == keccak256("org.monetha.proxy.pendingOwner"));
    }

    function pendingOwner() public view returns (address) {
        return _getPendingOwner();
    }

     
    modifier onlyPendingOwner() {
        require(msg.sender == _getPendingOwner());
        _;
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _setPendingOwner(newOwner);
    }

     
    function claimOwnership() public onlyPendingOwner {
        emit OwnershipTransferred(_getOwner(), _getPendingOwner());
        _setOwner(_getPendingOwner());
        _setPendingOwner(address(0));
    }

     
    function _getPendingOwner() internal view returns (address penOwn) {
        bytes32 slot = PENDING_OWNER_SLOT;
        assembly {
            penOwn := sload(slot)
        }
    }

     
    function _setPendingOwner(address _newPendingOwner) internal {
        bytes32 slot = PENDING_OWNER_SLOT;

        assembly {
            sstore(slot, _newPendingOwner)
        }
    }
}

 

interface IPassportLogic {
     
    function owner() external view returns (address);

     

     
     
    function setAddress(bytes32 _key, address _value) external;

     
     
    function setUint(bytes32 _key, uint _value) external;

     
     
    function setInt(bytes32 _key, int _value) external;

     
     
    function setBool(bytes32 _key, bool _value) external;

     
     
    function setString(bytes32 _key, string _value) external;

     
     
    function setBytes(bytes32 _key, bytes _value) external;

     
    function setTxDataBlockNumber(bytes32 _key, bytes _data) external;

     

     
    function deleteAddress(bytes32 _key) external;

     
    function deleteUint(bytes32 _key) external;

     
    function deleteInt(bytes32 _key) external;

     
    function deleteBool(bytes32 _key) external;

     
    function deleteString(bytes32 _key) external;

     
    function deleteBytes(bytes32 _key) external;

     
    function deleteTxDataBlockNumber(bytes32 _key) external;

     

     
     
    function getAddress(address _factProvider, bytes32 _key) external view returns (bool success, address value);

     
     
    function getUint(address _factProvider, bytes32 _key) external view returns (bool success, uint value);

     
     
    function getInt(address _factProvider, bytes32 _key) external view returns (bool success, int value);

     
     
    function getBool(address _factProvider, bytes32 _key) external view returns (bool success, bool value);

     
     
    function getString(address _factProvider, bytes32 _key) external view returns (bool success, string value);

     
     
    function getBytes(address _factProvider, bytes32 _key) external view returns (bool success, bytes value);

     
     
    function getTxDataBlockNumber(address _factProvider, bytes32 _key) external view returns (bool success, uint blockNumber);
}

 

 
 
contract Storage is ClaimableProxy
{
    struct AddressValue {
        bool initialized;
        address value;
    }

    mapping(address => mapping(bytes32 => AddressValue)) internal addressStorage;

    struct UintValue {
        bool initialized;
        uint value;
    }

    mapping(address => mapping(bytes32 => UintValue)) internal uintStorage;

    struct IntValue {
        bool initialized;
        int value;
    }

    mapping(address => mapping(bytes32 => IntValue)) internal intStorage;

    struct BoolValue {
        bool initialized;
        bool value;
    }

    mapping(address => mapping(bytes32 => BoolValue)) internal boolStorage;

    struct StringValue {
        bool initialized;
        string value;
    }

    mapping(address => mapping(bytes32 => StringValue)) internal stringStorage;

    struct BytesValue {
        bool initialized;
        bytes value;
    }

    mapping(address => mapping(bytes32 => BytesValue)) internal bytesStorage;

    struct BlockNumberValue {
        bool initialized;
        uint blockNumber;
    }

    mapping(address => mapping(bytes32 => BlockNumberValue)) internal txBytesStorage;

    bool private onlyFactProviderFromWhitelistAllowed;
    mapping(address => bool) private factProviderWhitelist;

    event WhitelistOnlyPermissionSet(bool indexed onlyWhitelist);
    event WhitelistFactProviderAdded(address indexed factProvider);
    event WhitelistFactProviderRemoved(address indexed factProvider);

     
    modifier allowedFactProvider() {
        require(isAllowedFactProvider(msg.sender));
        _;
    }

     
    function isAllowedFactProvider(address _address) public view returns (bool) {
        return !onlyFactProviderFromWhitelistAllowed || factProviderWhitelist[_address] || _address == _getOwner();
    }

     
    function isWhitelistOnlyPermissionSet() external view returns (bool) {
        return onlyFactProviderFromWhitelistAllowed;
    }

     
    function setWhitelistOnlyPermission(bool _onlyWhitelist) onlyOwner external {
        onlyFactProviderFromWhitelistAllowed = _onlyWhitelist;
        emit WhitelistOnlyPermissionSet(_onlyWhitelist);
    }

     
    function isFactProviderInWhitelist(address _address) external view returns (bool) {
        return factProviderWhitelist[_address];
    }

     
    function addFactProviderToWhitelist(address _address) onlyOwner external {
        factProviderWhitelist[_address] = true;
        emit WhitelistFactProviderAdded(_address);
    }

     
    function removeFactProviderFromWhitelist(address _address) onlyOwner external {
        delete factProviderWhitelist[_address];
        emit WhitelistFactProviderRemoved(_address);
    }
}

 

contract AddressStorageLogic is Storage {
    event AddressUpdated(address indexed factProvider, bytes32 indexed key);
    event AddressDeleted(address indexed factProvider, bytes32 indexed key);

     
     
    function setAddress(bytes32 _key, address _value) external {
        _setAddress(_key, _value);
    }

     
    function deleteAddress(bytes32 _key) external {
        _deleteAddress(_key);
    }

     
     
    function getAddress(address _factProvider, bytes32 _key) external view returns (bool success, address value) {
        return _getAddress(_factProvider, _key);
    }

    function _setAddress(bytes32 _key, address _value) allowedFactProvider internal {
        addressStorage[msg.sender][_key] = AddressValue({
            initialized : true,
            value : _value
            });
        emit AddressUpdated(msg.sender, _key);
    }

    function _deleteAddress(bytes32 _key) allowedFactProvider internal {
        delete addressStorage[msg.sender][_key];
        emit AddressDeleted(msg.sender, _key);
    }

    function _getAddress(address _factProvider, bytes32 _key) internal view returns (bool success, address value) {
        AddressValue storage initValue = addressStorage[_factProvider][_key];
        return (initValue.initialized, initValue.value);
    }
}

 

contract UintStorageLogic is Storage {
    event UintUpdated(address indexed factProvider, bytes32 indexed key);
    event UintDeleted(address indexed factProvider, bytes32 indexed key);

     
     
    function setUint(bytes32 _key, uint _value) external {
        _setUint(_key, _value);
    }

     
    function deleteUint(bytes32 _key) external {
        _deleteUint(_key);
    }

     
     
    function getUint(address _factProvider, bytes32 _key) external view returns (bool success, uint value) {
        return _getUint(_factProvider, _key);
    }

    function _setUint(bytes32 _key, uint _value) allowedFactProvider internal {
        uintStorage[msg.sender][_key] = UintValue({
            initialized : true,
            value : _value
            });
        emit UintUpdated(msg.sender, _key);
    }

    function _deleteUint(bytes32 _key) allowedFactProvider internal {
        delete uintStorage[msg.sender][_key];
        emit UintDeleted(msg.sender, _key);
    }

    function _getUint(address _factProvider, bytes32 _key) internal view returns (bool success, uint value) {
        UintValue storage initValue = uintStorage[_factProvider][_key];
        return (initValue.initialized, initValue.value);
    }
}

 

contract IntStorageLogic is Storage {
    event IntUpdated(address indexed factProvider, bytes32 indexed key);
    event IntDeleted(address indexed factProvider, bytes32 indexed key);

     
     
    function setInt(bytes32 _key, int _value) external {
        _setInt(_key, _value);
    }

     
    function deleteInt(bytes32 _key) external {
        _deleteInt(_key);
    }

     
     
    function getInt(address _factProvider, bytes32 _key) external view returns (bool success, int value) {
        return _getInt(_factProvider, _key);
    }

    function _setInt(bytes32 _key, int _value) allowedFactProvider internal {
        intStorage[msg.sender][_key] = IntValue({
            initialized : true,
            value : _value
            });
        emit IntUpdated(msg.sender, _key);
    }

    function _deleteInt(bytes32 _key) allowedFactProvider internal {
        delete intStorage[msg.sender][_key];
        emit IntDeleted(msg.sender, _key);
    }

    function _getInt(address _factProvider, bytes32 _key) internal view returns (bool success, int value) {
        IntValue storage initValue = intStorage[_factProvider][_key];
        return (initValue.initialized, initValue.value);
    }
}

 

contract BoolStorageLogic is Storage {
    event BoolUpdated(address indexed factProvider, bytes32 indexed key);
    event BoolDeleted(address indexed factProvider, bytes32 indexed key);

     
     
    function setBool(bytes32 _key, bool _value) external {
        _setBool(_key, _value);
    }

     
    function deleteBool(bytes32 _key) external {
        _deleteBool(_key);
    }

     
     
    function getBool(address _factProvider, bytes32 _key) external view returns (bool success, bool value) {
        return _getBool(_factProvider, _key);
    }

    function _setBool(bytes32 _key, bool _value) allowedFactProvider internal {
        boolStorage[msg.sender][_key] = BoolValue({
            initialized : true,
            value : _value
            });
        emit BoolUpdated(msg.sender, _key);
    }

    function _deleteBool(bytes32 _key) allowedFactProvider internal {
        delete boolStorage[msg.sender][_key];
        emit BoolDeleted(msg.sender, _key);
    }

    function _getBool(address _factProvider, bytes32 _key) internal view returns (bool success, bool value) {
        BoolValue storage initValue = boolStorage[_factProvider][_key];
        return (initValue.initialized, initValue.value);
    }
}

 

contract StringStorageLogic is Storage {
    event StringUpdated(address indexed factProvider, bytes32 indexed key);
    event StringDeleted(address indexed factProvider, bytes32 indexed key);

     
     
    function setString(bytes32 _key, string _value) external {
        _setString(_key, _value);
    }

     
    function deleteString(bytes32 _key) external {
        _deleteString(_key);
    }

     
     
    function getString(address _factProvider, bytes32 _key) external view returns (bool success, string value) {
        return _getString(_factProvider, _key);
    }

    function _setString(bytes32 _key, string _value) allowedFactProvider internal {
        stringStorage[msg.sender][_key] = StringValue({
            initialized : true,
            value : _value
            });
        emit StringUpdated(msg.sender, _key);
    }

    function _deleteString(bytes32 _key) allowedFactProvider internal {
        delete stringStorage[msg.sender][_key];
        emit StringDeleted(msg.sender, _key);
    }

    function _getString(address _factProvider, bytes32 _key) internal view returns (bool success, string value) {
        StringValue storage initValue = stringStorage[_factProvider][_key];
        return (initValue.initialized, initValue.value);
    }
}

 

contract BytesStorageLogic is Storage {
    event BytesUpdated(address indexed factProvider, bytes32 indexed key);
    event BytesDeleted(address indexed factProvider, bytes32 indexed key);

     
     
    function setBytes(bytes32 _key, bytes _value) external {
        _setBytes(_key, _value);
    }

     
    function deleteBytes(bytes32 _key) external {
        _deleteBytes(_key);
    }

     
     
    function getBytes(address _factProvider, bytes32 _key) external view returns (bool success, bytes value) {
        return _getBytes(_factProvider, _key);
    }

    function _setBytes(bytes32 _key, bytes _value) allowedFactProvider internal {
        bytesStorage[msg.sender][_key] = BytesValue({
            initialized : true,
            value : _value
            });
        emit BytesUpdated(msg.sender, _key);
    }

    function _deleteBytes(bytes32 _key) allowedFactProvider internal {
        delete bytesStorage[msg.sender][_key];
        emit BytesDeleted(msg.sender, _key);
    }

    function _getBytes(address _factProvider, bytes32 _key) internal view returns (bool success, bytes value) {
        BytesValue storage initValue = bytesStorage[_factProvider][_key];
        return (initValue.initialized, initValue.value);
    }
}

 

 
contract TxDataStorageLogic is Storage {
    event TxDataUpdated(address indexed factProvider, bytes32 indexed key);
    event TxDataDeleted(address indexed factProvider, bytes32 indexed key);

     
     
     
    function setTxDataBlockNumber(bytes32 _key, bytes _data) allowedFactProvider external {
        txBytesStorage[msg.sender][_key] = BlockNumberValue({
            initialized : true,
            blockNumber : block.number
            });
        emit TxDataUpdated(msg.sender, _key);
    }

     
    function deleteTxDataBlockNumber(bytes32 _key) allowedFactProvider external {
        delete txBytesStorage[msg.sender][_key];
        emit TxDataDeleted(msg.sender, _key);
    }

     
     
    function getTxDataBlockNumber(address _factProvider, bytes32 _key) external view returns (bool success, uint blockNumber) {
        return _getTxDataBlockNumber(_factProvider, _key);
    }

    function _getTxDataBlockNumber(address _factProvider, bytes32 _key) private view returns (bool success, uint blockNumber) {
        BlockNumberValue storage initValue = txBytesStorage[_factProvider][_key];
        return (initValue.initialized, initValue.blockNumber);
    }
}

 

contract PassportLogic
is IPassportLogic
, ClaimableProxy
, AddressStorageLogic
, UintStorageLogic
, IntStorageLogic
, BoolStorageLogic
, StringStorageLogic
, BytesStorageLogic
, TxDataStorageLogic
{}