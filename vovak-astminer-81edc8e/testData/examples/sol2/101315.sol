pragma solidity ^0.6.0;
 
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
 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
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
 
contract Pausable is Context {
     
    event Paused(address account);

     
    event Unpaused(address account);

    bool private _paused;

     
    constructor () internal {
        _paused = false;
    }

     
    function paused() public view returns (bool) {
        return _paused;
    }

     
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

     
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

     
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

     
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract DaoStakeContract is Ownable, Pausable {
     
    using SafeMath for uint256;

    uint256 ONE_DAY;
    uint256 public stakeDays;
    uint256 public maxStakedQuantity;
    address public phnxContractAddress;
    uint256 public ratio;
    uint256 public totalStakedTokens;

    mapping(address => uint256) public stakerBalance;
    mapping(uint256 => StakerData) public stakerData;

    struct StakerData {
        uint256 altQuantity;
        uint256 initiationTimestamp;
        uint256 durationTimestamp;
        uint256 rewardAmount;
        address staker;
    }
    event StakeCompleted(
        uint256 altQuantity,
        uint256 initiationTimestamp,
        uint256 durationTimestamp,
        uint256 rewardAmount,
        address staker,
        address phnxContractAddress,
        address portalAddress
    );

    event Unstake(
        address staker,
        address stakedToken,
        address portalAddress,
        uint256 altQuantity,
        uint256 durationTimestamp
    );  
    event BaseInterestUpdated(uint256 _newRate, uint256 _oldRate);

    constructor() public {
        ratio = 821917808219178;
        phnxContractAddress = 0x38A2fDc11f526Ddd5a607C1F251C065f40fBF2f7;
        maxStakedQuantity = 10000000000000000000000;
        stakeDays = 365;
        ONE_DAY = 60;
    }

     
    function stakeALT(uint256 _altQuantity, uint256 _days)
        public
        whenNotPaused
        returns (uint256 rewardAmount)
    {
        require(_days <= stakeDays && _days > 0, "Invalid Days");  
        require(
            _altQuantity <= maxStakedQuantity && _altQuantity > 0,
            "Invalid PHNX quantity"
        );  

        IERC20(phnxContractAddress).transferFrom(
            msg.sender,
            address(this),
            _altQuantity
        );

        rewardAmount = _calculateReward(_altQuantity, ratio, _days);

        uint256 _timestamp = block.timestamp;

        if (stakerData[_timestamp].staker != address(0)) {
            _timestamp = _timestamp.add(1);
        }

        stakerData[_timestamp] = StakerData(
            _altQuantity,
            _timestamp,
            _days.mul(ONE_DAY),
            rewardAmount,
            msg.sender
        );

        stakerBalance[msg.sender] = stakerBalance[msg.sender].add(_altQuantity);

        totalStakedTokens = totalStakedTokens.add(_altQuantity);

        IERC20(phnxContractAddress).transfer(msg.sender, rewardAmount);

        emit StakeCompleted(
            _altQuantity,
            _timestamp,
            _days.mul(ONE_DAY),
            rewardAmount,
            msg.sender,
            phnxContractAddress,
            address(this)
        );
    }

     
    function unstakeALT(uint256[] calldata _expiredTimestamps, uint256 _amount)
        external
        whenNotPaused
        returns (uint256)
    {
        require(_amount > 0, "Amount should be greater than 0");
        uint256 withdrawAmount = 0;
        uint256 burnAmount = 0;
        for (uint256 i = 0; i < _expiredTimestamps.length; i = i.add(1)) {
            require(
                stakerData[_expiredTimestamps[i]].durationTimestamp != 0,
                "Nothing staked"
            );
            if (
                _expiredTimestamps[i].add(
                    stakerData[_expiredTimestamps[i]].durationTimestamp  
                ) >= block.timestamp
            ) {
                uint256 _remainingDays = (
                    stakerData[_expiredTimestamps[i]]
                        .durationTimestamp
                        .add(_expiredTimestamps[i])
                        .sub(block.timestamp)
                )
                    .div(ONE_DAY);
                uint256 _totalDays = stakerData[_expiredTimestamps[i]]
                    .durationTimestamp
                    .div(ONE_DAY);
                if (_amount >= stakerData[_expiredTimestamps[i]].altQuantity) {
                    uint256 stakeBurn = _calculateBurn(
                        stakerData[_expiredTimestamps[i]].altQuantity,
                        _remainingDays,
                        _totalDays
                    );
                    burnAmount = burnAmount.add(stakeBurn);
                    withdrawAmount = withdrawAmount.add(
                        stakerData[_expiredTimestamps[i]].altQuantity.sub(
                            stakeBurn
                        )
                    );
                    _amount = _amount.sub(
                        stakerData[_expiredTimestamps[i]].altQuantity
                    );
                    emit Unstake(
                        msg.sender,
                        phnxContractAddress,
                        address(this),
                        stakerData[_expiredTimestamps[i]].altQuantity,
                        _expiredTimestamps[i]
                    );
                    stakerData[_expiredTimestamps[i]].altQuantity = 0;
                } else if (
                    (_amount < stakerData[_expiredTimestamps[i]].altQuantity) &&
                    _amount > 0  
                ) {
                    stakerData[_expiredTimestamps[i]]
                        .altQuantity = stakerData[_expiredTimestamps[i]]
                        .altQuantity
                        .sub(_amount);
                    uint256 stakeBurn = _calculateBurn(
                        _amount,
                        _remainingDays,
                        _totalDays
                    );
                    burnAmount = burnAmount.add(stakeBurn);
                    withdrawAmount = withdrawAmount.add(_amount.sub(stakeBurn));
                    emit Unstake(
                        msg.sender,
                        phnxContractAddress,
                        address(this),
                        _amount,
                        _expiredTimestamps[i]
                    );
                    _amount = 0;
                }
            } else {
                if (_amount >= stakerData[_expiredTimestamps[i]].altQuantity) {
                    _amount = _amount.sub(
                        stakerData[_expiredTimestamps[i]].altQuantity
                    );
                    withdrawAmount = withdrawAmount.add(
                        stakerData[_expiredTimestamps[i]].altQuantity
                    );
                    emit Unstake(
                        msg.sender,
                        phnxContractAddress,
                        address(this),
                        stakerData[_expiredTimestamps[i]].altQuantity,
                        _expiredTimestamps[i]
                    );
                    stakerData[_expiredTimestamps[i]].altQuantity = 0;
                } else if (
                    (_amount < stakerData[_expiredTimestamps[i]].altQuantity) &&
                    _amount > 0
                ) {
                    stakerData[_expiredTimestamps[i]]
                        .altQuantity = stakerData[_expiredTimestamps[i]]
                        .altQuantity
                        .sub(_amount);
                    withdrawAmount = withdrawAmount.add(_amount);
                    emit Unstake(
                        msg.sender,
                        phnxContractAddress,
                        address(this),
                        _amount,
                        _expiredTimestamps[i]
                    );
                    break;
                }
            }
        }
        require(withdrawAmount != 0, "Not Transferred");

        if (burnAmount > 0) {
            IERC20(phnxContractAddress).transfer(
                0x0000000000000000000000000000000000000001,
                burnAmount
            );
        }

        stakerBalance[msg.sender] = stakerBalance[msg.sender].sub(
            withdrawAmount
        );

        totalStakedTokens = totalStakedTokens.sub(withdrawAmount);

        IERC20(phnxContractAddress).transfer(msg.sender, withdrawAmount);
        return withdrawAmount;
    }

     
    function _calculateReward(
        uint256 _altQuantity,
        uint256 _ratio,
        uint256 _days
    ) internal pure returns (uint256 rewardAmount) {
        rewardAmount = (_altQuantity.mul(_ratio).mul(_days)).div(
            1000000000000000000
        );
    }

     
    function _calculateBurn(
        uint256 _amount,
        uint256 _remainingDays,
        uint256 _totalDays
    ) internal pure returns (uint256 burnAmount) {
        burnAmount = ((_amount * _remainingDays) / _totalDays);
    }

     
    function updateRatio(uint256 _rate) public onlyOwner whenNotPaused {
        ratio = _rate;
    }

    function updateTime(uint256 _time) public onlyOwner whenNotPaused {
        ONE_DAY = _time;
    }

    function updateQuantity(uint256 _quantity) public onlyOwner whenNotPaused {
        maxStakedQuantity = _quantity;
    }

     
    function updatestakeDays(uint256 _stakeDays) public onlyOwner {
        stakeDays = _stakeDays;
    }

     
    function withdrawTokens() public onlyOwner {
        IERC20(phnxContractAddress).transfer(
            owner(),
            IERC20(phnxContractAddress).balanceOf(address(this))
        );
        pause();
    }

    function getTotalrewardTokens() external view returns(uint256){
        return IERC20(phnxContractAddress).balanceOf(address(this)).sub(totalStakedTokens);
    }

     
    function setPheonixContractAddress(address _address) public onlyOwner {
        phnxContractAddress = _address;
    }

     
    function pause() public onlyOwner {
        _pause();
    }

     
    function unPause() public onlyOwner {
        _unpause();
    }
}