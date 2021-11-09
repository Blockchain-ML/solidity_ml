pragma solidity ^0.4.24;

 
contract Ownable {
  address public owner;

   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  uint8 public decimals;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

     
     

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval (address _spender, uint256 _addedValue)
      public
      returns (bool success) {
      allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
      emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
  }

  function decreaseApproval (address _spender, uint256 _subtractedValue)
      public
      returns (bool success) {
      uint256 oldValue = allowed[msg.sender][_spender];
      if (_subtractedValue > oldValue) {
          allowed[msg.sender][_spender] = 0;
      } else {
          allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
      }
      emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
  }
}

contract ExchangableToken is StandardToken {
    function TransferToken(address from_address, address to_address, uint256 amount)
        public
        returns (bool)
    {
        balances[from_address] = balances[from_address].sub(amount);
        balances[to_address] = balances[to_address].add(amount);
        emit Transfer(0x0, to_address, amount);
        return true;
    }
}

pragma solidity ^0.4.16;

contract DateTime {
     
    struct _DateTime {
        uint16 year;
        uint8 month;
        uint8 day;
        uint8 hour;
        uint8 minute;
        uint8 second;
        uint8 weekday;
    }

    uint constant DAY_IN_SECONDS = 86400;
    uint constant YEAR_IN_SECONDS = 31536000;
    uint constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint constant HOUR_IN_SECONDS = 3600;
    uint constant MINUTE_IN_SECONDS = 60;

    uint16 constant ORIGIN_YEAR = 1970;

    function isLeapYear(uint16 year) public pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }

    function leapYearsBefore(uint year) public pure returns (uint) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            return 31;
        }
        else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        }
        else if (isLeapYear(year)) {
            return 29;
        }
        else {
            return 28;
        }
    }

    function parseTimestamp(uint timestamp) internal pure returns (_DateTime dt) {
        uint secondsAccountedFor = 0;
        uint buf;
        uint8 i;

         
        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

         
        uint secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                dt.month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }

         
        for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                dt.day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }

         
        dt.hour = getHour(timestamp);

         
        dt.minute = getMinute(timestamp);

         
        dt.second = getSecond(timestamp);

         
        dt.weekday = getWeekday(timestamp);
    }

    function getYear(uint timestamp) public pure returns (uint16) {
        uint secondsAccountedFor = 0;
        uint16 year;
        uint numLeapYears;

         
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                    secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            }
            else {
                    secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function getMonth(uint timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).month;
    }

    function getDay(uint timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).day;
    }

    function getHour(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60 / 60) % 24);
    }

    function getMinute(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60) % 60);
    }

    function getSecond(uint timestamp) public pure returns (uint8) {
        return uint8(timestamp % 60);
    }

    function getWeekday(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, 0, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, hour, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, hour, minute, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp) {
        uint16 i;

         
        for (i = ORIGIN_YEAR; i < year; i++) {
            if (isLeapYear(i)) {
                timestamp += LEAP_YEAR_IN_SECONDS;
            }
            else {
                timestamp += YEAR_IN_SECONDS;
            }
        }

         
        uint8[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        if (isLeapYear(year)) {
            monthDayCounts[1] = 29;
        }
        else {
            monthDayCounts[1] = 28;
        }
        monthDayCounts[2] = 31;
        monthDayCounts[3] = 30;
        monthDayCounts[4] = 31;
        monthDayCounts[5] = 30;
        monthDayCounts[6] = 31;
        monthDayCounts[7] = 31;
        monthDayCounts[8] = 30;
        monthDayCounts[9] = 31;
        monthDayCounts[10] = 30;
        monthDayCounts[11] = 31;

        for (i = 1; i < month; i++) {
            timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
        }

         
        timestamp += DAY_IN_SECONDS * (day - 1);

         
        timestamp += HOUR_IN_SECONDS * (hour);

         
        timestamp += MINUTE_IN_SECONDS * (minute);

         
        timestamp += second;

        return timestamp;
    }
}

