 

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



 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


contract IOneSplitConsts {
     
    uint256 public constant FLAG_DISABLE_UNISWAP = 0x01;
    uint256 public constant FLAG_DISABLE_KYBER = 0x02;
    uint256 public constant FLAG_ENABLE_KYBER_UNISWAP_RESERVE = 0x100000000;  
    uint256 public constant FLAG_ENABLE_KYBER_OASIS_RESERVE = 0x200000000;  
    uint256 public constant FLAG_ENABLE_KYBER_BANCOR_RESERVE = 0x400000000;  
    uint256 public constant FLAG_DISABLE_BANCOR = 0x04;
    uint256 public constant FLAG_DISABLE_OASIS = 0x08;
    uint256 public constant FLAG_DISABLE_COMPOUND = 0x10;
    uint256 public constant FLAG_DISABLE_FULCRUM = 0x20;
    uint256 public constant FLAG_DISABLE_CHAI = 0x40;
    uint256 public constant FLAG_DISABLE_AAVE = 0x80;
    uint256 public constant FLAG_DISABLE_SMART_TOKEN = 0x100;
    uint256 public constant FLAG_ENABLE_MULTI_PATH_ETH = 0x200;  
    uint256 public constant FLAG_DISABLE_BDAI = 0x400;
    uint256 public constant FLAG_DISABLE_IEARN = 0x800;
    uint256 public constant FLAG_DISABLE_CURVE_COMPOUND = 0x1000;
    uint256 public constant FLAG_DISABLE_CURVE_USDT = 0x2000;
    uint256 public constant FLAG_DISABLE_CURVE_Y = 0x4000;
    uint256 public constant FLAG_DISABLE_CURVE_BINANCE = 0x8000;
    uint256 public constant FLAG_ENABLE_MULTI_PATH_DAI = 0x10000;  
    uint256 public constant FLAG_ENABLE_MULTI_PATH_USDC = 0x20000;  
    uint256 public constant FLAG_DISABLE_CURVE_SYNTHETIX = 0x40000;
    uint256 public constant FLAG_DISABLE_WETH = 0x80000;
    uint256 public constant FLAG_ENABLE_UNISWAP_COMPOUND = 0x100000;  
    uint256 public constant FLAG_ENABLE_UNISWAP_CHAI = 0x200000;  
    uint256 public constant FLAG_ENABLE_UNISWAP_AAVE = 0x400000;  
    uint256 public constant FLAG_DISABLE_IDLE = 0x800000;
    uint256 public constant FLAG_DISABLE_MOONISWAP = 0x1000000;
    uint256 public constant FLAG_DISABLE_UNISWAP_V2_ALL = 0x1E000000;
    uint256 public constant FLAG_DISABLE_UNISWAP_V2 = 0x2000000;
    uint256 public constant FLAG_DISABLE_UNISWAP_V2_ETH = 0x4000000;
    uint256 public constant FLAG_DISABLE_UNISWAP_V2_DAI = 0x8000000;
    uint256 public constant FLAG_DISABLE_UNISWAP_V2_USDC = 0x10000000;
    uint256 public constant FLAG_DISABLE_ALL_SPLIT_SOURCES = 0x20000000;
    uint256 public constant FLAG_DISABLE_ALL_WRAP_SOURCES = 0x40000000;
    uint256 public constant FLAG_DISABLE_CURVE_PAX = 0x80000000;
    uint256 public constant FLAG_DISABLE_CURVE_RENBTC = 0x100000000;
    uint256 public constant FLAG_DISABLE_CURVE_TBTC = 0x200000000;
    uint256 public constant FLAG_ENABLE_MULTI_PATH_USDT = 0x400000000;  
    uint256 public constant FLAG_ENABLE_MULTI_PATH_WBTC = 0x800000000;  
    uint256 public constant FLAG_ENABLE_MULTI_PATH_TBTC = 0x1000000000;  
    uint256 public constant FLAG_ENABLE_MULTI_PATH_RENBTC = 0x2000000000;  
    uint256 public constant FLAG_DISABLE_DFORCE_SWAP = 0x4000000000;
    uint256 public constant FLAG_DISABLE_SHELL = 0x8000000000;
    uint256 public constant FLAG_ENABLE_CHI_BURN = 0x10000000000;
}


contract IOneSplit is IOneSplitConsts {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        );

    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 flags
    ) public payable;
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



interface IUniswapExchange {
    function getEthToTokenInputPrice(uint256 ethSold) external view returns (uint256 tokensBought);

    function getTokenToEthInputPrice(uint256 tokensSold) external view returns (uint256 ethBought);

    function ethToTokenSwapInput(uint256 minTokens, uint256 deadline)
        external
        payable
        returns (uint256 tokensBought);

    function tokenToEthSwapInput(uint256 tokensSold, uint256 minEth, uint256 deadline)
        external
        returns (uint256 ethBought);

    function tokenToTokenSwapInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint256 deadline,
        address tokenAddr
    ) external returns (uint256 tokensBought);
}

 

pragma solidity ^0.5.0;



interface IUniswapFactory {
    function getExchange(IERC20 token) external view returns (IUniswapExchange exchange);
}

 

pragma solidity ^0.5.0;



interface IKyberNetworkContract {
    function searchBestRate(IERC20 src, IERC20 dest, uint256 srcAmount, bool usePermissionless)
        external
        view
        returns (address reserve, uint256 rate);
}

 

pragma solidity ^0.5.0;



interface IKyberNetworkProxy {
    function getExpectedRate(IERC20 src, IERC20 dest, uint256 srcQty)
        external
        view
        returns (uint256 expectedRate, uint256 slippageRate);

    function tradeWithHint(
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address walletId,
        bytes calldata hint
    ) external payable returns (uint256);

    function kyberNetworkContract() external view returns (IKyberNetworkContract);

     
     

     
     
     
}

 

pragma solidity ^0.5.0;


interface IKyberUniswapReserve {
    function uniswapFactory() external view returns (address);
}

 

pragma solidity ^0.5.0;


interface IKyberOasisReserve {
    function otc() external view returns (address);
}

 

pragma solidity ^0.5.0;


contract IKyberBancorReserve {
    function bancorEth() public view returns (address);
}

 

pragma solidity ^0.5.0;


interface IBancorNetwork {
    function getReturnByPath(address[] calldata path, uint256 amount)
        external
        view
        returns (uint256 returnAmount, uint256 conversionFee);

    function claimAndConvert(address[] calldata path, uint256 amount, uint256 minReturn)
        external
        returns (uint256);

    function convert(address[] calldata path, uint256 amount, uint256 minReturn)
        external
        payable
        returns (uint256);
}

 

pragma solidity ^0.5.0;


contract IBancorContractRegistry {
    function addressOf(bytes32 contractName) external view returns (address);
}

 

pragma solidity ^0.5.0;



interface IBancorConverterRegistry {

    function getConvertibleTokenSmartTokenCount(IERC20 convertibleToken)
        external view returns(uint256);

    function getConvertibleTokenSmartTokens(IERC20 convertibleToken)
        external view returns(address[] memory);

    function getConvertibleTokenSmartToken(IERC20 convertibleToken, uint256 index)
        external view returns(address);

    function isConvertibleTokenSmartToken(IERC20 convertibleToken, address value)
        external view returns(bool);
}

 

pragma solidity ^0.5.0;



contract IBancorEtherToken is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}

 

pragma solidity ^0.5.0;



interface IOasisExchange {
    function getBuyAmount(IERC20 buyGem, IERC20 payGem, uint256 payAmt)
        external
        view
        returns (uint256 fillAmt);

    function sellAllAmount(IERC20 payGem, uint256 payAmt, IERC20 buyGem, uint256 minFillAmount)
        external
        returns (uint256 fillAmt);
}

 

pragma solidity ^0.5.0;



contract IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}

 

pragma solidity ^0.5.0;


interface ICurve {
     
    function get_dy_underlying(int128 i, int128 j, uint256 dx) external view returns(uint256 dy);

     
    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256 dy);

     
    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 minDy) external;

     
    function exchange(int128 i, int128 j, uint256 dx, uint256 minDy) external;
}

 

pragma solidity ^0.5.0;



interface IPot {
    function dsr() external view returns (uint256);

    function chi() external view returns (uint256);

    function rho() external view returns (uint256);

    function drip() external returns (uint256);

    function join(uint256) external;

    function exit(uint256) external;
}


contract IChai is IERC20 {
    function POT() public view returns (IPot);

    function join(address dst, uint256 wad) external;

    function exit(address src, uint256 wad) external;
}


library ChaiHelper {
    IPot private constant POT = IPot(0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7);
    uint256 private constant RAY = 10**27;

    function _mul(uint256 x, uint256 y) private pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function _rmul(uint256 x, uint256 y) private pure returns (uint256 z) {
         
        z = _mul(x, y) / RAY;
    }

    function _rdiv(uint256 x, uint256 y) private pure returns (uint256 z) {
         
        z = _mul(x, RAY) / y;
    }

    function rpow(uint256 x, uint256 n, uint256 base) private pure returns (uint256 z) {
         
        assembly {
            switch x
                case 0 {
                    switch n
                        case 0 {
                            z := base
                        }
                        default {
                            z := 0
                        }
                }
                default {
                    switch mod(n, 2)
                        case 0 {
                            z := base
                        }
                        default {
                            z := x
                        }
                    let half := div(base, 2)  
                    for {
                        n := div(n, 2)
                    } n {
                        n := div(n, 2)
                    } {
                        let xx := mul(x, x)
                        if iszero(eq(div(xx, x), x)) {
                            revert(0, 0)
                        }
                        let xxRound := add(xx, half)
                        if lt(xxRound, xx) {
                            revert(0, 0)
                        }
                        x := div(xxRound, base)
                        if mod(n, 2) {
                            let zx := mul(z, x)
                            if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) {
                                revert(0, 0)
                            }
                            let zxRound := add(zx, half)
                            if lt(zxRound, zx) {
                                revert(0, 0)
                            }
                            z := div(zxRound, base)
                        }
                    }
                }
        }
    }

    function potDrip() private view returns (uint256) {
        return _rmul(rpow(POT.dsr(), now - POT.rho(), RAY), POT.chi());
    }

    function daiToChai(
        IChai,  
        uint256 amount
    ) internal view returns (uint256) {
        uint256 chi = (now > POT.rho()) ? potDrip() : POT.chi();
        return _rdiv(amount, chi);
    }

    function chaiToDai(
        IChai,  
        uint256 amount
    ) internal view returns (uint256) {
        uint256 chi = (now > POT.rho()) ? potDrip() : POT.chi();
        return _rmul(chi, amount);
    }
}

 

pragma solidity ^0.5.0;



contract ICompound {
    function markets(address cToken)
        external
        view
        returns (bool isListed, uint256 collateralFactorMantissa);
}


contract ICompoundToken is IERC20 {
    function underlying() external view returns (address);

    function exchangeRateStored() external view returns (uint256);

    function mint(uint256 mintAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);
}


contract ICompoundEther is IERC20 {
    function mint() external payable;

    function redeem(uint256 redeemTokens) external returns (uint256);
}

 

pragma solidity ^0.5.0;



contract IAaveToken is IERC20 {
    function underlyingAssetAddress() external view returns (IERC20);

    function redeem(uint256 amount) external;
}


interface IAaveLendingPool {
    function core() external view returns (address);

    function deposit(IERC20 token, uint256 amount, uint16 refCode) external payable;
}

 

pragma solidity ^0.5.0;



interface IMooniswapRegistry {
    function target() external view returns(IMooniswap);
}


interface IMooniswap {
    function getReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    )
        external
        view
        returns(uint256 returnAmount);

    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 minReturn
    )
        external
        payable
        returns(uint256 returnAmount);
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





