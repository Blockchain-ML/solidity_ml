pragma solidity ^0.4.24;

 
 
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

 function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0);  
    uint256 c = a / b;
    assert(a == b * c + a % b);  
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


   
  constructor () public {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


   
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

 
contract ERC20Interface {
     function totalSupply() public constant returns (uint);
     function balanceOf(address tokenOwner) public constant returns (uint balance);
     function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
     function transfer(address to, uint tokens) public returns (bool success);
     function approve(address spender, uint tokens) public returns (bool success);
     function transferFrom(address from, address to, uint tokens) public returns (bool success);
     event Transfer(address indexed from, address indexed to, uint tokens);
     event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract CloudexchangeToken is ERC20Interface,Ownable {

    using SafeMath for uint256;
   
    mapping(address => uint256) tokenBalances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    string public constant name = "CLOUDEXCHANGE";
    string public constant symbol = "CXT";
    uint256 public constant decimals = 18;

   uint256 public constant INITIAL_SUPPLY = 1000000000;

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(tokenBalances[msg.sender]>=_value);
    tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(_value);
    tokenBalances[_to] = tokenBalances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return tokenBalances[_owner];
  }
  
  
      
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= tokenBalances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    tokenBalances[_from] = tokenBalances[_from].sub(_value);
    tokenBalances[_to] = tokenBalances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }
  
      
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

      
      
      
     function totalSupply() public constant returns (uint) {
         return totalSupply - tokenBalances[address(0)];
     }
     
    
     
      
      
      
      
     function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
         return allowed[tokenOwner][spender];
     }
     
      
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

     
      
      
      
     function () public payable {
         revert();
     }   


  
   event Debug(string message, address addr, uint256 number);
    
    function CloudexchangeToken(address wallet) public {
        owner = msg.sender;
        totalSupply = INITIAL_SUPPLY * 10 ** 18;
        tokenBalances[wallet] = totalSupply;    
    }

    function mint(address wallet, address buyer, uint256 tokenAmount) public onlyOwner {
      require(tokenBalances[wallet] >= tokenAmount);                
      tokenBalances[buyer] = tokenBalances[buyer].add(tokenAmount);                   
      tokenBalances[wallet] = tokenBalances[wallet].sub(tokenAmount);                         
      emit Transfer(wallet, buyer, tokenAmount); 
      totalSupply = totalSupply.sub(tokenAmount); 
    }
    
   
}
contract CloudexchangeCrowdsale {
  using SafeMath for uint256;
 
   
  CloudexchangeToken public token;

   
  uint public startTime;
  uint public endTime;

   
   
  address public wallet;

   
  uint256 public ratePerWei = 2000;

   
  uint256 public weiRaised;

   
  bool public isSoftCapReached = false;
  bool public isHardCapReached = false;
    
   
  bool public refundToBuyers = false;
    
   
  uint256 public softCap = 1;
    
   
  uint256 public hardCap = 2;
  
   
  uint256 public tokens_sold = 0;

   
  uint maxTokensForSale = 200000000;
  
   
  uint256 public tokensForReservedFund = 0;
  uint256 public tokensForAdvisors = 0;
  uint256 public tokensForFoundersAndTeam = 0;
  uint256 public tokensForMarketing = 0;
  uint256 public tokensForTournament = 0;

  bool ethersSentForRefund = false;

   
  mapping(address=>uint256) usersThatBoughtCXT;
 
   
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event ICOStarted(uint256 startTime, uint256 endTime);
  function CloudexchangeCrowdsale(uint256 _startTime, address _wallet) public {

    startTime = _startTime;
    endTime = startTime.add(7 days);

    require(endTime >= startTime);
    require(_wallet != 0x0);

    wallet = _wallet;
    token = createTokenContract(wallet);
    
    emit ICOStarted(startTime,endTime);

  }

  function createTokenContract(address wall) internal returns (CloudexchangeToken) {
    return new CloudexchangeToken(wall);
  }

   
  function () public payable {
    buyTokens(msg.sender);
  }

   
  function determineBonus(uint tokens) internal view returns (uint256 bonus) {
    
    uint256 timeElapsed = now - startTime;
    uint256 timeElapsedInDays = timeElapsed.div(1 days);
     
    if (timeElapsedInDays <=1)
    {
         
         
         
        bonus = tokens.mul(25);
        bonus = bonus.div(100);
       
    }
    else if (timeElapsedInDays>1 && timeElapsedInDays <=2)
    {
         
         
       
         
        bonus = tokens.mul(20);
        bonus = bonus.div(100);
        
       
    }
    else if (timeElapsedInDays>2 && timeElapsedInDays <=3)
    {
         
         
       
         
        bonus = tokens.mul(0);
        bonus = bonus.div(100);
        
       
    }
    else
    {
         
        bonus = 0;
    }
   
  }

   
   
  
  function buyTokens(address beneficiary) public payable {
    
   
  require(beneficiary != 0x0);

  if(hasEnded() && !isHardCapReached)
  {
      if (!isSoftCapReached)
        refundToBuyers = true;
      burnRemainingTokens();
      beneficiary.transfer(msg.value);
  }
  
  else
  {
     
    require(validPurchase());
    
     
    uint256 weiAmount = msg.value;
    
     
    uint256 tokens = weiAmount.mul(ratePerWei);
  
    require (tokens>=50 * 10 ** 18);
    
     
    uint bonus = determineBonus(tokens);
    tokens = tokens.add(bonus);
  
     
    require(tokens_sold + tokens <= maxTokensForSale * 10 ** 18);
  
     
    updateTokensForCloudexchangeTeam(tokens);

    weiRaised = weiRaised.add(weiAmount);
    
    
    if (weiRaised >= softCap * 10 ** 18 && !isSoftCapReached)
    {
      isSoftCapReached = true;
    }
  
    if (weiRaised >= hardCap * 10 ** 18 && !isHardCapReached)
      isHardCapReached = true;
    
    token.mint(wallet, beneficiary, tokens);
    
    uint olderAmount = usersThatBoughtCXT[beneficiary];
    usersThatBoughtCXT[beneficiary] = weiAmount + olderAmount;
    
    emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    
    tokens_sold = tokens_sold.add(tokens);
    forwardFunds();
  }
 }

   
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

   
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

   
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }
    
    function burnRemainingTokens() internal
    {
         
        uint balance = token.balanceOf(wallet);
        require(balance>0);
        uint tokensForTeam = tokensForReservedFund + tokensForFoundersAndTeam + tokensForAdvisors +tokensForMarketing + tokensForTournament;
        uint tokensToBurn = balance.sub(tokensForTeam);
        require (balance >=tokensToBurn);
        address burnAddress = 0x0;
        token.mint(wallet,burnAddress,tokensToBurn);
    }
    
    function getRefund() public 
    {
        require(ethersSentForRefund && usersThatBoughtCXT[msg.sender]>0);
        uint256 ethersSent = usersThatBoughtCXT[msg.sender];
        require (wallet.balance >= ethersSent);
        msg.sender.transfer(ethersSent);
        uint256 tokensIHave = token.balanceOf(msg.sender);
        token.mint(msg.sender,0x0,tokensIHave);
    }
    
    function debitAmountToRefund() public payable 
    {
        require(hasEnded() && msg.sender == wallet && !isSoftCapReached && !ethersSentForRefund);
        require(msg.value >=weiRaised);
        ethersSentForRefund = true;
    }
    
    function updateTokensForCloudexchangeTeam(uint256 tokens) internal 
    {
        uint256 reservedFundTokens;
        uint256 foundersAndTeamTokens;
        uint256 advisorsTokens;
        uint256 marketingTokens;
        uint256 tournamentTokens;
        
         
        reservedFundTokens = tokens.mul(40);
        reservedFundTokens = reservedFundTokens.div(100);
        tokensForReservedFund = tokensForReservedFund.add(reservedFundTokens);
    
         
        foundersAndTeamTokens=tokens.mul(35);
        foundersAndTeamTokens= foundersAndTeamTokens.div(100);
        tokensForFoundersAndTeam = tokensForFoundersAndTeam.add(foundersAndTeamTokens);
    
         
        advisorsTokens=tokens.mul(3);
        advisorsTokens= advisorsTokens.div(100);
        tokensForAdvisors= tokensForAdvisors.add(advisorsTokens);
    
         
        marketingTokens = tokens.mul(1);
        marketingTokens= marketingTokens.div(100);
        tokensForMarketing= tokensForMarketing.add(marketingTokens);
        
         
        tournamentTokens=tokens.mul(1);
        tournamentTokens= tournamentTokens.div(100);
        tokensForTournament= tokensForTournament.add(tournamentTokens);
    }
    
    function withdrawTokensForCloudexchangeTeam(uint256 whoseTokensToWithdraw,address[] whereToSendTokens) public {
         
        require(msg.sender == wallet && now>=endTime);
        uint256 lockPeriod = 0;
        uint256 timePassed = now - endTime;
        uint256 tokensToSend = 0;
        uint256 i = 0;
        if (whoseTokensToWithdraw == 1)
        {
           
          lockPeriod = 1 days * 1;
          require(timePassed >= lockPeriod);
          require (tokensForReservedFund >0);
           
          tokensToSend = tokensForReservedFund.div(whereToSendTokens.length);
                
          for (i=0;i<whereToSendTokens.length;i++)
          {
            token.mint(wallet,whereToSendTokens[i],tokensToSend);
          }
          tokensForReservedFund = 0;
        }
        else if (whoseTokensToWithdraw == 2)
        {
           
          lockPeriod = 2 days * 1;
          require(timePassed >= lockPeriod);
          require(tokensForFoundersAndTeam > 0);
           
          tokensToSend = tokensForFoundersAndTeam.div(whereToSendTokens.length);
                
          for (i=0;i<whereToSendTokens.length;i++)
          {
            token.mint(wallet,whereToSendTokens[i],tokensToSend);
          }            
          tokensForFoundersAndTeam = 0;
        }
        else if (whoseTokensToWithdraw == 3)
        {
            require (tokensForAdvisors > 0);
           
          tokensToSend = tokensForAdvisors.div(whereToSendTokens.length);        
          for (i=0;i<whereToSendTokens.length;i++)
          {
            token.mint(wallet,whereToSendTokens[i],tokensToSend);
          }
          tokensForAdvisors = 0;
        }
        else if (whoseTokensToWithdraw == 4)
        {
            require (tokensForMarketing > 0);
           
          tokensToSend = tokensForMarketing.div(whereToSendTokens.length);
                
          for (i=0;i<whereToSendTokens.length;i++)
          {
            token.mint(wallet,whereToSendTokens[i],tokensToSend);
          }
          tokensForMarketing = 0;
        }
        else if (whoseTokensToWithdraw == 5)
        {
            require (tokensForTournament > 0);
           
          tokensToSend = tokensForTournament.div(whereToSendTokens.length);
                
          for (i=0;i<whereToSendTokens.length;i++)
          {
            token.mint(wallet,whereToSendTokens[i],tokensToSend);
          }
          tokensForTournament = 0;
        }
        else 
        {
           
          require (1!=1);
        }
    }
}