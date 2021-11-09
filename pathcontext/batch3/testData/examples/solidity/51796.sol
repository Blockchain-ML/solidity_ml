pragma solidity ^0.5.0;

 
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

 
contract ManualApprovalTransferManager is ITransferManager {
    
    using SafeMath for uint256;

     
    address public issuanceAddress = address(0);

     
    address public signingAddress = address(0);

    bytes32 public constant TRANSFER_APPROVAL = "TRANSFER_APPROVAL";

    struct ManualApproval {
        uint256 allowance;
        uint256 expiryTime;
    }

    struct ManualBlocking {
        uint256 expiryTime;
    }

    mapping (address => mapping (address => ManualApproval)) public manualApprovals;

    mapping (address => mapping (address => ManualBlocking)) public manualBlockings;

    event LogAddManualApproval(
        address indexed _from,
        address indexed _to,
        uint256 _allowance,
        uint256 _expiryTime,
        address indexed _addedBy
    );

    event LogAddManualBlocking(
        address indexed _from,
        address indexed _to,
        uint256 _expiryTime,
        address indexed _addedBy
    );

    event LogRevokeManualApproval(
        address indexed _from,
        address indexed _to,
        address indexed _addedBy
    );

    event LogRevokeManualBlocking(
        address indexed _from,
        address indexed _to,
        address indexed _addedBy
    );

    
    constructor (address _securityTokenAddress, address _platformTokenAddress)
    public
    IModule(_securityTokenAddress, _platformTokenAddress)
    {
    }

    
    function getInitFunction() public pure returns (bytes4) {
        return bytes4(0);
    }

    function verifyTransfer(address _from, address _to, uint256 _amount, bool _isTransfer) public returns(Result) {
        require(_isTransfer == false || msg.sender == securityTokenAddress, "Sender is not owner");
        if (!paused) {


            if (manualBlockings[_from][_to].expiryTime >= now) {
                return Result.INVALID;
            }
            if ((manualApprovals[_from][_to].expiryTime >= now) && (manualApprovals[_from][_to].allowance >= _amount)) {
                if (_isTransfer) {
                    manualApprovals[_from][_to].allowance = manualApprovals[_from][_to].allowance.sub(_amount);
                }
                return Result.VALID;
            }
        }
        return Result.NA;
    }

    function addManualApproval(address _from, address _to, uint256 _allowance, uint256 _expiryTime) public withPerm(TRANSFER_APPROVAL) {
        require(_from != address(0), "Invalid from address");
        require(_to != address(0), "Invalid to address");
        require(_expiryTime > now, "Invalid expiry time");
        require(manualApprovals[_from][_to].allowance == 0, "Approval already exists");

        manualApprovals[_from][_to] = ManualApproval(_allowance, _expiryTime);

        emit LogAddManualApproval(_from, _to, _allowance, _expiryTime, msg.sender);
    }

    function addManualBlocking(address _from, address _to, uint256 _expiryTime) public withPerm(TRANSFER_APPROVAL) {
        require(_from != address(0), "Invalid from address");
        require(_to != address(0), "Invalid to address");
        require(_expiryTime > now, "Invalid expiry time");
        require(manualBlockings[_from][_to].expiryTime == 0, "Blocking already exists");

        manualBlockings[_from][_to] = ManualBlocking(_expiryTime);

        emit LogAddManualBlocking(_from, _to, _expiryTime, msg.sender);
    }

    function revokeManualApproval(address _from, address _to) public withPerm(TRANSFER_APPROVAL) {
        require(_from != address(0), "Invalid from address");
        require(_to != address(0), "Invalid to address");

        delete manualApprovals[_from][_to];

        emit LogRevokeManualApproval(_from, _to, msg.sender);
    }


    function revokeManualBlocking(address _from, address _to) public withPerm(TRANSFER_APPROVAL) {
        require(_from != address(0), "Invalid from address");
        require(_to != address(0), "Invalid to address");

        delete manualBlockings[_from][_to];

        emit LogRevokeManualBlocking(_from, _to, msg.sender);
    }

    
    function getPermissions() public view returns(bytes32[] memory) {
        bytes32[] memory allPermissions = new bytes32[](1);
        allPermissions[0] = TRANSFER_APPROVAL;
        return allPermissions;
    }
}

contract ManualApprovalTransferManagerFactory is IModuleFactory {

    
    constructor (address _platformTokenAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost) public
      IModuleFactory(_platformTokenAddress, _setupCost, _usageCost, _subscriptionCost)
    {

    }

    
    function create(bytes calldata  ) external returns(address) {

        if (setupCost > 0){
            require(platformToken.transferFrom(msg.sender, owner, setupCost), "Failed transferFrom because of sufficent Allowance is not provided");
        }

        ManualApprovalTransferManager manualTransferManager = new ManualApprovalTransferManager(msg.sender, address(platformToken));

        emit LogGenerateModuleFromFactory(address(manualTransferManager), getName(), address(this), msg.sender, now);

        return address(manualTransferManager);
    }

    
    function getType() public view returns(uint8) {
        return 2;
    }

    
    function getName() public view returns(bytes32) {
        return "ManualApprovalTransferManager";
    }

    
    function getDescription() public view returns(string memory) {
        return "Manage transfers using single approvals / blocking";
    }

    
    function getTitle() public view returns(string memory) {
        return "Manual Approval Transfer Manager";
    }

    
    function getInstructions() public view returns(string memory) {
        return "Allows an issuer to set manual approvals or blocks for specific pairs of addresses and amounts. Init function takes no parameters.";
    }

    
    function getTags() public view returns(bytes32[] memory) {
        bytes32[] memory availableTags = new bytes32[](2);
        availableTags[0] = "ManualApproval";
        availableTags[1] = "Transfer Restriction";
        return availableTags;
    }
}