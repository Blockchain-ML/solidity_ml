pragma solidity ^0.4.25;

 


library SafeMath {
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
     
     
     
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0);  
    uint256 c = _a / _b;
     

    return c;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}


library Percent {
   
  struct percent {
    uint num;
    uint den;
  }
  function mul(percent storage p, uint a) internal view returns (uint) {
    if (a == 0) {
      return 0;
    }
    return a*p.num/p.den;
  }

  function div(percent storage p, uint a) internal view returns (uint) {
    return a/p.num*p.den;
  }

  function sub(percent storage p, uint a) internal view returns (uint) {
    uint b = mul(p, a);
    if (b >= a) return 0;
    return a - b;
  }

  function add(percent storage p, uint a) internal view returns (uint) {
    return a + mul(p, a);
  }
}


library Zero {
  function requireNotZero(uint a) internal pure {
    require(a != 0, "require not zero");
  }

  function requireNotZero(address addr) internal pure {
    require(addr != address(0), "require not zero address");
  }

  function notZero(address addr) internal pure returns(bool) {
    return !(addr == address(0));
  }

  function isZero(address addr) internal pure returns(bool) {
    return addr == address(0);
  }
}


library ToAddress {
  function toAddr(uint source) internal pure returns(address) {
    return address(source);
  }

  function toAddr(bytes source) internal pure returns(address addr) {
    assembly { addr := mload(add(source,0x14)) }
    return addr;
  }
}





contract InvestorsStorage {
  struct investor {
    uint keyIndex;
    uint value;
    uint paymentTime;
    uint refs;
    uint refBonus;
  }
  struct bestAddress {
      uint value;
      address addr;
  }
  struct itmap {
    mapping(address => investor) data;
    address[] keys;
    bestAddress bestInvestor;
    bestAddress bestPromouter;
  }
  itmap private s;
  address private owner;

  modifier onlyOwner() {
    require(msg.sender == owner, "access denied");
    _;
  }

  constructor() public {
    owner = msg.sender;
    s.keys.length++;
  }

  function insert(address addr, uint value) public onlyOwner returns (bool) {
    uint keyIndex = s.data[addr].keyIndex;
    if (keyIndex != 0) return false;
    s.data[addr].value = value;
    keyIndex = s.keys.length++;
    s.data[addr].keyIndex = keyIndex;
    s.keys[keyIndex] = addr;
    return true;
  }

  function investorFullInfo(address addr) public view returns(uint, uint, uint, uint, uint) {
    return (
      s.data[addr].keyIndex,
      s.data[addr].value,
      s.data[addr].paymentTime,
      s.data[addr].refs,
      s.data[addr].refBonus
    );
  }

  function investorBaseInfo(address addr) public view returns(uint, uint, uint, uint) {
    return (
      s.data[addr].value,
      s.data[addr].paymentTime,
      s.data[addr].refs,
      s.data[addr].refBonus
    );
  }

  function investorShortInfo(address addr) public view returns(uint, uint) {
    return (
      s.data[addr].value,
      s.data[addr].refBonus
    );
  }

  function getBestInvestor() public view returns(uint, address) {
    return (
      s.bestInvestor.value,
      s.bestInvestor.addr
    );
  }
  
  function getBestPromouter() public view returns(uint, address) {
    return (
      s.bestInvestor.value,
      s.bestInvestor.addr
    );
  }

  function addRefBonus(address addr, uint refBonus) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].refBonus += refBonus;
    return true;
  }
  
  function addRefBonusWithRefs(address addr, uint refBonus) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].refBonus += refBonus;
    s.data[addr].refs++;
    
    if(s.data[addr].refs > s.bestPromouter.value){
        s.bestPromouter.value = s.data[addr].refs;
        s.bestPromouter.addr = addr;
    }
    
    return true;
  }

  function addValue(address addr, uint value) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].value += value;
    
    if(s.data[addr].value > s.bestInvestor.value){
        s.bestInvestor.value = s.data[addr].value;
        s.bestInvestor.addr = addr;
    }
    
    return true;
  }

  function setPaymentTime(address addr, uint paymentTime) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].paymentTime = paymentTime;
    return true;
  }

  function setRefBonus(address addr, uint refBonus) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].refBonus = refBonus;
    return true;
  }

  function keyFromIndex(uint i) public view returns (address) {
    return s.keys[i];
  }

  function contains(address addr) public view returns (bool) {
    return s.data[addr].keyIndex > 0;
  }

  function size() public view returns (uint) {
    return s.keys.length;
  }

  function iterStart() public pure returns (uint) {
    return 1;
  }
}