library UniversalERC20 {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private constant ZERO_ADDRESS = IERC20(0x0000000000000000000000000000000000000000);
    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(IERC20 token, address to, uint256 amount) internal returns(bool) {
        if (amount == 0) {
            return true;
        }

        if (isETH(token)) {
            address(uint160(to)).transfer(amount);
        } else {
            token.safeTransfer(to, amount);
            return true;
        }
    }

    function universalTransferFrom(IERC20 token, address from, address to, uint256 amount) internal {
        if (amount == 0) {
            return;
        }

        if (isETH(token)) {
            require(from == msg.sender && msg.value >= amount, "Wrong useage of ETH.universalTransferFrom()");
            if (to != address(this)) {
                address(uint160(to)).transfer(amount);
            }
            if (msg.value > amount) {
                msg.sender.transfer(msg.value.sub(amount));
            }
        } else {
            token.safeTransferFrom(from, to, amount);
        }
    }

    function universalTransferFromSenderToThis(IERC20 token, uint256 amount) internal {
        if (amount == 0) {
            return;
        }

        if (isETH(token)) {
            if (msg.value > amount) {
                 
                msg.sender.transfer(msg.value.sub(amount));
            }
        } else {
            token.safeTransferFrom(msg.sender, address(this), amount);
        }
    }

    function universalApprove(IERC20 token, address to, uint256 amount) internal {
        if (!isETH(token)) {
            if (amount > 0 && token.allowance(address(this), to) > 0) {
                token.safeApprove(to, 0);
            }
            token.safeApprove(to, amount);
        }
    }

    function universalBalanceOf(IERC20 token, address who) internal view returns (uint256) {
        if (isETH(token)) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }

    function universalDecimals(IERC20 token) internal view returns (uint256) {

        if (isETH(token)) {
            return 18;
        }

        (bool success, bytes memory data) = address(token).staticcall.gas(10000)(
            abi.encodeWithSignature("decimals()")
        );
        if (!success || data.length == 0) {
            (success, data) = address(token).staticcall.gas(10000)(
                abi.encodeWithSignature("DECIMALS()")
            );
        }

        return (success && data.length > 0) ? abi.decode(data, (uint256)) : 18;
    }

    function isETH(IERC20 token) internal pure returns(bool) {
        return (address(token) == address(ZERO_ADDRESS) || address(token) == address(ETH_ADDRESS));
    }
}

 

pragma solidity ^0.5.0;





interface IUniswapV2Exchange {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}


library UniswapV2ExchangeLib {
    using SafeMath for uint256;
    using UniversalERC20 for IERC20;

    function getReturn(
        IUniswapV2Exchange exchange,
        IERC20 fromToken,
        IERC20 toToken,
        uint amountIn
    ) internal view returns (uint256) {
        uint256 reserveIn = fromToken.universalBalanceOf(address(exchange));
        uint256 reserveOut = toToken.universalBalanceOf(address(exchange));

        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        return (denominator == 0) ? 0 : numerator.div(denominator);
    }
}

 

pragma solidity ^0.5.0;



interface IUniswapV2Factory {
    function getPair(IERC20 tokenA, IERC20 tokenB) external view returns (IUniswapV2Exchange pair);
}

 

pragma solidity ^0.5.0;



interface IDForceSwap {
    function getAmountByInput(IERC20 input, IERC20 output, uint256 amount) external view returns(uint256);
    function swap(IERC20 input, IERC20 output, uint256 amount) external;
}

 

pragma solidity ^0.5.0;


interface IShell {
    function viewOriginTrade(
        address origin,
        address target,
        uint256 originAmount
    ) external view returns (uint256);

    function swapByOrigin(
        address origin,
        address target,
        uint256 originAmount,
        uint256 minTargetAmount,
        uint256 deadline
    ) external returns (uint256);
}

 

pragma solidity ^0.5.0;









 
















contract IOneSplitView is IOneSplitConsts {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        );
}


library DisableFlags {
    function check(uint256 flags, uint256 flag) internal pure returns(bool) {
        return (flags & flag) != 0;
    }
}


contract OneSplitRoot {
    using SafeMath for uint256;
    using DisableFlags for uint256;

    using UniversalERC20 for IERC20;
    using UniversalERC20 for IWETH;
    using UniversalERC20 for IBancorEtherToken;
    using UniswapV2ExchangeLib for IUniswapV2Exchange;
    using ChaiHelper for IChai;

    uint256 constant public DEXES_COUNT = 22;
    IERC20 constant public ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    IERC20 constant public dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 constant public bnt = IERC20(0x1F573D6Fb3F13d689FF844B4cE37794d79a7FF1C);
    IERC20 constant public usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 constant public usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 constant public tusd = IERC20(0x0000000000085d4780B73119b644AE5ecd22b376);
    IERC20 constant public busd = IERC20(0x4Fabb145d64652a948d72533023f6E7A623C7C53);
    IERC20 constant public susd = IERC20(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51);
    IERC20 constant public pax = IERC20(0x8E870D67F660D95d5be530380D0eC0bd388289E1);
    IWETH constant public weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IBancorEtherToken constant public bancorEtherToken = IBancorEtherToken(0xc0829421C1d260BD3cB3E0F06cfE2D52db2cE315);
    IChai constant public chai = IChai(0x06AF07097C9Eeb7fD685c692751D5C66dB49c215);
    IERC20 constant public renbtc = IERC20(0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D);
    IERC20 constant public wbtc = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IERC20 constant public tbtc = IERC20(0x1bBE271d15Bb64dF0bc6CD28Df9Ff322F2eBD847);
    IERC20 constant public hbtc = IERC20(0x0316EB71485b0Ab14103307bf65a021042c6d380);

    IKyberNetworkProxy constant public kyberNetworkProxy = IKyberNetworkProxy(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
    IUniswapFactory constant public uniswapFactory = IUniswapFactory(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);
    IBancorContractRegistry constant public bancorContractRegistry = IBancorContractRegistry(0x52Ae12ABe5D8BD778BD5397F99cA900624CfADD4);
     
    IBancorConverterRegistry constant public bancorConverterRegistry = IBancorConverterRegistry(0xf6E2D7F616B67E46D708e4410746E9AAb3a4C518);
    IOasisExchange constant public oasisExchange = IOasisExchange(0x794e6e91555438aFc3ccF1c5076A74F42133d08D);
    ICurve constant public curveCompound = ICurve(0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56);
    ICurve constant public curveUsdt = ICurve(0x52EA46506B9CC5Ef470C5bf89f17Dc28bB35D85C);
    ICurve constant public curveY = ICurve(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);
    ICurve constant public curveBinance = ICurve(0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27);
    ICurve constant public curveSynthetix = ICurve(0xA5407eAE9Ba41422680e2e00537571bcC53efBfD);
    ICurve constant public curvePax = ICurve(0x06364f10B501e868329afBc005b3492902d6C763);
    ICurve constant public curveRenBtc = ICurve(0x93054188d876f558f4a66B2EF1d97d16eDf0895B);
    ICurve constant public curveTBtc = ICurve(0x9726e9314eF1b96E45f40056bEd61A088897313E);
    IShell constant public shell = IShell(0xA8253a440Be331dC4a7395B73948cCa6F19Dc97D);
    IAaveLendingPool constant public aave = IAaveLendingPool(0x398eC7346DcD622eDc5ae82352F02bE94C62d119);
    ICompound constant public compound = ICompound(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    ICompoundEther constant public cETH = ICompoundEther(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);
    IMooniswapRegistry constant public mooniswapRegistry = IMooniswapRegistry(0x7079E8517594e5b21d2B9a0D17cb33F5FE2bca70);
    IUniswapV2Factory constant public uniswapV2 = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    IDForceSwap constant public dforceSwap = IDForceSwap(0x03eF3f37856bD08eb47E2dE7ABc4Ddd2c19B60F2);

    function _buildBancorPath(
        IERC20 fromToken,
        IERC20 toToken
    ) internal view returns(address[] memory path) {
        if (fromToken == toToken) {
            return new address[](0);
        }

        if (fromToken.isETH()) {
            fromToken = bancorEtherToken;
        }
        if (toToken.isETH()) {
            toToken = bancorEtherToken;
        }

        if (fromToken == bnt || toToken == bnt) {
            path = new address[](3);
        } else {
            path = new address[](5);
        }

        address fromConverter;
        address toConverter;

        if (fromToken != bnt) {
            (bool success, bytes memory data) = address(bancorConverterRegistry).staticcall.gas(10000)(abi.encodeWithSelector(
                bancorConverterRegistry.getConvertibleTokenSmartToken.selector,
                fromToken.isETH() ? bnt : fromToken,
                0
            ));
            if (!success) {
                return new address[](0);
            }

            fromConverter = abi.decode(data, (address));
            if (fromConverter == address(0)) {
                return new address[](0);
            }
        }

        if (toToken != bnt) {
            (bool success, bytes memory data) = address(bancorConverterRegistry).staticcall.gas(10000)(abi.encodeWithSelector(
                bancorConverterRegistry.getConvertibleTokenSmartToken.selector,
                toToken.isETH() ? bnt : toToken,
                0
            ));
            if (!success) {
                return new address[](0);
            }

            toConverter = abi.decode(data, (address));
            if (toConverter == address(0)) {
                return new address[](0);
            }
        }

        if (toToken == bnt) {
            path[0] = address(fromToken);
            path[1] = fromConverter;
            path[2] = address(bnt);
            return path;
        }

        if (fromToken == bnt) {
            path[0] = address(bnt);
            path[1] = toConverter;
            path[2] = address(toToken);
            return path;
        }

        path[0] = address(fromToken);
        path[1] = fromConverter;
        path[2] = address(bnt);
        path[3] = toConverter;
        path[4] = address(toToken);
        return path;
    }

    function _getCompoundToken(IERC20 token) internal pure returns(ICompoundToken) {
        if (token.isETH()) {  
            return ICompoundToken(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);
        }
        if (token == IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F)) {  
            return ICompoundToken(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
        }
        if (token == IERC20(0x0D8775F648430679A709E98d2b0Cb6250d2887EF)) {  
            return ICompoundToken(0x6C8c6b02E7b2BE14d4fA6022Dfd6d75921D90E4E);
        }
        if (token == IERC20(0x1985365e9f78359a9B6AD760e32412f4a445E862)) {  
            return ICompoundToken(0x158079Ee67Fce2f58472A96584A73C7Ab9AC95c1);
        }
        if (token == IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)) {  
            return ICompoundToken(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
        }
        if (token == IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599)) {  
            return ICompoundToken(0xC11b1268C1A384e55C48c2391d8d480264A3A7F4);
        }
        if (token == IERC20(0xE41d2489571d322189246DaFA5ebDe1F4699F498)) {  
            return ICompoundToken(0xB3319f5D18Bc0D84dD1b4825Dcde5d5f7266d407);
        }
        if (token == IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7)) {  
            return ICompoundToken(0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9);
        }

        return ICompoundToken(0);
    }

    function _getAaveToken(IERC20 token) internal pure returns(IAaveToken) {
        if (token.isETH()) {  
            return IAaveToken(0x3a3A65aAb0dd2A17E3F1947bA16138cd37d08c04);
        }
        if (token == IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F)) {  
            return IAaveToken(0xfC1E690f61EFd961294b3e1Ce3313fBD8aa4f85d);
        }
        if (token == IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)) {  
            return IAaveToken(0x9bA00D6856a4eDF4665BcA2C2309936572473B7E);
        }
        if (token == IERC20(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51)) {  
            return IAaveToken(0x625aE63000f46200499120B906716420bd059240);
        }
        if (token == IERC20(0x4Fabb145d64652a948d72533023f6E7A623C7C53)) {  
            return IAaveToken(0x6Ee0f7BB50a54AB5253dA0667B0Dc2ee526C30a8);
        }
        if (token == IERC20(0x0000000000085d4780B73119b644AE5ecd22b376)) {  
            return IAaveToken(0x4DA9b813057D04BAef4e5800E36083717b4a0341);
        }
        if (token == IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7)) {  
            return IAaveToken(0x71fc860F7D3A592A4a98740e39dB31d25db65ae8);
        }
        if (token == IERC20(0x0D8775F648430679A709E98d2b0Cb6250d2887EF)) {  
            return IAaveToken(0xE1BA0FB44CCb0D11b80F92f4f8Ed94CA3fF51D00);
        }
        if (token == IERC20(0xdd974D5C2e2928deA5F71b9825b8b646686BD200)) {  
            return IAaveToken(0x9D91BE44C06d373a8a226E1f3b146956083803eB);
        }
        if (token == IERC20(0x80fB784B7eD66730e8b1DBd9820aFD29931aab03)) {  
            return IAaveToken(0x7D2D3688Df45Ce7C552E19c27e007673da9204B8);
        }
        if (token == IERC20(0x514910771AF9Ca656af840dff83E8264EcF986CA)) {  
            return IAaveToken(0xA64BD6C70Cb9051F6A9ba1F163Fdc07E0DfB5F84);
        }
        if (token == IERC20(0x0F5D2fB29fb7d3CFeE444a200298f468908cC942)) {  
            return IAaveToken(0x6FCE4A401B6B80ACe52baAefE4421Bd188e76F6f);
        }
        if (token == IERC20(0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2)) {  
            return IAaveToken(0x7deB5e830be29F91E298ba5FF1356BB7f8146998);
        }
        if (token == IERC20(0x1985365e9f78359a9B6AD760e32412f4a445E862)) {  
            return IAaveToken(0x71010A9D003445aC60C4e6A7017c1E89A477B438);
        }
        if (token == IERC20(0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F)) {  
            return IAaveToken(0x328C4c80BC7aCa0834Db37e6600A6c49E12Da4DE);
        }
        if (token == IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599)) {  
            return IAaveToken(0xFC4B8ED459e00e5400be803A9BB3954234FD50e3);
        }
        if (token == IERC20(0xE41d2489571d322189246DaFA5ebDe1F4699F498)) {  
            return IAaveToken(0x6Fb0855c404E09c47C3fBCA25f08d4E41f9F062f);
        }

        return IAaveToken(0);
    }

    function _infiniteApproveIfNeeded(IERC20 token, address to) internal {
        if (!token.isETH()) {
            if ((token.allowance(address(this), to) >> 255) == 0) {
                token.universalApprove(to, uint256(- 1));
            }
        }
    }
}


