pragma solidity ^0.4.24;

contract ValidationInterface {
  function getValidated(address _address,uint256 _code) external pure returns (bool);
}
contract AcutalMinerInterface{
     
    uint256 public ETHUSD;
     
    uint256 public CouponRatio;
     
    uint256 public MaintenanceFee;
     
    uint256 public maintenanceDividends;
     
    uint256 public lastMaintenanceTime;
     
    uint256 public Price;
}
 
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public{
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner,"its only for administration of ActuralMiner");
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner() {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
 
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

 
contract UserInterface is Ownable{
    using SafeMath for uint256;
    
    ValidationInterface public validate;
    AcutalMinerInterface public actualminer;
    address private AcutalMinerInterfaceAddress;
    address private ValidationInterfaceAddress;
     
    uint256 public amountPlayer;
     
    uint256 public ExpiredTime;
     
    uint256 public lastExpiredIndex;
     
    uint256 public ReferralRatio;
     
    uint256 public ReferralThreshold;
     
    uint256 public amountSold;
     
    uint256 public totalDividendPoints;
    
    struct Account {
        bool Existed;
        bool ReferralActivated;
        bool Validated;
        bytes8 ReferralCode;
        uint256 ID;
        uint256 Balance;
        uint256 AffiliateBalance;     
        uint256 AffiliateTimes;     
        uint256 AffiliateToken;     
        uint256 Tokens;
        uint256 lastDividendPoints;
        uint256 totalProfits;
    }

    struct salesHistory{
        address addr;
        uint256 Tokens;
        uint256 Time;
    }
    
    mapping(address=>Account) accounts;
     
    mapping(bytes8=>address) referralMap;
    salesHistory[] public salesRecord;
    
    event eventRegister(
        address addr,
        uint256 playerID
    );
    event eventReferralActivated(
        address addr,
        bytes8 referralCode
    );
    event eventWithdraw(
        address addr,
        uint256 amount
    );
    
    constructor() public{
        ValidationInterfaceAddress = 0xD46b8Da4DB8AA6BcBd8d168BbA9681425001F1F9;
        AcutalMinerInterfaceAddress = 0x1308F82277CbA53abEa0F959073A92aD29D32BfA;
        validate = ValidationInterface(ValidationInterfaceAddress);
        actualminer = AcutalMinerInterface(AcutalMinerInterfaceAddress);
         
        amountPlayer = 0;
         
        ExpiredTime = 730 days;
         
        ReferralRatio = 250;
         
        ReferralThreshold = 10000;
         
        lastExpiredIndex = 0;
         
        amountSold = 0;
         
        totalDividendPoints = 0;
    }
    
    modifier accountExisted(address addr) {
        require(accounts[addr].Existed==true,"Accounts not existed!");
        _;
    }
    
    modifier isActualMiner() {
        require(msg.sender==AcutalMinerInterfaceAddress,"You are not official!");
        _;
    }

    modifier isValidated(address Address,uint256 inValidationCode) {
        if(!accounts[Address].Validated){
            bool Vali = validate.getValidated(Address,inValidationCode);
            if(Vali){
                accounts[Address].Validated = true;
            }
        }
        require(accounts[Address].Validated,"Accounts not verified!!");
        _;
    }
    
    modifier updateAccount(address addr) {
      uint256 balanceToAdd = dividends(addr);
      if(balanceToAdd > 0) {
        accounts[addr].Balance += balanceToAdd;
        accounts[addr].lastDividendPoints = totalDividendPoints;
      }
      _;
    }
    
    function setActualMinerAddress(address addr) external
    onlyOwner()
    {
        AcutalMinerInterfaceAddress = addr;
        actualminer = AcutalMinerInterface(AcutalMinerInterfaceAddress);
    }
    
    function setValidationAddress(address addr) external
    onlyOwner()
    {
        ValidationInterfaceAddress = addr;
        validate = ValidationInterface(ValidationInterfaceAddress);
    }
    
    function getReferralCode(address addr) external view returns(bytes8){
        require(accounts[addr].ReferralActivated,"You don&#39;t have a ReferralCode until now!");
        return accounts[addr].ReferralCode;
    }

    function getUserID(address addr) external view 
    accountExisted(addr)
    returns(uint256){
        return accounts[addr].ID;
    }
     
    function getTotalProfits(address addr) external view 
    accountExisted(addr)
    returns(uint256){
        uint256 balanceToAdd = dividends(addr);
        uint256 balanceSum = accounts[addr].Balance;
        if(balanceToAdd > 0) 
            balanceSum = balanceSum.add(balanceToAdd);
        return accounts[addr].totalProfits+balanceSum+accounts[addr].AffiliateBalance;
    } 
    
    function getlastDividendPoints(address addr) external view
    accountExisted(addr)
    returns(uint256)
    {
        return accounts[addr].lastDividendPoints;
    }
    
    function getToken(address addr) external view
    accountExisted(addr)
    returns(uint256)
    {
        return accounts[addr].Tokens;
    }
    
    function getBalance(address addr) external view
    accountExisted(addr)
    returns(uint256,uint256)
    {
        uint256 balanceToAdd = dividends(addr);
        uint256 balanceSum = accounts[addr].Balance;
        if(balanceToAdd > 0) 
            balanceSum = balanceSum.add(balanceToAdd);
        return (balanceSum,accounts[addr].AffiliateBalance);
    }
    
    
    function ReferralActivated(address addr) private
    accountExisted(addr)
    {
        if (accounts[addr].ReferralCode!=bytes8(0)){
             
            bytes8 ReferralCode;
            uint8 i = 0;
            do{
                ReferralCode = bytes8(uint256(keccak256(abi.encodePacked(addr))).add(uint256(i)));
                i++;
            }while(referralMap[ReferralCode]!=address(0) || ReferralCode==bytes8(0));
            referralMap[ReferralCode] = addr;
            accounts[addr].ReferralCode = ReferralCode;
            accounts[addr].ReferralActivated = true;
            emit eventReferralActivated(addr,ReferralCode);
        }
    }
    
    
    function registerCustomer(address addr) private
    {
        require(accounts[addr].Existed==false,"Customer existed!");
        amountPlayer++;
        accounts[addr].ID = uint256(amountPlayer);
        accounts[addr].Existed = true;
        accounts[addr].lastDividendPoints = totalDividendPoints;

         
         
         
         
         
         
        emit eventRegister(addr,amountPlayer);
    }
    
    
    function dividends(address addr) private view returns(uint256) {
      uint256 newDividend = (totalDividendPoints.sub(accounts[addr].lastDividendPoints)).mul(accounts[addr].Tokens);
      return newDividend;
    }
    
    function buyTokens_ETH(address addr,uint256 ethAmount,uint256 validationCode,bytes8 affCode) external 
    isActualMiner()
    isValidated(addr,validationCode)
    returns(uint256)
    {
        uint256 PriceNow = actualminer.Price();
         
        if(accounts[addr].Existed==false)
            registerCustomer(addr);
         
        if(accounts[referralMap[affCode]].ReferralActivated){
            PriceNow = PriceNow.mul(actualminer.CouponRatio()).div(10000);
             
            accounts[referralMap[affCode]].AffiliateBalance += ethAmount.div(uint256(10000).div(ReferralRatio)); 
        }

        if(ReferralThreshold > accounts[addr].Tokens && ReferralThreshold <= (accounts[addr].Tokens.add(token)))
            ReferralActivated(msg.sender);
        
        uint256 token = ethAmount.mul(actualminer.ETHUSD()).div(1e30).div(PriceNow);

        if(accounts[referralMap[affCode]].ReferralActivated){
            accounts[referralMap[affCode]].AffiliateTimes += 1;
            accounts[referralMap[affCode]].AffiliateToken += token;
        }

        uint256 dividendShift = totalDividendPoints.sub(accounts[addr].lastDividendPoints)*(accounts[addr].Tokens.div(accounts[addr].Tokens.add(token)));
        accounts[addr].lastDividendPoints = totalDividendPoints.sub(dividendShift);
        accounts[addr].Tokens += token;
        amountSold += token;
        salesRecord.push(salesHistory(addr,token,now));
        return token;
    }
    
    function buyTokens_Vault(address addr,uint256 ethAmount,bytes8 affCode) external 
    isActualMiner()
    accountExisted(addr)
    updateAccount(addr)
    returns(uint256)
    {
        uint256 totalBalance = accounts[addr].Balance.add(accounts[addr].AffiliateBalance);
        uint256 PriceNow = actualminer.Price();
         
        require(totalBalance>=ethAmount,"Vault not enought!");
        
         
        if(accounts[referralMap[affCode]].ReferralActivated){
            PriceNow = PriceNow.mul(actualminer.CouponRatio()).div(10000);
             
            accounts[referralMap[affCode]].AffiliateBalance += ethAmount.mul(ReferralRatio).div(uint256(10000)); 

        }

        if(ReferralThreshold > accounts[addr].Tokens && ReferralThreshold <= (accounts[addr].Tokens.add(token)))
            ReferralActivated(addr);

        uint256 token = ethAmount.mul(actualminer.ETHUSD()).div(1e30).div(PriceNow);
        
        if(accounts[referralMap[affCode]].ReferralActivated){
            accounts[referralMap[affCode]].AffiliateTimes += 1;
            accounts[referralMap[affCode]].AffiliateToken += token;
        }
        
        if(accounts[addr].AffiliateBalance>ethAmount){
            accounts[addr].AffiliateBalance-=ethAmount;
        }
        else{
            accounts[addr].Balance -= (ethAmount.sub(accounts[addr].AffiliateBalance));
            accounts[addr].AffiliateBalance -= 0;
        }
        
        uint256 dividendShift = totalDividendPoints.sub(accounts[addr].lastDividendPoints)*(accounts[addr].Tokens.div(accounts[addr].Tokens.add(token)));
        accounts[addr].lastDividendPoints = totalDividendPoints.sub(dividendShift);
        accounts[addr].Tokens += token;
        amountSold += token;

        salesRecord.push(salesHistory(addr,token,now));
        return token;
    }
     
    function buyTokens_Address(address addr,uint256 token,bytes8 affCode) external
    isActualMiner()
    returns(bool)
    {
        uint256 PriceNow = actualminer.Price();
         
        if(accounts[addr].Existed==false)
            registerCustomer(addr);
         
        if(!accounts[addr].Validated)
            accounts[addr].Validated = true;
         
        if(accounts[referralMap[affCode]].ReferralActivated){
            PriceNow = PriceNow.mul(actualminer.CouponRatio()).div(uint256(10000));
             
            accounts[referralMap[affCode]].AffiliateBalance += token.mul(PriceNow).mul(ReferralRatio).div(actualminer.ETHUSD()).div(uint256(1e6)).div(uint256(10000)); 
            accounts[referralMap[affCode]].AffiliateTimes += 1;
            accounts[referralMap[affCode]].AffiliateToken += token;
        }
        
        if(ReferralThreshold > accounts[addr].Tokens && ReferralThreshold <= (accounts[addr].Tokens.add(token)))
            ReferralActivated(addr);
            
        uint256 dividendShift = totalDividendPoints.sub(accounts[addr].lastDividendPoints)*(accounts[addr].Tokens.div(accounts[addr].Tokens.add(token)));
        accounts[addr].lastDividendPoints = totalDividendPoints.sub(dividendShift);
        accounts[addr].Tokens += token;
        amountSold += token;
        salesRecord.push(salesHistory(addr,token,now));
        
        return true;
    }
    
    function checkExpired() external{
        uint256 arrayLength = salesRecord.length;
        uint256 timeNow = now;
        uint256 i = lastExpiredIndex;
        for (; i<arrayLength; i++) {
          if((timeNow-salesRecord[i].Time)>ExpiredTime){
             
            accounts[salesRecord[i].addr].lastDividendPoints = totalDividendPoints.sub((totalDividendPoints.sub(accounts[salesRecord[i].addr].lastDividendPoints)).mul(accounts[salesRecord[i].addr].Tokens).div(accounts[salesRecord[i].addr].Tokens.sub(salesRecord[i].Tokens)));
            accounts[salesRecord[i].addr].Tokens -= salesRecord[i].Tokens;
          }
          else
            break;
        }
        lastExpiredIndex = i;
    }
    
    function withdraw(address addr) external 
    isActualMiner()
    accountExisted(addr)
    updateAccount(addr)
    returns(uint256){
        uint256 BalanceWithdraw = accounts[addr].Balance.add(accounts[addr].AffiliateBalance);
        accounts[addr].Balance = 0;
        accounts[addr].AffiliateBalance = 0;
        accounts[addr].lastDividendPoints =  totalDividendPoints;
        accounts[addr].totalProfits = accounts[addr].totalProfits.add(BalanceWithdraw);
        emit eventWithdraw(addr,BalanceWithdraw);
        return BalanceWithdraw;
    }
    

    function addTotalDividendPoints(uint256 tdp) external
    isActualMiner(){
        totalDividendPoints = totalDividendPoints.add(tdp);
    }

    function kill() external 
    onlyOwner(){
        selfdestruct(owner);
    }
    
    function () payable public{
    }
}