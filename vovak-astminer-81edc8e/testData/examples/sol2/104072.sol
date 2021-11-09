 

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

 

pragma solidity 0.5.16;

interface Gauge {
    function deposit(uint) external;
    function balanceOf(address) external view returns (uint);
    function withdraw(uint) external;
    function user_checkpoint(address) external;
}

interface VotingEscrow {
    function create_lock(uint256 v, uint256 time) external;
    function increase_amount(uint256 _value) external;
    function increase_unlock_time(uint256 _unlock_time) external;
    function withdraw() external;
}

interface Mintr {
    function mint(address) external;
}

 

pragma solidity 0.5.16;

interface ICurveFiWbtc {
  function get_virtual_price() external view returns (uint);
  function add_liquidity(
    uint256[2] calldata amounts,
    uint256 min_mint_amount
  ) external;
  function remove_liquidity_imbalance(
    uint256[2] calldata amounts,
    uint256 max_burn_amount
  ) external;
  function remove_liquidity(
    uint256 _amount,
    uint256[2] calldata amounts
  ) external;
  function exchange(
    int128 from, int128 to, uint256 _from_amount, uint256 _min_to_amount
  ) external;
  function calc_token_amount(
    uint256[2] calldata amounts,
    bool deposit
  ) external view returns(uint);
  function calc_withdraw_one_coin(
    uint256 _token_amount, int128 i) external view returns (uint256);
  function remove_liquidity_one_coin(uint256 _token_amount, int128 i,
    uint256 min_amount) external;
}

 

pragma solidity 0.5.16;

interface yERC20 {
  function deposit(uint256 _amount) external;
  function withdraw(uint256 _amount) external;
  function getPricePerFullShare() external view returns (uint256);
}

 

pragma solidity 0.5.16;

interface IPriceConvertor {
  function yCrvToUnderlying(uint256 _token_amount, uint256 i) external view returns (uint256);
}

 

pragma solidity 0.5.16;

interface IController {
     
     
     
     
     
     
     
     
     
     
    function greyList(address _target) external returns(bool);

    function addVaultAndStrategy(address _vault, address _strategy) external;
    function doHardWork(address _vault) external;
    function hasVault(address _vault) external returns(bool);

    function salvage(address _token, uint256 amount) external;
    function salvageStrategy(address _strategy, address _token, uint256 amount) external;

    function notifyFee(address _underlying, uint256 fee) external;
    function profitSharingNumerator() external view returns (uint256);
    function profitSharingDenominator() external view returns (uint256);
}

 

pragma solidity 0.5.16;

contract Storage {

  address public governance;
  address public controller;

  constructor() public {
    governance = msg.sender;
  }

  modifier onlyGovernance() {
    require(isGovernance(msg.sender), "Not governance");
    _;
  }

  function setGovernance(address _governance) public onlyGovernance {
    require(_governance != address(0), "new governance shouldn't be empty");
    governance = _governance;
  }

  function setController(address _controller) public onlyGovernance {
    require(_controller != address(0), "new controller shouldn't be empty");
    controller = _controller;
  }

  function isGovernance(address account) public view returns (bool) {
    return account == governance;
  }

  function isController(address account) public view returns (bool) {
    return account == controller;
  }
}

 

pragma solidity 0.5.16;


contract Governable {

  Storage public store;

  constructor(address _store) public {
    require(_store != address(0), "new storage shouldn't be empty");
    store = Storage(_store);
  }

  modifier onlyGovernance() {
    require(store.isGovernance(msg.sender), "Not governance");
    _;
  }

  function setStorage(address _store) public onlyGovernance {
    require(_store != address(0), "new storage shouldn't be empty");
    store = Storage(_store);
  }

  function governance() public view returns (address) {
    return store.governance();
  }
}

 

pragma solidity 0.5.16;


contract Controllable is Governable {

  constructor(address _storage) Governable(_storage) public {
  }

  modifier onlyController() {
    require(store.isController(msg.sender), "Not a controller");
    _;
  }

  modifier onlyControllerOrGovernance(){
    require((store.isController(msg.sender) || store.isGovernance(msg.sender)),
      "The caller must be controller or governance");
    _;
  }

  function controller() public view returns (address) {
    return store.controller();
  }
}

 