contract OneSplitViewWrapBase is IOneSplitView, OneSplitRoot {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags  
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        return _getExpectedReturnFloor(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }

    function _getExpectedReturnFloor(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags  
    )
        internal
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        );
}


contract OneSplitView is IOneSplitView, OneSplitRoot {
    function log(uint256) external view {
    }

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags  
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        distribution = new uint256[](DEXES_COUNT);

        if (fromToken == toToken) {
            return (amount, distribution);
        }

        bool invert = flags.check(FLAG_DISABLE_ALL_SPLIT_SOURCES);
        function(IERC20,IERC20,uint256,uint256) view returns(uint256)[DEXES_COUNT] memory reserves = [
            invert != flags.check(FLAG_DISABLE_UNISWAP)          ? _calculateNoReturn : calculateUniswapReturn,
            invert != flags.check(FLAG_DISABLE_KYBER)            ? _calculateNoReturn : calculateKyberReturn,
            invert != flags.check(FLAG_DISABLE_BANCOR)           ? _calculateNoReturn : calculateBancorReturn,
            invert != flags.check(FLAG_DISABLE_OASIS)            ? _calculateNoReturn : calculateOasisReturn,
            invert != flags.check(FLAG_DISABLE_CURVE_COMPOUND)   ? _calculateNoReturn : calculateCurveCompound,
            invert != flags.check(FLAG_DISABLE_CURVE_USDT)       ? _calculateNoReturn : calculateCurveUsdt,
            invert != flags.check(FLAG_DISABLE_CURVE_Y)          ? _calculateNoReturn : calculateCurveY,
            invert != flags.check(FLAG_DISABLE_CURVE_BINANCE)    ? _calculateNoReturn : calculateCurveBinance,
            invert != flags.check(FLAG_DISABLE_CURVE_SYNTHETIX)  ? _calculateNoReturn : calculateCurveSynthetix,
            (true) != flags.check(FLAG_ENABLE_UNISWAP_COMPOUND)  ? _calculateNoReturn : calculateUniswapCompound,
            (true) != flags.check(FLAG_ENABLE_UNISWAP_CHAI)      ? _calculateNoReturn : calculateUniswapChai,
            (true) != flags.check(FLAG_ENABLE_UNISWAP_AAVE)      ? _calculateNoReturn : calculateUniswapAave,
            invert != flags.check(FLAG_DISABLE_MOONISWAP)        ? _calculateNoReturn : calculateMooniswap,
            invert != flags.check(FLAG_DISABLE_UNISWAP_V2)       ? _calculateNoReturn : calculateUniswapV2,
            invert != flags.check(FLAG_DISABLE_UNISWAP_V2_ETH)   ? _calculateNoReturn : calculateUniswapV2ETH,
            invert != flags.check(FLAG_DISABLE_UNISWAP_V2_DAI)   ? _calculateNoReturn : calculateUniswapV2DAI,
            invert != flags.check(FLAG_DISABLE_UNISWAP_V2_USDC)  ? _calculateNoReturn : calculateUniswapV2USDC,
            invert != flags.check(FLAG_DISABLE_CURVE_PAX)        ? _calculateNoReturn : calculateCurvePax,
            invert != flags.check(FLAG_DISABLE_CURVE_RENBTC)     ? _calculateNoReturn : calculateCurveRenBtc,
            invert != flags.check(FLAG_DISABLE_CURVE_TBTC)       ? _calculateNoReturn : calculateCurveTBtc,
            invert != flags.check(FLAG_DISABLE_DFORCE_SWAP)      ? _calculateNoReturn : calculateDforceSwap,
            invert != flags.check(FLAG_DISABLE_SHELL)            ? _calculateNoReturn : calculateShell
        ];

        uint256[DEXES_COUNT] memory rates;
        uint256[DEXES_COUNT] memory fullRates;
        for (uint i = 0; i < rates.length; i++) {
            rates[i] = reserves[i](fromToken, toToken, amount.div(parts), flags);
            this.log(rates[i]);
            fullRates[i] = rates[i];
        }

        for (uint j = 0; j < parts; j++) {
             
            uint256 bestIndex = 0;
            for (uint i = 1; i < rates.length; i++) {
                if (rates[i] > rates[bestIndex]) {
                    bestIndex = i;
                }
            }

             
            returnAmount = returnAmount.add(rates[bestIndex]);
            distribution[bestIndex]++;

             
            uint256 srcAmount = amount;

             
            if (j + 1 < parts) {
                uint256 newRate = reserves[bestIndex](
                    fromToken,
                    toToken,
                    srcAmount.mul(distribution[bestIndex] + 1).div(parts),
                    flags
                );
                if (newRate > fullRates[bestIndex]) {
                    rates[bestIndex] = newRate.sub(fullRates[bestIndex]);
                } else {
                    rates[bestIndex] = 0;
                }
                this.log(rates[bestIndex]);
                fullRates[bestIndex] = newRate;
            }
        }
    }

     

    function calculateCurveCompound(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256  
    ) public view returns(uint256) {
        int128 i = (fromToken == dai ? 1 : 0) + (fromToken == usdc ? 2 : 0);
        int128 j = (destToken == dai ? 1 : 0) + (destToken == usdc ? 2 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        return curveCompound.get_dy_underlying(i - 1, j - 1, amount);
    }

    function calculateCurveUsdt(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256  
    ) public view returns(uint256) {
        int128 i = (fromToken == dai ? 1 : 0) +
            (fromToken == usdc ? 2 : 0) +
            (fromToken == usdt ? 3 : 0);
        int128 j = (destToken == dai ? 1 : 0) +
            (destToken == usdc ? 2 : 0) +
            (destToken == usdt ? 3 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        return curveUsdt.get_dy_underlying(i - 1, j - 1, amount);
    }

    function calculateCurveY(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256  
    ) public view returns(uint256) {
        int128 i = (fromToken == dai ? 1 : 0) +
            (fromToken == usdc ? 2 : 0) +
            (fromToken == usdt ? 3 : 0) +
            (fromToken == tusd ? 4 : 0);
        int128 j = (destToken == dai ? 1 : 0) +
            (destToken == usdc ? 2 : 0) +
            (destToken == usdt ? 3 : 0) +
            (destToken == tusd ? 4 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        return curveY.get_dy_underlying(i - 1, j - 1, amount);
    }

    function calculateCurveBinance(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256  
    ) public view returns(uint256) {
        int128 i = (fromToken == dai ? 1 : 0) +
            (fromToken == usdc ? 2 : 0) +
            (fromToken == usdt ? 3 : 0) +
            (fromToken == busd ? 4 : 0);
        int128 j = (destToken == dai ? 1 : 0) +
            (destToken == usdc ? 2 : 0) +
            (destToken == usdt ? 3 : 0) +
            (destToken == busd ? 4 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        return curveBinance.get_dy_underlying(i - 1, j - 1, amount);
    }

    function calculateCurveSynthetix(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256  
    ) public view returns(uint256) {
        int128 i = (fromToken == dai ? 1 : 0) +
            (fromToken == usdc ? 2 : 0) +
            (fromToken == usdt ? 3 : 0) +
            (fromToken == susd ? 4 : 0);
        int128 j = (destToken == dai ? 1 : 0) +
            (destToken == usdc ? 2 : 0) +
            (destToken == usdt ? 3 : 0) +
            (destToken == susd ? 4 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        return curveSynthetix.get_dy_underlying(i - 1, j - 1, amount);
    }

    function calculateCurvePax(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256  
    ) public view returns(uint256) {
        int128 i = (fromToken == dai ? 1 : 0) +
            (fromToken == usdc ? 2 : 0) +
            (fromToken == usdt ? 3 : 0) +
            (fromToken == pax ? 4 : 0);
        int128 j = (destToken == dai ? 1 : 0) +
            (destToken == usdc ? 2 : 0) +
            (destToken == usdt ? 3 : 0) +
            (destToken == pax ? 4 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        return curvePax.get_dy_underlying(i - 1, j - 1, amount);
    }

    function calculateCurveRenBtc(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256  
    ) public view returns(uint256) {
        int128 i = (fromToken == renbtc ? 1 : 0) +
            (fromToken == wbtc ? 2 : 0);
        int128 j = (destToken == renbtc ? 1 : 0) +
            (destToken == wbtc ? 2 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        return curveRenBtc.get_dy(i - 1, j - 1, amount);
    }

    function calculateCurveTBtc(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256  
    ) public view returns(uint256) {
        int128 i = (fromToken == tbtc ? 1 : 0) +
            (fromToken == wbtc ? 2 : 0) +
            (fromToken == hbtc ? 3 : 0);
        int128 j = (destToken == tbtc ? 1 : 0) +
            (destToken == wbtc ? 2 : 0) +
            (destToken == hbtc ? 3 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        return curveTBtc.get_dy(i - 1, j - 1, amount);
    }

    function calculateShell(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256  
    ) public view returns (uint256) {
        (bool success, bytes memory data) = address(shell).staticcall(abi.encodeWithSelector(
            shell.viewOriginTrade.selector,
            fromToken,
            destToken,
            amount
        ));

        if (!success || data.length == 0) {
            return 0;
        }

        return abi.decode(data, (uint256));
    }

    function calculateDforceSwap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256  
    ) public view returns(uint256) {
        (bool success, bytes memory data) = address(dforceSwap).staticcall(
            abi.encodeWithSelector(
                dforceSwap.getAmountByInput.selector,
                fromToken,
                destToken,
                amount
            )
        );
        if (!success || data.length == 0) {
            return 0;
        }

        uint256 result = abi.decode(data, (uint256));
        uint256 available = destToken.universalBalanceOf(address(dforceSwap));
        if (result > available) {
            return 0;
        }

        return result;
    }

    function calculateUniswapReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256  
    ) public view returns(uint256) {
        uint256 returnAmount = amount;

        if (!fromToken.isETH()) {
            IUniswapExchange fromExchange = uniswapFactory.getExchange(fromToken);
            if (fromExchange != IUniswapExchange(0)) {
                (bool success, bytes memory data) = address(fromExchange).staticcall.gas(200000)(
                    abi.encodeWithSelector(
                        fromExchange.getTokenToEthInputPrice.selector,
                        returnAmount
                    )
                );
                if (success) {
                    returnAmount = abi.decode(data, (uint256));
                } else {
                    returnAmount = 0;
                }
            } else {
                returnAmount = 0;
            }
        }

        if (!toToken.isETH()) {
            IUniswapExchange toExchange = uniswapFactory.getExchange(toToken);
            if (toExchange != IUniswapExchange(0)) {
                (bool success, bytes memory data) = address(toExchange).staticcall.gas(200000)(
                    abi.encodeWithSelector(
                        toExchange.getEthToTokenInputPrice.selector,
                        returnAmount
                    )
                );
                if (success) {
                    returnAmount = abi.decode(data, (uint256));
                } else {
                    returnAmount = 0;
                }
            } else {
                returnAmount = 0;
            }
        }

        return returnAmount;
    }

    function calculateUniswapCompound(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 flags
    ) public view returns(uint256) {
        if (!fromToken.isETH() && !toToken.isETH()) {
            return 0;
        }

        if (!fromToken.isETH()) {
            ICompoundToken fromCompound = _getCompoundToken(fromToken);
            if (fromCompound != ICompoundToken(0)) {
                return calculateUniswapReturn(
                    fromCompound,
                    toToken,
                    amount.mul(1e18).div(fromCompound.exchangeRateStored()),
                    flags
                );
            }
        } else {
            ICompoundToken toCompound = _getCompoundToken(toToken);
            if (toCompound != ICompoundToken(0)) {
                return calculateUniswapReturn(
                    fromToken,
                    toCompound,
                    amount,
                    flags
                ).mul(toCompound.exchangeRateStored()).div(1e18);
            }
        }

        return 0;
    }

    function calculateUniswapChai(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 flags
    ) public view returns(uint256) {
        if (fromToken == dai && toToken.isETH()) {
            return calculateUniswapReturn(
                chai,
                toToken,
                chai.daiToChai(amount),
                flags
            );
        }

        if (fromToken.isETH() && toToken == dai) {
            return chai.chaiToDai(calculateUniswapReturn(
                fromToken,
                chai,
                amount,
                flags
            ));
        }

        return 0;
    }

    function calculateUniswapAave(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 flags
    ) public view returns(uint256) {
        if (!fromToken.isETH() && !toToken.isETH()) {
            return 0;
        }

        if (!fromToken.isETH()) {
            IAaveToken fromAave = _getAaveToken(fromToken);
            if (fromAave != IAaveToken(0)) {
                return calculateUniswapReturn(
                    fromAave,
                    toToken,
                    amount,
                    flags
                );
            }
        } else {
            IAaveToken toAave = _getAaveToken(toToken);
            if (toAave != IAaveToken(0)) {
                return calculateUniswapReturn(
                    fromToken,
                    toAave,
                    amount,
                    flags
                );
            }
        }

        return 0;
    }

    function calculateKyberReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 flags
    ) public view returns(uint256) {
        (bool success, bytes memory data) = address(kyberNetworkProxy).staticcall.gas(2300)(abi.encodeWithSelector(
            kyberNetworkProxy.kyberNetworkContract.selector
        ));
        if (!success) {
            return 0;
        }

        IKyberNetworkContract kyberNetworkContract = IKyberNetworkContract(abi.decode(data, (address)));

        if (fromToken.isETH() || toToken.isETH()) {
            return _calculateKyberReturnWithEth(kyberNetworkContract, fromToken, toToken, amount, flags);
        }

        uint256 value = _calculateKyberReturnWithEth(kyberNetworkContract, fromToken, ETH_ADDRESS, amount, flags);
        if (value == 0) {
            return 0;
        }

        return _calculateKyberReturnWithEth(kyberNetworkContract, ETH_ADDRESS, toToken, value, flags);
    }

    function _calculateKyberReturnWithEth(
        IKyberNetworkContract kyberNetworkContract,
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 flags
    ) public view returns(uint256) {
        require(fromToken.isETH() || toToken.isETH(), "One of the tokens should be ETH");

        (bool success, bytes memory data) = address(kyberNetworkContract).staticcall.gas(1500000)(abi.encodeWithSelector(
            kyberNetworkContract.searchBestRate.selector,
            fromToken.isETH() ? ETH_ADDRESS : fromToken,
            toToken.isETH() ? ETH_ADDRESS : toToken,
            amount,
            true
        ));
        if (!success) {
            return 0;
        }

        (address reserve, uint256 rate) = abi.decode(data, (address,uint256));

        if (rate == 0) {
            return 0;
        }

        if ((reserve == 0x31E085Afd48a1d6e51Cc193153d625e8f0514C7F && !flags.check(FLAG_ENABLE_KYBER_UNISWAP_RESERVE)) ||
            (reserve == 0x1E158c0e93c30d24e918Ef83d1e0bE23595C3c0f && !flags.check(FLAG_ENABLE_KYBER_OASIS_RESERVE)) ||
            (reserve == 0x053AA84FCC676113a57e0EbB0bD1913839874bE4 && !flags.check(FLAG_ENABLE_KYBER_BANCOR_RESERVE)))
        {
            return 0;
        }

        if (!flags.check(FLAG_ENABLE_KYBER_UNISWAP_RESERVE)) {
            (success,) = reserve.staticcall.gas(2300)(abi.encodeWithSelector(
                IKyberUniswapReserve(reserve).uniswapFactory.selector
            ));
            if (success) {
                return 0;
            }
        }

        if (!flags.check(FLAG_ENABLE_KYBER_OASIS_RESERVE)) {
            (success,) = reserve.staticcall.gas(2300)(abi.encodeWithSelector(
                IKyberOasisReserve(reserve).otc.selector
            ));
            if (success) {
                return 0;
            }
        }

        if (!flags.check(FLAG_ENABLE_KYBER_BANCOR_RESERVE)) {
            (success,) = reserve.staticcall.gas(2300)(abi.encodeWithSelector(
                IKyberBancorReserve(reserve).bancorEth.selector
            ));
            if (success) {
                return 0;
            }
        }

        return rate.mul(amount)
            .mul(10 ** IERC20(toToken).universalDecimals())
            .div(10 ** IERC20(fromToken).universalDecimals())
            .div(1e18);
    }

    function calculateBancorReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256  
    ) public view returns(uint256) {
        IBancorNetwork bancorNetwork = IBancorNetwork(bancorContractRegistry.addressOf("BancorNetwork"));
        address[] memory path = _buildBancorPath(fromToken, toToken);

        (bool success, bytes memory data) = address(bancorNetwork).staticcall.gas(500000)(
            abi.encodeWithSelector(
                bancorNetwork.getReturnByPath.selector,
                path,
                amount
            )
        );
        if (!success) {
            return 0;
        }

        (uint256 returnAmount,) = abi.decode(data, (uint256,uint256));
        return returnAmount;
    }

    function calculateOasisReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256  
    ) public view returns(uint256) {
        (bool success, bytes memory data) = address(oasisExchange).staticcall.gas(500000)(
            abi.encodeWithSelector(
                oasisExchange.getBuyAmount.selector,
                toToken.isETH() ? weth : toToken,
                fromToken.isETH() ? weth : fromToken,
                amount
            )
        );
        if (!success) {
            return 0;
        }

        return abi.decode(data, (uint256));
    }

    function calculateMooniswap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256  
    ) public view returns(uint256) {
        IMooniswap mooniswap = mooniswapRegistry.target();
        (bool success, bytes memory data) = address(mooniswap).staticcall.gas(1000000)(
            abi.encodeWithSelector(
                mooniswap.getReturn.selector,
                fromToken,
                toToken,
                amount
            )
        );
        if (!success) {
            return 0;
        }

        return abi.decode(data, (uint256));
    }

    function calculateUniswapV2(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256  
    ) public view returns(uint256) {
        IERC20 fromTokenReal = fromToken.isETH() ? weth : fromToken;
        IERC20 toTokenReal = toToken.isETH() ? weth : toToken;
        IUniswapV2Exchange fromExchange = uniswapV2.getPair(fromTokenReal, toTokenReal);
        if (fromExchange != IUniswapV2Exchange(0)) {
            return fromExchange.getReturn(fromTokenReal, toTokenReal, amount);
        }
    }

    function calculateUniswapV2ETH(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 flags
    ) public view returns(uint256) {
        if (fromToken.isETH() || fromToken == weth || toToken.isETH() || toToken == weth) {
            return 0;
        }
        return calculateUniswapV2OverMidToken(
            fromToken,
            weth,
            toToken,
            amount,
            flags
        );
    }

    function calculateUniswapV2DAI(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 flags
    ) public view returns(uint256) {
        if (fromToken == dai || toToken == dai) {
            return 0;
        }
        return calculateUniswapV2OverMidToken(
            fromToken,
            dai,
            toToken,
            amount,
            flags
        );
    }

    function calculateUniswapV2USDC(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 flags
    ) public view returns(uint256) {
        if (fromToken == usdc || toToken == usdc) {
            return 0;
        }
        return calculateUniswapV2OverMidToken(
            fromToken,
            usdc,
            toToken,
            amount,
            flags
        );
    }

    function calculateUniswapV2OverMidToken(
        IERC20 fromToken,
        IERC20 midToken,
        IERC20 toToken,
        uint256 amount,
        uint256 flags
    ) public view returns(uint256) {
        return calculateUniswapV2(
            midToken,
            toToken,
            calculateUniswapV2(fromToken, midToken, amount, flags),
            flags
        );
    }

    function _calculateNoReturn(
        IERC20  ,
        IERC20  ,
        uint256  ,
        uint256  
    ) internal view returns(uint256) {
        this;
    }
}


contract OneSplitBaseWrap is IOneSplit, OneSplitRoot {
    function _swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags  
    ) internal {
        if (fromToken == toToken) {
            return;
        }

        _swapFloor(
            fromToken,
            toToken,
            amount,
            distribution,
            flags
        );
    }

    function _swapFloor(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256    
    ) internal;
}


