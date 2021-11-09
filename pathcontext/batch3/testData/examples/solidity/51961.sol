pragma solidity 0.4.24;

 

interface IBridgeValidators {
    function initialize(uint256 _requiredSignatures, address[] _initialValidators, address _owner) public returns(bool);
    function isValidator(address _validator) public view returns(bool);
    function requiredSignatures() public view returns(uint256);
    function owner() public view returns(address);
}

 

contract IForeignBridge {

  function initialize(address _validatorContract, address _erc20token, uint256 _requiredBlockConfirmations, uint256 _gasPrice) public returns(bool);
  
}

 

 
contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;


    mapping(bytes32 => uint256[]) internal uintArrayStorage;
    mapping(bytes32 => string[]) internal stringArrayStorage;
    mapping(bytes32 => address[]) internal addressArrayStorage;
     
    mapping(bytes32 => bool[]) internal boolArrayStorage;
    mapping(bytes32 => int256[]) internal intArrayStorage;
    mapping(bytes32 => bytes32[]) internal bytes32ArrayStorage;
}

 

 
contract Proxy {

   
    function implementation() public view returns (address);

   
    function () payable public {
        address _impl = implementation();
        require(_impl != address(0));
        assembly {
             
            let ptr := mload(0x40)
             
            calldatacopy(ptr, 0, calldatasize)
             
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
             
             
            mstore(0x40, add(ptr, returndatasize))
             
            returndatacopy(ptr, 0, returndatasize)

             
            switch result
            case 0 { revert(ptr, returndatasize) }
            default { return(ptr, returndatasize) }
        }
    }
}

 

 
contract UpgradeabilityStorage {
     
    uint256 internal _version;

     
    address internal _implementation;

     
    function version() public view returns (uint256) {
        return _version;
    }

     
    function implementation() public view returns (address) {
        return _implementation;
    }
}

 

 
contract UpgradeabilityProxy is Proxy, UpgradeabilityStorage {
     
    event Upgraded(uint256 version, address indexed implementation);

     
    function _upgradeTo(uint256 version, address implementation) internal {
        require(_implementation != implementation);
        require(version > _version);
        _version = version;
        _implementation = implementation;
        emit Upgraded(version, implementation);
    }
}

 

 
contract UpgradeabilityOwnerStorage {
     
    address private _upgradeabilityOwner;

     
    function upgradeabilityOwner() public view returns (address) {
        return _upgradeabilityOwner;
    }

     
    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {
        _upgradeabilityOwner = newUpgradeabilityOwner;
    }
}

 

 
contract OwnedUpgradeabilityProxy is UpgradeabilityOwnerStorage, UpgradeabilityProxy {
   
    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

     
    constructor() public {
        setUpgradeabilityOwner(msg.sender);
    }

     
    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner());
        _;
    }

     
    function proxyOwner() public view returns (address) {
        return upgradeabilityOwner();
    }

     
    function transferProxyOwnership(address newOwner) public onlyProxyOwner {
        require(newOwner != address(0));
        emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
        setUpgradeabilityOwner(newOwner);
    }

     
    function upgradeTo(uint256 version, address implementation) public onlyProxyOwner {
        _upgradeTo(version, implementation);
    }

     
    function upgradeToAndCall(uint256 version, address implementation, bytes data) payable public onlyProxyOwner {
        upgradeTo(version, implementation);
        require(address(this).call.value(msg.value)(data));
    }
}

 

 
contract EternalStorageProxy is OwnedUpgradeabilityProxy, EternalStorage {}

 

 
contract EternalOwnable is EternalStorage {
     
    event OwnershipTransferred(address previousOwner, address newOwner);

     
    modifier onlyOwner() {
        require(msg.sender == owner());
        _;
    }

     
    function owner() public view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("owner"))];
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        setOwner(newOwner);
    }

     
    function setOwner(address newOwner) internal {
        emit OwnershipTransferred(owner(), newOwner);
        addressStorage[keccak256(abi.encodePacked("owner"))] = newOwner;
    }
}

 