contract Accessibility {
  enum AccessRank { None, Payout, Paymode, Full }
  mapping(address => AccessRank) internal m_admins;
  modifier onlyAdmin(AccessRank  r) {
    require(
      m_admins[msg.sender] == r || m_admins[msg.sender] == AccessRank.Full,
      "access denied"
    );
    _;
  }
  event LogProvideAccess(address indexed whom, uint when,  AccessRank rank);

  constructor() public {
    m_admins[msg.sender] = AccessRank.Full;
    emit LogProvideAccess(msg.sender, now, AccessRank.Full);
  }
  
  function provideAccess(address addr, AccessRank rank) public onlyAdmin(AccessRank.Full) {
    require(rank <= AccessRank.Full, "invalid access rank");
    require(m_admins[addr] != AccessRank.Full, "cannot change full access rank");
    if (m_admins[addr] != rank) {
      m_admins[addr] = rank;
      emit LogProvideAccess(addr, now, rank);
    }
  }

  function access(address addr) public view returns(AccessRank rank) {
    rank = m_admins[addr];
  }
}


contract PaymentSystem {
   
  enum Paymode { Push, Pull }
  struct PaySys {
    uint latestTime;
    uint latestKeyIndex;
    Paymode mode; 
  }
  PaySys internal m_paysys;

  modifier atPaymode(Paymode mode) {
    require(m_paysys.mode == mode, "pay mode does not the same");
    _;
  }
  event LogPaymodeChanged(uint when, Paymode indexed mode);
  
  function paymode() public view returns(Paymode mode) {
    mode = m_paysys.mode;
  }

  function changePaymode(Paymode mode) internal {
    require(mode <= Paymode.Pull, "invalid pay mode");
    if (mode == m_paysys.mode ) return; 
    if (mode == Paymode.Pull) require(m_paysys.latestTime != 0, "cannot set pull pay mode if latest time is 0");
    if (mode == Paymode.Push) m_paysys.latestTime = 0;
    m_paysys.mode = mode;
    emit LogPaymodeChanged(now, m_paysys.mode);
  }
}



