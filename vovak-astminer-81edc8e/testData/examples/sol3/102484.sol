 

 

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

 



pragma solidity ^0.6.2;

 
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

 



pragma solidity ^0.6.0;





 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

 



pragma solidity ^0.6.0;


 
contract Pausable is Context {
    event Paused(address account);
    event Shutdown(address account);
    event Unpaused(address account);
    event Open(address account);

    bool public paused;
    bool public stopEverything;

    constructor() internal {
        paused = false;
        stopEverything = false;
    }

    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }
    modifier whenPaused() {
        require(paused, "Pausable: not paused");
        _;
    }

    modifier whenNotShutdown() {
        require(!stopEverything, "Pausable: shutdown");
        _;
    }

    modifier whenShutdown() {
        require(stopEverything, "Pausable: not shutdown");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused whenNotShutdown {
        paused = false;
        emit Unpaused(_msgSender());
    }

    function _shutdown() internal virtual whenNotShutdown {
        stopEverything = true;
        paused = true;
        emit Shutdown(_msgSender());
    }

    function _open() internal virtual whenShutdown {
        stopEverything = false;
        emit Open(_msgSender());
    }
}

 



pragma solidity ^0.6.0;

 
contract ReentrancyGuard {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }
}

 



pragma solidity ^0.6.6;




abstract contract PoolShareToken is ERC20, ReentrancyGuard, Pausable {
    uint256 public withdrawFee;  
    address public feeCollector;

     
    constructor(string memory name, string memory symbol) public ERC20(name, symbol) {}

     
    function deposit() public virtual payable nonReentrant {}

     
    function totalValue() public virtual view returns (uint256) {}

     
    function withdraw() public virtual {}

     
    function _beforeMinting(uint256 amount) internal virtual {}

     
    function _afterBurning(uint256 shares) internal virtual {}

    function _deposit(uint256 amount) internal whenNotPaused {
        require(amount > 0, "Deposit must be greater than 0");

        uint256 _totalSupply = totalSupply();
        uint256 _totalValue = totalValue();
        uint256 shares = (_totalSupply == 0 || _totalValue == 0)
            ? amount
            : amount.mul(_totalSupply).div(_totalValue);
        require(_totalSupply.add(shares) < 50e18, "test limit");
        _beforeMinting(amount);

        _mint(msg.sender, shares);
    }

    event Withdraw(address owner, uint256 shares, uint256 amount);

     
    function _beforeBurning(uint256 shares) internal virtual {}

    function _handleFee(uint256 shares) internal returns (uint256 _sharesAfterFee) {
        if (withdrawFee > 0) {
            uint256 _fee = shares.mul(withdrawFee).div(1e18);
            _sharesAfterFee = shares.sub(_fee);
            _transfer(_msgSender(), feeCollector, _fee);
        } else {
            _sharesAfterFee = shares;
        }
    }

    function _updateWithdrawFee(uint256 _withdrawFee) internal {
        require(_withdrawFee <= 1e18, "fee is greater than 100%");
        withdrawFee = _withdrawFee;
    }

    function _updateFeeCollector(address _feeCollector) internal {
        require(_feeCollector != address(0), "_feeCollector is 0x0");
        feeCollector = _feeCollector;
    }

     
    function _withdraw(uint256 shares) internal whenNotShutdown {
        require(shares > 0, "Withdraw must be greater than 0");
        uint256 sharesAfterFee = _handleFee(shares);
        uint256 amount = sharesAfterFee.mul(totalValue()).div(totalSupply());
        _burn(msg.sender, shares);
        _afterBurning(amount);
        emit Withdraw(msg.sender, shares, amount);
    }
}

 



pragma solidity ^0.6.6;

interface ICollateralManager {
    function borrowDai(uint256 vaultNum, uint256 amount) external;

    function depositCollateral(uint256 vaultNum) external payable;

    function depositCollateral(uint256 vaultNum, uint256 amount) external;

    function getVaultBalance(uint256 vaultNum) external view returns (uint256 collateralLocked);

    function getVaultDebt(uint256 vaultNum) external view returns (uint256 daiDebt);

    function getVaultInfo(uint256 vaultNum)
        external
        view
        returns (
            uint256 collateralLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        );

    function isEmpty(uint256 vaultNum) external view returns (bool);

    function paybackDai(uint256 vaultNum, uint256 amount) external;

    function registerVault(uint256 vaultNum, bytes32 collateralType) external;

    function updateStrategyManager(uint256 vaultNum, address strategyManager) external;

    function vaultOwner(uint256 vaultNum) external returns (address owner);

    function whatWouldWithdrawDo(uint256 vaultNum, uint256 amount)
        external
        view
        returns (
            uint256 collateralLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        );

    function withdrawCollateral(
        uint256 vaultNum,
        uint256 amount,
        address recipient
    ) external;
}

 



