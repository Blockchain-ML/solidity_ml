pragma solidity ^0.4.24;

contract ValidationInterface {
  function getValidated(address _address,uint256 _code) public view returns (bool);
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

contract ActuralMiner is Ownable{
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     

     
     
     
     
     
     
     
    
    event eventByAddress(address,bytes8,uint256,uint256,uint256);
    event eventByETH(bytes8,uint256,uint256,uint256);
    event eventByVault();
    event eventWithdraw(uint256,uint256);
    event eventRegister(address,uint256);
    event eventReferralActivated(address,bytes8,uint256);
    event eventDivideProfit(address,uint256,uint256,uint256);
    
    address public AdminWallet;
    address public Manager;

    address ValidationInterfaceAddress = 0x272a43805714624F4c8179f5aFf7b711C0F073c5;
    ValidationInterface ValidationContract = ValidationInterface(ValidationInterfaceAddress);
     
    uint256 public TotalHashRate;
     
    uint256 public Price;
     
    uint256 public ExpiredTime;
     
    uint256 public lastExpiredIndex;
     
    uint256 public ETHUSD;
     
    uint256 public lastUpdateETHUSD;
     
    uint256 public IntervalETHUSD;
     
    uint256 public amountPlayer;
     
    uint256 public amountSold;
     
    uint256 public CouponRatio;
     
    uint256 public ReferralRatio;
     
    uint256 public ReferralThreshold;
     
    uint256 public totalDividendPoints;
     
    uint256 public unclaimedDividends;
     
    uint256 public MaintenanceFee;
     
    uint256 public maintenanceDividends;
     
    uint256 public lastMaintenanceTime;
    
    struct Account {
        bool Validated;
        bytes8 ReferralCode;
        uint256 ID;
        uint256 Balance;
        uint256 AffiliateBalance;     
        uint256 Tokens;
        uint256 lastDividendPoints;
    }

    struct salesHistory{
        address addr;
        uint8 method;
        bytes8 ReferralCode;
        uint256 Tokens;
        uint256 Time;
    }
    
    mapping(address=>Account) accounts;
     
    mapping(bytes8=>address) referralMap;
    salesHistory[] public salesRecord;
    
    constructor() public{
        
        AdminWallet = msg.sender;
        Manager = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;
        
         
        TotalHashRate = 30000000;
         
        Price = 24000;
         
        ExpiredTime = 730 days;
         
        CouponRatio = 9000;
         
        lastUpdateETHUSD = 0;
         
        IntervalETHUSD = 60;
         
        amountPlayer = 1;
         
        amountSold = 0;
         
        ReferralRatio = 250;
         
        ReferralThreshold = 40000;
         
        totalDividendPoints = 0;
         
        unclaimedDividends = 0;
         
        MaintenanceFee = 12;
         
        lastMaintenanceTime = now;
         
        lastExpiredIndex = 0;

        getETHUSD();

    }

    modifier onlyManager(){
        require(msg.sender == Manager, "its only for manager of ActuralMiner");
        _;
    }
    
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
    
    modifier accountExisted(address addr) {
        uint256 CustomerID = accounts[addr].ID;
        require(CustomerID!=0,"Accounts not existed!");
        _;
    }

    modifier isValidated(address Address,uint256 inValidationCode) {
        if(!accounts[Address].Validated){
            bool Vali = ValidationContract.getValidated(Address,inValidationCode);
            if(Vali){
                accounts[Address].Validated = true;
            }
        }
        require(accounts[Address].Validated,"Accounts not verified!!");
        _;
    }
    
     
    function setAdminWallet(address _newAdminWallet) external
    onlyOwner()
    {
        require(_newAdminWallet != 0x0);
        AdminWallet = _newAdminWallet;
    }
    
    
    function setManager(address _newManager) external
    onlyOwner()
    {
        require(_newManager != 0x0);
        Manager = _newManager;
    }
    
    function setPrice(uint32 _newPrice) external
    onlyOwner()
    {
        require(_newPrice > 0);
        Price = _newPrice;
    }
    
    function setCouponRatio(uint32 _newCouponRatio) external
    onlyOwner()
    {
        require(_newCouponRatio > 0);
        CouponRatio = _newCouponRatio;
    }
    
    function setSupply(uint256 _newSupply) external
    onlyOwner()
    {
        require(_newSupply > 0);
        TotalHashRate = _newSupply;
    }
    
    function getReferralCode() public view returns(bytes8){
        require(accounts[msg.sender].ReferralCode!=bytes8(0),"You don&#39;t have a ReferralCode until now!");
        return accounts[msg.sender].ReferralCode;
    }
    
     
    function getMaintainFee() private view returns(uint256){
        return (now-lastMaintenanceTime)*MaintenanceFee*amountSold;
    }
    
    function getETHUSD() private{
        require((now-lastUpdateETHUSD)>IntervalETHUSD);
        
        ETHUSD = uint256(400000);
        lastUpdateETHUSD = now;
    }
    
    function getToken() public view
    accountExisted(msg.sender)
    returns(uint256)
    {
        return accounts[msg.sender].Tokens;
    }
    
    function getBalance() public view
    accountExisted(msg.sender)
    returns(uint256,uint256)
    {
        uint256 balanceToAdd = dividends(msg.sender);
        uint256 balanceSum = accounts[msg.sender].Balance;
        if(balanceToAdd > 0) 
            balanceSum += balanceToAdd;
        return (balanceSum,accounts[msg.sender].AffiliateBalance);
    }
    
    function getID() public view
    accountExisted(msg.sender)
    returns(uint256)
    {
        return (accounts[msg.sender].ID);
    }
    
    function getReferral() public view
    returns(bytes8)
    {
         
        bytes8 ReferralCode;
        do{
            ReferralCode = bytes8(keccak256(abi.encodePacked(msg.sender)));
        }while(referralMap[ReferralCode]!=address(0) || ReferralCode==bytes8(0));
        return ReferralCode;
    }
    
    
     
    function checkInventory(uint256 amountBuy) private view returns(bool){
        if(amountBuy<=TotalHashRate-amountSold)
            return true;
        else
            return false;
    }
    
    function ReferralActivated(address addr) private{
         
        bytes8 ReferralCode;
        do{
            ReferralCode = bytes8(keccak256(abi.encodePacked(addr)));
        }while(referralMap[ReferralCode]!=address(0) || ReferralCode==bytes8(0));
        referralMap[ReferralCode] = addr;
        accounts[addr].ReferralCode = ReferralCode;
        emit eventReferralActivated(addr,ReferralCode,now);
    }
    
     
     
     
    function buy_ETH(uint256 validationCode,bytes8 affCode) payable public
    isValidated(msg.sender,validationCode)
    {
        getETHUSD();
        uint256 priceNow = Price;
        uint256 CustomerID = accounts[msg.sender].ID;
        uint256 token = msg.value/priceNow;
         
        if(CustomerID==0)
            registerCustomer(msg.sender);
            
         
        if(referralMap[affCode]!=address(0)){
            priceNow = priceNow*CouponRatio/10000;
             
            accounts[referralMap[affCode]].AffiliateBalance += msg.value/(10000/ReferralRatio); 
        }
        if(accounts[msg.sender].ReferralCode==bytes8(0) && ReferralThreshold > accounts[msg.sender].Tokens && ReferralThreshold <= (accounts[msg.sender].Tokens + token))
            ReferralActivated(msg.sender);
         
        accounts[msg.sender].lastDividendPoints = totalDividendPoints - (totalDividendPoints-accounts[msg.sender].lastDividendPoints)*accounts[msg.sender].Tokens/(accounts[msg.sender].Tokens+token);
        accounts[msg.sender].Tokens += token;
        amountSold += msg.value/priceNow;


        salesRecord.push(salesHistory(msg.sender,1,affCode,token,now));
        emit eventByETH(affCode,priceNow,token,now);
         
    }
    
     
     
     
    function buyAddress(address addr,bytes8 affCode,uint256 token) public
    onlyManager()
     
    {
        uint256 priceNow = Price;
        uint256 CustomerID = accounts[addr].ID;
         
        if(CustomerID==0)
            registerCustomer(addr);
         
        if(referralMap[affCode]!=address(0)){
            priceNow = priceNow*CouponRatio/10000;
             
            accounts[referralMap[affCode]].AffiliateBalance += token*priceNow/(10000/ReferralRatio); 
        }
        
        if(accounts[addr].ReferralCode!=bytes8(0) && ReferralThreshold > accounts[addr].Tokens && ReferralThreshold <= (accounts[addr].Tokens + token))
            ReferralActivated(addr);
         
        accounts[addr].lastDividendPoints = totalDividendPoints - (totalDividendPoints-accounts[addr].lastDividendPoints)*accounts[addr].Tokens/(accounts[addr].Tokens+token);
        accounts[addr].Tokens += token;
        amountSold += token;

        salesRecord.push(salesHistory(addr,0,affCode,token,now));
        
        emit eventByAddress(addr,affCode,priceNow,token,now);
         
    }
    
    function checkExpired() private{
        uint256 arrayLength = salesRecord.length;
        uint256 timeNow = now;
        uint256 i = lastExpiredIndex;
        for (; i<arrayLength; i++) {
          if((timeNow-salesRecord[i].Time)>ExpiredTime){
            amountSold -= salesRecord[i].Tokens;
             
            accounts[salesRecord[i].addr].lastDividendPoints = accounts[salesRecord[i].addr].lastDividendPoints*(accounts[salesRecord[i].addr].Tokens)/(accounts[salesRecord[i].addr].Tokens-salesRecord[i].Tokens);
            accounts[salesRecord[i].addr].Tokens -= salesRecord[i].Tokens;
          }
          else
            break;
        }
        lastExpiredIndex = i;
    }
    
    function registerCustomer(address customer) private
    isHuman()
    {
        uint256 CustomerID = accounts[customer].ID;
        require(CustomerID==0,"Customer existed!");
        accounts[customer].ID = amountPlayer;
         
        accounts[customer].Balance = 0;
        accounts[customer].AffiliateBalance = 0;
        accounts[customer].Tokens = 0;
        accounts[customer].Validated = true;
        accounts[customer].ReferralCode = 0x0000000000000000;
         
        amountPlayer++;
        emit eventRegister(customer,amountPlayer);
    }
    
    modifier updateAccount(address addr) {
      uint256 balanceToAdd = dividends(addr);
      if(balanceToAdd > 0) {
         
        accounts[addr].Balance += balanceToAdd;
        accounts[addr].lastDividendPoints = totalDividendPoints;
      }
      _;
    }
    
     
    function withdraw() public
    isHuman()
    updateAccount(msg.sender)
    {   
        address Addr = msg.sender;
        uint256 BalanceWithdraw = accounts[Addr].Balance+accounts[Addr].AffiliateBalance;
        accounts[Addr].Balance = 0;
        accounts[Addr].AffiliateBalance = 0;
        accounts[Addr].lastDividendPoints =  totalDividendPoints;
        unclaimedDividends -= BalanceWithdraw;
        Addr.transfer(BalanceWithdraw);
        emit eventWithdraw(BalanceWithdraw,now);
    }
    
     
    function () payable public{
        checkExpired();
        uint256 ethReceived = msg.value;
        uint256 thisTimeMaintainFee = getMaintainFee();

        if(thisTimeMaintainFee>ethReceived){
            maintenanceDividends += thisTimeMaintainFee;
            totalDividendPoints += (ethReceived-thisTimeMaintainFee);
            unclaimedDividends += (ethReceived-thisTimeMaintainFee);
            lastMaintenanceTime = now;
        }
        else{
            lastMaintenanceTime += ethReceived/amountSold/MaintenanceFee;
            maintenanceDividends += ethReceived;
        }
        emit eventDivideProfit(msg.sender,ethReceived,thisTimeMaintainFee,now);
    }
      
    uint256 pointMultiplier = 10e18;
    
    function dividends(address addr) private view returns(uint256) {
      uint256 newDividend = (totalDividendPoints-accounts[addr].lastDividendPoints) * accounts[addr].Tokens;
      return newDividend;
    }
    
    function kill() external 
    onlyOwner(){
        selfdestruct(AdminWallet);
    }
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