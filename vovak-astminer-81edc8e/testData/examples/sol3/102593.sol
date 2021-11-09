pragma solidity ^0.6.12;

 
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

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
             
            if (returndata.length > 0) {
                 

                 
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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

 

library SafeDecimal {
    using SafeMath for uint;

    uint8 public constant decimals = 18;
    uint public constant UNIT = 10 ** uint(decimals);

    function unit() external pure returns (uint) {
        return UNIT;
    }

    function multiply(uint x, uint y) internal pure returns (uint) {
        return x.mul(y).div(UNIT);
    }

     
    function power(uint x, uint n) internal pure returns (uint) {
        uint result = UNIT;
        while (n > 0) {
            if (n % 2 != 0) {
                result = multiply(result, x);
            }
            x = multiply(x, x);
            n /= 2;
        }
        return result;
    }
}

contract CritSupplySchedule is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;
    using SafeDecimal for uint;
    uint256[157] public weeklySupplies = [
     
    0,
     
    358025, 250600, 175420, 122794, 112970, 103932, 95618, 87968, 80931, 74456, 68500, 63020, 57978,
    53340, 49073, 45147, 41535, 38212, 35155, 32343, 29755, 27375, 25185, 23170, 21316, 19611,
    18042, 16599, 15271, 14049, 12925, 11891, 10940, 10064, 9259, 8518, 7837, 7210, 6633,
    6102, 5614, 5165, 4752, 4372, 4022, 3700, 3404, 3132, 2881, 2651, 2438, 2244,
     
    2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244,
    2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244,
    2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244,
    2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244,
     
    1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734,
    1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734,
    1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734,
    1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734
    ];
    uint public constant MINT_PERIOD_DURATION = 1 weeks;
    uint public constant SUPPLY_START_DATE = 1601258400;  

    uint public constant MAX_OPERATION_SHARES = 20e16;

    address public rewardsToken;
    uint public lastMintEvent;
    uint public weekCounter;
    uint public operationShares = 2e16;  

    event OperationSharesUpdated(uint newShares);
    event SupplyMinted(uint supplyMinted, uint numberOfWeeksIssued, uint lastMintEvent, uint timestamp);

    modifier onlyRewardsToken() {
        require(msg.sender == address(rewardsToken), "onlyRewardsToken");
        _;
    }

    constructor(address _rewardsToken, uint _lastMintEvent, uint _currentWeek) public {
        rewardsToken = _rewardsToken;
        lastMintEvent = _lastMintEvent;
        weekCounter = _currentWeek;
    }

    function mintableSupply() external view returns (uint) {
        uint totalAmount;
        if (!isMintable()) {
            return 0;
        }

        uint currentWeek = weekCounter;
        uint remainingWeeksToMint = weeksSinceLastIssuance();
        while (remainingWeeksToMint > 0) {
            currentWeek++;
            remainingWeeksToMint--;
            if (currentWeek >= weeklySupplies.length) {
                break;
            }
            totalAmount = totalAmount.add(weeklySupplies[currentWeek]);
        }
        return totalAmount.mul(1e18);
    }

    function weeksSinceLastIssuance() public view returns (uint) {
        uint timeDiff = lastMintEvent > 0 ? now.sub(lastMintEvent) : now.sub(SUPPLY_START_DATE);
        return timeDiff.div(MINT_PERIOD_DURATION);
    }

    function isMintable() public view returns (bool) {
        if (now - lastMintEvent > MINT_PERIOD_DURATION && weekCounter < weeklySupplies.length) {
            return true;
        }
        return false;
    }

    function recordMintEvent(uint _supplyMinted) external onlyRewardsToken returns (bool) {
        uint numberOfWeeksIssued = weeksSinceLastIssuance();
        weekCounter = weekCounter.add(numberOfWeeksIssued);
        lastMintEvent = SUPPLY_START_DATE.add(weekCounter.mul(MINT_PERIOD_DURATION));

        emit SupplyMinted(_supplyMinted, numberOfWeeksIssued, lastMintEvent, now);
        return true;
    }

    function setOperationShares(uint _shares) external onlyOwner {
        require(_shares <= MAX_OPERATION_SHARES, "shares");
        operationShares = _shares;
        emit OperationSharesUpdated(_shares);
    }

    function rewardOfOperation(uint _supplyMinted) public view returns (uint) {
        return _supplyMinted.mul(operationShares).div(SafeDecimal.unit());
    }

    function currentWeekSupply() external view returns(uint) {
        if (weekCounter < weeklySupplies.length) {
            return weeklySupplies[weekCounter];
        }
        return 0;
    }
}