pragma solidity ^0.6.6;

interface StrategyManager {
    function getStrategyTokenAddress(address token) external returns (address);

    function isEmpty() external returns (bool);

    function moveDaiFromAave(uint256 vaultNum, uint256 amount) external;

    function moveDaiToMaker(uint256 vaultNum, uint256 amount) external;

    function rebalance(
        uint256 vaulNum,
        uint256 highWater,
        uint256 lowWater
    ) external;

    function rebalanceCollRatio(
        uint256 vaulNum,
        uint256 highWater,
        uint256 lowWater
    ) external;

    function rebalanceEarnedDai(uint256 vaultNum) external;

    function updateCollateralManager(address collateralManager) external;
}

 



pragma solidity ^0.6.6;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

 



pragma solidity ^0.6.6;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

 



pragma solidity ^0.6.6;


interface GemJoinInterface {
    function ilk() external view returns (bytes32);
}

contract Helper is Ownable {
    mapping(bytes32 => address) public mcdGemJoin;

    event LogAddGemJoin(address[] gemJoin);

     
    function addGemJoin(address[] memory gemJoins) public onlyOwner {
        require(gemJoins.length > 0, "No gemJoin address");
        for (uint256 i = 0; i < gemJoins.length; i++) {
            address gemJoin = gemJoins[i];
            bytes32 ilk = GemJoinInterface(gemJoin).ilk();
            require(mcdGemJoin[ilk] == address(0), "GemJoin already added");
            mcdGemJoin[ilk] = gemJoin;
        }
        emit LogAddGemJoin(gemJoins);
    }
}

contract AddressProvider is Helper {
     
    address public daiAddress;
    address public manaAddress;
    address public mcdManaJoin;
    address public mcdManager;
    address public mcdEthJoin;
    address public mcdSpot;
    address public mcdDaiJoin;
    address public mcdJug;
    address public aaveProvider;
    address public uniswapRouterV2;
    address public weth;

    constructor() public {
        uint256 id;
        assembly {
            id := chainid()
        }
        if (id == 42) {
            aaveProvider = 0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5;
            uniswapRouterV2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
             
            daiAddress = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
            manaAddress = 0x221F4D62636b7B51b99e36444ea47Dc7831c2B2f;
            mcdManager = 0x1476483dD8C35F25e568113C5f70249D3976ba21;
            mcdDaiJoin = 0x5AA71a3ae1C0bd6ac27A1f28e1415fFFB6F15B8c;
            mcdSpot = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
            mcdJug = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
            weth = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
        } else {
            aaveProvider = 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8;
            uniswapRouterV2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
             
            daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
            manaAddress = 0x0F5D2fB29fb7d3CFeE444a200298f468908cC942;
            mcdManager = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
            mcdDaiJoin = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
            mcdSpot = 0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3;
            mcdJug = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
            weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        }
    }
}

 



pragma solidity ^0.6.6;







interface ManagerLike {
    function vat() external view returns (address);

    function open(bytes32, address) external returns (uint256);

    function cdpAllow(
        uint256,
        address,
        uint256
    ) external;
}

interface VatLike {
    function hope(address) external;
}

