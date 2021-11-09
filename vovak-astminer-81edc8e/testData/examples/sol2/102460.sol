 

 
 

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}


 

 
 

interface IERC2917 is IERC20 {

     
     
    event InterestsPerBlockChanged (uint oldValue, uint newValue);

     
     
    event ProductivityIncreased (address indexed user, uint value);

     
     
    event ProductivityDecreased (address indexed user, uint value);

    
     
     
    function interestsPerBlock() external view returns (uint);

     
     
     
    function changeInterestsPerBlock(uint value) external returns (bool);

     
     
     
    function getProductivity(address user) external view returns (uint, uint);

     
     
     
    function increaseProductivity(address user, uint value) external returns (uint);

     
     
     
    function decreaseProductivity(address user, uint value) external returns (uint);

     
     
     
    function take() external view returns (uint);

     
     
     
    function takeWithBlock() external view returns (uint, uint);

     
     
     
    function mint(address to) external returns (uint);
}


 

 

contract UpgradableProduct {
    address public impl;

    event ImplChanged(address indexed _oldImpl, address indexed _newImpl);

    constructor() public {
        impl = msg.sender;
    }

    modifier requireImpl() {
        require(msg.sender == impl, 'FORBIDDEN');
        _;
    }

    function upgradeImpl(address _newImpl) public requireImpl {
        require(_newImpl != address(0), 'INVALID_ADDRESS');
        require(_newImpl != impl, 'NO_CHANGE');
        address lastImpl = impl;
        impl = _newImpl;
        emit ImplChanged(lastImpl, _newImpl);
    }
}

