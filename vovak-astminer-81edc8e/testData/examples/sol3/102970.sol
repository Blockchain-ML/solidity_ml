 

 

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

 



pragma solidity ^0.6.2;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        uint256 size;
         
        assembly { size := extcodesize(account) }
        return size > 0;
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

 



pragma solidity ^0.6.0;




 
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

 


pragma solidity ^0.6.2;

interface Controller {
    function strategist() external view returns (address);
    function vaults(address) external view returns (address);
    function rewards() external view returns (address);
    function balanceOf(address) external view returns (uint);
    function withdraw(address, uint) external;
    function earn(address, uint) external;
}

 


pragma solidity ^0.6.2;

interface Vault {
    function token() external view returns (address);
    function priceE18() external view returns (uint);
    function deposit(uint) external;
    function withdraw(uint) external;
    function depositAll() external;
    function withdrawAll() external;
}

 


pragma solidity ^0.6.2;

interface IUniV2 {
    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external;
}

interface UniSwapV1 {
    function tokenAddress() external view returns (address token);
    function factoryAddress() external view returns (address factory);
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

interface IUniStakingRewards{
    function balanceOf(address account) external view returns (uint256);
    function stake(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function getReward() external;
    function rewardPerToken() external;
    function exit() external;
}

interface IUniswapV2Router02{
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external;
}

 



pragma solidity ^0.6.0;

 
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

 


pragma solidity ^0.6.2;







abstract contract StrategyBaseline {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public want;
    address public governance;
    address public controller;

    constructor(address _want, address _controller) public {
        governance = msg.sender;
        controller = _controller;
        want = _want;
    }

    function deposit() public virtual;

    function withdraw(IERC20 _asset) external virtual returns (uint256 balance);

    function withdraw(uint256 _amount) external virtual;

    function withdrawAll() external virtual returns (uint256 balance);

    function balanceOf() public virtual view returns (uint256);

    function SetGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function SetController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
}

 


pragma solidity ^0.6.2;








abstract contract StrategyBaselineCarbon is StrategyBaseline {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    uint256 public feen = 5e15;
    uint256 public constant feed = 1e18;

    constructor(address _want, address _controller)
        public
        StrategyBaseline(_want, _controller)
    {}

    function DepositToken(uint256 _amount) internal virtual;

    function WithdrawToken(uint256 _amount) internal virtual;

    function Harvest() external virtual;

    function GetDeposited() public virtual view returns (uint256);

    function deposit() public override {
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            DepositToken(_want);
        }
    }

    function withdraw(IERC20 _asset)
        external
        override
        returns (uint256 balance)
    {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    function withdraw(uint256 _aw) external override {
        require(msg.sender == controller, "!controller");
        uint256 _w = IERC20(want).balanceOf(address(this));
        if (_w < _aw) {
            WithdrawToken(_aw.sub(_w));
        }
        _w = IERC20(want).balanceOf(address(this));
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault");
        IERC20(want).safeTransfer(_vault, Math.min(_aw, _w));
    }

    function withdrawAll() external override returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        WithdrawToken(GetDeposited());
        balance = IERC20(want).balanceOf(address(this));
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault");
        IERC20(want).safeTransfer(_vault, balance);
    }

    function balanceOf() public override view returns (uint256) {
        uint256 _want = IERC20(want).balanceOf(address(this));
        return GetDeposited().add(_want);
    }

    function setFeeN(uint256 _feen) external {
        require(msg.sender == governance, "!governance");
        feen = _feen;
    }
}

 


pragma solidity ^0.6.2;









contract StrategyBaselineCarbonUniswapWBTC is StrategyBaselineCarbon {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant unitoken = address(
        0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984
    );
    address public constant lptoken = address(
        0xBb2b8038a1640196FbE3e38816F3e67Cba72D940
    );
    address public constant lppool = address(
        0xCA35e32e7926b96A9988f61d510E038108d8068e
    );
    address public constant unipool = address(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );
    address public constant weth = address(
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    );
    address public constant wbtc = address(
        0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599
    );
    address public constant uniswapRouterV2 = address(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );

    constructor(address _controller)
        public
        StrategyBaselineCarbon(lptoken, _controller)
    {}

    function DepositToken(uint256 _amount) internal override {
        IERC20(want).safeApprove(lppool, 0);
        IERC20(want).safeApprove(lppool, _amount);
        IUniStakingRewards(lppool).stake(_amount);
    }

    function WithdrawToken(uint256 _amount) internal override {
        IUniStakingRewards(lppool).withdraw(_amount);
    }

    function Harvest() external override {
        require(
            msg.sender == Controller(controller).strategist() ||
                msg.sender == governance,
            "!permission"
        );
        IUniStakingRewards(lppool).getReward();
        uint256 unitokenBalance = IERC20(unitoken).balanceOf(address(this));

        if (unitokenBalance > 0) {
            uint256 _fee = unitokenBalance.mul(feen).div(feed);
            IERC20(unitoken).safeTransfer(Controller(controller).rewards(), _fee);
            unitokenBalance = unitokenBalance.sub(_fee);

            IERC20(unitoken).safeApprove(uniswapRouterV2, 0);
            IERC20(unitoken).safeApprove(uniswapRouterV2, unitokenBalance);
            address[] memory path1 = new address[](2);
            path1[0] = unitoken;
            path1[1] = weth;
            IUniswapV2Router02(uniswapRouterV2).swapExactTokensForTokens(
                unitokenBalance,
                0,
                path1,
                address(this),
                block.timestamp
            );

            uint256 wethAmount = IERC20(weth).balanceOf(address(this));
            IERC20(weth).safeApprove(uniswapRouterV2, 0);
            IERC20(weth).safeApprove(uniswapRouterV2, wethAmount);
            address[] memory path2 = new address[](2);
            path2[0] = weth;
            path2[1] = wbtc;
            IUniswapV2Router02(uniswapRouterV2).swapExactTokensForTokens(
                wethAmount / 2,
                0,
                path2,
                address(this),
                block.timestamp
            );

            wethAmount = IERC20(weth).balanceOf(address(this));
            uint256 wbtcAmount = IERC20(wbtc).balanceOf(address(this));

            IERC20(wbtc).safeApprove(uniswapRouterV2, 0);
            IERC20(wbtc).safeApprove(uniswapRouterV2, wbtcAmount);

            IUniswapV2Router02(uniswapRouterV2).addLiquidity(
                weth,
                wbtc,
                wethAmount,
                wbtcAmount,
                1,
                1,
                address(this),
                block.timestamp
            );
        }
    }

    function GetDeposited() public override view returns (uint256) {
        return IUniStakingRewards(lppool).balanceOf(address(this));
    }
}

 


pragma solidity ^0.6.2;


contract StrategyBaselineCarbonUniswapWBTCInstance is StrategyBaselineCarbonUniswapWBTC {
    constructor()
        public
        StrategyBaselineCarbonUniswapWBTC(
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}