abstract contract VTokenBase is PoolShareToken, Ownable {
    uint256 public vaultNum;
    bytes32 public collType;
    AddressProvider internal ap = new AddressProvider();
    uint256 internal constant WAT = 10**16;
    address internal ethAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint256 internal highWater = 300 * WAT;
    uint256 internal lowWater = 250 * WAT;
    bool internal lockEth = true;
    ICollateralManager public cm;
    StrategyManager public sm;

    constructor(
        string memory name,
        string memory symbol,
        bytes32 _collType
    ) public PoolShareToken(name, symbol) {
        collType = _collType;
    }

    function approveToken() public virtual {
        IERC20 aDai = IERC20(sm.getStrategyTokenAddress(ap.daiAddress()));
        aDai.approve(address(sm), uint256(-1));
    }

    function init(address _cm, address _sm) public onlyOwner {
        require(vaultNum == 0, "Already intialized");
        require(address(cm) == address(0), "Already intialized");
        require(address(sm) == address(0), "Already intialized");
        cm = ICollateralManager(_cm);
        sm = StrategyManager(_sm);
        vaultNum = createVault(collType, _cm);
        cm.updateStrategyManager(vaultNum, _sm);
        approveToken();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function shutdown() public onlyOwner {
        _shutdown();
    }

    function open() public onlyOwner {
        _open();
    }

    function updateFeeAndCollector(uint256 _fee, address _feeCollector) public onlyOwner {
        _updateWithdrawFee(_fee);
        _updateFeeCollector(_feeCollector);
    }

    function updateManagers(address _cm, address _sm) public onlyOwner {
        require(_cm != address(0) && _sm != address(0), "CM and SM cannot be 0");

         
        require(cm.isEmpty(vaultNum), "CM is not empty");
        require(sm.isEmpty(), "SM is not empty");

        cm = ICollateralManager(_cm);
        registerCollateralManager(_cm);
        cm.updateStrategyManager(vaultNum, _sm);

        sm = StrategyManager(_sm);
        sm.updateCollateralManager(_cm);
    }

    function updateBalancingFactor(uint256 _highWater, uint256 _lowWater) public onlyOwner {
        require(_lowWater > 0, "Value is zero");
        require(_highWater > _lowWater, "highWater is small than lowWater");
        highWater = _highWater.mul(WAT);
        lowWater = _lowWater.mul(WAT);
    }

    function rebalanceCollRatio() public {
        require(!stopEverything || (_msgSender() == owner()), "Not an owner");
        sm.rebalanceCollRatio(vaultNum, highWater, lowWater);
    }

    function rebalanceEarnedDai() public {
        require(!stopEverything || (_msgSender() == owner()), "Not an owner");
        sm.rebalanceEarnedDai(vaultNum);
    }

    function getVaultBalance() public view returns (uint256 collateralLocked) {
        collateralLocked = cm.getVaultBalance(vaultNum);
    }

    function _afterBurning(uint256 amount) internal override {
        (
            uint256 collaterolLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        ) = cm.whatWouldWithdrawDo(vaultNum, amount);
        if (daiDebt > 0) {
            IERC20 aDai = IERC20(sm.getStrategyTokenAddress(ap.daiAddress()));
            uint256 aDaiBalance = aDai.balanceOf(address(this));
            require(daiDebt <= aDaiBalance, "Pool is underwater");
            if (collateralRatio < lowWater) {
                 
                uint256 maxDaiDebt = (collaterolLocked.mul(collateralUsdRate)).div(highWater);
                if (maxDaiDebt < minimumDebt) {
                     
                    sm.moveDaiToMaker(vaultNum, daiDebt);
                } else if (maxDaiDebt < daiDebt) {
                    sm.moveDaiToMaker(vaultNum, daiDebt.sub(maxDaiDebt));
                }
            }
        }
        cm.withdrawCollateral(vaultNum, amount, msg.sender);
    }

    function totalValue() public override view returns (uint256 value) {
        value = cm.getVaultBalance(vaultNum);
    }

    function createVault(bytes32 _collType, address _cm) internal returns (uint256 vaultId) {
        ManagerLike manager = ManagerLike(ap.mcdManager());
        vaultId = manager.open(_collType, address(this));
        manager.cdpAllow(vaultId, address(this), 1);

         
        VatLike(manager.vat()).hope(_cm);
        manager.cdpAllow(vaultId, _cm, 1);

         
        ICollateralManager(_cm).registerVault(vaultId, _collType);
    }

    function registerCollateralManager(address _cm) internal {
        ManagerLike manager = ManagerLike(ap.mcdManager());
         
        VatLike(manager.vat()).hope(_cm);
        manager.cdpAllow(vaultNum, _cm, 1);

         
        ICollateralManager(_cm).registerVault(vaultNum, collType);
    }

    function _sweepErc20(address from, address to) internal {
        require(
            from != to &&
                from != address(this) &&
                from != ap.daiAddress() &&
                from != sm.getStrategyTokenAddress(ap.daiAddress()),
            "Not allowed to sweep"
        );
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(ap.uniswapRouterV2());
        IERC20 token = IERC20(from);
        uint256 amt = token.balanceOf(address(this));
        token.approve(address(uniswapRouter), amt);
        address[] memory path = new address[](2);
        path[0] = from;
        if (to == ethAddress) {
            path[1] = uniswapRouter.WETH();
            uniswapRouter.swapExactTokensForETH(amt, 1, path, address(this), now + 30);
        } else {
            path[1] = to;
            uniswapRouter.swapExactTokensForTokens(amt, 1, path, address(this), now + 30);
        }
    }
}

 



pragma solidity ^0.6.6;


contract VWETH is VTokenBase("VWETH Pool Token", "VWETH", "ETH-A") {
     
    receive() external payable {
        if (lockEth) {
            deposit();
        }
    }

     
    function deposit() public override payable nonReentrant {
        _deposit(msg.value);
    }

    function withdraw(uint256 shares) public nonReentrant {
        _withdraw(shares);
    }

    function sweepErc20(address erc20) public {
        lockEth = false;
        _sweepErc20(erc20, ethAddress);
        cm.depositCollateral{value: address(this).balance}(vaultNum);
        lockEth = true;
    }

    function _beforeMinting(uint256 amount) internal override {
        cm.depositCollateral{value: amount}(vaultNum);
    }
}