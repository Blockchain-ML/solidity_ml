pragma solidity ^0.4.24;

 

 
contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value)
    public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

 

 
library SafeMath {

   
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
     
     
     
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

   
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0);  
    uint256 c = _a / _b;
     

    return c;
  }

   
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

   
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

   
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

 

 
contract StandardToken is ERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private balances;

  mapping (address => mapping (address => uint256)) private allowed;

  uint256 private totalSupply_;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

   
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function _mint(address _account, uint256 _amount) internal {
    require(_account != 0);
    totalSupply_ = totalSupply_.add(_amount);
    balances[_account] = balances[_account].add(_amount);
    emit Transfer(address(0), _account, _amount);
  }

   
  function _burn(address _account, uint256 _amount) internal {
    require(_account != 0);
    require(_amount <= balances[_account]);

    totalSupply_ = totalSupply_.sub(_amount);
    balances[_account] = balances[_account].sub(_amount);
    emit Transfer(_account, address(0), _amount);
  }

   
  function _burnFrom(address _account, uint256 _amount) internal {
    require(_amount <= allowed[_account][msg.sender]);

     
     
    allowed[_account][msg.sender] = allowed[_account][msg.sender].sub(_amount);
    _burn(_account, _amount);
  }
}

 

 
library SafeERC20 {
  function safeTransfer(
    ERC20 _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

 

 
contract BurnableToken is StandardToken {

  event Burn(address indexed burner, uint256 value);

   
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

   
  function burnFrom(address _from, uint256 _value) public {
    _burnFrom(_from, _value);
  }

   
  function _burn(address _who, uint256 _value) internal {
    super._burn(_who, _value);
    emit Burn(_who, _value);
  }
}

 

 
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

   
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

   
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

 

contract Token is ERC20, BurnableToken {}

contract ClarityCrowdsale is Ownable {

  using SafeMath for uint256;
  using SafeERC20 for Token;

  uint256 constant DECIMALS = 10 ** uint256(18);

  Token token;

  mapping (address => uint8) public whitelist;

  mapping (address => uint256) public contributions;

  mapping (address => uint256) public InvestorVault;
  uint256 public InvestorTokens;

  mapping (address => uint256) public USInvestorVault;
  uint256 public USInvestorTokens;

  mapping (address => bool) public admins;

  mapping (address => bool) public USInvestors;

  mapping (address => address) public referrers;

  mapping (address => bool) public hasPromoCode;

  address public founderAddress = address(0);
  uint256 public founderFunds = 0;

  address public advisorAddress = address(0);
  uint256 public advisorFunds = 0;

  uint256 public totalContributed = 0;

  uint256 public softcap = 8333 ether;

  uint256 public startTime;
  uint256 public endTime;

  bool public initialized = false;
  bool public finalized = false;

  struct Tier {
    uint256 amount;
    uint16 rate;
  }

  Tier[] public tiers;

  event AdminAdded(address indexed addr, address owner);
  event AdminRemoved(address indexed addr, address owner);
  event AddressWhitelisted(address indexed addr, address admin);
  event ContributionLevelSet(address indexed addr, uint8 lvl, address admin);
  event AdvisorSet(address indexed addr, address owner);
  event FounderSet(address indexed addr, address owner);
  event FlaggedUSInvestor(address indexed addr, address admin);
  event FounderFundsWithdrawn(address founder, uint256 amount);
  event AdvisorFundsWithdrawn(address advisor, uint256 amount);
  event TokensBought(address indexed buyer, uint256 tokens, uint256 eth);
  event Referral(address indexed addr, address referrer);
  event PromoApplied(address indexed addr);
  event Bonus(address indexed addr, uint256 tokens);

  modifier onlyAdmins() {
    require(admins[msg.sender] == true || msg.sender == owner);
    _;
  }

  modifier onlyFounder() {
    require(msg.sender == founderAddress);
    _;
  }

   modifier onlyAdvisor() {
    require(msg.sender == advisorAddress);
    _;
  }

  modifier onlyWhitelisted() {
    require(whitelist[msg.sender] > 0);
    _;
  }

  modifier onlyWhitelistedProxy(address _addr) {
    require(whitelist[_addr] > 0);
    _;
  }

  modifier onlyUpToAllowedContribution() {
    if (whitelist[msg.sender] == 1) {
      require(contributions[msg.sender].add(msg.value) < 71.5 ether);
    }

    if (whitelist[msg.sender] == 2) {
      require(contributions[msg.sender].add(msg.value) < 214 ether);
    }
    _;
  }

  modifier onlyUpToAllowedContributionProxy(address _addr) {
    if (whitelist[_addr] == 1) {
      require(contributions[_addr].add(msg.value) < 71.5 ether);
    }

    if (whitelist[_addr] == 2) {
      require(contributions[_addr].add(msg.value) < 214 ether);
    }
    _;
  }

  modifier onlyWhenInitialized() {
    require(initialized == true);
    _;
  }

  modifier onlyWhenCrowdsaleIsOpen() {
    require(now >= startTime && now < endTime);
    _;
  }

  modifier onlyAfterSoftCapReached() {
    require(totalContributed >= softcap);
    _;
  }

  modifier onlyWhenRefundable() {
    require(
      now > endTime &&
      totalContributed < softcap &&
      contributions[msg.sender] > 0
    );
    _;
  }

  modifier onlyWhenUnlocked() {
    require(now >= endTime + 356 days);
    _;
  }

  modifier onlyNonUSInvestor() {
    require(USInvestors[msg.sender] != true);
    _;
  }

  modifier onlyUSInvestor() {
    require(USInvestors[msg.sender] == true);
    _;
  }

  modifier onlyWhenSaleHasEnded() {
    require(now >= endTime);
    _;
  }

  modifier onlyWhenNotFinalized() {
    require(finalized == false);
    _;
  }

  constructor(Token _token, address _founder, address _advisor) public {

    token = Token(_token);
    founderAddress = _founder;
    emit FounderSet(_founder, msg.sender);
    advisorAddress = _advisor;
    emit AdvisorSet(_advisor, msg.sender);

    tiers.push(Tier(uint256(10000000).mul(DECIMALS), 1245));
    tiers.push(Tier(uint256(20000000).mul(DECIMALS), 830));
    tiers.push(Tier(uint256(30000000).mul(DECIMALS), 620));
    tiers.push(Tier(uint256(40000000).mul(DECIMALS), 415));
    tiers.push(Tier(uint256(43000000).mul(DECIMALS), 290));
  }

  function init(uint256 _startTime, uint256 _endTime) external onlyOwner returns (bool) {
    require(token.balanceOf(address(this)) == 143000000 * 10**18);
    startTime = _startTime;
    endTime = _endTime;
    initialized = true;
  }

  function () public payable  {
    buyTokens();
  }

   
  function buyTokens() public payable onlyWhenInitialized onlyWhenCrowdsaleIsOpen onlyWhitelisted onlyUpToAllowedContribution {
    _allocateTokens(msg.sender);
  }

  function buyTokensByProxy(address _addr) public payable onlyAdmins onlyWhenInitialized onlyWhenCrowdsaleIsOpen onlyWhitelistedProxy(_addr) onlyUpToAllowedContributionProxy(_addr) {
    _allocateTokens(_addr);
  }

  function _allocateTokens(address _addr) private {
    uint256 tokens = _getTokenAmount();

    contributions[_addr] = contributions[_addr].add(msg.value);
    totalContributed = totalContributed.add(msg.value);

     
    uint256 tenPercent = msg.value.mul(10).div(100);
    advisorFunds = advisorFunds.add(tenPercent);
    founderFunds = founderFunds.add(msg.value.sub(tenPercent));
    emit TokensBought(_addr, tokens, msg.value);
    _creditTokens(_addr, tokens);

     
    if (hasPromoCode[_addr] == true) {
      _allocatePromoTokens(_addr, tokens);
    }

     
    if (referrers[_addr] != 0) {
      _allocateReferralTokens(referrers[_addr], tokens);
    }
  }

  function _allocateReferralTokens(address _addr, uint256 _tokens) private {
    uint256 bonus = _tokens.mul(15).div(100);
    uint256 tokensToCredit = bonus;

     
    for (uint8 i = 0; i < tiers.length; i++) {
      if (tiers[i].amount > tokensToCredit) {
        tiers[i].amount = tiers[i].amount.sub(tokensToCredit);
        break;
      }

      tokensToCredit = tokensToCredit.sub(tiers[i].amount);
      tiers[i].amount = 0;
    }

    emit Bonus(_addr, bonus);
    _creditTokens(_addr, bonus);
  }

  function _allocatePromoTokens(address _addr, uint256 _tokens) private {
    uint256 bonus = _tokens.mul(20).div(100);
    uint256 tokensToCredit = bonus;

     
    for (uint8 i = 0; i < tiers.length; i++) {
      if (tiers[i].amount > tokensToCredit) {
        tiers[i].amount = tiers[i].amount.sub(tokensToCredit);
        break;
      }

      tokensToCredit = tokensToCredit.sub(tiers[i].amount);
      tiers[i].amount = 0;
    }

    emit Bonus(_addr, bonus);
    _creditTokens(_addr, bonus);
  }

  function _creditTokens(address _addr, uint256 _tokens) private {
    if (USInvestors[_addr]) {
       
      USInvestorTokens = USInvestorTokens.add(_tokens);
      USInvestorVault[_addr] = USInvestorVault[_addr].add(_tokens);
    } else {
       
      InvestorTokens = InvestorTokens.add(_tokens);
      InvestorVault[_addr] = InvestorVault[_addr].add(_tokens);
    }
  }

  function _getTokenAmount() private returns (uint256) {
    uint256 txBalance = msg.value;
    uint256 tokenAmount = 0;
    for (uint8 i = 0; i < tiers.length; i++) {
      uint256 tokensToBuy = txBalance.mul(tiers[i].rate);

      if (tiers[i].amount > tokensToBuy) {
        tiers[i].amount = tiers[i].amount.sub(tokensToBuy);
        tokenAmount = tokenAmount.add(tokensToBuy);
        return tokenAmount;
      }

      uint256 price = tiers[i].amount.div(tiers[i].rate);
      tokenAmount = tokenAmount.add(tiers[i].amount);
      tiers[i].amount = 0;
      txBalance = txBalance.sub(price);
    }

    return tokenAmount;
  }

  function whitelistAddresses(address[] _addrs) external onlyAdmins returns (bool) {
    for (uint8 i = 0; i < _addrs.length; i++) {
      whitelist[_addrs[i]] = 1;
      emit AddressWhitelisted(_addrs[i], msg.sender);
    }
    return true;
  }

  function setContributionLevel(address _addr, uint8 _lvl) external onlyAdmins returns (bool) {
    require(_lvl < 4);
    whitelist[_addr] = _lvl;
    emit ContributionLevelSet(_addr, _lvl, msg.sender);
    return true;
  }

  function setReferrer(address _addr, address _referrer) external onlyAdmins returns (bool) {
    referrers[_addr] = _referrer;
    emit Referral(_addr, _referrer);
    return true;
  }

  function setPromoCode(address _addr) external onlyAdmins returns (bool) {
    hasPromoCode[_addr] = true;
    emit PromoApplied(_addr);
    return true;
  }

  function flagUSInvestor(address _addr) external onlyAdmins returns (bool) {
    emit FlaggedUSInvestor(_addr, msg.sender);
    return USInvestors[_addr] = true;
  }

  function withdrawFounderFunds() external onlyFounder onlyAfterSoftCapReached returns (bool) {
    uint256 amount = founderFunds;
    founderFunds = 0;
    msg.sender.transfer(amount);
    emit FounderFundsWithdrawn(msg.sender, amount);
    return true;
  }

  function withdrawAdvisorFunds() external onlyAdvisor onlyAfterSoftCapReached returns (bool) {
    uint256 amount = advisorFunds;
    advisorFunds = 0;
    msg.sender.transfer(amount);
    emit AdvisorFundsWithdrawn(msg.sender, amount);
    return true;
  }

  function claimRefund() external onlyWhenRefundable returns (bool) {
    uint256 _tokensBought;

    uint256 _contributions = contributions[msg.sender];
    contributions[msg.sender] = 0;

    if (USInvestors[msg.sender] == true) {
      _tokensBought = USInvestorVault[msg.sender];
      USInvestorTokens = USInvestorTokens.sub(_tokensBought);
      USInvestorVault[msg.sender] = 0;
    } else {
      _tokensBought = InvestorVault[msg.sender];
      InvestorTokens = InvestorTokens.sub(_tokensBought);
      InvestorVault[msg.sender] = 0;
    }
    msg.sender.transfer(_contributions);
    return true;
  }

  function claimTokens() external onlyNonUSInvestor onlyAfterSoftCapReached onlyWhenSaleHasEnded returns (bool) {
    uint256 _tokens = InvestorVault[msg.sender];
    InvestorVault[msg.sender] = 0;
    InvestorTokens = InvestorTokens.sub(_tokens);

    token.safeTransfer(msg.sender, _tokens);
    return true;
  }

  function claimUSInvestorTokens() external onlyUSInvestor onlyAfterSoftCapReached onlyWhenUnlocked returns (bool) {
    uint256 _tokens = USInvestorVault[msg.sender];
    USInvestorVault[msg.sender] = 0;
    USInvestorTokens = USInvestorTokens.sub(_tokens);

    token.safeTransfer(msg.sender, _tokens);
    return true;
  }

  function setFounderAddress(address _addr) external onlyOwner returns (bool) {
    founderAddress = _addr;
    emit FounderSet(_addr, msg.sender);
    return true;
  }

  function setAdvisorAddress(address _addr) external onlyOwner returns (bool) {
    advisorAddress = _addr;
    emit AdvisorSet(_addr, msg.sender);
    return true;
  }

  function addAdmin(address _addr) external onlyOwner returns (bool) {
    admins[_addr] = true;
    emit AdminAdded(_addr, msg.sender);
    return true;
  }

  function removeAdmin(address _addr) external onlyOwner returns (bool) {
    admins[_addr] = false;
    emit AdminRemoved(_addr, msg.sender);
    return true;
  }

  function finalize() external onlyOwner onlyWhenSaleHasEnded onlyAfterSoftCapReached onlyWhenNotFinalized returns (bool) {
     
    uint256 _tokensLeft = token.balanceOf(address(this)).sub(InvestorTokens);
    _tokensLeft = _tokensLeft.sub(USInvestorTokens);

    token.burn(_tokensLeft);

    uint256 _founderFunds = founderFunds;
    founderFunds = 0;

    uint256 _advisorFunds = advisorFunds;
    advisorFunds = 0;

    finalized = true;

    founderAddress.transfer(_founderFunds);
    advisorAddress.transfer(_advisorFunds);
  }
}