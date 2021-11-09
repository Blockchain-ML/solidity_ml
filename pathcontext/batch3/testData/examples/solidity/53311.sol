pragma solidity ^0.4.21;

 
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


   
  constructor() public {
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
 
contract ERC20Basic {
     
  uint256 public totalSupply;
  
  function balanceOf(address _owner) public view returns (uint256 balance);
  
  function transfer(address _to, uint256 _amount) public returns (bool success);
  
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender) public view returns (uint256 remaining);
  
  function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);
  
  function approve(address _spender, uint256 _amount) public returns (bool success);
  
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
contract BasicToken is ERC20Basic, Ownable {
  using SafeMath for uint256;

   
  mapping(address => uint256) balances;
  address[] public allTokenHolders;
  uint percentQuotient;
  uint percentDividend;
  
  uint public totalFeesCollectedAllTime;
  uint public totalFeesDistributedAllTime;
  
  struct totalFeesCollected 
  {
      uint feesCollected;
      uint timestamp;
  }
  struct totalFeesDistributed 
  {
      uint feesDistributed;
      uint timestamp;
  }
  
  totalFeesCollected[] public feesCollection;
  totalFeesDistributed[] public feesDistribution;
  
  totalFeesCollected internal feeTaken;
  totalFeesDistributed internal feeDisbursed;
   
  function transfer(address _to, uint256 _amount) public returns (bool success) {
    require(_to != address(0));
    require(balances[msg.sender] >= _amount && _amount > 0
        && balances[_to].add(_amount) > balances[_to]);

    uint tokensForOwner = _amount.mul(percentQuotient);
    tokensForOwner = tokensForOwner.div(percentDividend);
    
    uint tokensToBeSent = _amount.sub(tokensForOwner);
    redistributeFees(tokensForOwner);
     
    if (balances[_to] == 0)
        allTokenHolders.push(_to);
    balances[_to] = balances[_to].add(tokensToBeSent);
    
    
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    
    
    emit Transfer(msg.sender, _to, _amount);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
  
  function redistributeFees(uint tokensForOwner) internal
  {
      uint thirtyPercent = tokensForOwner.mul(30).div(100);
      uint seventyPercent = tokensForOwner.mul(70).div(100);
     
      uint soldTokens = totalSupply.sub(balances[owner]);
      balances[owner] = balances[owner].add(thirtyPercent);
      if (allTokenHolders.length ==0)
        balances[owner] = balances[owner].add(seventyPercent);
      else 
      {
        for (uint i=0;i<allTokenHolders.length;i++)
        {
          if ( balances[allTokenHolders[i]] > 0)
          {
            uint bal = balances[allTokenHolders[i]];
            uint percentOfTotalSold = bal.mul(100).div(soldTokens);
        
            uint tokensToBeTransferred = percentOfTotalSold.mul(seventyPercent).div(100);
            balances[allTokenHolders[i]] = balances[allTokenHolders[i]].add(tokensToBeTransferred);
          }
        }
      }
      
      totalFeesCollectedAllTime = totalFeesCollectedAllTime.add(tokensForOwner);
      totalFeesDistributedAllTime = totalFeesDistributedAllTime.add(seventyPercent);
      
      feeTaken = totalFeesCollected({feesCollected:tokensForOwner, timestamp: now});
      feesCollection.push(feeTaken);
      
      feeDisbursed = totalFeesDistributed({feesDistributed:seventyPercent, timestamp: now});
      feesDistribution.push(feeDisbursed);
   }
}

 
contract StandardToken is ERC20, BasicToken {
  
  
  mapping (address => mapping (address => uint256)) internal allowed;


   
  function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
    require(_to != address(0));
    require(balances[_from] >= _amount);
    require(allowed[_from][msg.sender] >= _amount);
    require(_amount > 0 && balances[_to].add(_amount) > balances[_to]);

    uint tokensForOwner = _amount.mul(percentQuotient);
    tokensForOwner = tokensForOwner.div(percentDividend);
    
    uint tokensToBeSent = _amount.sub(tokensForOwner);
    redistributeFees(tokensForOwner);
    
    balances[_from] = balances[_from].sub(_amount);
     if (balances[_to] == 0)
        allTokenHolders.push(_to);
    balances[_to] = balances[_to].add(tokensToBeSent);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
    emit Transfer(_from, _to, _amount);
    return true;
  }

   
  function approve(address _spender, uint256 _amount) public returns (bool success) {
    allowed[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

 
contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

     
    function burn(uint256 _value) public onlyOwner{
        require(_value <= balances[msg.sender]);
         
         

        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
    }
}
 
 contract XITOToken is BurnableToken {
     string public name ;
     string public symbol ;
     uint8 public decimals = 18 ;
     
      
     function ()public payable {
         revert();
     }
     
      
     constructor(
            address wallet
         ) public {
         owner = wallet;
         totalSupply = 100000000000;
         totalSupply = totalSupply.mul( 10 ** uint256(decimals));  
         name = "XITO";
         symbol = "USDX";
         balances[wallet] = totalSupply;
         percentQuotient = 3;
         percentDividend = 1000;
         
          
         emit Transfer(address(0), msg.sender, totalSupply);
     }
     
      
    function getTokenDetail() public view returns (string, string, uint256) {
	    return (name, symbol, totalSupply);
    }
    
    function setFee(uint _percentQuotient, uint _percentDividend) public onlyOwner
    {
        percentQuotient = _percentQuotient;
        percentDividend = _percentDividend;
    }
 }