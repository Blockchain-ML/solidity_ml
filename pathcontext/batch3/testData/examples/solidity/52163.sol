pragma solidity 0.4.24;

 
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
    require(msg.sender == owner,"Sender not authorized");
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
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
contract DRC_AD is Ownable{
    
   
  ERC20Interface public token;

  uint public TOTAL_AIRDROPPED_TOKENS;
  
   
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  constructor(address _wallet, address _tokenAddress) public 
  {
    require(_wallet != 0x0);
    require (_tokenAddress != 0x0);
    owner = _wallet;
    token = ERC20Interface(_tokenAddress);
    TOTAL_AIRDROPPED_TOKENS = 0;
  }
  
   
  function () public payable {
    revert();
  }

      
    function BulkTransfer(address[] tokenHolders, uint[] amount) public onlyOwner {
        for(uint i = 0; i<tokenHolders.length; i++)
        {
                token.transferFrom(owner,tokenHolders[i],amount[i]);
                TOTAL_AIRDROPPED_TOKENS += amount[i];
        }
    }
}