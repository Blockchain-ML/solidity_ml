pragma solidity 0.4.24;

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}


 
contract TokenTimelock {
  using SafeERC20 for ERC20Basic;

   
  ERC20Basic public token;

   
  address public beneficiary;

   
  uint256 public releaseTime;

  function TokenTimelock(ERC20Basic _token, address _beneficiary, uint256 _releaseTime) public {
    require(_releaseTime > now);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

   
  function release() public {
    require(now >= releaseTime);

    uint256 amount = token.balanceOf(this);
    require(amount > 0);

    token.safeTransfer(beneficiary, amount);
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


contract FootStarToken is ERC20, Ownable {
    using SafeMath for uint256;

    string public constant name = "FTST Token";
    string public constant symbol = "FTST";
    uint8 public constant decimals = 18;

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;

    uint256 private totalSupply_;

    modifier canTransfer() {
        require(mintingFinished);
        _;
    }

     
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

     
    function transfer(address _to, uint256 _value) public canTransfer returns (bool) {
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

     
    function transferFrom(address _from, address _to, uint256 _value) public canTransfer returns (bool) {
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

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

     
    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

     
    function finishMinting() public onlyOwner canMint returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}

 
contract EscrowVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, GoalReached, Closed }

  mapping (address => uint256) public deposited;
  address public beneficiary;
  address public superOwner;
  State public state;

  event GoalReached();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);
  event Withdrawal(uint256 weiAmount);
  event Close();

  function EscrowVault(address _superOwner, address _beneficiary) public {
    require(_beneficiary != address(0));
    require(_superOwner != address(0));
    beneficiary = _beneficiary;
    superOwner = _superOwner;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active || state == State.GoalReached);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function setGoalReached() onlyOwner public {
    require (state == State.Active);
    state = State.GoalReached;
    GoalReached();
  }

  function withdraw(uint256 _amount) public {
    require(msg.sender == superOwner);
    require(state == State.GoalReached);
    require (_amount <= this.balance &&  _amount > 0);
    beneficiary.transfer(_amount);
    Withdrawal(_amount);
  }

  function withdrawAll() onlyOwner public {
    require(state == State.GoalReached);
    uint256 balance = this.balance;
    Withdrawal(balance);
    beneficiary.transfer(balance);
  }

  function close() onlyOwner public {
    require (state == State.GoalReached);
    withdrawAll();
    state = State.Closed;
    Close();
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}


contract FootStarCrowdsale is Ownable {
    using SafeMath for uint256;
     
    address public constant WALLET = 0x57E26E9B82b230CcbDE8931ee15f28B2C5557386;
     
    address public constant FOUNDERS_WALLET = 0x830feb44eB47043E3296EC5C44F3961Ec924625D;
     
    address public constant ADVISORS_WALLET = 0x41a9398a8D0770dA3F77602274025Fa1078E1783;
     
    address public constant COMPANY_WALLET = 0xE223d321f66a7d23a5D4C018bd71c7373bE1d348;
     
    address public constant BOUNTY_WALLET = 0xA1a45Bbc4AfdBbD36F2284BE04a9D71fa1D218C8;

    uint256 public constant FOUNDERS_TOKENS_LOCK_PERIOD = 60 * 60 * 24 * 365;  
    uint256 public constant COMPANY_TOKENS_LOCK_PERIOD = 60 * 60 * 24 * 365;  
    uint256 public constant SOFT_CAP = 207983100e18;
    uint256 public constant ITO_TOKENS = 2079850551e18;
    uint256 public constant START_TIME = 1536207000;  
    uint256 public constant RATE = 51000000000000;   

    uint256 public itoEndTime = 1536210000;  
    uint8 public constant ITO_TOKENS_PERCENT = 70;
    uint8 public constant FOUNDERS_TOKENS_PERCENT = 10;
    uint8 public constant COMPANY_TOKENS_PERCENT = 10;
    uint8 public constant ADVISORS_TOKENS_PERCENT = 5;
    uint8 public constant BOUNTY_TOKENS_PERCENT = 5;


    Stage[] internal stages;

    struct Stage {
        uint256 cap;
        uint64 till;
        uint8 bonus;
    }

     
    FootStarToken public token;

     
    uint256 public weiRaised;

     
    EscrowVault public vault;

    uint256 public currentStage = 0;
    bool public isFinalized = false;

    address private tokenMinter;

    TokenTimelock public foundersTimelock;
    TokenTimelock public companyTimelock;

     
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event Finalized();
     
    event ManualTokenMintRequiresRefund(address indexed purchaser, uint256 value);

    function FootStarCrowdsale() public {
        stages.push(Stage({ till: 1536207600, bonus: 55, cap: 2079850551e18 }));     
        stages.push(Stage({ till: 1536208200, bonus: 34, cap: 0 }));                 
        stages.push(Stage({ till: 1536208500, bonus: 21, cap: 0 }));                 
        stages.push(Stage({ till: 1536208800, bonus: 13, cap: 0 }));                 
        stages.push(Stage({ till: 1536209400, bonus: 8, cap: 0 }));                  
        stages.push(Stage({ till: 1536210000, bonus: 5, cap: 0 }));                  
        stages.push(Stage({ till: ~uint64(0), bonus: 0, cap: 0 }));                              

        token = FootStarToken(0xe1123110924073B74190710f20D9b394B8b15cFC);
        vault = new EscrowVault(msg.sender, WALLET);   
    }

    modifier onlyTokenMinterOrOwner() {
        require(msg.sender == tokenMinter || msg.sender == owner);
        _;
    }

    function buyTokens(address beneficiary) public payable {
        internalBuyTokens(msg.sender, beneficiary);
    }

    function internalBuyTokens(address sender, address beneficiary) internal {
        require(beneficiary != address(0));
        require(sender != address(0));
        require(validPurchase());

        uint256 weiAmount = msg.value;
        uint256 nowTime = getNow();
         
        while (currentStage < stages.length && stages[currentStage].till < nowTime) {
             
            uint256 nextStage = currentStage.add(1);
            stages[nextStage].cap = stages[nextStage].cap.add(stages[currentStage].cap);
            stages[currentStage].cap = 0;
            currentStage = nextStage;
        }

         
        uint256 tokens = calculateTokens(weiAmount);

        uint256 excess = appendContribution(beneficiary, tokens);
        uint256 refund = (excess > 0 ? excess.mul(weiAmount).div(tokens) : 0);
        weiAmount = weiAmount.sub(refund);
        weiRaised = weiRaised.add(weiAmount);

        if (refund > 0) {  
            sender.transfer(refund);
        }

        TokenPurchase(sender, beneficiary, weiAmount, tokens.sub(excess));

        if (goalReached() && vault.state() == EscrowVault.State.Active) {
            vault.setGoalReached();
        }
        vault.deposit.value(weiAmount)(sender);
    }

    function calculateTokens(uint256 _weiAmount) internal view returns (uint256) {
        uint256 tokens = _weiAmount.mul(RATE);

        if (stages[currentStage].bonus > 0) {
            uint256 stageBonus = tokens.mul(stages[currentStage].bonus).div(100);
            tokens = tokens.add(stageBonus);
        }

        if (currentStage < 2) return tokens;

        return tokens.add(tokens.div(100));
    }

    function appendContribution(address _beneficiary, uint256 _tokens) internal returns (uint256) {
        uint256 excess = _tokens;
        uint256 tokensToMint = 0;

        while (excess > 0 && currentStage < stages.length) {
            Stage storage stage = stages[currentStage];
            if (excess >= stage.cap) {
                excess = excess.sub(stage.cap);
                tokensToMint = tokensToMint.add(stage.cap);
                stage.cap = 0;
                currentStage = currentStage.add(1);
            } else {
                stage.cap = stage.cap.sub(excess);
                tokensToMint = tokensToMint.add(excess);
                excess = 0;
            }
        }
        if (tokensToMint > 0) {
            token.mint(_beneficiary, tokensToMint);
        }
        return excess;
    }

     
    function validPurchase() internal view returns (bool) {
        bool withinPeriod = getNow() >= START_TIME && getNow() <= itoEndTime;
        bool nonZeroPurchase = msg.value != 0;
        bool canMint = token.totalSupply() < ITO_TOKENS;
        bool validStage = (currentStage < stages.length);
        return withinPeriod && nonZeroPurchase && canMint && validStage;
    }

     
    function claimRefund() public {
        require(isFinalized);
        require(!goalReached());

        vault.refund(msg.sender);
    }

     
    function finalize() public onlyOwner {
        require(!isFinalized);
        require(getNow() > itoEndTime || token.totalSupply() == ITO_TOKENS);

        if (goalReached()) {
             
            if (vault.state() != EscrowVault.State.Closed) {
                vault.close();
            }

            uint256 totalSupply = token.totalSupply();

            foundersTimelock = new TokenTimelock(token, FOUNDERS_WALLET, getNow().add(FOUNDERS_TOKENS_LOCK_PERIOD));
            token.mint(foundersTimelock, uint256(FOUNDERS_TOKENS_PERCENT).mul(totalSupply).div(ITO_TOKENS_PERCENT));

            companyTimelock = new TokenTimelock(token, COMPANY_WALLET, getNow().add(COMPANY_TOKENS_LOCK_PERIOD));
            token.mint(companyTimelock, uint256(COMPANY_TOKENS_PERCENT).mul(totalSupply).div(ITO_TOKENS_PERCENT));

            token.mint(ADVISORS_WALLET, uint256(ADVISORS_TOKENS_PERCENT).mul(totalSupply).div(ITO_TOKENS_PERCENT));

            token.mint(BOUNTY_WALLET, uint256(BOUNTY_TOKENS_PERCENT).mul(totalSupply).div(ITO_TOKENS_PERCENT));

            token.finishMinting();
            token.transferOwnership(token);
        } else {
            vault.enableRefunds();
        }
        Finalized();
        isFinalized = true;
    }

    function goalReached() public view returns (bool) {
        return token.totalSupply() >= SOFT_CAP;
    }

     
    function () external payable {
        if (!isFinalized) {
            buyTokens(msg.sender);
        } else {
            claimRefund();
        }
    }

    function mintTokens(address[] _receivers, uint256[] _amounts) external onlyTokenMinterOrOwner {
        require(_receivers.length > 0 && _receivers.length <= 100);
        require(_receivers.length == _amounts.length);
        require(!isFinalized);
        for (uint256 i = 0; i < _receivers.length; i++) {
            address receiver = _receivers[i];
            uint256 amount = _amounts[i];

            require(receiver != address(0));
            require(amount > 0);

            uint256 excess = appendContribution(receiver, amount);

            if (excess > 0) {
                ManualTokenMintRequiresRefund(receiver, excess);
            }
        }
    }

    function setItoEndTime(uint256 _endTime) public onlyOwner {
        require(_endTime > START_TIME && _endTime > getNow());
        itoEndTime = _endTime;
    }

    function setTokenMinter(address _tokenMinter) public onlyOwner {
        require(_tokenMinter != address(0));
        tokenMinter = _tokenMinter;
    }

    function getNow() internal view returns (uint256) {
        return now;
    }
}