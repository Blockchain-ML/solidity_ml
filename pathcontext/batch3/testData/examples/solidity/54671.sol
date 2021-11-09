pragma solidity ^0.4.18;

 
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
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
}

 
contract Ownable {

  address public owner;

   
  function Ownable() {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}

 
interface Token {
  function transfer(address _to, uint256 _value) returns (bool);
  function balanceOf(address _owner) constant returns (uint256 balance);
}

contract LiquexPrivateSale is Ownable {

  using SafeMath for uint256;

  Token token;

  uint256 public RATE = 5000;  
  uint256 public constant CAP = 35000;  
  uint256 public constant initialTokens =  175000000 * 10**18;  
  bool public initialized = false; 
  uint256 public raisedAmount = 0;
  
  mapping (address => uint256) buyers;
  
  event BoughtTokens(address indexed to, uint256 value);
  

  modifier whenSaleIsActive() {
     
    assert(isActive());

    _;
  }

   

  function LiquexPrivateSale() {
      
      
      token = Token(0xc78bec96a3cac8cb4bec299adaefb3e556bb3561);  
  }
  
  function initialize() onlyOwner {
      require(initialized == false);  
      require(tokensAvailable() == initialTokens);  
      initialized = true;
  }

  function isActive() public constant returns (bool) {
    return (
        initialized == true &&
       
        goalReached() == false  
    );
  }

  function goalReached() public constant returns (bool) {
    return (raisedAmount >= CAP * 1 ether);
  }

  function () payable {
    buyTokens();
  }

   
  function buyTokens() payable public whenSaleIsActive {
  
    
    if(buyers[msg.sender].add(msg.value) >= 3 ether){
        RATE = 9500;  
    }
    else
         if(buyers[msg.sender].add(msg.value) >= 2 ether){
         RATE = 7500;  
    }
    else
        if(buyers[msg.sender].add(msg.value) >= 1 ether){
        RATE = 6250;  
    }

    
    uint256 weiAmount = msg.value;
    uint256 tokens = weiAmount.mul(RATE);
  
    
    emit BoughtTokens(msg.sender, tokens);
   
     
    raisedAmount = raisedAmount.add(msg.value);
    
     
    token.transfer(msg.sender, tokens);
    
     
    owner.transfer(msg.value);
    
  }
  
 
    
   
  
        
        
       
  function tokensAvailable() public constant returns (uint256) {
    return token.balanceOf(this);
  }

   
  function destroy() public onlyOwner {
     
    uint256 balance = token.balanceOf(this);
    assert(balance > 0);
    token.transfer(owner, balance);

    
  }

}