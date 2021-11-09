pragma solidity 0.6.6;


        
interface UniswapPairContract {
  
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  }
        

interface xETHTokenInterface {
   
     
    function maxScalingFactor() external view returns (uint256);
    function xETHScalingFactor() external view returns (uint256);
     
    function setTxFee(uint16 fee) external ;
    function setSellFee(uint16 fee) external ;
    function rebase(uint256 epoch, uint256 indexDelta, bool positive) external returns (uint256);
}

contract xETHRebaser {

    using SafeMath for uint256;

    modifier onlyGov() {
        require(msg.sender == gov);
        _;
    }

 
     
    event NewDeviationThreshold(uint256 oldDeviationThreshold, uint256 newDeviationThreshold);

     
    address public gov;

  
     
    uint256 public rebaseLag;

     
    uint256 public targetRate;
  
     
     
     
    uint256 public deviationThreshold;

     
    uint256 public minRebaseTimeIntervalSec;

     
    uint256 public lastRebaseTimestampSec;

     
     
    uint256 public rebaseWindowOffsetSec;

     
    uint256 public rebaseWindowLengthSec;

     
    uint256 public epoch;

     
     
     
    bool public rebasingActive;

     
    uint256 public constant rebaseDelay = 0;

    address public xETHAddress;
   
    address public uniswap_xeth_eth_pair;
    
    mapping(address => bool) public whitelistFrom;
    
   

    constructor(
        address xETHAddress_,
        address xEthEthPair_
    )
        public
    {
          minRebaseTimeIntervalSec = 1 days;
          rebaseWindowOffsetSec = 0;  
       
           
          targetRate = 10**18;

           
          rebaseLag = 10;

           
          deviationThreshold = 5 * 10**15;

           
          rebaseWindowLengthSec = 24 hours;
          
          uniswap_xeth_eth_pair = xEthEthPair_;
          xETHAddress = xETHAddress_;

          gov = msg.sender;
    }

  
  
  
    
     function setWhitelistedFrom(address _addr, bool _whitelisted) external onlyGov {
        whitelistFrom[_addr] = _whitelisted;
    }
    
    
     function _isWhitelisted(address _from) internal view returns (bool) {
        return whitelistFrom[_from];
    }
    
     
    function rebase()
        public
    {
         
        require(msg.sender == tx.origin);
        require(_isWhitelisted(msg.sender));
         
        _inRebaseWindow();
        

        require(lastRebaseTimestampSec.add(minRebaseTimeIntervalSec) < now);

         
        lastRebaseTimestampSec = now;

        epoch = epoch.add(1);

         
        uint256 exchangeRate = getPrice();

         
        (uint256 offPegPerc, bool positive) = computeOffPegPerc(exchangeRate);

        uint256 indexDelta = offPegPerc;

         
        indexDelta = indexDelta.div(rebaseLag);

        xETHTokenInterface xETH = xETHTokenInterface(xETHAddress);

        if (positive) {
            require(xETH.xETHScalingFactor().mul(uint256(10**18).add(indexDelta)).div(10**18) < xETH.maxScalingFactor(), "new scaling factor will be too big");
        }


         
        xETH.rebase(epoch, indexDelta, positive);
        assert(xETH.xETHScalingFactor() <= xETH.maxScalingFactor());

  }
  
    function getPrice()
        public
        view
        returns (uint256)
    {
        (uint xethReserve, uint ethReserve, ) = UniswapPairContract(uniswap_xeth_eth_pair).getReserves();
        
        uint xEthPrice = ethReserve.mul(10**18).div(xethReserve);
               
        return xEthPrice;
    }


  


    function setDeviationThreshold(uint256 deviationThreshold_)
        external
        onlyGov
    {
        require(deviationThreshold > 0);
        uint256 oldDeviationThreshold = deviationThreshold;
        deviationThreshold = deviationThreshold_;
        emit NewDeviationThreshold(oldDeviationThreshold, deviationThreshold_);
    }

     
    function setRebaseLag(uint256 rebaseLag_)
        external
        onlyGov
    {
        require(rebaseLag_ > 0);
        rebaseLag = rebaseLag_;
    }
    
     
    function setTargetRate(uint256 targetRate_)
        external
        onlyGov
    {
        require(targetRate_ > 0);
        targetRate = targetRate_;
    }

     
    function setRebaseTimingParameters(
        uint256 minRebaseTimeIntervalSec_,
        uint256 rebaseWindowOffsetSec_,
        uint256 rebaseWindowLengthSec_)
        external
        onlyGov
    {
        require(minRebaseTimeIntervalSec_ > 0);
        require(rebaseWindowOffsetSec_ < minRebaseTimeIntervalSec_);

        minRebaseTimeIntervalSec = minRebaseTimeIntervalSec_;
        rebaseWindowOffsetSec = rebaseWindowOffsetSec_;
        rebaseWindowLengthSec = rebaseWindowLengthSec_;
    }

     
    function inRebaseWindow() public view returns (bool) {

         
        _inRebaseWindow();
        return true;
    }

    function _inRebaseWindow() internal view {
        require(now.mod(minRebaseTimeIntervalSec) >= rebaseWindowOffsetSec, "too early");
        require(now.mod(minRebaseTimeIntervalSec) < (rebaseWindowOffsetSec.add(rebaseWindowLengthSec)), "too late");
    }

     
    function computeOffPegPerc(uint256 rate)
        private
        view
        returns (uint256, bool)
    {
        if (withinDeviationThreshold(rate)) {
            return (0, false);
        }

         
        if (rate > targetRate) {
            return (rate.sub(targetRate).mul(10**18).div(targetRate), true);
        } else {
            return (targetRate.sub(rate).mul(10**18).div(targetRate), false);
        }
    }

     
    function withinDeviationThreshold(uint256 rate)
        private
        view
        returns (bool)
    {
        uint256 absoluteDeviationThreshold = targetRate.mul(deviationThreshold)
            .div(10 ** 18);

        return (rate >= targetRate && rate.sub(targetRate) < absoluteDeviationThreshold)
            || (rate < targetRate && targetRate.sub(rate) < absoluteDeviationThreshold);
    }
}

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
  
  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }

   
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
  
  function divRound(uint256 x, uint256 y) internal pure returns (uint256) {
        require(y != 0, "Div by zero");
        uint256 r = x / y;
        if (x % y != 0) {
            r = r + 1;
        }

        return r;
    }
}