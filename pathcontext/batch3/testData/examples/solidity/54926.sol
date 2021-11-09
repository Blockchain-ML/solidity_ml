pragma solidity ^0.4.23;


 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
    uint256 c = a / b;
     
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  function Ownable() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

interface TokenInterface {
     function totalSupply() external constant returns (uint);
     function balanceOf(address tokenOwner) external constant returns (uint balance);
     function allowance(address tokenOwner, address spender) external constant returns (uint remaining);
     function transfer(address to, uint tokens) external returns (bool success);
     function approve(address spender, uint tokens) external returns (bool success);
     function transferFrom(address from, address to, uint tokens) external returns (bool success);
     function burn(uint256 _value) external; 
     event Transfer(address indexed from, address indexed to, uint tokens);
     event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
     event Burn(address indexed burner, uint256 value);
}

 contract ScallopCrowdsale is Ownable{
  using SafeMath for uint256;
 
   
  TokenInterface public token;
  
   
  uint Hardcap = 30000000;
  uint Softcap = 5000000;

   
  uint256 public startTime;
  uint256 public endTime;


   
  uint256 public ratePerEth = 2000;

   
  uint256 public weiRaised;
  uint256 maxTokensToSaleInEachPhase;
  uint256 maxTokensToSale;
  
  uint256 public TOKENS_SOLD;
  

  uint256 bonusPercInPrivateSale;
  uint256 bonusPercInPreICO;
  uint256 bonusPercInFinalICO;
  
  
  bool isCrowdsalePaused = false;
  

  mapping(address=>uint)  tokensAgainstAddressPrivateSale;
  address[] usersAddressForPrivateSale;
  
  mapping(address=>uint)  tokensAgainstAddressPreICO;
  address[] usersAddressForPreICO;
  
   
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function ScallopCrowdsale(uint256 _startTime, uint256 _endTime, address _wallet, address _tokenAddress) public 
  {
     
    require(_wallet != 0x0);
    
    weiRaised=0;
    
    startTime = _startTime;  
    endTime = _endTime;
     
    require(endTime >= startTime);
   
    owner = _wallet;

    bonusPercInPrivateSale = 30;
    bonusPercInPreICO= 20;
    bonusPercInFinalICO=0;
    
    
    token = TokenInterface(_tokenAddress);
    maxTokensToSale=(token.totalSupply().mul(60)).div(100);
    
  }
  
  
    
   function () public  payable {
     buyTokens(msg.sender);
    }
    
    function determineBonus(uint tokens) internal view returns (uint256 bonus) 
    {

        uint256 timeElapsed = now - startTime;
        uint256 timeElapsedInDays = timeElapsed.div(1 days);

         
       if (timeElapsedInDays < 13)  
        {
            bonus = tokens.mul(bonusPercInPrivateSale); 
            bonus = bonus.div(100);
            require (TOKENS_SOLD.add(tokens.add(bonus)) <= maxTokensToSale);
        }
         
        else if (timeElapsedInDays >= 13 && timeElapsedInDays < 25)  
        {
            bonus = tokens.mul(bonusPercInPreICO); 
            bonus = bonus.div(100);
            require (TOKENS_SOLD.add(tokens.add(bonus)) <= maxTokensToSale);
        }
        
        else 
        {
            bonus = 0;
        }
    }

   
  
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(isCrowdsalePaused == false);
    require(validPurchase());
    require(msg.value>=1*10**17);
    
    require(TOKENS_SOLD<maxTokensToSale);
   
    uint256 weiAmount = msg.value;
    uint weiAmountForTokens=0;
    uint256 tokens=0;
    uint256 bonus=0;

     
    weiAmountForTokens = weiAmount.div(10**(18-2));
    tokens = weiAmountForTokens.mul(ratePerEth);
    bonus = determineBonus(tokens);
    tokens = tokens.add(bonus);
    require(TOKENS_SOLD.add(tokens)<=maxTokensToSale);
    
     
    weiRaised = weiRaised.add(weiAmount);
    
    token.transfer(beneficiary,tokens);
    emit TokenPurchase(owner, beneficiary, weiAmount, tokens);
    TOKENS_SOLD = TOKENS_SOLD.add(tokens);
    forwardFunds();
   
  
  }

   
  function forwardFunds() internal {
    owner.transfer(msg.value);
  }

   
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

   
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }
  
    
    function changeEndDate(uint256 endTimeUnixTimestamp) public onlyOwner{
        endTime = endTimeUnixTimestamp;
    }
    
     
    
    function changeStartDate(uint256 startTimeUnixTimestamp) public onlyOwner{
        startTime = startTimeUnixTimestamp;
    }
    
     
    function setPriceRate(uint256 newPrice) public onlyOwner {
        ratePerEth = newPrice;
    }
    
   
      
     
    function pauseCrowdsale() public onlyOwner {
        isCrowdsalePaused = true;
    }

      
    function resumeCrowdsale() public onlyOwner {
        isCrowdsalePaused = false;
    }
    
  
     
      
      
      
     function remainingTokensForSale() public constant returns (uint) {
         return maxTokensToSale.sub(TOKENS_SOLD);
     }
    
     
     function burnUnsoldTokens() public onlyOwner 
     {
         require(hasEnded());
         uint value = remainingTokensForSale();
         token.burn(value);
         TOKENS_SOLD = maxTokensToSale;
     }
     
      
     function takeTokensBack() public onlyOwner
     {
         uint remainingTokensInTheContract = token.balanceOf(address(this));
         token.transfer(owner,remainingTokensInTheContract);
     }
     
        
    function manualTransfer(address beneficiary, uint tokens) public onlyOwner {
        token.transfer(beneficiary,tokens);
    }
  
 }