contract ForeignBridgeFactory is EternalStorage, EternalOwnable {

  function initialize(address _owner,
      address _bridgeValidatorsImplementation,
      uint256 _requiredSignatures,
      address[] _initialValidators,
      address _bridgeValidatorsOwner,
      address _bridgeValidatorsProxyOwner,
      address _foreignBridgeErcToErcImplementation,
      uint256 _requiredBlockConfirmations,
      uint256 _gasPrice,
      address _foreignBridgeProxyOwner) public {
    
    require(_owner != address(0));
    require(_bridgeValidatorsImplementation != address(0));
    require(_requiredSignatures >= 1);
    require(_bridgeValidatorsOwner != address(0));
    require(_bridgeValidatorsProxyOwner != address(0));
    require(_foreignBridgeErcToErcImplementation != address(0));
    require(_requiredBlockConfirmations > 0);
    require(_foreignBridgeProxyOwner != address(0));

    setOwner(_owner);
    setBridgeValidatorsImplementation(_bridgeValidatorsImplementation);
    setRequiredSignatures(_requiredSignatures);
    setInitialValidators(_initialValidators);
    setBridgeValidatorsOwner(_bridgeValidatorsOwner);
    setBridgeValidatorsProxyOwner(_bridgeValidatorsProxyOwner);
    setForeignBridgeErcToErcImplementation(_foreignBridgeErcToErcImplementation);
    setRequiredBlockConfirmations(_requiredBlockConfirmations);
    setGasPrice(_gasPrice);
    setForeignBridgeProxyOwner(_foreignBridgeProxyOwner);
  }

  function deployForeignBridge(address _erc20Token) public onlyOwner {
     
    EternalStorageProxy proxy = new EternalStorageProxy();
     
    proxy.upgradeTo(1, bridgeValidatorsImplementation());
     
    IBridgeValidators bridgeValidators = IBridgeValidators(proxy);
     
    bridgeValidators.initialize(requiredSignatures(), initialValidators(), bridgeValidatorsOwner());
     
    proxy.transferProxyOwnership(bridgeValidatorsProxyOwner());
     
    proxy = new EternalStorageProxy();
     
    proxy.upgradeTo(1, foreignBridgeErcToErcImplementation());
     
    IForeignBridge foreignBridge = IForeignBridge(proxy);
     
    foreignBridge.initialize(bridgeValidators, _erc20Token, requiredBlockConfirmations(), gasPrice());
     
    proxy.transferProxyOwnership(foreignBridgeProxyOwner());
  }
  

  function bridgeValidatorsImplementation() public view returns(address) {
    return addressStorage[keccak256(abi.encodePacked("bridgeValidatorsImplementation"))];
  }

  function setBridgeValidatorsImplementation(address _bridgeValidatorsImplementation) public onlyOwner {
    addressStorage[keccak256(abi.encodePacked("bridgeValidatorsImplementation"))] = _bridgeValidatorsImplementation;
  }

  function requiredSignatures() public view returns(uint256) {
    return uintStorage[keccak256(abi.encodePacked("requiredSignatures"))];
  }

  function setRequiredSignatures(uint256 _requiredSignatures) public onlyOwner {
    uintStorage[keccak256(abi.encodePacked("requiredSignatures"))] = _requiredSignatures;
  }

  function initialValidators() public view returns(address[]) {
    return addressArrayStorage[keccak256(abi.encodePacked("initialValidators"))];
  }

  function setInitialValidators(address[] _initialValidators) public onlyOwner {
    addressArrayStorage[keccak256(abi.encodePacked("initialValidators"))] = _initialValidators;
  }

  function bridgeValidatorsOwner() public view returns(address) {
    return addressStorage[keccak256(abi.encodePacked("bridgeValidatorsOwner"))];
  }

  function setBridgeValidatorsOwner(address _bridgeValidatorsOwner) public onlyOwner {
    addressStorage[keccak256(abi.encodePacked("bridgeValidatorsOwner"))] = _bridgeValidatorsOwner;
  }

  function bridgeValidatorsProxyOwner() public view returns(address) {
    return addressStorage[keccak256(abi.encodePacked("bridgeValidatorsProxyOwner"))];
  }

  function setBridgeValidatorsProxyOwner(address _bridgeValidatorsProxyOwner) public onlyOwner {
    addressStorage[keccak256(abi.encodePacked("bridgeValidatorsProxyOwner"))] = _bridgeValidatorsProxyOwner;
  }

  function foreignBridgeErcToErcImplementation() public view returns(address) {
    return addressStorage[keccak256(abi.encodePacked("foreignBridgeErcToErcImplementation"))];
  }

  function setForeignBridgeErcToErcImplementation(address _foreignBridgeErcToErcImplementation) public onlyOwner {
    addressStorage[keccak256(abi.encodePacked("foreignBridgeErcToErcImplementation"))] = _foreignBridgeErcToErcImplementation;
  }

  function requiredBlockConfirmations() public view returns(uint256) {
    return uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))];
  }

  function setRequiredBlockConfirmations(uint256 _requiredBlockConfirmations) public onlyOwner {
    uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))] = _requiredBlockConfirmations;
  }

  function gasPrice() public view returns(uint256) {
    return uintStorage[keccak256(abi.encodePacked("gasPrice"))];
  }

  function setGasPrice(uint256 _gasPrice) public onlyOwner {
    uintStorage[keccak256(abi.encodePacked("gasPrice"))] = _gasPrice;
  }

  function foreignBridgeProxyOwner() public view returns(address) {
    return addressStorage[keccak256(abi.encodePacked("foreignBridgeProxyOwner"))];
  }

  function setForeignBridgeProxyOwner(address _foreignBridgeProxyOwner) public onlyOwner {
    addressStorage[keccak256(abi.encodePacked("foreignBridgeProxyOwner"))] = _foreignBridgeProxyOwner;
  }
}