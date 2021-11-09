 

 

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

 



pragma solidity ^0.6.0;

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 


pragma solidity ^0.6.0;

 
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

 



pragma solidity ^0.6.0;

 
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

 

pragma solidity 0.6.12;




contract CrowdFund is Ownable {
    using SafeMath for uint256;
    IERC20 public yfethToken;
    mapping(address => bool) public isClaimed;
    mapping(address => uint256) public ethContributed;
    mapping(address => uint256) public refferer_earnings;

    address constant ETH_TOKEN_PLACHOLDER = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256 public immutable startTime;
    uint256 public immutable endTime;
    uint256 public constant referralRewardAmount = 500 finney;  
    uint256 public constant claimRewardAmount = 3 ether;
    uint256 public yfePerWei = 100;  
    uint256 public totalEthContributed;

    uint256[] public canClaimIfHasThisMuchTokens;
    address[] public canClaimIfHasTokens;

    event TokenWithdrawn(
        address indexed token,
        uint256 indexed amount,
        address indexed dest
    );
    event EthContributed(
        address indexed contributor,
        uint256 indexed amount,
        uint256 indexed yfeReceived
    );

    constructor(
        IERC20 _yfethToken,
        uint256 _startTime,
        uint256 _endTime,
        address[] memory _canClaimIfHasTokens,
        uint256[] memory _canClaimIfHasThisMuchTokens
    ) public {
        _updateClaimCondtions(
            _canClaimIfHasTokens,
            _canClaimIfHasThisMuchTokens
        );
        yfethToken = _yfethToken;
        endTime = _endTime;
        startTime = _startTime;
    }

    function claim() external {
        if (
            !(isClaimed[msg.sender] ||
                now < startTime ||
                yfePerWei == 0 ||
                now >= endTime)
        ) {
            if (canClaim(msg.sender)) {
                require(yfethToken.transfer(msg.sender, claimRewardAmount));
                isClaimed[msg.sender] = true;
            }
        }
    }

    function canClaim(address _who) public view returns (bool) {
        for (uint8 i = 0; i < canClaimIfHasTokens.length; i++) {
            if (
                IERC20(canClaimIfHasTokens[i]).balanceOf(_who) >=
                canClaimIfHasThisMuchTokens[i]
            ) {
                return true;
            }
        }
        return false;
    }

    function _updateClaimCondtions(
        address[] memory _canClaimIfHasTokens,
        uint256[] memory _canClaimIfHasThisMuchTokens
    ) internal {
        require(
            _canClaimIfHasTokens.length == _canClaimIfHasThisMuchTokens.length,
            "CrowdFund: Invalid Input"
        );
        canClaimIfHasTokens = _canClaimIfHasTokens;
        canClaimIfHasThisMuchTokens = _canClaimIfHasThisMuchTokens;
    }

    function updateClaimCondtions(
        address[] memory _canClaimIfHasTokens,
        uint256[] memory _canClaimIfHasThisMuchTokens
    ) public onlyOwner {
        _updateClaimCondtions(
            _canClaimIfHasTokens,
            _canClaimIfHasThisMuchTokens
        );
    }

    function contribute(address _referrer) external payable {
         
        if (now < startTime || yfePerWei == 0 || now >= endTime) {
            msg.sender.transfer(msg.value);
        } else {
            totalEthContributed = totalEthContributed.add(msg.value);
            ethContributed[msg.sender] = ethContributed[msg.sender].add(
                msg.value
            );

            require(ethContributed[msg.sender] <= 25 ether, "Limit reached");

            uint256 yfeToTransfer = yfePerWei.mul(msg.value);

             
             
            emit EthContributed(msg.sender, msg.value, yfeToTransfer);
            require(yfethToken.transfer(msg.sender, yfeToTransfer));
             
            if (
                _referrer != address(0) &&
                refferer_earnings[_referrer] <= 25 ether &&
                _referrer != msg.sender
            ) {
                refferer_earnings[_referrer] = refferer_earnings[_referrer].add(
                    referralRewardAmount
                );
                require(yfethToken.transfer(_referrer, referralRewardAmount));
            }

            if (totalEthContributed > 550 ether && yfePerWei == 50) {
                 
                yfePerWei = 0;
            } else if (totalEthContributed > 250 ether && yfePerWei == 75) {
                 
                yfePerWei = 50;
            } else if (totalEthContributed > 85 ether && yfePerWei == 100) {
                 
                yfePerWei = 75;
            }
        }
    }

     
    function withdrawToken(address _tokenAddress, address _dest)
        external
        onlyOwner
    {
        uint256 _balance = IERC20(_tokenAddress).balanceOf(address(this));
        emit TokenWithdrawn(_tokenAddress, _balance, _dest);
        require(IERC20(_tokenAddress).transfer(_dest, _balance));
    }

     
    function withdrawEther(address payable _dest) external onlyOwner {
        uint256 _balance = address(this).balance;
        emit TokenWithdrawn(ETH_TOKEN_PLACHOLDER, _balance, _dest);
        _dest.transfer(_balance);
    }
}