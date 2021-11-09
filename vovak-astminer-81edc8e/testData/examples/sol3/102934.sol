 
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 

 
 
 

 

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

 

pragma solidity ^0.6.0;

 
contract ReentrancyGuard {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
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

 

pragma solidity ^0.6.2;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        uint256 size;
         
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

         
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

     
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

     
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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
    function _msgSender() internal virtual view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity ^0.6.0;

 
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

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);
}

interface IUniswapRouter02 {
     
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

     
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

    function swapETHForExactTokens(
        uint256 amountOut,
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
}

interface yVault {
    function deposit(uint256) external;

    function withdraw(uint256) external;

    function getPricePerFullShare() external view returns (uint256);

    function token() external view returns (address);
}

interface ICurveZapInGeneral {
    function ZapIn(
        address _toWhomToIssue,
        address _IncomingTokenAddress,
        address _curvePoolExchangeAddress,
        uint256 _IncomingTokenQty,
        uint256 _minPoolTokens
    ) external payable returns (uint256 crvTokensBought);
}

interface ICurveZapOutGeneral {
    function ZapOut(
        address payable _toWhomToIssue,
        address _curveExchangeAddress,
        uint256 _tokenCount,
        uint256 _IncomingCRV,
        address _ToTokenAddress,
        uint256 _minToTokens
    ) external returns (uint256 ToTokensBought);
}

interface IAaveLendingPoolAddressesProvider {
    function getLendingPool() external view returns (address);

    function getLendingPoolCore() external view returns (address payable);
}

interface IAaveLendingPool {
    function deposit(
        address _reserve,
        uint256 _amount,
        uint16 _referralCode
    ) external payable;
}

interface IAToken {
    function redeem(uint256 _amount) external;

    function underlyingAssetAddress() external returns (address);
}

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}

