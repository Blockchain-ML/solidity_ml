pragma solidity ^0.4.11;


 
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
     
    uint c = a / b;
     
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}


 
contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
}


 
contract BasicToken is ERC20Basic {
  using SafeMath for uint;

  mapping(address => uint) balances;

   
  modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }

   
  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
  }

   
  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

}


 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint);
  function transferFrom(address from, address to, uint value);
  function approve(address spender, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


 
contract StandardToken is BasicToken, ERC20 {

  mapping (address => mapping (address => uint)) allowed;


   
  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {
    var _allowance = allowed[_from][msg.sender];

     
     

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }

   
  function approve(address _spender, uint _value) {

     
     
     
     
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

   
  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}


 
contract Ownable {
  address public owner;


   
  function Ownable() {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }


   
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


 

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint value);
  event MintFinished();

  bool public mintingFinished = false;
  uint public totalSupply = 0;


  modifier canMint() {
    if(mintingFinished) throw;
    _;
  }

   
  function mint(address _to, uint _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    if (paused) throw;
    _;
  }

   
  modifier whenPaused {
    if (!paused) throw;
    _;
  }

   
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

   
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}


 

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint _value) whenNotPaused {
    super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) whenNotPaused {
    super.transferFrom(_from, _to, _value);
  }
}

 
contract CryptoDailyToken is PausableToken, MintableToken {
  using SafeMath for uint256;

  string public name = "Crypto Daily Token";
  string public symbol = "CRDT";
  uint public decimals = 18;

}

 
contract Crowdsale {
    using SafeMath for uint;
    
    uint private million = 1000000;
    uint private decimals = 18;

     
    CryptoDailyToken private token = new CryptoDailyToken();
    
    address private owner;
    address private constant fundsWallet = 0xD8CAb37A560D8B22104508ac42bd045a5Abcb2E7; 
    address private constant tokenWallet = 0xf8Fab9fa6C154bd2A59035283AD508705aa49641; 
    
    uint private start = now;
    uint private finish = now + 10 minutes;

    uint private tokensPerEth;
    
    uint private tokensReserved = 65 * million * 10 ** uint256(decimals);
    uint private tokensCrowdsaled = 0;
    uint private tokensLeft = 90 * million * 10 ** uint256(decimals);
    uint private tokensTotal = 155 * million * 10 ** uint256(decimals);
    
    event Mint(address indexed to, uint value);
    event SaleFinished(address target, uint amountRaised);
    
     
    constructor(
        uint UnixTimestampOfICOStart, 
        uint UnixTimestampOfICOEnd, 
        uint _tokensPerEth
    ) public {
        owner = msg.sender;
        start = UnixTimestampOfICOStart;
        finish = UnixTimestampOfICOEnd;
        tokensPerEth = _tokensPerEth;
        preMinting();
    }
    

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
     
    modifier saleIsOn() {
    	require(now >= start && now <= finish);
    	_;
    }
    
         
    modifier isUnderHardCap() { 
        require(getTokensReleased() <= tokensTotal);  
        _;
    }
    
     

     
    function getAddressOfTokenUsedAsReward() constant public returns(address){
        return token;
    } 
    
     
    function getTokensCrowdsaled() constant public returns(uint){
        return tokensCrowdsaled;
    }
    
      
    function getTokensLeft() constant public returns(uint){
        return tokensLeft;
    }
    
      
    function getOwner() constant public returns(address){
        return owner;
    }
    
     
    function getStart() constant public returns(uint){
        return start;
    }
    
     
    function getFinish() constant public returns(uint){
        return finish;
    }
    
      
    function getTokensPerEth() constant public returns(uint){
        return tokensPerEth;
    }
    
     

     
    function setStart(uint newStart) onlyOwner public {
        start = newStart; 
    }
    
     
    function setFinish(uint newFinish) onlyOwner public {
        finish = newFinish; 
    }
    
     
    function setTokensPerEth(uint _tokensPerEth) onlyOwner public {
        tokensPerEth = _tokensPerEth; 
    }
    
    
     
     
    function getTokensReleased() constant public returns(uint){
        return tokensReserved + tokensCrowdsaled;
    }
    
     
    function getIfBonus() constant public returns(bool){
        return (getTokensCrowdsaled() < 50 * million * 10 ** uint256(decimals));
    }
    

      
    function setICOIsFinished() onlyOwner public {
        token.mint(tokenWallet, tokensLeft);
         
        token.transferOwnership(owner);
        tokensLeft = 0;
        emit SaleFinished(fundsWallet, getTokensReleased());
    }
    
     
    function preMinting() private  {
        token.mint(tokenWallet, tokensReserved);
    }
    
     
    function() isUnderHardCap saleIsOn public payable {
        
        require(msg.sender != 0x0);
        
         
        require(msg.value >= 3 ether);
        fundsWallet.transfer(msg.value);
        
         
        uint firstFifty = 50 * million * 10 ** uint256(decimals);
        uint amount = msg.value;
        uint tokensToMint = 0;

        tokensToMint = amount.mul(tokensPerEth);
        
         
        if (tokensCrowdsaled.add(tokensToMint) <= firstFifty){
            tokensToMint = tokensToMint.mul(11).div(10); 
        }
        
        token.mint(msg.sender, tokensToMint);
        emit Mint(msg.sender, tokensToMint);
        
        tokensLeft = tokensLeft.sub(tokensToMint);
        tokensCrowdsaled = tokensCrowdsaled.add(tokensToMint);
    }

}