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



library ScaleValidations {
    using SafeMath for uint256;

    uint256 private constant ONE_HUNDRED_PERCENT = 1e18;
    uint256 private constant ONE_BASIS_POINT = 1e14;

    function validateLessThanEqualOneHundredPercent(uint256 _value) internal view {
        require(_value <= ONE_HUNDRED_PERCENT, "Must be <= 100%");
    }

    function validateMultipleOfBasisPoint(uint256 _value) internal view {
        require(
            _value.mod(ONE_BASIS_POINT) == 0,
            "Must be multiple of 0.01%"
        );
    }
}

 

 

pragma solidity 0.5.7;


 
interface ICore {
     
    function transferProxy()
        external
        view
        returns (address);

     
    function vault()
        external
        view
        returns (address);

     
    function exchangeIds(
        uint8 _exchangeId
    )
        external
        view
        returns (address);

     
    function validSets(address)
        external
        view
        returns (bool);

     
    function validModules(address)
        external
        view
        returns (bool);

     
    function validPriceLibraries(
        address _priceLibrary
    )
        external
        view
        returns (bool);

     
    function issue(
        address _set,
        uint256 _quantity
    )
        external;

     
    function issueTo(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;

     
    function issueInVault(
        address _set,
        uint256 _quantity
    )
        external;

     
    function redeem(
        address _set,
        uint256 _quantity
    )
        external;

     
    function redeemTo(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;

     
    function redeemInVault(
        address _set,
        uint256 _quantity
    )
        external;

     
    function redeemAndWithdrawTo(
        address _set,
        address _to,
        uint256 _quantity,
        uint256 _toExclude
    )
        external;

     
    function batchDeposit(
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;

     
    function batchWithdraw(
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;

     
    function deposit(
        address _token,
        uint256 _quantity
    )
        external;

     
    function withdraw(
        address _token,
        uint256 _quantity
    )
        external;

     
    function internalTransfer(
        address _token,
        address _to,
        uint256 _quantity
    )
        external;

     
    function createSet(
        address _factory,
        address[] calldata _components,
        uint256[] calldata _units,
        uint256 _naturalUnit,
        bytes32 _name,
        bytes32 _symbol,
        bytes calldata _callData
    )
        external
        returns (address);

     
    function depositModule(
        address _from,
        address _to,
        address _token,
        uint256 _quantity
    )
        external;

     
    function withdrawModule(
        address _from,
        address _to,
        address _token,
        uint256 _quantity
    )
        external;

     
    function batchDepositModule(
        address _from,
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;

     
    function batchWithdrawModule(
        address _from,
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;

     
    function issueModule(
        address _owner,
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;

     
    function redeemModule(
        address _burnAddress,
        address _incrementAddress,
        address _set,
        uint256 _quantity
    )
        external;

     
    function batchIncrementTokenOwnerModule(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;

     
    function batchDecrementTokenOwnerModule(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;

     
    function batchTransferBalanceModule(
        address[] calldata _tokens,
        address _from,
        address _to,
        uint256[] calldata _quantities
    )
        external;

     
    function transferModule(
        address _token,
        uint256 _quantity,
        address _from,
        address _to
    )
        external;

     
    function batchTransferModule(
        address[] calldata _tokens,
        uint256[] calldata _quantities,
        address _from,
        address _to
    )
        external;
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

 
interface IOracleWhiteList {

     

     
    function oracleWhiteList(
        address _tokenAddress
    )
        external
        view
        returns (address);

     
    function areValidAddresses(
        address[] calldata _addresses
    )
        external
        view
        returns (bool);

     
    function getOracleAddressesByToken(
        address[] calldata _tokenAddresses
    )
        external
        view
        returns (address[] memory);

    function getOracleAddressByToken(
        address _token
    )
        external
        view
        returns (address);
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





 

interface IRebalancingSetTokenV2 {

     
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


 
library PerformanceFeeLibrary {

     

    struct FeeState {
        uint256 profitFeePeriod;                 
        uint256 highWatermarkResetPeriod;        
        uint256 profitFeePercentage;             
        uint256 streamingFeePercentage;          
        uint256 highWatermark;                   
        uint256 lastProfitFeeTimestamp;          
        uint256 lastStreamingFeeTimestamp;       
    }
}

 

pragma solidity ^0.5.2;

 
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity ^0.5.2;


 
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

 

pragma solidity ^0.5.2;

 
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

 

 
 

pragma solidity 0.5.7;


library AddressArrayUtils {

     
    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {
        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (0, false);
    }

     
    function contains(address[] memory A, address a) internal pure returns (bool) {
        bool isIn;
        (, isIn) = indexOf(A, a);
        return isIn;
    }

     
    function extend(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        uint256 aLength = A.length;
        uint256 bLength = B.length;
        address[] memory newAddresses = new address[](aLength + bLength);
        for (uint256 i = 0; i < aLength; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = 0; j < bLength; j++) {
            newAddresses[aLength + j] = B[j];
        }
        return newAddresses;
    }

     
    function append(address[] memory A, address a) internal pure returns (address[] memory) {
        address[] memory newAddresses = new address[](A.length + 1);
        for (uint256 i = 0; i < A.length; i++) {
            newAddresses[i] = A[i];
        }
        newAddresses[A.length] = a;
        return newAddresses;
    }

     
    function intersect(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        uint256 length = A.length;
        bool[] memory includeMap = new bool[](length);
        uint256 newLength = 0;
        for (uint256 i = 0; i < length; i++) {
            if (contains(B, A[i])) {
                includeMap[i] = true;
                newLength++;
            }
        }
        address[] memory newAddresses = new address[](newLength);
        uint256 j = 0;
        for (uint256 k = 0; k < length; k++) {
            if (includeMap[k]) {
                newAddresses[j] = A[k];
                j++;
            }
        }
        return newAddresses;
    }

     
    function union(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        address[] memory leftDifference = difference(A, B);
        address[] memory rightDifference = difference(B, A);
        address[] memory intersection = intersect(A, B);
        return extend(leftDifference, extend(intersection, rightDifference));
    }

     
    function difference(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        uint256 length = A.length;
        bool[] memory includeMap = new bool[](length);
        uint256 count = 0;
         
        for (uint256 i = 0; i < length; i++) {
            address e = A[i];
            if (!contains(B, e)) {
                includeMap[i] = true;
                count++;
            }
        }
        address[] memory newAddresses = new address[](count);
        uint256 j = 0;
        for (uint256 k = 0; k < length; k++) {
            if (includeMap[k]) {
                newAddresses[j] = A[k];
                j++;
            }
        }
        return newAddresses;
    }

     
    function pop(address[] memory A, uint256 index)
        internal
        pure
        returns (address[] memory, address)
    {
        uint256 length = A.length;
        address[] memory newAddresses = new address[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newAddresses[j - 1] = A[j];
        }
        return (newAddresses, A[index]);
    }

     
    function remove(address[] memory A, address a)
        internal
        pure
        returns (address[] memory)
    {
        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert();
        } else {
            (address[] memory _A,) = pop(A, index);
            return _A;
        }
    }

     
    function hasDuplicate(address[] memory A) internal pure returns (bool) {
        if (A.length == 0) {
            return false;
        }
        for (uint256 i = 0; i < A.length - 1; i++) {
            for (uint256 j = i + 1; j < A.length; j++) {
                if (A[i] == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }

     
    function isEqual(address[] memory A, address[] memory B) internal pure returns (bool) {
        if (A.length != B.length) {
            return false;
        }
        for (uint256 i = 0; i < A.length; i++) {
            if (A[i] != B[i]) {
                return false;
            }
        }
        return true;
    }
}

 

 

pragma solidity 0.5.7;


 
interface IOracle {

     
    function read()
        external
        view
        returns (uint256);
}

 

 

pragma solidity 0.5.7;



 
library SetMath {
    using SafeMath for uint256;


     
    function setToComponent(
        uint256 _setQuantity,
        uint256 _componentUnit,
        uint256 _naturalUnit
    )
        internal
        pure
        returns(uint256)
    {
        return _setQuantity.mul(_componentUnit).div(_naturalUnit);
    }

     
    function componentToSet(
        uint256 _componentQuantity,
        uint256 _componentUnit,
        uint256 _naturalUnit
    )
        internal
        pure
        returns(uint256)
    {
        return _componentQuantity.mul(_naturalUnit).div(_componentUnit);
    }
}

 

 

pragma solidity 0.5.7;












 
library SetUSDValuation {
    using SafeMath for uint256;
    using AddressArrayUtils for address[];

    uint256 constant public SET_FULL_UNIT = 10 ** 18;

     


     
    function calculateRebalancingSetValue(
        address _rebalancingSetTokenAddress,
        IOracleWhiteList _oracleWhitelist
    )
        internal
        view
        returns (uint256)
    {
        IRebalancingSetTokenV2 rebalancingSetToken = IRebalancingSetTokenV2(_rebalancingSetTokenAddress);

        uint256 unitShares = rebalancingSetToken.unitShares();
        uint256 naturalUnit = rebalancingSetToken.naturalUnit();
        ISetToken currentSet = rebalancingSetToken.currentSet();

         
        uint256 collateralValue = calculateSetTokenDollarValue(
            currentSet,
            _oracleWhitelist
        );

         
        return collateralValue.mul(unitShares).div(naturalUnit);
    }

     
    function calculateSetTokenDollarValue(
        ISetToken _set,
        IOracleWhiteList _oracleWhitelist
    )
        internal
        view
        returns (uint256)
    {
        uint256 setDollarAmount = 0;

        address[] memory components = _set.getComponents();
        uint256[] memory units = _set.getUnits();
        uint256 naturalUnit = _set.naturalUnit();

         
        for (uint256 i = 0; i < components.length; i++) {
            address currentComponent = components[i];

            address oracle = _oracleWhitelist.getOracleAddressByToken(currentComponent);
            uint256 price = IOracle(oracle).read();
            uint256 decimals = ERC20Detailed(currentComponent).decimals();

             
            uint256 tokenDollarValue = calculateTokenAllocationAmountUSD(
                price,
                naturalUnit,
                units[i],
                decimals
            );

             
            setDollarAmount = setDollarAmount.add(tokenDollarValue);
        }

        return setDollarAmount;
    }

     
    function calculateTokenAllocationAmountUSD(
        uint256 _tokenPrice,
        uint256 _naturalUnit,
        uint256 _unit,
        uint256 _tokenDecimal
    )
        internal
        pure
        returns (uint256)
    {
        uint256 tokenFullUnit = 10 ** _tokenDecimal;

         
        uint256 componentUnitsInFullToken = SetMath.setToComponent(
            SET_FULL_UNIT,
            _unit,
            _naturalUnit
        );

         
        uint256 allocationUSDValue = _tokenPrice
            .mul(componentUnitsInFullToken)
            .div(tokenFullUnit);

        require(
            allocationUSDValue > 0,
            "SetUSDValuation.calculateTokenAllocationAmountUSD: Value must be > 0"
        );

        return allocationUSDValue;
    }
}

 

 

pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;












 
contract PerformanceFeeCalculator is IFeeCalculator {

    using SafeMath for uint256;
    using CommonMath for uint256;

     

    enum FeeType { StreamingFee, ProfitFee }

     

    event FeeActualization(
        address indexed rebalancingSetToken,
        uint256 newHighWatermark,
        uint256 profitFee,
        uint256 streamingFee
    );

    event FeeInitialization(
        address indexed rebalancingSetToken,
        uint256 profitFeePeriod,
        uint256 highWatermarkResetPeriod,
        uint256 profitFeePercentage,
        uint256 streamingFeePercentage,
        uint256 highWatermark,
        uint256 lastProfitFeeTimestamp,
        uint256 lastStreamingFeeTimestamp
    );

    event FeeAdjustment(
        address indexed rebalancingSetToken,
        FeeType feeType,
        uint256 newFeePercentage
    );

     

    struct InitFeeParameters {
        uint256 profitFeePeriod;
        uint256 highWatermarkResetPeriod;
        uint256 profitFeePercentage;
        uint256 streamingFeePercentage;
    }

     
     
    uint256 private constant ONE_YEAR_IN_SECONDS = 365.25 days;
    uint256 private constant ONE_HUNDRED_PERCENT = 1e18;
    uint256 private constant ZERO = 0;

     
    ICore public core;
    IOracleWhiteList public oracleWhiteList;
    uint256 public maximumProfitFeePercentage;
    uint256 public maximumStreamingFeePercentage;
    mapping(address => PerformanceFeeLibrary.FeeState) public feeState;

     

     
    constructor(
        ICore _core,
        IOracleWhiteList _oracleWhiteList,
        uint256 _maximumProfitFeePercentage,
        uint256 _maximumStreamingFeePercentage
    )
        public
    {
        core = _core;
        oracleWhiteList = _oracleWhiteList;
        maximumProfitFeePercentage = _maximumProfitFeePercentage;
        maximumStreamingFeePercentage = _maximumStreamingFeePercentage;
    }

     

     
    function initialize(
        bytes calldata _feeCalculatorData
    )
        external
    {
         
        InitFeeParameters memory parameters = parsePerformanceFeeCallData(_feeCalculatorData);

         
        validateFeeParameters(parameters);
        uint256 highWatermark = SetUSDValuation.calculateRebalancingSetValue(msg.sender, oracleWhiteList);

         
        PerformanceFeeLibrary.FeeState storage feeInfo = feeState[msg.sender];

        feeInfo.profitFeePeriod = parameters.profitFeePeriod;
        feeInfo.highWatermarkResetPeriod = parameters.highWatermarkResetPeriod;
        feeInfo.profitFeePercentage = parameters.profitFeePercentage;
        feeInfo.streamingFeePercentage = parameters.streamingFeePercentage;
        feeInfo.lastProfitFeeTimestamp = block.timestamp;
        feeInfo.lastStreamingFeeTimestamp = block.timestamp;
        feeInfo.highWatermark = highWatermark;

        emit FeeInitialization(
            msg.sender,
            parameters.profitFeePeriod,
            parameters.highWatermarkResetPeriod,
            parameters.profitFeePercentage,
            parameters.streamingFeePercentage,
            highWatermark,
            block.timestamp,
            block.timestamp
        );
    }

     
    function getFee()
        external
        view
        returns (uint256)
    {
        (
            uint256 streamingFee,
            uint256 profitFee
        ) = calculateFees(msg.sender);

        return streamingFee.add(profitFee);
    }

     
    function getCalculatedFees(
        address _setAddress
    )
        external
        view
        returns (uint256, uint256)
    {
        (
            uint256 streamingFee,
            uint256 profitFee
        ) = calculateFees(_setAddress);

        return (streamingFee, profitFee);
    }

     
    function updateAndGetFee()
        external
        returns (uint256)
    {
        (
            uint256 streamingFee,
            uint256 profitFee
        ) = calculateFees(msg.sender);

         
        updateFeeState(msg.sender, streamingFee, profitFee);

        emit FeeActualization(
            msg.sender,
            highWatermark(msg.sender),
            profitFee,
            streamingFee
        );

        return streamingFee.add(profitFee);
    }

     
    function adjustFee(
        bytes calldata _newFeeData
    )
        external
    {
        (
            FeeType feeIdentifier,
            uint256 feePercentage
        ) = parseNewFeeCallData(_newFeeData);

         
         
        if (feeIdentifier == FeeType.StreamingFee) {
            validateStreamingFeePercentage(feePercentage);

            feeState[msg.sender].streamingFeePercentage = feePercentage;
        } else {
            validateProfitFeePercentage(feePercentage);

             
             
             
             
            uint256 rebalancingSetValue = SetUSDValuation.calculateRebalancingSetValue(msg.sender, oracleWhiteList);
            uint256 existingHighwatermark = feeState[msg.sender].highWatermark;
            if (rebalancingSetValue > existingHighwatermark) {
                 
                require(
                    exceedsProfitFeePeriod(msg.sender),
                    "PerformanceFeeCalculator.adjustFee: ProfitFeePeriod must have elapsed to update fee"
                );

                feeState[msg.sender].lastProfitFeeTimestamp = block.timestamp;
                feeState[msg.sender].highWatermark = rebalancingSetValue;
            }

            feeState[msg.sender].profitFeePercentage = feePercentage;
        }

        emit FeeAdjustment(msg.sender, feeIdentifier, feePercentage);
    }

     

     
    function updateFeeState(
        address _setAddress,
        uint256 _streamingFee,
        uint256 _profitFee
    )
        internal
    {
         
        feeState[_setAddress].lastStreamingFeeTimestamp = block.timestamp;

        uint256 rebalancingSetValue = SetUSDValuation.calculateRebalancingSetValue(_setAddress, oracleWhiteList);
        uint256 postStreamingValue = calculatePostStreamingValue(rebalancingSetValue, _streamingFee);

         
        if (_profitFee > 0) {
            feeState[_setAddress].lastProfitFeeTimestamp = block.timestamp;
            feeState[_setAddress].highWatermark = postStreamingValue;
        } else if (timeSinceLastProfitFee(_setAddress) >= highWatermarkResetPeriod(_setAddress)) {
             
             
            feeState[_setAddress].highWatermark = postStreamingValue;
            feeState[_setAddress].lastProfitFeeTimestamp = block.timestamp;
        }
    }

     
    function validateFeeParameters(
        InitFeeParameters memory parameters
    )
        internal
        view
    {
         
        validateStreamingFeePercentage(parameters.streamingFeePercentage);
        validateProfitFeePercentage(parameters.profitFeePercentage);

         
         
         
        require(
            parameters.highWatermarkResetPeriod >= parameters.profitFeePeriod,
            "PerformanceFeeCalculator.validateFeeParameters: Fee collection frequency must exceed highWatermark reset."
        );
    }

     
    function validateStreamingFeePercentage(
        uint256 _streamingFee
    )
        internal
        view
    {
        require(
            _streamingFee <= maximumStreamingFeePercentage,
            "PerformanceFeeCalculator.validateStreamingFeePercentage: Streaming fee exceeds maximum."
        );

        ScaleValidations.validateMultipleOfBasisPoint(_streamingFee);
    }

     
    function validateProfitFeePercentage(
        uint256 _profitFee
    )
        internal
        view
    {
        require(
            _profitFee <= maximumProfitFeePercentage,
            "PerformanceFeeCalculator.validateProfitFeePercentage: Profit fee exceeds maximum."
        );

        ScaleValidations.validateMultipleOfBasisPoint(_profitFee);
    }

     
    function calculateFees(
        address _setAddress
    )
        internal
        view
        returns (uint256, uint256)
    {
        require(
            core.validSets(_setAddress),
            "PerformanceFeeCalculator.calculateFees: Caller must be valid RebalancingSetToken."
        );

        uint256 streamingFee = calculateStreamingFee(_setAddress);

        uint256 profitFee = calculateProfitFee(_setAddress, streamingFee);

        return (streamingFee, profitFee);
    }

     
    function calculateStreamingFee(
        address _setAddress
    )
        internal
        view
        returns(uint256)
    {
        uint256 timeSinceLastFee = block.timestamp.sub(lastStreamingFeeTimestamp(_setAddress));

         
        return timeSinceLastFee.mul(streamingFeePercentage(_setAddress)).div(ONE_YEAR_IN_SECONDS);
    }

     
    function calculateProfitFee(
        address _setAddress,
        uint256 _streamingFee
    )
        internal
        view
        returns(uint256)
    {
         
        if (exceedsProfitFeePeriod(_setAddress)) {
             
            uint256 rebalancingSetValue = SetUSDValuation.calculateRebalancingSetValue(_setAddress, oracleWhiteList);
            uint256 postStreamingValue = calculatePostStreamingValue(rebalancingSetValue, _streamingFee);
            uint256 highWatermark = highWatermark(_setAddress);

             
            uint256 gainedValue = postStreamingValue > highWatermark ? postStreamingValue.sub(highWatermark) : 0;

             
            return gainedValue.mul(profitFeePercentage(_setAddress)).div(rebalancingSetValue);
        } else {
            return 0;
        }
    }

    
    function calculatePostStreamingValue(
        uint256 _rebalancingSetValue,
        uint256 _streamingFee
    )
        internal
        view
        returns (uint256)
    {
        return _rebalancingSetValue.sub(_rebalancingSetValue.mul(_streamingFee).deScale());
    }

     
    function exceedsProfitFeePeriod(address _set) internal view returns (bool) {
        return timeSinceLastProfitFee(_set) > profitFeePeriod(_set);
    }

     
    function timeSinceLastProfitFee(address _set) internal view returns (uint256) {
        return block.timestamp.sub(lastProfitFeeTimestamp(_set));
    }

    function lastStreamingFeeTimestamp(address _set) internal view returns (uint256) {
        return feeState[_set].lastStreamingFeeTimestamp;
    }

    function lastProfitFeeTimestamp(address _set) internal view returns (uint256) {
        return feeState[_set].lastProfitFeeTimestamp;
    }

    function streamingFeePercentage(address _set) internal view returns (uint256) {
        return feeState[_set].streamingFeePercentage;
    }

    function profitFeePercentage(address _set) internal view returns (uint256) {
        return feeState[_set].profitFeePercentage;
    }

    function profitFeePeriod(address _set) internal view returns (uint256) {
        return feeState[_set].profitFeePeriod;
    }

    function highWatermark(address _set) internal view returns(uint256) {
        return feeState[_set].highWatermark;
    }

    function highWatermarkResetPeriod(address _set) internal view returns(uint256) {
        return feeState[_set].highWatermarkResetPeriod;
    }

     

     
    function parsePerformanceFeeCallData(
        bytes memory _callData
    )
        private
        pure
        returns (InitFeeParameters memory)
    {
        return abi.decode (_callData, (InitFeeParameters));
    }

     
    function parseNewFeeCallData(
        bytes memory _callData
    )
        private
        pure
        returns (FeeType, uint256)
    {
        (
            uint8 feeType,
            uint256 feePercentage
        ) = abi.decode (_callData, (uint8, uint256));

        require(
            feeType < 2,
            "PerformanceFeeCalculator.parseNewFeeCallData: Fee type invalid"
        );

        return (FeeType(feeType), feePercentage);
    }
}