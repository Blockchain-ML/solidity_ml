 
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

     
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

     
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

 
abstract contract Context {
    function _msgSender() internal virtual view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

     
    constructor() internal {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

     
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IRebaseToken is IERC20 {
    function rebase(
        uint256 epoch,
        uint256 numerator,
        uint256 denominator
    ) external returns (uint256);
}

interface IUniswapV2Pair {
    function sync() external;
}

contract UniPriceRebaseInvoker is Ownable {
    using SafeMath for uint256;

    uint256 private _epoch;
    uint256 private _startTime;
    uint256 private _interval;

    uint256 private _targetPrice;
    uint256 private _minPrice;
    uint256 private _maxPrice;

    IRebaseToken private _token;
    IERC20 private _usdt;
    IERC20 private _eth;

    IUniswapV2Pair private _tokenUsdtPair;
    IUniswapV2Pair private _tokenEthPair;
    IUniswapV2Pair private _ethUsdtPair;

    modifier onlyCanRebase() {
        uint256 epoch = currentEpoch();
        require(epoch > _epoch, "Rebase: current epoch is rebased");
        if (owner() != address(0x0)) {
            require(owner() == _msgSender(), "Rebase: caller is not the owner");
        }
        _;
    }

    constructor() public {
        _startTime = 1599004800;
        _interval = 86400;

        _targetPrice = 10**6;
        _minPrice = 96 * 10**4;
        _maxPrice = 106 * 10**4;

        _token = IRebaseToken(
            address(0x95DA1E3eECaE3771ACb05C145A131Dca45C67FD4)
        );
        _usdt = IERC20(address(0xdAC17F958D2ee523a2206206994597C13D831ec7));
        _eth = IERC20(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));

        _tokenUsdtPair = IUniswapV2Pair(
            address(0xFBC57CE413631dd910457f4476AFAC4D8590dA00)
        );

        _tokenEthPair = IUniswapV2Pair(
            address(0xdA9c8bb286EACD04eBACF97A13bEBA1D76896791)
        );

        _ethUsdtPair = IUniswapV2Pair(
            address(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852)
        );
    }

    function epoch() public view returns (uint256) {
        return _epoch;
    }

    function startTime() public view returns (uint256) {
        return _startTime;
    }

    function interval() public view returns (uint256) {
        return _interval;
    }

    function targetPrice() public view returns (uint256) {
        return _targetPrice;
    }

    function minPrice() public view returns (uint256) {
        return _minPrice;
    }

    function maxPrice() public view returns (uint256) {
        return _maxPrice;
    }

    function token() public view returns (IRebaseToken) {
        return _token;
    }

    function usdt() public view returns (IERC20) {
        return _usdt;
    }

    function eth() public view returns (IERC20) {
        return _eth;
    }

    function tokenUsdtPair() public view returns (IUniswapV2Pair) {
        return _tokenUsdtPair;
    }

    function tokenEthPair() public view returns (IUniswapV2Pair) {
        return _tokenEthPair;
    }

    function ethUsdtPair() public view returns (IUniswapV2Pair) {
        return _ethUsdtPair;
    }

    function currentEpoch() public view returns (uint256) {
        return now.sub(_startTime).div(_interval);
    }

    function ethToUsdt(uint256 amount) public view returns (uint256) {
        uint256 usdtAmount = _usdt.balanceOf(address(_ethUsdtPair));
        uint256 ethAmount = _eth.balanceOf(address(_ethUsdtPair));
        return amount.mul(usdtAmount).div(ethAmount);
    }

    function getPrice() public view returns (uint256) {
        uint256 usdtAmount = _usdt.balanceOf(address(_tokenUsdtPair));
        uint256 tokenAmount = _token.balanceOf(address(_tokenUsdtPair));

        usdtAmount = usdtAmount.add(
            ethToUsdt(_eth.balanceOf(address(_tokenEthPair)))
        );
        tokenAmount = tokenAmount.add(_token.balanceOf(address(_tokenEthPair)));
        return usdtAmount.mul(10**12).mul(_targetPrice).div(tokenAmount);
    }

    function _rebase(uint256 rebaseEepoch) private {
        uint256 price = getPrice();
        if (price >= _minPrice && price <= _maxPrice) {
            return;
        }
        uint256 denumerator = _targetPrice;
        if (price > _targetPrice) {
            denumerator = _targetPrice.sub(
                price.sub(_targetPrice).mul(10).div(100)
            );
        } else {
            denumerator = _targetPrice.add(
                _targetPrice.sub(price).mul(10).div(100)
            );
        }
        _token.rebase(rebaseEepoch, _targetPrice, denumerator);
        _tokenUsdtPair.sync();
        _tokenEthPair.sync();
    }

    function rebase() external onlyCanRebase {
        uint256 rebaseEepoch = currentEpoch();
        _rebase(rebaseEepoch);
        _epoch = rebaseEepoch;
    }
}