pragma solidity ^0.5.2;

 
 
 
 
 

 
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
  address payable public owner;

  event OwnershipTransferred(address payable indexed previousOwner, address payable indexed newOwner);

   
  constructor() internal {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address payable newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

 
contract ERC20Basic {
  uint256 public totalSupply;
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

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping (address => uint256) balances;

   
  function _transfer(address _to, uint256 _value) internal returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
}

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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

 
contract BurnableToken is MintableToken {
  event Burn(address indexed burner, uint256 value);

   
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);

     
     

    balances[_who] = balances[_who].sub(_value);
    totalSupply = totalSupply.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

contract TradableToken is BurnableToken {
address public tradeAddress;

modifier onlyTrade() {
require(msg.sender == tradeAddress);
_;
}

function setTradeAddress(address _tradeAddress) public onlyOwner {
require(_tradeAddress != address(0));
tradeAddress = _tradeAddress;
}

function transferTrade(address _from, address _to, uint256 _value) onlyTrade public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);

balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(_from, _to, _value);
return true;
}

function transfer(address _to, uint256 _value) public returns (bool) {
if ((_to == tradeAddress) && !ITrade(tradeAddress).isOwner(msg.sender)) {
ITrade(tradeAddress).sellTokens(_value);
} else {
_transfer(_to, _value);
}
return true;
}
}

interface ITrade {
function sellTokens(uint amount) external;
function isOwner(address user) external view returns (bool);
}


 

contract BitcoinShortCoin is BurnableToken, TradableToken {
  string public constant name = "BitcoinShortCoin";
  string public constant symbol = "BSHORT";
  uint public constant decimals = 2;
}

 
contract BitcoinShortCoinCrowdsale is Ownable, BitcoinShortCoin {
  string public constant name = "Bitcoin Short Coin Sale Event";
  using SafeMath for uint256;

   
  BitcoinShortCoin public token;

  uint256 public startTime = 0;
  uint256 public endTime;
  bool public isPaused = false;

   
   
  uint256 public rate;

   
  uint256 public weiRaised;

  string public saleStatus = "Not started";

  uint public tokensMinted = 0;

  uint public minimumSupply = 1;  

  uint public hardCap = 2500000 * 10**2;

  event TokenPurchase(address indexed purchaser, uint256 value, uint integer_value, uint256 amount, uint integer_amount, uint256 tokensMinted);
  event TokenIssue(address indexed purchaser, uint256 amount, uint integer_amount, uint256 tokensMinted);

  constructor (uint256 _rate, uint256 _hardCap) public {
    require(_rate > 0);
    require(_rate <= 1000);
    token = createTokenContract();
    startTime = now;
    rate = _rate;
    hardCap = _hardCap * 10**2;
    saleStatus = "Running";
  }

  function pauseCrowdSale() public onlyOwner {
    isPaused = true;
    saleStatus = "Paused";
  }

  function startCrowdSale() public onlyOwner {
    isPaused = false;
    saleStatus = "Running";
  }

  function setRate(uint _rate) public onlyOwner {
    require(_rate > 0);
    require(_rate <= 1000);
    rate = _rate;
  }

  function createTokenContract() internal returns (BitcoinShortCoin) {
    return new BitcoinShortCoin();
  }

   
  function () external payable {
    buyTokens();
  }

   
  function buyTokens() public payable {
    require(!isPaused);
    require(validPurchase());

    uint256 weiAmount = msg.value;

     
    uint256 tokens = weiAmount.mul(1000).div(rate).div(10**16);

    require(tokensMinted.add(tokens) <= hardCap);

    weiRaised = weiRaised.add(weiAmount);

    token.mint(msg.sender, tokens);
    tokensMinted = tokensMinted.add(tokens);
    emit TokenPurchase(msg.sender, weiAmount, weiAmount.div(10**18), tokens, tokens.div(10**2), tokensMinted.div(10**2));

    forwardFunds();
  }

  function forwardFunds() internal {
    owner.transfer(msg.value);
  }

  function issueTokens(address _to, uint _amount) public onlyOwner {
    bool tmp = isPaused;
    isPaused = false;

    uint amount = _amount * 10**2;
    token.mint(_to, amount);
    tokensMinted = tokensMinted.add(amount);
    emit TokenIssue(_to, amount, amount.div(10**2), tokensMinted.div(10**2));

    isPaused = tmp;
  }

   
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = startTime > 0 && !isPaused;
    bool validAmount = msg.value >= (minimumSupply * 10**18 * rate).div(1000);
    return withinPeriod && validAmount;
  }
}