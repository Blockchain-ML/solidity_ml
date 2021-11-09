pragma solidity ^0.4.24;

 

 
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

   
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
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
    emit OwnershipTransferred(_owner, address(0));
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

 

contract DateTime {
     
    struct _DateTime {
        uint year;
        uint month;
        uint day;
        uint hour;
        uint minute;
        uint second;
        uint weekday;
    }

    uint constant DAY_IN_SECONDS = 86400;
    uint constant YEAR_IN_SECONDS = 31536000;
    uint constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint constant HOUR_IN_SECONDS = 3600;
    uint constant MINUTE_IN_SECONDS = 60;

    uint constant ORIGIN_YEAR = 1970;

    function isLeapYear(uint year) public pure returns (bool) {
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

    function getDaysInMonth(uint month, uint year) public pure returns (uint) {
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
        uint i;

         
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

    function getYear(uint timestamp) public pure returns (uint) {
        uint secondsAccountedFor = 0;
        uint year;
        uint numLeapYears;

         
        year = uint(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
                if (isLeapYear(uint(year - 1))) {
                        secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                }
                else {
                        secondsAccountedFor -= YEAR_IN_SECONDS;
                }
                year -= 1;
        }
        return year;
    }

    function getMonth(uint timestamp) public pure returns (uint) {
        return parseTimestamp(timestamp).month;
    }

    function getDay(uint timestamp) public pure returns (uint) {
        return parseTimestamp(timestamp).day;
    }

    function getHour(uint timestamp) public pure returns (uint) {
        return uint((timestamp / 60 / 60) % 24);
    }

    function getMinute(uint timestamp) public pure returns (uint) {
        return uint((timestamp / 60) % 60);
    }

    function getSecond(uint timestamp) public pure returns (uint) {
        return uint(timestamp % 60);
    }

    function getWeekday(uint timestamp) public pure returns (uint) {
        return uint((timestamp / DAY_IN_SECONDS + 4) % 7);
    }

    function toTimestamp(uint year, uint month, uint day) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, 0, 0, 0);
    }

    function toTimestamp(uint year, uint month, uint day, uint hour) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, hour, 0, 0);
    }

    function toTimestamp(uint year, uint month, uint day, uint hour, uint minute) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, hour, minute, 0);
    }

    function toTimestamp(uint year, uint month, uint day, uint hour, uint minute, uint second) public pure returns (uint timestamp) {
        uint i;

         
        for (i = ORIGIN_YEAR; i < year; i++) {
                if (isLeapYear(i)) {
                        timestamp += LEAP_YEAR_IN_SECONDS;
                }
                else {
                        timestamp += YEAR_IN_SECONDS;
                }
        }

         
        uint[12] memory monthDayCounts;
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

 

 
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

   
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

   
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

   
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

   
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

   
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

   
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

   
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

   
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

   
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

   
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

   
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

   
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

     
     
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

 

 
contract ERC20Burnable is ERC20 {

   
  function burn(uint256 value) public {
    _burn(msg.sender, value);
  }

   
  function burnFrom(address from, uint256 value) public {
    _burnFrom(from, value);
  }
}

 

 
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

   
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

   
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

   
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

 

contract MinterRole {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private minters;

  constructor() internal {
    _addMinter(msg.sender);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender));
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyMinter {
    _addMinter(account);
  }

  function renounceMinter() public {
    _removeMinter(msg.sender);
  }

  function _addMinter(address account) internal {
    minters.add(account);
    emit MinterAdded(account);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}

 

 
contract ERC20Mintable is ERC20, MinterRole {
   
  function mint(
    address to,
    uint256 value
  )
    public
    onlyMinter
    returns (bool)
  {
    _mint(to, value);
    return true;
  }
}

 

contract NGT is ERC20Mintable, ERC20Burnable, Ownable {
    using SafeMath for uint;

    string public name = "NemoGrid Token";
    string public symbol = "NGT";
    uint8 public decimals = 18;
}

 

 
contract MarketsManager is Ownable, DateTime {
    using SafeMath for uint;

     

     
    enum MarketType {
                        Monthly,
                        Daily,
                        Hourly
                    }

     
    enum MarketState {
                        None,
                        NotRunning,              
                        WaitingConfirmToStart,   
                        Running,                 
                        WaitingConfirmToEnd,     
                        WaitingForTheReferee,    
                        Closed,                  
                        ClosedAfterJudgement,    
                        ClosedNotPlayed          
                     }

     
    enum MarketResult {
                        None,
                        NotDecided,          
                        NotPlayed,           
                        Prize,               
                        Revenue,             
                        Penalty,             
                        Crash,               
                        DSOCheating,         
                        PlayerCheating,      
                        Cheaters             
                      }

     

     
    struct MarketData {
         
        address player;

         
        address referee;

         
        uint startTime;

         
        uint endTime;

         
        MarketType marketType;

         
        uint maxPowerLower;

         
        uint maxPowerUpper;

         
        uint revenueFactor;

         
        uint penaltyFactor;

         
        uint dsoStaking;

         
        uint playerStaking;

         
        uint tknReleasedToDso;

         
        uint tknReleasedToPlayer;

         
        uint powerPeakDeclaredByDso;

         
        uint powerPeakDeclaredByPlayer;

         
        uint revPercReferee;

         
        MarketState state;

         
        MarketResult result;
    }

     

     
    NGT public ngt;

     
    address public dso;

     
    mapping (uint => MarketData) marketsData;

     
    mapping (uint => bool) marketsFlag;

     

     
     
     
     
    event Opened(address player, uint startTime, uint idx);

     
     
     
     
    event ConfirmedOpening(address player, uint startTime, uint idx);

     
     
     
    event RefundedDSO(address dso, uint idx);

     
     
     
     
     
    event Settled(address player, uint startTime, uint idx, uint powerPeak);

     
     
     
     
     
    event ConfirmedSettlement(address player, uint startTime, uint idx, uint powerPeak);

     
    event SuccessfulSettlement();

     
     
     
    event UnsuccessfulSettlement(uint powerPeakDSO, uint powerPeakPlayer);

     
     
     
    event Prize(uint tokensForDso, uint tokensForPlayer);

     
     
     
    event Revenue(uint tokensForDso, uint tokensForPlayer);

     
     
     
    event Penalty(uint tokensForDso, uint tokensForPlayer);

     
     
     
    event Crash(uint tokensForDso, uint tokensForPlayer);

     
     
    event Closed(MarketResult marketResult);

     
     
     
     
    event RefereeIntervention(address player, uint startTime, uint idx);

     
    event PlayerCheated();

     
    event DSOCheated();

     
    event DSOAndPlayerCheated();

     
     
    event BurntTokens(uint burntTokens);

     
     
    event ClosedAfterJudgement(MarketResult marketResult);

     

     
     
     
    constructor(address _dso, address _token) public {
        dso = _dso;
        ngt = NGT(_token);
    }

     
     
     
     
     
     
     
     
     
     
     
     
    function open(address _player,
                  uint _startTime,
                  MarketType _type,
                  address _referee,
                  uint _maxLow,
                  uint _maxUp,
                  uint _revFactor,
                  uint _penFactor,
                  uint _stakedNGTs,
                  uint _playerNGTs,
                  uint _revPercReferee) public {

         
        uint idx = calcIdx(_player, _startTime, _type);

         
        require(msg.sender == dso);

         
        require(marketsFlag[idx] == false);

         
        require(now < _startTime);
        require(_checkStartTime(_startTime, _type));

         
        require(_referee != address(0));
        require(_referee != dso);
        require(_referee != _player);

         
        require(_maxLow < _maxUp);

         
        require(_checkRevenueFactor(_maxUp, _maxLow, _revFactor, _stakedNGTs) == true);

         
        require(_stakedNGTs <= ngt.allowance(dso, address(this)));

         
        marketsData[idx].startTime = _startTime;
        marketsData[idx].endTime = _calcEndTime(_startTime, _type);
        marketsData[idx].marketType = _type;
        marketsData[idx].referee = _referee;
        marketsData[idx].player = _player;
        marketsData[idx].maxPowerLower = _maxLow;
        marketsData[idx].maxPowerUpper = _maxUp;
        marketsData[idx].revenueFactor = _revFactor;
        marketsData[idx].penaltyFactor = _penFactor;
        marketsData[idx].dsoStaking = _stakedNGTs;
        marketsData[idx].playerStaking = _playerNGTs;
        marketsData[idx].tknReleasedToDso = 0;
        marketsData[idx].tknReleasedToPlayer = 0;
        marketsData[idx].revPercReferee = _revPercReferee;
        marketsData[idx].state = MarketState.WaitingConfirmToStart;
        marketsData[idx].result = MarketResult.NotDecided;
        marketsFlag[idx] = true;

         
        ngt.transferFrom(dso, address(this), marketsData[idx].dsoStaking);

        emit Opened(_player, _startTime, idx);
    }

     
     
     
    function confirmOpening(uint idx, uint stakedNGTs) public {

         
        require(msg.sender == marketsData[idx].player);

         
        require(marketsFlag[idx] == true);

         
        require(marketsData[idx].playerStaking == stakedNGTs);

         
        require(marketsData[idx].state == MarketState.WaitingConfirmToStart);

         
        require(stakedNGTs <= ngt.allowance(marketsData[idx].player, address(this)));

         
        require(now <= marketsData[idx].startTime);

         
        ngt.transferFrom(marketsData[idx].player, address(this), marketsData[idx].playerStaking);

         
        marketsData[idx].state = MarketState.Running;

        emit ConfirmedOpening(marketsData[idx].player, marketsData[idx].startTime, idx);
    }

     
     
    function refund(uint idx) public {
         
        require(msg.sender == dso);

         
        require(marketsFlag[idx] == true);

         
        require(marketsData[idx].state == MarketState.WaitingConfirmToStart);

         
        require(marketsData[idx].startTime < now);

         
        ngt.transfer(dso, marketsData[idx].dsoStaking);

         
        marketsData[idx].result = MarketResult.NotPlayed;

         
        marketsData[idx].state = MarketState.ClosedNotPlayed;

        emit RefundedDSO(dso, idx);
    }

     
     
     
    function settle(uint idx, uint powerPeak) public {

         
        require(msg.sender == dso);

         
        require(marketsFlag[idx] == true);

         
        require(marketsData[idx].state == MarketState.Running);

         
        require(now >= marketsData[idx].endTime);

        marketsData[idx].powerPeakDeclaredByDso = powerPeak;
        marketsData[idx].state = MarketState.WaitingConfirmToEnd;

        emit Settled(marketsData[idx].player, marketsData[idx].startTime, idx, powerPeak);
    }

     
     
     
    function confirmSettlement(uint idx, uint powerPeak) public {

         
        require(msg.sender == marketsData[idx].player);

         
        require(marketsFlag[idx] == true);

         
        require(marketsData[idx].state == MarketState.WaitingConfirmToEnd);

        marketsData[idx].powerPeakDeclaredByPlayer = powerPeak;

        emit ConfirmedSettlement(marketsData[idx].player, marketsData[idx].startTime, idx, powerPeak);

         
        if(marketsData[idx].powerPeakDeclaredByDso == marketsData[idx].powerPeakDeclaredByPlayer) {

             
            _decideMarket(idx);

            emit SuccessfulSettlement();
        }
        else {
             
            marketsData[idx].state = MarketState.WaitingForTheReferee;

            emit UnsuccessfulSettlement(marketsData[idx].powerPeakDeclaredByDso, marketsData[idx].powerPeakDeclaredByPlayer);
        }
    }

     
     
    function _decideMarket(uint idx) private {
        uint peak = marketsData[idx].powerPeakDeclaredByDso;
        uint tokensForDso;
        uint tokensForPlayer;
        uint peakDiff;

         
        if(peak <= marketsData[idx].maxPowerLower) {
            tokensForDso = 0;
            tokensForPlayer = marketsData[idx].dsoStaking.add(marketsData[idx].playerStaking);

             
            marketsData[idx].result = MarketResult.Prize;

            emit Prize(tokensForDso, tokensForPlayer);
        }
         
        else if(peak > marketsData[idx].maxPowerLower && peak <= marketsData[idx].maxPowerUpper) {
             
            peakDiff = peak.sub(marketsData[idx].maxPowerLower);

            tokensForDso = peakDiff.mul(marketsData[idx].revenueFactor);

            tokensForPlayer = marketsData[idx].dsoStaking.sub(tokensForDso);

            tokensForPlayer = tokensForPlayer.add(marketsData[idx].playerStaking);

             
            marketsData[idx].result = MarketResult.Revenue;

            emit Revenue(tokensForDso, tokensForPlayer);
        }
         
        else {
             
            peakDiff = peak.sub(marketsData[idx].maxPowerUpper);

            tokensForDso = peakDiff.mul(marketsData[idx].penaltyFactor);

             
            if(tokensForDso >= marketsData[idx].playerStaking) {
                tokensForPlayer = 0;
                tokensForDso = marketsData[idx].dsoStaking.add(marketsData[idx].playerStaking);

                 
                marketsData[idx].result = MarketResult.Crash;

                emit Crash(tokensForDso, tokensForPlayer);
            }
            else {
                tokensForPlayer = marketsData[idx].playerStaking.sub(tokensForDso);
                tokensForDso = tokensForDso.add(marketsData[idx].dsoStaking);

                 
                marketsData[idx].result = MarketResult.Penalty;

                emit Penalty(tokensForDso, tokensForPlayer);
            }
        }

        _saveAndTransfer(idx, tokensForDso, tokensForPlayer);
    }

     
     
     
     
    function _saveAndTransfer(uint idx, uint _tokensForDso, uint _tokensForPlayer) private {
         
        marketsData[idx].tknReleasedToDso = _tokensForDso;
        marketsData[idx].tknReleasedToPlayer = _tokensForPlayer;

         
        if(marketsData[idx].result != MarketResult.Prize) {
            ngt.transfer(dso, marketsData[idx].tknReleasedToDso);
        }

         
        if(marketsData[idx].result != MarketResult.Crash) {
            ngt.transfer(marketsData[idx].player, marketsData[idx].tknReleasedToPlayer);
        }

         
        marketsData[idx].state = MarketState.Closed;
        emit Closed(marketsData[idx].result);
    }

     
     
     
    function performRefereeDecision(uint idx, uint _powerPeak) public {

         
        require(msg.sender == marketsData[idx].referee);

         
        require(marketsData[idx].state == MarketState.WaitingForTheReferee);

         
        uint tokensStaked = marketsData[idx].dsoStaking.add(marketsData[idx].playerStaking);

         
        uint tokensForReferee = tokensStaked.div(uint(100).div(marketsData[idx].revPercReferee));

         
        uint tokensForHonest = tokensStaked.sub(tokensForReferee);

        emit RefereeIntervention(marketsData[idx].player, marketsData[idx].startTime, idx);

         
        if(marketsData[idx].powerPeakDeclaredByDso == _powerPeak)
        {
            marketsData[idx].result = MarketResult.PlayerCheating;

             
            ngt.transfer(dso, tokensForHonest);

            emit PlayerCheated();
        }
         
        else if(marketsData[idx].powerPeakDeclaredByPlayer == _powerPeak)
        {
            marketsData[idx].result = MarketResult.DSOCheating;

             
            ngt.transfer(marketsData[idx].player, tokensForHonest);

            emit DSOCheated();
        }
         
        else {
            marketsData[idx].result = MarketResult.Cheaters;

             
            ngt.burn(tokensForHonest);

            emit DSOAndPlayerCheated();
            emit BurntTokens(tokensForHonest);
        }

         
        ngt.transfer(marketsData[idx].referee, tokensForReferee);

         
        marketsData[idx].state = MarketState.ClosedAfterJudgement;
        emit ClosedAfterJudgement(marketsData[idx].result);
    }

     
     
     
     
     
     
    function _checkRevenueFactor(uint _maxUp, uint _maxLow, uint _revFactor, uint _stakedNGTs) pure private returns(bool) {
        uint calcNGTs = _maxUp.sub(_maxLow);
        calcNGTs = calcNGTs.mul(_revFactor);

         
        return calcNGTs == _stakedNGTs;
    }

     
     
     
     
    function _checkStartTime(uint _ts, MarketType _type) pure private returns(bool) {

         
        if(_type == MarketType.Monthly) {
            return (getDay(_ts) == 1) && (getHour(_ts) == 0) && (getMinute(_ts) == 0) && (getSecond(_ts) == 0);
        }
         
        else if(_type == MarketType.Daily) {
            return (getHour(_ts) == 0) && (getMinute(_ts) == 0) && (getSecond(_ts) == 0);
        }
         
        else if(_type == MarketType.Hourly) {
            return (getMinute(_ts) == 0) && (getSecond(_ts) == 0);
        }
         
        else {
            return false;
        }
    }

     
     
     
     
    function _calcEndTime(uint _ts, MarketType _type) pure private returns(uint) {
         
        if(_type == MarketType.Monthly) {
            return toTimestamp(getYear(_ts), getMonth(_ts), getDaysInMonth(getMonth(_ts), getYear(_ts)), 23, 59, 59);
        }
         
        else if(_type == MarketType.Daily) {
            return toTimestamp(getYear(_ts), getMonth(_ts), getDay(_ts), 23, 59, 59);
        }
         
        else if(_type == MarketType.Hourly) {
            return toTimestamp(getYear(_ts), getMonth(_ts), getDay(_ts), getHour(_ts), 59, 59);
        }
         
        else {
            return 0;
        }
    }

     
     
     
     
     
    function calcIdx(address _addr, uint _ts, MarketType _type) pure public returns(uint) {
        return uint(keccak256(abi.encodePacked(_addr, _ts, _type)));
    }

     

     
     
    function getState(uint _idx) view public returns(MarketState)       { return marketsData[_idx].state; }

     
     
    function getResult(uint _idx) view public returns(MarketResult)     { return marketsData[_idx].result; }

     
     
    function getPlayer(uint _idx) view public returns(address)          { return marketsData[_idx].player; }

     
     
    function getReferee(uint _idx) view public returns(address)         { return marketsData[_idx].referee; }

     
     
    function getStartTime(uint _idx) view public returns(uint)          { return marketsData[_idx].startTime; }

     
     
    function getEndTime(uint _idx) view public returns(uint)            { return marketsData[_idx].endTime; }

     
     
    function getLowerMaximum(uint _idx) view public returns(uint)       { return marketsData[_idx].maxPowerLower; }

     
     
    function getUpperMaximum(uint _idx) view public returns(uint)       { return marketsData[_idx].maxPowerUpper; }

     
     
    function getRevenueFactor(uint _idx) view public returns(uint)      { return marketsData[_idx].revenueFactor; }

     
     
    function getPenaltyFactor(uint _idx) view public returns(uint)      { return marketsData[_idx].penaltyFactor; }

     
     
    function getDsoStake(uint _idx) view public returns(uint)           { return marketsData[_idx].dsoStaking; }

     
     
    function getPlayerStake(uint _idx) view public returns(uint)        { return marketsData[_idx].playerStaking; }

     
     
    function getFlag(uint _idx) view public returns(bool)                { return marketsFlag[_idx];}
}

 

 
contract GroupsManager is Ownable{

     
    address public token;

     
    mapping (address => MarketsManager) groups;

     
    mapping (address => bool) groupsFlags;

     

     
     
     
    event AddedGroup(address dso, address token);

     
     
    constructor(address _token) public {
        token = _token;
    }

     
     
    function addGroup(address _dso) onlyOwner public {

         
        require(owner() != _dso);

         
        require(groupsFlags[_dso] == false);

         
        groups[_dso] = new MarketsManager(_dso, token);
        groupsFlags[_dso] = true;

        emit AddedGroup(_dso, token);
    }

     

     
     
    function getFlag(address _dso) view public returns(bool)         { return groupsFlags[_dso]; }

     
     
    function getAddress(address _dso) view public returns(address)   { return address(groups[_dso]); }
}