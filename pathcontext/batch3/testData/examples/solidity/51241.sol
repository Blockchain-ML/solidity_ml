pragma solidity ^0.4.23;

 

 
contract ERC20 {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender)
    public view returns (uint256);
  function transferFrom(address from, address to, uint256 value)
    public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

 

 
contract Ownable {
  address public owner;
  address public adminAddress;

  event AdminAddressUpdated(address indexed newAdminAddress);
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

  modifier onlyOwnerOrAdmin(){
    require(isOwnerOrAdmin(msg.sender));
    _;
  }

  function isAdmin(address _address) public view returns (bool){
    return (adminAddress != address(0) && _address == adminAddress);
  }

  function isOwner(address _address) public view returns (bool){
    return (owner != address(0) && _address == owner);
  }

  function isOwnerOrAdmin(address _address) public view returns (bool){
    return (isOwner(_address) || isAdmin(_address));
  }

  function setAdminAddress(address _newAdminAddress) public onlyOwner returns (bool){
    require(_newAdminAddress != owner);
    require(_newAdminAddress != address(this));

    adminAddress = _newAdminAddress;
    AdminAddressUpdated(adminAddress);

    return true;
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

 

 
 
 



contract Finalizable is Ownable {

   bool public finalized;

   event Finalized();


   constructor() public
      Ownable()
   {
      finalized = false;
   }


   function finalize() public onlyOwner returns (bool) {
      require(!finalized);

      finalized = true;

      Finalized();

      return true;
   }
}

 

 
library SafeERC20 {
  function safeTransfer(ERC20 token, address to, uint256 value) internal {
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

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
     
     
     
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

 

 
contract Crowdsale is Finalizable{
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

   
  ERC20 public token;

   
  address public wallet;

  bool public saleSuspended;

   
   
   
   
  uint256 public tokensPerEther;
  uint256 public maxContribution;
  uint256 public minContribution;
  uint256 public tokenConversionFactor;
  uint256 public currentStage;

  mapping(uint256 => uint256) bonusStages;

   
  uint256 public totalTokensSold;
  uint256 public weiRaised;

   
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );
  event TokensPerEtherUpdated(uint256 _newValue);
  event MaxContributionUpdated(uint256 _newMax);
  event MinContributionUpdated(uint256 _newMax);
  event BonusUpdated(uint256 _stage, uint256 _newBonus);
  event SaleWindowUpdated(uint256 _startTime, uint256 _endTime);
  event WalletAddressUpdated(address _newAddress);
  event SaleSuspended();
  event SaleResumed();
  event TokensPurchased(address _beneficiary, uint256 _cost, uint256 _tokens);

   
  constructor(uint256 _tokensPerEther, address _wallet, ERC20 _token) public {
    require(_tokensPerEther > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    tokensPerEther = _tokensPerEther;
    wallet = _wallet;
    token = _token;

    finalized = false;
    saleSuspended = false;

     
     
    currentStage        = 0;
    bonusStages[0]      = 2000;
    bonusStages[1]      = 1500;
    bonusStages[2]      = 1000;
    bonusStages[3]      = 500;
    bonusStages[4]      = 0;
    maxContribution     = 2 ether;  
    minContribution     = 0.5 ether;  
    totalTokensSold     = 0;
    weiRaised           = 0;

     
     
    tokenConversionFactor = 10**4;
    require(tokenConversionFactor > 0);
  }

   
   
   
  function setWalletAddress(address _walletAddress) external onlyOwner returns(bool) {
    require(_walletAddress != address(0));
    require(_walletAddress != address(this));
    require(_walletAddress != address(token));
    require(isOwnerOrAdmin(_walletAddress) == false);

    wallet = _walletAddress;

    emit WalletAddressUpdated(_walletAddress);

    return true;
  }

   
   
  function setMaxContribution(uint256 _maxEthers) external onlyOwner returns(bool) {

    maxContribution = _maxEthers;

    emit MaxContributionUpdated(_maxEthers);

    return true;
  }

   
   
  function setMinContribution(uint256 _minEthers) external onlyOwner returns(bool) {

    minContribution = _minEthers;

    emit MinContributionUpdated(_minEthers);

    return true;
  }

   
   
  function setTokensPerEther(uint256 _tokensPerEther) external onlyOwner returns(bool) {
    require(_tokensPerEther > 0);

    tokensPerEther = _tokensPerEther;

    emit TokensPerEtherUpdated(_tokensPerEther);

    return true;
  }

   
   
   
  function setBonus(uint256 _stage, uint256 _bonus) external onlyOwner returns(bool) {
    require(_bonus <= 10000);
    require(_stage > currentStage);

    bonusStages[_stage] = _bonus;

    emit BonusUpdated(_stage , _bonus);

    return true;
  }

   
  function nextStageBonus() public onlyOwner {
    currentStage++;
  }

  function getStageBonus() public view returns (uint256) {
    return bonusStages[currentStage];
  }

  function getCurrentStage() public view returns (uint256) {
    return currentStage;
  }

   
   function suspendSale() external onlyOwner returns(bool) {
      if (saleSuspended == true) {
          return false;
      }

      saleSuspended = true;

      emit SaleSuspended();

      return true;
   }

    
   function resume() external onlyOwner returns(bool) {
      if (saleSuspended == false) {
          return false;
      }

      saleSuspended = false;

      emit SaleResumed();

      return true;
   }



   
   
   

   
  function () external payable {
    buyTokens(msg.sender);
  }

   
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

     
    uint256 tokens = _getTokenAmount(weiAmount);

     
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

   
   
   

   
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

   
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
     
  }

   
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.safeTransfer(_beneficiary, _tokenAmount);
  }

   
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

   
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
     
  }

   
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return _weiAmount.mul(tokensPerEther);
  }

   
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

 

 
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

   
  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

   
  function capReached() public view returns (bool) {
    return weiRaised >= cap;
  }

   
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    require(weiRaised.add(_weiAmount) <= cap);
  }

}

 

 
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;

  event UpdatedOpeningTime(uint256 _newOpeningTime);
  event UpdatedClosingTime(uint256 _newClosingTime);
   
  modifier onlyWhileOpen {
     
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

   
  constructor(uint256 _openingTime, uint256 _closingTime) public {
     
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  function currentTime() public constant returns (uint256){
    return now;
  }

  function updateOpeningTime(uint256 _newOpeningTime) public returns (bool) {
    require(now < openingTime);
    require(now < _newOpeningTime);

    openingTime = _newOpeningTime;

    emit UpdatedOpeningTime(_newOpeningTime);

    return true;
  }

  function updateClosingTime(uint256 _newClosingTime) public returns (bool) {
    require(now < openingTime);
    require(openingTime < _newClosingTime);

    closingTime = _newClosingTime;

    emit UpdatedClosingTime(_newClosingTime);

    return true;
  }

   
  function hasClosed() public view returns (bool) {
     
    return block.timestamp > closingTime;
  }

   
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    onlyWhileOpen
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

 

contract TokenSale is Crowdsale, TimedCrowdsale, CappedCrowdsale{

    constructor
    (
        uint256 _rate,
        address _wallet,
        ERC20 _token,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _cap
    ) 
        Crowdsale(_rate, _wallet, _token)
        TimedCrowdsale(_openingTime, _closingTime)
        CappedCrowdsale(_cap)
        public
    {

    }
}