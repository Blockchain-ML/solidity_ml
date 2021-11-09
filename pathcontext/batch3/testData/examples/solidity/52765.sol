pragma solidity 0.4.25;

 

 
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

 

 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

   
  modifier whenPaused() {
    require(paused);
    _;
  }

   
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

   
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

 

 
contract Destructible is Ownable {
   
  function destroy() public onlyOwner {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) public onlyOwner {
    selfdestruct(_recipient);
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

 

contract HasManager is Ownable {

     
     
    mapping (address => bool) public isManager;

    event ChangedManager(address indexed manager, bool active);

     
    function setManager(address manager, bool active) public onlyOwner {
        isManager[manager] = active;
        emit ChangedManager(manager, active);
    }

    modifier managerRole() {
        require(isManager[msg.sender], "sender is not a manager");
        _;
    }

}

 

contract HasBank is Ownable {

     
    mapping (address => bool) public isBank;

    event ChangedBank(address indexed bank, bool active);

     
    function setBank(address bank, bool active) public onlyOwner {
        isBank[bank] = active;
        emit ChangedBank(bank, active);
    }

    modifier bankRole() {
        require(isBank[msg.sender], "sender is not a bank");
        _;
    }
}

 

contract TokenGateCrowdsale is Ownable, Pausable, HasManager, HasBank, Destructible {

    using SafeMath for uint256;

    event InvestorAdded(address indexed wallet);
    event InvestorRemoved(address indexed wallet);
    event PaymentEvent(bytes32 indexed paymentId, PaymentStatus status);
    event ExchangeRateEvent(uint _timestamp, uint256 _rateBTC, uint256 _rateETH);
    
    enum PaymentStatus { Verified, Cancelled, ErrorInvestorNotFound, ErrorNotTheSameInvestor,
        ErrorExceedsKycLimit, ErrorBelowMinInvest, ErrorNotStarted, ErrorHasEnded }

    uint8 constant public CURRENCY_TYPE_CHF = 0;
    uint8 constant public CURRENCY_TYPE_BTC = 1;
    uint8 constant public CURRENCY_TYPE_ETH = 2;
    
    uint256 constant ZERO = uint256(0);

    struct Payment {
        bytes32 refId;
        uint timestamp;
        uint256 amount;
        uint256 tokenAmount;
        uint8 currencyType;
        PaymentStatus status;
    }

    struct InvestorData {
        uint256 kycLimit;
        uint256 bonus;
    }
    
     
     
     
    mapping(bytes32 => address) public investors;

     
    mapping(address => InvestorData) public investorData;
    
     
    mapping(bytes32 => Payment) public payments;

     
    struct ExchangeRate {
        uint timestamp;
        uint256[2] rate;
    }
    
    ExchangeRate[] public exchangeRates;

    bool public finalized = false;

    uint public creationTime = now;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public pendingTime;
    
    ERC20 public token;
    
     
    uint256 public rateCHF;
    
     
    uint256 public minInvestment;

     
    uint256 public teamTokensSum;
    uint256 public founderTokensSum;
    uint256 public privateSaleTokensSum;
    uint256 public referralTokensSum;
    
    uint8 public constant decimals = 18;
    uint256 public constant oneToken = (10 ** uint256(decimals));

    address public tokenHolder;
    
     
    constructor (
        uint256 _startTime,
        uint256 _endTime,
        uint256 _pendingTime,
        address _managerAddress,
        address _bankAddress,
        ERC20 _token,
        address _tokenHolder)
    public
    Pausable()
    {
        require(_token != address(0), "token can not be 0x");
        require(_bankAddress != address(0), "bank address cannot be 0x");
        require(_managerAddress != address(0), "manager address cannot be 0x");
        require(_endTime > _startTime, "endTime must be bigger than startTme");
        require(_pendingTime > 0, "pendingTime must be > 0");
 
        setManager(_managerAddress, true);
        setBank(_bankAddress, true);

        token = _token;
        startTime = _startTime;
        endTime = _endTime;
        pendingTime = _pendingTime;
        tokenHolder = _tokenHolder;
        
         
         
         
        
         
         
        rateCHF = oneToken.div(2);
        
         
        uint256 minCHF = 1000;
         
        minInvestment = minCHF.mul(rateCHF);
    }
    
     
    function daysToSeconds(uint _days) internal pure returns (uint) {
        return _days.mul(24 hours);
    }

     
    function getInvestorKey(bytes32 _refId, uint8 _currencyType) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_refId, _currencyType));
    }
    
     
     
     
     
     
    
     
     
     
    
     
    function addInvestor(bytes32[3][] _refIds, address _wallet, uint256 _kycLimit, uint256 _bonus)
    public managerRole whenNotFinalized whenNotPaused returns (bool) {
        require(now < endTime, "crowdsale is already finished");
        require(_refIds.length > 0, "refs must be a non-empty array");
        require(_wallet != address(0), "wallet must have non-zero address");
        require(_bonus >= 0, "bonus must be greater than or equals to zero");
        require(_bonus <= 100, "bonus must be less than or equals to hundred");

        for (uint i = 0; i < _refIds.length; i++) {
            bytes32[3] memory ref = _refIds[i];
            for (uint j = 0; j < ref.length; j++) {
                 
                if (ref[j] == bytes32(0)) continue;

                bytes32 index = getInvestorKey(ref[j], uint8(j));

                address _curAddress = investors[index];
                require(_curAddress == address(0) || _curAddress == _wallet,
                    "refId already registered with a different wallet");

                investors[index] = _wallet;
            }
        }
        
         
         
        uint256 kycLimitInTokens = _kycLimit.mul(rateCHF).div(oneToken);

        investorData[_wallet].kycLimit = kycLimitInTokens;
        investorData[_wallet].bonus = _bonus;

        emit InvestorAdded(_wallet);
        
        return true;
    }
 
     
    function getInvestor(bytes32 _refId, uint8 _currencyType) public view returns (address) {
        return investors[getInvestorKey(_refId, _currencyType)];
    }

     
    function getInvestorKycLimit(bytes32 _refId, uint8 _currencyType) public view returns (uint256) {
        address wallet = investors[getInvestorKey(_refId, _currencyType)];
        return investorData[wallet].kycLimit;
    }

     
    function getBonus(bytes32 _refId, uint8 _currencyType) public view returns (uint256) {
        address wallet = investors[getInvestorKey(_refId, _currencyType)];
        return investorData[wallet].bonus;
    }
    
     
     
     
    
     
    function provideExchangeRate(
        uint256 _timestamp,
        uint256 _rateBTC,
        uint256 _rateETH) 
    public managerRole whenNotFinalized whenNotPaused whenNotFinalized returns (bool) {
        require(exchangeRates.length == 0 || exchangeRates[exchangeRates.length - 1].timestamp < _timestamp,
            "ts must be greater than the latest ts");
        require(_rateBTC > 0 && _rateETH > 0, "exchange rates must be positive");

         
        uint256 rateBtcToken = _rateBTC.mul(rateCHF).div(oneToken);
        uint256 rateEthToken = _rateETH.mul(rateCHF).div(oneToken);
        ExchangeRate memory rate = ExchangeRate(_timestamp, [rateBtcToken, rateEthToken]);
        exchangeRates.push(rate);
        
        emit ExchangeRateEvent(_timestamp, rateBtcToken, rateEthToken);
        
        return true;
    }

     
    function getCurrentExchangeRate() public view 
    returns (uint ts, uint256[3] rate) {
        if (exchangeRates.length == 0) return (now, [rateCHF, ZERO, ZERO]);
        ExchangeRate memory er = exchangeRates[exchangeRates.length - 1];
        return (now, [rateCHF, er.rate[CURRENCY_TYPE_BTC - 1], er.rate[CURRENCY_TYPE_ETH - 1]]);
    }

     
    function getExchangeRateAtTime(uint _timestamp) public view
    returns (uint ts, uint256[3] rate) {
        if (exchangeRates.length == 0) return (_timestamp, [rateCHF, ZERO, ZERO]);
        for (uint j = 0; j <= exchangeRates.length - 1; j++) {
            uint i = exchangeRates.length - j - 1;
            if (_timestamp >= exchangeRates[i].timestamp) {
                ExchangeRate memory er = exchangeRates[i];
                return (_timestamp, [rateCHF, er.rate[CURRENCY_TYPE_BTC - 1], er.rate[CURRENCY_TYPE_ETH - 1]]);
            }
        }
        return (_timestamp, [rateCHF, ZERO, ZERO]);
    }
    
     
    function getExchangeRatesLength() public view returns (uint) {
        return exchangeRates.length;
    }

     
     
     

     
    function allocateTokens(Payment storage _payment, address _investor, bool _force) internal {
        (, uint256[3] memory er) = getExchangeRateAtTime(_payment.timestamp);
        require(er[_payment.currencyType] > 0, "exchange rate must be positive");
         
         
        _payment.tokenAmount = _payment.amount.mul(er[_payment.currencyType]).div(oneToken);
        
         
        if (!_force && _payment.tokenAmount < minInvestment) {
            _payment.status = PaymentStatus.ErrorBelowMinInvest;
            _payment.tokenAmount = 0;
        } else if (!_force && investorData[_investor].kycLimit > 0 &&
            investorData[_investor].kycLimit < token.balanceOf(_investor).add(_payment.tokenAmount)) {
            _payment.status = PaymentStatus.ErrorExceedsKycLimit;
            _payment.tokenAmount = 0;
        } else {
            if (investorData[_investor].bonus > 0) {
                uint256 bonus = investorData[_investor].bonus;
                _payment.tokenAmount = _payment.tokenAmount.add(bonus.mul(_payment.tokenAmount).div(100));
            }
            token.transferFrom(tokenHolder, _investor, _payment.tokenAmount);
        }
    }

     
    function submitPayment(
        bytes32 _paymentId,
        bytes32[] _refIds,
        uint256 _timestamp,
        uint256 _amount,
        uint8 _currencyType
    ) public bankRole whenNotFinalized whenNotPaused whenNotFinalized returns (bool) {
        require(_timestamp <= now, "payment cannot be in the future");
        require(_amount > 0, "payment amount must be positive");
        require(payments[_paymentId].timestamp == 0, "payment already registered");
        require(_refIds.length > 0, "refIds must not be empty");

        PaymentStatus status = PaymentStatus.Verified;

        if (_timestamp < startTime) {
            status = PaymentStatus.ErrorNotStarted;
        } else if (_timestamp > endTime) {
            status = PaymentStatus.ErrorHasEnded;
        }

        payments[_paymentId] = Payment(
            _refIds[0],
            _timestamp,
            _amount,
            0,
            _currencyType,
            status);

        Payment storage payment = payments[_paymentId];

        bytes32 index = getInvestorKey(_refIds[0], _currencyType);
        address investor = investors[index];
        for (uint8 i = 1; i < _refIds.length; i++) {
            index = getInvestorKey(_refIds[i], _currencyType);
            
            if (investor != investors[index]) {
                 
                if (payment.status == PaymentStatus.Verified) {
                    payment.status = PaymentStatus.ErrorNotTheSameInvestor;
                }
            }
        }

        if (investor == address(0)) {
             
            if (payment.status == PaymentStatus.Verified) {
                payment.status = PaymentStatus.ErrorInvestorNotFound;
            }
        } else if (payment.status == PaymentStatus.Verified) {
            allocateTokens(payment, investor, false);
        }
        
        emit PaymentEvent(_paymentId, payment.status);
        
        return true;
    }

    function setPaymentStatus(bytes32 _paymentId, PaymentStatus status)
    public managerRole whenNotFinalized whenNotPaused returns (bool) {
        Payment storage payment = payments[_paymentId];
        require(status != PaymentStatus.Cancelled, "payment cancellation not supported");
        require(payment.status != PaymentStatus.Verified, "already verified, cannot change");
        require(payment.timestamp > 0, "payment not found");
        require(payment.status != status, "status already set");

        payment.status = status;
        
        address investor = investors[getInvestorKey(payment.refId, payment.currencyType)];
        require(investor != address(0), "investor not found by payment refid");

        if (status == PaymentStatus.Verified) {
            allocateTokens(payment, investor, true);
        }

        emit PaymentEvent(_paymentId, payment.status);
        
        return true;
    }
    
     
     
     

     
    function finalize() public onlyOwner {
        require(now > endTime + pendingTime, "pending time is not elapsed yet");
        finalized = true;
    }

    modifier whenNotFinalized() {
        require(!finalized, "is already finalized");
        _;
    }
    
    function setEndTime(uint256 _endTime) public onlyOwner whenNotFinalized {
        require(_endTime > startTime, "endTime must be bigger than startTme");
        endTime = _endTime;
    }
}