contract EarnEveryDay_v1_355 is Accessibility, PaymentSystem {
  using Percent for Percent.percent;
  using SafeMath for uint;
  using Zero for *;
  using ToAddress for *;

   
  InvestorsStorage private m_investors;
  mapping(address => address) private m_referrals;
  bool private m_nextWave;

   
  address public adminAddr;
  uint public waveStartup;
  uint public investmentsNum;
  uint public totalInvested;
  uint public constant minInvesment = 10 finney;  
  uint public constant maxBalance = 355e5 ether;  
  uint public constant pauseOnNextWave = 168 hours; 
  uint public constant dividendsPeriod = 2 hours;  

   
  Percent.percent private m_dividendsPercent = Percent.percent(355, 10000);  
  Percent.percent private m_adminPercent = Percent.percent(5, 100);  
  Percent.percent private m_refPercent1 = Percent.percent(3, 100);  
  Percent.percent private m_refPercent2 = Percent.percent(2, 100);  

   
  event LogNewInvestor(address indexed addr, uint when, uint value);
  event LogNewInvesment(address indexed addr, uint when, uint value);
  event LogNewReferral(address indexed addr, uint when, uint value);
  event LogPayDividends(address indexed addr, uint when, uint value);
  event LogPayReferrerBonus(address indexed addr, uint when, uint value);
  event LogBalanceChanged(uint when, uint balance);
  event LogAdminAddrChanged(address indexed addr, uint when);
  event LogNextWave(uint when);

  modifier balanceChanged {
    _;
    emit LogBalanceChanged(now, address(this).balance);
  }

  modifier notOnPause() {
    require(waveStartup+pauseOnNextWave <= now, "pause on next wave not expired");
    _;
  }

  constructor() public {
    adminAddr = msg.sender;
    emit LogAdminAddrChanged(msg.sender, now);

    nextWave();
    waveStartup = waveStartup.sub(pauseOnNextWave);
  }

  function() public payable {
     
    if (msg.value == 0) {
      getMyDividends();
      return;
    }

     
    address a = msg.data.toAddr();
    doInvest(a);
  }

  function investorsNumber() public view returns(uint) {
    return m_investors.size()-1;
     
  }

  function balanceETH() public view returns(uint) {
    return address(this).balance;
  }

  function dividendsPercent() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_dividendsPercent.num, m_dividendsPercent.den);
  }

  function adminPercent() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_adminPercent.num, m_adminPercent.den);
  }

  function referrer1Percent() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_refPercent1.num, m_refPercent1.den);
  }
  
  function referrer2Percent() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_refPercent2.num, m_refPercent2.den);
  }

  function investorInfo(address addr) public view returns(uint value, uint paymentTime, uint refsCount, uint refBonus, bool isReferral) {
    (value, paymentTime, refsCount, refBonus) = m_investors.investorBaseInfo(addr);
    isReferral = m_referrals[addr].notZero();
  }
  
  function bestInvestorInfo() public view returns(uint value, address addr) {
    (value, addr) = m_investors.getBestInvestor();
  }
  
  function bestPromouterInfo() public view returns(uint value, address addr) {
    (value, addr) = m_investors.getBestPromouter();
  }
  
  function latestPayout() public view returns(uint timestamp) {
    return m_paysys.latestTime;
  }

  function getMyDividends() public notOnPause atPaymode(Paymode.Pull) balanceChanged {
     
    InvestorsStorage.investor memory investor = getMemInvestor(msg.sender);
    require(investor.keyIndex > 0, "sender is not investor"); 
    if (investor.paymentTime < m_paysys.latestTime) {
      assert(m_investors.setPaymentTime(msg.sender, m_paysys.latestTime));
      investor.paymentTime = m_paysys.latestTime;
    }

     
    uint256 daysAfter = now.sub(investor.paymentTime).div(dividendsPeriod);
    require(daysAfter > 0, "the latest payment was earlier than dividents period");
    assert(m_investors.setPaymentTime(msg.sender, now));

     
    uint value = m_dividendsPercent.mul(investor.value) * daysAfter;
    if (address(this).balance < value + investor.refBonus) {
      nextWave();
      return;
    }

     
    if (investor.refBonus > 0) {
      assert(m_investors.setRefBonus(msg.sender, 0));
      sendDividendsWithRefBonus(msg.sender, value, investor.refBonus);
    } else {
      sendDividends(msg.sender, value);
    }
  }

  function doInvest(address ref) public payable notOnPause balanceChanged {
    require(msg.value >= minInvesment, "msg.value must be >= minInvesment");
    require(address(this).balance <= maxBalance, "the contract eth balance limit");

    uint value = msg.value;
     
    if (m_referrals[msg.sender].notZero()) {
       
      if (notZeroNotSender(ref) && m_investors.contains(ref)) {
        uint reward = m_refPercent1.mul(value);
        assert(m_investors.addRefBonusWithRefs(ref, reward));  
        m_referrals[msg.sender] = ref;
        value = m_dividendsPercent.add(value);  
        emit LogNewReferral(msg.sender, now, value);
         
        if (notZeroNotSender(m_referrals[ref]) && m_investors.contains(m_referrals[ref]) && ref != m_referrals[ref]) { 
          reward = m_refPercent2.mul(value);
          assert(m_investors.addRefBonus(m_referrals[ref], reward));  
        }
      }
    }else{
        InvestorsStorage.bestAddress memory bestInvestor = getMemBestInvestor();
        InvestorsStorage.bestAddress memory bestPromouter = getMemBestPromouter();
        if(notZeroNotSender(bestInvestor.addr)){
          assert(m_investors.addRefBonusWithRefs(bestInvestor.addr, m_refPercent1.mul(value) ));  
          m_referrals[msg.sender] = bestInvestor.addr;
        }
        if(notZeroNotSender(bestPromouter.addr)){
          assert(m_investors.addRefBonusWithRefs(bestInvestor.addr, m_refPercent2.mul(value) ));  
          m_referrals[msg.sender] = bestPromouter.addr;
        }
    }

     
    adminAddr.transfer(m_adminPercent.mul(msg.value));
    
     
    if (m_investors.contains(msg.sender)) {
      assert(m_investors.addValue(msg.sender, value));
    } else {
      assert(m_investors.insert(msg.sender, value));
      emit LogNewInvestor(msg.sender, now, value); 
    }
    
    if (m_paysys.mode == Paymode.Pull)
      assert(m_investors.setPaymentTime(msg.sender, now));

    emit LogNewInvesment(msg.sender, now, value);   
    investmentsNum++;
    totalInvested += msg.value;
  }

  function payout() public notOnPause onlyAdmin(AccessRank.Payout) atPaymode(Paymode.Push) balanceChanged {
    if (m_nextWave) {
      nextWave(); 
      return;
    }
   
     
    if (m_paysys.latestKeyIndex == m_investors.iterStart()) {
      require(now>m_paysys.latestTime+dividendsPeriod.div(2), "the latest payment was earlier than half of divident period");
      m_paysys.latestTime = now;
    }

    uint i = m_paysys.latestKeyIndex;
    uint value;
    uint refBonus;
    uint size = m_investors.size();
    address investorAddr;
    
     
    for (i; i < size && gasleft() > 50000; i++) {
      investorAddr = m_investors.keyFromIndex(i);
      (value, refBonus) = m_investors.investorShortInfo(investorAddr);
      value = m_dividendsPercent.mul(value);

      if (address(this).balance < value + refBonus) {
        m_nextWave = true;
        break;
      }

      if (refBonus > 0) {
        require(m_investors.setRefBonus(investorAddr, 0), "internal error");
        sendDividendsWithRefBonus(investorAddr, value, refBonus);
        continue;
      }

      sendDividends(investorAddr, value);
    }

    if (i == size) 
      m_paysys.latestKeyIndex = m_investors.iterStart();
    else 
      m_paysys.latestKeyIndex = i;
  }

  function setAdminAddr(address addr) public onlyAdmin(AccessRank.Full) {
    addr.requireNotZero();
    if (adminAddr != addr) {
      adminAddr = addr;
      emit LogAdminAddrChanged(addr, now);
    }    
  }

  function setPullPaymode() public onlyAdmin(AccessRank.Paymode) atPaymode(Paymode.Push) {
    changePaymode(Paymode.Pull);
  }

  function getMemInvestor(address addr) internal view returns(InvestorsStorage.investor) {
    (uint a, uint b, uint c, uint d, uint e) = m_investors.investorFullInfo(addr);
    return InvestorsStorage.investor(a, b, c, d, e);
  }
  
  function getMemBestInvestor() internal view returns(InvestorsStorage.bestAddress) {
    (uint value, address addr) = m_investors.getBestInvestor();
    return InvestorsStorage.bestAddress(value, addr);
  }
  
  function getMemBestPromouter() internal view returns(InvestorsStorage.bestAddress) {
    (uint value, address addr) = m_investors.getBestPromouter();
    return InvestorsStorage.bestAddress(value, addr);
  }

  function notZeroNotSender(address addr) internal view returns(bool) {
    return addr.notZero() && addr != msg.sender;
  }

  function sendDividends(address addr, uint value) private {
    if (addr.send(value)) emit LogPayDividends(addr, now, value); 
  }

  function sendDividendsWithRefBonus(address addr, uint value,  uint refBonus) private {
    if (addr.send(value+refBonus)) {
      emit LogPayDividends(addr, now, value);
      emit LogPayReferrerBonus(addr, now, refBonus);
    }
  }

  function nextWave() private {
    m_investors = new InvestorsStorage();
    changePaymode(Paymode.Push);
    m_paysys.latestKeyIndex = m_investors.iterStart();
    investmentsNum = 0;
    waveStartup = now;
    m_nextWave = false;
    emit LogNextWave(now);
  }
}