contract OneSplit is IOneSplit, OneSplitRoot {
    IOneSplitView public oneSplitView;

    constructor(IOneSplitView _oneSplitView) public {
        oneSplitView = _oneSplitView;
    }

    function() external payable {
         
        require(msg.sender != tx.origin);
    }

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        return oneSplitView.getExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }

    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256  ,
        uint256[] memory distribution,
        uint256     
    ) public payable {
        if (fromToken == toToken) {
            return;
        }

        function(IERC20,IERC20,uint256) returns(uint256)[DEXES_COUNT] memory reserves = [
            _swapOnUniswap,
            _swapOnKyber,
            _swapOnBancor,
            _swapOnOasis,
            _swapOnCurveCompound,
            _swapOnCurveUsdt,
            _swapOnCurveY,
            _swapOnCurveBinance,
            _swapOnCurveSynthetix,
            _swapOnUniswapCompound,
            _swapOnUniswapChai,
            _swapOnUniswapAave,
            _swapOnMooniswap,
            _swapOnUniswapV2,
            _swapOnUniswapV2ETH,
            _swapOnUniswapV2DAI,
            _swapOnUniswapV2USDC,
            _swapOnCurvePax,
            _swapOnCurveRenBtc,
            _swapOnCurveTBtc,
            _swapOnDforceSwap,
            _swapOnShell
        ];

        require(distribution.length <= reserves.length, "OneSplit: Distribution array should not exceed reserves array size");

        uint256 parts = 0;
        uint256 lastNonZeroIndex = 0;
        for (uint i = 0; i < distribution.length; i++) {
            if (distribution[i] > 0) {
                parts = parts.add(distribution[i]);
                lastNonZeroIndex = i;
            }
        }

        require(parts > 0, "OneSplit: distribution should contain non-zeros");

        uint256 remainingAmount = amount;
        for (uint i = 0; i < distribution.length; i++) {
            if (distribution[i] == 0) {
                continue;
            }

            uint256 swapAmount = amount.mul(distribution[i]).div(parts);
            if (i == lastNonZeroIndex) {
                swapAmount = remainingAmount;
            }
            remainingAmount -= swapAmount;
            reserves[i](fromToken, toToken, swapAmount);
        }
    }

     

    function _swapOnCurveCompound(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) internal returns(uint256) {
        int128 i = (fromToken == dai ? 1 : 0) + (fromToken == usdc ? 2 : 0);
        int128 j = (destToken == dai ? 1 : 0) + (destToken == usdc ? 2 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        _infiniteApproveIfNeeded(fromToken, address(curveCompound));
        curveCompound.exchange_underlying(i - 1, j - 1, amount, 0);
    }

    function _swapOnCurveUsdt(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) internal returns(uint256) {
        int128 i = (fromToken == dai ? 1 : 0) +
            (fromToken == usdc ? 2 : 0) +
            (fromToken == usdt ? 3 : 0);
        int128 j = (destToken == dai ? 1 : 0) +
            (destToken == usdc ? 2 : 0) +
            (destToken == usdt ? 3 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        _infiniteApproveIfNeeded(fromToken, address(curveUsdt));
        curveUsdt.exchange_underlying(i - 1, j - 1, amount, 0);
    }

    function _swapOnCurveY(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) internal returns(uint256) {
        int128 i = (fromToken == dai ? 1 : 0) +
            (fromToken == usdc ? 2 : 0) +
            (fromToken == usdt ? 3 : 0) +
            (fromToken == tusd ? 4 : 0);
        int128 j = (destToken == dai ? 1 : 0) +
            (destToken == usdc ? 2 : 0) +
            (destToken == usdt ? 3 : 0) +
            (destToken == tusd ? 4 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        _infiniteApproveIfNeeded(fromToken, address(curveY));
        curveY.exchange_underlying(i - 1, j - 1, amount, 0);
    }

    function _swapOnCurveBinance(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) internal returns(uint256) {
        int128 i = (fromToken == dai ? 1 : 0) +
            (fromToken == usdc ? 2 : 0) +
            (fromToken == usdt ? 3 : 0) +
            (fromToken == busd ? 4 : 0);
        int128 j = (destToken == dai ? 1 : 0) +
            (destToken == usdc ? 2 : 0) +
            (destToken == usdt ? 3 : 0) +
            (destToken == busd ? 4 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        _infiniteApproveIfNeeded(fromToken, address(curveBinance));
        curveBinance.exchange_underlying(i - 1, j - 1, amount, 0);
    }

    function _swapOnCurveSynthetix(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) internal returns(uint256) {
        int128 i = (fromToken == dai ? 1 : 0) +
            (fromToken == usdc ? 2 : 0) +
            (fromToken == usdt ? 3 : 0) +
            (fromToken == susd ? 4 : 0);
        int128 j = (destToken == dai ? 1 : 0) +
            (destToken == usdc ? 2 : 0) +
            (destToken == usdt ? 3 : 0) +
            (destToken == susd ? 4 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        _infiniteApproveIfNeeded(fromToken, address(curveSynthetix));
        curveSynthetix.exchange_underlying(i - 1, j - 1, amount, 0);
    }

    function _swapOnCurvePax(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) internal returns(uint256) {
        int128 i = (fromToken == dai ? 1 : 0) +
            (fromToken == usdc ? 2 : 0) +
            (fromToken == usdt ? 3 : 0) +
            (fromToken == pax ? 4 : 0);
        int128 j = (destToken == dai ? 1 : 0) +
            (destToken == usdc ? 2 : 0) +
            (destToken == usdt ? 3 : 0) +
            (destToken == pax ? 4 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        _infiniteApproveIfNeeded(fromToken, address(curvePax));
        curvePax.exchange_underlying(i - 1, j - 1, amount, 0);
    }

    function _swapOnShell(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns (uint256) {
        _infiniteApproveIfNeeded(fromToken, address(shell));
        return shell.swapByOrigin(
            address(fromToken),
            address(toToken),
            amount,
            0,
            now + 50
        );
    }

    function _swapOnCurveRenBtc(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) internal returns(uint256) {
        int128 i = (fromToken == renbtc ? 1 : 0) +
            (fromToken == wbtc ? 2 : 0);
        int128 j = (destToken == renbtc ? 1 : 0) +
            (destToken == wbtc ? 2 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        _infiniteApproveIfNeeded(fromToken, address(curveRenBtc));
        curveRenBtc.exchange(i - 1, j - 1, amount, 0);
    }

    function _swapOnCurveTBtc(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) internal returns(uint256) {
        int128 i = (fromToken == tbtc ? 1 : 0) +
            (fromToken == wbtc ? 2 : 0) +
            (fromToken == hbtc ? 3 : 0);
        int128 j = (destToken == tbtc ? 1 : 0) +
            (destToken == wbtc ? 2 : 0) +
            (destToken == hbtc ? 3 : 0);
        if (i == 0 || j == 0) {
            return 0;
        }

        _infiniteApproveIfNeeded(fromToken, address(curveTBtc));
        curveTBtc.exchange(i - 1, j - 1, amount, 0);
    }

    function _swapOnDforceSwap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) internal returns(uint256) {
        _infiniteApproveIfNeeded(fromToken, address(dforceSwap));
        dforceSwap.swap(fromToken, destToken, amount);
    }

    function _swapOnUniswap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns(uint256) {

        uint256 returnAmount = amount;

        if (!fromToken.isETH()) {
            IUniswapExchange fromExchange = uniswapFactory.getExchange(fromToken);
            if (fromExchange != IUniswapExchange(0)) {
                _infiniteApproveIfNeeded(fromToken, address(fromExchange));
                returnAmount = fromExchange.tokenToEthSwapInput(returnAmount, 1, now);
            }
        }

        if (!toToken.isETH()) {
            IUniswapExchange toExchange = uniswapFactory.getExchange(toToken);
            if (toExchange != IUniswapExchange(0)) {
                returnAmount = toExchange.ethToTokenSwapInput.value(returnAmount)(1, now);
            }
        }

        return returnAmount;
    }

    function _swapOnUniswapCompound(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns(uint256) {
        if (!fromToken.isETH()) {
            ICompoundToken fromCompound = _getCompoundToken(fromToken);
            _infiniteApproveIfNeeded(fromToken, address(fromCompound));
            fromCompound.mint(amount);
            return _swapOnUniswap(IERC20(fromCompound), toToken, IERC20(fromCompound).universalBalanceOf(address(this)));
        }

        if (!toToken.isETH()) {
            ICompoundToken toCompound = _getCompoundToken(toToken);
            uint256 compoundAmount = _swapOnUniswap(fromToken, IERC20(toCompound), amount);
            toCompound.redeem(compoundAmount);
            return toToken.universalBalanceOf(address(this));
        }

        return 0;
    }

    function _swapOnUniswapChai(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns(uint256) {
        if (fromToken == dai) {
            _infiniteApproveIfNeeded(fromToken, address(chai));
            chai.join(address(this), amount);
            return _swapOnUniswap(IERC20(chai), toToken, IERC20(chai).universalBalanceOf(address(this)));
        }

        if (toToken == dai) {
            uint256 chaiAmount = _swapOnUniswap(fromToken, IERC20(chai), amount);
            chai.exit(address(this), chaiAmount);
            return toToken.universalBalanceOf(address(this));
        }

        return 0;
    }

    function _swapOnUniswapAave(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns(uint256) {
        if (!fromToken.isETH()) {
            IAaveToken fromAave = _getAaveToken(fromToken);
            _infiniteApproveIfNeeded(fromToken, aave.core());
            aave.deposit(fromToken, amount, 1101);
            return _swapOnUniswap(IERC20(fromAave), toToken, IERC20(fromAave).universalBalanceOf(address(this)));
        }

        if (!toToken.isETH()) {
            IAaveToken toAave = _getAaveToken(toToken);
            uint256 aaveAmount = _swapOnUniswap(fromToken, IERC20(toAave), amount);
            toAave.redeem(aaveAmount);
            return aaveAmount;
        }

        return 0;
    }

    function _swapOnMooniswap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns(uint256) {
        IMooniswap mooniswap = mooniswapRegistry.target();
        _infiniteApproveIfNeeded(fromToken, address(mooniswap));
        return mooniswap.swap.value(fromToken.isETH() ? amount : 0)(
            fromToken,
            toToken,
            amount,
            0
        );
    }

    function _swapOnKyber(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns(uint256) {
        _infiniteApproveIfNeeded(fromToken, address(kyberNetworkProxy));
        return kyberNetworkProxy.tradeWithHint.value(fromToken.isETH() ? amount : 0)(
            fromToken.isETH() ? ETH_ADDRESS : fromToken,
            amount,
            toToken.isETH() ? ETH_ADDRESS : toToken,
            address(this),
            1 << 255,
            0,
            0x4D37f28D2db99e8d35A6C725a5f1749A085850a3,
            ""
        );
    }

    function _swapOnBancor(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns(uint256) {
        if (fromToken.isETH()) {
            bancorEtherToken.deposit.value(amount)();
        }

        IBancorNetwork bancorNetwork = IBancorNetwork(bancorContractRegistry.addressOf("BancorNetwork"));
        address[] memory path = _buildBancorPath(fromToken, toToken);

        _infiniteApproveIfNeeded(fromToken.isETH() ? bancorEtherToken : fromToken, address(bancorNetwork));
        uint256 returnAmount = bancorNetwork.claimAndConvert(path, amount, 1);

        if (toToken.isETH()) {
            bancorEtherToken.withdraw(bancorEtherToken.balanceOf(address(this)));
        }

        return returnAmount;
    }

    function _swapOnOasis(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns(uint256) {
        if (fromToken.isETH()) {
            weth.deposit.value(amount)();
        }

        _infiniteApproveIfNeeded(fromToken.isETH() ? weth : fromToken, address(oasisExchange));
        uint256 returnAmount = oasisExchange.sellAllAmount(
            fromToken.isETH() ? weth : fromToken,
            amount,
            toToken.isETH() ? weth : toToken,
            1
        );

        if (toToken.isETH()) {
            weth.withdraw(weth.balanceOf(address(this)));
        }

        return returnAmount;
    }

    function _swapOnUniswapV2Internal(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns(uint256 returnAmount) {
        if (fromToken.isETH()) {
            weth.deposit.value(amount)();
        }

        IERC20 fromTokenReal = fromToken.isETH() ? weth : fromToken;
        IERC20 toTokenReal = toToken.isETH() ? weth : toToken;
        IUniswapV2Exchange exchange = uniswapV2.getPair(fromTokenReal, toTokenReal);
        returnAmount = exchange.getReturn(fromTokenReal, toTokenReal, amount);

        fromTokenReal.universalTransfer(address(exchange), amount);
        if (uint256(address(fromTokenReal)) < uint256(address(toTokenReal))) {
            exchange.swap(0, returnAmount, address(this), "");
        } else {
            exchange.swap(returnAmount, 0, address(this), "");
        }

        if (toToken.isETH()) {
            weth.withdraw(weth.balanceOf(address(this)));
        }
    }

    function _swapOnUniswapV2OverMid(
        IERC20 fromToken,
        IERC20 midToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns(uint256) {
        return _swapOnUniswapV2Internal(
            midToken,
            toToken,
            _swapOnUniswapV2Internal(
                fromToken,
                midToken,
                amount
            )
        );
    }

    function _swapOnUniswapV2(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns(uint256) {
        return _swapOnUniswapV2Internal(
            fromToken,
            toToken,
            amount
        );
    }

    function _swapOnUniswapV2ETH(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns(uint256) {
        return _swapOnUniswapV2OverMid(
            fromToken,
            weth,
            toToken,
            amount
        );
    }

    function _swapOnUniswapV2DAI(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns(uint256) {
        return _swapOnUniswapV2OverMid(
            fromToken,
            dai,
            toToken,
            amount
        );
    }

    function _swapOnUniswapV2USDC(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount
    ) internal returns(uint256) {
        return _swapOnUniswapV2OverMid(
            fromToken,
            usdc,
            toToken,
            amount
        );
    }
}

 

pragma solidity ^0.5.0;



contract OneSplitMultiPathBase is IOneSplitConsts, OneSplitRoot {
    function _getMultiPathToken(uint256 flags) internal pure returns(IERC20 midToken) {
        uint256[7] memory allFlags = [
            FLAG_ENABLE_MULTI_PATH_ETH,
            FLAG_ENABLE_MULTI_PATH_DAI,
            FLAG_ENABLE_MULTI_PATH_USDC,
            FLAG_ENABLE_MULTI_PATH_USDT,
            FLAG_ENABLE_MULTI_PATH_WBTC,
            FLAG_ENABLE_MULTI_PATH_TBTC,
            FLAG_ENABLE_MULTI_PATH_RENBTC
        ];

        IERC20[7] memory allMidTokens = [
            ETH_ADDRESS,
            dai,
            usdc,
            usdt,
            wbtc,
            tbtc,
            renbtc
        ];

        for (uint i = 0; i < allFlags.length; i++) {
            if (flags.check(allFlags[i])) {
                require(midToken == IERC20(0), "OneSplit: Do not use multipath with each other");
                midToken = allMidTokens[i];
            }
        }
    }
}


contract OneSplitMultiPathView is OneSplitViewWrapBase, OneSplitMultiPathBase {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        returns (
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        if (fromToken == toToken) {
            return (amount, new uint256[](DEXES_COUNT));
        }

        IERC20 midToken = _getMultiPathToken(flags);

        if (midToken != IERC20(0)) {
            if ((fromToken.isETH() && midToken.isETH()) ||
                (toToken.isETH() && midToken.isETH()) ||
                fromToken == midToken ||
                toToken == midToken)
            {
                super.getExpectedReturn(
                    fromToken,
                    toToken,
                    amount,
                    parts,
                    flags
                );
            }

            (returnAmount, distribution) = super.getExpectedReturn(
                fromToken,
                midToken,
                amount,
                parts,
                flags | FLAG_DISABLE_BANCOR | FLAG_DISABLE_CURVE_COMPOUND | FLAG_DISABLE_CURVE_USDT | FLAG_DISABLE_CURVE_Y | FLAG_DISABLE_CURVE_BINANCE | FLAG_DISABLE_CURVE_PAX
            );

            uint256[] memory dist;
            (returnAmount, dist) = super.getExpectedReturn(
                midToken,
                toToken,
                returnAmount,
                parts,
                flags | FLAG_DISABLE_BANCOR | FLAG_DISABLE_CURVE_COMPOUND | FLAG_DISABLE_CURVE_USDT | FLAG_DISABLE_CURVE_Y | FLAG_DISABLE_CURVE_BINANCE | FLAG_DISABLE_CURVE_PAX
            );
            for (uint i = 0; i < distribution.length; i++) {
                distribution[i] = distribution[i].add(dist[i] << 8);
            }
            return (returnAmount, distribution);
        }

        return super.getExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }
}


contract OneSplitMultiPath is OneSplitBaseWrap, OneSplitMultiPathBase {
    function _swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) internal {
        IERC20 midToken = _getMultiPathToken(flags);

        if (midToken != IERC20(0)) {
            uint256[] memory dist = new uint256[](distribution.length);
            for (uint i = 0; i < distribution.length; i++) {
                dist[i] = distribution[i] & 0xFF;
            }
            super._swap(
                fromToken,
                midToken,
                amount,
                dist,
                flags
            );

            for (uint i = 0; i < distribution.length; i++) {
                dist[i] = (distribution[i] >> 8) & 0xFF;
            }
            super._swap(
                midToken,
                toToken,
                midToken.universalBalanceOf(address(this)),
                dist,
                flags
            );
            return;
        }

        super._swap(
            fromToken,
            toToken,
            amount,
            distribution,
            flags
        );
    }
}

 

pragma solidity ^0.5.0;




contract OneSplitCompoundBase {
    function _getCompoundUnderlyingToken(IERC20 token) internal pure returns(IERC20) {
        if (token == IERC20(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5)) {  
            return IERC20(0);
        }
        if (token == IERC20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643)) {  
            return IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        }
        if (token == IERC20(0x6C8c6b02E7b2BE14d4fA6022Dfd6d75921D90E4E)) {  
            return IERC20(0x0D8775F648430679A709E98d2b0Cb6250d2887EF);
        }
        if (token == IERC20(0x158079Ee67Fce2f58472A96584A73C7Ab9AC95c1)) {  
            return IERC20(0x1985365e9f78359a9B6AD760e32412f4a445E862);
        }
        if (token == IERC20(0x39AA39c021dfbaE8faC545936693aC917d5E7563)) {  
            return IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        }
        if (token == IERC20(0xC11b1268C1A384e55C48c2391d8d480264A3A7F4)) {  
            return IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
        }
        if (token == IERC20(0xB3319f5D18Bc0D84dD1b4825Dcde5d5f7266d407)) {  
            return IERC20(0xE41d2489571d322189246DaFA5ebDe1F4699F498);
        }
        if (token == IERC20(0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9)) {  
            return IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        }

        return IERC20(-1);
    }
}


contract OneSplitCompoundView is OneSplitViewWrapBase, OneSplitCompoundBase {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        return _compoundGetExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }

    function _compoundGetExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        private
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        if (fromToken == toToken) {
            return (amount, new uint256[](DEXES_COUNT));
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_COMPOUND)) {
            IERC20 underlying = _getCompoundUnderlyingToken(fromToken);
            if (underlying != IERC20(-1)) {
                uint256 compoundRate = ICompoundToken(address(fromToken)).exchangeRateStored();

                return _compoundGetExpectedReturn(
                    underlying,
                    toToken,
                    amount.mul(compoundRate).div(1e18),
                    parts,
                    flags
                );
            }

            underlying = _getCompoundUnderlyingToken(toToken);
            if (underlying != IERC20(-1)) {
                uint256 compoundRate = ICompoundToken(address(toToken)).exchangeRateStored();

                (returnAmount, distribution) = super.getExpectedReturn(
                    fromToken,
                    underlying,
                    amount,
                    parts,
                    flags
                );

                returnAmount = returnAmount.mul(1e18).div(compoundRate);
                return (returnAmount, distribution);

            }
        }

        return super.getExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }
}


contract OneSplitCompound is OneSplitBaseWrap, OneSplitCompoundBase {
    function _swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) internal {
        _compundSwap(
            fromToken,
            toToken,
            amount,
            distribution,
            flags
        );
    }

    function _compundSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) private {
        if (fromToken == toToken) {
            return;
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_COMPOUND)) {
            IERC20 underlying = _getCompoundUnderlyingToken(fromToken);
            if (underlying != IERC20(-1)) {
                ICompoundToken(address(fromToken)).redeem(amount);
                uint256 underlyingAmount = underlying.universalBalanceOf(address(this));

                return _compundSwap(
                    underlying,
                    toToken,
                    underlyingAmount,
                    distribution,
                    flags
                );
            }

            underlying = _getCompoundUnderlyingToken(toToken);
            if (underlying != IERC20(-1)) {
                super._swap(
                    fromToken,
                    underlying,
                    amount,
                    distribution,
                    flags
                );

                uint256 underlyingAmount = underlying.universalBalanceOf(address(this));

                if (underlying.isETH()) {
                    cETH.mint.value(underlyingAmount)();
                } else {
                    _infiniteApproveIfNeeded(underlying, address(toToken));
                    ICompoundToken(address(toToken)).mint(underlyingAmount);
                }
                return;
            }
        }

        return super._swap(
            fromToken,
            toToken,
            amount,
            distribution,
            flags
        );
    }
}

 

pragma solidity ^0.5.0;


 
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

     
    function name() public view returns (string memory) {
        return _name;
    }

     
    function symbol() public view returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

 

pragma solidity ^0.5.0;



contract IFulcrumToken is IERC20 {
    function tokenPrice() external view returns (uint256);

    function loanTokenAddress() external view returns (address);

    function mintWithEther(address receiver) external payable returns (uint256 mintAmount);

    function mint(address receiver, uint256 depositAmount) external returns (uint256 mintAmount);

    function burnToEther(address receiver, uint256 burnAmount)
        external
        returns (uint256 loanAmountPaid);

    function burn(address receiver, uint256 burnAmount) external returns (uint256 loanAmountPaid);
}

 

pragma solidity ^0.5.0;





contract OneSplitFulcrumBase {
    using UniversalERC20 for IERC20;

    function _isFulcrumToken(IERC20 token) public view returns(IERC20) {
        if (token.isETH()) {
            return IERC20(-1);
        }

        (bool success, bytes memory data) = address(token).staticcall.gas(5000)(abi.encodeWithSelector(
            ERC20Detailed(address(token)).name.selector
        ));
        if (!success) {
            return IERC20(-1);
        }

        bool foundBZX = false;
        for (uint i = 0; i + 6 < data.length; i++) {
            if (data[i + 0] == "F" &&
                data[i + 1] == "u" &&
                data[i + 2] == "l" &&
                data[i + 3] == "c" &&
                data[i + 4] == "r" &&
                data[i + 5] == "u" &&
                data[i + 6] == "m")
            {
                foundBZX = true;
                break;
            }
        }
        if (!foundBZX) {
            return IERC20(-1);
        }

        (success, data) = address(token).staticcall.gas(5000)(abi.encodeWithSelector(
            IFulcrumToken(address(token)).loanTokenAddress.selector
        ));
        if (!success) {
            return IERC20(-1);
        }

        return abi.decode(data, (IERC20));
    }
}


contract OneSplitFulcrumView is OneSplitViewWrapBase, OneSplitFulcrumBase {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        return _fulcrumGetExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }

    function _fulcrumGetExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        private
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        if (fromToken == toToken) {
            return (amount, new uint256[](DEXES_COUNT));
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_FULCRUM)) {
            IERC20 underlying = _isFulcrumToken(fromToken);
            if (underlying != IERC20(-1)) {
                uint256 fulcrumRate = IFulcrumToken(address(fromToken)).tokenPrice();

                return _fulcrumGetExpectedReturn(
                    underlying,
                    toToken,
                    amount.mul(fulcrumRate).div(1e18),
                    parts,
                    flags
                );
            }

            underlying = _isFulcrumToken(toToken);
            if (underlying != IERC20(-1)) {
                uint256 fulcrumRate = IFulcrumToken(address(toToken)).tokenPrice();

                (returnAmount, distribution) = super.getExpectedReturn(
                    fromToken,
                    underlying,
                    amount,
                    parts,
                    flags
                );

                returnAmount = returnAmount.mul(1e18).div(fulcrumRate);
                return (returnAmount, distribution);
            }
        }

        return super.getExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }
}


contract OneSplitFulcrum is OneSplitBaseWrap, OneSplitFulcrumBase {
    function _swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) internal {
        _fulcrumSwap(
            fromToken,
            toToken,
            amount,
            distribution,
            flags
        );
    }

    function _fulcrumSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) private {
        if (fromToken == toToken) {
            return;
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_FULCRUM)) {
            IERC20 underlying = _isFulcrumToken(fromToken);
            if (underlying != IERC20(-1)) {
                if (underlying.isETH()) {
                    IFulcrumToken(address(fromToken)).burnToEther(address(this), amount);
                } else {
                    IFulcrumToken(address(fromToken)).burn(address(this), amount);
                }

                uint256 underlyingAmount = underlying.universalBalanceOf(address(this));

                return super._swap(
                    underlying,
                    toToken,
                    underlyingAmount,
                    distribution,
                    flags
                );
            }

            underlying = _isFulcrumToken(toToken);
            if (underlying != IERC20(-1)) {
                super._swap(
                    fromToken,
                    underlying,
                    amount,
                    distribution,
                    flags
                );

                uint256 underlyingAmount = underlying.universalBalanceOf(address(this));

                if (underlying.isETH()) {
                    IFulcrumToken(address(toToken)).mintWithEther.value(underlyingAmount)(address(this));
                } else {
                    _infiniteApproveIfNeeded(underlying, address(toToken));
                    IFulcrumToken(address(toToken)).mint(address(this), underlyingAmount);
                }
                return;
            }
        }

        return super._swap(
            fromToken,
            toToken,
            amount,
            distribution,
            flags
        );
    }
}

 

pragma solidity ^0.5.0;




contract OneSplitChaiView is OneSplitViewWrapBase {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        if (fromToken == toToken) {
            return (amount, new uint256[](DEXES_COUNT));
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_CHAI)) {
            if (fromToken == IERC20(chai)) {
                return super.getExpectedReturn(
                    dai,
                    toToken,
                    chai.chaiToDai(amount),
                    parts,
                    flags
                );
            }

            if (toToken == IERC20(chai)) {
                (returnAmount, distribution) = super.getExpectedReturn(
                    fromToken,
                    dai,
                    amount,
                    parts,
                    flags
                );
                return (chai.daiToChai(returnAmount), distribution);
            }
        }

        return super.getExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }
}


contract OneSplitChai is OneSplitBaseWrap {
    function _swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) internal {
        if (fromToken == toToken) {
            return;
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_CHAI)) {
            if (fromToken == IERC20(chai)) {
                chai.exit(address(this), amount);

                return super._swap(
                    dai,
                    toToken,
                    dai.balanceOf(address(this)),
                    distribution,
                    flags
                );
            }

            if (toToken == IERC20(chai)) {
                super._swap(
                    fromToken,
                    dai,
                    amount,
                    distribution,
                    flags
                );

                _infiniteApproveIfNeeded(dai, address(chai));
                chai.join(address(this), dai.balanceOf(address(this)));
                return;
            }
        }

        return super._swap(
            fromToken,
            toToken,
            amount,
            distribution,
            flags
        );
    }
}

 

