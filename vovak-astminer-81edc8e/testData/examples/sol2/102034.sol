 

 

 

pragma solidity ^0.5.5;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;


            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function toPayable(address account)
        internal
        pure
        returns (address payable)
    {
        return address(uint160(account));
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

         
        (bool success, ) = recipient.call.value(amount)("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}

 

pragma solidity ^0.5.0;

 
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

 

pragma solidity ^0.5.0;

 
contract Context {
     
     
    constructor() internal {}

     

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

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

pragma solidity ^0.5.0;

 
contract ReentrancyGuard {
    bool private _notEntered;

    constructor() internal {
         
         
         
         
         
         
        _notEntered = true;
    }

     
    modifier nonReentrant() {
         
        require(_notEntered, "ReentrancyGuard: reentrant call");

         
        _notEntered = false;

        _;

         
         
        _notEntered = true;
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

 

 

 

 
 
 
 
 
 
 
 
 
 
 

 

 
 

pragma solidity 0.5.12;

interface IBFactory_Balancer_Unzap_V1_1 {
    function isBPool(address b) external view returns (bool);
}

interface IBPool_Balancer_Unzap_V1_1 {
    function exitswapPoolAmountIn(
        address tokenOut,
        uint256 poolAmountIn,
        uint256 minAmountOut
    ) external payable returns (uint256 tokenAmountOut);

    function totalSupply() external view returns (uint256);

    function getFinalTokens() external view returns (address[] memory tokens);

    function getDenormalizedWeight(address token)
        external
        view
        returns (uint256);

    function getTotalDenormalizedWeight() external view returns (uint256);

    function getSwapFee() external view returns (uint256);

    function isBound(address t) external view returns (bool);

    function calcSingleOutGivenPoolIn(
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 poolAmountIn,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountOut);

    function getBalance(address token) external view returns (uint256);
}

interface IuniswapFactory_Balancer_Unzap_V1_1 {
    function getExchange(address token)
        external
        view
        returns (address exchange);
}

interface Iuniswap_Balancer_Unzap_V1_1 {
     
    function tokenToTokenTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address recipient,
        address token_addr
    ) external returns (uint256 tokens_bought);

    function getTokenToEthInputPrice(uint256 tokens_sold)
        external
        view
        returns (uint256 eth_bought);

    function getEthToTokenInputPrice(uint256 eth_sold)
        external
        view
        returns (uint256 tokens_bought);

    function tokenToEthTransferInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline,
        address recipient
    ) external returns (uint256 eth_bought);

    function balanceOf(address _owner) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external returns (bool success);
}

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

contract Balancer_ZapOut_General_V2 is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address;
    bool private stopped = false;
    uint16 public goodwill;
    address public dzgoodwillAddress;

    IuniswapFactory_Balancer_Unzap_V1_1
        public UniSwapFactoryAddress = IuniswapFactory_Balancer_Unzap_V1_1(
        0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95
    );
    IBFactory_Balancer_Unzap_V1_1 BalancerFactory = IBFactory_Balancer_Unzap_V1_1(
        0x9424B1412450D0f8Fc2255FAf6046b98213B76Bd
    );

    address wethTokenAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    event Zapout(
        address _toWhomToIssue,
        address _fromBalancerPoolAddress,
        address _toTokenContractAddress,
        uint256 _OutgoingAmount
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

     
    function EasyZapOut(
        address _ToTokenContractAddress,
        address _FromBalancerPoolAddress,
        uint256 _IncomingBPT,
        uint256 _minTokensRec
    ) public payable nonReentrant stopInEmergency returns (uint256) {
        require(
            BalancerFactory.isBPool(_FromBalancerPoolAddress),
            "Invalid Balancer Pool"
        );

        address _FromTokenAddress;
        if (
            IBPool_Balancer_Unzap_V1_1(_FromBalancerPoolAddress).isBound(
                _ToTokenContractAddress
            )
        ) {
            _FromTokenAddress = _ToTokenContractAddress;
        } else if (
            _ToTokenContractAddress == address(0) &&
            IBPool_Balancer_Unzap_V1_1(_FromBalancerPoolAddress).isBound(
                wethTokenAddress
            )
        ) {
            _FromTokenAddress = wethTokenAddress;
        } else {
            _FromTokenAddress = _getBestDeal(
                _FromBalancerPoolAddress,
                _IncomingBPT
            );
        }

        return (
            _performZapOut(
                msg.sender,
                _ToTokenContractAddress,
                _FromBalancerPoolAddress,
                _IncomingBPT,
                _FromTokenAddress,
                _minTokensRec
            )
        );
    }

     
    function ZapOut(
        address payable _toWhomToIssue,
        address _ToTokenContractAddress,
        address _FromBalancerPoolAddress,
        uint256 _IncomingBPT,
        address _IntermediateToken,
        uint256 _minTokensRec
    ) public payable nonReentrant stopInEmergency returns (uint256) {
        return (
            _performZapOut(
                _toWhomToIssue,
                _ToTokenContractAddress,
                _FromBalancerPoolAddress,
                _IncomingBPT,
                _IntermediateToken,
                _minTokensRec
            )
        );
    }

     
    function _performZapOut(
        address payable _toWhomToIssue,
        address _ToTokenContractAddress,
        address _FromBalancerPoolAddress,
        uint256 _IncomingBPT,
        address _IntermediateToken,
        uint256 _minTokensRec
    ) internal returns (uint256) {
         
        uint256 goodwillPortion = _transferGoodwill(
            _FromBalancerPoolAddress,
            _IncomingBPT
        );

        require(
            IERC20(_FromBalancerPoolAddress).transferFrom(
                msg.sender,
                address(this),
                SafeMath.sub(_IncomingBPT, goodwillPortion)
            )
        );

        if (
            IBPool_Balancer_Unzap_V1_1(_FromBalancerPoolAddress).isBound(
                _ToTokenContractAddress
            )
        ) {
            return (
                _directZapout(
                    _FromBalancerPoolAddress,
                    _ToTokenContractAddress,
                    _toWhomToIssue,
                    SafeMath.sub(_IncomingBPT, goodwillPortion),
                    _minTokensRec
                )
            );
        }

         
        uint256 _returnedTokens = _exitBalancer(
            _FromBalancerPoolAddress,
            _IntermediateToken,
            SafeMath.sub(_IncomingBPT, goodwillPortion)
        );

        if (_ToTokenContractAddress == address(0)) {
            uint256 ethBought = _token2Eth(
                _IntermediateToken,
                _returnedTokens,
                _toWhomToIssue
            );

            require(ethBought >= _minTokensRec, "High slippage");
            emit Zapout(
                _toWhomToIssue,
                _FromBalancerPoolAddress,
                _ToTokenContractAddress,
                ethBought
            );
            return ethBought;
        } else {
            uint256 tokenBought = _token2Token(
                _IntermediateToken,
                _toWhomToIssue,
                _ToTokenContractAddress,
                _returnedTokens
            );
            require(tokenBought >= _minTokensRec, "High slippage");

            emit Zapout(
                _toWhomToIssue,
                _FromBalancerPoolAddress,
                _ToTokenContractAddress,
                tokenBought
            );
            return tokenBought;
        }
    }

     
    function _directZapout(
        address _FromBalancerPoolAddress,
        address _ToTokenContractAddress,
        address _toWhomToIssue,
        uint256 tokens2Trade,
        uint256 _minTokensRec
    ) internal returns (uint256 returnedTokens) {
        returnedTokens = _exitBalancer(
            _FromBalancerPoolAddress,
            _ToTokenContractAddress,
            tokens2Trade
        );

        require(returnedTokens >= _minTokensRec, "High slippage");

        emit Zapout(
            _toWhomToIssue,
            _FromBalancerPoolAddress,
            _ToTokenContractAddress,
            returnedTokens
        );

        IERC20(_ToTokenContractAddress).transfer(
            _toWhomToIssue,
            returnedTokens
        );
    }

     
    function _transferGoodwill(
        address _tokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 goodwillPortion) {
        if (goodwill == 0) {
            return 0;
        }

        goodwillPortion = SafeMath.div(
            SafeMath.mul(tokens2Trade, goodwill),
            10000
        );

        require(
            IERC20(_tokenContractAddress).transferFrom(
                msg.sender,
                dzgoodwillAddress,
                goodwillPortion
            ),
            "Error in transferring BPT:1"
        );
        return goodwillPortion;
    }

     
    function _getBestDeal(
        address _FromBalancerPoolAddress,
        uint256 _IncomingBPT
    ) internal view returns (address _token) {
         
        address[] memory tokens = IBPool_Balancer_Unzap_V1_1(
            _FromBalancerPoolAddress
        )
            .getFinalTokens();

        uint256 maxEth;

        for (uint256 index = 0; index < tokens.length; index++) {
             
            uint256 tokensForBPT = _getBPT2Token(
                _FromBalancerPoolAddress,
                _IncomingBPT,
                tokens[index]
            );

             

            Iuniswap_Balancer_Unzap_V1_1 FromUniSwapExchangeContractAddress
             = Iuniswap_Balancer_Unzap_V1_1(
                UniSwapFactoryAddress.getExchange(tokens[index])
            );

            if (address(FromUniSwapExchangeContractAddress) == address(0)) {
                continue;
            }
            uint256 ethReturned = FromUniSwapExchangeContractAddress
                .getTokenToEthInputPrice(tokensForBPT);

             
            if (maxEth < ethReturned) {
                maxEth = ethReturned;
                _token = tokens[index];
            }
        }
    }

     
    function _getBPT2Token(
        address _FromBalancerPoolAddress,
        uint256 _IncomingBPT,
        address _toToken
    ) internal view returns (uint256 tokensReturned) {
        uint256 totalSupply = IBPool_Balancer_Unzap_V1_1(
            _FromBalancerPoolAddress
        )
            .totalSupply();
        uint256 swapFee = IBPool_Balancer_Unzap_V1_1(_FromBalancerPoolAddress)
            .getSwapFee();
        uint256 totalWeight = IBPool_Balancer_Unzap_V1_1(
            _FromBalancerPoolAddress
        )
            .getTotalDenormalizedWeight();
        uint256 balance = IBPool_Balancer_Unzap_V1_1(_FromBalancerPoolAddress)
            .getBalance(_toToken);
        uint256 denorm = IBPool_Balancer_Unzap_V1_1(_FromBalancerPoolAddress)
            .getDenormalizedWeight(_toToken);

        tokensReturned = IBPool_Balancer_Unzap_V1_1(_FromBalancerPoolAddress)
            .calcSingleOutGivenPoolIn(
            balance,
            denorm,
            totalSupply,
            totalWeight,
            _IncomingBPT,
            swapFee
        );
    }

     
    function _exitBalancer(
        address _FromBalancerPoolAddress,
        address _ToTokenContractAddress,
        uint256 _amount
    ) internal returns (uint256 returnedTokens) {
        require(
            IBPool_Balancer_Unzap_V1_1(_FromBalancerPoolAddress).isBound(
                _ToTokenContractAddress
            ),
            "Token not bound"
        );

        uint256 minTokens = _getBPT2Token(
            _FromBalancerPoolAddress,
            _amount,
            _ToTokenContractAddress
        );
        minTokens = SafeMath.div(SafeMath.mul(minTokens, 98), 100);

        returnedTokens = IBPool_Balancer_Unzap_V1_1(_FromBalancerPoolAddress)
            .exitswapPoolAmountIn(_ToTokenContractAddress, _amount, minTokens);

        require(returnedTokens > 0, "Error in exiting balancer pool");
    }

     
    function _token2Token(
        address _FromTokenContractAddress,
        address _ToWhomToIssue,
        address _ToTokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 tokenBought) {

        Iuniswap_Balancer_Unzap_V1_1 FromUniSwapExchangeContractAddress
         = Iuniswap_Balancer_Unzap_V1_1(
            UniSwapFactoryAddress.getExchange(_FromTokenContractAddress)
        );

        IERC20(_FromTokenContractAddress).approve(
            address(FromUniSwapExchangeContractAddress),
            tokens2Trade
        );

        tokenBought = FromUniSwapExchangeContractAddress
            .tokenToTokenTransferInput(
            tokens2Trade,
            1,
            1,
            SafeMath.add(now, 300),
            _ToWhomToIssue,
            _ToTokenContractAddress
        );
        require(tokenBought > 0, "Error in swapping ERC: 1");
    }

     
    function _token2Eth(
        address _FromTokenContractAddress,
        uint256 tokens2Trade,
        address payable _toWhomToIssue
    ) internal returns (uint256 ethBought) {
        if (_FromTokenContractAddress == wethTokenAddress) {
            IWETH(wethTokenAddress).withdraw(tokens2Trade);
            _toWhomToIssue.transfer(tokens2Trade);
            return tokens2Trade;
        }


            Iuniswap_Balancer_Unzap_V1_1 FromUniSwapExchangeContractAddress
         = Iuniswap_Balancer_Unzap_V1_1(
            UniSwapFactoryAddress.getExchange(_FromTokenContractAddress)
        );

        IERC20(_FromTokenContractAddress).approve(
            address(FromUniSwapExchangeContractAddress),
            tokens2Trade
        );

        uint256 minEthBought = FromUniSwapExchangeContractAddress
            .getTokenToEthInputPrice(tokens2Trade);
        minEthBought = SafeMath.div(SafeMath.mul(minEthBought, 98), 100);

        ethBought = FromUniSwapExchangeContractAddress.tokenToEthTransferInput(
            tokens2Trade,
            minEthBought,
            SafeMath.add(now, 300),
            _toWhomToIssue
        );
        require(ethBought > 0, "Error in swapping Eth: 1");
    }

    function set_new_goodwill(uint16 _new_goodwill) public onlyOwner {
        require(
            _new_goodwill >= 0 && _new_goodwill < 10000,
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

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.transfer(owner(), qty);
    }

     
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

     
    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        address payable _to = owner().toPayable();
        _to.transfer(contractBalance);
    }

    function() external payable {}
}