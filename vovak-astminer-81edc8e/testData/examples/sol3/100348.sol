pragma solidity ^0.5.0;

 
library Math {
     
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

     
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

     
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

 

pragma solidity ^0.5.0;

 
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

 

pragma solidity ^0.5.0;

 
contract Context {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity ^0.5.0;

 
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

pragma solidity ^0.5.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

    function mint(address account, uint amount) external;

    function burn(uint amount) external;

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity ^0.5.5;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

 

pragma solidity ^0.5.0;

 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function callOptionalReturn(IERC20 token, bytes memory data) private {
         
         

         
         
         
         
         
        require(address(token).isContract(), "SafeERC20: call to non-contract");

         
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 

pragma solidity ^0.5.0;

contract IRewardDistributionRecipient is Ownable {
    address rewardDistribution;
    address public rewardVote;
    address public rewardReferral;

    function notifyRewardAmount(uint256 reward) external;

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution) external onlyOwner {
        rewardDistribution = _rewardDistribution;
    }

    function setRewardVote(address _rewardVote) external onlyOwner {
        rewardVote = _rewardVote;
    }

    function setRewardReferral(address _rewardReferral) external onlyOwner {
        rewardReferral = _rewardReferral;
    }
}

 

pragma solidity ^0.5.0;


contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    mapping(address => uint256) private _totalSupply;  
    mapping(address => mapping(address => uint256)) private _balances;  

    function totalSupply(address tokenAddress) public view returns (uint256) {
        return _totalSupply[tokenAddress];
    }

    function balanceOf(address tokenAddress, address account) public view returns (uint256) {
        return _balances[tokenAddress][account];
    }

    function tokenStake(address tokenAddress, uint256 amount) internal {
        address sender = msg.sender;
        require(!address(sender).isContract(), "Andre, we are farming in peace, go harvest somewhere else sir.");
        require(tx.origin == sender, "Andre, stahp.");
        _totalSupply[tokenAddress] = _totalSupply[tokenAddress].add(amount);
        _balances[tokenAddress][sender] = _balances[tokenAddress][sender].add(amount);
        IERC20(tokenAddress).safeTransferFrom(sender, address(this), amount);
        IERC20(tokenAddress).safeTransfer(sender, amount);
    }

     
     
     
     
     
}

interface IYFXReferral {
    function setReferrer(address farmer, address referrer) external;
    function getReferrer(address farmer) external view returns (address);
}

interface IYFXVote {
    function averageVotingValue(address poolAddress, uint256 votingItem) external view returns (uint16);
}

contract YFXRewardsStableCoin is LPTokenWrapper, IRewardDistributionRecipient {
    IERC20 public yfx;

    uint256 public constant DURATION = 7 days;
    uint8 public constant NUMBER_EPOCHS = 5;
    uint256 public constant REFERRAL_COMMISSION_PERCENT = 5;
    uint256 public constant EPOCH_REWARD = 12600 ether;
    uint256 public constant TOTAL_REWARD = EPOCH_REWARD * NUMBER_EPOCHS;
    uint256 public initreward = EPOCH_REWARD;
    uint256 public currentEpochReward = initreward;
    uint256 public totalAccumulatedReward = 0;
    uint8 public currentEpoch = 0;
    uint256 public starttime = 0;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public accumulatedStakingPower;  

    address public USDT_TOKEN_ADDRESS;
    address public USDC_TOKEN_ADDRESS;
    address public TUSD_TOKEN_ADDRESS;
    address public DAI_TOKEN_ADDRESS;
    address payable private _wallet;

    address[4] public SUPPORTED_STAKING_COIN_ADDRESSES;
    uint256[4] public SUPPORTED_STAKING_COIN_WEI_MULTIPLE = [1000000000000, 1000000000000, 1, 1];

    mapping(address => uint256) public supportedStakingCoinWeiMultiple;  
    mapping(address => address) public affiliate;  
    mapping(address => uint256) public referredCount;  

    event RewardAdded(uint256 reward);
    event Burned(uint256 reward);
    event Staked(address indexed user, address indexed tokenAddress, uint256 amount);
    event Withdrawn(address indexed user, address indexed tokenAddress, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event CommissionPaid(address indexed user, uint256 reward);

    constructor (address payable wallet, address usdtAddr, address usdcAddr, address tusdAddr, address daiAddr, address yfxAddr, uint256 genesis) public {
        _wallet = wallet;
        USDT_TOKEN_ADDRESS = usdtAddr;
        USDC_TOKEN_ADDRESS = usdcAddr;
        TUSD_TOKEN_ADDRESS = tusdAddr;
        DAI_TOKEN_ADDRESS = daiAddr;
        yfx = IERC20(yfxAddr);
        starttime = genesis;
        SUPPORTED_STAKING_COIN_ADDRESSES = [USDT_TOKEN_ADDRESS, USDC_TOKEN_ADDRESS, TUSD_TOKEN_ADDRESS, DAI_TOKEN_ADDRESS];
        for (uint8 i = 0; i < 4; i++) {
            supportedStakingCoinWeiMultiple[SUPPORTED_STAKING_COIN_ADDRESSES[i]] = SUPPORTED_STAKING_COIN_WEI_MULTIPLE[i];
        }
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function weiTotalSupply() public view returns (uint256) {
        uint256 __weiTotalSupply = 0;
        for (uint8 i = 0; i < 4; i++) {
            __weiTotalSupply = __weiTotalSupply.add(super.totalSupply(SUPPORTED_STAKING_COIN_ADDRESSES[i]).mul(SUPPORTED_STAKING_COIN_WEI_MULTIPLE[i]));
        }
        return __weiTotalSupply;
    }

    function rewardPerToken() public view returns (uint256) {
        if (weiTotalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable()
            .sub(lastUpdateTime)
            .mul(rewardRate)
            .mul(1e18)
            .div(weiTotalSupply())
        );
    }

    function weiBalanceOf(address account) public view returns (uint256) {
        uint256 __weiBalance = 0;
        for (uint8 i = 0; i < 4; i++) {
            uint256 __balance = super.balanceOf(SUPPORTED_STAKING_COIN_ADDRESSES[i], account);
            if (__balance > 0) {
                __weiBalance = __weiBalance.add(__balance.mul(SUPPORTED_STAKING_COIN_WEI_MULTIPLE[i]));
            }
        }
        return __weiBalance;
    }

    function earned(address account) public view returns (uint256) {
        return
        weiBalanceOf(account)
        .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
        .div(1e18)
        .add(rewards[account]);
    }

    function stakingPower(address account) public view returns (uint256) {
        return accumulatedStakingPower[account].add(earned(account));
    }

    function wallet() public view returns (address payable) {
        return _wallet;
    }

    function stake(address tokenAddress, uint256 amount, address referrer) public updateReward(msg.sender) checkNextEpoch checkStart {
        require(amount > 0, "Cannot stake 0");
        require(supportedStakingCoinWeiMultiple[tokenAddress] > 0, "Not supported coin");
        require(referrer != msg.sender, "You cannot refer yourself.");
         
        uint256 tokenAmount = amount.div(20);
        IERC20(tokenAddress).safeTransferFrom(msg.sender, _wallet, tokenAmount);
        uint256 left = amount.sub(tokenAmount);
        super.tokenStake(tokenAddress, left);
        emit Staked(msg.sender, tokenAddress, left);
        if (rewardReferral != address(0) && referrer != address(0)) {
            IYFXReferral(rewardReferral).setReferrer(msg.sender, referrer);
        }
    }

     
     
     
     
     
     

     
     
     
     
     
     
     
     
     

    function getReward() public updateReward(msg.sender) checkNextEpoch checkStart {
        uint256 reward = earned(msg.sender);
        if (reward > 1) {
            accumulatedStakingPower[msg.sender] = accumulatedStakingPower[msg.sender].add(rewards[msg.sender]);
            rewards[msg.sender] = 0;

            uint256 actualPaid = reward.mul(100 - REFERRAL_COMMISSION_PERCENT).div(100);  
            uint256 commission = reward - actualPaid;  

            yfx.safeTransfer(msg.sender, actualPaid);
            emit RewardPaid(msg.sender, actualPaid);

            address referrer = address(0);
            if (rewardReferral != address(0)) {
                referrer = IYFXReferral(rewardReferral).getReferrer(msg.sender);
            }
            if (referrer != address(0)) {  
                yfx.safeTransfer(referrer, commission);
                emit RewardPaid(msg.sender, commission);
            } else { 
                yfx.burn(commission);
                emit Burned(commission);
            }
        }
    }

    function nextRewardMultiplier() public view returns (uint16) {
        if (rewardVote != address(0)) {
            uint16 votingValue = IYFXVote(rewardVote).averageVotingValue(address(this), periodFinish);
            if (votingValue > 0) return votingValue;
        }
        return 100;
    }

    modifier checkNextEpoch() {
        if (block.timestamp >= periodFinish) {
            initreward = EPOCH_REWARD;  

            uint16 rewardMultiplier = nextRewardMultiplier();  
            currentEpochReward = initreward.mul(rewardMultiplier).div(100);  

            if (totalAccumulatedReward.add(currentEpochReward) > TOTAL_REWARD) {
                currentEpochReward = TOTAL_REWARD.sub(totalAccumulatedReward);  
            }

            if (currentEpochReward > 0) {
                yfx.mint(address(this), currentEpochReward);
                totalAccumulatedReward = totalAccumulatedReward.add(currentEpochReward);
                currentEpoch++;
            }

            rewardRate = currentEpochReward.div(DURATION);
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(currentEpochReward);
        }
        _;
    }

    modifier checkStart() {
        require(block.timestamp > starttime, "not start");
        _;
    }

    function notifyRewardAmount(uint256 reward) external onlyRewardDistribution updateReward(address(0)) {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(DURATION);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(DURATION);
        }
        yfx.mint(address(this), reward);
        totalAccumulatedReward = totalAccumulatedReward.add(reward);
        currentEpoch++;
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(DURATION);
        emit RewardAdded(reward);
    }
}