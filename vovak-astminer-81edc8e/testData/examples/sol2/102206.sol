 

pragma solidity ^0.4.11;


 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  function Ownable() {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


   
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 

pragma solidity ^0.4.11;


 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

pragma solidity ^0.4.11;


 
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
     
    uint256 c = a / b;
     
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

 

pragma solidity ^0.4.11;




 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

 

pragma solidity ^0.4.11;



 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity ^0.4.11;




 
contract StandardToken is ERC20, BasicToken, Ownable {

  mapping (address => mapping (address => uint256)) allowed;


   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

     
     

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

   
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

}




 

pragma solidity ^0.4.15;


 
contract OdinalaToken is StandardToken {

    string public constant name = "Odinala Token";
    string public constant symbol = "ODN";
    uint8 public constant decimals = 18;

    function OdinalaToken()
        public
         { }
}


 

pragma solidity ^0.4.11;



 
contract Crowdsale {
  using SafeMath for uint256;

   
  StandardToken public token;

   
  uint256 public startTime;
  uint256 public endTime;

   
  address public wallet;

   
  uint256 public rate;

   
  uint256 public weiRaised;

   
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

   
   
  function createTokenContract() internal returns (StandardToken) {
    return new StandardToken();
  }


   
  function () payable {
    buyTokens(msg.sender);
  }

   
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

     
    uint256 tokens = weiAmount.mul(rate);

     
    weiRaised = weiRaised.add(weiAmount);

    token.approve(this,tokens);
    token.transferFrom(this,beneficiary,tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
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


}

 

pragma solidity ^0.4.11;

 
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;
  bool private circuitBreaker;

  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap;
    circuitBreaker = false;
  }

   
   
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap && !circuitBreaker;
  }

   
   
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached || circuitBreaker;
  }
  
  function triggerCircuitBreaker() internal{
      require(circuitBreaker == false);
      circuitBreaker = true;
  }

}


 

pragma solidity ^0.4.15;

 
contract ExternalTokenCrowdsale is Crowdsale {
    function ExternalTokenCrowdsale(StandardToken _token) public {
        require(_token != address(0));
         
         
        token = _token;
    }

    function createTokenContract() internal returns (StandardToken) {
        return StandardToken(0x0);  
    }
}



contract DevTimeLock is Ownable{
    
    uint256 private _count1 = 0;
    uint256 private _count2 = 0;
    uint256 private _count3 = 0;
    
    uint256 private _releaseTime1;
    uint256 private _releaseTime2;
    uint256 private _releaseTime3;
    
     StandardToken _token;
    address private _wallet;
    
    function DevTimeLock(
        address wallet,
        StandardToken token,
        uint256 releaseTime1,
        uint256 releaseTime2,
        uint256 releaseTime3 ){
            
        _wallet = wallet;
        _token = token;
        _releaseTime1 = releaseTime1;
        _releaseTime2 = releaseTime2;
        _releaseTime3 = releaseTime3;
        
    }
    
     function release1() onlyOwner public  {
         
        require(block.timestamp >= _releaseTime1);
        require(_count1 == 0);
        uint256 amount = 400000000000000000000000;
        _token.approve(this,amount);
        _token.transferFrom(this,_wallet,amount);
        _count1 = 1;
    }
    
     function release2() onlyOwner public  {
         
        require(block.timestamp >= _releaseTime2);
        require(_count2 == 0);
        uint256 amount = 400000000000000000000000;
        _token.approve(this,amount);
        _token.transferFrom(this,_wallet,amount);
        _count2 = 1;
    }
    
    function release3() onlyOwner public  {
         
        require(block.timestamp >= _releaseTime3);
        require(_count3 == 0);
        uint256 amount = 400000000000000000000000;
        _token.approve(this,amount);
        _token.transferFrom(this,_wallet,amount);
        _count3 = 1;
    }
}

contract StakingTimeLock is Ownable{
    
    uint256 private _count1 = 0;

    
    uint256 private _releaseTime1;

    
     StandardToken _token;
    address private _wallet;
    
    function StakingTimeLock(
        address wallet,
        StandardToken token,
        uint256 releaseTime1 ){
            
        _wallet = wallet;
        _token = token;
        _releaseTime1 = releaseTime1;
        
    }
    
     function release1() onlyOwner public  {
         
        require(block.timestamp >= _releaseTime1);
        require(_count1 == 0);
        uint256 amount = 1500000000000000000000000;
        _token.approve(this,amount);
        _token.transferFrom(this,_wallet,amount);
        _count1 = 1;
    }
    
}

