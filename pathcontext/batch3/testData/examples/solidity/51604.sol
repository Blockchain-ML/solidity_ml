pragma solidity ^0.5.0;

 
contract ITickerService {

     
    function checkValidity(string memory _symbol, address _owner, string memory _tokenName) public returns(bool);

     
    function getTickerDetail(string memory _symbol) public view returns(address _issuer, uint256 _timestamp, string memory _tokenName, bool _status);

     
    function checkTickerExists(string memory _symbol) public view returns(bool);
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
        require(msg.sender == owner, "Not contract owner");
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
        require(_newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

 
library EncoderUtil {

     
    function encode(string memory _str) public pure returns(bytes32) {
        require(bytes(_str).length != 0, "Encode value must not empty");
        return keccak256(abi.encodePacked(_str));
    }

     
    function encode(address _addr) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_addr));
    }
}

 
contract ServiceStorage is Ownable {

     
    mapping(bytes32 => address) public serviceMap;

     
    event LogServiceStorageUpdate(string _key, address _oldValue, address _newValue);

     
    function get(string memory _key) public view returns(address){
        bytes32 key = EncoderUtil.encode(_key);
        require(serviceMap[key] != address(0), "No result");
        return serviceMap[key];
    }

     
    function update(string memory _key, address _value) public onlyOwner {
        bytes32 key = EncoderUtil.encode(_key);
        emit LogServiceStorageUpdate(_key, serviceMap[key], _value);
        serviceMap[key] = _value;
    }

}

 
contract ServiceHelper is Ownable {

    address public servicesStorageAddress;
    address public moduleServiceAddress;
    address public securityTokenServiceAddress;
    address public tickerServiceAddress;
    address public platformTokenAddress;

    ServiceStorage serviceStorage;

    constructor (address _servicesStorageAddress) public {
        require(_servicesStorageAddress != address(0), "Invlid address");
        servicesStorageAddress = _servicesStorageAddress;
        serviceStorage = ServiceStorage(_servicesStorageAddress);
    }

    function loadData() public onlyOwner {
        moduleServiceAddress = serviceStorage.get("moduleService");
        securityTokenServiceAddress = serviceStorage.get("securityTokenService");
        tickerServiceAddress = serviceStorage.get("tickerService");
        platformTokenAddress = serviceStorage.get("platformToken");
    }

}

contract IERC20 {

    string public name;
    string public symbol;
    uint8 public decimals;

    event Transfer(
        address indexed _from, 
        address indexed _to, 
        uint256 _value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);
    
    function allowance(address _owner, address _spender) public view returns (uint256);

}

contract IERC20Extend is IERC20 {

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool);

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool);
}

contract IERC20Detail is IERC20 {

    constructor(string memory _name, string memory _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

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

contract StandardToken is IERC20,IERC20Detail,IERC20Extend {

    using SafeMath for uint256;
    

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    mapping (address => mapping (address => uint256)) internal allowed;

    function totalSupply() public view returns (uint256){
        return totalSupply_;
    }

    function balanceOf(address who) public view returns (uint256){
        return balances[who];
    }

    function allowance(address owner, address spender) public view returns (uint256){
        return allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool){

        require(to != address(0), "Invalid address");

        require(balances[msg.sender] >= value, "Insufficient tokens transferable");

        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function approve(address spender, uint256 value) public returns (bool){

        require(balances[msg.sender] >= value, "Insufficient tokens approval");

        allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        require(to != address(0), "Invalid address");
        require(balances[from] >= value, "Insufficient tokens transferable");
        require(allowed[from][msg.sender] >= value, "Insufficient tokens allowable");

        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);

        emit Transfer(from, to, value);

        return true;
    }

    function increaseApproval(address spender, uint256 value) public returns(bool) {

        require(balances[msg.sender] >= value, "Insufficient tokens approval");

        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(value);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);

        return true;
    }

    function decreaseApproval(address spender, uint256 value) public returns(bool){

        uint256 oldApproval = allowed[msg.sender][spender];

        if(oldApproval > value){
            allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(value);
        }else {
            allowed[msg.sender][spender] = 0;
        }

        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);

        return true;
    }
}

 
contract ISTEP is StandardToken {

    string public tokenDetails;

     
    event LogMint(address indexed _to, uint256 _amount);

     
    function verifyTransfer(address _from, address _to, uint256 _amount) public returns (bool);

     
    function mint(address _investor, uint256 _amount) public returns (bool);

}

