pragma solidity ^0.4.18;

 

 
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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

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

 

 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

 

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

 

 

contract MintableToken is StandardToken, Ownable {
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
    Transfer(address(0), _to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

 

contract SilcToken is MintableToken {
  string public name = "SILC Token Test 9";
  string public symbol = "SILCT9";
  uint8 public decimals = 18;
}

 

 
contract Crowdsale {
  using SafeMath for uint256;

   
  MintableToken public token;

   
  uint256 public startTime;
  uint256 public endTime;

   
  address public wallet;

   
  uint256 public rate;

   
  uint256 public weiRaised;

   
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
     
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

   
   
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


   
  function () external payable {
    buyTokens(msg.sender);
  }

   
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

     
    uint256 tokens = weiAmount.mul(rate);

     
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

   
   
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

   
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

   
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }


}

 

 
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

   
   
  function validPurchase() internal view returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

   
   
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

 

 
contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

   
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }

   
  function finalization() internal {
  }
}

 

contract RecordingRefundVault is Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) public deposited;

  struct DepositRecord {
    uint256 value;
    uint stage;
    bool isDeposited;
  }

  mapping(address => DepositRecord) public depositRecords;
  address[] public depositList;

  function isDeposited(address entityAddress) public constant returns(bool isIndeed) {
      return depositRecords[entityAddress].isDeposited;
  }

  function getDepositedCount() public constant returns(uint entityCount) {
    return depositList.length;
  }

  function newDeposit(address entityAddress, uint256 _value, uint _stage) public returns(uint rowNumber) {
    if(isDeposited(entityAddress)) revert();
    depositRecords[entityAddress].value = _value;
    depositRecords[entityAddress].stage = _stage;
    depositRecords[entityAddress].isDeposited = true;
    return depositList.push(entityAddress) - 1;
  }

  function updateDeposit(address entityAddress, uint256 _value, uint _stage) public returns(bool success) {
    if(!isDeposited(entityAddress)) revert();
    depositRecords[entityAddress].value = _value;
    depositRecords[entityAddress].stage = _stage;
    return true;
  }

  function getDepositedValue(address entityAddress) public constant returns(uint256 depositedValue) {
    if(!isDeposited(entityAddress)) revert();
    return depositRecords[entityAddress].value;
  }

  function getDeposit(address entityAddress) public constant returns(uint256 depositedValue, uint stage) {
    if(!isDeposited(entityAddress)) revert();
    return (depositRecords[entityAddress].value, depositRecords[entityAddress].stage);
  }

  enum State { Active, Refunding, Closed }

  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function RecordingRefundVault(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor, uint stage) onlyOwner public payable {
    require(state != State.Closed);
    newDeposit(investor, msg.value, stage);
     
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = getDepositedValue(investor);
    updateDeposit(investor, 0, 0);
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}

contract RecordableRefundableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;

   
  uint256 public goal;

   
  RecordingRefundVault public vault;

  function RecordableRefundableCrowdsale(uint256 _goal) public {
    require(_goal > 0);
    vault = new RecordingRefundVault(wallet);
    goal = _goal;
  }

   
   
   
  function forwardFunds(uint stage) internal {
    vault.deposit.value(msg.value)(msg.sender, stage);
  }

   
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());

    vault.refund(msg.sender);
  }

   
  function finalization() internal {
    if (goalReached()) {
      vault.close();
    } else {
      vault.enableRefunds();
    }

    super.finalization();
  }

  function goalReached() public view returns (bool) {
    return weiRaised >= goal;
  }

}