contract ZWExchange is ExchangableToken, Ownable {
    using SafeMath for uint256;

     
    event EventAddToken(address indexed token_address,
                        uint256 token_rate,
                        bool token_enable,
                        uint256 token_daily_exchange_amount_wei);

    event EventUpdateTokenRate(address indexed token_address,
                        uint256 token_rate);

    event EventUpdateTokenDailyExchangeAmount(address indexed token_address,
                        uint256 token_daily_exchange_amount_wei);

    event EventTokenSwitch(address indexed token_address,
                        bool token_enable);

    event EventCreateExchange(address indexed creator,
                        address indexed zwc_address);

    event EventExchangeSwitch(bool enable);

    event EventExchangeTokenToZWCGetToken(address indexed src_address,
                                address indexed dst_address,
                                address indexed token_address,
                                uint256 token_amount_wei);

    event EventExchangeTokenToZWC(address indexed src_address,
                                address indexed dst_address,
                                address indexed token_address,
                                uint256 token_amount_wei,
                                uint256 zwc_amount_wei);

     
     
     
    uint256 constant internal MAX_RATE_POWER = 8;     
    uint256 constant internal RATE_DECIMAL = 6;       

     
    mapping (address => TokenInfo) public tokenMap;    
    mapping (address => bool) public tokenWhiteList;   
    uint256 public tokenCount;                         
    bool public exchangeEnable;                        
    ExchangableToken public zwcToken;                  

     
    struct TokenInfo {
         
         
         
        uint256   rate;

         
        bool      enable;

         
        uint256   daily_exchange_amount_wei;

         
        uint256   latest_exchange_timestamp;

         
        uint256   today_exchange_amount_wei;
    }

     
    modifier notNullAddress(address _address) {
        require(_address != 0);
        _;
    }

     
    modifier tokenExists(address _address) {
        require(tokenWhiteList[_address]);
        _;
    }

     
    modifier tokenNotExists(address _address) {
        require(!tokenWhiteList[_address]);
        _;
    }

     
    modifier isTokenEnable(address _address) {
        require(tokenWhiteList[_address]);
        require(tokenMap[_address].enable);
        _;
    }

     
    modifier isExchangeEnable() {
        require(exchangeEnable);
        _;
    }

     
    modifier validRate(uint256 token_rate) {
        require((token_rate <= (10 ** (MAX_RATE_POWER + RATE_DECIMAL))) &&
                (token_rate >= (10 ** (0 + RATE_DECIMAL))));
        _;
    }

     
     
    constructor(ExchangableToken zwc_token)
      public
      notNullAddress(address(zwc_token))
    {
        tokenCount = 0;
        exchangeEnable = true;
        zwcToken = zwc_token;
        emit EventCreateExchange(msg.sender, address(zwc_token));
    }

     
    function ExchangeSwitch(bool enable)
        public
        onlyOwner()
    {
        exchangeEnable = enable;
        emit EventExchangeSwitch(enable);
    }

     
    function AddToken(address token_address,
                    uint256 token_rate,
                    bool token_enable,
                    uint256 token_daily_exchange_amount_wei)
        public
        onlyOwner()
        notNullAddress(token_address)
        tokenNotExists(token_address)
        validRate(token_rate)
    {
        tokenMap[token_address] = TokenInfo({
            rate:                       token_rate,
            enable:                     token_enable,
            daily_exchange_amount_wei:  token_daily_exchange_amount_wei,
            latest_exchange_timestamp:  0,
            today_exchange_amount_wei:  0
        });

        tokenCount += 1;
        tokenWhiteList[token_address] = true;

        emit EventAddToken(token_address,
                            token_rate,
                            token_enable,
                            token_daily_exchange_amount_wei);
    }

     
    function UpdateTokenRate(address token_address, uint256 token_rate)
        public
        onlyOwner()
        notNullAddress(token_address)
        tokenExists(token_address)
        validRate(token_rate)
    {
        tokenMap[token_address].rate = token_rate;
        emit EventUpdateTokenRate(token_address, token_rate);
    }

     
    function UpdateTokenDailyExchangeAmount(address token_address,
                                            uint256 token_daily_exchange_amount_wei)
        public
        onlyOwner()
        notNullAddress(token_address)
        tokenExists(token_address)
    {
        tokenMap[token_address].daily_exchange_amount_wei = token_daily_exchange_amount_wei;
        emit EventUpdateTokenDailyExchangeAmount(token_address, token_daily_exchange_amount_wei);
    }

     
    function TokenSwitch(address token_address,
                        bool enable)
        public
        onlyOwner()
        notNullAddress(token_address)
        tokenExists(token_address)
    {
        tokenMap[token_address].enable = enable;
        emit EventTokenSwitch(token_address, enable);
    }

     
    function ExchangeTokenToZWC(address token_address,
                                uint256 token_amount_wei)
        public
        notNullAddress(token_address)
        tokenExists(token_address)
        isExchangeEnable()
    {
         
        if (isDailyUplimitReach(token_address, token_amount_wei))
        {
            return;
        }

         
        uint256 zwc_amount_wei = calcZWCAmountByToken(token_address, token_amount_wei);
        if (zwc_amount_wei == 0)
        {
            emit EventExchangeTokenToZWC(msg.sender,
                                          owner,
                                          token_address,
                                          token_amount_wei,
                                          zwc_amount_wei);
            return;
        }

         
        require(zwcToken.balanceOf(address(zwcToken)) >= zwc_amount_wei);

         
        ExchangableToken otherToken = ExchangableToken(token_address);
        require(otherToken.balanceOf(msg.sender) >= token_amount_wei);

         
        require(otherToken.transferFrom(msg.sender, owner, token_amount_wei));
        emit EventExchangeTokenToZWCGetToken(msg.sender,
                                            owner,
                                            token_address,
                                            token_amount_wei);

         
        require(zwcToken.TransferToken(address(zwcToken), msg.sender, zwc_amount_wei));
        emit EventExchangeTokenToZWC(msg.sender,
                                    address(zwcToken),
                                    token_address,
                                    token_amount_wei,
                                    zwc_amount_wei);

        tokenMap[token_address].latest_exchange_timestamp = now;
        tokenMap[token_address].today_exchange_amount_wei += token_amount_wei;
        
        return;
    }

     
    function isDailyUplimitReach(address token_address,
                                uint256 token_amount_wei)
        internal
        notNullAddress(token_address)
        tokenExists(token_address)
        returns (bool)
    {
         
        DateTime dateTime = new DateTime();

        uint256 curr_day = dateTime.getDay(now);
        uint256 latest_exchange_day = dateTime.getDay(tokenMap[token_address].latest_exchange_timestamp);

         
        if (curr_day == latest_exchange_day)
        {
            if (tokenMap[token_address].today_exchange_amount_wei + token_amount_wei >
                  tokenMap[token_address].daily_exchange_amount_wei)
            {
                return true;
            }

            return false;
             
             
        }

        if (curr_day < latest_exchange_day)
        {
            return true;
             
             
        }

        if (curr_day > latest_exchange_day)
        {
            tokenMap[token_address].today_exchange_amount_wei = 0;
            return false;
        }
    }

     
    function calcZWCAmountByToken(address token_address,
                                  uint256 token_amount_wei)
        internal
        view
        notNullAddress(token_address)
        tokenExists(token_address)
        returns (uint256)
    {
        uint256 rate = tokenMap[token_address].rate;

        uint256 token_amount = fromWei(token_address, token_amount_wei);
        uint256 zwc_amount = token_amount.mul(rate);

        uint256 zwc_amount_wei = toWei(address(zwcToken), zwc_amount);
        zwc_amount_wei = zwc_amount_wei.div(10 ** RATE_DECIMAL);

        return zwc_amount_wei;
    }

    function fromWei(address _address, uint256 _amount_wei)
        internal
        view
        returns (uint256)
    {
        ExchangableToken token = ExchangableToken(_address);
        uint256 token_decimals = uint256(token.decimals());
        uint256 amount = _amount_wei.div(token_decimals);
        return amount;
    }

    function toWei(address _address, uint256 _amount)
        internal
        view
        returns (uint256)
    {
        ExchangableToken token = ExchangableToken(_address);
        uint256 token_decimals = uint256(token.decimals());
        uint256 amount_wei = _amount.mul(10 ** token_decimals);
        return amount_wei;
    }

    function createTokenContract()
      internal
      returns (ExchangableToken)
    {
        return new ExchangableToken();
    }

     
    function() public payable
    {
        revert();
    }
}