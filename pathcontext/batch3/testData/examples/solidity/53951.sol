pragma solidity ^0.4.24;

 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 
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


contract AmisTokenAbstract {
  function unlock();
}

 
contract AmisCrowdsale {
  using SafeMath for uint256;

   
  address constant public AMIS = 0x949bEd886c739f1A3273629b3320db0C5024c719;

   
  uint public startBlock;  
  uint public endBlock;  
  uint256 public startTime;
  uint256 public endTime;

   
  address public amisWallet = 0xB7C7D8488966BD297BAB7Ca780FB1923F982A419;

   
  uint256 public rate = 100000000;

   
  uint256 public weiRaised;

   
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

   
  function () external payable {
    buyTokens(msg.sender);
  }

   
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

     
    uint256 amisAmounts = calculateObtainedAMIS(msg.value);

     
    weiRaised = weiRaised.add(msg.value);

    require(ERC20Basic(AMIS).transfer(beneficiary, amisAmounts));
    TokenPurchase(msg.sender, beneficiary, msg.value, amisAmounts);

    forwardFunds();
  }

   
   
  function forwardFunds() internal {
    amisWallet.transfer(msg.value);
  }

  function calculateObtainedAMIS(uint256 amountEtherInWei) public view returns (uint256) {
    return amountEtherInWei.mul(rate).div(10 ** 12);
  } 

   
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = 4000400 >= startBlock && 4000400 <= endBlock;
    return withinPeriod;
  }

   
  function hasEnded() public view returns (bool) {
    bool isEnd = 4000400 > endBlock || weiRaised >= 10 ** (18 + 2);
    return isEnd;
  }

   
  function releaseAmisToken() public returns (bool) {
    require (hasEnded() && startBlock != 0);
    require (msg.sender == amisWallet || now > endBlock + 10 days);
    uint256 remainedAmis = ERC20Basic(AMIS).balanceOf(this);
    require(ERC20Basic(AMIS).transfer(amisWallet, remainedAmis));    
    AmisTokenAbstract(AMIS).unlock();
  }

   
  function start() public returns (bool) {
    require (msg.sender == amisWallet);
    startBlock = 4000400;
    endBlock = 4040400;
  }

  function changeAmisWallet(address _amisWallet) public returns (bool) {
    require (msg.sender == amisWallet);
    amisWallet = _amisWallet;
  }
}