pragma solidity ^0.5.0;



contract IBdai is IERC20 {
    function join(uint256) external;

    function exit(uint256) external;
}

 

pragma solidity ^0.5.0;




contract OneSplitBdaiBase {
    IBdai public bdai = IBdai(0x6a4FFAafa8DD400676Df8076AD6c724867b0e2e8);
    IERC20 public btu = IERC20(0xb683D83a532e2Cb7DFa5275eED3698436371cc9f);
}


contract OneSplitBdaiView is OneSplitViewWrapBase, OneSplitBdaiBase {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        returns (uint256 returnAmount, uint256[] memory distribution)
    {
        if (fromToken == toToken) {
            return (amount, new uint256[](DEXES_COUNT));
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_BDAI)) {
            if (fromToken == IERC20(bdai)) {
                return super.getExpectedReturn(
                    dai,
                    toToken,
                    amount,
                    parts,
                    flags
                );
            }

            if (toToken == IERC20(bdai)) {
                return super.getExpectedReturn(
                    fromToken,
                    dai,
                    amount,
                    parts,
                    flags
                );
            }
        }

        return super.getExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }
}


contract OneSplitBdai is OneSplitBaseWrap, OneSplitBdaiBase {
    function _swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) internal {
        if (fromToken == toToken) {
            return;
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_BDAI)) {
            if (fromToken == IERC20(bdai)) {
                bdai.exit(amount);

                uint256 btuBalance = btu.balanceOf(address(this));
                if (btuBalance > 0) {
                    (,uint256[] memory btuDistribution) = getExpectedReturn(
                        btu,
                        toToken,
                        btuBalance,
                        1,
                        flags
                    );

                    _swap(
                        btu,
                        toToken,
                        btuBalance,
                        btuDistribution,
                        flags
                    );
                }

                return super._swap(
                    dai,
                    toToken,
                    amount,
                    distribution,
                    flags
                );
            }

            if (toToken == IERC20(bdai)) {
                super._swap(fromToken, dai, amount, distribution, flags);

                _infiniteApproveIfNeeded(dai, address(bdai));
                bdai.join(dai.balanceOf(address(this)));
                return;
            }
        }

        return super._swap(fromToken, toToken, amount, distribution, flags);
    }
}

 

