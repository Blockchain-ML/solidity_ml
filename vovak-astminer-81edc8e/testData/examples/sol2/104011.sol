 

 



 

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

 

 

 
library AddressArrayUtils {

     
    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {
        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (uint256(-1), false);
    }

     
    function contains(address[] memory A, address a) internal pure returns (bool) {
        (, bool isIn) = indexOf(A, a);
        return isIn;
    }

     
    function hasDuplicate(address[] memory A) internal pure returns(bool) {
        require(A.length > 0, "A is empty");

        for (uint256 i = 0; i < A.length - 1; i++) {
            address current = A[i];
            for (uint256 j = i + 1; j < A.length; j++) {
                if (current == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }

     
    function remove(address[] memory A, address a)
        internal
        pure
        returns (address[] memory)
    {
        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert("Address not in array.");
        } else {
            (address[] memory _A,) = pop(A, index);
            return _A;
        }
    }

     
    function pop(address[] memory A, uint256 index)
        internal
        pure
        returns (address[] memory, address)
    {
        uint256 length = A.length;
        require(index < A.length, "Index must be < A length");
        address[] memory newAddresses = new address[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newAddresses[j - 1] = A[j];
        }
        return (newAddresses, A[index]);
    }
}
 



 

 
 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 



 

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity 0.6.10;

 
 
 


 
contract Controller is Ownable {
    using AddressArrayUtils for address[];

     

    event FactoryAdded(address indexed _factory);
    event FactoryRemoved(address indexed _factory);
    event FeeEdited(address indexed _module, uint256 indexed _feeType, uint256 _feePercentage);
    event FeeRecipientChanged(address _newFeeRecipient);
    event ModuleAdded(address indexed _module);
    event ModuleRemoved(address indexed _module);
    event ResourceAdded(address indexed _resource, uint256 _id);
    event ResourceRemoved(address indexed _resource, uint256 _id);
    event SetAdded(address indexed _setToken, address indexed _factory);
    event SetRemoved(address indexed _setToken);

     

     
    modifier onlyFactory() {
        require(isFactory[msg.sender], "Only valid factories can call");
        _;
    }

    modifier onlyInitialized() {
        require(isInitialized, "Contract must be initialized.");
        _;
    }

     

     
    address[] public sets;
     
    address[] public factories;
     
    address[] public modules;
     
     
    address[] public resources;

     
    mapping(address => bool) public isSet;
    mapping(address => bool) public isFactory;
    mapping(address => bool) public isModule;
    mapping(address => bool) public isResource;

     
     
    mapping(address => mapping(uint256 => uint256)) public fees;

     
     
    mapping(uint256 => address) public resourceId;

     
    address public feeRecipient;

     
    bool public isInitialized;

     

     
    constructor(address _feeRecipient) public {
        feeRecipient = _feeRecipient;
    }

     

     
    function initialize(
        address[] memory _factories,
        address[] memory _modules,
        address[] memory _resources,
        uint256[] memory _resourceIds
    )
        external
        onlyOwner
    {
        require(!isInitialized, "Controller is already initialized");
        require(_resources.length == _resourceIds.length, "Array lengths do not match.");

        factories = _factories;
        modules = _modules;
        resources = _resources;

         
        for (uint256 i = 0; i < _factories.length; i++) {
            require(_factories[i] != address(0), "Zero address submitted.");
            isFactory[_factories[i]] = true;
        }
        for (uint256 i = 0; i < _modules.length; i++) {
            require(_modules[i] != address(0), "Zero address submitted.");
            isModule[_modules[i]] = true;
        }

        for (uint256 i = 0; i < _resources.length; i++) {
            require(_resources[i] != address(0), "Zero address submitted.");
            require(resourceId[_resourceIds[i]] == address(0), "Resource ID already exists");
            isResource[_resources[i]] = true;
            resourceId[_resourceIds[i]] = _resources[i];
        }

         
        isInitialized = true;
    }

     
    function addSet(address _setToken) external onlyInitialized onlyFactory {
        require(!isSet[_setToken], "Set already exists");

        isSet[_setToken] = true;

        sets.push(_setToken);

        emit SetAdded(_setToken, msg.sender);
    }

     
    function removeSet(address _setToken) external onlyInitialized onlyOwner {
        require(isSet[_setToken], "Set does not exist");

        sets = sets.remove(_setToken);

        isSet[_setToken] = false;

        emit SetRemoved(_setToken);
    }

     
    function addFactory(address _factory) external onlyInitialized onlyOwner {
        require(!isFactory[_factory], "Factory already exists");

        isFactory[_factory] = true;

        factories.push(_factory);

        emit FactoryAdded(_factory);
    }

     
    function removeFactory(address _factory) external onlyInitialized onlyOwner {
        require(isFactory[_factory], "Factory does not exist");

        factories = factories.remove(_factory);

        isFactory[_factory] = false;

        emit FactoryRemoved(_factory);
    }

     
    function addModule(address _module) external onlyInitialized onlyOwner {
        require(!isModule[_module], "Module already exists");

        isModule[_module] = true;

        modules.push(_module);

        emit ModuleAdded(_module);
    }

     
    function removeModule(address _module) external onlyInitialized onlyOwner {
        require(isModule[_module], "Module does not exist");

        modules = modules.remove(_module);

        isModule[_module] = false;

        emit ModuleRemoved(_module);
    }

     
    function addResource(address _resource, uint256 _id) external onlyInitialized onlyOwner {
        require(!isResource[_resource], "Resource already exists");

        require(resourceId[_id] == address(0), "Resource ID already exists");

        isResource[_resource] = true;

        resourceId[_id] = _resource;

        resources.push(_resource);

        emit ResourceAdded(_resource, _id);
    }

     
    function removeResource(uint256 _id) external onlyInitialized onlyOwner {
        address resourceToRemove = resourceId[_id];

        require(resourceToRemove != address(0), "Resource does not exist");

        resources = resources.remove(resourceToRemove);

        delete resourceId[_id];

        isResource[resourceToRemove] = false;

        emit ResourceRemoved(resourceToRemove, _id);
    }

     
    function addFee(address _module, uint256 _feeType, uint256 _newFeePercentage) external onlyInitialized onlyOwner {
        require(isModule[_module], "Module does not exist");

        require(fees[_module][_feeType] == 0, "Fee type already exists on module");

        fees[_module][_feeType] = _newFeePercentage;

        emit FeeEdited(_module, _feeType, _newFeePercentage);
    }

     
    function editFee(address _module, uint256 _feeType, uint256 _newFeePercentage) external onlyInitialized onlyOwner {
        require(isModule[_module], "Module does not exist");

        require(fees[_module][_feeType] != 0, "Fee type does not exist on module");

        fees[_module][_feeType] = _newFeePercentage;

        emit FeeEdited(_module, _feeType, _newFeePercentage);
    }

     
    function editFeeRecipient(address _newFeeRecipient) external onlyInitialized onlyOwner {
        require(_newFeeRecipient != address(0), "Address must not be 0");

        feeRecipient = _newFeeRecipient;

        emit FeeRecipientChanged(_newFeeRecipient);
    }

     

    function getModuleFee(
        address _moduleAddress,
        uint256 _feeType
    )
        external
        view
        returns (uint256)
    {
        return fees[_moduleAddress][_feeType];
    }

    function getFactories() external view returns (address[] memory) {
        return factories;
    }

    function getModules() external view returns (address[] memory) {
        return modules;
    }

    function getResources() external view returns (address[] memory) {
        return resources;
    }

    function getSets() external view returns (address[] memory) {
        return sets;
    }

     
    function isSystemContract(address _contractAddress) external view returns (bool) {
        return (
            isSet[_contractAddress] ||
            isModule[_contractAddress] ||
            isResource[_contractAddress] ||
            isFactory[_contractAddress] ||
            _contractAddress == address(this)
        );
    }
}