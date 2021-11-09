pragma solidity ^0.6.6;


 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
     
     
     
     
     
     
     
     
     
     
     

     
     
     
     
     
     
     
     
     
     
     
     

     
     

     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     

     
     

     
     

     
     
     
     
     
     
     
     
     
     
     
     
     
     

     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     

     
     

     
     
     
     
     
     
     
     
     
     
     
     
     
     

     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
}

 
interface IERC20 {
     
     

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
     

     
     
}

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
     
     

     
     
     
     
}

 
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

     
     
     
     

     
     
     
     

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         

         
         
         
         
         
        require(address(token).isContract(), "SafeERC20: call to non-contract");

         
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 
interface IFlashLoanReceiver {
    function executeOperation(address _reserve, uint256 _amount, uint256 _fee, bytes calldata _params) external;
}

 
interface ILendingPoolAddressesProvider {
    function getLendingPoolCore() external view returns (address payable);
    function getLendingPool() external view returns (address);
}

 
contract Context {
     
     
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

     
     
     
     
}

 
 
 
 

 

 

 

 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 

 
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 

 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 

 
 
 
 

 
 
 
 
 
 
 
 
 
 
 

 

 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 

 

 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
 

 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
contract Ownable is Context {
    address private _owner;

     

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
         
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
     
     
     
     

     
     
     
     
     
     
}

 
contract Withdrawable is Ownable {
    using SafeERC20 for IERC20;
    address constant ETHER = address(0);

     
     
     
     
     

     
    function withdraw(address _assetAddress) public onlyOwner {
        uint assetBalance;
        if (_assetAddress == ETHER) {
            address self = address(this);  
            assetBalance = self.balance;
            msg.sender.transfer(assetBalance);
        } else {
            assetBalance = IERC20(_assetAddress).balanceOf(address(this));
            IERC20(_assetAddress).safeTransfer(msg.sender, assetBalance);
        }
         
    }
}

abstract contract FlashLoanReceiverBase is IFlashLoanReceiver, Withdrawable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address constant ethAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    ILendingPoolAddressesProvider public addressesProvider;

    constructor(address _addressProvider) public {
        addressesProvider = ILendingPoolAddressesProvider(_addressProvider);
    }

    receive() payable external {}

    function transferFundsBackToPoolInternal(address _reserve, uint256 _amount) internal {
        address payable core = addressesProvider.getLendingPoolCore();
        transferInternal(core, _reserve, _amount);
    }

    function transferInternal(address payable _destination, address _reserve, uint256 _amount) internal {
        if(_reserve == ethAddress) {
            (bool success, ) = _destination.call{value: _amount}("");
            require(success == true, "Couldn't transfer ETH");
            return;
        }
        IERC20(_reserve).safeTransfer(_destination, _amount);
    }

    function getBalanceInternal(address _target, address _reserve) internal view returns(uint256) {
        if(_reserve == ethAddress) {
            return _target.balance;
        }
        return IERC20(_reserve).balanceOf(_target);
    }
}

interface ILendingPool {
  function addressesProvider () external view returns ( address );
 
 
 
 
 
 
 
 
  function flashLoan ( address _receiver, address _reserve, uint256 _amount, bytes calldata _params ) external;
 
 
 
 
 
}

interface IUniswapRouter {
    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external;
}

interface IBank {
    function withdraw(address underlying, uint256 withdrawTokens) external;

    function controller() external view returns (address);

    function liquidateBorrow(
        address borrower,
        address underlyingBorrow,
        address underlyingCollateral,
        uint256 repayAmount
    ) external payable;
}

interface IFToken {
    function balanceOf(address account) external view returns (uint256);
}

interface IBankController {
    function getFTokeAddress(address underlying)
        external
        view
        returns (address);
}

contract FlashloanForTube is FlashLoanReceiverBase {
    using SafeERC20 for IERC20;

    address public bank = address(0xdE7B3b2Fe0E7b4925107615A5b199a4EB40D9ca9);
    address[] public swap2TokenRouting;

    address public uniRouterV2 = address(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );
    address public weth = address(
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    );  

    constructor(address _addressProvider)
        public
        FlashLoanReceiverBase(_addressProvider)
    {}

    function doApprove(address erc20, address spender) public {
        IERC20(erc20).safeApprove(spender, 0);
        IERC20(erc20).safeApprove(spender, uint256(-1));
    }

     
    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params
    ) external override {
        require(
            _amount <= getBalanceInternal(address(this), _reserve),
            "Invalid balance, was the flashLoan successful?"
        );

         
         
         
         

        (
            address borrower,
            address underlyingBorrow,
            address underlyingCollateral,
            uint256 repayAmount
        ) = abi.decode(_params, (address, address, address, uint256));
        require(underlyingBorrow == _reserve, "liquidate asset not match");

        doApprove(_reserve, bank);
        IBank(bank).liquidateBorrow(
            borrower,
            underlyingBorrow,
            underlyingCollateral,
            repayAmount
        );
        IBankController ctrl = IBankController(IBank(bank).controller());
        IFToken fToken = IFToken(ctrl.getFTokeAddress(underlyingCollateral));
        IBank(bank).withdraw(
            underlyingCollateral,
            fToken.balanceOf(address(this))
        );

         
        doApprove(underlyingCollateral, uniRouterV2);
        swap2TokenRouting = [underlyingCollateral, weth, _reserve];
         
        IUniswapRouter(uniRouterV2).swapExactTokensForTokens(
            IERC20(underlyingCollateral).balanceOf(address(this)),
            0,
            swap2TokenRouting,
            address(this),
            now.add(1800)
        );

        uint256 totalDebt = _amount.add(_fee);
        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }

     
    function flashloan(
        address _asset,
        uint256 _amount,
        bytes calldata _data
    ) external onlyOwner {
        ILendingPool lendingPool = ILendingPool(
            addressesProvider.getLendingPool()
        );
        lendingPool.flashLoan(address(this), _asset, _amount, _data);
    }

    function set(
        address _bank,
        address _weth,
        address _uniRouterV2,
        address _addressesProvider
    ) external onlyOwner {
        bank = _bank;
        weth = _weth;
        uniRouterV2 = _uniRouterV2;
        addressesProvider = ILendingPoolAddressesProvider(_addressesProvider);
    }
}