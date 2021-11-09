pragma solidity 0.4.25;
 
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
    require(b > 0);  
    uint256 c = a / b;
    assert(a == b * c + a % b);  
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}
contract Owned {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner , "Unauthorized Access");
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }
interface ERC20Interface {
   
       
     
    function balanceOf(address _owner) view external returns (uint256 balance);

     
     
     
     
    function transfer(address _to, uint256 _value) external returns (bool success);

     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

   
    function approve(address _spender, uint256 _value) external returns (bool success);
    function disApprove(address _spender)  external returns (bool success);
   function increaseApproval(address _spender, uint _addedValue) external returns (bool success);
   function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool success);
      
     
     
    function allowance(address _owner, address _spender) constant external returns (uint256 remaining);
     function name() external view returns (string _name);

     
    function symbol() external view returns (string _symbol);

     
    function decimals() external view returns (uint8 _decimals); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
library SafeERC20{

  function safeTransfer(ERC20Interface token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }    
    
  

  function safeTransferFrom(ERC20Interface token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20Interface token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
  
}
contract ERCStaking {
  event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
  event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);

  function stake(uint256 amount, bytes data) public;
  function stakeFor(address user, uint256 amount, bytes data) public;
  function withdrawStake(uint256 amount, bytes data) public;
  function totalStakedFor(address addr) public view returns (uint256);
  function totalStaked() public view returns (uint256);
  function token() public view returns (address);
  
   
   
  }
  
  contract BasicStakeContract is ERCStaking {
  
  using SafeMath for uint256;
  using SafeERC20 for ERC20Interface;

   
  ERC20Interface stakingToken;

   
  uint256 public defaultLockInDuration;

   
   
   
   
   
  mapping (address => StakeContract) public stakeHolders;

   
   
   
   
  struct Stake {
    uint256 unlockedTimestamp;
    uint256 stakedAt;   
    uint256 actualAmount;
    address stakedFor;
  }

   
   
   
   
   
  struct StakeContract {
    uint256 totalStakedFor;

    uint256 personalStakeIndex;

    Stake[] personalStakes;

    bool exists;
  }

   
  modifier canStake(address _address, uint256 _amount) {
    require(
      stakingToken.transferFrom(_address, this, _amount),
      "Stake required");

    _;
  }

   
  constructor(ERC20Interface _stakingToken) public {
    stakingToken = _stakingToken;
  }

   
  function getPersonalStakeUnlockedTimestamps(address _address) external view returns (uint256[]) {
    uint256[] memory timestamps;
    (timestamps,,) = getPersonalStakes(_address);

    return timestamps;
  }

   
  function getPersonalStakeActualAmounts(address _address) external view returns (uint256[]) {
    uint256[] memory actualAmounts;
    (,actualAmounts,) = getPersonalStakes(_address);

    return actualAmounts;
  }

   
  function getPersonalStakeForAddresses(address _address) external view returns (address[]) {
    address[] memory stakedFor;
    (,,stakedFor) = getPersonalStakes(_address);

    return stakedFor;
  }

   
  function stake(uint256 _amount, bytes _data) public {
    createStake(
      msg.sender,
      _amount,
      defaultLockInDuration,
      _data);
  }

   
  function stakeFor(address _user, uint256 _amount, bytes _data) public {
    createStake(
      _user,
      _amount,
      defaultLockInDuration,
      _data);
  }

   
  function withdrawStake(uint256 _amount, bytes _data) public;

   
  function totalStakedFor(address _address) public view returns (uint256) {
    return stakeHolders[_address].totalStakedFor;
  }

   
  function totalStaked() public view returns (uint256) {
    return stakingToken.balanceOf(this);
  }

   
  function token() public view returns (address) {
    return stakingToken;
  }



   
  function getPersonalStakes(
    address _address
  )
    view
    public
    returns(uint256[], uint256[], address[])
  {
    StakeContract storage stakeContract = stakeHolders[_address];

    uint256 arraySize = stakeContract.personalStakes.length - stakeContract.personalStakeIndex;
    uint256[] memory unlockedTimestamps = new uint256[](arraySize);
    uint256[] memory actualAmounts = new uint256[](arraySize);
    address[] memory stakedFor = new address[](arraySize);

    for (uint256 i = stakeContract.personalStakeIndex; i < stakeContract.personalStakes.length; i++) {
      uint256 index = i - stakeContract.personalStakeIndex;
      unlockedTimestamps[index] = stakeContract.personalStakes[i].unlockedTimestamp;
      actualAmounts[index] = stakeContract.personalStakes[i].actualAmount;
      stakedFor[index] = stakeContract.personalStakes[i].stakedFor;
    }

    return (
      unlockedTimestamps,
      actualAmounts,
      stakedFor
    );
  }

   
  function createStake(
    address _address,
    uint256 _amount,
    uint256 _lockInDuration,
    bytes _data
  )
    internal
    canStake(msg.sender, _amount)
  {
    if (!stakeHolders[msg.sender].exists) {
      stakeHolders[msg.sender].exists = true;
    }

    stakeHolders[_address].totalStakedFor = stakeHolders[_address].totalStakedFor.add(_amount);
    stakeHolders[msg.sender].personalStakes.push(
      Stake(
        block.timestamp.add(_lockInDuration),
        block.timestamp,
        _amount,
        _address)
      );

    emit Staked(
      _address,
      _amount,
      totalStakedFor(_address),
      _data);
  }

  
}

