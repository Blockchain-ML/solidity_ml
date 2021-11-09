pragma solidity ^0.4.21;



contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
  public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
  public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}
 
library SafeMath {
     
  function mul(uint256 a, uint256 b) internal pure returns (uint256){
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
   
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

 
contract Ownable {
  address public owner;

   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}

 
 
 
 
 



 
contract HSLICO is Ownable {
  using SafeERC20 for ERC20Basic;

   
  ERC20Basic public token;
    
    
  using SafeMath for uint256;
  
  mapping(address => uint) bal;   
  mapping(uint => address) index;  
  mapping(address => uint) Tokenamount;  
  
  uint256 public number;
  
  
  uint256 public constant RATE = 3000;  
  uint256 public constant CAP = 7;  
  uint256 public constant softtop = 3;  
  uint256 public constant START = 1532943370;  
  uint256 public constant DAYS = 5;  
  uint256 public constant ENDTIME = START+DAYS * 1 days;   
  uint256 public minContribution = 1* 10**18;     
  uint256 public maxContribution = 10 * 10**18;     
  
  
  uint256 public constant initialTokens = 6000 * 10**18;  
  bool public initialized = false;
  uint256 public raisedAmount = 0;
  
   
  event BoughtTokens(address indexed to, uint256 value);

   
  modifier whenSaleIsActive() {
     
    assert(isActive());
    _;
  }
  
  modifier defeated() { 
      if (now >= ENDTIME && raisedAmount <= softtop * 1 ether)
      _; 
      
  }
  
  modifier succeed() { 
   if (now >= ENDTIME && raisedAmount >= softtop * 1 ether)
   _; 
  
  }
   
  constructor(ERC20Basic _token) public {
      token = _token;
  }
  
   
  function initialize() public onlyOwner {
      require(initialized == false);  
      require(tokensAvailable() == initialTokens);  
      initialized = true;
  }

   
  function isActive() public view returns (bool) {
    return (
        initialized == true &&
        now >= START &&  
        now <= ENDTIME &&  
        goalReached() == false  
    );
  }

   
  function goalReached() public view returns (bool) {
    return (raisedAmount >= CAP * 1 ether);
  }

   
  function () public payable {
      
    buyTokens();
  }

   
  function buyTokens() public payable whenSaleIsActive {
    require(msg.value > 0);
    uint256 weiAmount = msg.value;  
    uint256 tokens = msg.value.mul(RATE);
    if (weiAmount <= minContribution || weiAmount >= maxContribution){
         
        msg.sender.transfer(weiAmount);
        
    }
    else{
        if (bal[msg.sender] == 0){
            bal[msg.sender] = msg.value;
            Tokenamount[msg.sender] = tokens;
            number  = number.add(1);
            index[number] = msg.sender;
            
            emit BoughtTokens(msg.sender, tokens);  
            raisedAmount = raisedAmount.add(weiAmount);  
             
             
        }
         else{
             uint b = bal[msg.sender];
             b = b.add(msg.value);
             bal[msg.sender] =b;
             uint c = Tokenamount[msg.sender];
             Tokenamount[msg.sender] = tokens.add(c);
             emit BoughtTokens(msg.sender, tokens);  
             raisedAmount = raisedAmount.add(weiAmount);  
         }
    }
  }

   
  function tokensAvailable() public constant returns (uint256) {
    return token.balanceOf(this);
  }


  function refund() public onlyOwner defeated {
      uint256 balance = token.balanceOf(this);
      assert(balance > 0);
      token.transfer(owner, balance);
      for (uint i;number>=i;i++){
           address add = index[i];
           uint256 a = bal[add];
           add.transfer(a);
        }
  }
 
  function remit() public onlyOwner succeed {
     
     
      owner.transfer(raisedAmount);
      for (uint i;number>=i;i++){
           address add = index[i];
           uint256 a = Tokenamount[add];
           token.transfer(add, a);
            
        }
  }

   
  function destroy() onlyOwner public {
     
    uint256 balance = token.balanceOf(this);
    assert(balance > 0);
    token.transfer(owner, balance);
     
    selfdestruct(owner);
  }
}