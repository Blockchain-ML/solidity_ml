pragma solidity ^0.4.11;

 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

contract token {
  function balanceOf(address _owner) public constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) public returns (bool success);
}

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
  constructor() public{
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

 
contract Crowdsale100 is Ownable {
  using SafeMath for uint256;

   
  token myToken;

  uint256 public phase_1_remaining_tokens  = 1000000 * (10 ** uint256(18));
  uint256 public phase_2_remaining_tokens  = 5000000 * (10 ** uint256(18));
  uint256 public phase_3_remaining_tokens  = 10500000 * (10 ** uint256(18));

  uint256 public phase_1_remaining_bonus_tokens  = 150000 * (10 ** uint256(18));
  uint256 public phase_2_remaining_bonus_tokens  = 400000 * (10 ** uint256(18));
  uint256 public phase_3_remaining_bonus_tokens  = 315000 * (10 ** uint256(18));
  
  
   
  address public wallet;

   
  uint256 public phase_1_bonus = 15;
  uint256 public phase_2_bonus = 8;
  uint256 public phase_3_bonus = 3;
  
   
  uint256 public rate = 440;  

   
  uint256 public weiRaised;

   
  event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);


  constructor(address tokenContractAddress, address _walletAddress) public{
    wallet = _walletAddress;
    myToken = token(tokenContractAddress);
  }

   
  function () payable public{
    buyTokens(msg.sender);
  }

   
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(msg.value != 0);

    uint256 weiAmount = msg.value;

     
    uint256 tokens = weiAmount.mul(rate);

     
    require(isTokenAvailable(tokens));

    uint256 tokens_to_transfer = calculateAndDecreasePhaseSupply(tokens);

     
    weiRaised = weiRaised.add(weiAmount);

    myToken.transfer(beneficiary, tokens_to_transfer);

    emit TokenPurchase(beneficiary, weiAmount, tokens_to_transfer);

    forwardFunds();
  }

   
  function calculateAndDecreasePhaseSupply(uint256 _tokens) internal returns (uint256){
    uint256 bonus = 0;
    uint256 tokens_from_phase_2 = 0;
    uint256 phase_2_bonus_tokens = 0;
    uint256 phase_3_bonus_tokens = 0;
    if(phase_1_remaining_tokens > 0){
      if(phase_1_remaining_tokens >= _tokens){
        phase_1_remaining_tokens = phase_1_remaining_tokens.sub(_tokens);
        bonus = phase_1_remaining_tokens.mul(phase_1_bonus).div(100);
        phase_1_remaining_bonus_tokens = phase_1_remaining_bonus_tokens.sub(bonus);
        return _tokens.add(bonus);
      }else{
        uint256 tokens_from_phase_1 = phase_1_remaining_tokens;
        tokens_from_phase_2 = _tokens.sub(phase_1_remaining_tokens);
        
        phase_1_remaining_tokens = 0;
        phase_2_remaining_tokens = phase_2_remaining_tokens.sub(tokens_from_phase_2);

        uint256 phase_1_bonus_tokens = tokens_from_phase_1.mul(phase_1_bonus).div(100);
        phase_1_remaining_bonus_tokens = phase_1_remaining_bonus_tokens.sub(phase_1_bonus_tokens);

        phase_2_bonus_tokens = tokens_from_phase_2.mul(phase_2_bonus).div(100);
        phase_2_remaining_bonus_tokens = phase_2_remaining_bonus_tokens.sub(phase_2_bonus_tokens);

        return _tokens.add(phase_1_bonus_tokens).add(phase_2_bonus_tokens);
      }
    }else if(phase_2_remaining_tokens > 0){
      if(phase_2_remaining_tokens >= _tokens){
        phase_2_remaining_tokens = phase_2_remaining_tokens.sub(_tokens);
        bonus = phase_2_remaining_tokens.mul(phase_2_bonus).div(100);
        phase_2_remaining_bonus_tokens = phase_2_remaining_bonus_tokens.sub(bonus);
        return _tokens.add(bonus);
      }else{
        tokens_from_phase_2 = phase_2_remaining_tokens;
        uint256 tokens_from_phase_3 = _tokens.sub(phase_2_remaining_tokens);
        
        phase_2_remaining_tokens = 0;
        phase_3_remaining_tokens = phase_3_remaining_tokens.sub(tokens_from_phase_3);

        phase_2_bonus_tokens = tokens_from_phase_2.mul(phase_2_bonus).div(100);
        phase_2_remaining_bonus_tokens = phase_2_remaining_bonus_tokens.sub(phase_2_bonus_tokens);

        phase_3_bonus_tokens = tokens_from_phase_3.mul(phase_3_bonus).div(100);
        phase_3_remaining_bonus_tokens = phase_3_remaining_bonus_tokens.sub(phase_3_bonus_tokens);

        return _tokens.add(phase_2_bonus_tokens).add(phase_3_bonus_tokens);
      }
    }else if(phase_3_remaining_tokens > 0){
      if(phase_3_remaining_tokens >= _tokens){
        phase_3_remaining_tokens = phase_3_remaining_tokens.sub(_tokens);
        bonus = phase_3_remaining_tokens.mul(phase_3_bonus).div(100);
        phase_3_remaining_bonus_tokens = phase_3_remaining_bonus_tokens.sub(bonus);
        return _tokens.add(bonus);
      }
    }
  }


   
  function isTokenAvailable(uint256 _tokens) internal constant returns (bool){
    uint256 total_remaining_tokens = phase_1_remaining_tokens.add(phase_2_remaining_tokens).add(phase_3_remaining_tokens);
    return total_remaining_tokens >= _tokens;
  }

   
   
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  function transferBackTo(uint256 tokens, address beneficiary) onlyOwner public returns (bool){
    myToken.transfer(beneficiary, tokens);
    return true;
  }

}