contract SilcCrowdsale is CappedCrowdsale, RecordableRefundableCrowdsale {

   
   
  enum CrowdsaleStage { preSale, mainSale1, mainSale2 }
  CrowdsaleStage public stage = CrowdsaleStage.preSale;  
   

   
   
  uint256 public maxTokens = 20000000000000000000000000;           
  uint256 public tokensForEcosystem = 3500000000000000000000000;   
  uint256 public tokensForTeam = 2500000000000000000000000;        
  uint256 public tokensForAdvisory = 1000000000000000000000000;    

  uint256 public totalTokensForSale = 3000000000000000000000000;   
  uint256 public totalTokensForSaleDuringpreSale = 1000000000000000000000000;  
   

   
  uint256 public rateForpreSale = 110000;
  uint256 public rateFormainSale1 = 105000;
  uint256 public rateFormainSale2 = 100000;

   
   
  uint256 public totalWeiRaisedDuringpreSale;
   

  uint256 public totalTokenSupply;

   
  event EthTransferred(string text);
  event EthRefunded(string text);


   
   
  function SilcCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _goal, uint256 _cap) CappedCrowdsale(_cap) FinalizableCrowdsale() RecordableRefundableCrowdsale(_goal) Crowdsale(_startTime, _endTime, _rate, _wallet) public {
      require(_goal <= _cap);
  }
   

   
   
  function createTokenContract() internal returns (MintableToken) {
    return new SilcToken();  
  }
   

   
   

   
  function setCrowdsaleStage(uint value) public onlyOwner {

      CrowdsaleStage _stage;

      if (uint(CrowdsaleStage.preSale) == value) {
        _stage = CrowdsaleStage.preSale;
      } else if (uint(CrowdsaleStage.mainSale1) == value) {
        _stage = CrowdsaleStage.mainSale1;
      } else if (uint(CrowdsaleStage.mainSale2) == value) {
        _stage = CrowdsaleStage.mainSale2;
      }


      stage = _stage;

      if (stage == CrowdsaleStage.preSale) {
        setCurrentRate(rateForpreSale);
      } else if (stage == CrowdsaleStage.mainSale1) {
        setCurrentRate(rateFormainSale1);
      } else if (stage == CrowdsaleStage.mainSale2) {
        setCurrentRate(rateFormainSale2);
      }
  }

   
  function setCurrentRate(uint256 _rate) private {
      rate = _rate;
  }

   

   
   
  function () external payable {
      uint256 tokensThatWillBeMintedAfterPurchase = msg.value.mul(rate);
      if ((stage == CrowdsaleStage.preSale) && (token.totalSupply() + tokensThatWillBeMintedAfterPurchase > totalTokensForSaleDuringpreSale)) {
        msg.sender.transfer(msg.value);  
        EthRefunded("preSale Limit Hit");
        return;
      }

      buyTokens(msg.sender);
      totalTokenSupply = token.totalSupply();

      if (stage == CrowdsaleStage.preSale) {
          totalWeiRaisedDuringpreSale = totalWeiRaisedDuringpreSale.add(msg.value);
      }
  }

  function forwardFunds() internal {
      if (stage == CrowdsaleStage.preSale) {
           
           
          EthTransferred("forwarding funds to refundable vault");
          super.forwardFunds(0);
      } else if (stage == CrowdsaleStage.mainSale1) {
          EthTransferred("forwarding funds to refundable vault");
          super.forwardFunds(1);
      } else if (stage == CrowdsaleStage.mainSale2) {
          EthTransferred("forwarding funds to refundable vault");
          super.forwardFunds(2);
      }
  }
   

   
   

  function finish(address _teamFund, address _ecosystemFund, address _advisoryFund) public onlyOwner {

      require(!isFinalized);
      uint256 alreadyMinted = token.totalSupply();
      require(alreadyMinted < maxTokens);

      uint256 unsoldTokens = totalTokensForSale - alreadyMinted;
      if (unsoldTokens > 0) {
        tokensForEcosystem = tokensForEcosystem + unsoldTokens;
      }

      token.mint(_teamFund,tokensForTeam);
      token.mint(_ecosystemFund,tokensForEcosystem);
      token.mint(_advisoryFund,tokensForAdvisory);
      finalize();
  }
   

   
   
  function hasEnded() public view returns (bool) {
    return true;
  }
}