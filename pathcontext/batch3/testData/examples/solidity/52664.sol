pragma solidity ^0.4.24;

 

 
contract IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);


  function burn(uint256 value) external ;

 
  function burnFrom(address from, uint256 value) external;

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

 

contract SignerRole {
  using Roles for Roles.Role;

  event SignerAdded(address indexed account);
  event SignerRemoved(address indexed account);

  Roles.Role private signers;

  constructor() internal {
    _addSigner(msg.sender);
  }

  modifier onlySigner() {
    require(isSigner(msg.sender));
    _;
  }

  function isSigner(address account) public view returns (bool) {
    return signers.has(account);
  }

  function addSigner(address account) public onlySigner {
    _addSigner(account);
  }

  function renounceSigner() public {
    _removeSigner(msg.sender);
  }

  function _addSigner(address account) internal {
    signers.add(account);
    emit SignerAdded(account);
  }

  function _removeSigner(address account) internal {
    signers.remove(account);
    emit SignerRemoved(account);
  }
}

 

 




 
contract NRTManager is Ownable, SignerRole{
    using SafeMath for uint256;

    uint256 releaseNrtTime;  
    IERC20   tokenContract;   

     
    uint256 MonthlyReleaseNrt;
    uint256 AnnualReleaseNrt;
    uint256 monthCount;

     
    event sendToken(
    string pool,
    address indexed sendAddress,
    uint256 value
    );

     
    event ChangingPoolAddress(
    string pool,
    address indexed newAddress
    );

     
    event NRTDistributed(
        uint256 NRTReleased
    );


    address public newTalentsAndPartnerships;
    address public platformMaintenance;
    address public marketingAndRNR;
    address public kmPards;
    address public contingencyFunds;
    address public researchAndDevelopment;
    address public buzzCafe;
    address public powerToken;

     

    uint256 public newTalentsAndPartnershipsBal;
    uint256 public platformMaintenanceBal;
    uint256 public marketingAndRNRBal;
    uint256 public kmPardsBal;
    uint256 public contingencyFundsBal;
    uint256 public researchAndDevelopmentBal;
    uint256 public powerTokenBal;

     
    uint256 public curatorsBal;
    uint256 public timeTradersBal;
    uint256 public daySwappersBal;
    uint256 public buzzCafeBal;
    uint256 public stakersBal; 
    uint256 public luckPoolBal;     

     
    uint256 public OneYearStakersBal;
    uint256 public TwoYearStakersBal;
    
    uint256 public burnTokenBal; 

    address public eraswapToken;   
    address public stakingContract;

    
    modifier isValidAddress(address addr) {
        require(addr != address(0),"It should be a valid address");
        _;
    }

    
    modifier isNotZero(uint256 value) {
        require(value != 0,"It should be non zero");
        _;
    }

     

    function setNewTalentsAndPartnerships(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        newTalentsAndPartnerships = pool_addr;
        emit ChangingPoolAddress("NewTalentsAndPartnerships",newTalentsAndPartnerships);
    }

      
    function sendNewTalentsAndPartnerships() internal isValidAddress(newTalentsAndPartnerships) 
    returns(bool) {
        uint256 temp = newTalentsAndPartnershipsBal;
        emit sendToken("NewTalentsAndPartnerships",newTalentsAndPartnerships,newTalentsAndPartnershipsBal);
        newTalentsAndPartnershipsBal = 0;
        require(tokenContract.transfer(newTalentsAndPartnerships, temp),"The transfer must not fail");
        return true;
    }

     

    function setPlatformMaintenance(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        platformMaintenance = pool_addr;
        emit ChangingPoolAddress("PlatformMaintenance",platformMaintenance);
    }
    

      
    function sendPlatformMaintenance() internal isValidAddress(platformMaintenance) 
    returns(bool){
        uint256 temp = platformMaintenanceBal;
        emit sendToken("PlatformMaintenance",platformMaintenance,platformMaintenanceBal);
        platformMaintenanceBal = 0;
        require(tokenContract.transfer(platformMaintenance, temp),"The transfer must not fail");
        return true;    
    }

     

    function setMarketingAndRNR(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        marketingAndRNR = pool_addr;
        emit ChangingPoolAddress("MarketingAndRNR",marketingAndRNR);
    }

     
    function sendMarketingAndRNR() internal isValidAddress(marketingAndRNR) 
    returns(bool){
        uint256 temp = marketingAndRNRBal;
        emit sendToken("MarketingAndRNR",marketingAndRNR,marketingAndRNRBal);
        marketingAndRNRBal = 0;
        require(tokenContract.transfer(marketingAndRNR, temp),"The transfer must not fail");
        return true;
    }

     

    function setKmPards(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        kmPards = pool_addr;
        emit ChangingPoolAddress("kmPards",kmPards);
    }

     
    function sendKmPards() internal isValidAddress(kmPards) 
    returns(bool){
        uint256 temp = kmPardsBal;
        emit sendToken("MarketingAndRNR",kmPards,kmPardsBal);
        kmPardsBal = 0;
        require(tokenContract.transfer(kmPards, temp),"The transfer must not fail");
        return true;
    }

     

    function setContingencyFunds(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        contingencyFunds = pool_addr;
        emit ChangingPoolAddress("ContingencyFunds",contingencyFunds);
    }

     
    function sendContingencyFunds() internal  isValidAddress(contingencyFunds) 
    returns(bool){
        uint256 temp = contingencyFundsBal;
        emit sendToken("contingencyFunds",contingencyFunds,contingencyFundsBal);
        contingencyFundsBal = 0;
        require(tokenContract.transfer(contingencyFunds, temp),"The transfer must not fail");
        return true;
    }
     

    function setResearchAndDevelopment(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        researchAndDevelopment = pool_addr;
        emit ChangingPoolAddress("ResearchAndDevelopment",researchAndDevelopment);
    }

     
    function sendResearchAndDevelopment() internal isValidAddress(researchAndDevelopment) 
    returns(bool){
        uint256 temp = researchAndDevelopmentBal;
        emit sendToken("ResearchAndDevelopment",researchAndDevelopment,researchAndDevelopmentBal);
        researchAndDevelopmentBal = 0;
        require(tokenContract.transfer(researchAndDevelopment, temp),"The transfer must not fail");
        return true;
    }

     

    function setBuzzCafe(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        buzzCafe = pool_addr;
        emit ChangingPoolAddress("BuzzCafe",buzzCafe);
    }

     
    function sendBuzzCafe() internal isValidAddress(buzzCafe) 
    returns(bool){
        uint256 temp = buzzCafeBal;
        emit sendToken("BuzzCafe",buzzCafe,buzzCafeBal);
        buzzCafeBal = 0;
        require(tokenContract.transfer(buzzCafe, temp),"The transfer must not fail");
        return true;
    }

     

    function setPowerToken(address pool_addr) public onlyOwner() isValidAddress(pool_addr){
        powerToken = pool_addr;
        emit ChangingPoolAddress("PowerToken",powerToken);
    }

     
    function sendPowerToken() internal  isValidAddress(powerToken) 
    returns(bool){
        uint256 temp = powerTokenBal;
        emit sendToken("PowerToken",powerToken,powerTokenBal);
        powerTokenBal = 0;
        require(tokenContract.transfer(powerToken, temp),"The transfer must not fail");
        return true;
    }

     
    function setStakingContract(address token) external onlyOwner() isValidAddress(token){
        stakingContract = token;
        emit ChangingPoolAddress("stakingContract",stakingContract);
    }

     
    function sendStakingContract() internal  isValidAddress(stakingContract) 
    returns(bool){
        emit sendToken("staking contract",stakingContract,stakersBal);
        require(tokenContract.transfer(stakingContract, stakersBal),"The transfer must not fail");
        return true;
    }

    function resetStaking() external returns(bool) {
        require(msg.sender == stakingContract , "shoul reset staking " );
        stakersBal = 0;
        return true;
    }

     
    function updateLuckpool(uint256 amount) external onlySigner(){
        require(tokenContract.transfer(address(this), amount), "The token transfer should be done");
        luckPoolBal = luckPoolBal.add(amount);
    }

     
    function updateBurnBal(uint256 amount) external onlySigner(){
        require(tokenContract.transfer(address(this), amount), "The token transfer should be done");
        burnTokenBal = burnTokenBal.add(amount);
    }


       

function burnTokens() internal returns (bool){
      tokenContract.burn(burnTokenBal);
      return true;
}

         

    function receiveMonthlyNRT() external onlySigner() returns (bool) {
        require(tokenContract.balanceOf(address(this))>0,"NRT_Manger should have token balance");
        require(now >= releaseNrtTime,"NRT can be distributed only after 30 days");
        uint NRTBal = NRTBal.add(MonthlyReleaseNrt);
        require(NRTBal > 0, "It should be Non-Zero");

        require(distribute_NRT(NRTBal));
        if(monthCount == 11){
            monthCount = 0;
            AnnualReleaseNrt = (AnnualReleaseNrt.mul(9)).div(10);
            MonthlyReleaseNrt = AnnualReleaseNrt.div(12);
        }
        else{
            monthCount = monthCount.add(1);
        }     
        return true;   
    }

     
    function distribute_NRT(uint256 NRTBal) internal isNotZero(NRTBal) returns (bool){
        require(tokenContract.balanceOf(address(this))>=NRTBal,"NRT_Manger doesn&#39;t have token balance");
        NRTBal = NRTBal.add(luckPoolBal);
        
         
        
        newTalentsAndPartnershipsBal = newTalentsAndPartnershipsBal.add((NRTBal.mul(5)).div(100));
        platformMaintenanceBal = platformMaintenanceBal.add((NRTBal.mul(10)).div(100));
        marketingAndRNRBal = marketingAndRNRBal.add((NRTBal.mul(10)).div(100));
        kmPardsBal = kmPardsBal.add((NRTBal.mul(10)).div(100));
        contingencyFundsBal = contingencyFundsBal.add((NRTBal.mul(10)).div(100));
        researchAndDevelopmentBal = researchAndDevelopmentBal.add((NRTBal.mul(5)).div(100));
        curatorsBal = curatorsBal.add((NRTBal.mul(5)).div(100));
        timeTradersBal = timeTradersBal.add((NRTBal.mul(5)).div(100));
        daySwappersBal = daySwappersBal.add((NRTBal.mul(125)).div(1000));
        buzzCafeBal = buzzCafeBal.add((NRTBal.mul(25)).div(1000)); 
        powerTokenBal = powerTokenBal.add((NRTBal.mul(10)).div(100));
        stakersBal = stakersBal.add((NRTBal.mul(15)).div(100));

        

         

        emit NRTDistributed(NRTBal);
        NRTBal = 0;
        luckPoolBal = 0;
        releaseNrtTime = releaseNrtTime.add(30 days + 6 hours);  


         
        require(sendNewTalentsAndPartnerships(),"Tokens should be succesfully send");
        require(sendPlatformMaintenance(),"Tokens should be succesfully send");
        require(sendMarketingAndRNR(),"Tokens should be succesfully send");
        require(sendKmPards(),"Tokens should be succesfully send");
        require(sendContingencyFunds(),"Tokens should be succesfully send");
        require(sendResearchAndDevelopment(),"Tokens should be succesfully send");
        require(sendBuzzCafe(),"Tokens should be succesfully send");
        require(sendPowerToken(),"Tokens should be succesfully send");
        require(sendStakingContract(),"Tokens should be succesfully send");
        return true;

    }


     

    constructor (address token, address[] memory pool) public{
        require(token != address(0),"address should be valid");
        eraswapToken = token;
        tokenContract = IERC20(eraswapToken);
          
        setNewTalentsAndPartnerships(pool[0]);
        setPlatformMaintenance(pool[1]);
        setMarketingAndRNR(pool[2]);
        setKmPards(pool[3]);
        setContingencyFunds(pool[4]);
        setResearchAndDevelopment(pool[5]);
        setBuzzCafe(pool[6]);
        setPowerToken(pool[7]);
        releaseNrtTime = now.add(30 days + 6 hours);
        AnnualReleaseNrt = 81900000000000000;
        MonthlyReleaseNrt = AnnualReleaseNrt.div(uint256(12));
        monthCount = 0;
    }

}

 

 



 

