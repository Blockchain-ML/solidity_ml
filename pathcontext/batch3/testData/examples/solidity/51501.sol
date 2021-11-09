pragma solidity 0.4.24;

 

 
contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() public {
        owner = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

 

contract Whitelisted is Ownable {

     
    bool public whitelistEnabled = true;

     
    mapping(address => bool) public whitelist;

    event ICOWhitelisted(address indexed addr);
    event ICOBlacklisted(address indexed addr);

    modifier onlyWhitelisted {
        require(!whitelistEnabled || whitelist[msg.sender]);
        _;
    }

     
    function whitelist(address address_) external onlyOwner {
        whitelist[address_] = true;
        emit ICOWhitelisted(address_);
    }

     
    function blacklist(address address_) external onlyOwner {
        delete whitelist[address_];
        emit ICOBlacklisted(address_);
    }

     
    function whitelisted(address address_) public view returns (bool) {
        if (whitelistEnabled) {
            return whitelist[address_];
        } else {
            return true;
        }
    }

     
    function enableWhitelist() public onlyOwner {
        whitelistEnabled = true;
    }

     
    function disableWhitelist() public onlyOwner {
        whitelistEnabled = false;
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

 

 
contract Lockable is Ownable {
    event Lock();
    event Unlock();

    bool public locked = false;

     
    modifier whenNotLocked() {
        require(!locked);
        _;
    }

     
    modifier whenLocked() {
        require(locked);
        _;
    }

     
    modifier preLockUnlock() {
      _;
    }

     
    function lock() public onlyOwner whenNotLocked preLockUnlock {
        locked = true;
        emit Lock();
    }

     
    function unlock() public onlyOwner whenLocked preLockUnlock {
        locked = false;
        emit Unlock();
    }
}

 

contract BaseFixedERC20Token is Lockable {
    using SafeMath for uint;

     
    uint public totalSupply;

    mapping(address => uint) public balances;

    mapping(address => mapping(address => uint)) private allowed;

     
    event Transfer(address indexed from, address indexed to, uint value);

     
    event Approval(address indexed owner, address indexed spender, uint value);

     
    function balanceOf(address owner_) public view returns (uint balance) {
        return balances[owner_];
    }

     
    function transfer(address to_, uint value_) public whenNotLocked returns (bool) {
        require(to_ != address(0) && value_ <= balances[msg.sender]);
         
        balances[msg.sender] = balances[msg.sender].sub(value_);
        balances[to_] = balances[to_].add(value_);
        emit Transfer(msg.sender, to_, value_);
        return true;
    }

     
    function transferFrom(address from_, address to_, uint value_) public whenNotLocked returns (bool) {
        require(to_ != address(0) && value_ <= balances[from_] && value_ <= allowed[from_][msg.sender]);
        balances[from_] = balances[from_].sub(value_);
        balances[to_] = balances[to_].add(value_);
        allowed[from_][msg.sender] = allowed[from_][msg.sender].sub(value_);
        emit Transfer(from_, to_, value_);
        return true;
    }

     
    function approve(address spender_, uint value_) public whenNotLocked returns (bool) {
        if (value_ != 0 && allowed[msg.sender][spender_] != 0) {
            revert();
        }
        allowed[msg.sender][spender_] = value_;
        emit Approval(msg.sender, spender_, value_);
        return true;
    }

     
    function allowance(address owner_, address spender_) public view returns (uint) {
        return allowed[owner_][spender_];
    }
}

 

 
contract BaseICOToken is BaseFixedERC20Token {

     
    uint public availableSupply;

     
    address public ico;

     
    uint public constant ETH_TOKEN_EXCHANGE_RATIO_MULTIPLIER = 1000;

     
    uint public ethTokenExchangeRatio;

     
    event ICOTokensInvested(address indexed to, uint amount);

     
    event ICOChanged(address indexed icoContract);

    modifier onlyICO() {
        require(msg.sender == ico);
        _;
    }

     
    constructor(uint totalSupply_) public {
        locked = true;
        totalSupply = totalSupply_;
        availableSupply = totalSupply_;
    }

     
    function changeICO(address ico_) public onlyOwner {
        ico = ico_;
        emit ICOChanged(ico);
    }

    function isValidICOInvestment(address to_, uint amount_) internal view returns (bool) {
        return to_ != address(0) && amount_ <= availableSupply;
    }

     
    function icoInvestmentWei(address to_, uint amountWei_) public returns (uint);

     
    function icoAssignReservedBounty(address to_, uint amount_) public;
}

 

 
contract BaseICO is Ownable, Whitelisted {

   
  enum State {

     
    Inactive,

     
     
    Active,

     
     
     
    Suspended,

     
    Terminated,

     
     
    NotCompleted,

     
     
    Completed
  }

   
  BaseICOToken public token;

   
  State public state;

   
  uint public startAt;

   
  uint public endAt;

   
  uint public lowCapTokens;

   
   
  uint public hardCapTokens;

   
  uint public lowCapTxWei;

   
  uint public hardCapTxWei;

   
  address public teamWallet;

   
  event ICOStarted(uint indexed endAt, uint lowCapTokens, uint hardCapTokens, uint lowCapTxWei, uint hardCapTxWei);
  event ICOResumed(uint indexed endAt, uint lowCapTokens, uint hardCapTokens, uint lowCapTxWei, uint hardCapTxWei);
  event ICOSuspended();
  event ICOTerminated();
  event ICONotCompleted();
  event ICOCompleted(uint collectedTokens);
  event ICOInvestment(address indexed from, uint investedWei, uint tokens, uint8 bonusPct);

  modifier isSuspended() {
    require(state == State.Suspended);
    _;
  }
  modifier isActive() {
    require(state == State.Active);
    _;
  }

   
  function start(uint endAt_) onlyOwner public {
    require(endAt_ > block.timestamp && state == State.Inactive);
    endAt = endAt_;
    startAt = block.timestamp;
    state = State.Active;
    emit ICOStarted(endAt, lowCapTokens, hardCapTokens, lowCapTxWei, hardCapTxWei);
  }

   
  function suspend() onlyOwner isActive public {
    state = State.Suspended;
    emit ICOSuspended();
  }

   
  function terminate() onlyOwner public {
    require(state != State.Terminated &&
            state != State.NotCompleted &&
            state != State.Completed);
    state = State.Terminated;
    emit ICOTerminated();
  }

   
  function tune(uint endAt_,
                uint lowCapTokens_,
                uint hardCapTokens_,
                uint lowCapTxWei_,
                uint hardCapTxWei_) onlyOwner isSuspended public {
    if (endAt_ > block.timestamp) {
      require(endAtCheck(endAt_));
      endAt = endAt_;
    }
    if (lowCapTokens_ > 0) {
      lowCapTokens = lowCapTokens_;
    }
    if (hardCapTokens_ > 0) {
      hardCapTokens = hardCapTokens_;
    }
    if (lowCapTxWei_ > 0) {
      lowCapTxWei = lowCapTxWei_;
    }
    if (hardCapTxWei_ > 0) {
      hardCapTxWei = hardCapTxWei_;
    }
    require(lowCapTokens <= hardCapTokens && lowCapTxWei <= hardCapTxWei);
    touch();
  }

   
  function endAtCheck(uint) internal returns (bool) {
     
    return true;
  }

   
  function resume() onlyOwner isSuspended public {
    state = State.Active;
    emit ICOResumed(endAt, lowCapTokens, hardCapTokens, lowCapTxWei, hardCapTxWei);
    touch();
  }

   
  function forwardFunds() internal {
    teamWallet.transfer(msg.value);
  }

   
  function touch() public;

   
  function buyTokens() public payable;
}

 

contract ESRTICO is BaseICO {
  using SafeMath for uint;

   
  uint public collectedWei;

   
  uint public collectedTokens;

  bool internal lowCapChecked = false;

  uint public lastStageStartAt = 1554076800;  

  constructor(address icoToken_,
              address teamWallet_) public {
    require(icoToken_ != address(0) && teamWallet_ != address(0));
    token = BaseICOToken(icoToken_);
    teamWallet = teamWallet_;
    hardCapTokens = 60e24;  
    lowCapTokens = 15e23;   
    hardCapTxWei = 1e30;   
    lowCapTxWei = 5e16;    
  }

   
  function() external payable {
    buyTokens();
  }

   
  function touch() public {
    if (state != State.Active && state != State.Suspended) {
      return;
    }
    if (collectedTokens >= hardCapTokens) {
      state = State.Completed;
      endAt = block.timestamp;
      emit ICOCompleted(collectedTokens);
    } else if (!lowCapChecked && block.timestamp >= lastStageStartAt) {
      lowCapChecked = true;
      if (collectedTokens < lowCapTokens) {
        state = State.NotCompleted;
        emit ICONotCompleted();
      }
    } else if (block.timestamp >= endAt) {
        state = State.Completed;
        emit ICOCompleted(collectedTokens);
    }
  }

   
  function tuneLastStageStartAt(uint lastStageStartAt_) onlyOwner isSuspended public {
    if (lastStageStartAt_ > block.timestamp) {
       
      require(lastStageStartAt_ < lastStageStartAt);
      lastStageStartAt = lastStageStartAt_;
    }
    touch();
  }

   
  function endAtCheck(uint endAt_) internal returns (bool) {
     
    return endAt_ < endAt;
  }

  function computeBonus() internal view returns (uint8) {
    if (block.timestamp < 1538352000) {  
      return 20;
    } else if (block.timestamp < 1546300800) {  
      return 10;
    } else if (block.timestamp < lastStageStartAt) {
      return 5;
    } else {
      return 0;
    }
  }

  function buyTokens() public payable {

    require(state == State.Active &&
            block.timestamp < endAt &&
            msg.value >= lowCapTxWei &&
            msg.value <= hardCapTxWei &&
            whitelisted(msg.sender));

    uint8 bonus = computeBonus();
    uint amountWei = msg.value;
    uint itokens = token.icoInvestmentWei(msg.sender, amountWei);

    uint bwei = amountWei.mul(bonus).div(100);
    uint btokens = bwei.mul(token.ethTokenExchangeRatio()).div(token.ETH_TOKEN_EXCHANGE_RATIO_MULTIPLIER());
    token.icoAssignReservedBounty(msg.sender, btokens);

    require(collectedTokens + itokens <= hardCapTokens);
    collectedTokens = collectedTokens.add(itokens);
    collectedWei = collectedWei.add(amountWei);

    emit ICOInvestment(msg.sender, amountWei, itokens.add(btokens), bonus);
    forwardFunds();
    touch();
  }
}