pragma solidity ^0.4.23;

 
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

 

 
contract BasicToken is ERC20Basic, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;
  
  bool public stopped = false;
  
  event Stop(address indexed from);
  
  event Start(address indexed from);
  
  modifier isRunning {
    assert (!stopped);
    _;
  }

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) isRunning public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256 ownerBalance) {
    return balances[_owner];
  }
  
  function stop() onlyOwner public {
    stopped = true;
    emit Stop(msg.sender);
  }

  function start() onlyOwner public {
    stopped = false;
    emit Start(msg.sender);
  }

}


 

 
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

   
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

 

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


   
  function transferFrom(address _from, address _to, uint256 _value) isRunning public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) isRunning public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint _addedValue) isRunning public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(address _spender, uint _subtractedValue) isRunning public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

 

 
contract StandardBurnableToken is BurnableToken, StandardToken {

   
  function burnFrom(address _from, uint256 _value) public {
    require(_value <= allowed[_from][msg.sender]);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _burn(_from, _value);
  }
}

 

 
contract CappedMintableToken is StandardToken {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event MintingAgentChanged(address addr, bool state);

  uint256 public cap;

  bool public mintingFinished = false;
  mapping (address => bool) public mintAgents;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }
  
  modifier onlyMintAgent() {
     
    if(!mintAgents[msg.sender] && (msg.sender != owner)) {
        revert();
    }
    _;
  }


  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }


   
  function setMintAgent(address addr, bool state) onlyOwner canMint public {
    mintAgents[addr] = state;
    emit MintingAgentChanged(addr, state);
  }
  
   
  function mint(address _to, uint256 _amount) onlyMintAgent canMint isRunning public returns (bool) {
    require(totalSupply_.add(_amount) <= cap);
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

 

 
contract ODXToken is CappedMintableToken, StandardBurnableToken {

  string public name; 
  string public symbol; 
  uint8 public decimals; 

   
  constructor(
      string _name, 
      string _symbol, 
      uint8 _decimals, 
      uint256 _maxTokens
  ) 
    public 
    CappedMintableToken(_maxTokens) 
  {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    totalSupply_ = 0;
  }
  
  function () payable public {
      revert();
  }

}

 

 
 
contract Crowdsale {
  using SafeMath for uint256;

   
  ERC20 public token;

   
  address public wallet;

   
  uint256 public rate;

   
  uint256 public weiRaised;

   
  uint256 public tokensToBeMinted;

   
  event AllocateTokens(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

   
  constructor(uint256 _rate, address _wallet, ERC20 _token) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));
	
    rate = _rate;
    wallet = _wallet;
    token = _token;
    
  }

   
   
   

   
  function () external payable {
    buyTokens(msg.sender);
  }

   
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;

     
    uint256 tokens = _getTokenAmount(weiAmount);
    
    _preValidatePurchase(_beneficiary, weiAmount, tokens);
    
     
    tokensToBeMinted = tokensToBeMinted.add(tokens);

     
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    emit AllocateTokens(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

     
    
    _forwardFunds();
     
  }

   
   
   

   
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount, uint256 _tokenToBeMinted) internal {
    require(_beneficiary != address(0));
     
    
  }

   
   
     
   

   
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    token.transfer(_beneficiary, _tokenAmount);
  }

   
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    _deliverTokens(_beneficiary, _tokenAmount);
  }
  
   
   
     
   

   
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(rate);
  }

   
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

 

 
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;
  uint256 public tokenCap;

   
  constructor(uint256 _cap, uint256 _tokenCap) public {
    require(_cap > 0);
    require(_tokenCap > 0);
    cap = _cap;
    tokenCap = _tokenCap;
  }
  

   
  function capReached() public view returns (bool) {
    return weiRaised >= cap;
  }

   
  function tokenCapReached() public view returns (bool) {
    return tokensToBeMinted >= tokenCap;
  }

}

 

 
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;

   
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

   
  function hasClosed() public view returns (bool) {
    return block.timestamp > closingTime;
  }

}

 

 
contract WhitelistedCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  mapping(address => bool) public whitelist;
  
  mapping (address => bool) public whitelistAgents;
  
  event WhitelistAgentChanged(address addr, bool state);
  event AddToWhitelist(address addr, bool state);
  event RemoveFromWhitelist(address addr, bool state);
  
  modifier onlyWhitelistAgent() {
     
    if(!whitelistAgents[msg.sender] && (msg.sender != owner)) {
        revert();
    }
    _;
  }
  
   
  modifier isWhitelisted(address _beneficiary) {
    require(whitelist[_beneficiary]);
    _;
  }

   
  function setWhitelistAgent(address addr, bool state) onlyOwner public {
    whitelistAgents[addr] = state;
    emit WhitelistAgentChanged(addr, state);
  }
  
  
   
  function addToWhitelist(address _beneficiary) external onlyWhitelistAgent {
    whitelist[_beneficiary] = true;
    emit AddToWhitelist(_beneficiary, true);
  }

   
  function addManyToWhitelist(address[] _beneficiaries) external onlyWhitelistAgent {
    for (uint256 i = 0; i < _beneficiaries.length; i++) {
      whitelist[_beneficiaries[i]] = true;
      emit AddToWhitelist(_beneficiaries[i], true);
    }
  }

   
  function removeFromWhitelist(address _beneficiary) external onlyWhitelistAgent {
    whitelist[_beneficiary] = false;
    emit RemoveFromWhitelist(_beneficiary, true);
  }

}

 

 
contract CrowdsaleFromOtherSource is Crowdsale, Ownable {
  using SafeMath for uint256;

  mapping (address => bool) public allowedAgentsForOtherSource;
  
  mapping(string => uint256) raisedAmount;
  
  event AllowedAgentsForOtherSourceChanged(address addr, bool state);
  
  modifier onlyAllowedAgentForOtherSource() {
     
    if(!allowedAgentsForOtherSource[msg.sender] && (msg.sender != owner)) {
        revert();
    }
    _;
  }
  
  constructor() public {
  }
  
   
  function setAllowedAgentsForOtherSource(address addr, bool state) onlyOwner public {
    allowedAgentsForOtherSource[addr] = state;
    emit AllowedAgentsForOtherSourceChanged(addr, state);
  }
  
  function validOtherSource(string _newOtherSource) internal view returns (bool) {
    if (keccak256(_newOtherSource)==keccak256("BTC") || keccak256(_newOtherSource)==keccak256("LTC")) return true;
    return false;
  }
  
  function getRaisedAmount(string source) public view returns (uint256){
      return raisedAmount[source];
  }
  
}

 

 
contract ETHRateAgents is Ownable {
  using SafeMath for uint256;

  mapping (address => bool) public ethRateAgents;
  
  event ETHRateAgentChanged(address addr, bool state);
  
  modifier onlyETHRateAgent() {
     
    if(!ethRateAgents[msg.sender] && (msg.sender != owner)) {
        revert();
    }
    _;
  }
  
   
  function setETHRateAgent(address addr, bool state) onlyOwner public {
    ethRateAgents[addr] = state;
    emit ETHRateAgentChanged(addr, state);
  }
  
}

 

 
contract CrowdsaleNewRules is CappedCrowdsale, TimedCrowdsale, WhitelistedCrowdsale, CrowdsaleFromOtherSource, ETHRateAgents {
  using SafeMath for uint256;

   
   

   
  uint256 public minContribution;

  mapping(address => uint256) public balances;
  
  event DeliverTokens(address indexed sender, address indexed beneficiary, uint256 value);
  event UpdateRate(address indexed sender, uint256 rate);
  
  event AllocateTokensFromOtherSource(string indexed coinType, address indexed beneficiary, uint256 value, uint256 amount);


   
  constructor(uint256 _minContribution) public {
    require(_minContribution > 0);
    minContribution = _minContribution;
  }

   
  function withdrawTokensByInvestors() external isWhitelisted(msg.sender) {
    _sendTokens(msg.sender);
  }

   
  function sendTokensToInvestors(address _beneficiary) external onlyOwner isWhitelisted(_beneficiary) {
    _sendTokens(_beneficiary);
  }

   
  function _sendTokens(address _beneficiary) internal {
    require(hasClosed());
    uint256 amount = balances[_beneficiary];
    require(amount > 0);
    balances[_beneficiary] = 0;
    _deliverTokens(_beneficiary, amount);
    
    emit DeliverTokens(
        msg.sender,
        _beneficiary,
        amount
    );
  }
  
   
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    balances[_beneficiary] = balances[_beneficiary].add(_tokenAmount);
  }
  
   
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    require(ODXToken(token).mint(_beneficiary, _tokenAmount));
    tokensToBeMinted = tokensToBeMinted.sub(_tokenAmount);
     
  }
  
   
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount, uint256 _tokensToBeMinted) internal onlyWhileOpen isWhitelisted(_beneficiary) {
    require(_weiAmount >= minContribution);
     
    require(tokensToBeMinted.add(_tokensToBeMinted) <= tokenCap);
    super._preValidatePurchase(_beneficiary, _weiAmount, _tokensToBeMinted);
  }


   
  function updateRate(uint256 _newrate) external onlyETHRateAgent() {
    require(_newrate > 0);
    rate = _newrate;
    
    emit UpdateRate(
        msg.sender,
        _newrate
    );
  }


   
  function addPurchaseFromOtherSource(address _beneficiary, string _coinType, uint256 _amount, uint256 _tokensToBeMinted) public onlyWhileOpen isWhitelisted(_beneficiary) onlyAllowedAgentForOtherSource() {
    require(_amount >= 0);
    require(_tokensToBeMinted >= 0);
    require(validOtherSource(_coinType));
    require(tokensToBeMinted.add(_tokensToBeMinted) <= tokenCap);
    
    tokensToBeMinted = tokensToBeMinted.add(_tokensToBeMinted);
    balances[_beneficiary] = balances[_beneficiary].add(_tokensToBeMinted);
    emit AllocateTokensFromOtherSource(_coinType, _beneficiary, _amount, _tokensToBeMinted);
    raisedAmount[_coinType] = raisedAmount[_coinType] + _amount;
    
  }
}

 

 
contract ODXCrowdsale is CrowdsaleNewRules {
  constructor(
    uint256 _rate,
    address _wallet,
    uint256 _cap,
    uint256 _tokenCap,
    ODXToken _token,
    uint256 _minContribution,
    uint256 _openingTime
  )
    public
    Crowdsale(_rate, _wallet, _token)
    CappedCrowdsale(_cap, _tokenCap)
    CrowdsaleNewRules(_minContribution)
    TimedCrowdsale(_openingTime, now + 4 days)
     
    CrowdsaleFromOtherSource()
  {
    require(_rate > 0);
  }
  
}