contract ISecurityToken is ISTEP, Ownable {
    
    uint8 public constant PERMISSIONMANAGER_KEY = 1;
    uint8 public constant TRANSFERMANAGER_KEY = 2;
    uint8 public constant STO_KEY = 3;
    
     
    uint256 public granularity;

    uint256 public investorCount;

    address[] public investors;

     
    function checkPermission(address _delegate, address _module, bytes32 _perm) public view returns(bool);
    
     
    function getModule(uint8 _moduleType, uint _moduleIndex) public view returns (bytes32, address);

     
    function getModuleByName(uint8 _moduleType, bytes32 _name) public view returns (bytes32, address);

     
    function getInvestorsLength() public view returns(uint256);

    
}

 
contract IModuleService {
    
    function useModule(address _moduleFactoryAddress) external;

    
    function registerModule(address _moduleFactoryAddress) external returns(bool);

   
    function getTagByModuleType(uint8 _moduleType) public view returns(bytes32[] memory);
}

 
contract IModuleFactory is Ownable {

     
    IERC20 public platformToken;
     
    uint256 public setupCost;
     
    uint256 public usageCost;
     
    uint256 public monthlySubscriptionCost;

     
    event LogChangeFactorySetupFee(uint256 _oldSetupcost, uint256 _newSetupCost, address _moduleFactoryAddress);
     
    event LogChangeFactoryUsageFee(uint256 _oldUsageCost, uint256 _newUsageCost, address _moduleFactoryAddress);
     
    event LogChangeFactorySubscriptionFee(uint256 _oldSubscriptionCost, uint256 _newMonthlySubscriptionCost, address _moduleFactoryAddress);
     
    event LogGenerateModuleFromFactory(address _moduleAddress, bytes32 indexed _moduleName, address indexed _moduleFactoryAddress, address _creator, uint256 _timestamp);

   
     
    constructor (address _platformTokenAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost) public {
        platformToken = IERC20(_platformTokenAddress);
        setupCost = _setupCost;
        usageCost = _usageCost;
        monthlySubscriptionCost = _subscriptionCost;
    }

    function create(bytes calldata _data) external returns(address);

    function getType() public view returns(uint8);

    function getName() public view returns(bytes32);

    function getDescription() public view returns(string memory);

    function getTitle() public view returns(string memory);

    function getInstructions() public view returns (string memory);

    function getTags() public view returns (bytes32[] memory);

    function getSig(bytes memory _data) internal pure returns (bytes32 sig) {
        uint len = _data.length < 4 ? _data.length : 4;
        for (uint i = 0; i < len; i++) {
            sig = bytes32(uint(sig) + uint8(_data[i]) * (2 ** (8 * (len - 1 - i))));
        }
    }

    
     
    function changeFactorySetupFee(uint256 _newSetupCost) public onlyOwner {
        emit LogChangeFactorySetupFee(setupCost, _newSetupCost, address(this));
        setupCost = _newSetupCost;
    }

     
    function changeFactoryUsageFee(uint256 _newUsageCost) public onlyOwner {
        emit LogChangeFactoryUsageFee(usageCost, _newUsageCost, address(this));
        usageCost = _newUsageCost;
    }

     
    function changeFactorySubscriptionFee(uint256 _newSubscriptionCost) public onlyOwner {
        emit LogChangeFactorySubscriptionFee(monthlySubscriptionCost, _newSubscriptionCost, address(this));
        monthlySubscriptionCost = _newSubscriptionCost;
        
    }

}

 
contract Pausable {

    event Pause(uint256 pauseTime);
    event Unpause(uint256 unpauseTime);

    bool public paused = false;


     
    modifier whenNotPaused() {
        require(!paused, "Should not pause");
        _;
    }

     
    modifier whenPaused() {
        require(paused, "Should be pause");
        _;
    }

     
    function pause() public whenNotPaused {
        paused = true;
        emit Pause(now);
    }

     
    function unpause() public whenPaused {
        paused = false;
        emit Unpause(now);
    }
}

 
contract IModule {

     
    address public factoryAddress;

     
    address public securityTokenAddress;

    bytes32 public constant FEE_ADMIN = "FEE_ADMIN";

     
    IERC20 public platformToken;

     
    constructor (address _securityTokenAddress, address _platformTokenAddress) public {
        securityTokenAddress = _securityTokenAddress;
        factoryAddress = msg.sender;
        platformToken = IERC20(_platformTokenAddress);
    }

    function getInitFunction() public pure returns (bytes4);


    modifier withPerm(bytes32 _perm) {
        bool isOwner = msg.sender == ISecurityToken(securityTokenAddress).owner();
        bool isFactory = msg.sender == factoryAddress;
        require(isOwner || isFactory || ISecurityToken(securityTokenAddress).checkPermission(msg.sender, address(this), _perm), "Permission check failed");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == ISecurityToken(securityTokenAddress).owner(), "Sender is not owner");
        _;
    }

    modifier onlyFactory {
        require(msg.sender == factoryAddress, "Sender is not factory");
        _;
    }

    modifier onlyFactoryOwner {
        require(msg.sender == IModuleFactory(factoryAddress).owner(), "Sender is not factory owner");
        _;
    }

    function getPermissions() public view returns(bytes32[] memory);

    function takeFee(uint256 _amount) public withPerm(FEE_ADMIN) returns(bool) {
        require(platformToken.transferFrom(address(this), IModuleFactory(factoryAddress).owner(), _amount), "Unable to take fee");
        return true;
    }
}

 
contract ITransferManager is IModule, Pausable {

     
     
     
     
     
    enum Result {INVALID, NA, VALID, FORCE_VALID}

    function verifyTransfer(address _from, address _to, uint256 _amount, bool _isTransfer) public returns(Result);

    function unpause() public onlyOwner {
        super.pause();
    }

    function pause() public onlyOwner {
        super.unpause();
    }
}

 
contract IPermissionManager {

     
    function checkPermission(address _delegateAddress, address _moduleAddress, bytes32 _perm) public view returns(bool);

     
    function changePermission(address _delegateAddress, address _moduleAddress, bytes32 _perm, bool _valid) public returns(bool);

     
    function getDelegateDetails(address _delegateAddress) public view returns(bytes32);

}

 
contract ReentrancyGuard {

     
    bool private reentrancyLock = false;

     
    modifier nonReentrant() {
        require(!reentrancyLock, "Invlid status");
        reentrancyLock = true;
        _;
        reentrancyLock = false;
    }

}

 
library Math {
    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

 
library StringUtil {

     
    function lower(string memory _base) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for(uint i = 0; i < _baseBytes.length; i++) {
            bytes1 b1 = _baseBytes[i];
            if (b1 >= 0x41 && b1 <= 0x5A) {
                b1 = bytes1(uint8(b1)+32);
            }
            _baseBytes[i] = b1;
        }
        return string(_baseBytes);
    }

     
    function upper(string memory _base) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            bytes1 b1 = _baseBytes[i];
            if (b1 >= 0x61 && b1 <= 0x7A) {
                b1 = bytes1(uint8(b1)-32);
            }
            _baseBytes[i] = b1;
        }
        return string(_baseBytes);
    }

     
    function length(string memory _base) internal pure returns (uint) {
        bytes memory _baseBytes = bytes(_base);
        return _baseBytes.length;
    }

     
    function compare(string memory _str1, string memory _str2) internal pure returns(bool){
        return keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2));
    }

     
     
    function stringToBytes32(string memory _source) internal pure returns (bytes32) {
        return bytesToBytes32(bytes(_source), 0);
    }

     
     
    function bytesToBytes32(bytes memory _b, uint _offset) internal pure returns (bytes32) {
        bytes32 result;

        for (uint i = 0; i < _b.length; i++) {
            result |= bytes32(_b[_offset + i] & 0xFF) >> (i * 8);
        }
        return result;
    }

     
    function bytes32ToString(bytes32 _source) internal pure returns (string memory result) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(_source) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint8 j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

     
     
     
     
     
     
     


}

 
contract SecurityToken is ISecurityToken, ReentrancyGuard, ServiceHelper {

    using SafeMath for uint256;

     
    bool public freeze = false;

    struct ModuleData {
        bytes32 name;  
        address moduleAddress;  
    }

     
    bool public finishedIssuerMinting = false;
     
    bool public finishedSTOMinting = false;

    mapping (bytes4 => bool) transferFunctions;

     
    mapping (uint8 => ModuleData[]) public modules;

     
    uint8 public constant MAX_MODULES = 20;

    mapping (address => bool) public investorListed;

     
    event LogModuleAdded(
        uint8 indexed _type,
        bytes32 _name,
        address _moduleFactory,
        address _module,
        uint256 _moduleCost,
        uint256 _budget,
        uint256 _timestamp
    );

     
    event LogUpdateTokenDetails(string _oldDetails, string _newDetails);
     
    event LogGranularityChanged(uint256 _oldGranularity, uint256 _newGranularity);
     
    event LogModuleRemoved(uint8 indexed _type, address _module, uint256 _timestamp);
     
    event LogModuleBudgetChanged(uint8 indexed _moduleType, address _module, uint256 _budget);
     
    event LogFreezeTransfers(bool _freeze, uint256 _timestamp);
     
     
    event LogCheckpointCreated(uint256 indexed _checkpointId, uint256 _timestamp);
     
    event LogFinishMintingIssuer(uint256 _timestamp);
     
    event LogFinishMintingSTO(uint256 _timestamp);
     
    event LogChangeSTRAddress(address indexed _oldAddress, address indexed _newAddress);

    modifier onlyModule(uint8 _moduleType, bool _fallback) {

        bool isModuleType = false;
        for (uint8 i = 0; i < modules[_moduleType].length; i++) {
            isModuleType = isModuleType || (modules[_moduleType][i].moduleAddress == msg.sender);
        }
        if (_fallback && !isModuleType) {
            if (_moduleType == STO_KEY)
                require(modules[_moduleType].length == 0 && msg.sender == owner, "Sender is not owner or STO module is attached");
            else
                require(msg.sender == owner, "Sender is not owner");
        } else {
            require(isModuleType, "Sender is not correct module type");
        }
        _;
    }

     
    modifier checkGranularity(uint256 _amount) {
        require(_amount % granularity == 0, "Unable to modify token balances at this granularity");
        _;
    }

    modifier isMintingAllowed() {
        if (msg.sender == owner) {
            require(!finishedIssuerMinting, "Minting is finished for Issuer");
        } else {
            require(!finishedSTOMinting, "Minting is finished for STOs");
        }
        _;
    }

     
    constructor (
        string memory _tokenName,
        string memory _symbol,
        uint8 _decimals,
        uint256 _granularity,
        string memory _tokenDetails,
        address _servicesStorageAddress
    )
    public
    IERC20Detail(_tokenName, _symbol, _decimals)
    ServiceHelper(_servicesStorageAddress)
    {
        loadData();
        tokenDetails = _tokenDetails;
        granularity = _granularity;
        transferFunctions[bytes4(keccak256("transfer(address,uint256)"))] = true;
        transferFunctions[bytes4(keccak256("transferFrom(address,address,uint256)"))] = true;
        transferFunctions[bytes4(keccak256("mint(address,uint256)"))] = true;
        transferFunctions[bytes4(keccak256("burn(uint256)"))] = true;
    }

    function addModule(
        address _moduleFactoryAddress,
        bytes calldata _data,
        uint256 _maxCost,
        uint256 _budget
    ) external onlyOwner nonReentrant {
        _addModule(_moduleFactoryAddress, _data, _maxCost, _budget);
    }

     
    function _addModule(address _moduleFactoryAddress, bytes memory _data, uint256 _maxCost, uint256 _budget) internal {

        IModuleService(moduleServiceAddress).useModule(_moduleFactoryAddress);

         
        IModuleFactory moduleFactory = IModuleFactory(_moduleFactoryAddress);
         
        uint8 moduleType = moduleFactory.getType();

         
        require(modules[moduleType].length < MAX_MODULES, "Limit of MAX MODULES is reached");

         
        uint256 moduleCost = moduleFactory.setupCost();

        require(moduleCost <= _maxCost, "Max Cost is always be greater than module cost");

         
        require(IERC20(platformTokenAddress).approve(_moduleFactoryAddress, moduleCost), "Not able to approve the module cost");
        
         
        address moduleAddress = moduleFactory.create(_data);

        require(IERC20(platformTokenAddress).approve(moduleAddress, _budget), "Not able to approve the budget");
        
         
        bytes32 moduleName = moduleFactory.getName();

         
        modules[moduleType].push(ModuleData(moduleName, moduleAddress));

         
        emit LogModuleAdded(moduleType, moduleName, _moduleFactoryAddress, moduleAddress, moduleCost, _budget, now);
    }

     
    function removeModule(uint8 _moduleType, uint8 _moduleIndex) external onlyOwner {

        require(_moduleIndex < modules[_moduleType].length,"Module index doesn&#39;t exist as per the choosen module type");
        require(modules[_moduleType][_moduleIndex].moduleAddress != address(0), "Module contract address should not be 0x");
        
        emit LogModuleRemoved(_moduleType, modules[_moduleType][_moduleIndex].moduleAddress, now);
        modules[_moduleType][_moduleIndex] = modules[_moduleType][modules[_moduleType].length - 1];
        modules[_moduleType].length = modules[_moduleType].length - 1;
    }

     
    function getModule(uint8 _moduleType, uint _moduleIndex) public view returns (bytes32, address) {
        if (modules[_moduleType].length > 0) {
            return (
                modules[_moduleType][_moduleIndex].name,
                modules[_moduleType][_moduleIndex].moduleAddress
            );
        } else {
            return ("", address(0));
        }

    }

     
    function getModuleByName(uint8 _moduleType, bytes32 _name) public view returns (bytes32, address) {
        if (modules[_moduleType].length > 0) {
            for (uint256 i = 0; i < modules[_moduleType].length; i++) {
                if (keccak256(abi.encodePacked((modules[_moduleType][i].name))) == keccak256(abi.encodePacked(_name))) {
                  return (
                      modules[_moduleType][i].name,
                      modules[_moduleType][i].moduleAddress
                  );
                }
            }
            return ("", address(0));
        } else {
            return ("", address(0));
        }
    }

    function withdrawPoly(uint256 _amount) public onlyOwner {
        require(IERC20(platformTokenAddress).transfer(owner, _amount), "In-sufficient balance");
    }

     
    function changeModuleBudget(uint8 _moduleType, uint8 _moduleIndex, uint256 _budget) public onlyOwner {
        require(_moduleType != 0, "Module type cannot be zero");
        require(_moduleIndex < modules[_moduleType].length, "Incorrrect module index");
        uint256 _currentAllowance = IERC20(platformTokenAddress).allowance(address(this), modules[_moduleType][_moduleIndex].moduleAddress);
        if (_budget < _currentAllowance) {
            require(IERC20Extend(platformTokenAddress).decreaseApproval(modules[_moduleType][_moduleIndex].moduleAddress, _currentAllowance.sub(_budget)), "Insufficient balance to decreaseApproval");
        } else {
            require(IERC20Extend(platformTokenAddress).increaseApproval(modules[_moduleType][_moduleIndex].moduleAddress, _budget.sub(_currentAllowance)), "Insufficient balance to increaseApproval");
        }
        emit LogModuleBudgetChanged(_moduleType, modules[_moduleType][_moduleIndex].moduleAddress, _budget);
    }

     
    function updateTokenDetails(string memory _newTokenDetails) public onlyOwner {
        emit LogUpdateTokenDetails(tokenDetails, _newTokenDetails);
        tokenDetails = _newTokenDetails;
    }

     
    function changeGranularity(uint256 _granularity) public onlyOwner {
        require(_granularity != 0, "Granularity can not be 0");
        emit LogGranularityChanged(granularity, _granularity);
        granularity = _granularity;
    }

     
    function adjustInvestorCount(address _from, address _to, uint256 _value) internal {
        if ((_value == 0) || (_from == _to)) {
            return;
        }
         
        if ((balanceOf(_to) == 0) && (_to != address(0))) {
            investorCount = investorCount.add(1);
        }
         
        if (_value == balanceOf(_from)) {
            investorCount = investorCount.sub(1);
        }
        if (!investorListed[_to] && (_to != address(0))) {
            investors.push(_to);
            investorListed[_to] = true;
        }
    }

     
    function getInvestorsLength() public view returns(uint256) {
        return investors.length;
    }

     
    function freezeTransfers() public onlyOwner {
        require(!freeze);
        freeze = true;
        emit LogFreezeTransfers(freeze, now);
    }

     
    function unfreezeTransfers() public onlyOwner {
        require(freeze);
        freeze = false;
        emit LogFreezeTransfers(freeze, now);
    }

     
    function transfer(address _to, uint256 _value) public returns (bool success) {
        adjustInvestorCount(msg.sender, _to, _value);
        require(verifyTransfer(msg.sender, _to, _value), "Transfer is not valid");
        require(super.transfer(_to, _value));
        return true;
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        adjustInvestorCount(_from, _to, _value);
        require(verifyTransfer(_from, _to, _value), "Transfer is not valid");
        require(super.transferFrom(_from, _to, _value));
        return true;
    }

     
    function verifyTransfer(address _from, address _to, uint256 _amount) public checkGranularity(_amount) returns (bool) {
         
        if (!freeze) {
            bool isTransfer = false;
            if (transferFunctions[getSig(msg.data)]) {
              isTransfer = true;
            }
             
            if (modules[TRANSFERMANAGER_KEY].length == 0) {
                return true;
            }
            bool isInvalid = false;
            bool isValid = false;
            bool isForceValid = false;
            for (uint8 i = 0; i < modules[TRANSFERMANAGER_KEY].length; i++) {
                 
                ITransferManager.Result valid = ITransferManager(modules[TRANSFERMANAGER_KEY][i].moduleAddress).verifyTransfer(_from, _to, _amount, isTransfer);
                if (valid == ITransferManager.Result.INVALID) {
                    isInvalid = true;
                }
                if (valid == ITransferManager.Result.VALID) {
                    isValid = true;
                }
                if (valid == ITransferManager.Result.FORCE_VALID) {
                    isForceValid = true;
                }
            }
            return isForceValid ? true : (isInvalid ? false : isValid);
      }
      return false;
    }

     
    function finishMintingIssuer() public onlyOwner {
        finishedIssuerMinting = true;
        emit LogFinishMintingIssuer(now);
    }

     
    function finishMintingSTO() public onlyOwner {
        finishedSTOMinting = true;
        emit LogFinishMintingSTO(now);
    }

     
    function mintMulti(address[] memory _investors, uint256[] memory _amounts) public onlyModule(STO_KEY, true) returns (bool success) {
        require(_investors.length == _amounts.length, "Mis-match in the length of the arrays");
        for (uint256 i = 0; i < _investors.length; i++) {
            mint(_investors[i], _amounts[i]);
        }
        return true;
    }

     
    function mint(address _investor, uint256 _amount) public onlyModule(STO_KEY, true) checkGranularity(_amount) isMintingAllowed() returns (bool success) {
        require(_investor != address(0), "Investor address should not be 0x");
        adjustInvestorCount(address(0), _investor, _amount);

        require(verifyTransfer(address(0), _investor, _amount), "Transfer is not valid");
        totalSupply_ = totalSupply_.add(_amount);
        balances[_investor] = balances[_investor].add(_amount);

        emit LogMint(_investor, _amount);
        emit Transfer(address(0), _investor, _amount);
        return true;
    }

     
    function checkPermission(address _delegate, address _module, bytes32 _perm) public view returns(bool) {
        if (modules[PERMISSIONMANAGER_KEY].length == 0) {
            return false;
        }

        for (uint8 i = 0; i < modules[PERMISSIONMANAGER_KEY].length; i++) {
            if (IPermissionManager(modules[PERMISSIONMANAGER_KEY][i].moduleAddress).checkPermission(_delegate, _module, _perm)) {
                return true;
            }
        }
    }

    function getSig(bytes memory _data) internal pure returns (bytes4 sig) {
        uint len = _data.length < 4 ? _data.length : 4;
        for (uint i = 0; i < len; i++) {
             
            sig = (bytes4(msg.data[0]) | bytes4(msg.data[1]) >> 8 |bytes4(msg.data[2]) >> 16 | bytes4(msg.data[3]) >> 24);
        }
    }
}

 
contract ISTFactory {

     
    function createToken(
        string memory _tokenName, 
        string memory _symbol, 
        uint8 _decimals, 
        string memory _tokenDetails, 
        address _issuer, 
        bool _divisible, 
        address _servicesStorageAddress)
        public returns (address);
}

 
contract ISecurityTokenService {

    struct SecurityTokenData {
        string symbol;
        string tokenDetails;
    }

     
    mapping(address => SecurityTokenData) securityTokens;

     
    mapping(string => address) symbols;

     
    function generateSecurityToken(string memory _tokenName, string memory _symbol, string memory _tokenDetails, bool _divisible) public;

     
    function getSecurityTokenAddress(string memory _symbol) public view returns (address);

     
    function getSecurityTokenData(address _securityTokenAddress) public view returns (string memory, address, string memory);
    
     
    function isSecurityToken(address _securityTokenAddress) public view returns (bool);
}

 
contract SecurityTokenService is ISecurityTokenService, Pausable, ServiceHelper {

    using StringUtil for string;

     
    uint256 public registrationFee;

     
    address public stFactoryAddress;

     
    event LogChangeRegistrationFee(uint256 _oldFee, uint256 _newFee);
     
    event LogNewSecurityToken(string _ticker, address indexed _securityTokenAddress, address indexed _owner);

     
    constructor (
        address _servicesStorageAddress,
        address _stFactoryAddress,
        uint256 _registrationFee
    )
    public
    ServiceHelper(_servicesStorageAddress)
    {
        stFactoryAddress = _stFactoryAddress;
        registrationFee = _registrationFee;
    }

     
    function generateSecurityToken(string memory _tokenName, string memory _symbol, string memory _tokenDetails, bool _divisible) public whenNotPaused {
        
         
        require(_tokenName.length() > 0 && _symbol.length() > 0, "Name and Symbol string length should be greater than 0");
        
         
        require(ITickerService(tickerServiceAddress).checkValidity(_symbol, msg.sender, _tokenName), "Trying to use non-valid symbol");

         
        if(registrationFee > 0){
            require(IERC20(platformTokenAddress).transferFrom(msg.sender, address(this), registrationFee), "Failed transferFrom because of sufficent Allowance is not provided");
        }
         
        string memory symbol = _symbol.upper();
        
         
        address newSecurityTokenAddress = ISTFactory(stFactoryAddress).createToken(
            _tokenName,
            symbol,
            18,
            _tokenDetails,
            msg.sender,
            _divisible,
            servicesStorageAddress
        );

         
        securityTokens[newSecurityTokenAddress] = SecurityTokenData(symbol, _tokenDetails);
         
        symbols[symbol] = newSecurityTokenAddress;

         
        emit LogNewSecurityToken(symbol, newSecurityTokenAddress, msg.sender);
    }

     
    function setSTFactory(address _stFactoryAddress) public onlyOwner {
        require(_stFactoryAddress != address(0), "Invalid address!");
        stFactoryAddress = _stFactoryAddress;
    }

     
    function getSecurityTokenAddress(string memory _symbol) public view returns (address) {
        string memory symbol = _symbol.upper();
        return symbols[symbol];
    }

     
    function getSecurityTokenData(address _securityTokenAddress) public view returns (string memory, address, string memory) {
        return (
            securityTokens[_securityTokenAddress].symbol,
            ISecurityToken(_securityTokenAddress).owner(),
            securityTokens[_securityTokenAddress].tokenDetails
        );
    }

     
    function isSecurityToken(address _securityTokenAddress) public view returns (bool) {
        return (keccak256(bytes(securityTokens[_securityTokenAddress].symbol)) != keccak256(""));
    }

     
    function changeRegistrationFee(uint256 _registrationFee) public onlyOwner {
        require(registrationFee != _registrationFee, "Registration fee should not equal to previous");
        emit LogChangeRegistrationFee(registrationFee, _registrationFee);
        registrationFee = _registrationFee;
    }

    function unpause() public onlyOwner  {
        super.pause();
    }

    function pause() public onlyOwner {
        super.unpause();
    }

}

 
contract STFactory is ISTFactory {

    address public transferManagerFactory;

    bool addTransferManager = true;

    constructor (address _transferManagerFactory) public {
        transferManagerFactory = _transferManagerFactory;
    }


     
    function createToken(
        string memory _tokenName, 
        string memory _symbol, 
        uint8 _decimals, 
        string memory _tokenDetails, 
        address _issuer, 
        bool _divisible, 
        address _servicesStorageAddress)
    public returns (address){
        SecurityToken newSecurityToken = new SecurityToken(
        _tokenName,
        _symbol,
        _decimals,
        _divisible ? 1 : uint256(10)**_decimals,
        _tokenDetails,
        _servicesStorageAddress
        );

        address newSecurityTokenAddress = address(newSecurityToken);

        if (addTransferManager) {
            
             
            SecurityToken(newSecurityTokenAddress).addModule(transferManagerFactory, "", 0, 0);
        }

         
        SecurityToken(newSecurityTokenAddress).transferOwnership(_issuer);

        return newSecurityTokenAddress;
    }
}