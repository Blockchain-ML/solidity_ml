 
pragma solidity ^0.4.23;


 
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



 
contract ReentrancyGuard {

   
  bool private reentrancyLock = false;

   
  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
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



 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



 
contract ERC223Receiver {
   
  function tokenFallback(address _from, uint _value, bytes _data) public;
}


 
contract BaseInvestmentPool is Ownable, ReentrancyGuard, ERC223Receiver {
  using SafeMath for uint;

   
  mapping(address => uint) public tokensWithdrawnByInvestor;

   
  mapping(address => uint) public investments;

   
  address public investmentAddress;

   
  address public tokenAddress;

   
  uint public tokensWithdrawn;

   
  uint public rewardWithdrawn;

   
  uint public rewardPermille;

   
  uint public weiRaised;

   
  bool public isFinalized;

   
  event Finalized();

   
  event Invest(address indexed investor, uint amount);

   
  event WithdrawTokens(address indexed investor, uint amount);

   
  event WithdrawReward(address indexed owner, uint amount);

   
  event SetInvestmentAddress(address indexed investmentAddress);

   
  event SetTokenAddress(address indexed tokenAddress);

   
  constructor(
    address _owner,
    address _investmentAddress,
    address _tokenAddress,
    uint _rewardPermille
  )
    public
  {
    require(_owner != address(0), "owner address should not be null");
    require(_rewardPermille < 1000, "rate should be less than 1000");
    owner = _owner;
    investmentAddress = _investmentAddress;
    tokenAddress = _tokenAddress;
    rewardPermille = _rewardPermille;
  }

   
  function finalize() external nonReentrant {
    require(!isFinalized, "pool is already finalized");
    _preValidateFinalization();
     
    require(investmentAddress.call.value(weiRaised)(), "error when sending funds to ICO");
    isFinalized = true;
    emit Finalized();
  }

   
  function withdrawTokens() external nonReentrant {
    require(msg.sender == owner || investments[msg.sender] != 0, "you are not owner and not investor");
    if (investments[msg.sender] != 0) {
      _withdrawInvestorTokens(msg.sender);
    }
    if (msg.sender == owner && rewardPermille != 0) {
      _withdrawOwnerTokens();
    }
  }

   
  function tokenFallback(address, uint, bytes) public {
    require(msg.sender == tokenAddress, "allowed receive tokens only from target ICO");
  }

   
  function invest(address _beneficiary) public payable {
    uint amount = msg.value;
    _preValidateInvest(_beneficiary, amount);
    weiRaised = weiRaised.add(amount);
    investments[_beneficiary] = investments[_beneficiary].add(amount);
    emit Invest(_beneficiary, amount);
  }

   
  function setInvestmentAddress(address _investmentAddress) public onlyOwner {
    require(investmentAddress == address(0), "investment address already set");
    investmentAddress = _investmentAddress;
    emit SetInvestmentAddress(_investmentAddress);
  }

   
  function setTokenAddress(address _tokenAddress) public onlyOwner {
    require(tokenAddress == address(0), "token address already set");
    tokenAddress = _tokenAddress;
    emit SetTokenAddress(_tokenAddress);
  }

   
  function _withdrawInvestorTokens(address _investor) internal {
    uint tokenAmount = _getInvestorTokenAmount(_investor);
    require(tokenAmount != 0, "contract have no tokens for you");
    _transferTokens(_investor, tokenAmount);
    tokensWithdrawnByInvestor[_investor] = tokensWithdrawnByInvestor[_investor].add(tokenAmount);
    emit WithdrawTokens(_investor, tokenAmount);
  }

   
  function _withdrawOwnerTokens() internal {
    require(isFinalized, "contract not finalized yet");
    uint tokenAmount = _getRewardTokenAmount();
    require(tokenAmount != 0, "contract have no tokens for you");
    _transferTokens(owner, tokenAmount);
    rewardWithdrawn = rewardWithdrawn.add(tokenAmount);
    emit WithdrawReward(owner, tokenAmount);
  }

   
  function _getRewardTokenAmount() internal view returns (uint) {
    uint tokenRaised = ERC20Basic(tokenAddress).balanceOf(this).add(tokensWithdrawn);
    uint tokenAmount = tokenRaised.mul(rewardPermille).div(1000);
    return tokenAmount.sub(rewardWithdrawn);
  }

   
  function _getInvestorTokenAmount(address _investor) internal view returns (uint) {
    uint tokenRaised = ERC20Basic(tokenAddress).balanceOf(this).add(tokensWithdrawn);
    uint investedAmount = investments[_investor];
    uint tokenAmount = investedAmount.mul(tokenRaised).mul(1000 - rewardPermille).div(weiRaised.mul(1000));
    return tokenAmount.sub(tokensWithdrawnByInvestor[_investor]);
  }

   
  function _transferTokens(address _investor, uint _amount) internal {
    ERC20Basic(tokenAddress).transfer(_investor, _amount);
    tokensWithdrawn = tokensWithdrawn.add(_amount);
  }

   
  function _preValidateInvest(address _beneficiary, uint _amount) internal {
    require(_beneficiary != address(0), "cannot invest from null address");
    require(!isFinalized, "contract is already finalized");
  }

   
  function _preValidateFinalization() internal {
    require(investmentAddress != address(0), "investment address did not set");
    require(tokenAddress != address(0), "token address did not set");
  }
}


 
contract CancellableInvestmentPool is BaseInvestmentPool {
   
  bool public isCancelled;

   
  event Cancelled();

   
  function cancel() public onlyOwner {
    require(!isCancelled, "pool is already cancelled");
    _preValidateCancellation();
    isCancelled = true;
    emit Cancelled();
  }

   
  function _preValidateCancellation() internal {
    require(!isFinalized, "pool is finalized");
  }

   
  function _preValidateFinalization() internal {
    super._preValidateFinalization();
    require(!isCancelled, "pool is cancelled");
  }

   
  function _preValidateInvest(address _beneficiary, uint _amount) internal {
    super._preValidateInvest(_beneficiary, _amount);
    require(!isCancelled, "contract is already cancelled");
  }
}


 
contract TimedInvestmentPool is BaseInvestmentPool {
   
  uint public startTime;

   
  uint public endTime;

   
  constructor(uint _startTime, uint _endTime) public {
    require(_startTime < _endTime, "start time should be before end time");
    startTime = _startTime;
    endTime = _endTime;
  }

   
  function hasStarted() public view returns (bool) {
    return now >= startTime;
  }

   
  function hasEnded() public view returns (bool) {
    return now >= endTime;
  }

   
  function _preValidateInvest(address _beneficiary, uint _amount) internal {
    super._preValidateInvest(_beneficiary, _amount);
    require(hasStarted(), "contract is not yet started");
    require(!hasEnded(), "contract is already ended");
  }

   
  function _preValidateFinalization() internal {
    super._preValidateFinalization();
    require(!hasEnded(), "time is out");
  }
}


 
contract HardCappedInvestmentPool is BaseInvestmentPool {
   
  uint hardCap;

   
  constructor(uint _hardCap) public {
    hardCap = _hardCap;
  }

   
  function hardCapReached() public view returns (bool) {
    return weiRaised >= hardCap;
  }

   
  function _preValidateInvest(address _beneficiary, uint _amount) internal {
    super._preValidateInvest(_beneficiary, _amount);
    require(!hardCapReached(), "hard cap already reached");
    require(weiRaised.add(_amount) <= hardCap, "cannot invest more than hard cap");
  }
}


 
contract SoftCappedInvestmentPool is BaseInvestmentPool {
   
  uint softCap;

   
  constructor(uint _softCap) public {
    softCap = _softCap;
  }

   
  function softCapReached() public view returns (bool) {
    return weiRaised >= softCap;
  }

   
  function _preValidateFinalization() internal {
    super._preValidateFinalization();
    require(softCapReached(), "soft cap did not reached yet");
  }
}


 
contract RefundableInvestmentPool is CancellableInvestmentPool, TimedInvestmentPool {
   
  address public serviceAccount;

   
  bool public isInvestmentAddressRefunded;

   
  bool private isRefundMode;

   
  event Refund(address indexed investor, uint amount);

   
  event ClaimRefund(uint amount);

   
  constructor(address _serviceAccount) {
    serviceAccount = _serviceAccount;
  }

   
  function() external payable {
    if (msg.sender == investmentAddress || isRefundMode) {
      emit ClaimRefund(msg.value);
    } else {
      invest(msg.sender);
    }
  }

   
  function executeAfterFinalize(bytes _data)
    external
    payable
    nonReentrant
  {
    require(msg.sender == owner || msg.sender == serviceAccount, "only owner and service account may do this");
    require(investmentAddress != address(0), "investment address did not set");
    require(isFinalized, "contract not finalized yet");
    uint balanceBeforeCall = address(this).balance;
    isRefundMode = true;
    if (msg.value != 0) {
      investmentAddress.call.value(msg.value)(_data);  
    } else {
      investmentAddress.call(_data);  
    }
    isRefundMode = false;
    if (address(this).balance > balanceBeforeCall) {
      isInvestmentAddressRefunded = true;
    }
  }

   
  function claimRefund() external nonReentrant {
    require(investments[msg.sender] != 0, "you are not investor");
     
    require(isCancelled || (!isFinalized && hasEnded()) || isInvestmentAddressRefunded,
      "contract has not ended, not cancelled and ico did not refunded");
    address investor = msg.sender;
    uint amount = investments[investor];
    investor.transfer(amount);
    delete investments[investor];
    emit Refund(investor, amount);
  }
}


 
contract ChangeableTimedInvestmentPool is TimedInvestmentPool {
   
  event TimesChanged(uint startTime, uint endTime, uint oldStartTime, uint oldEndTime);

   
  function setStartTime(uint _startTime) public onlyOwner {
     
    require(now < startTime);
     
    require(_startTime > startTime);
    require(_startTime < endTime);
    emit TimesChanged(
      _startTime,
      endTime,
      startTime,
      endTime
    );
    startTime = _startTime;
  }

   
  function setEndTime(uint _endTime) public onlyOwner {
     
    require(now < endTime);
     
    require(now < _endTime);
    require(_endTime > startTime);
    emit TimesChanged(
      startTime,
      _endTime,
      startTime,
      endTime
    );
    endTime = _endTime;
  }

   
  function setTimes(uint _startTime, uint _endTime) public onlyOwner {
    require(_endTime > _startTime);
    uint oldStartTime = startTime;
    uint oldEndTime = endTime;
    bool changed = false;
    if (_startTime != oldStartTime) {
      require(_startTime > now);
       
      require(now < oldStartTime);
       
      require(_startTime > oldStartTime);

      startTime = _startTime;
      changed = true;
    }
    if (_endTime != oldEndTime) {
       
      require(now < oldEndTime);
       
      require(now < _endTime);

      endTime = _endTime;
      changed = true;
    }

    if (changed) {
      emit TimesChanged(
        startTime,
        _endTime,
        startTime,
        endTime
      );
    }
  }
}


 
contract InvestmentPool is  
    SoftCappedInvestmentPool
  , HardCappedInvestmentPool
  , CancellableInvestmentPool
  , RefundableInvestmentPool
  , ChangeableTimedInvestmentPool
{
   
  constructor(
    address _owner,
    address _investmentAddress,
    address _tokenAddress,
    address _serviceAccount
  )
    public
    BaseInvestmentPool(_owner, _investmentAddress, _tokenAddress, 70)
    RefundableInvestmentPool(_serviceAccount)
    SoftCappedInvestmentPool(0)
    HardCappedInvestmentPool(132000000000000000000)
    TimedInvestmentPool(1532083380, 1532084100)
  {
    require(softCap < hardCap, "soft cap should be less than hard cap");
  }
}