contract Staking {
    using SafeMath for uint256;
    
    address public NRTManagerAddr;
    NRTManager NRTContract;

     
    event stakeCreation(
    uint64 orderid,
    address indexed ownerAddress,
    uint256 value
    );


     
    event loanTaken(
    uint64 orderid
    );

     
    event windupContract(
    uint64 orderid
    );

    IERC20   tokenContract;   
    address public eraswapToken;   

    uint256 public luckPoolBal;     

      
    uint256 public  OneYearStakerCount;
    uint256 public TwoYearStakerCount;
    uint256 public TotalStakerCount;

     
    uint256 public OneYearStakedAmount;
    uint256 public TwoYearStakedAmount;

     
    uint256 public burnTokenBal;
    uint64[] public delList;

     
    uint256 public OneYearStakersBal;
    uint256 public TwoYearStakersBal;

   
    uint64 OrderId=100000;   


    struct Staker {
        bool isTwoYear;          
        bool loan;               
        uint8 loanCount;       
        uint64 index;           
        uint64 orderID;         
        uint256 stakedAmount;    
        uint256 stakedTime;      
        uint256 windUpTime;      
        uint256 loanStartTime;   

    }

    mapping (uint64 => address) public  StakingOwnership;  
    mapping (uint64 => Staker) public StakingDetails;      
    mapping (uint64 => uint256[]) public cumilativeStakedDetails;  
    mapping (uint64 => uint256) public totalNrtMonthCount;  

    uint64[] public OrderList;   
  


    
    modifier isWithinPeriod(uint64 orderID) {
        if (StakingDetails[orderID].isTwoYear) {
        require(now <= StakingDetails[orderID].stakedTime + 730 days,"Contract can only be ended after 2 years");
        }else {
        require(now <= StakingDetails[orderID].stakedTime + 365 days,"Contract can only be ended after 1 years");
        }
        _;
    }

    
   modifier isNoLoanTaken(uint64 orderID) {
        require(StakingDetails[orderID].loan != true,"Loan is present");
        _;
    }

    
   modifier onlyStakeOwner(uint64 orderID) {
        require(StakingOwnership[orderID] == msg.sender,"Staking owner should be valid");
        _;
    }

       
 
   

function deleteList() internal returns (bool){
      for (uint j = delList.length - 1;j > 0;j--)
      {
          deleteRecord(delList[j]);
          delList.length--;
      }
      return true;
}


    

    function createStakingContract(uint256 amount,bool isTwoYear) external returns (uint64) { 
            OrderId = OrderId + 1;
            StakingOwnership[OrderId] = msg.sender;
            uint64 index = uint64(OrderList.push(OrderId) - 1);
            cumilativeStakedDetails[OrderId].push(amount);
            if (isTwoYear) {
            TwoYearStakerCount = TwoYearStakerCount.add(1);
            TwoYearStakedAmount = TwoYearStakedAmount.add(amount);
            StakingDetails[OrderId] = Staker(true,false,0,index,OrderId,amount, now,0,0);
            }else {
            OneYearStakerCount = OneYearStakerCount.add(1);
            OneYearStakedAmount = OneYearStakedAmount.add(amount);
            StakingDetails[OrderId] = Staker(false,false,0,index,OrderId,amount, now,0,0);
            }
            require(tokenContract.transfer(address(this), amount), "The token transfer should be done");
            emit stakeCreation(OrderId,StakingOwnership[OrderId], amount);
            return OrderId;
        }

     

  function isOrderExist(uint64 orderId) public view returns(bool) {
      return OrderList[StakingDetails[orderId].index] == orderId;
 }
 
     
  function takeLoan(uint64 orderId) onlyStakeOwner(orderId) isNoLoanTaken(orderId) isWithinPeriod(orderId) external returns (bool) {
    require(isOrderExist(orderId),"The orderId should exist");
    require((StakingDetails[orderId].stakedTime).sub(now) >= 60 days,"Contract End is near");
    if (StakingDetails[orderId].isTwoYear) {
          require(StakingDetails[orderId].loanCount <= 1,"only one loan per year is allowed");        
          TwoYearStakerCount = TwoYearStakerCount.sub(1);
          TwoYearStakedAmount = TwoYearStakedAmount.sub(StakingDetails[orderId].stakedAmount);
    }else {
          require(StakingDetails[orderId].loanCount == 0,"only one loan per year is allowed");        
          OneYearStakerCount = OneYearStakerCount.sub(1);
          OneYearStakedAmount = OneYearStakedAmount.sub(StakingDetails[orderId].stakedAmount);
    }
          StakingDetails[orderId].loan = true;
          StakingDetails[orderId].loanStartTime = now;
          StakingDetails[orderId].loanCount = StakingDetails[orderId].loanCount + 1;
           
          require(tokenContract.transfer(msg.sender,(StakingDetails[orderId].stakedAmount).div(2)),"The contract should transfer loan amount");
          emit loanTaken(orderId);
          return true;
      }
      
   

  function calculateTotalPayment(uint64 orderId)  public view returns (uint256) {
          require(isOrderExist(orderId),"The orderId should exist");
          return ((StakingDetails[orderId].stakedAmount).div(200)).mul(101);
      
  }
    
  function isEligibleForRepayment(uint64 orderId)  public view returns (bool) {
          require(isOrderExist(orderId),"The orderId should exist");
          require(StakingDetails[orderId].loan == true,"User should have taken loan");
          require((StakingDetails[orderId].loanStartTime).sub(now) < 60 days,"Loan repayment should be done on time");
          return true;
  }
    
  function rePayLoan(uint64 orderId) onlyStakeOwner(orderId) isWithinPeriod(orderId) external returns (bool) {
      require(isEligibleForRepayment(orderId),"The user should be eligible for repayment");
      StakingDetails[orderId].loan = false;
      StakingDetails[orderId].loanStartTime = 0;
      luckPoolBal = luckPoolBal.add((StakingDetails[orderId].stakedAmount).div(200));
      if (StakingDetails[orderId].isTwoYear) {  
          TwoYearStakerCount = TwoYearStakerCount.add(1);
          TwoYearStakedAmount = TwoYearStakedAmount.add(StakingDetails[orderId].stakedAmount);
      }else {  
          OneYearStakerCount = OneYearStakerCount.add(1);
          OneYearStakedAmount = OneYearStakedAmount.add(StakingDetails[orderId].stakedAmount);
      }
           
          require(tokenContract.transfer(address(this),calculateTotalPayment(orderId)),"The contract should receive loan amount with interest");
          return true;
  }



  

  function deleteRecord(uint64 orderId) internal returns (bool) {
      require(isOrderExist(orderId),"The orderId should exist");
      uint64 rowToDelete = StakingDetails[orderId].index;
      uint64 orderToMove = OrderList[OrderList.length-1];
      OrderList[rowToDelete] = orderToMove;
      StakingDetails[orderToMove].index = rowToDelete;
      OrderList.length--; 
      return true;
  }

    

  function sendTokens(uint64 orderId, uint256 amount) internal returns (bool) {
       
      require(tokenContract.transfer(StakingOwnership[orderId], amount),"The contract should send from its balance to the user");
      return true;
  }
  
 

  function windUpContract(uint64 orderId) onlyStakeOwner(orderId)  external returns (bool) {
      require(isOrderExist(orderId),"The orderId should exist");
      require(StakingDetails[orderId].loan == false,"There should be no loan currently");
      require(StakingDetails[orderId].windUpTime == 0,"Windup Shouldn&#39;t be initiated currently");
      StakingDetails[orderId].windUpTime = now + 104 weeks;  
      StakingDetails[orderId].stakedTime = now;  
      if (StakingDetails[orderId].isTwoYear) {      
          TwoYearStakerCount = TwoYearStakerCount.sub(1);
          TwoYearStakedAmount = TwoYearStakedAmount.sub(StakingDetails[orderId].stakedAmount);
    }else {     
          OneYearStakerCount = OneYearStakerCount.sub(1);
          OneYearStakedAmount = OneYearStakedAmount.sub(StakingDetails[orderId].stakedAmount);
    }
      emit windupContract( orderId);
      return true;
  }

function preStakingDistribution() internal returns(bool){
    uint256 temp = NRTContract.stakersBal();
    if(temp == 0)
    {
        return true;
    }
    require(NRTContract.resetStaking(),"It should be successfully reset");
     if(OneYearStakerCount>0)
        {
        OneYearStakersBal = (temp.mul(OneYearStakerCount)).div(TotalStakerCount);
        TwoYearStakersBal = (temp.mul(TwoYearStakerCount)).div(TotalStakerCount);
        luckPoolBal = (OneYearStakersBal.mul(2)).div(15);
        OneYearStakersBal = OneYearStakersBal.sub(luckPoolBal);
        }
        else{
            TwoYearStakersBal = temp;
        }
        return true;
}

     

  function updateStakers() external returns(bool) {
      uint temp;
      uint temp1;
      require(preStakingDistribution(),"pre staking disribution should be done");
      for (uint i = 0;i < OrderList.length; i++) {
          if (StakingDetails[OrderList[i]].windUpTime > 0) {
                 
                if(StakingDetails[OrderList[i]].windUpTime < now){
                temp = ((StakingDetails[OrderList[i]].windUpTime.sub(StakingDetails[OrderList[i]].stakedTime)).div(104 weeks))
                        .mul(StakingDetails[OrderList[i]].stakedAmount);
                delList.push(OrderList[i]);
                }
                else{
                temp = ((now.sub(StakingDetails[OrderList[i]].stakedTime)).div(104 weeks)).mul(StakingDetails[OrderList[i]].stakedAmount);
                StakingDetails[OrderList[i]].stakedTime = now;
                }
                sendTokens(OrderList[i],temp);
          }else if (StakingDetails[OrderList[i]].loan && (StakingDetails[OrderList[i]].loanStartTime > 60 days) ) {
              burnTokenBal = burnTokenBal.add((StakingDetails[OrderList[i]].stakedAmount).div(2));
              delList.push(OrderList[i]);
          }else if(StakingDetails[OrderList[i]].loan){
              continue;
          }
          else if (StakingDetails[OrderList[i]].isTwoYear) {
                 
                totalNrtMonthCount[OrderList[i]] = totalNrtMonthCount[OrderList[i]].add(1);
                temp = (((StakingDetails[OrderList[i]].stakedAmount).div(TwoYearStakedAmount)).mul(TwoYearStakersBal)).div(2);
                if(cumilativeStakedDetails[OrderList[i]].length < 24){
                cumilativeStakedDetails[OrderList[i]].push(temp);
                sendTokens(OrderList[i],temp);
                }
                else{
                    temp1 = temp;
                    temp = temp.add(cumilativeStakedDetails[OrderList[i]][totalNrtMonthCount[OrderList[i]] % 24]); 
                    cumilativeStakedDetails[OrderList[i]][totalNrtMonthCount[OrderList[i]] % 24] = temp1; 
                    sendTokens(OrderList[i],temp);
                }
          }else {
               
              totalNrtMonthCount[OrderList[i]] = totalNrtMonthCount[OrderList[i]].add(1);
              temp = (((StakingDetails[OrderList[i]].stakedAmount).div(OneYearStakedAmount)).mul(OneYearStakersBal)).div(2);
              if(cumilativeStakedDetails[OrderList[i]].length < 12){
              cumilativeStakedDetails[OrderList[i]].push(temp);
              sendTokens(OrderList[i],temp);
              }
              else{
                    temp1 = temp;
                    temp = temp.add(cumilativeStakedDetails[OrderList[i]][totalNrtMonthCount[OrderList[i]] % 12]); 
                    cumilativeStakedDetails[OrderList[i]][totalNrtMonthCount[OrderList[i]] % 12] = temp1; 
                    sendTokens(OrderList[i],temp);
                }
          }
      }
      return true;
  }

      

    constructor (address token,address NRT) public{
        require(token != address(0),"address should be valid");
        eraswapToken = token;
        tokenContract = IERC20(eraswapToken);
        NRTManagerAddr = NRT;
        NRTContract = NRTManager(NRTManagerAddr);
    }

}