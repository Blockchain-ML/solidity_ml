pragma solidity 0.4.25;


 
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

 contract FeedCrowdsale is Ownable{
  using SafeMath for uint256;
 
   
  TokenInterface public token;

   
  uint256 public startTime;
  uint256 public endTime;


   
  uint256 public ratePerWei = 11905;

   
  uint256 public weiRaised;
  
  uint256 public weiRaisedInPreICO;

  uint256 TOKENS_SOLD;

  bool isCrowdsalePaused = false;
  
  uint256 decimals = 18;
  
  uint256 step1Contributions = 0;
  uint256 step2Contributions = 0;
  uint256 step3Contributions = 0;
  uint256 step4Contributions = 0;
  uint256 step5Contributions = 0;
  uint256 step6Contributions = 0;
  uint256 step7Contributions = 0;
  uint256 step8Contributions = 0;
  
  
  
   
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  constructor(address _wallet, address _tokenAddress) public 
  {
    require(_wallet != 0x0);
    owner = _wallet;
    token = TokenInterface(_tokenAddress);
  }
  
  
    
   function () public  payable {
     buyTokens(msg.sender);
    }
    
    function calculateTokens(uint etherAmount) public returns (uint tokenAmount) {
        
        if (etherAmount >= 0.05 ether && etherAmount < 0.09 ether)
        {
             
            require(step1Contributions<1000);
            tokenAmount = uint(1000).mul(uint(10)** decimals);
            step1Contributions = step1Contributions.add(1);
        }
        else if (etherAmount>=0.09 ether && etherAmount < 0.24 ether )
        {
             
            require(step2Contributions<1000);
            tokenAmount = uint(2000).mul(uint(10)** decimals);
            step2Contributions = step2Contributions.add(1);
            
        }
        else if (etherAmount>=0.24 ether && etherAmount<0.46 ether )
        {
             
            require(step3Contributions<1000);
            tokenAmount = uint(6000).mul(uint(10)** decimals);
            step3Contributions = step3Contributions.add(1);
        
        }
        else if (etherAmount>=0.46 ether && etherAmount<0.90 ether)
        {
             
            require(step4Contributions<1000);
            tokenAmount = uint(13000).mul(uint(10)** decimals);
            step4Contributions = step4Contributions.add(1);
        
        }
        else if (etherAmount>=0.90 ether && etherAmount<2.26 ether)
        {
             
            require(step5Contributions<1000);
            tokenAmount = uint(25000).mul(uint(10)** decimals);
            step5Contributions = step5Contributions.add(1);
        
        }
        else if (etherAmount>=2.26 ether && etherAmount<4.49 ether)
        {
             
            require(step6Contributions<1000);
            tokenAmount = uint(60000).mul(uint(10)** decimals);
            step6Contributions = step6Contributions.add(1);
        
        }
        else if (etherAmount>=4.49 ether && etherAmount<8.99 ether)
        {
             
            require(step7Contributions<1000);
            tokenAmount = uint(130000).mul(uint(10)** decimals);
            step7Contributions = step7Contributions.add(1);
        
        }
        else if (etherAmount>=8.99 ether && etherAmount<=10 ether)
        {
             
            require(step8Contributions<1000);
            tokenAmount = uint(200000).mul(uint(10)** decimals);
            step8Contributions = step8Contributions.add(1);
        
        }
        else 
        {
            revert();
        }
    }
   
  
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(isCrowdsalePaused == false);
    require(msg.value>0);
    
    uint256 weiAmount = msg.value;
    
     
    uint256 tokens = calculateTokens(weiAmount);
    
     
    weiRaised = weiRaised.add(weiAmount);
    token.transfer(beneficiary,tokens);
    
    emit TokenPurchase(owner, beneficiary, weiAmount, tokens);
    TOKENS_SOLD = TOKENS_SOLD.add(tokens);
    forwardFunds();
  }

   
  function forwardFunds() internal {
    owner.transfer(msg.value);
  }

 
   
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }
    
     
    function setPriceRate(uint256 newPrice) public onlyOwner {
        ratePerWei = newPrice;
    }
    
      
     
    function pauseCrowdsale() public onlyOwner {
        isCrowdsalePaused = true;
    }

      
    function resumeCrowdsale() public onlyOwner {
        isCrowdsalePaused = false;
    }
    
     function getUnsoldTokensBack() public onlyOwner
     {
        uint contractTokenBalance = token.balanceOf(address(this));
        require(contractTokenBalance>0);
        token.transfer(owner,contractTokenBalance);
     }
}