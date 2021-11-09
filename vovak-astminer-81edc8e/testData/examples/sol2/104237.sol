 

pragma solidity ^0.5.2;
pragma experimental "ABIEncoderV2";

 
contract ReentrancyGuard {
     
    uint256 private _guardCounter;

    constructor () internal {
         
         
        _guardCounter = 1;
    }

     
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

 

pragma solidity ^0.5.2;

 
library SafeMath {
     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        require(b > 0);
        uint256 c = a / b;
         

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

 

 

pragma solidity 0.5.7;



library CommonMath {
    using SafeMath for uint256;

    uint256 public constant SCALE_FACTOR = 10 ** 18;
    uint256 public constant MAX_UINT_256 = 2 ** 256 - 1;

     
    function scaleFactor()
        internal
        pure
        returns (uint256)
    {
        return SCALE_FACTOR;
    }

     
    function maxUInt256()
        internal
        pure
        returns (uint256)
    {
        return MAX_UINT_256;
    }

     
    function scale(
        uint256 a
    )
        internal
        pure
        returns (uint256)
    {
        return a.mul(SCALE_FACTOR);
    }

     
    function deScale(
        uint256 a
    )
        internal
        pure
        returns (uint256)
    {
        return a.div(SCALE_FACTOR);
    }

     
    function safePower(
        uint256 a,
        uint256 pow
    )
        internal
        pure
        returns (uint256)
    {
        require(a > 0);

        uint256 result = 1;
        for (uint256 i = 0; i < pow; i++){
            uint256 previousResult = result;

             
            result = previousResult.mul(a);
        }

        return result;
    }

     
    function divCeil(uint256 a, uint256 b)
        internal
        pure
        returns(uint256)
    {
        return a.mod(b) > 0 ? a.div(b).add(1) : a.div(b);
    }

     
    function getPartialAmount(
        uint256 _principal,
        uint256 _numerator,
        uint256 _denominator
    )
        internal
        pure
        returns (uint256)
    {
         
        uint256 remainder = mulmod(_principal, _numerator, _denominator);

         
        if (remainder == 0) {
            return _principal.mul(_numerator).div(_denominator);
        }

         
        uint256 errPercentageTimes1000000 = remainder.mul(1000000).div(_numerator.mul(_principal));

         
        require(
            errPercentageTimes1000000 < 1000,
            "CommonMath.getPartialAmount: Rounding error exceeds bounds"
        );

        return _principal.mul(_numerator).div(_denominator);
    }

     
    function ceilLog10(
        uint256 _value
    )
        internal
        pure
        returns (uint256)
    {
         
        require (
            _value > 0,
            "CommonMath.ceilLog10: Value must be greater than zero."
        );

         
        if (_value == 1) return 0;

         
        uint256 x = _value - 1;

        uint256 result = 0;

        if (x >= 10 ** 64) {
            x /= 10 ** 64;
            result += 64;
        }
        if (x >= 10 ** 32) {
            x /= 10 ** 32;
            result += 32;
        }
        if (x >= 10 ** 16) {
            x /= 10 ** 16;
            result += 16;
        }
        if (x >= 10 ** 8) {
            x /= 10 ** 8;
            result += 8;
        }
        if (x >= 10 ** 4) {
            x /= 10 ** 4;
            result += 4;
        }
        if (x >= 100) {
            x /= 100;
            result += 2;
        }
        if (x >= 10) {
            result += 1;
        }

        return result + 1;
    }
}

 

 

pragma solidity 0.5.7;




 
library CompoundUtils
{
    using SafeMath for uint256;

     
    function convertCTokenToUnderlying(
        uint256 _cTokenAmount,
        uint256 _cTokenExchangeRate
    )
    internal
    pure
    returns (uint256)
    {
         
        uint256 a = _cTokenAmount.mul(_cTokenExchangeRate);
        uint256 b = CommonMath.scaleFactor();

         
        return CommonMath.divCeil(a, b);
    }
}

 

 

pragma solidity 0.5.7;


 
interface IERC20 {
    function balanceOf(
        address _owner
    )
        external
        view
        returns (uint256);

    function allowance(
        address _owner,
        address _spender
    )
        external
        view
        returns (uint256);

    function transfer(
        address _to,
        uint256 _quantity
    )
        external;

    function transferFrom(
        address _from,
        address _to,
        uint256 _quantity
    )
        external;

    function approve(
        address _spender,
        uint256 _quantity
    )
        external
        returns (bool);

    function totalSupply()
        external
        returns (uint256);
}

 

 

pragma solidity 0.5.7;




 
library ERC20Wrapper {

     

     
    function balanceOf(
        address _token,
        address _owner
    )
        external
        view
        returns (uint256)
    {
        return IERC20(_token).balanceOf(_owner);
    }

     
    function allowance(
        address _token,
        address _owner,
        address _spender
    )
        internal
        view
        returns (uint256)
    {
        return IERC20(_token).allowance(_owner, _spender);
    }

     
    function transfer(
        address _token,
        address _to,
        uint256 _quantity
    )
        external
    {
        IERC20(_token).transfer(_to, _quantity);

         
        require(
            checkSuccess(),
            "ERC20Wrapper.transfer: Bad return value"
        );
    }

     
    function transferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _quantity
    )
        external
    {
        IERC20(_token).transferFrom(_from, _to, _quantity);

         
        require(
            checkSuccess(),
            "ERC20Wrapper.transferFrom: Bad return value"
        );
    }

     
    function approve(
        address _token,
        address _spender,
        uint256 _quantity
    )
        internal
    {
        IERC20(_token).approve(_spender, _quantity);

         
        require(
            checkSuccess(),
            "ERC20Wrapper.approve: Bad return value"
        );
    }

     
    function ensureAllowance(
        address _token,
        address _owner,
        address _spender,
        uint256 _quantity
    )
        internal
    {
        uint256 currentAllowance = allowance(_token, _owner, _spender);
        if (currentAllowance < _quantity) {
            approve(
                _token,
                _spender,
                CommonMath.maxUInt256()
            );
        }
    }

     

     
    function checkSuccess(
    )
        private
        pure
        returns (bool)
    {
         
        uint256 returnValue = 0;

        assembly {
             
            switch returndatasize

             
            case 0x0 {
                returnValue := 1
            }

             
            case 0x20 {
                 
                returndatacopy(0x0, 0x0, 0x20)

                 
                returnValue := mload(0x0)
            }

             
            default { }
        }

         
        return returnValue == 1;
    }
}

 

 

pragma solidity 0.5.7;


 
interface ICToken {

     
    function exchangeRateCurrent()
        external
        returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function decimals() external view returns(uint8);

     
    function mint(uint mintAmount) external returns (uint);

     
    function redeem(uint redeemTokens) external returns (uint);
}

 

 

pragma solidity 0.5.7;

 

interface IRebalanceAuctionModule {
     
    function bidAndWithdraw(
        address _rebalancingSetToken,
        uint256 _quantity,
        bool _allowPartialFill
    )
        external;
}

 

 

pragma solidity 0.5.7;


 
library RebalancingLibrary {

     

    enum State { Default, Proposal, Rebalance, Drawdown }

     

    struct AuctionPriceParameters {
        uint256 auctionStartTime;
        uint256 auctionTimeToPivot;
        uint256 auctionStartPrice;
        uint256 auctionPivotPrice;
    }

    struct BiddingParameters {
        uint256 minimumBid;
        uint256 remainingCurrentSets;
        uint256[] combinedCurrentUnits;
        uint256[] combinedNextSetUnits;
        address[] combinedTokenArray;
    }
}

 

 

pragma solidity 0.5.7;


 

interface IRebalancingSetToken {

     
    function auctionLibrary()
        external
        view
        returns (address);

     
    function totalSupply()
        external
        view
        returns (uint256);

     
    function proposalStartTime()
        external
        view
        returns (uint256);

     
    function lastRebalanceTimestamp()
        external
        view
        returns (uint256);

     
    function rebalanceInterval()
        external
        view
        returns (uint256);

     
    function rebalanceState()
        external
        view
        returns (RebalancingLibrary.State);

     
    function startingCurrentSetAmount()
        external
        view
        returns (uint256);

     
    function balanceOf(
        address owner
    )
        external
        view
        returns (uint256);

     
    function propose(
        address _nextSet,
        address _auctionLibrary,
        uint256 _auctionTimeToPivot,
        uint256 _auctionStartPrice,
        uint256 _auctionPivotPrice
    )
        external;

     
    function naturalUnit()
        external
        view
        returns (uint256);

     
    function currentSet()
        external
        view
        returns (address);

     
    function nextSet()
        external
        view
        returns (address);

     
    function unitShares()
        external
        view
        returns (uint256);

     
    function burn(
        address _from,
        uint256 _quantity
    )
        external;

     
    function placeBid(
        uint256 _quantity
    )
        external
        returns (address[] memory, uint256[] memory, uint256[] memory);

     
    function getCombinedTokenArrayLength()
        external
        view
        returns (uint256);

     
    function getCombinedTokenArray()
        external
        view
        returns (address[] memory);

     
    function getFailedAuctionWithdrawComponents()
        external
        view
        returns (address[] memory);

     
    function getAuctionPriceParameters()
        external
        view
        returns (uint256[] memory);

     
    function getBiddingParameters()
        external
        view
        returns (uint256[] memory);

     
    function getBidPrice(
        uint256 _quantity
    )
        external
        view
        returns (uint256[] memory, uint256[] memory);

}

 

 

pragma solidity 0.5.7;

 
interface IFeeCalculator {

     

    function initialize(
        bytes calldata _feeCalculatorData
    )
        external;

    function getFee()
        external
        view
        returns(uint256);

    function updateAndGetFee()
        external
        returns(uint256);

    function adjustFee(
        bytes calldata _newFeeData
    )
        external;
}

 

 

pragma solidity 0.5.7;

 
interface ISetToken {

     

     
    function naturalUnit()
        external
        view
        returns (uint256);

     
    function getComponents()
        external
        view
        returns (address[] memory);

     
    function getUnits()
        external
        view
        returns (uint256[] memory);

     
    function tokenIsComponent(
        address _tokenAddress
    )
        external
        view
        returns (bool);

     
    function mint(
        address _issuer,
        uint256 _quantity
    )
        external;

     
    function burn(
        address _from,
        uint256 _quantity
    )
        external;

     
    function transfer(
        address to,
        uint256 value
    )
        external;
}

 

 

pragma solidity 0.5.7;



 
library Rebalance {

    struct TokenFlow {
        address[] addresses;
        uint256[] inflow;
        uint256[] outflow;
    }

    function composeTokenFlow(
        address[] memory _addresses,
        uint256[] memory _inflow,
        uint256[] memory _outflow
    )
        internal
        pure
        returns(TokenFlow memory)
    {
        return TokenFlow({addresses: _addresses, inflow: _inflow, outflow: _outflow });
    }

    function decomposeTokenFlow(TokenFlow memory _tokenFlow)
        internal
        pure
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {
        return (_tokenFlow.addresses, _tokenFlow.inflow, _tokenFlow.outflow);
    }

    function decomposeTokenFlowToBidPrice(TokenFlow memory _tokenFlow)
        internal
        pure
        returns (uint256[] memory, uint256[] memory)
    {
        return (_tokenFlow.inflow, _tokenFlow.outflow);
    }

     
    function getTokenFlows(
        IRebalancingSetToken _rebalancingSetToken,
        uint256 _quantity
    )
        internal
        view
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {
         
        address[] memory combinedTokenArray = _rebalancingSetToken.getCombinedTokenArray();

         
        (
            uint256[] memory inflowArray,
            uint256[] memory outflowArray
        ) = _rebalancingSetToken.getBidPrice(_quantity);

        return (combinedTokenArray, inflowArray, outflowArray);
    }
}

 

 

pragma solidity 0.5.7;




 
interface ILiquidator {

     

    function startRebalance(
        ISetToken _currentSet,
        ISetToken _nextSet,
        uint256 _startingCurrentSetQuantity,
        bytes calldata _liquidatorData
    )
        external;

    function getBidPrice(
        address _set,
        uint256 _quantity
    )
        external
        view
        returns (Rebalance.TokenFlow memory);

    function placeBid(
        uint256 _quantity
    )
        external
        returns (Rebalance.TokenFlow memory);


    function settleRebalance()
        external;

    function endFailedRebalance() external;

     
     
     

    function auctionPriceParameters(address _set)
        external
        view
        returns (RebalancingLibrary.AuctionPriceParameters memory);

     
     
     

    function hasRebalanceFailed(address _set) external view returns (bool);
    function minimumBid(address _set) external view returns (uint256);
    function startingCurrentSets(address _set) external view returns (uint256);
    function remainingCurrentSets(address _set) external view returns (uint256);
    function getCombinedCurrentSetUnits(address _set) external view returns (uint256[] memory);
    function getCombinedNextSetUnits(address _set) external view returns (uint256[] memory);
    function getCombinedTokenArray(address _set) external view returns (address[] memory);
}

 

 

pragma solidity 0.5.7;





 

interface IRebalancingSetTokenV3 {

     
    function totalSupply()
        external
        view
        returns (uint256);

     
    function liquidator()
        external
        view
        returns (ILiquidator);

     
    function lastRebalanceTimestamp()
        external
        view
        returns (uint256);

     
    function rebalanceStartTime()
        external
        view
        returns (uint256);

     
    function startingCurrentSetAmount()
        external
        view
        returns (uint256);

     
    function rebalanceInterval()
        external
        view
        returns (uint256);

     
    function rebalanceFailPeriod()
        external
        view
        returns (uint256);

     
    function getAuctionPriceParameters() external view returns (uint256[] memory);

     
    function getBiddingParameters() external view returns (uint256[] memory);

     
    function rebalanceState()
        external
        view
        returns (RebalancingLibrary.State);

     
    function balanceOf(
        address owner
    )
        external
        view
        returns (uint256);

     
    function manager()
        external
        view
        returns (address);

     
    function feeRecipient()
        external
        view
        returns (address);

     
    function entryFee()
        external
        view
        returns (uint256);

     
    function rebalanceFee()
        external
        view
        returns (uint256);

     
    function rebalanceFeeCalculator()
        external
        view
        returns (IFeeCalculator);

     
    function initialize(
        bytes calldata _rebalanceFeeCalldata
    )
        external;

     
    function setLiquidator(
        ILiquidator _newLiquidator
    )
        external;

     
    function setFeeRecipient(
        address _newFeeRecipient
    )
        external;

     
    function setEntryFee(
        uint256 _newEntryFee
    )
        external;

     
    function startRebalance(
        address _nextSet,
        bytes calldata _liquidatorData

    )
        external;

     
    function settleRebalance()
        external;

     
    function actualizeFee()
        external;

     
    function adjustFee(
        bytes calldata _newFeeData
    )
        external;

     
    function naturalUnit()
        external
        view
        returns (uint256);

     
    function currentSet()
        external
        view
        returns (ISetToken);

     
    function nextSet()
        external
        view
        returns (ISetToken);

     
    function unitShares()
        external
        view
        returns (uint256);

     
    function placeBid(
        uint256 _quantity
    )
        external
        returns (address[] memory, uint256[] memory, uint256[] memory);

     
    function getBidPrice(
        uint256 _quantity
    )
        external
        view
        returns (uint256[] memory, uint256[] memory);

     
    function name()
        external
        view
        returns (string memory);

     
    function symbol()
        external
        view
        returns (string memory);
}

 

 

pragma solidity 0.5.7;

 
interface ITransferProxy {

     

     
    function transfer(
        address _token,
        uint256 _quantity,
        address _from,
        address _to
    )
        external;

     
    function batchTransfer(
        address[] calldata _tokens,
        uint256[] calldata _quantities,
        address _from,
        address _to
    )
        external;
}

 

 

pragma solidity 0.5.7;


 
interface ITWAPAuctionGetters {

    function getOrderSize(address _set) external view returns (uint256);

    function getOrderRemaining(address _set) external view returns (uint256);

    function getTotalSetsRemaining(address _set) external view returns (uint256);

    function getChunkSize(address _set) external view returns (uint256);

    function getChunkAuctionPeriod(address _set) external view returns (uint256);

    function getLastChunkAuctionEnd(address _set) external view returns (uint256);
}

 

 

pragma solidity 0.5.7;














 
contract RebalancingSetCTokenBidder is
    ReentrancyGuard
{
    using SafeMath for uint256;

     
    IRebalanceAuctionModule public rebalanceAuctionModule;

     
    ITransferProxy public transferProxy;

     
    mapping (address => address) public cTokenToUnderlying;

    string public dataDescription;

     

    event BidPlacedCToken(
        address indexed rebalancingSetToken,
        address indexed bidder,
        uint256 quantity
    );

     

     
    constructor(
        IRebalanceAuctionModule _rebalanceAuctionModule,
        ITransferProxy _transferProxy,
        address[] memory _cTokenArray,
        address[] memory _underlyingArray,
        string memory _dataDescription
    )
        public
    {
        rebalanceAuctionModule = _rebalanceAuctionModule;

        transferProxy = _transferProxy;

        dataDescription = _dataDescription;

        require(
            _cTokenArray.length == _underlyingArray.length,
            "RebalancingSetCTokenBidder.constructor: cToken array and underlying array must be same length"
        );

        for (uint256 i = 0; i < _cTokenArray.length; i++) {
            address cTokenAddress = _cTokenArray[i];
            address underlyingAddress = _underlyingArray[i];

             
            cTokenToUnderlying[cTokenAddress] = underlyingAddress;

             
            ERC20Wrapper.approve(
                underlyingAddress,
                cTokenAddress,
                CommonMath.maxUInt256()
            );

             
            ERC20Wrapper.approve(
                cTokenAddress,
                address(_transferProxy),
                CommonMath.maxUInt256()
            );
        }
    }

     

     

    function bidAndWithdraw(
        IRebalancingSetToken _rebalancingSetToken,
        uint256 _quantity,
        bool _allowPartialFill
    )
        public
    {
         
        (
            address[] memory combinedTokenArray,
            uint256[] memory inflowUnitsArray,
            uint256[] memory outflowUnitsArray
        ) = Rebalance.getTokenFlows(_rebalancingSetToken, _quantity);

         
        depositComponents(
            combinedTokenArray,
            inflowUnitsArray
        );

         
        rebalanceAuctionModule.bidAndWithdraw(
            address(_rebalancingSetToken),
            _quantity,
            _allowPartialFill
        );

         
        withdrawComponentsToSender(
            combinedTokenArray
        );

         
        emit BidPlacedCToken(
            address(_rebalancingSetToken),
            msg.sender,
            _quantity
        );
    }

     

    function bidAndWithdrawTWAP(
        IRebalancingSetTokenV3 _rebalancingSetToken,
        uint256 _quantity,
        uint256 _lastChunkTimestamp,
        bool _allowPartialFill
    )
        external
    {
        address liquidatorAddress = address(_rebalancingSetToken.liquidator());
        address rebalancingSetTokenAddress = address(_rebalancingSetToken);

        uint256 lastChunkAuctionEnd = ITWAPAuctionGetters(liquidatorAddress).getLastChunkAuctionEnd(rebalancingSetTokenAddress);

        require(
            lastChunkAuctionEnd == _lastChunkTimestamp,
            "RebalancingSetCTokenBidder.bidAndWithdrawTWAP: Bid must be for intended chunk"
        );

        bidAndWithdraw(
            IRebalancingSetToken(rebalancingSetTokenAddress),
            _quantity,
            _allowPartialFill
        );
    }

     
    function getAddressAndBidPriceArray(
        IRebalancingSetToken _rebalancingSetToken,
        uint256 _quantity
    )
        external
        view
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {
         
        (
            address[] memory combinedTokenArray,
            uint256[] memory inflowUnitsArray,
            uint256[] memory outflowUnitsArray
        ) = Rebalance.getTokenFlows(_rebalancingSetToken, _quantity);

         
        for (uint256 i = 0; i < combinedTokenArray.length; i++) {
            address currentComponentAddress = combinedTokenArray[i];

             
            address underlyingAddress = cTokenToUnderlying[currentComponentAddress];
            if (underlyingAddress != address(0)) {
                combinedTokenArray[i] = underlyingAddress;

                 
                 
                uint256 exchangeRate = ICToken(currentComponentAddress).exchangeRateStored();
                uint256 currentInflowQuantity = inflowUnitsArray[i];
                uint256 currentOutflowQuantity = outflowUnitsArray[i];

                inflowUnitsArray[i] = CompoundUtils.convertCTokenToUnderlying(currentInflowQuantity, exchangeRate);
                outflowUnitsArray[i] = CompoundUtils.convertCTokenToUnderlying(currentOutflowQuantity, exchangeRate);
            }
        }

        return (combinedTokenArray, inflowUnitsArray, outflowUnitsArray);
    }

     

     
    function depositComponents(
        address[] memory _combinedTokenArray,
        uint256[] memory _inflowUnitsArray
    )
        private
    {
         
        for (uint256 i = 0; i < _combinedTokenArray.length; i++) {
            address currentComponentAddress = _combinedTokenArray[i];
            uint256 currentComponentQuantity = _inflowUnitsArray[i];

             
            if (currentComponentQuantity > 0) {
                 
                ERC20Wrapper.ensureAllowance(
                    currentComponentAddress,
                    address(this),
                    address(transferProxy),
                    currentComponentQuantity
                );

                 
                 
                address underlyingAddress = cTokenToUnderlying[currentComponentAddress];
                if (underlyingAddress != address(0)) {
                    ICToken cTokenInstance = ICToken(currentComponentAddress);

                     
                    uint256 exchangeRate = cTokenInstance.exchangeRateCurrent();
                    uint256 underlyingQuantity = CompoundUtils.convertCTokenToUnderlying(currentComponentQuantity, exchangeRate);

                     
                    ERC20Wrapper.transferFrom(
                        underlyingAddress,
                        msg.sender,
                        address(this),
                        underlyingQuantity
                    );

                     
                    ERC20Wrapper.ensureAllowance(
                        underlyingAddress,
                        address(this),
                        address(cTokenInstance),
                        underlyingQuantity
                    );

                     
                    uint256 mintResponse = cTokenInstance.mint(underlyingQuantity);
                    require(
                        mintResponse == 0,
                        "RebalancingSetCTokenBidder.bidAndWithdraw: Error minting cToken"
                    );
                } else {
                     
                    ERC20Wrapper.transferFrom(
                        currentComponentAddress,
                        msg.sender,
                        address(this),
                        currentComponentQuantity
                    );
                }
            }
        }
    }

     
    function withdrawComponentsToSender(
        address[] memory _combinedTokenArray
    )
        private
    {
         
        for (uint256 i = 0; i < _combinedTokenArray.length; i++) {
            address currentComponentAddress = _combinedTokenArray[i];

             
            uint256 currentComponentBalance = ERC20Wrapper.balanceOf(
                currentComponentAddress,
                address(this)
            );

             
            if (currentComponentBalance > 0) {
                 
                address underlyingAddress = cTokenToUnderlying[currentComponentAddress];
                if (underlyingAddress != address(0)) {
                     
                    uint256 mintResponse = ICToken(currentComponentAddress).redeem(currentComponentBalance);
                    require(
                        mintResponse == 0,
                        "RebalancingSetCTokenBidder.bidAndWithdraw: Erroring redeeming cToken"
                    );

                     
                    uint256 underlyingComponentBalance = ERC20Wrapper.balanceOf(
                        underlyingAddress,
                        address(this)
                    );

                     
                    ERC20Wrapper.transfer(
                        underlyingAddress,
                        msg.sender,
                        underlyingComponentBalance
                    );
                } else {
                     
                    ERC20Wrapper.transfer(
                        currentComponentAddress,
                        msg.sender,
                        currentComponentBalance
                    );
                }
            }
        }
    }
}