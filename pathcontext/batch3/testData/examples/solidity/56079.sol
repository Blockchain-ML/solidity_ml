pragma solidity ^0.4.24;
contract UserInterface {
    function getTokens(address) external view returns(uint256);
    function buyTokens_ETH(address,uint256 ,uint256,bytes8) external returns(uint256);
    function buyTokens_Vault(address,uint256,bytes8) external returns(uint256);
    function buyTokens_Address(address,uint256,bytes8) external returns(bool);
    function withdraw(address) external returns(uint256);
    uint256 public amountSold;
    function addTotalDividendPoints(uint256) external;
}
contract ValidationInterface {
  function getValidated(address _address,uint256 _code) external pure returns (bool);
}
 
contract FiatContract {
  function ETH(uint _id) public view returns (uint256);
  function USD(uint _id) public view returns (uint256);
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

contract ActuralMiner is Ownable{
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     

     
     
     
     
     
     
     
    using SafeMath for uint256;

    event eventByAddress(address,bytes8,uint256,uint256);
    event eventByETH(bytes8,uint256,uint256);
    event eventByVault(bytes8,uint256,uint256);
    event eventWithdraw(uint256,uint256);
    event eventDivideProfit(address,uint256,uint256,uint256);

    address private AdminWallet;
    address private Manager;
    FiatContract public price;
    ValidationInterface public validate;
    UserInterface public user;
     
    address private ValidationInterfaceAddress;
    address private UserInterfaceAddress;
    address private PriceAddress;
    
     
    uint256 public TotalHashRate;
     
    uint256 public Price;
     
    uint256 public ETHUSD;
     
    uint256 public lastUpdateETHUSD;
     
    uint256 public IntervalETHUSD;
     
    uint256 public CouponRatio;
     
    uint256 public MaintenanceFee;
     
    uint256 public maintenanceDividends;
     
    uint256 public lastMaintenanceTime;
    
    
    constructor() public{
        
        AdminWallet = msg.sender;
        Manager = 0x272a43805714624F4c8179f5aFf7b711C0F073c5;
        
        ValidationInterfaceAddress = 0xD46b8Da4DB8AA6BcBd8d168BbA9681425001F1F9;
        UserInterfaceAddress = 0x184e689aFc989946D27b2B6b81Ccd9f793605DdE;
        PriceAddress = 0x2CDe56E5c8235D6360CCbb0c57Ce248Ca9C80909;
         
        
        validate = ValidationInterface(ValidationInterfaceAddress);
        price = FiatContract(PriceAddress);
        user = UserInterface(UserInterfaceAddress);
        
         
        TotalHashRate = 30000000;
         
        Price = 24000;
         
        CouponRatio = 9000;
         
        lastUpdateETHUSD = 0;
         
        IntervalETHUSD = 60;
         
         
        MaintenanceFee = 100*uint256(1e18)/320/1000/259200;
         
        lastMaintenanceTime = now;

        getETHUSD();

    }
    

    modifier onlyManager(){
        require(msg.sender == Manager, "its only for manager of ActuralMiner");
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

    function setUserList(address _userAddr) external
    onlyOwner()
    {
        UserInterfaceAddress = _userAddr;
        user = UserInterface(UserInterfaceAddress);
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
        require(_newCouponRatio > 0 && _newCouponRatio <= 10000);
        CouponRatio = _newCouponRatio;
    }
    
    function setSupply(uint256 _newSupply) external
    onlyOwner()
    {
        require(_newSupply > 0);
        TotalHashRate = _newSupply;
    }
     

     
     
     
    function getMaintainFee() public view returns(uint256){
        return (now.sub(lastMaintenanceTime)).mul(MaintenanceFee).mul(user.amountSold()).mul(1e18).div(ETHUSD);
    }
    
    function getETHUSD() private{
        if((now-lastUpdateETHUSD)>IntervalETHUSD){
            ETHUSD = uint256(10e33).div(price.USD(0));
            lastUpdateETHUSD = now;
        }
    }
    
     
    function buy_ETH(uint256 validationCode,bytes8 affCode) payable public
    {
        getETHUSD();
        uint256 token = user.buyTokens_ETH(msg.sender,msg.value,validationCode,affCode);
        maintenanceDividends = maintenanceDividends.add(msg.value);
        emit eventByETH(affCode,token,now);
    }
     
    function buy_Vault(uint256 vaultAmount,bytes8 affCode) public
    {
        getETHUSD();
        uint256 token = user.buyTokens_Vault(msg.sender,vaultAmount,affCode);
        maintenanceDividends = maintenanceDividends.add(vaultAmount);
        emit eventByVault(affCode,token,now);
         
    }
    
     
     
    function buyAddress(address addr,bytes8 affCode,uint256 token) public
    onlyManager()
     
    {
        getETHUSD();
        user.buyTokens_Address(addr,token,affCode);
        emit eventByAddress(addr,affCode,token,now);
         
    }
    
    function withdraw() public
    {   
        address Addr = msg.sender;
        uint256 BalanceWithdraw = user.withdraw(Addr);
        Addr.transfer(BalanceWithdraw);
        emit eventWithdraw(BalanceWithdraw,now);
    }
    
     
     
    function () payable public{
        uint256 ethReceived = msg.value;
        uint256 thisTimeMaintainFee = getMaintainFee();
        if(thisTimeMaintainFee<ethReceived){
            maintenanceDividends += thisTimeMaintainFee;
            user.addTotalDividendPoints(ethReceived.sub(thisTimeMaintainFee).div(user.amountSold()));
            lastMaintenanceTime = now;
        }
         
        else{
            lastMaintenanceTime += ethReceived.mul(ETHUSD).div(user.amountSold()).div(MaintenanceFee);
            maintenanceDividends += ethReceived;
        }
        emit eventDivideProfit(msg.sender,ethReceived,thisTimeMaintainFee,now);
    }
    
    function withdrawAdmin() public
    onlyOwner()
    {   
        owner.transfer(maintenanceDividends);
        maintenanceDividends = 0;
    }
    
    function kill() external 
    onlyOwner(){
        if(user.amountSold() < 1000)
            selfdestruct(AdminWallet);
    }
}