pragma solidity ^0.5.0;



contract IIearn is IERC20 {
    function token() external view returns(IERC20);

    function calcPoolValueInToken() external view returns(uint256);

    function deposit(uint256 _amount) external;

    function withdraw(uint256 _shares) external;
}

 

pragma solidity ^0.5.0;




contract OneSplitIearnBase {
    function _yTokens() internal pure returns(IIearn[13] memory) {
        return [
            IIearn(0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01),
            IIearn(0x04Aa51bbcB46541455cCF1B8bef2ebc5d3787EC9),
            IIearn(0x73a052500105205d34Daf004eAb301916DA8190f),
            IIearn(0x83f798e925BcD4017Eb265844FDDAbb448f1707D),
            IIearn(0xd6aD7a6750A7593E092a9B218d66C0A814a3436e),
            IIearn(0xF61718057901F84C4eEC4339EF8f0D86D2B45600),
            IIearn(0x04bC0Ab673d88aE9dbC9DA2380cB6B79C4BCa9aE),
            IIearn(0xC2cB1040220768554cf699b0d863A3cd4324ce32),
            IIearn(0xE6354ed5bC4b393a5Aad09f21c46E101e692d447),
            IIearn(0x26EA744E5B887E5205727f55dFBE8685e3b21951),
            IIearn(0x99d1Fa417f94dcD62BfE781a1213c092a47041Bc),
            IIearn(0x9777d7E2b60bB01759D0E2f8be2095df444cb07E),
            IIearn(0x1bE5d71F2dA660BFdee8012dDc58D024448A0A59)
        ];
    }
}