contract yVault_ZapInOut_General_V1_4 is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;
    bool public stopped = false;
    uint16 public goodwill;

    IUniswapV2Factory
        private constant UniSwapV2FactoryAddress = IUniswapV2Factory(
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
    );
    IUniswapRouter02 private constant uniswapRouter = IUniswapRouter02(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );

    ICurveZapInGeneral public CurveZapInGeneral = ICurveZapInGeneral(
        0xBB7678acd5494cA06d9738DCBD2BdF1c6d58672f
    );
    ICurveZapOutGeneral public CurveZapOutGeneral = ICurveZapOutGeneral(
        0x4bF331Aa2BfB0869315fB81a350d109F4839f81b
    );
    
    IAaveLendingPoolAddressesProvider
        private constant lendingPoolAddressProvider = IAaveLendingPoolAddressesProvider(
        0x24a42fD28C976A61Df5D00D0599C34c4f90748c8
    );

    address private constant yCurveExchangeAddress = 0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3;
    address private constant sBtcCurveExchangeAddress = 0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714;
    address private constant bUSDCurveExchangeAddress = 0xb6c057591E073249F2D9D88Ba59a46CFC9B59EdB;
    
    address private constant yCurvePoolTokenAddress = 0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8;
    address private constant sBtcCurvePoolTokenAddress = 0x075b1bb99792c9E1041bA13afEf80C91a1e70fB3;
    address private constant bUSDCurvePoolTokenAddress = 0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B;
    
    mapping(address => address) internal token2Exchange;

    address
        private constant ETHAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address
        private constant wethTokenAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address
        private constant zgoodwillAddress = 0xE737b6AfEC2320f616297e59445b60a11e3eF75F;

    uint256
        private constant deadline = 0xf000000000000000000000000000000000000000000000000000000000000000;

    event Zapin(
        address _toWhomToIssue,
        address _toYVaultAddress,
        uint256 _Outgoing
    );

    event Zapout(
        address _toWhomToIssue,
        address _fromYVaultAddress,
        address _toTokenAddress,
        uint256 _tokensRecieved
    );

    constructor(uint16 _goodwill) public {
        goodwill = _goodwill;
        
        token2Exchange[yCurvePoolTokenAddress] = yCurveExchangeAddress;
        token2Exchange[bUSDCurvePoolTokenAddress] = bUSDCurveExchangeAddress;
        token2Exchange[sBtcCurvePoolTokenAddress] = sBtcCurveExchangeAddress;
    }

     
    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function updateCurveZapIn(address CurveZapInGeneralAddress)
        public
        onlyOwner
    {
        require(CurveZapInGeneralAddress != address(0), "Invalid Address");
        CurveZapInGeneral = ICurveZapInGeneral(CurveZapInGeneralAddress);
    }
    
    function updateCurveZapOut(address CurveZapOutGeneralAddress)
        public
        onlyOwner
    {
        require(CurveZapOutGeneralAddress != address(0), "Invalid Address");
        CurveZapOutGeneral = ICurveZapOutGeneral(CurveZapOutGeneralAddress);
    }
    
    function addNewCurveExchange(address curvePoolToken, address curveExchangeAddress)
        public
        onlyOwner
    {
        require(curvePoolToken != address(0) && curveExchangeAddress != address(0), "Invalid Address");
        token2Exchange[curvePoolToken] = curveExchangeAddress;
    }

     
    function ZapIn(
        address _toWhomToIssue,
        address _toYVaultAddress,
        uint16 _vaultType,
        address _fromTokenAddress,
        uint256 _amount,
        uint256 _minTokensSwapped
    ) public payable nonReentrant stopInEmergency returns (uint256) {
        yVault vaultToEnter = yVault(_toYVaultAddress);
        address underlyingVaultToken = vaultToEnter.token();

        if (_fromTokenAddress == address(0)) {
            require(msg.value > 0, "ERR: No ETH sent");
        } else {
            require(_amount > 0, "Err: No Tokens Sent");
            require(msg.value == 0, "ERR: ETH sent with Token");

            IERC20(_fromTokenAddress).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );
        }
        if (underlyingVaultToken == _fromTokenAddress) {
            IERC20(underlyingVaultToken).safeApprove(
                address(vaultToEnter),
                _amount
            );
            vaultToEnter.deposit(_amount);
        } else {
             
            if (_vaultType == 2) {
                address curveExchangeAddr = token2Exchange[underlyingVaultToken];
                
                uint256 tokensBought;
                if (_fromTokenAddress == address(0)) {
                    tokensBought = CurveZapInGeneral.ZapIn{value: msg.value}(
                        address(this),
                        address(0),
                        curveExchangeAddr,
                        msg.value,
                        _minTokensSwapped
                    );
                } else {
                    IERC20(_fromTokenAddress).safeApprove(
                        address(CurveZapInGeneral),
                        _amount
                    );
                    tokensBought = CurveZapInGeneral.ZapIn(
                        address(this),
                        _fromTokenAddress,
                        curveExchangeAddr,
                        _amount,
                        _minTokensSwapped
                    );
                }

                IERC20(underlyingVaultToken).safeApprove(
                    address(vaultToEnter),
                    tokensBought
                );
                vaultToEnter.deposit(tokensBought);
            } else if (_vaultType == 1) {
                address underlyingAsset = IAToken(underlyingVaultToken)
                    .underlyingAssetAddress();

                uint256 tokensBought;
                if (_fromTokenAddress == address(0)) {
                    tokensBought = _eth2Token(
                        underlyingAsset,
                        _minTokensSwapped
                    );
                } else {
                    tokensBought = _token2Token(
                        _fromTokenAddress,
                        underlyingAsset,
                        _amount,
                        _minTokensSwapped
                    );
                }

                IERC20(underlyingAsset).safeApprove(
                    lendingPoolAddressProvider.getLendingPoolCore(),
                    tokensBought
                );

                IAaveLendingPool(lendingPoolAddressProvider.getLendingPool())
                    .deposit(underlyingAsset, tokensBought, 0);

                uint256 aTokensBought = IERC20(underlyingVaultToken).balanceOf(
                    address(this)
                );
                IERC20(underlyingVaultToken).safeApprove(
                    address(vaultToEnter),
                    aTokensBought
                );
                vaultToEnter.deposit(aTokensBought);
            } else {
                uint256 tokensBought;
                if (_fromTokenAddress == address(0)) {
                    tokensBought = _eth2Token(
                        underlyingVaultToken,
                        _minTokensSwapped
                    );
                } else {
                    tokensBought = _token2Token(
                        _fromTokenAddress,
                        underlyingVaultToken,
                        _amount,
                        _minTokensSwapped
                    );
                }

                IERC20(underlyingVaultToken).safeApprove(
                    address(vaultToEnter),
                    tokensBought
                );
                vaultToEnter.deposit(tokensBought);
            }
        }

        uint256 yTokensRec = IERC20(address(vaultToEnter)).balanceOf(
            address(this)
        );

         
        uint256 goodwillPortion = _transferGoodwill(
            address(vaultToEnter),
            yTokensRec
        );

        IERC20(address(vaultToEnter)).safeTransfer(
            _toWhomToIssue,
            yTokensRec.sub(goodwillPortion)
        );

        emit Zapin(
            _toWhomToIssue,
            address(vaultToEnter),
            yTokensRec.sub(goodwillPortion)
        );

        return (yTokensRec.sub(goodwillPortion));
    }

       
    function ZapOut(
        address _toWhomToIssue,
        address _ToTokenContractAddress,
        address _fromYVaultAddress,
        uint16 _vaultType,
        uint256 _IncomingAmt,
        uint256 _minTokensRec
    ) public nonReentrant stopInEmergency returns (uint256) {
        yVault vaultToExit = yVault(_fromYVaultAddress);
        address underlyingVaultToken = vaultToExit.token();

        IERC20(address(vaultToExit)).safeTransferFrom(
            msg.sender,
            address(this),
            _IncomingAmt
        );
        
        uint256 goodwillPortion = _transferGoodwill(
            address(vaultToExit),
            _IncomingAmt
        );

        vaultToExit.withdraw(_IncomingAmt.sub(goodwillPortion));
        uint256 underlyingReceived = IERC20(underlyingVaultToken).balanceOf(
            address(this)
        );
        
        uint256 toTokensReceived;
        if(_ToTokenContractAddress == underlyingVaultToken) {
            IERC20(underlyingVaultToken).safeTransfer(
                _toWhomToIssue,
                underlyingReceived
            );
            toTokensReceived = underlyingReceived;
        } else {
            if(_vaultType == 2) {
                toTokensReceived = _withdrawFromCurve(
                    underlyingVaultToken,
                    underlyingReceived,
                    _toWhomToIssue,
                    _ToTokenContractAddress,
                    _minTokensRec
                );
            } else if(_vaultType == 1) {
                 
                IAToken(underlyingVaultToken).redeem(underlyingReceived);
                address underlyingAsset = IAToken(underlyingVaultToken)
                        .underlyingAssetAddress();
                
                 
                if(_ToTokenContractAddress == address(0)) {
                    toTokensReceived = _token2Eth(
                        underlyingAsset,
                        underlyingReceived,
                        payable(_toWhomToIssue),
                        _minTokensRec
                    );
                } else {
                    toTokensReceived = _token2Token(
                        underlyingAsset,
                        _ToTokenContractAddress,
                        underlyingReceived,
                        _minTokensRec
                    );
                    IERC20(_ToTokenContractAddress).safeTransfer(
                        _toWhomToIssue,
                        toTokensReceived
                    );
                }
            } else {
                if(_ToTokenContractAddress == address(0)) {
                    toTokensReceived = _token2Eth(
                        underlyingVaultToken,
                        underlyingReceived,
                        payable(_toWhomToIssue),
                        _minTokensRec
                    );
                } else {
                    toTokensReceived = _token2Token(
                        underlyingVaultToken,
                        _ToTokenContractAddress,
                        underlyingReceived,
                        _minTokensRec
                    );
                    
                    IERC20(_ToTokenContractAddress).safeTransfer(
                        _toWhomToIssue,
                        toTokensReceived
                    );
                }
            }
        }
        
        emit Zapout(
            _toWhomToIssue,
            _fromYVaultAddress,
            _ToTokenContractAddress,
            toTokensReceived
        );
        
        return toTokensReceived;
    }
    
    function _withdrawFromCurve(
        address _CurvePoolToken,
        uint256 _tokenAmt,
        address _toWhomToIssue,
        address _ToTokenContractAddress,
        uint256 _minTokensRec
    ) internal returns(uint256) {
        IERC20(_CurvePoolToken).safeApprove(
            address(CurveZapOutGeneral),
            _tokenAmt
        );
        
        address curveExchangeAddr = token2Exchange[_CurvePoolToken];
        uint256 tokenCount = 4;
        
        if(curveExchangeAddr == sBtcCurveExchangeAddress) {
            tokenCount = 3;
        }
            
        return(
            CurveZapOutGeneral.ZapOut(
                payable(_toWhomToIssue),
                curveExchangeAddr,
                tokenCount,
                _tokenAmt,
                _ToTokenContractAddress,
                _minTokensRec
            )
        );
    }

     
    function _eth2Token(address _tokenContractAddress, uint256 minTokens)
        internal
        returns (uint256 tokensBought)
    {
        if(_tokenContractAddress == wethTokenAddress) {
            IWETH(wethTokenAddress).deposit{value: msg.value}();
            return msg.value;
        }

        address[] memory path = new address[](2);
        path[0] = wethTokenAddress;
        path[1] = _tokenContractAddress;
        tokensBought = uniswapRouter.swapExactETHForTokens{value: msg.value}(
            1,
            path,
            address(this),
            deadline
        )[path.length - 1];
        require(tokensBought >= minTokens, "ERR: High Slippage");
    }

     
    function _token2Token(
        address _FromTokenContractAddress,
        address _ToTokenContractAddress,
        uint256 tokens2Trade,
        uint256 minTokens
    ) internal returns (uint256 tokenBought) {
        if (_FromTokenContractAddress == _ToTokenContractAddress) {
            return tokens2Trade;
        }

        IERC20(_FromTokenContractAddress).safeApprove(
            address(uniswapRouter),
            tokens2Trade
        );

        if (_FromTokenContractAddress != wethTokenAddress) {
            if (_ToTokenContractAddress != wethTokenAddress) {
                address[] memory path = new address[](3);
                path[0] = _FromTokenContractAddress;
                path[1] = wethTokenAddress;
                path[2] = _ToTokenContractAddress;
                tokenBought = uniswapRouter.swapExactTokensForTokens(
                    tokens2Trade,
                    1,
                    path,
                    address(this),
                    deadline
                )[path.length - 1];
            } else {
                address[] memory path = new address[](2);
                path[0] = _FromTokenContractAddress;
                path[1] = wethTokenAddress;

                tokenBought = uniswapRouter.swapExactTokensForTokens(
                    tokens2Trade,
                    1,
                    path,
                    address(this),
                    deadline
                )[path.length - 1];
            }
        } else {
            address[] memory path = new address[](2);
            path[0] = wethTokenAddress;
            path[1] = _ToTokenContractAddress;
            tokenBought = uniswapRouter.swapExactTokensForTokens(
                tokens2Trade,
                1,
                path,
                address(this),
                deadline
            )[path.length - 1];
        }

        require(tokenBought > minTokens, "ERR: High Slippage");
    }
    
    function _token2Eth(
        address _FromTokenContractAddress,
        uint256 tokens2Trade,
        address payable _toWhomToIssue,
        uint256 minTokens
    ) internal returns (uint256) {
        if (_FromTokenContractAddress == wethTokenAddress) {
            IWETH(wethTokenAddress).withdraw(tokens2Trade);
            _toWhomToIssue.transfer(tokens2Trade);
            return tokens2Trade;
        }

        IERC20(_FromTokenContractAddress).safeApprove(
            address(uniswapRouter),
            tokens2Trade
        );

        address[] memory path = new address[](2);
        path[0] = _FromTokenContractAddress;
        path[1] = wethTokenAddress;
        uint256 ethBought = uniswapRouter.swapExactTokensForETH(
                            tokens2Trade,
                            1,
                            path,
                            _toWhomToIssue,
                            deadline
                        )[path.length - 1];
        
        require(ethBought > minTokens, "Error: High Slippage");
        return ethBought;
    }

     
    function _transferGoodwill(
        address _tokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 goodwillPortion) {
        goodwillPortion = SafeMath.div(
            SafeMath.mul(tokens2Trade, goodwill),
            10000
        );

        if (goodwillPortion == 0) {
            return 0;
        }

        IERC20(_tokenContractAddress).safeTransfer(
            zgoodwillAddress,
            goodwillPortion
        );
    }

    function set_new_goodwill(uint16 _new_goodwill) public onlyOwner {
        require(
            _new_goodwill >= 0 && _new_goodwill < 10000,
            "GoodWill Value not allowed"
        );
        goodwill = _new_goodwill;
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        IERC20(address(_TokenAddress)).safeTransfer(owner(), qty);
    }

     
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

     
    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        address payable _to = payable(owner());
        _to.transfer(contractBalance);
    }
    
    receive() external payable{}
}