pragma solidity 0.5.16;






contract ProfitNotifier is Controllable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint256 public profitSharingNumerator;
  uint256 public profitSharingDenominator;
  address public underlying;

  event ProfitLog(
    uint256 oldBalance,
    uint256 newBalance,
    uint256 feeAmount,
    uint256 timestamp
  );

  constructor(
    address _storage,
    address _underlying
  ) public Controllable(_storage){
    underlying = _underlying;
     
    profitSharingNumerator = 30;  
    profitSharingDenominator = 100;  
    require(profitSharingNumerator < profitSharingDenominator, "invalid profit share");
  }

  function notifyProfit(uint256 oldBalance, uint256 newBalance) internal {
    if (newBalance > oldBalance) {
      uint256 profit = newBalance.sub(oldBalance);
      uint256 feeAmount = profit.mul(profitSharingNumerator).div(profitSharingDenominator);
      emit ProfitLog(oldBalance, newBalance, feeAmount, block.timestamp);

      IERC20(underlying).safeApprove(controller(), 0);
      IERC20(underlying).safeApprove(controller(), feeAmount);
      IController(controller()).notifyFee(
        underlying,
        feeAmount
      );
    } else {
      emit ProfitLog(oldBalance, newBalance, 0, block.timestamp);
    }
  }
}

 

pragma solidity 0.5.16;


interface IVault {
     

    function underlyingBalanceInVault() external view returns (uint256);
    function underlyingBalanceWithInvestment() external view returns (uint256);

    function governance() external view returns (address);
    function controller() external view returns (address);
    function underlying() external view returns (address);
    function strategy() external view returns (address);

    function setStrategy(address _strategy) external;
    function setVaultFractionToInvest(uint256 numerator, uint256 denominator) external;

    function deposit(uint256 amountWei) external;
    function depositFor(uint256 amountWei, address holder) external;

    function withdrawAll() external;
    function withdraw(uint256 numberOfShares) external;
    function getPricePerFullShare() external view returns (uint256);

    function underlyingBalanceWithInvestmentForHolder(address holder) view external returns (uint256);

     
    function doHardWork() external;
    function rebalance() external;
}

 

pragma solidity 0.5.16;


interface IStrategy {
    
    function unsalvagableTokens(address tokens) external view returns (bool);
    
    function governance() external view returns (address);
    function controller() external view returns (address);
    function underlying() external view returns (address);
    function vault() external view returns (address);

    function withdrawAllToVault() external;
    function withdrawToVault(uint256 amount) external;

    function investedUnderlyingBalance() external view returns (uint256);  

     
    function salvage(address recipient, address token, uint256 amount) external;

    function doHardWork() external;
    function depositArbCheck() external view returns(bool);
}

 

pragma solidity >=0.5.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

 

pragma solidity >=0.5.0;


interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

 

pragma solidity 0.5.16;


















