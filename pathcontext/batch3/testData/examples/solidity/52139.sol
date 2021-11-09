pragma solidity ^0.4.24;

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);  
    uint256 c = a / b;

    return c;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

   
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

 
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

   
  constructor() public {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

   
  function owner() public view returns(address) {
    return _owner;
  }

   
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

   
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

 
interface IERC20 {

  function balanceOf(address account) external view returns (uint256);
 
  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function allowance(address owner, address spender)
    external view returns (uint256);

   
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

contract ERC20 is IERC20 {
  using SafeMath for uint256;
	
  mapping (address => uint256) public balances;
  mapping (address => mapping (address => uint256)) public allowed;

  uint256 public totalSupply;
  
  constructor(uint256 initialSupply) public {
	require(msg.sender != 0);
	totalSupply = initialSupply;
    balances[msg.sender] = initialSupply;
    emit Transfer(address(0), msg.sender, initialSupply);
  }

   
  function balanceOf(address account) external view returns (uint256) {
    return balances[account];
  }

   
  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= balances[msg.sender]);
    require(to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[to] = balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
  }

   
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (bool)
  {
    require(value <= balances[from]);
    require(value <= allowed[from][msg.sender]);
    require(to != address(0));

    balances[from] = balances[from].sub(value);
    balances[to] = balances[to].add(value);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
    emit Transfer(from, to, value);
    return true;
  }

   
  function approve(address spender, uint256 value) external returns (bool) {
    require(spender != address(0));

    allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

   
  function allowance(
    address owner,
    address spender
   )
    external
    view
    returns (uint256)
  {
    return allowed[owner][spender];
  }

   
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    allowed[msg.sender][spender] = (
      allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

   
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    allowed[msg.sender][spender] = (
      allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }
}

 
contract Burnable is ERC20 {
	
   
  event Burn(
    address indexed from,
	uint256 value
  );
  
   
  function burn(uint256 value) public {
	_burn(msg.sender, value);
  }

   
  function burnFrom(address from, uint256 value) public {
	require(value <= allowed[from][msg.sender]);

     
     
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
    _burn(from, value);
  }

   
  function _burn(address account, uint256 amount) internal {
    require(account != 0);
    require(amount <= balances[account]);

    totalSupply = totalSupply.sub(amount);
    balances[account] = balances[account].sub(amount);
    emit Burn(account, amount);
  }
}

 
contract Freezable is ERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _freeze;

   
  event Freeze(
    address indexed from,
	uint256 value
  );

   
  event Unfreeze(
    address indexed from,
	uint256 value
  );

   
  function freezeOf(address account) public view returns (uint256) {
    return _freeze[account];
  }

   
  function freeze(uint256 amount) public {
    require(balances[msg.sender] >= amount);
    require(amount > 0);
    balances[msg.sender] = balances[msg.sender].sub(amount);
    _freeze[msg.sender] = _freeze[msg.sender].add(amount);
    emit Freeze(msg.sender, amount);
  }

   
  function unfreeze(uint256 amount) public {
    require(_freeze[msg.sender] >= amount);
    require(amount > 0);
    _freeze[msg.sender] = _freeze[msg.sender].sub(amount);
    balances[msg.sender] = balances[msg.sender].add(amount);
    emit Unfreeze(msg.sender, amount);
  }
}

 
contract CrowdsaleToken is ERC20 {

  uint256 public crowdsaleCap;
  uint256 public crowdsaleRate;  
  uint256 public tokensSold = 0;
  uint256 private _tokensRemaining;

   
   enum Stages {
      none,
      icoStarted,
      icoEnded
  }

  Stages public currentStage;

   
  event TokensPurchased(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

   
  constructor(uint256 cap, uint256 rate) public {
    currentStage = Stages.none;
	crowdsaleCap = cap;
	crowdsaleRate = rate;
	_tokensRemaining = cap;
  }

   
  function () external payable {
    buyTokens(msg.sender);
  }

   
  function buyTokens(address beneficiary) public payable {

    uint256 weiAmount = msg.value;

	 
    uint256 tokens = _getTokenAmount(weiAmount);

    _preValidatePurchase(beneficiary, tokens);

     
     

    _processPurchase(beneficiary, tokens);
    emit TokensPurchased(
      msg.sender,
      beneficiary,
      weiAmount,
      tokens
    );

     

     
     
  }

   
  function _preValidatePurchase(
    address beneficiary,
    uint256 tokensAmount
  )
    internal view
  {
    require(beneficiary != address(0x0));
    require(tokensAmount > 0);
    require(tokensSold.add(tokensAmount) <= crowdsaleCap);
  }

   
  function _getTokenAmount(uint256 weiAmount)
    internal view returns (uint256)
  {
    return weiAmount.mul(crowdsaleRate);
  }

   
  function _processPurchase(
    address beneficiary,
    uint256 tokenAmount
  )
    internal
  {
    require(transfer(beneficiary, tokenAmount));
  }
}

contract TestMNC2 is ERC20, Burnable, Freezable, Ownable, CrowdsaleToken {
  using SafeMath for uint256;

  string public constant name = "TestMNC2";
  string public constant symbol = "TMNC2";
  uint8 public constant decimals = 18;

  uint256 private constant _initialSupply = 300000000 * (10 ** uint256(decimals));
  uint256 private constant _crodwsaleRate = 20000 * (10 ** uint256(decimals));
  uint256 private constant _crowdsaleCap = 200000000 * (10 ** uint256(decimals));

   
  constructor() public ERC20(_initialSupply) CrowdsaleToken(_crowdsaleCap, _crodwsaleRate) {
    require(msg.sender != 0);
  }
  
   
  function withdrawEther() public onlyOwner {
    uint256 totalBalance = address(this).balance;
    require(totalBalance > 0);
    owner().transfer(totalBalance);
  }
}