 

 

pragma solidity 0.5.17;

 
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

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

     
    function mul(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a * b;

         
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

     
    function div(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
         
        require(b != -1 || a != MIN_INT256);

         
        return a / b;
    }

     
    function sub(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

     
    function add(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

     
    function abs(int256 a)
        internal
        pure
        returns (int256)
    {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

 
library UInt256Lib {

    uint256 private constant MAX_INT256 = ~(uint256(1) << 255);

     
    function toInt256Safe(uint256 a)
        internal
        pure
        returns (int256)
    {
        require(a <= MAX_INT256);
        return int256(a);
    }
}

 
interface IERC20 {

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

interface IRebased {
    function totalSupply() external view returns (uint256);
    function rebase(uint256 epoch, int256 supplyDelta) external returns (uint256);
}

interface IOracle {
    function getData() external view returns (uint256);
    function update() external;
}


 
contract Ownable {
  address private _owner;

  event OwnershipRenounced(address indexed previousOwner);
  
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  constructor() public {
    _owner = msg.sender;
  }

   
  function owner() public view returns(address) {
    return _owner;
  }

   
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

   
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

   
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

 
contract RebasedController is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using UInt256Lib for uint256;

    struct Transaction {
        bool enabled;
        address destination;
        bytes data;
    }

    event TransactionFailed(address indexed destination, uint index, bytes data);

     
    Transaction[] public transactions;

    event LogRebase(
        uint256 indexed epoch,
        uint256 exchangeRate,
        int256 requestedSupplyAdjustment,
        uint256 timestampSec
    );

    IRebased public rebased;

     
    IOracle public marketOracle;

     
     
     
     
    uint256 public deviationThreshold;

     
    uint256 public rebaseCooldown;

     
    uint256 public lastRebaseTimestampSec;

     
    uint256 public epoch;

    uint256 private constant DECIMALS = 18;

     
     
    uint256 private constant MAX_RATE = 10**6 * 10**DECIMALS;
     
    uint256 private constant MAX_SUPPLY = ~(uint256(1) << 255) / MAX_RATE;

     
     
    
    bool public rebaseLocked; 

    constructor(address _rebased) public {
        deviationThreshold = 5 * 10 ** (DECIMALS-2);

         
        rebaseCooldown = 4 hours;
        lastRebaseTimestampSec = 0;
        epoch = 0;
        rebaseLocked = true;
        
        rebased = IRebased(_rebased);
    }
    
     
     
    function renounceOwnership() public onlyOwner {
        require(!rebaseLocked, "Cannot renounce ownership if rebase is locked");
        super.renounceOwnership();
    }
        
    function setRebaseLocked(bool _locked) external onlyOwner {
        rebaseLocked = _locked;
    }

     
     
    function canRebase() public view returns (bool) {
        return ((!rebaseLocked || isOwner()) && lastRebaseTimestampSec.add(rebaseCooldown) < now);
    }
    
    function cooldownExpiryTimestamp() public view returns (uint256) {
        return lastRebaseTimestampSec.add(rebaseCooldown);
    }

     
     
    function rebase() external {

        require(tx.origin == msg.sender);
        require(canRebase(), "Rebase not allowed");

        lastRebaseTimestampSec = now;

        epoch = epoch.add(1);
        
        (uint256 exchangeRate, uint256 targetRate, int256 supplyDelta) = getRebaseValues();
        
        uint256 supplyAfterRebase = rebased.rebase(epoch, supplyDelta);
        
        assert(supplyAfterRebase <= MAX_SUPPLY);
        
        for (uint i = 0; i < transactions.length; i++) {
            Transaction storage t = transactions[i];
            if (t.enabled) {
                bool result =
                    externalCall(t.destination, t.data);
                if (!result) {
                    emit TransactionFailed(t.destination, i, t.data);
                    revert("Transaction Failed");
                }
            }
        }
        
        marketOracle.update();
        
        emit LogRebase(epoch, exchangeRate, supplyDelta, now);
    }
    
         
    
    function getRebaseValues() public view returns (uint256, uint256, int256) {

        uint256 targetRate = 10 ** DECIMALS;
        uint256 exchangeRate = marketOracle.getData();

        if (exchangeRate > MAX_RATE) {
            exchangeRate = MAX_RATE;
        }

        int256 supplyDelta = computeSupplyDelta(exchangeRate, targetRate);

         
        if (supplyDelta < 0) {
            supplyDelta = supplyDelta.div(2);
        } else {
            supplyDelta = supplyDelta.div(5);                   
        }

        if (supplyDelta > 0 && rebased.totalSupply().add(uint256(supplyDelta)) > MAX_SUPPLY) {
            supplyDelta = (MAX_SUPPLY.sub(rebased.totalSupply())).toInt256Safe();
        }

        return (exchangeRate, targetRate, supplyDelta);
    }


     
    function computeSupplyDelta(uint256 rate, uint256 targetRate)
        internal
        view
        returns (int256)
    {
        if (withinDeviationThreshold(rate, targetRate)) {
            return 0;
        }

         
        int256 targetRateSigned = targetRate.toInt256Safe();
        return rebased.totalSupply().toInt256Safe()
            .mul(rate.toInt256Safe().sub(targetRateSigned))
            .div(targetRateSigned);
    }

     
    function withinDeviationThreshold(uint256 rate, uint256 targetRate)
        internal
        view
        returns (bool)
    {
        uint256 absoluteDeviationThreshold = targetRate.mul(deviationThreshold)
            .div(10 ** DECIMALS);

        return (rate >= targetRate && rate.sub(targetRate) < absoluteDeviationThreshold)
            || (rate < targetRate && targetRate.sub(rate) < absoluteDeviationThreshold);
    }
    
     
    function setMarketOracle(IOracle marketOracle_)
        external
        onlyOwner
    {
        marketOracle = marketOracle_;
    }
    
     
    function addTransaction(address destination, bytes calldata data)
        external
        onlyOwner
    {
        transactions.push(Transaction({
            enabled: true,
            destination: destination,
            data: data
        }));
    }

     
    function removeTransaction(uint index)
        external
        onlyOwner
    {
        require(index < transactions.length, "index out of bounds");

        if (index < transactions.length - 1) {
            transactions[index] = transactions[transactions.length - 1];
        }

        transactions.length--;
    }

     
    function setTransactionEnabled(uint index, bool enabled)
        external
        onlyOwner
    {
        require(index < transactions.length, "index must be in range of stored tx list");
        transactions[index].enabled = enabled;
    }

     
    function transactionsSize()
        external
        view
        returns (uint256)
    {
        return transactions.length;
    }

     
    function externalCall(address destination, bytes memory data)
        internal
        returns (bool)
    {
        bool result;
        assembly {   
             
             
            let outputAddress := mload(0x40)

             
            let dataAddress := add(data, 32)

            result := call(
                sub(gas(), 34710),
                destination,
                0,  
                dataAddress,
                mload(data),   
                outputAddress,
                0   
            )
        }
        return result;
    }    
    
}