contract AfricaTokenStakeWithBonus is BasicStakeContract(ERC20Interface(0x4cc1ae0aFED85B02c2891039b4Fad212F64b1C33)), Owned{
    uint256 constant public YEAR_IN_SECONDS = 31557600;
    uint256 constant public HALF_YEAR_IN_SECONDS = 15778800;
    uint256 public oneYearBonusRate;  
    uint256 public halfYearBonusRate;  
   

    constructor() public
    {
         halfYearBonusRate = 7;
         oneYearBonusRate = 15;
         defaultLockInDuration = 15778800;
    }
    
    function setbonus(uint256 _halfyearRate, uint256 _oneyearRate) onlyOwner public {
         
      halfYearBonusRate = _halfyearRate;
      oneYearBonusRate = _oneyearRate;
    }
    function calculateBonus(uint256 _amount,uint256 _stakedAt) internal view returns(uint256){
        if(block.timestamp.sub(_stakedAt) >= YEAR_IN_SECONDS)
          return _amount.mul(oneYearBonusRate.div(100));
        else{
            if(block.timestamp.sub(_stakedAt) >= HALF_YEAR_IN_SECONDS)
              return _amount.mul(halfYearBonusRate.div(100));
            else
              return 0;
        }  
    }
    
    
    function withdrawStake(uint256 _amount, bytes _data) public {
    unstake(
      _amount,
      _data);
  }
     
  function unstake(
    uint256 _amount,
    bytes _data
  )
    internal
  {
    Stake storage personalStake = stakeHolders[msg.sender].personalStakes[stakeHolders[msg.sender].personalStakeIndex];

     
    require(
      personalStake.unlockedTimestamp <= block.timestamp,
      "The current stake hasn&#39;t unlocked yet");

    require(
      personalStake.actualAmount == _amount,
      "The unstake amount does not match the current stake");

    uint256 calculatedBonus = calculateBonus(_amount,personalStake.stakedAt);
     
     
     
    require(
      stakingToken.transfer(msg.sender, _amount.add(calculatedBonus)),
      "Unable to withdraw stake");

    stakeHolders[personalStake.stakedFor].totalStakedFor = stakeHolders[personalStake.stakedFor]
      .totalStakedFor.sub(personalStake.actualAmount);

    personalStake.actualAmount = 0;
    stakeHolders[msg.sender].personalStakeIndex++;

    emit Unstaked(
      personalStake.stakedFor,
      _amount,
      totalStakedFor(personalStake.stakedFor),
      _data);
  }
}