contract UpgradableGovernance {
    address public governor;

    event GovernorChanged(address indexed _oldGovernor, address indexed _newGovernor);

    constructor() public {
        governor = msg.sender;
    }

    modifier requireGovernor() {
        require(msg.sender == governor, 'FORBIDDEN');
        _;
    }

    function upgradeGovernance(address _newGovernor) public requireGovernor {
        require(_newGovernor != address(0), 'INVALID_ADDRESS');
        require(_newGovernor != governor, 'NO_CHANGE');
        address lastGovernor = governor;
        governor = _newGovernor;
        emit GovernorChanged(lastGovernor, _newGovernor);
    }
}


 


 

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

 

 

 
 
 

 
contract WasabiToken is IERC2917, UpgradableProduct, UpgradableGovernance {
    using SafeMath for uint;

    uint public mintCumulation;
    uint public maxMintCumulation;

    struct Production {
        uint amount;             
        uint total;              
        uint block;              
    }

    Production internal grossProduct = Production(0, 0, 0);

    struct Productivity {
        uint product;            
        uint total;              
        uint block;              
        uint user;               
        uint global;             
        uint gross;              
    }

    Productivity public global;
    mapping(address => Productivity) public users;

    uint private unlocked = 1;

    modifier lock() {
        require(unlocked == 1, 'Locked');
        unlocked = 0;
        _;
        unlocked = 1;
    }

     
    string override public name;
    string override public symbol;
    uint8 override public decimals = 18;
    uint override public totalSupply;

    mapping(address => uint) override public balanceOf;
    mapping(address => mapping(address => uint)) override public allowance;

    function _transfer(address from, address to, uint value) private {
        require(balanceOf[from] >= value, 'ERC20Token: INSUFFICIENT_BALANCE');
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        if (to == address(0)) {  
            totalSupply = totalSupply.sub(value);
        }
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external override returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external override returns (bool) {
        require(allowance[from][msg.sender] >= value, 'ERC20Token: INSUFFICIENT_ALLOWANCE');
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

     

     
    constructor(uint _interestsRate, uint _maxMintCumulation) UpgradableProduct() UpgradableGovernance() public {
        name        = "Wasabi Swap";
        symbol      = "WASABI";
        decimals    = 18;

        maxMintCumulation = _maxMintCumulation;
        grossProduct.amount = _interestsRate;
        grossProduct.block  = block.number;
    }

     
    function _computeBlockProduct() private view returns (uint) {
        uint elapsed = block.number.sub(grossProduct.block);
        return grossProduct.amount.mul(elapsed);
    }

     
    function _computeProductivity(Productivity memory user) private view returns (uint) {
        uint blocks = block.number.sub(user.block);
        return user.total.mul(blocks);
    }

     
    function _updateProductivity(Productivity storage user, uint value, bool increase) private returns (uint productivity) {
        user.product      = user.product.add(_computeProductivity(user));
        global.product    = global.product.add(_computeProductivity(global));

        require(global.product <= uint(-1), 'GLOBAL_PRODUCT_OVERFLOW');

        user.block      = block.number;
        global.block    = block.number;
        if(increase) {
            user.total   = user.total.add(value);
            global.total = global.total.add(value);
        }
        else {
            user.total   = user.total.sub(value);
            global.total = global.total.sub(value);
        }
        productivity = user.total;
    }

     
     
     
     
    function changeInterestsPerBlock(uint value) external override requireGovernor returns (bool) {
        uint old = grossProduct.amount;
        require(value != old, 'AMOUNT_PER_BLOCK_NO_CHANGE');

        uint product                = _computeBlockProduct();
        grossProduct.total          = grossProduct.total.add(product);
        grossProduct.block          = block.number;
        grossProduct.amount         = value;
        require(grossProduct.total <= uint(-1), 'BLOCK_PRODUCT_OVERFLOW');

        emit InterestsPerBlockChanged(old, value);
        return true;
    }

     
     
     
     
    function increaseProductivity(address user, uint value) external override requireImpl returns (uint) {
        if(mintCumulation >= maxMintCumulation)
            return 0;
        require(value > 0, 'PRODUCTIVITY_VALUE_MUST_BE_GREATER_THAN_ZERO');
        Productivity storage product        = users[user];

        if (product.block == 0) {
            product.gross = grossProduct.total.add(_computeBlockProduct());
            product.global = global.product.add(_computeProductivity(global));
        }
        
        uint _productivity = _updateProductivity(product, value, true);
        emit ProductivityIncreased(user, value);
        return _productivity;
    }

     
     
     
    function decreaseProductivity(address user, uint value) external override requireImpl returns (uint) {
        if(mintCumulation >= maxMintCumulation)
            return 0;
        Productivity storage product = users[user];

        require(value > 0 && product.total >= value, 'INSUFFICIENT_PRODUCTIVITY');
        
        uint _productivity = _updateProductivity(product, value, false);
        emit ProductivityDecreased(user, value);
        return _productivity;
    }


     
     
     
    function mint(address to) external override lock returns (uint) {
        if(mintCumulation >= maxMintCumulation)
            return 0;

        (uint gp, uint userProduct, uint globalProduct, uint amount) = _computeUserProduct();

        if(amount == 0)
            return 0;

        Productivity storage product = users[msg.sender];
        product.gross   = gp;
        product.user    = userProduct;
        product.global  = globalProduct;

        if (mintCumulation.add(amount) > maxMintCumulation) {
            amount = mintCumulation.add(amount).sub(maxMintCumulation);
        }
        balanceOf[to]   = balanceOf[to].add(amount);
        totalSupply     = totalSupply.add(amount);
        mintCumulation  = mintCumulation.add(amount);

        emit Transfer(address(0), msg.sender, amount);
        return amount;
    }

     
    function _computeUserProduct() private view returns (uint gp, uint userProduct, uint globalProduct, uint amount) {
        Productivity memory product    = users[msg.sender];

        gp              = grossProduct.total.add(_computeBlockProduct());
        userProduct     = product.product.add(_computeProductivity(product));
        globalProduct   = global.product.add(_computeProductivity(global));

        uint deltaBlockProduct  = gp.sub(product.gross);
        uint numerator          = userProduct.sub(product.user);
        uint denominator        = globalProduct.sub(product.global);

        if (denominator > 0) {
            amount = deltaBlockProduct.mul(numerator) / denominator;
        }
    }

    function burnAndReward(uint amountBurn, address rewardToken) public returns (uint amountReward) {
        uint totalReward = IERC20(rewardToken).balanceOf(address(this));
        require(totalReward > 0 && totalSupply > 0, "Invalid.");
        require(IERC20(rewardToken).balanceOf(msg.sender) >= amountBurn, "Insufficient.");

        amountReward = amountBurn.mul(totalReward).div(totalSupply);
        _transfer(msg.sender, address(0), amountBurn);
        IERC20(rewardToken).transfer(msg.sender, amountReward);
    }

     
    function getProductivity(address user) external override view returns (uint, uint) {
        return (users[user].total, global.total);
    }

     
    function interestsPerBlock() external override view returns (uint) {
        return grossProduct.amount;
    }

     
    function take() external override view returns (uint) {
        if(mintCumulation >= maxMintCumulation)
            return 0;
        (, , , uint amount) = _computeUserProduct();
        return amount;
    }

     
    function takeWithBlock() external override view returns (uint, uint) {
        if(mintCumulation >= maxMintCumulation)
            return (0, block.number);
        (, , , uint amount) = _computeUserProduct();
        return (amount, block.number);
    }
}


 


 

library SushiHelper {
    function deposit(address masterChef, uint256 pid, uint256 amount) internal {
        (bool success, bytes memory data) = masterChef.call(abi.encodeWithSelector(0xe2bbb158, pid, amount));
        require(success && data.length == 0, "SushiHelper: DEPOSIT FAILED");
    }

    function withdraw(address masterChef, uint256 pid, uint256 amount) internal {
        (bool success, bytes memory data) = masterChef.call(abi.encodeWithSelector(0x441a3e70, pid, amount));
        require(success && data.length == 0, "SushiHelper: WITHDRAW FAILED");
    }

    function pendingSushi(address masterChef, uint256 pid, address user) internal returns (uint256 amount) {
        (bool success, bytes memory data) = masterChef.call(abi.encodeWithSelector(0x195426ec, pid, user));
        require(success && data.length != 0, "SushiHelper: WITHDRAW FAILED");
        amount = abi.decode(data, (uint256));
    }
}


library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
         
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
         
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
         
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


 

 

interface IWasabi {
    function getOffer(address  _lpToken,  uint index) external view returns (address offer);
    function getOfferLength(address _lpToken) external view returns (uint length);
    function pool(address _token) external view returns (uint);
    function increaseProductivity(uint amount) external;
    function decreaseProductivity(uint amount) external;
    function tokenAddress() external view returns(address);
    function addTakerOffer(address _offer, address _user) external returns (uint);
    function getUserOffer(address _user, uint _index) external view returns (address);
    function getUserOffersLength(address _user) external view returns (uint length);
    function getTakerOffer(address _user, uint _index) external view returns (address);
    function getTakerOffersLength(address _user) external view returns (uint length);
    function offerStatus() external view returns(uint amountIn, address masterChef, uint sushiPid);
    function cancel(address _from, address _sushi) external ;
    function take(address taker,uint amountWasabi) external;
    function payback(address _from) external;
    function close(address _from, uint8 _state, address _sushi) external  returns (address tokenToOwner, address tokenToTaker, uint amountToOwner, uint amountToTaker);
    function upgradeGovernance(address _newGovernor) external;
    function acceptToken() external view returns(address);
    function rewardAddress() external view returns(address);
    function getTokensLength() external view returns (uint);
    function tokens(uint _index) external view returns(address);
    function offers(address _offer) external view returns(address tokenIn, address tokenOut, uint amountIn, uint amountOut, uint expire, uint interests, uint duration);
    function getRateForOffer(address _offer) external view returns (uint offerFeeRate, uint offerInterestrate);
}


 

 
 
 
 
 
 

interface IMasterChef {
    function pendingSushi(uint256 _pid, address _user)
        external
        view
        returns (uint256);
}

contract Offer {
    using SafeMath for uint256;
     
    enum OfferState {Created, Opened, Taken, Paidback, Expired, Closed}
    address public wasabi;
    address public owner;
    address public taker;
    address public sushi;

    uint8 public state = 0;

    event StateChange(
        uint256 _prev,
        uint256 _curr,
        address from,
        address to,
        address indexed token,
        uint256 indexed amount
    );

    constructor() public {
        wasabi = msg.sender;
    }

    function getState() public view returns (uint256 _state) {
        _state = uint256(state);
    }

    function tranferToken(
        address token,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(msg.sender == wasabi, "WASABI OFFER : TRANSFER PERMISSION DENY");
        TransferHelper.safeTransfer(token, to, amount);
    }

    function initialize(
        address _owner,
        address _sushi,
        uint256 sushiPid,
        address tokenIn,
        address masterChef,
        uint256 amountIn
    ) external {
        require(msg.sender == wasabi, "WASABI OFFER : INITIALIZE PERMISSION DENY");
        require(state == 0);
        owner = _owner;
        sushi = _sushi;
        state = 1;
        if (sushiPid > 0) {
            TransferHelper.safeApprove(tokenIn, masterChef, amountIn);
            SushiHelper.deposit(masterChef, sushiPid, amountIn);
        }
    }

    function cancel() public returns (uint256 amount) {
        require(msg.sender == owner, "WASABI OFFER : CANCEL SENDER IS OWNER");
        (uint256 _amount, address _masterChef, uint256 _sushiPid) = IWasabi(
            wasabi
        )
            .offerStatus();
        state = 5;
        if (_sushiPid > 0) {
            SushiHelper.withdraw(_masterChef, _sushiPid, _amount);
        }
        amount = WasabiToken(IWasabi(wasabi).tokenAddress()).mint(msg.sender);
        IWasabi(wasabi).cancel(msg.sender, sushi);
    }

    function take() external {
        require(state == 1, "WASABI OFFER : TAKE STATE ERROR");
        require(msg.sender != owner, "WASABI OFFER : TAKE SENDER IS OWNER");
        state = 2;
        address tokenAddress = IWasabi(wasabi).tokenAddress();
        uint256 amountWasabi = WasabiToken(tokenAddress).mint(address(this));
        IWasabi(wasabi).take(msg.sender, amountWasabi);
        taker = msg.sender;
    }

    function payback() external {
        require(state == 2, "WASABI: payback");
        state = 3;
        IWasabi(wasabi).payback(msg.sender);
    }

    function close()
        external
        returns (
            address,
            address,
            uint256,
            uint256
        )
    {
        require(state != 5, "WASABI OFFER : TAKE STATE ERROR");
        (uint256 _amount, address _masterChef, uint256 _sushiPid) = IWasabi(
            wasabi
        )
            .offerStatus();
        if (_sushiPid > 0) {
            SushiHelper.withdraw(_masterChef, _sushiPid, _amount);
        }
        uint8 oldState = state;
        state = 5;
        return IWasabi(wasabi).close(msg.sender, oldState, sushi);
    }

    function getEstimatedWasabi() external view returns (uint256 amount) {
        address tokenAddress = IWasabi(wasabi).tokenAddress();
        amount = WasabiToken(tokenAddress).take();
    }

    function getEstimatedSushi() external view returns (uint256 amount) {
        (, address _masterChef, uint256 _sushiPid) = IWasabi(wasabi)
            .offerStatus();
        amount = IMasterChef(_masterChef).pendingSushi(
            _sushiPid,
            address(this)
        );
    }
}


 

pragma solidity >=0.5.16;
 
 
 
 

contract Wasabi is UpgradableGovernance
{
    using SafeMath for uint;
    address public rewardAddress;
    address public tokenAddress;
    address public sushiAddress;
    address public masterChef;
    address public acceptToken;
    bytes32 public contractCodeHash;
    mapping(address => address[]) public allOffers;
    uint public feeRate;
    uint public interestRate;
    
    mapping(address => uint) public offerStats;
    mapping(address => address[]) public userOffers;
    mapping(address => uint) public pool;
    mapping(address => address[]) public takerOffers;
    mapping(address => uint) public sushiPids;
    address[] public tokens;
  
    struct OfferStruct {
        address tokenIn;
        address tokenOut;
        uint amountIn;
        uint amountOut;
        uint expire;
        uint interests;
        uint duration;
        uint feeRate;
        uint interestrate;
        address owner;
        address taker;
        address masterChef;
        uint sushiPid;
        uint productivity;
    }
    
    mapping(address => OfferStruct) public offers;

    function setPoolShare(address _token, uint _share) requireGovernor public {
        if (pool[_token] == 0) {
            tokens.push(_token);
        }
        pool[_token] = _share;
    }

    function getTokens() external view returns (address[] memory) {
        return tokens;
    }

    function getTokensLength() external view returns (uint) {
        return tokens.length;
    }

    function setFeeRate(uint _feeRate) requireGovernor public  {
        feeRate = _feeRate;
    }

    function setInterestRate(uint _interestRate) requireGovernor public  {
        interestRate = _interestRate;
    }

    function setSushiPid(address _token, uint _pid) requireGovernor public  {
        sushiPids[_token] = _pid;
    }

    function getRateForOffer(address _offer) external view returns (uint offerFeeRate, uint offerInterestrate) {
        OfferStruct memory offer = offers[_offer];
        offerFeeRate = offer.feeRate;
        offerInterestrate = offer.interestrate;
    }

    event OfferCreated(address indexed _tokenIn, address indexed _tokenOut, uint _amountIn, uint _amountOut, uint _duration, uint _interests, address indexed _offer);
    event OfferChanged(address indexed _offer, uint _state);

    constructor(address _rewardAddress, address _wasabiTokenAddress, address _sushiAddress, address _masterChef, address _acceptToken) public  {
        rewardAddress = _rewardAddress;
        tokenAddress = _wasabiTokenAddress;
        sushiAddress = _sushiAddress;
        masterChef = _masterChef;
        feeRate = 100;
        interestRate = 1000;
        acceptToken = _acceptToken;
    }

    function createOffer(
        address[2] memory _addrs,
        uint[4] memory _uints) public returns(address offer, uint productivity) 
    {
        require(_addrs[0] != _addrs[1],     "WASABI: INVALID TOKEN IN&OUT");
        require(_uints[3] < _uints[1],      "WASABI: INVALID INTERESTS");
        require(pool[_addrs[0]] > 0,        "WASABI: INVALID TOKEN");
        require(_uints[1] > 0,              "WASABI: INVALID AMOUNT OUT");
         
        require(_addrs[1] == acceptToken, "WASABI: ONLY USDT SUPPORTED");

        bytes memory bytecode = type(Offer).creationCode;
        if (uint(contractCodeHash) == 0) {
            contractCodeHash = keccak256(bytecode);
        }
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, _addrs[0], _addrs[1], _uints[0], _uints[1], _uints[2], _uints[3], block.number));
        assembly {
            offer := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        productivity = pool[_addrs[0]] * _uints[0];
        uint sushiPid = sushiPids[_addrs[0]];
        offers[offer] = OfferStruct({
            productivity:productivity,
            tokenIn: _addrs[0],
            tokenOut: _addrs[1],
            amountIn: _uints[0],
            amountOut :_uints[1],
            expire :0,
            interests:_uints[3],
            duration:_uints[2],
            feeRate:feeRate,
            interestrate:interestRate,
            owner:msg.sender,
            taker:address(0),
            masterChef:masterChef,
            sushiPid:sushiPid
        });
        WasabiToken(tokenAddress).increaseProductivity(offer, productivity);
        TransferHelper.safeTransferFrom(_addrs[0], msg.sender, offer, _uints[0]);
        offerStats[offer] = 1;
        Offer(offer).initialize(msg.sender, sushiAddress, sushiPid, _addrs[0], masterChef, _uints[0]);
        
        allOffers[_addrs[0]].push(offer);
    
        userOffers[msg.sender].push(offer);

        emit OfferCreated(_addrs[0], _addrs[1], _uints[0], _uints[1], _uints[2], _uints[3], offer);
    }
    
    function cancel(address _from, address sushi) external {
        require(offerStats[msg.sender] != 0, "WASABI: CANCEL OFFER NOT FOUND");
        OfferStruct storage offer = offers[msg.sender];
        if (offer.productivity > 0) {
            WasabiToken(tokenAddress).decreaseProductivity(msg.sender, offer.productivity);
        }
        if(offer.sushiPid > 0) {
            Offer(msg.sender).tranferToken(sushi,_from, IERC20(sushi).balanceOf(msg.sender));
        }
        OfferChanged(msg.sender, Offer(msg.sender).state());
    }
    
    function take(address _from, uint amountWasabi) external {
        require(offerStats[msg.sender] != 0, "WASABI: TAKE OFFER NOT FOUND");
        OfferStruct storage offer = offers[msg.sender];
        offer.taker = _from;
        offer.expire = offer.duration.add(block.number);
        uint platformFee = offer.amountOut.mul(offer.feeRate).div(10000); 
        uint feeAmount = platformFee.add(offer.interests.mul(offer.interestrate).div(10000)); 
        TransferHelper.safeTransferFrom(offer.tokenOut, _from, rewardAddress, feeAmount);
        
        uint amountToOwner = offer.amountOut.sub(offer.interests.add(platformFee));
        TransferHelper.safeTransferFrom(offer.tokenOut, _from, offer.owner, amountToOwner); 
        
        TransferHelper.safeTransferFrom(offer.tokenOut, _from, msg.sender, offer.amountOut.sub(amountToOwner).sub(feeAmount));
        
        WasabiToken(tokenAddress).decreaseProductivity(msg.sender, offer.amountOut);
        uint amountWasabiTeam = amountWasabi.mul(1).div(10);
        Offer(msg.sender).tranferToken(tokenAddress, rewardAddress, amountWasabiTeam);
        Offer(msg.sender).tranferToken(tokenAddress, offer.owner, amountWasabi - amountWasabiTeam);
        addTakerOffer(msg.sender, _from);
        OfferChanged(msg.sender, Offer(msg.sender).state());
    }
    

    function payback(address _from) external {
        require(offerStats[msg.sender] != 0, "WASABI: PAYBACK OFFER NOT FOUND");
        OfferStruct storage offer = offers[msg.sender];
        TransferHelper.safeTransferFrom(offer.tokenOut, _from, msg.sender, offer.amountOut);
        OfferChanged(msg.sender, Offer(msg.sender).state());
    }
    
    function close(address _from, uint8 _state, address sushi) external returns (address tokenToOwner, address tokenToTaker, uint amountToOwner, uint amountToTaker) {
        require(offerStats[msg.sender] != 0, "WASABI: CLOSE OFFER NOT FOUND");
        OfferStruct storage offer = offers[msg.sender];
        require(_state == 3 || block.number >= offer.expire, "WASABI: INVALID STATE");
        require(_from == offer.owner || _from == offer.taker, "WASABI: INVALID CALLEE");
         if(_state == 3) {
            amountToTaker = offer.amountOut.add(offer.interests.sub(offer.interests.div(10)));
            tokenToTaker = offer.tokenOut;
            Offer(msg.sender).tranferToken(tokenToTaker,  offer.taker, amountToTaker);
            amountToOwner = offer.amountIn;
            tokenToOwner = offer.tokenIn;
            Offer(msg.sender).tranferToken(tokenToOwner, offer.owner, amountToOwner);
            Offer(msg.sender).tranferToken(sushi, offer.owner, IERC20(sushi).balanceOf(msg.sender));
        }
         
        else if(block.number >= offer.expire) {
            amountToTaker = offer.amountIn;
            tokenToTaker = offer.tokenIn;
            Offer(msg.sender).tranferToken(tokenToTaker, offer.taker, amountToTaker);

            uint  amountRest = IERC20(offer.tokenOut).balanceOf(msg.sender);
            Offer(msg.sender).tranferToken(offer.tokenOut, offer.taker, amountRest);
            Offer(msg.sender).tranferToken(sushi, offer.taker, IERC20(sushi).balanceOf(msg.sender));
        }
        OfferChanged(msg.sender, Offer(msg.sender).state());
    }
    
    function offerStatus() external view returns(uint amountIn, address _masterChef, uint sushiPid) {
        OfferStruct storage offer = offers[msg.sender];
        amountIn= offer.amountIn;
        _masterChef= offer.masterChef;
        sushiPid= offer.sushiPid;
    }
    
 
    function  getOffer(address  _lpToken,  uint index) external view returns (address offer) {
        offer = allOffers[_lpToken][index];
    }

    function getOfferLength(address _lpToken) external view returns (uint length) {
        length = allOffers[_lpToken].length;
    }

    function getUserOffer(address _user, uint _index) external view returns (address) {
        return userOffers[_user][_index];
    }

    function getUserOffersLength(address _user) external view returns (uint length) {
        length = userOffers[_user].length;
    }

    function addTakerOffer(address _offer, address _user) public returns (uint) {
        require(msg.sender == _offer, 'WASABI: FORBIDDEN');
        takerOffers[_user].push(_offer);
        return takerOffers[_user].length;
    }

    function getTakerOffer(address _user, uint _index) external view returns (address) {
        return takerOffers[_user][_index];
    }

    function getTakerOffersLength(address _user) external view returns (uint length) {
        length = takerOffers[_user].length;
    }
}