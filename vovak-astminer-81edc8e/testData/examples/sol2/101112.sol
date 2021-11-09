 

 

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

 

pragma solidity >=0.6.2;

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

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

 

pragma solidity >=0.5.0;

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





contract VTPToken is ERC20,Ownable{

    using SafeMath for uint256;
    using Address for address;

    bytes32 public DOMAIN_SEPARATOR;

    constructor()
    ERC20("Vesta",'VTP')
    public {
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
                 
                keccak256(bytes("Vesta")),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    function mint(address account, uint256 amount) public onlyOwner{
        return _mint(account, amount);
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

 

pragma solidity ^0.6.0;






 
contract Crowdsale is Context, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

     
    IERC20 private _token;

     
    address payable private immutable _wallet;

     
     
     
     
    uint256 private _rate;

     
    uint256 private _weiRaised;

     
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

     
    constructor (uint256 rate, address payable wallet, IERC20 token) public {
        require(rate > 0, "Crowdsale: rate is 0");
        require(wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(token) != address(0), "Crowdsale: token is the zero address");

        _rate = rate;
        _wallet = wallet;
        _token = token;
    }

     
    receive() external payable {
        buyTokens(_msgSender());
    }

     
    function token() public view returns (IERC20) {
        return _token;
    }

     
    function wallet() public view returns (address payable) {
        return _wallet;
    }

     
    function rate() public view virtual returns (uint256) {
        return _rate;
    }

     
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

     
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

         
        uint256 tokens = _getTokenAmount(weiAmount);

         
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }

     
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view virtual{
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this;  
    }

     
    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view virtual {
         
    }

     
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal virtual{
         
    }

     
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal virtual{
         
    }

     
    function _getTokenAmount(uint256 weiAmount) internal view virtual returns (uint256) {
        return weiAmount.mul(_rate);
    }

     
    function _forwardFunds() internal virtual {
         
    }
}

 

pragma solidity ^0.6.0;



contract BlockCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint private _openingBlock;
    uint private _closingBlock;

    event BlockCrowdsaleExtended(uint prevClosingBlock, uint newClosingBlock);

     
    modifier onlyWhileOpen {
        require(isOpen(), "BlockCrowdsale: not open");
        _;
    }

    constructor (uint256 rate, address payable wallet, IERC20 token,uint openingBlock, uint closingBlock) Crowdsale(rate,wallet,token) public {
        require(openingBlock >= block.number, "BlockCrowdsale: opening time is before current time");
        require(openingBlock < closingBlock, "BlockCrowdsale: opening time is not before closing time");

        _openingBlock = openingBlock;
        _closingBlock = closingBlock;
    }

    function openingBlock() public view returns (uint256) {
        return _openingBlock;
    }

    function closingBlock() public view returns (uint256) {
        return _closingBlock;
    }

    function isOpen() public view returns (bool) {
        return block.number >= _openingBlock && block.number <= _closingBlock;
    }

    function hasClosed() public view returns (bool) {
        return block.number > _closingBlock;
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen view virtual override{
        super._preValidatePurchase(beneficiary, weiAmount);
    }

    function _extendBlock(uint newClosingBlock) internal {
        require(!hasClosed(), "BlockCrowdsale: already closed");
         
        require(newClosingBlock >= _closingBlock, "BlockCrowdsale: new closing block is before current closing block");
        if(newClosingBlock == _closingBlock) return;

        emit BlockCrowdsaleExtended(_closingBlock, newClosingBlock);
        _closingBlock = newClosingBlock;
    }
}

 

 
pragma solidity ^0.6.0;










contract VTPPresale is BlockCrowdsale,Ownable {
    using SafeMath for uint256;
    using Address for address;

    struct ReleaseOneStage{
        bool release;
        uint block;
        uint256 valueWei;
    }

    struct ReleaseRecord{
        uint size;
        mapping (uint => ReleaseOneStage) stages;
        bool done;
    }

    struct ReleaseRecordArray{
        uint size;
        mapping (uint => ReleaseRecord) content;
    }

    mapping (address => ReleaseRecordArray) private _releasePool;
    mapping (address => uint256) public addressLimit;

    uint256 private _storeValue;
    uint256 private _storeTokenValue;
    uint256 private _rateVTP;
    VTPToken private _token;
    uint private _rawCloseBlock;

    uint private _preExtend;
    uint private _rateReduce;
    IUniswapV2Router01 private _uniswap;
    uint private _step;

    bool private _unlock;
    uint private _dailyRelease;

    constructor(uint256 rate, VTPToken token,address payable project,uint openBlock,uint closeBlock,address uniswap,uint step)
    BlockCrowdsale(rate,project,token,openBlock,closeBlock) public{
        require(openBlock<closeBlock,"VTPPresale:Time Breaking");
        require(step > 0,"VTPPresale:Step can not be zero");
        require(step <= 100,"VTPPresale:Step is too big");
        _rateVTP = rate;
        _token = token;
        _rawCloseBlock = closeBlock;
        _preExtend = 24 * step;
        _rateReduce = 1000;
        _uniswap = IUniswapV2Router01(uniswap);
        _unlock = false;
        _step = step; 
    }

    function storeAmount() public view returns(uint256,uint256){
        return (_storeValue,_storeTokenValue);
    }

    function rate() public view override returns (uint256) {
        return _rateVTP.sub(_storeValue.div(10 ** 18).div(500).mul(_rateReduce));
    }

    function _getTokenAmount(uint256 weiAmount) internal view override returns (uint256) {
        uint256 r = rate();
        require(r > 0,"VTPPresale:can not any token now!");
        return weiAmount.mul(r);
    }

     
    function _forwardFunds() internal override {
        _storeValue = _storeValue.add(msg.value);
        addressLimit[msg.sender] += msg.value;
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view override {
        super._preValidatePurchase(beneficiary, weiAmount);
        require(_storeValue < 3000 * 10 ** uint256(18),"VTPPresale:Exceed maximum");
        require(_storeValue.add(weiAmount) < 20000 * 10 ** uint256(18),"VTPPresale:Oops");
        require(weiAmount > 10000000000000000,"VTPPresale:Maybe buy little more?");
        require(_step <= 2 || addressLimit[msg.sender] < _storeValue.div(100).add(100000000000000000000),"VTPPresale:Buy limit");
    }

    function _updatePurchasingState(address, uint256 weiAmount) internal override{
         
        uint256 amount = _storeValue.add(weiAmount).div(10 ** 18);
        uint256 times = 0; 
        if(amount > 500){
            times = uint256(5).add(amount.sub(500).div(500));
        }else{
            times = amount.div(100);
        }
        uint256 newBlock = times.mul(_preExtend).add(_rawCloseBlock);

        _extendBlock(uint(newBlock));
    }

     
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal override{
        ReleaseRecordArray storage records = _releasePool[beneficiary];
        records.size++;
        ReleaseRecord storage record = records.content[records.size - 1];
        record.size = 3;
        record.stages[0] = ReleaseOneStage(false,block.number + 140 * _step,tokenAmount.mul(2).div(10));
        record.stages[1] = ReleaseOneStage(false,block.number + 216 * _step,tokenAmount.mul(3).div(10));
        record.stages[2] = ReleaseOneStage(false,block.number + 288 * _step,tokenAmount.mul(5).div(10));
        record.done = false;

        _storeTokenValue = _storeTokenValue.add(tokenAmount);
    }

    event ReleaseVTP(address beneficiary, uint256 amount,uint stage,uint id);

    function canRelease() public view returns(bool){
        return _unlock;
    }

    function release() public nonReentrant{
        require(_unlock == true,"VTPPresale:Locking");
        ReleaseRecordArray storage records = _releasePool[msg.sender];
        for(uint record = 0;record < records.size;record++){
            ReleaseRecord storage stages = records.content[record];
            if(stages.done == false){
                uint releaseTimes = 0;
                for(uint i = 0;i < 3;i++){
                    ReleaseOneStage storage one = stages.stages[i];
                    if(one.block <= block.number && one.release == false){
                        one.release = true;
                        _token.mint(msg.sender,one.valueWei);

                        emit ReleaseVTP(msg.sender,one.valueWei,i,record);
                    }

                    if(one.release == true){
                        releaseTimes = releaseTimes + 1;
                    }
                }
                if(releaseTimes == 3) stages.done = true;
            }
        }
    }

    function buyRecords() public view returns(uint256[] memory returnData){
        ReleaseRecordArray storage array = _releasePool[msg.sender];
        returnData = new uint256[](array.size*9);
        for(uint i = 0;i<array.size;i++){
            ReleaseRecord storage rawOneRecord = array.content[i];
            for(uint ii = 0;ii<rawOneRecord.size;ii++){ 
                if(rawOneRecord.stages[ii].release){
                    returnData[i*9+ii*3] = 1;
                }else{
                    returnData[i*9+ii*3] = 0;
                }

                returnData[i*9+ii*3+1] = uint256(rawOneRecord.stages[ii].block); 
                returnData[i*9+ii*3+2] = rawOneRecord.stages[ii].valueWei;
            }
        }
    }

    event UnlockRelease(uint block,address self);

    function afterClose() public onlyOwner nonReentrant{
        if(_step != 1){ 
            require(hasClosed(),"VTPPresale:have not close");
        }
        address payable project = Crowdsale(address (this)).wallet();

        uint toMaster = _storeTokenValue.mul(11).div(10);
        uint toSwap = _storeTokenValue.mul(4).div(10);
         
        _token.mint(project,toMaster);
        uint256 last = _storeValue.div(2);
        project.transfer(last);
        last = _storeValue.sub(last);

         
        _token.mint(address(this),toSwap);
        _token.approve(address(_uniswap), toSwap);
         
        _uniswap.addLiquidityETH{value: last}(address(_token), toSwap, toSwap, last,address(this),now);

        _unlock = true;
        _dailyRelease = block.number.add(216 * _step);
        emit UnlockRelease(block.number,address (this));
    }

    function getPair() public view returns(address){
        return pairFor(_uniswap.factory(),address (_token),_uniswap.WETH());
    }

    event DailyRelease(uint amount,uint nextBlock);

     
    function projectRelease() public onlyOwner{
        if(_step != 1) require(_dailyRelease <= block.number,"VTPPresale:not the block");
        _dailyRelease = _dailyRelease + 72 * _step;
        IUniswapV2Pair pair = IUniswapV2Pair(getPair());

        uint liq = pair.balanceOf(address (this));
        uint releaseAmount = liq.mul(5).div(100);
        require(releaseAmount > 0,"VTPPresale:have not liquidity");
        pair.approve(address (_uniswap), releaseAmount);
        _uniswap.removeLiquidityETH(address (_token),releaseAmount,0,0,address (wallet()),now);
        emit DailyRelease(releaseAmount,_dailyRelease);
    }

     
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

     
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f'  
            ))));
    }
}