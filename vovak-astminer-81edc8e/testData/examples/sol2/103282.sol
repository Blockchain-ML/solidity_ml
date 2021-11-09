 

pragma solidity ^0.5.0;

 
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
    address payable public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address payable msgSender = _msgSender();
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

     
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

 
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
         
         
         
         
         
         
        _notEntered = true;
    }

     
    modifier nonReentrant() {
         
        require(_notEntered, "ReentrancyGuard: reentrant call");

         
        _notEntered = false;

        _;

         
         
        _notEntered = true;
    }
}
 

 

 
 
 
 
 
 
 
 
 
 
 

 

 
 

 
interface IWethToken_ETH_Balancer_General_Zap_V1 {
    function deposit() external payable;

    function withdraw(uint256 amount) external;

    function withdraw(uint256 amount, address user) external;
}


interface IBFactory_ETH_Balancer_General_Zap_V1 {
    function isBPool(address b) external view returns (bool);
}


interface IBPool_Unipool_Balancer_Bridge_Zap_V1 {
    function joinswapExternAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        uint256 minPoolAmountOut
    ) external payable returns (uint256 poolAmountOut);

    function exitswapPoolAmountIn(
        address tokenOut,
        uint256 poolAmountIn,
        uint256 minAmountOut
    ) external payable returns (uint256 tokenAmountOut);
}

pragma solidity ^0.5.13;






contract ETH_Balancer_General_Zap_v1 is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    bool private stopped = false;
    uint16 public goodwill;
    address public dzgoodwillAddress;

    IBFactory_ETH_Balancer_General_Zap_V1 BalancerFactory = IBFactory_ETH_Balancer_General_Zap_V1(
        0x9424B1412450D0f8Fc2255FAf6046b98213B76Bd
    );

    address public WethTokenAddress = address(
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    );

    constructor(uint16 _goodwill, address _dzgoodwillAddress) public {
        goodwill = _goodwill;
        dzgoodwillAddress = _dzgoodwillAddress;
    }

     
    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function LetsInvest(address _toWhomToIssue, address _ToBalancerPoolAddress)
        public
        payable
        nonReentrant
        stopInEmergency
        returns (uint256 balancerPoolTokensRec)
    {
        require(
            BalancerFactory.isBPool(_ToBalancerPoolAddress),
            "Invalid Balancer Pool"
        );

        uint256 wrappedEth = _eth2Weth(msg.value);
        uint256 balancerTokens = _enter2Balancer(
            wrappedEth,
            _ToBalancerPoolAddress
        );
        uint256 goodwillPortion = SafeMath.div(
            SafeMath.mul(balancerTokens, goodwill),
            10000
        );
        require(
            IERC20(_ToBalancerPoolAddress).transfer(
                dzgoodwillAddress,
                goodwillPortion
            ),
            "Error 1 in transferring balancer tokens"
        );
        require(
            IERC20(_ToBalancerPoolAddress).transfer(
                _toWhomToIssue,
                balancerTokens.sub(goodwillPortion)
            ),
            "Error 2 in transferring balancer tokens"
        );
        balancerPoolTokensRec = balancerTokens.sub(goodwillPortion);
    }

    function _enter2Balancer(uint256 wrappedEth, address _ToBalancerPoolAddress)
        internal
        returns (uint256 poolAmountOut)
    {
        uint256 allowance = IERC20(WethTokenAddress).allowance(
            address(this),
            _ToBalancerPoolAddress
        );
        if (allowance < wrappedEth) {
            IERC20(WethTokenAddress).approve(
                _ToBalancerPoolAddress,
                uint256(-1)
            );
        }

        poolAmountOut = IBPool_Unipool_Balancer_Bridge_Zap_V1(
            _ToBalancerPoolAddress
        )
            .joinswapExternAmountIn(WethTokenAddress, wrappedEth, 1);
        require(poolAmountOut > 0, "Error in entering balancer pool");
    }

    function _eth2Weth(uint256 eth2Wrap) internal returns (uint256 wrappedEth) {
        IWethToken_ETH_Balancer_General_Zap_V1(WethTokenAddress).deposit.value(
            eth2Wrap
        )();
        wrappedEth = IERC20(WethTokenAddress).balanceOf(address(this));
        require(wrappedEth > 0, "Error in wrapping ETH");
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.transfer(_owner, qty);
    }

    function set_new_goodwill(uint16 _new_goodwill) public onlyOwner {
        require(
            _new_goodwill > 0 && _new_goodwill < 10000,
            "GoodWill Value not allowed"
        );
        goodwill = _new_goodwill;
    }

    function set_new_dzgoodwillAddress(address _new_dzgoodwillAddress)
        public
        onlyOwner
    {
        dzgoodwillAddress = _new_dzgoodwillAddress;
    }

     
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

     
    function withdraw() public onlyOwner {
        _owner.transfer(address(this).balance);
    }

     
    function destruct() public onlyOwner {
        selfdestruct(_owner);
    }

    function() external payable {}
}