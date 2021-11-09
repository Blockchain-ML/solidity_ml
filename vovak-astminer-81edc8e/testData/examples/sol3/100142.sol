 

 
 

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

 

pragma solidity >=0.6.6;

 
 
 

 
contract WasabiToken is IERC2917, UpgradableProduct, UpgradableGovernance {
    using SafeMath for uint;

    uint public mintCumulation;
    uint public maxMintCumulation;

    uint private unlocked = 1;
    uint public wasabiPerBlock;

    modifier lock() {
        require(unlocked == 1, 'Locked');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    uint public nounce;

    function incNounce() public {
        nounce ++;
    }

    struct UserInfo {
        uint amount;      
        uint rewardDebt;  
    }

    mapping(address => UserInfo) public users;

     
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

        wasabiPerBlock = _interestsRate;

        maxMintCumulation = _maxMintCumulation;
    }

     
     
     
     
    function changeInterestsPerBlock(uint value) external override requireGovernor returns (bool) {
        uint old = wasabiPerBlock;
        require(value != old, 'AMOUNT_PER_BLOCK_NO_CHANGE');

        wasabiPerBlock = value;

        emit InterestsPerBlockChanged(old, value);
        return true;
    }

    uint lastRewardBlock;
    uint totalProductivity;
    uint accAmountPerShare;

         
    function update() internal 
    {
        if (block.number <= lastRewardBlock) {
            return;
        }

        if (totalProductivity == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number.sub(lastRewardBlock);
        uint256 reward = multiplier.mul(wasabiPerBlock);
        balanceOf[address(this)] = balanceOf[address(this)].add(reward);
        totalSupply = totalSupply.add(reward);

        accAmountPerShare = accAmountPerShare.add(reward.mul(1e12).div(totalProductivity));
        lastRewardBlock = block.number;
    }

     
     
     
     
    function increaseProductivity(address user, uint value) external override requireImpl returns (uint) {
        if(mintCumulation >= maxMintCumulation)
            return 0;

        require(value > 0, 'PRODUCTIVITY_VALUE_MUST_BE_GREATER_THAN_ZERO');

        UserInfo storage userInfo = users[user];
        update();
        if (userInfo.amount > 0) {
            uint pending = userInfo.amount.mul(accAmountPerShare).div(1e12).sub(userInfo.rewardDebt);
            _transfer(address(this), user, pending);
            mintCumulation = mintCumulation.add(pending);
        }

        totalProductivity = totalProductivity.add(value);

        userInfo.amount = userInfo.amount.add(value);
        userInfo.rewardDebt = userInfo.amount.mul(accAmountPerShare).div(1e12);
        emit ProductivityIncreased(user, value);
        return userInfo.amount;
    }

     
     
     
    function decreaseProductivity(address user, uint value) external override requireImpl returns (uint) {
        if(mintCumulation >= maxMintCumulation)
            return 0;

        require(value > 0, 'INSUFFICIENT_PRODUCTIVITY');
        
        UserInfo storage userInfo = users[user];
        require(userInfo.amount >= value, "WASABI: FORBIDDEN");
        update();
        uint pending = userInfo.amount.mul(accAmountPerShare).div(1e12).sub(userInfo.rewardDebt);
        _transfer(address(this), user, pending);
        mintCumulation = mintCumulation.add(pending);
        userInfo.amount = userInfo.amount.sub(value);
        userInfo.rewardDebt = userInfo.amount.mul(accAmountPerShare).div(1e12);
        totalProductivity = totalProductivity.sub(value);

        emit ProductivityDecreased(user, value);
        return pending;
    }

    function take() external override view returns (uint) {
        if(mintCumulation >= maxMintCumulation)
            return 0;

        UserInfo storage userInfo = users[msg.sender];
        uint _accAmountPerShare = accAmountPerShare;
         
        if (block.number > lastRewardBlock && totalProductivity != 0) {
            uint multiplier = block.number.sub(lastRewardBlock);
            uint reward = multiplier.mul(wasabiPerBlock);
            _accAmountPerShare = _accAmountPerShare.add(reward.mul(1e12).div(totalProductivity));
        }
        return userInfo.amount.mul(_accAmountPerShare).div(1e12).sub(userInfo.rewardDebt);
    }

    function takeWithAddress(address user) external view returns (uint) {
        if(mintCumulation >= maxMintCumulation)
            return 0;

        UserInfo storage userInfo = users[user];
        uint _accAmountPerShare = accAmountPerShare;
         
        if (block.number > lastRewardBlock && totalProductivity != 0) {
            uint multiplier = block.number.sub(lastRewardBlock);
            uint reward = multiplier.mul(wasabiPerBlock);
            _accAmountPerShare = _accAmountPerShare.add(reward.mul(1e12).div(totalProductivity));
        }
        return userInfo.amount.mul(_accAmountPerShare).div(1e12).sub(userInfo.rewardDebt);
    }

     
    function takeWithBlock() external override view returns (uint, uint) {
        if(mintCumulation >= maxMintCumulation)
            return (0, block.number);

        UserInfo storage userInfo = users[msg.sender];
        uint _accAmountPerShare = accAmountPerShare;
         
        if (block.number > lastRewardBlock && totalProductivity != 0) {
            uint multiplier = block.number.sub(lastRewardBlock);
            uint reward = multiplier.mul(wasabiPerBlock);
            _accAmountPerShare = _accAmountPerShare.add(reward.mul(1e12).div(totalProductivity));
        }
        return (userInfo.amount.mul(_accAmountPerShare).div(1e12).sub(userInfo.rewardDebt), block.number);
    }


     
     
     
    function mint(address to) external override lock returns (uint) {
        require(to != address(0), '');
        return 0;
    }

     
    function getProductivity(address user) external override view returns (uint, uint) {
        return (users[user].amount, totalProductivity);
    }

     
    function interestsPerBlock() external override view returns (uint) {
        return accAmountPerShare;
    }
}