 

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

 

pragma solidity ^0.5.2;

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

 

pragma solidity ^0.5.2;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

 

pragma solidity ^0.5.2;





 
contract IUSO {
  using SafeMath for uint256;
  using SafeMath for uint32;

  uint256 LIQUIDITY_PERCENT = 14;
  uint256 BUYIN_PERCENT = 1;

  address uniswapRouterAddress = 0xf164fC0Ec4E93095b804a4795bBe1e041497b92a;
  IUniswapV2Router01 uniswapRouter = IUniswapV2Router01(uniswapRouterAddress);
  address payable fusePool = 0x1ce78dbc91f96Cf4a87B37F7711113289243889a;
  IUniswapV2Pair fuseETHPair = IUniswapV2Pair(0x4Ce3687fEd17e19324F23e305593Ab13bBd55c4D);
  IERC20 fuseToken = IERC20(0x970B9bB2C0444F5E81e9d0eFb84C8ccdcdcAf84d);
  IERC20 wethToken = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  

  function () external payable  {
    if (msg.sender == uniswapRouterAddress) {
      return fusePool.transfer(msg.value);
    }

    address[] memory weth2fusePath = new address[](2);
    weth2fusePath[0] = address(wethToken);
    weth2fusePath[1] = address(fuseToken);

    uint256 fuseReserve;
    uint256 ethReserve;

    (fuseReserve, ethReserve, ) = fuseETHPair.getReserves();
    uint256 fuse2eth1 = fuseReserve.div(ethReserve);

     

    uint256 ethLiquidityAmount = msg.value.mul(LIQUIDITY_PERCENT).div(100);
     
    uint256 fuseLiquidityAmount = uniswapRouter.quote(ethLiquidityAmount, ethReserve, fuseReserve);

    uint256 ethBuyinAmount = msg.value.mul(BUYIN_PERCENT).div(100);

    uint256 ethToTeamAmount = msg.value.sub(ethLiquidityAmount).sub(ethBuyinAmount);

    fuseToken.transferFrom(fusePool, address(this), fuseLiquidityAmount);
    fuseToken.approve(uniswapRouterAddress, fuseLiquidityAmount);

     

    uniswapRouter.addLiquidityETH.value(ethLiquidityAmount)(
      address(fuseToken),
      fuseLiquidityAmount,
      fuseLiquidityAmount.mul(99).div(100),
      uniswapRouter.quote(fuseLiquidityAmount, fuseReserve, ethReserve),
      fusePool,
      block.timestamp
    );

    (fuseReserve, ethReserve, ) = fuseETHPair.getReserves();
    uint256 fuseBuyinAmount = uniswapRouter.getAmountOut(ethBuyinAmount, ethReserve, fuseReserve);

    (uint[] memory amounts) = uniswapRouter.swapExactETHForTokens.value(ethBuyinAmount)(
      fuseBuyinAmount,
      weth2fusePath,
      msg.sender,
      block.timestamp
    );

    (fuseReserve, ethReserve, ) = fuseETHPair.getReserves();
    uint256 fuse2eth2 = fuseReserve.div(ethReserve);

    uint256 fuse2eth = fuse2eth1.add(fuse2eth2).div(2);
    uint256 fuseOut = msg.value.mul(fuse2eth).sub(amounts[1]);
    fusePool.transfer(ethToTeamAmount);
    require(fuseToken.transferFrom(fusePool, msg.sender, fuseOut));
  }
}