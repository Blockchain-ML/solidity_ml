 
pragma solidity >=0.4.22 <0.8.0;

 



 
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

 




contract InitialTokenLocker {
    using SafeMath for uint256;

    IERC20 private _token;
    address private _beneficiary;

    uint256 private _releasedEpoch;
    uint256 private _totalEpoch;
    uint256 private _startTime;
    uint256 private _interval;

    constructor() public {
        _token = IERC20(address(0x95DA1E3eECaE3771ACb05C145A131Dca45C67FD4));
        _beneficiary = address(0x2864d65866feFD5760929a095b5665f09d04E182);
        _startTime = 1599004800;
        _interval = 86400;
        _totalEpoch = 30;
        _releasedEpoch = 1;
    }

    function token() public view returns (IERC20) {
        return _token;
    }

    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    function releasedEpoch() public view returns (uint256) {
        return _releasedEpoch;
    }

    function totalEpoch() public view returns (uint256) {
        return _totalEpoch;
    }

    function startTime() public view returns (uint256) {
        return _startTime;
    }

    function interval() public view returns (uint256) {
        return _interval;
    }

    function currentEpoch() public view returns (uint256) {
        return now.sub(_startTime).div(_interval);
    }

    function canReleaseAmount(uint256 epoch) public view returns (uint256) {
        if (epoch <= _releasedEpoch) {
            return 0;
        }

        uint256 remainingAmount = _token.balanceOf(address(this));
        if (epoch > _totalEpoch) {
            return remainingAmount;
        }

        uint256 notReleasedEpoch = _totalEpoch.sub(_releasedEpoch);
        uint256 needReleasedEpoch = epoch.sub(_releasedEpoch);
        return remainingAmount.mul(needReleasedEpoch).div(notReleasedEpoch);
    }

    function release() external returns (uint256) {
        uint256 epoch = currentEpoch();
        uint256 releaseAmount = canReleaseAmount(epoch);
        if (releaseAmount > 0) {
            _token.transfer(_beneficiary, releaseAmount);
            _releasedEpoch = epoch;
        }
        return releaseAmount;
    }
}