contract CRVStrategyWRenBTC is IStrategy, ProfitNotifier {

  enum TokenIndex {REN_BTC, WBTC}

  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

   
  address public wbtc;

   
  TokenIndex tokenIndex;

   
  address public vault;

   
  address public mixToken;

   
  address public curve;

   
  mapping(address => bool) public unsalvagableTokens;

   
  address public gauge;

   
  address public mintr;

   
  address public crv;

   
  address public uni;

   
  uint256 public wbtcPriceCheckpoint;

   
  uint256 public mixTokenUnit;

   
  uint256 public arbTolerance = 3;

   
  address[] public uniswap_CRV2WBTC;

   
  bool public sell = true;

   
  uint256 public sellFloor = 30e18;

  event Liquidating(uint256 amount);
  event ProfitsNotCollected();


  modifier restricted() {
    require(msg.sender == vault || msg.sender == controller()
      || msg.sender == governance(),
      "The sender has to be the controller, governance, or vault");
    _;
  }

  constructor(
    address _storage,
    address _wbtc,
    address _vault,
    uint256 _tokenIndex,
    address _mixToken,
    address _curvePool,
    address _crv,
    address _weth,
    address _gauge,
    address _mintr,
    address _uniswap
  )
  ProfitNotifier(_storage, _wbtc) public {
    vault = _vault;
    wbtc = _wbtc;
    tokenIndex = TokenIndex(_tokenIndex);
    mixToken = _mixToken;
    curve = _curvePool;
    gauge = _gauge;
    crv = _crv;
    uni = _uniswap;
    mintr = _mintr;

    uniswap_CRV2WBTC = [_crv, _weth, _wbtc];

     
    unsalvagableTokens[wbtc] = true;
    unsalvagableTokens[mixToken] = true;
    unsalvagableTokens[crv] = true;

    mixTokenUnit = 10 ** 18;
    
     
    wbtcPriceCheckpoint = mixTokenUnit;
  }

  function depositArbCheck() public view returns(bool) {
    uint256 currentPrice = wbtcValueFromMixToken(mixTokenUnit);
    if (currentPrice > wbtcPriceCheckpoint) {
      return currentPrice.mul(100).div(wbtcPriceCheckpoint) > 100 - arbTolerance;
    } else {
      return wbtcPriceCheckpoint.mul(100).div(currentPrice) > 100 - arbTolerance;
    }
  }

  function setArbTolerance(uint256 tolerance) external onlyGovernance {
    require(tolerance <= 100, "at most 100");
    arbTolerance = tolerance;
  }

   
  function mixFromWBTC() internal {
    uint256 wbtcBalance = IERC20(wbtc).balanceOf(address(this));
    if (wbtcBalance > 0) {
      IERC20(wbtc).safeApprove(curve, 0);
      IERC20(wbtc).safeApprove(curve, wbtcBalance);
       
      uint256 minimum = 0;
      uint256[2] memory coinAmounts = wrapCoinAmount(wbtcBalance);
      ICurveFiWbtc(curve).add_liquidity(
        coinAmounts, minimum
      );
    }
     
  }

   
  function mixToWBTC(uint256 wbtcLimit) internal {
    uint256 mixTokenBalance = IERC20(mixToken).balanceOf(address(this));

     
    uint256 wbtcMaximumAmount = wbtcValueFromMixToken(mixTokenBalance);
    if (wbtcMaximumAmount == 0) {
      return;
    }

    if (wbtcLimit < wbtcMaximumAmount) {
       
       
      uint256[2] memory tokenAmounts = wrapCoinAmount(wbtcLimit);
      IERC20(mixToken).safeApprove(curve, 0);
      IERC20(mixToken).safeApprove(curve, mixTokenBalance);
      ICurveFiWbtc(curve).remove_liquidity_imbalance(
        tokenAmounts, mixTokenBalance
      );
    } else {
       
      IERC20(mixToken).safeApprove(curve, 0);
      IERC20(mixToken).safeApprove(curve, mixTokenBalance);
      ICurveFiWbtc(curve).remove_liquidity_one_coin(mixTokenBalance, int128(tokenIndex), 0);
    }
     
  }

   
  function withdrawToVault(uint256 amountWbtc) external restricted {
     
    Gauge(gauge).withdraw(Gauge(gauge).balanceOf(address(this)));
     
    mixToWBTC(amountWbtc);
     
    uint256 actualBalance = IERC20(wbtc).balanceOf(address(this));
    if (actualBalance > 0) {
      IERC20(wbtc).safeTransfer(vault, Math.min(amountWbtc, actualBalance));
    }

     
    investAllUnderlying();
  }

   
  function withdrawAllToVault() external restricted {
     
    Gauge(gauge).withdraw(Gauge(gauge).balanceOf(address(this)));
     
    mixToWBTC(uint256(~0));
     
    uint256 actualBalance = IERC20(wbtc).balanceOf(address(this));
    if (actualBalance > 0) {
      IERC20(wbtc).safeTransfer(vault, actualBalance);
    }
  }

   
  function investAllUnderlying() internal {
     
    mixFromWBTC();

     
    uint256 mixTokenBalance = IERC20(mixToken).balanceOf(address(this));
    if (mixTokenBalance > 0) {
      IERC20(mixToken).safeApprove(gauge, 0);
      IERC20(mixToken).safeApprove(gauge, mixTokenBalance);
      Gauge(gauge).deposit(mixTokenBalance);
    }
  }

   
  function doHardWork() public restricted {
    claimAndLiquidateCrv();
    investAllUnderlying();
    wbtcPriceCheckpoint = wbtcValueFromMixToken(mixTokenUnit);
  }

   
  function salvage(address recipient, address token, uint256 amount) public onlyGovernance {
     
    require(!unsalvagableTokens[token], "token is defined as not salvageable");
    IERC20(token).safeTransfer(recipient, amount);
  }

   
  function investedUnderlyingBalance() public view returns (uint256) {
    uint256 gaugeBalance = Gauge(gauge).balanceOf(address(this));
    uint256 wbtcBalance = IERC20(wbtc).balanceOf(address(this));
    if (gaugeBalance == 0) {
       
       
      return wbtcBalance;
    }
    uint256 investedBalance = wbtcValueFromMixToken(gaugeBalance);
    return investedBalance.add(wbtcBalance);
  }

  function wbtcValueFromMixToken(uint256 mixTokenBalance) public view returns (uint256) {
    return ICurveFiWbtc(curve).calc_withdraw_one_coin(mixTokenBalance,
      int128(tokenIndex));
  }

   
  function wrapCoinAmount(uint256 amount) internal view returns (uint256[2] memory) {
    uint256[2] memory amounts = [uint256(0), uint256(0)];
    amounts[uint56(tokenIndex)] = amount;
    return amounts;
  }

   
  function claimAndLiquidateCrv() internal {
    if (!sell) {
       
      emit ProfitsNotCollected();
      return;
    }
    Mintr(mintr).mint(gauge);
     
    uint256 crvBalance = IERC20(crv).balanceOf(address(this));
    emit Liquidating(crvBalance);
    if (crvBalance > sellFloor) {
      uint256 wbtcBalanceBefore = IERC20(wbtc).balanceOf(address(this));
      IERC20(crv).safeApprove(uni, 0);
      IERC20(crv).safeApprove(uni, crvBalance);
       
      IUniswapV2Router02(uni).swapExactTokensForTokens(
        crvBalance, 1, uniswap_CRV2WBTC, address(this), block.timestamp
      );

       
      notifyProfit(wbtcBalanceBefore, IERC20(wbtc).balanceOf(address(this)));
    }
  }

   
  function setSell(bool s) public onlyGovernance {
    sell = s;
  }

   
  function setSellFloor(uint256 floor) public onlyGovernance {
    sellFloor = floor;
  }
}

 

