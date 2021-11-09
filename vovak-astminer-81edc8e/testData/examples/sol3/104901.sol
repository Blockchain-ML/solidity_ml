 

pragma solidity >=0.4.24 <0.6.0;


 
contract Initializable {

   
  bool private initialized;

   
  bool private initializing;

   
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

   
  function isConstructor() private view returns (bool) {
     
     
     
     
     
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

   
  uint256[50] private ______gap;
}

 

pragma solidity ^0.4.24;


 
contract Ownable is Initializable {
  address private _owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  function initialize(address sender) public initializer {
    _owner = sender;
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

  uint256[50] private ______gap;
}

 

 

pragma solidity >=0.4.24;


 
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

 

pragma solidity >=0.4.24;


 
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

 

pragma solidity >=0.4.24;


interface ISeigniorageShares {
    function setDividendPoints(address account, uint256 totalDividends) external returns (bool);
    function mintShares(address account, uint256 amount) external returns (bool);
    function lastDividendPoints(address who) external view returns (uint256);
    function externalRawBalanceOf(address who) external view returns (uint256);
    function externalTotalSupply() external view returns (uint256);
}

 

pragma solidity ^0.4.24;


 
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

 

pragma solidity ^0.4.24;


 
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

 

pragma solidity ^0.4.24;




 
contract ERC20Detailed is Initializable, IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  function initialize(string name, string symbol, uint8 decimals) public initializer {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

   
  function name() public view returns(string) {
    return _name;
  }

   
  function symbol() public view returns(string) {
    return _symbol;
  }

   
  function decimals() public view returns(uint8) {
    return _decimals;
  }

  uint256[50] private ______gap;
}

 

pragma solidity >=0.4.24;







interface IDollarPolicy {
    function getUsdSharePrice() external view returns (uint256 price);
}

 

contract Dollars is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event LogContraction(uint256 indexed epoch, uint256 dollarsToBurn);
    event LogRebasePaused(bool paused);
    event LogBurn(address indexed from, uint256 value);
    event LogClaim(address indexed from, uint256 value);
    event LogMonetaryPolicyUpdated(address monetaryPolicy);

     
    address public monetaryPolicy;
    address public sharesAddress;

    modifier onlyMonetaryPolicy() {
        require(msg.sender == monetaryPolicy);
        _;
    }

     
    bool public rebasePaused;

    modifier whenRebaseNotPaused() {
        require(!rebasePaused);
        _;
    }

     
    uint256 private _remainingDollarsToBeBurned;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    uint256 private constant DECIMALS = 9;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_DOLLAR_SUPPLY = 1 * 10**6 * 10**DECIMALS;
    uint256 private _maxDiscount;

    modifier validDiscount(uint256 discount) {
        require(discount <= _maxDiscount, 'DISCOUNT_TOO_HIGH');
        _;
    }

    uint256 private constant MAX_SUPPLY = ~uint128(0);   

    uint256 private _totalSupply;

    uint256 private constant POINT_MULTIPLIER = 10 ** 9;

    uint256 private _totalDividendPoints;
    uint256 private _unclaimedDividends;

    ISeigniorageShares shares;

    mapping(address => uint256) private _dollarBalances;

     
     
    mapping (address => mapping (address => uint256)) private _allowedDollars;

    IDollarPolicy dollarPolicy;
    uint256 public burningDiscount;  
    uint256 public defaultDiscount;  
    uint256 public defaultDailyBonusDiscount;  

    uint256 public minimumBonusThreshold;

    bool reEntrancyMutex;
    bool reEntrancyRebaseMutex;

    address public uniswapV2Pool;

    modifier uniqueAddresses(address addr1, address addr2) {
        require(addr1 != addr2, "Addresses are not unique");
        _;
    }

     
    function setMonetaryPolicy(address monetaryPolicy_)
        external
        onlyOwner
    {
        monetaryPolicy = monetaryPolicy_;
        dollarPolicy = IDollarPolicy(monetaryPolicy_);
        emit LogMonetaryPolicyUpdated(monetaryPolicy_);
    }

    function setUniswapV2SyncAddress(address uniswapV2Pair_)
        external
        onlyOwner
    {
        uniswapV2Pool = uniswapV2Pair_;
    }

    function test()
        external
        onlyOwner
    {
        uniswapV2Pool.call(abi.encodeWithSignature('sync()'));
    }

    function setBurningDiscount(uint256 discount)
        external
        onlyOwner
        validDiscount(discount)
    {
        burningDiscount = discount;
    }

     
    function burn(uint256 amount)
        external
        updateAccount(msg.sender)
    {
        require(!reEntrancyMutex, "RE-ENTRANCY GUARD MUST BE FALSE");
        reEntrancyMutex = true;

        require(amount != 0, 'AMOUNT_MUST_BE_POSITIVE');
        require(_remainingDollarsToBeBurned != 0, 'COIN_BURN_MUST_BE_GREATER_THAN_ZERO');
        require(amount <= _dollarBalances[msg.sender], 'INSUFFICIENT_DOLLAR_BALANCE');
        require(amount <= _remainingDollarsToBeBurned, 'AMOUNT_MUST_BE_LESS_THAN_OR_EQUAL_TO_REMAINING_COINS');

        _burn(msg.sender, amount);

        reEntrancyMutex = false;
    }

    function setDefaultDiscount(uint256 discount)
        external
        onlyOwner
        validDiscount(discount)
    {
        defaultDiscount = discount;
    }

    function setMaxDiscount(uint256 discount)
        external
        onlyOwner
    {
        _maxDiscount = discount;
    }

    function setDefaultDailyBonusDiscount(uint256 discount)
        external
        onlyOwner
        validDiscount(discount)
    {
        defaultDailyBonusDiscount = discount;
    }

     
    function setRebasePaused(bool paused)
        external
        onlyOwner
    {
        rebasePaused = paused;
        emit LogRebasePaused(paused);
    }

     
    function claimDividends(address account) external updateAccount(account) returns (uint256) {
        uint256 owing = dividendsOwing(account);
        return owing;
    }

    function setMinimumBonusThreshold(uint256 minimum)
        external
        onlyOwner
    {
        require(minimum < _totalSupply, 'MINIMUM_TOO_HIGH');
        minimumBonusThreshold = minimum;
    }

     
    function rebase(uint256 epoch, int256 supplyDelta)
        external
        onlyMonetaryPolicy
        whenRebaseNotPaused
        returns (uint256)
    {
        reEntrancyRebaseMutex = true;
        uint256 burningDefaultDiscount = burningDiscount.add(defaultDailyBonusDiscount);

        if (supplyDelta == 0) {
            if (_remainingDollarsToBeBurned > minimumBonusThreshold) {

                burningDiscount = burningDefaultDiscount > _maxDiscount ? _maxDiscount : burningDefaultDiscount;
            } else {
                burningDiscount = defaultDiscount;
            }

            emit LogRebase(epoch, _totalSupply);
        } else if (supplyDelta < 0) {
            uint256 dollarsToBurn = uint256(supplyDelta.abs());
            uint256 tenPercent = _totalSupply.div(10);

            if (dollarsToBurn > tenPercent) {  
                dollarsToBurn = tenPercent;
            }

            if (dollarsToBurn.add(_remainingDollarsToBeBurned) > _totalSupply) {
                dollarsToBurn = _totalSupply.sub(_remainingDollarsToBeBurned);
            }

            if (_remainingDollarsToBeBurned > minimumBonusThreshold) {
                burningDiscount = burningDefaultDiscount > _maxDiscount ?
                    _maxDiscount : burningDefaultDiscount;
            } else {
                burningDiscount = defaultDiscount;  
            }

            _remainingDollarsToBeBurned = _remainingDollarsToBeBurned.add(dollarsToBurn);
            emit LogContraction(epoch, dollarsToBurn);
        } else {
            disburse(uint256(supplyDelta));

            uniswapV2Pool.call(abi.encodeWithSignature('sync()'));

            emit LogRebase(epoch, _totalSupply);

            if (_totalSupply > MAX_SUPPLY) {
                _totalSupply = MAX_SUPPLY;
            }
        }

        reEntrancyRebaseMutex = false;
        return _totalSupply;
    }

    function initialize(address owner_, address seigniorageAddress)
        public
        initializer
    {
        ERC20Detailed.initialize("Dollars", "USD", uint8(DECIMALS));
        Ownable.initialize(owner_);

        rebasePaused = false;
        _totalSupply = INITIAL_DOLLAR_SUPPLY;

        sharesAddress = seigniorageAddress;
        shares = ISeigniorageShares(seigniorageAddress);

        _dollarBalances[owner_] = _totalSupply;
        _maxDiscount = 50 * 10 ** 9;  
        defaultDiscount = 1 * 10 ** 9;               
        burningDiscount = defaultDiscount;
        defaultDailyBonusDiscount = 1 * 10 ** 9;     
        minimumBonusThreshold = 100 * 10 ** 9;     

        emit Transfer(address(0x0), owner_, _totalSupply);
    }

    function dividendsOwing(address account) public view returns (uint256) {
        if (_totalDividendPoints > shares.lastDividendPoints(account)) {
            uint256 newDividendPoints = _totalDividendPoints.sub(shares.lastDividendPoints(account));
            uint256 sharesBalance = shares.externalRawBalanceOf(account);
            return sharesBalance.mul(newDividendPoints).div(POINT_MULTIPLIER);
        } else {
            return 0;
        }
    }

     
     
     
    modifier updateAccount(address account) {
        uint256 owing = dividendsOwing(account);

        if (owing != 0) {
            _unclaimedDividends = _unclaimedDividends.sub(owing);
            _dollarBalances[account] += owing;
        }

        shares.setDividendPoints(account, _totalDividendPoints);

        emit LogClaim(account, owing);
        _;
    }


     
    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _totalSupply;
    }

     
    function balanceOf(address who)
        public
        view
        returns (uint256)
    {
        return _dollarBalances[who].add(dividendsOwing(who));
    }

    function getRemainingDollarsToBeBurned()
        public
        view
        returns (uint256)
    {
        return _remainingDollarsToBeBurned;
    }

     
    function transfer(address to, uint256 value)
        public
        uniqueAddresses(msg.sender, to)
        validRecipient(to)
        updateAccount(msg.sender)
        updateAccount(to)
        returns (bool)
    {
        require(!reEntrancyRebaseMutex, "RE-ENTRANCY GUARD MUST BE FALSE");
        _dollarBalances[msg.sender] = _dollarBalances[msg.sender].sub(value);
        _dollarBalances[to] = _dollarBalances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

     
    function allowance(address owner_, address spender)
        public
        view
        returns (uint256)
    {
        return _allowedDollars[owner_][spender];
    }

     
    function transferFrom(address from, address to, uint256 value)
        public
        validRecipient(to)
        updateAccount(from)
        updateAccount(msg.sender)
        updateAccount(to)
        returns (bool)
    {
        require(!reEntrancyRebaseMutex, "RE-ENTRANCY GUARD MUST BE FALSE");

        _allowedDollars[from][msg.sender] = _allowedDollars[from][msg.sender].sub(value);

        _dollarBalances[from] = _dollarBalances[from].sub(value);
        _dollarBalances[to] = _dollarBalances[to].add(value);
        emit Transfer(from, to, value);

        return true;
    }

     
    function approve(address spender, uint256 value)
        public
        uniqueAddresses(msg.sender, spender)
        validRecipient(spender)
        updateAccount(msg.sender)
        updateAccount(spender)
        returns (bool)
    {
        _allowedDollars[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue)
        public
        uniqueAddresses(msg.sender, spender)
        updateAccount(msg.sender)
        updateAccount(spender)
        returns (bool)
    {
        _allowedDollars[msg.sender][spender] =
            _allowedDollars[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedDollars[msg.sender][spender]);
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        uniqueAddresses(msg.sender, spender)
        updateAccount(spender)
        updateAccount(msg.sender)
        returns (bool)
    {
        uint256 oldValue = _allowedDollars[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedDollars[msg.sender][spender] = 0;
        } else {
            _allowedDollars[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedDollars[msg.sender][spender]);
        return true;
    }

    function consultBurn(uint256 amount)
        public
        returns (uint256)
    {
        require(amount > 0, 'AMOUNT_MUST_BE_POSITIVE');
        require(burningDiscount >= 0, 'DISCOUNT_NOT_VALID');
        require(_remainingDollarsToBeBurned > 0, 'COIN_BURN_MUST_BE_GREATER_THAN_ZERO');
        require(amount <= _dollarBalances[msg.sender].add(dividendsOwing(msg.sender)), 'INSUFFICIENT_DOLLAR_BALANCE');
        require(amount <= _remainingDollarsToBeBurned, 'AMOUNT_MUST_BE_LESS_THAN_OR_EQUAL_TO_REMAINING_COINS');

        uint256 usdPerShare = dollarPolicy.getUsdSharePrice();  
        uint256 decimals = 10 ** 9;
        uint256 percentDenominator = 100;
        usdPerShare = usdPerShare.sub(usdPerShare.mul(burningDiscount).div(percentDenominator * decimals));  
        uint256 sharesToMint = amount.mul(decimals).div(usdPerShare);  

        return sharesToMint;
    }

    function unclaimedDividends()
        public
        view
        returns (uint256)
    {
        return _unclaimedDividends;
    }

    function totalDividendPoints()
        public
        view
        returns (uint256)
    {
        return _totalDividendPoints;
    }

    function disburse(uint256 amount) internal returns (bool) {
        _totalDividendPoints = _totalDividendPoints.add(amount.mul(POINT_MULTIPLIER).div(shares.externalTotalSupply()));
        _totalSupply = _totalSupply.add(amount);
        _unclaimedDividends = _unclaimedDividends.add(amount);
        return true;
    }

    function _burn(address account, uint256 amount)
        internal 
    {
        _totalSupply = _totalSupply.sub(amount);
        _dollarBalances[account] = _dollarBalances[account].sub(amount);

        uint256 usdPerShare = dollarPolicy.getUsdSharePrice();  
        uint256 decimals = 10 ** 9;
        uint256 percentDenominator = 100;

        usdPerShare = usdPerShare.sub(usdPerShare.mul(burningDiscount).div(percentDenominator * decimals));  
        uint256 sharesToMint = amount.mul(decimals).div(usdPerShare);  
        _remainingDollarsToBeBurned = _remainingDollarsToBeBurned.sub(amount);

        shares.mintShares(account, sharesToMint);

        emit Transfer(account, address(0), amount);
        emit LogBurn(account, amount);
    }
}

 

pragma solidity >=0.4.24;




 


interface IDecentralizedOracle {
    function update() external;
    function consult(address token, uint amountIn) external view returns (uint amountOut);
}

contract DollarsPolicy is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using UInt256Lib for uint256;

    event LogRebase(
        uint256 indexed epoch,
        uint256 exchangeRate,
        uint256 cpi,
        int256 requestedSupplyAdjustment,
        uint256 timestampSec
    );

    Dollars public dollars;

     
    IDecentralizedOracle public sharesPerUsdOracle;
    IDecentralizedOracle public ethPerUsdOracle;
    IDecentralizedOracle public ethPerUsdcOracle;

    uint256 public deviationThreshold;

    uint256 public rebaseLag;

    uint256 private cpi;

    uint256 public minRebaseTimeIntervalSec;

    uint256 public lastRebaseTimestampSec;

    uint256 public rebaseWindowOffsetSec;

    uint256 public rebaseWindowLengthSec;

    uint256 public epoch;

    address WETH_ADDRESS;
    address SHARE_ADDRESS;

    uint256 private constant DECIMALS = 18;

    uint256 private constant MAX_RATE = 10**6 * 10**DECIMALS;
    uint256 private constant MAX_SUPPLY = ~(uint256(1) << 255) / MAX_RATE;

    address public orchestrator;
    bool private initializedOracle;

    modifier onlyOrchestrator() {
        require(msg.sender == orchestrator);
        _;
    }

    uint256 public minimumDollarCirculation;

    function getUsdSharePrice() external view returns (uint256) {
        sharesPerUsdOracle.update();

        uint256 shareDecimals = 10 ** 9;
        uint256 sharePrice = sharesPerUsdOracle.consult(SHARE_ADDRESS, 1 * shareDecimals);         
        return sharePrice;
    }

    function rebase() external onlyOrchestrator {
        require(inRebaseWindow(), "OUTISDE_REBASE");
        require(initializedOracle, 'ORACLE_NOT_INITIALIZED');

        require(lastRebaseTimestampSec.add(minRebaseTimeIntervalSec) < now, "MIN_TIME_NOT_MET");

        lastRebaseTimestampSec = now.sub(
            now.mod(minRebaseTimeIntervalSec)).add(rebaseWindowOffsetSec);

        epoch = epoch.add(1);

        sharesPerUsdOracle.update();
        ethPerUsdOracle.update();
        ethPerUsdcOracle.update();

        uint256 wethDecimals = 10 ** 18;
        uint256 shareDecimals = 10 ** 9;

        uint256 ethUsdcPrice = ethPerUsdcOracle.consult(WETH_ADDRESS, 1 * wethDecimals);         
        uint256 ethUsdPrice = ethPerUsdOracle.consult(WETH_ADDRESS, 1 * wethDecimals);           
        uint256 dollarCoinExchangeRate = ethUsdcPrice.mul(10 ** 21)                              
            .div(ethUsdPrice);
        uint256 sharePrice = sharesPerUsdOracle.consult(SHARE_ADDRESS, 1 * shareDecimals);       
        uint256 shareExchangeRate = sharePrice.mul(dollarCoinExchangeRate).div(shareDecimals);   

        uint256 targetRate = cpi;

        if (dollarCoinExchangeRate > MAX_RATE) {
            dollarCoinExchangeRate = MAX_RATE;
        }

         
        int256 supplyDelta = computeSupplyDelta(dollarCoinExchangeRate, targetRate);         

         
         
        uint256 algorithmicLag_ = getAlgorithmicRebaseLag(supplyDelta);
        require(algorithmicLag_ != 0, "algorithmic rate must be positive");
        rebaseLag = algorithmicLag_;

        supplyDelta = supplyDelta.mul(10 ** 9).div(algorithmicLag_.toInt256Safe());  

         
        if (supplyDelta > 0 && dollars.totalSupply().add(uint256(supplyDelta)) > MAX_SUPPLY) {
            supplyDelta = (MAX_SUPPLY.sub(dollars.totalSupply())).toInt256Safe();
        }

         
        if (supplyDelta < 0 && dollars.getRemainingDollarsToBeBurned().add(uint256(supplyDelta.abs())) > MAX_SUPPLY) {
            supplyDelta = (MAX_SUPPLY.sub(dollars.getRemainingDollarsToBeBurned())).toInt256Safe();
        }

         
        if (supplyDelta < 0 && dollars.totalSupply().sub(dollars.getRemainingDollarsToBeBurned().add(uint256(supplyDelta.abs()))) < minimumDollarCirculation) {
            supplyDelta = (dollars.totalSupply().sub(dollars.getRemainingDollarsToBeBurned()).sub(minimumDollarCirculation)).toInt256Safe();
        }

        uint256 supplyAfterRebase;

        if (supplyDelta < 0) {  
            uint256 dollarsToBurn = uint256(supplyDelta.abs());
            supplyAfterRebase = dollars.rebase(epoch, (dollarsToBurn).toInt256Safe().mul(-1));
        } else {  
            supplyAfterRebase = dollars.rebase(epoch, supplyDelta);
        }

        assert(supplyAfterRebase <= MAX_SUPPLY);
        emit LogRebase(epoch, dollarCoinExchangeRate, cpi, supplyDelta, now);
    }

    function setOrchestrator(address orchestrator_)
        external
        onlyOwner
    {
        orchestrator = orchestrator_;
    }

    function setDeviationThreshold(uint256 deviationThreshold_)
        external
        onlyOwner
    {
        deviationThreshold = deviationThreshold_;
    }

    function setCpi(uint256 cpi_)
        external
        onlyOwner
    {
        require(cpi_ != 0);
        cpi = cpi_;
    }

    function setRebaseLag(uint256 rebaseLag_)
        external
        onlyOwner
    {
        require(rebaseLag_ != 0);
        rebaseLag = rebaseLag_;
    }

    function initializeOracles(
        address sharesPerUsdOracleAddress,
        address ethPerUsdOracleAddress,
        address ethPerUsdcOracleAddress
    ) external onlyOwner {
        require(!initializedOracle, 'ALREADY_INITIALIZED_ORACLE');
        sharesPerUsdOracle = IDecentralizedOracle(sharesPerUsdOracleAddress);
        ethPerUsdOracle = IDecentralizedOracle(ethPerUsdOracleAddress);
        ethPerUsdcOracle = IDecentralizedOracle(ethPerUsdcOracleAddress);

        initializedOracle = true;
    }

    function changeOracles(
        address sharesPerUsdOracleAddress,
        address ethPerUsdOracleAddress,
        address ethPerUsdcOracleAddress
    ) external onlyOwner {
        sharesPerUsdOracle = IDecentralizedOracle(sharesPerUsdOracleAddress);
        ethPerUsdOracle = IDecentralizedOracle(ethPerUsdOracleAddress);
        ethPerUsdcOracle = IDecentralizedOracle(ethPerUsdcOracleAddress);
    }

    function setWethAddress(address wethAddress)
        external
        onlyOwner
    {
        WETH_ADDRESS = wethAddress;
    }

    function setShareAddress(address shareAddress)
        external
        onlyOwner
    {
        SHARE_ADDRESS = shareAddress;
    }

    function setMinimumDollarCirculation(uint256 minimumDollarCirculation_)
        external
        onlyOwner
    {
        minimumDollarCirculation = minimumDollarCirculation_;
    }

    function setRebaseTimingParameters(
        uint256 minRebaseTimeIntervalSec_,
        uint256 rebaseWindowOffsetSec_,
        uint256 rebaseWindowLengthSec_)
        external
        onlyOwner
    {
        require(minRebaseTimeIntervalSec_ != 0);
        require(rebaseWindowOffsetSec_ < minRebaseTimeIntervalSec_);

        minRebaseTimeIntervalSec = minRebaseTimeIntervalSec_;
        rebaseWindowOffsetSec = rebaseWindowOffsetSec_;
        rebaseWindowLengthSec = rebaseWindowLengthSec_;
    }

    function initialize(address owner_, Dollars dollars_)
        public
        initializer
    {
        Ownable.initialize(owner_);

        deviationThreshold = 5 * 10 ** (DECIMALS-2);

        rebaseLag = 50 * 10 ** 9;
        minRebaseTimeIntervalSec = 1 days;
        rebaseWindowOffsetSec = 63000;   
        rebaseWindowLengthSec = 15 minutes;
        lastRebaseTimestampSec = 0;
        cpi = 1 * 10 ** 18;
        epoch = 0;
        minimumDollarCirculation = 1000000 * 10 ** 9;  

        dollars = dollars_;
    }

     
     
    function getAlgorithmicRebaseLag(int256 supplyDelta) public view returns (uint256) {
        if (dollars.totalSupply() >= 30000000 * 10 ** 9) {
            return 30 * 10 ** 9;
        } else {
            if (supplyDelta < 0) {
                uint256 dollarsToBurn = uint256(supplyDelta.abs());  
                return uint256(100 * 10 ** 9).sub((dollars.totalSupply().sub(1000000 * 10 ** 9)).div(500000));
            } else {
                return uint256(29).mul(dollars.totalSupply().sub(1000000 * 10 ** 9)).div(35000000).add(1 * 10 ** 9);
            }
        }
    }

    function inRebaseWindow() public view returns (bool) {
        return (
            now.mod(minRebaseTimeIntervalSec) >= rebaseWindowOffsetSec &&
            now.mod(minRebaseTimeIntervalSec) < (rebaseWindowOffsetSec.add(rebaseWindowLengthSec))
        );
    }

    function computeSupplyDelta(uint256 rate, uint256 targetRate)
        private
        view
        returns (int256)
    {
        if (withinDeviationThreshold(rate, targetRate)) {
            return 0;
        }

        int256 targetRateSigned = targetRate.toInt256Safe();
        return dollars.totalSupply().toInt256Safe()
            .mul(rate.toInt256Safe().sub(targetRateSigned))
            .div(targetRateSigned);
    }

    function withinDeviationThreshold(uint256 rate, uint256 targetRate)
        private
        view
        returns (bool)
    {
        uint256 absoluteDeviationThreshold = targetRate.mul(deviationThreshold)
            .div(10 ** DECIMALS);

        return (rate >= targetRate && rate.sub(targetRate) < absoluteDeviationThreshold)
            || (rate < targetRate && targetRate.sub(rate) < absoluteDeviationThreshold);
    }
}

 

pragma solidity >=0.4.24;



 


contract Orchestrator is Ownable {

    struct Transaction {
        bool enabled;
        address destination;
        bytes data;
    }

    event TransactionFailed(address indexed destination, uint index, bytes data);

    Transaction[] public transactions;

    DollarsPolicy public policy;

    constructor(address policy_) public {
        Ownable.initialize(msg.sender);
        policy = DollarsPolicy(policy_);
    }

    function rebase()
        external
    {
        require(msg.sender == tx.origin);   

        policy.rebase();

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
    }

    function addTransaction(address destination, bytes data)
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

    function externalCall(address destination, bytes data)
        internal
        returns (bool)
    {
        bool result;
        assembly {   
             
             
            let outputAddress := mload(0x40)

             
            let dataAddress := add(data, 32)

            result := call(
                 
                 
                 
                 
                sub(gas, 34710),


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