contract OneSplitIearnView is OneSplitViewWrapBase, OneSplitIearnBase {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        returns (uint256 returnAmount, uint256[] memory distribution)
    {
        return _iearnGetExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }

    function _iearnGetExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        private
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        if (fromToken == toToken) {
            return (amount, new uint256[](DEXES_COUNT));
        }

        if (!flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == !flags.check(FLAG_DISABLE_IEARN)) {
            IIearn[13] memory yTokens = _yTokens();

            for (uint i = 0; i < yTokens.length; i++) {
                if (fromToken == IERC20(yTokens[i])) {
                    return _iearnGetExpectedReturn(
                        yTokens[i].token(),
                        toToken,
                        amount
                            .mul(yTokens[i].calcPoolValueInToken())
                            .div(yTokens[i].totalSupply()),
                        parts,
                        flags
                    );
                }
            }

            for (uint i = 0; i < yTokens.length; i++) {
                if (toToken == IERC20(yTokens[i])) {
                    (uint256 ret, uint256[] memory dist) = super.getExpectedReturn(
                        fromToken,
                        yTokens[i].token(),
                        amount,
                        parts,
                        flags
                    );

                    return (
                        ret
                            .mul(yTokens[i].totalSupply())
                            .div(yTokens[i].calcPoolValueInToken()),
                        dist
                    );
                }
            }
        }

        return super.getExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }
}


contract OneSplitIearn is OneSplitBaseWrap, OneSplitIearnBase {
    function _swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) internal {
        _iearnSwap(
            fromToken,
            toToken,
            amount,
            distribution,
            flags
        );
    }

    function _iearnSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) private {
        if (fromToken == toToken) {
            return;
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_IEARN)) {
            IIearn[13] memory yTokens = _yTokens();

            for (uint i = 0; i < yTokens.length; i++) {
                if (fromToken == IERC20(yTokens[i])) {
                    IERC20 underlying = yTokens[i].token();
                    yTokens[i].withdraw(amount);
                    _iearnSwap(underlying, toToken, underlying.balanceOf(address(this)), distribution, flags);
                    return;
                }
            }

            for (uint i = 0; i < yTokens.length; i++) {
                if (toToken == IERC20(yTokens[i])) {
                    IERC20 underlying = yTokens[i].token();
                    super._swap(fromToken, underlying, amount, distribution, flags);
                    _infiniteApproveIfNeeded(underlying, address(yTokens[i]));
                    yTokens[i].deposit(underlying.balanceOf(address(this)));
                    return;
                }
            }
        }

        return super._swap(fromToken, toToken, amount, distribution, flags);
    }
}

 

pragma solidity ^0.5.0;



contract IIdle is IERC20 {
    function token()
        external view returns (IERC20);

    function tokenPrice()
        external view returns (uint256);

    function mintIdleToken(uint256 _amount, uint256[] calldata _clientProtocolAmounts)
        external returns (uint256 mintedTokens);

    function redeemIdleToken(uint256 _amount, bool _skipRebalance, uint256[] calldata _clientProtocolAmounts)
        external returns (uint256 redeemedTokens);
}

 

pragma solidity ^0.5.0;




contract OneSplitIdleBase {
    function _idleTokens() internal pure returns(IIdle[2] memory) {
        return [
            IIdle(0x10eC0D497824e342bCB0EDcE00959142aAa766dD),
            IIdle(0xeB66ACc3d011056B00ea521F8203580C2E5d3991)
        ];
    }
}


contract OneSplitIdleView is OneSplitViewWrapBase, OneSplitIdleBase {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        returns (uint256  , uint256[] memory  )
    {
        return _idleGetExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }

    function _idleGetExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        internal
        view
        returns (uint256 returnAmount, uint256[] memory distribution)
    {
        if (fromToken == toToken) {
            return (amount, new uint256[](DEXES_COUNT));
        }

        if (!flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == !flags.check(FLAG_DISABLE_IDLE)) {
            IIdle[2] memory tokens = _idleTokens();

            for (uint i = 0; i < tokens.length; i++) {
                if (fromToken == IERC20(tokens[i])) {
                    return _idleGetExpectedReturn(
                        tokens[i].token(),
                        toToken,
                        amount.mul(tokens[i].tokenPrice()).div(1e18),
                        parts,
                        flags
                    );
                }
            }

            for (uint i = 0; i < tokens.length; i++) {
                if (toToken == IERC20(tokens[i])) {
                    (uint256 ret, uint256[] memory dist) = super.getExpectedReturn(
                        fromToken,
                        tokens[i].token(),
                        amount,
                        parts,
                        flags
                    );

                    return (
                        ret.mul(1e18).div(tokens[i].tokenPrice()),
                        dist
                    );
                }
            }
        }

        return super.getExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }
}


