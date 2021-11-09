pragma solidity ^0.5.0;

 
contract IModuleService {
    
    function useModule(address _moduleFactoryAddress) external;

    
    function registerModule(address _moduleFactoryAddress) external returns(bool);

   
    function getTagByModuleType(uint8 _moduleType) public view returns(bytes32[] memory);
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
        serviceStorage = ServiceStorage(_servicesStorageAddress);
    }

    function loadData() public onlyOwner {
        moduleServiceAddress = serviceStorage.get("moduleService");
        securityTokenServiceAddress = serviceStorage.get("securityTokenService");
        tickerServiceAddress = serviceStorage.get("tickerService");
        platformTokenAddress = serviceStorage.get("platformToken");
    }

}

contract ModuleService is IModuleService, ServiceHelper,  Pausable {

     
    mapping (address => uint8) public services;

     
    mapping (address => bool) public verified;

     
    mapping (address => address[]) public reputation;

     
    mapping (uint8 => address[]) public moduleList;
    
     
    mapping (uint8 => bytes32[]) public availableTags;
    
    
    

     
    event LogModuleUsed(address indexed _moduleFactory, address indexed _securityToken);
     
    event LogModuleRegistered(address indexed _moduleFactory, address indexed _owner);
     
    event LogModuleVerified(address indexed _moduleFactory, bool _verified);

     
    constructor (address _servicesStorageAddress) public
        ServiceHelper(_servicesStorageAddress)
    {
    }

     
    function useModule(address _moduleFactoryAddress) external {

        if (ISecurityTokenService(securityTokenServiceAddress).isSecurityToken(msg.sender)) {

            require(services[_moduleFactoryAddress] != 0, "ModuleFactory type should not be 0");

            require(verified[_moduleFactoryAddress] || (IModuleFactory(_moduleFactoryAddress).owner() == ISecurityToken(msg.sender).owner()),"Module factory is not verified as well as not called by the owner");

            reputation[_moduleFactoryAddress].push(msg.sender);

            emit LogModuleUsed (_moduleFactoryAddress, msg.sender);
        }
    }

     
    function registerModule(address _moduleFactoryAddress) external returns(bool){

        require(services[_moduleFactoryAddress] == 0, "Module factory should not be pre-registered");

         
        IModuleFactory moduleFactory = IModuleFactory(_moduleFactoryAddress);

         
        require(moduleFactory.getType() != 0, "Factory type should not equal to 0");

         
        services[_moduleFactoryAddress] = moduleFactory.getType();

         
        moduleList[moduleFactory.getType()].push(_moduleFactoryAddress);

        reputation[_moduleFactoryAddress] = new address[](0);

        emit LogModuleRegistered (_moduleFactoryAddress, moduleFactory.owner());

        return true;
    }

     
    function getTagByModuleType(uint8 _moduleType) public view returns(bytes32[] memory) {
        return availableTags[_moduleType];
    }

     
    function addTagByModuleType(uint8 _moduleType, bytes32[] memory _tag) public onlyOwner {
        for (uint8 i = 0; i < _tag.length; i++) {
            availableTags[_moduleType].push(_tag[i]);
        }
    }

     
    function removeTagByModuleType(uint8 _moduleType, bytes32[] memory _removedTags) public onlyOwner {
        for (uint8 i = 0; i < availableTags[_moduleType].length; i++) {
            for (uint8 j = 0; j < _removedTags.length; j++) {
                if (availableTags[_moduleType][i] == _removedTags[j]) {
                    delete availableTags[_moduleType][i];
                }
            }
        }
    }

     
    function verifyModule(address _moduleFactoryAddress, bool _verified) external onlyOwner returns(bool) {
         
        require(services[_moduleFactoryAddress] != 0, "Module factory should have been already registered");

         
        verified[_moduleFactoryAddress] = _verified;

         
        emit LogModuleVerified(_moduleFactoryAddress, _verified);
        return true;
    }

    function unpause() public onlyOwner  {
        super.unpause();
    }

    function pause() public onlyOwner {
        super.pause();
    }
}