pragma solidity 0.5.16;


interface IConvertor {
  function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);
}

contract PriceConvertor is IPriceConvertor {

  IConvertor public zap = IConvertor(0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3);

  function yCrvToUnderlying(uint256 _token_amount, uint256 i) public view returns (uint256) {
     
    return zap.calc_withdraw_one_coin(_token_amount, int128(i));
  }
}

contract MockPriceConvertor is IPriceConvertor {
  function yCrvToUnderlying(uint256 _token_amount, uint256  ) public view returns (uint256) {
     
    return _token_amount;
  }
}

 

pragma solidity 0.5.16;



 
contract CRVStrategyRENBTCMainnet is CRVStrategyWRenBTC {

   
  address constant public __renbtc = address(0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D);
  address constant public __wbtcMix = address(0x49849C98ae39Fff122806C06791Fa73784FB3675);
  address constant public __crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
  address constant public __weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  address constant public __gauge = address(0xB1F2cdeC61db658F091671F5f199635aEF202CAC);
  address constant public __mintr = address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);  

   
  address constant public __curve = address(0x93054188d876f558f4a66B2EF1d97d16eDf0895B);
  address constant public __uniswap = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

  uint256 constant public __tokenIndex = 0;

  constructor(
    address _storage,
    address _vault
  )
  CRVStrategyWRenBTC(
    _storage,
    __renbtc,
    _vault,
    __tokenIndex,  
    __wbtcMix,
    __curve,  
    __crv,  
    __weth,
    __gauge,
    __mintr,
    __uniswap  
  )
  public {
    wbtcPriceCheckpoint = wbtcValueFromMixToken(mixTokenUnit);
  }
}