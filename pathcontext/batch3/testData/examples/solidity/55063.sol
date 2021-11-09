pragma solidity ^0.4.24;

 

 
contract PeriodUtil {
     
    function getPeriodIdx(uint256 timestamp) public pure returns (uint256);
    
     
    function getPeriodStartTimestamp(uint256 periodIdx) public pure returns (uint256);

     
    function getPeriodCycle(uint256 timestamp) public pure returns (uint256);

     
    function getRatePerTimeUnits(uint256 tokens, uint256 periodIdx) public view returns (uint256);

     
    function getUnitsPerPeriod() public pure returns (uint256);
}

 

 
library SafeMath {

   
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
     
     
     
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

   
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
     
     
     
    return _a / _b;
  }

   
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

   
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

 

 
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

   
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

   
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

 

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

 
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

 

 
contract EnergisFees is Ownable {

    using SafeMath for uint256;

    struct PaymentHistory {
         
        bool paid;
         
        uint256 fees;
         
        uint256 reward;
         
        uint256 endBalance;
    }

    mapping (uint256 => PaymentHistory) payments;
    address public constant tokenAddress = 0xe1819b653793dDaBbFFed4AED5752fc447d4A1e9;
    PeriodUtil public constant periodUtil = PeriodUtil(0x458dD5413fE6bBb2BFf85E43947017753Cd24e39);
     
    uint256 public lastPeriodExecIdx;
     
    uint256 public lastPeriodCycleExecIdx;
     
    uint256 constant grasePeriod = 3600;

     
    address public constant feesWallet = 0x967F4aAAa326C7e1acE0AeEE7ECd73f6580283da;
     
    address public constant rewardWallet = 0x967F4aAAa326C7e1acE0AeEE7ECd73f6580283da;
    
     
    uint256 internal constant FEES_PER = 20;
     
    uint256 internal constant FEES_MAX_AMOUNT = 1200000 * (10**18);
     
    uint256 internal constant FEES_TOKEN_MIN_AMOUNT = 24000 * (10**18);
     
    uint256 internal constant FEES_TOKEN_MIN_PERPREV = 95;
     
    uint256 internal constant REWARD_PER = 70;
    
     
    constructor () public {
        assert(grasePeriod > 0);
         
        uint256 va1 = periodUtil.getPeriodStartTimestamp(1);
        uint256 va2 = periodUtil.getPeriodStartTimestamp(0);
        assert(grasePeriod < (va1 - va2));

         
        lastPeriodExecIdx = getWeekIdx() - 1;
        lastPeriodCycleExecIdx = getYearIdx();
        PaymentHistory storage prevPayment = payments[lastPeriodExecIdx];
        prevPayment.fees = 0;
        prevPayment.reward = 0;
        prevPayment.paid = true;
        prevPayment.endBalance = 0;
    }

     
    function process() public onlyOwner {
        uint256 currPeriodIdx = getWeekIdx();

         
        if (lastPeriodExecIdx == (currPeriodIdx - 1)) {
             
            return;
        }

        if ((currPeriodIdx - lastPeriodExecIdx) == 2) {
            paymentOnTime(currPeriodIdx);
             
            if (lastPeriodCycleExecIdx < getYearIdx()) {
                processEndOfYear(currPeriodIdx - 1);
            }
        }
        else {
            uint256 availableTokens = currentBalance();
             
            PaymentHistory memory lastExecPeriod = payments[lastPeriodExecIdx];
            uint256 tokensReceived = availableTokens.sub(lastExecPeriod.endBalance);
             
            uint256 tokenHourlyRate = periodUtil.getRatePerTimeUnits(tokensReceived, lastPeriodExecIdx + 1);

            PaymentHistory memory prePeriod;

            for (uint256 calcPeriodIdx = lastPeriodExecIdx + 1; calcPeriodIdx < currPeriodIdx; calcPeriodIdx++) {
                prePeriod = payments[calcPeriodIdx - 1];
                uint256 periodTokenReceived = periodUtil.getUnitsPerPeriod().mul(tokenHourlyRate);
                makePayments(prePeriod, payments[calcPeriodIdx], periodTokenReceived, prePeriod.endBalance.add(periodTokenReceived), calcPeriodIdx);

                if (periodUtil.getPeriodCycle(periodUtil.getPeriodStartTimestamp(calcPeriodIdx + 1)) > lastPeriodCycleExecIdx) {
                    processEndOfYear(calcPeriodIdx);
                }
            }
        }

        assert(payments[currPeriodIdx - 1].paid);
        lastPeriodExecIdx = currPeriodIdx - 1;
    }

     
    function processEndOfYear(uint256 yearEndPeriodCycle) internal {
        PaymentHistory storage lastYearPeriod = payments[yearEndPeriodCycle];
        uint256 availableTokens = currentBalance();
        uint256 tokensToClear = min256(availableTokens,lastYearPeriod.endBalance);

        assert(ERC20(tokenAddress).transfer(feesWallet, tokensToClear));
        lastPeriodCycleExecIdx = lastPeriodCycleExecIdx + 1;
        lastYearPeriod.endBalance = 0;

        emit YearEndClearance(lastPeriodCycleExecIdx, tokensToClear);
    }

     
    function paymentOnTime(uint256 currPeriodIdx) internal {
    
        uint256 availableTokens = currentBalance();
        PaymentHistory memory prePeriod = payments[currPeriodIdx - 2];

        uint256 tokensRecvInPeriod = availableTokens.sub(prePeriod.endBalance);

        if (tokensRecvInPeriod <= 0) {
            tokensRecvInPeriod = 0;
        }
        else if ((now - periodUtil.getPeriodStartTimestamp(currPeriodIdx)) > grasePeriod) {
            tokensRecvInPeriod = periodUtil.getRatePerTimeUnits(tokensRecvInPeriod, currPeriodIdx - 1).mul(periodUtil.getUnitsPerPeriod());
            if (tokensRecvInPeriod <= 0) {
                tokensRecvInPeriod = 0;
            }
            assert(availableTokens >= tokensRecvInPeriod);
        }   

        makePayments(prePeriod, payments[currPeriodIdx - 1], tokensRecvInPeriod, prePeriod.endBalance + tokensRecvInPeriod, currPeriodIdx - 1);
    }

     
    function makePayments(PaymentHistory memory prevPayment, PaymentHistory storage currPayment, uint256 tokensRaised, uint256 availableTokens, uint256 weekIdx) internal {

        assert(prevPayment.paid);
        assert(!currPayment.paid);
        assert(availableTokens >= tokensRaised);

        uint256 feesPay = tokensRaised == 0 ? 0 : tokensRaised.mul(FEES_PER).div(100);
        if (feesPay >= FEES_MAX_AMOUNT) {
            feesPay = FEES_MAX_AMOUNT;
        }
        else {
             
            uint256 prevFees95 = prevPayment.fees.mul(FEES_TOKEN_MIN_PERPREV).div(100);
             
            uint256 minFeesPay = max256(FEES_TOKEN_MIN_AMOUNT, prevFees95);
            feesPay = max256(feesPay, minFeesPay);
        }

        if (feesPay > availableTokens) {
            feesPay = availableTokens;
        }

        uint256 rewardPay = 0;
        if (feesPay < tokensRaised) {
             
            rewardPay = tokensRaised.mul(REWARD_PER).div(100);
             
            rewardPay = min256(rewardPay, tokensRaised.sub(feesPay));
        }

        currPayment.fees = feesPay;
        currPayment.reward = rewardPay;

        assert(ERC20(tokenAddress).transfer(rewardWallet, rewardPay));
        assert(ERC20(tokenAddress).transfer(feesWallet, feesPay));

        currPayment.endBalance = availableTokens - feesPay - rewardPay;
        currPayment.paid = true;

        emit Payment(weekIdx, rewardPay, feesPay);
    }

     
    event Payment(uint256 weekIdx, uint256 rewardPay, uint256 feesPay);

     
    event YearEndClearance(uint256 yearIdx, uint256 feesPay);


     
    function currentBalance() internal view returns (uint256) {
        return ERC20(tokenAddress).balanceOf(address(this));
    }

     
    function getWeekIdx() public view returns (uint256) {
        return periodUtil.getPeriodIdx(now);
    }

     
    function getYearIdx() public view returns (uint256) {
        return periodUtil.getPeriodCycle(now);
    }

     
    function weekProcessed(uint256 weekIdx) public view returns (bool) {
        return payments[weekIdx].paid;
    }

     
    function paymentForWeek(uint256 weekIdx) public view returns (uint256 fees, uint256 reward) {
        PaymentHistory storage history = payments[weekIdx];
        fees = history.fees;
        reward = history.reward;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}