contract DexTimeLock is Ownable{
    
    uint256 private _count1 = 0;

    
    uint256 private _releaseTime1;

    
     StandardToken _token;
    address private _wallet;
    
    function DexTimeLock(
        address wallet,
        StandardToken token,
        uint256 releaseTime1 ){
            
        _wallet = wallet;
        _token = token;
        _releaseTime1 = releaseTime1;
        
    }
    
     function release1() onlyOwner public  {
         
        require(block.timestamp >= _releaseTime1);
        require(_count1 == 0);
        uint256 amount = 1000000000000000000000000;
        _token.approve(this,amount);
        _token.transferFrom(this,_wallet,amount);
        _count1 = 1;
    }
    
}

contract UniswapTimeLock is Ownable{
    
    uint256 private _count1 = 0;

    
    uint256 private _releaseTime1;

    
     StandardToken _token;
    address private _wallet;
    
    function UniswapTimeLock(
        address wallet,
        StandardToken token,
        uint256 releaseTime1 ){
            
        _wallet = wallet;
        _token = token;
        _releaseTime1 = releaseTime1;
        
    }
    
     function release1() onlyOwner public  {
         
        require(block.timestamp >= _releaseTime1);
        require(_count1 == 0);
        uint256 amount = 1000000000000000000000000;
        _token.approve(this,amount);
        _token.transferFrom(this,_wallet,amount);
        _count1 = 1;
    }
    
}





 

pragma solidity ^0.4.15;


 
contract PreICOCrowdsale is Ownable, CappedCrowdsale, ExternalTokenCrowdsale {


    
    function PreICOCrowdsale(
        address _wallet,
        StandardToken _token,
        uint256 start,
        uint256 end,
        uint256 rate,
        uint256 cap
    )
        public
        CappedCrowdsale(cap)  
        Crowdsale(
            start, 
            end, 
            rate, 
            _wallet
        )
        ExternalTokenCrowdsale(_token)
    { 
      
    }
    
     function stopSale() onlyOwner public{
       triggerCircuitBreaker();
    }
    
}


 

pragma solidity ^0.4.15;

 
contract MultiStageCrowdsale is Ownable {
    PreICOCrowdsale public _preICOCrowdsale1;
    PreICOCrowdsale public _preICOCrowdsale2;
    PreICOCrowdsale public _preICOCrowdsale3;
    StandardToken public _token;
    DevTimeLock public  _devTimeLock;
    StakingTimeLock public _stakingTimeLock;
    UniswapTimeLock public _uniswapTimeLock;
    DexTimeLock public _dexTimeLock;

    function MultiStageCrowdsale(address wallet) public {

         
        
        _token = createTokenContract();
        
        _stakingTimeLock = new StakingTimeLock(wallet, _token, 1609459200);  
        
        _uniswapTimeLock = new UniswapTimeLock(wallet, _token, 1601769600000);  
        
        _dexTimeLock = new DexTimeLock(wallet, _token, 1612137600);  
        
        _preICOCrowdsale1 = new PreICOCrowdsale(wallet, _token, 1599430994, 1614556800, 4053, 370 ether);
        
        _preICOCrowdsale2 = new PreICOCrowdsale(wallet, _token, 1599430994, 1614556800, 3695, 135 ether);
        
        _preICOCrowdsale3 = new PreICOCrowdsale(wallet, _token, 1599430994, 1614556800, 3359, 140 ether);
        
        _devTimeLock = new DevTimeLock(wallet, _token, 1630454400, 1661990400, 1696118399);
        
        _token.mint(wallet, 800000000000000000000000);
        _token.mint(_preICOCrowdsale1, 1500000000000000000000000);
        _token.mint(_preICOCrowdsale2, 500000000000000000000000);
        _token.mint(_preICOCrowdsale3, 500000000000000000000000);
        _token.mint(_devTimeLock, 1200000000000000000000000);
        _token.mint(_stakingTimeLock, 1500000000000000000000000);
        _token.mint(_uniswapTimeLock, 1000000000000000000000000);
        _token.mint(_dexTimeLock, 1000000000000000000000000);
        
        _token.finishMinting();
    }
    

    function createTokenContract() internal returns (StandardToken) {
        return new OdinalaToken();
    }
    
    function devRelease1() onlyOwner public{
        _devTimeLock.release1();
    }
    
    function devRelease2() onlyOwner public{
        _devTimeLock.release2();
    }
    
    function devRelease3() onlyOwner public{
        _devTimeLock.release3();
    }
    
     function stakingRelease() onlyOwner public{
        _stakingTimeLock.release1();
    }
    
     function uniswapRelease() onlyOwner public{
        _uniswapTimeLock.release1();
    }
    
    function dexRelease() onlyOwner public{
        _dexTimeLock.release1();
    }
    
    function stopPreSale1() onlyOwner public{
       _preICOCrowdsale1.stopSale();
    }
    
    function stopPreSale2() onlyOwner public{
       _preICOCrowdsale2.stopSale();
    }
    
    function stopPreSale3() onlyOwner public{
       _preICOCrowdsale3.stopSale();
    }
}