contract OneSplitIdle is OneSplitBaseWrap, OneSplitIdleBase {
    function _superOneSplitIdleSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] calldata distribution,
        uint256 flags
    )
        external
    {
        require(msg.sender == address(this));
        return super._swap(fromToken, toToken, amount, distribution, flags);
    }

    function _swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) internal {
        _idleSwap(
            fromToken,
            toToken,
            amount,
            distribution,
            flags
        );
    }

    function _idleSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) public payable {
        if (!flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == !flags.check(FLAG_DISABLE_IDLE)) {
            IIdle[2] memory tokens = _idleTokens();

            for (uint i = 0; i < tokens.length; i++) {
                if (fromToken == IERC20(tokens[i])) {
                    IERC20 underlying = tokens[i].token();
                    uint256 minted = tokens[i].redeemIdleToken(amount, true, new uint256[](0));
                    _idleSwap(underlying, toToken, minted, distribution, flags);
                    return;
                }
            }

            for (uint i = 0; i < tokens.length; i++) {
                if (toToken == IERC20(tokens[i])) {
                    IERC20 underlying = tokens[i].token();
                    super._swap(fromToken, underlying, amount, distribution, flags);
                    _infiniteApproveIfNeeded(underlying, address(tokens[i]));
                    tokens[i].mintIdleToken(underlying.balanceOf(address(this)), new uint256[](0));
                    return;
                }
            }
        }

        return super._swap(fromToken, toToken, amount, distribution, flags);
    }
}

 

pragma solidity ^0.5.0;





contract OneSplitAaveBase {
    function _getAaveUnderlyingToken(IERC20 token) internal pure returns(IERC20) {
        if (token == IERC20(0x3a3A65aAb0dd2A17E3F1947bA16138cd37d08c04)) {  
            return IERC20(0);
        }
        if (token == IERC20(0xfC1E690f61EFd961294b3e1Ce3313fBD8aa4f85d)) {  
            return IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        }
        if (token == IERC20(0x9bA00D6856a4eDF4665BcA2C2309936572473B7E)) {  
            return IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        }
        if (token == IERC20(0x625aE63000f46200499120B906716420bd059240)) {  
            return IERC20(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51);
        }
        if (token == IERC20(0x6Ee0f7BB50a54AB5253dA0667B0Dc2ee526C30a8)) {  
            return IERC20(0x4Fabb145d64652a948d72533023f6E7A623C7C53);
        }
        if (token == IERC20(0x4DA9b813057D04BAef4e5800E36083717b4a0341)) {  
            return IERC20(0x0000000000085d4780B73119b644AE5ecd22b376);
        }
        if (token == IERC20(0x71fc860F7D3A592A4a98740e39dB31d25db65ae8)) {  
            return IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        }
        if (token == IERC20(0xE1BA0FB44CCb0D11b80F92f4f8Ed94CA3fF51D00)) {  
            return IERC20(0x0D8775F648430679A709E98d2b0Cb6250d2887EF);
        }
        if (token == IERC20(0x9D91BE44C06d373a8a226E1f3b146956083803eB)) {  
            return IERC20(0xdd974D5C2e2928deA5F71b9825b8b646686BD200);
        }
        if (token == IERC20(0x7D2D3688Df45Ce7C552E19c27e007673da9204B8)) {  
            return IERC20(0x80fB784B7eD66730e8b1DBd9820aFD29931aab03);
        }
        if (token == IERC20(0xA64BD6C70Cb9051F6A9ba1F163Fdc07E0DfB5F84)) {  
            return IERC20(0x514910771AF9Ca656af840dff83E8264EcF986CA);
        }
        if (token == IERC20(0x6FCE4A401B6B80ACe52baAefE4421Bd188e76F6f)) {  
            return IERC20(0x0F5D2fB29fb7d3CFeE444a200298f468908cC942);
        }
        if (token == IERC20(0x7deB5e830be29F91E298ba5FF1356BB7f8146998)) {  
            return IERC20(0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2);
        }
        if (token == IERC20(0x71010A9D003445aC60C4e6A7017c1E89A477B438)) {  
            return IERC20(0x1985365e9f78359a9B6AD760e32412f4a445E862);
        }
        if (token == IERC20(0x328C4c80BC7aCa0834Db37e6600A6c49E12Da4DE)) {  
            return IERC20(0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F);
        }
        if (token == IERC20(0xFC4B8ED459e00e5400be803A9BB3954234FD50e3)) {  
            return IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
        }
        if (token == IERC20(0x6Fb0855c404E09c47C3fBCA25f08d4E41f9F062f)) {  
            return IERC20(0xE41d2489571d322189246DaFA5ebDe1F4699F498);
        }

        return IERC20(-1);
    }
}


contract OneSplitAaveView is OneSplitViewWrapBase, OneSplitAaveBase {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        return _aaveGetExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }

    function _aaveGetExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        private
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        if (fromToken == toToken) {
            return (amount, distribution);
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_AAVE)) {
            IERC20 underlying = _getAaveUnderlyingToken(fromToken);
            if (underlying != IERC20(-1)) {
                return _aaveGetExpectedReturn(
                    underlying,
                    toToken,
                    amount,
                    parts,
                    flags
                );
            }

            underlying = _getAaveUnderlyingToken(toToken);
            if (underlying != IERC20(-1)) {
                return super.getExpectedReturn(
                    fromToken,
                    underlying,
                    amount,
                    parts,
                    flags
                );
            }
        }

        return super.getExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }
}


contract OneSplitAave is OneSplitBaseWrap, OneSplitAaveBase {
    function _swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) internal {
        _aaveSwap(
            fromToken,
            toToken,
            amount,
            distribution,
            flags
        );
    }

    function _aaveSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) private {
        if (fromToken == toToken) {
            return;
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_AAVE)) {
            IERC20 underlying = _getAaveUnderlyingToken(fromToken);
            if (underlying != IERC20(-1)) {
                IAaveToken(address(fromToken)).redeem(amount);

                return _aaveSwap(
                    underlying,
                    toToken,
                    amount,
                    distribution,
                    flags
                );
            }

            underlying = _getAaveUnderlyingToken(toToken);
            if (underlying != IERC20(-1)) {
                super._swap(
                    fromToken,
                    underlying,
                    amount,
                    distribution,
                    flags
                );

                uint256 underlyingAmount = underlying.universalBalanceOf(address(this));

                _infiniteApproveIfNeeded(underlying, aave.core());
                aave.deposit.value(underlying.isETH() ? underlyingAmount : 0)(
                    underlying.isETH() ? ETH_ADDRESS : underlying,
                    underlyingAmount,
                    1101
                );
                return;
            }
        }

        return super._swap(
            fromToken,
            toToken,
            amount,
            distribution,
            flags
        );
    }
}

 

pragma solidity ^0.5.0;




contract OneSplitWethView is OneSplitViewWrapBase {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        return _wethGetExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }

    function _wethGetExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        private
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        if (fromToken == toToken) {
            return (amount, new uint256[](DEXES_COUNT));
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_WETH)) {
            if (fromToken == weth || fromToken == bancorEtherToken) {
                return super.getExpectedReturn(ETH_ADDRESS, toToken, amount, parts, flags);
            }

            if (toToken == weth || toToken == bancorEtherToken) {
                return super.getExpectedReturn(fromToken, ETH_ADDRESS, amount, parts, flags);
            }
        }

        return super.getExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }
}


contract OneSplitWeth is OneSplitBaseWrap {
    function _swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) internal {
        _wethSwap(
            fromToken,
            toToken,
            amount,
            distribution,
            flags
        );
    }

    function _wethSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) private {
        if (fromToken == toToken) {
            return;
        }

        if (flags.check(FLAG_DISABLE_ALL_WRAP_SOURCES) == flags.check(FLAG_DISABLE_WETH)) {
            if (fromToken == weth) {
                weth.withdraw(weth.balanceOf(address(this)));
                super._swap(
                    ETH_ADDRESS,
                    toToken,
                    amount,
                    distribution,
                    flags
                );
                return;
            }

            if (fromToken == bancorEtherToken) {
                bancorEtherToken.withdraw(bancorEtherToken.balanceOf(address(this)));
                super._swap(
                    ETH_ADDRESS,
                    toToken,
                    amount,
                    distribution,
                    flags
                );
                return;
            }

            if (toToken == weth) {
                _wethSwap(
                    fromToken,
                    ETH_ADDRESS,
                    amount,
                    distribution,
                    flags
                );
                weth.deposit.value(address(this).balance)();
                return;
            }

            if (toToken == bancorEtherToken) {
                _wethSwap(
                    fromToken,
                    ETH_ADDRESS,
                    amount,
                    distribution,
                    flags
                );
                bancorEtherToken.deposit.value(address(this).balance)();
                return;
            }
        }

        return super._swap(
            fromToken,
            toToken,
            amount,
            distribution,
            flags
        );
    }
}

 

pragma solidity ^0.5.0;











 


contract OneSplitViewWrap is
    OneSplitViewWrapBase,
    OneSplitMultiPathView,
    OneSplitChaiView,
    OneSplitBdaiView,
    OneSplitAaveView,
    OneSplitFulcrumView,
    OneSplitCompoundView,
    OneSplitIearnView,
    OneSplitIdleView,
    OneSplitWethView
     
{
    IOneSplitView public oneSplitView;

    constructor(IOneSplitView _oneSplit) public {
        oneSplitView = _oneSplit;
    }

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        if (fromToken == toToken) {
            return (amount, new uint256[](DEXES_COUNT));
        }

        return super.getExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }

    function _getExpectedReturnFloor(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        internal
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        )
    {
        return oneSplitView.getExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }
}


contract OneSplitWrap is
    OneSplitBaseWrap,
    OneSplitMultiPath,
    OneSplitChai,
    OneSplitBdai,
    OneSplitAave,
    OneSplitFulcrum,
    OneSplitCompound,
    OneSplitIearn,
    OneSplitIdle,
    OneSplitWeth
     
{
    IOneSplitView public oneSplitView;
    IOneSplit public oneSplit;

    constructor(IOneSplitView _oneSplitView, IOneSplit _oneSplit) public {
        oneSplitView = _oneSplitView;
        oneSplit = _oneSplit;
    }

    function() external payable {
         
        require(msg.sender != tx.origin);
    }

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 flags  
    )
        public
        view
        returns(
            uint256  ,
            uint256[] memory  
        )
    {
        return oneSplitView.getExpectedReturn(
            fromToken,
            toToken,
            amount,
            parts,
            flags
        );
    }

    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,  
        uint256 flags  
    ) public payable {
        fromToken.universalTransferFrom(msg.sender, address(this), amount);
        uint256 confirmed = fromToken.universalBalanceOf(address(this));
        _swap(fromToken, toToken, confirmed, distribution, flags);

        uint256 returnAmount = toToken.universalBalanceOf(address(this));
        require(returnAmount >= minReturn, "OneSplit: actual return amount is less than minReturn");
        toToken.universalTransfer(msg.sender, returnAmount);
        fromToken.universalTransfer(msg.sender, fromToken.universalBalanceOf(address(this)));
    }

    function _swapFloor(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256[] memory distribution,
        uint256 flags
    ) internal {
        (bool success, bytes memory data) = address(oneSplit).delegatecall(
            abi.encodeWithSelector(
                this.swap.selector,
                fromToken,
                toToken,
                amount,
                0,
                distribution,
                flags
            )
        );

        assembly {
            switch success
                 
                case 0 { revert(add(data, 32), returndatasize) }
        }
    }
}