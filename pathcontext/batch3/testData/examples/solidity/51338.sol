pragma solidity ^0.4.24;

 
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

   
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

   
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

   
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}




contract MinterRole {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private minters;

  constructor() internal {
    _addMinter(msg.sender);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender));
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyMinter {
    _addMinter(account);
  }

  function renounceMinter() public {
    _removeMinter(msg.sender);
  }

  function _addMinter(address account) internal {
    minters.add(account);
    emit MinterAdded(account);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}




contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}


 
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


 
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

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

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 public _totalSupply;

   
  function totalSupply() public view returns (uint256) 
  {
    return _totalSupply;
  }

   
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

   
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

   
  function transfer(address from , address to, uint256 value) public returns (bool) {
    _transfer(from, to, value);
    return true;
  }

   
  function approve(address from, address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    value = value.mul(1 ether);
    _allowed[from][spender] = value;
    emit Approval(from, spender, value);
    return true;
  }

   
  function transferFrom( address makeTransfer, address from, address to, uint256 value ) public returns (bool)
  {
    require(value <= _allowed[from][makeTransfer]);
    _allowed[from][makeTransfer] = _allowed[from][makeTransfer].sub(value);
    _transfer(from, to, value);
    return true;
  }

   
  function increaseAllowance(address from ,address spender, uint256 addedValue) public returns (bool)
  {
    require(spender != address(0));

    addedValue = addedValue.mul(1 ether);
    _allowed[from][spender] = (
      _allowed[from][spender].add(addedValue));
    emit Approval(from, spender, _allowed[from][spender]);
    return true;
  }

   
  function decreaseAllowance(
    address from,
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    subtractedValue = subtractedValue.mul(1 ether);
    _allowed[from][spender] = (
      _allowed[from][spender].sub(subtractedValue));
    emit Approval(from, spender, _allowed[from][spender]);
    return true;
  }

   
  function _transfer(address from, address to, uint256 value) internal {
    value = value.mul(1 ether); 
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

   
  function _mint(address Minter,address account, uint256 value) internal {
    require(account != 0);
     
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }


   
  function _burn(address account, uint256 value) internal {
    value = value.mul(1 ether);
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

   
  function _burnFrom(address makeBurn, address account, uint256 value) internal {
    require(value <= _allowed[account][makeBurn]);

     
     
    _allowed[account][makeBurn] = _allowed[account][makeBurn].sub(value);
    _burn(account, value);
  }
}





 
library SafeERC20 {

  using SafeMath for uint256;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
     
     
     
    require((value == 0) || (token.allowance(msg.sender, spender) == 0));
    require(token.approve(spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance));
  }
}


  






 
contract ReentrancyGuard {

   
  uint256 private _guardCounter;

  constructor() internal {
     
     
    _guardCounter = 1;
  }

   
  modifier nonReentrant() {
    _guardCounter += 1;
    uint256 localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter);
  }

}







 
contract ERC20Detailed is IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

   
  function name() public view returns(string) {
    return _name;
  }

   
  function symbol() public view returns(string) {
    return _symbol;
  }

   
  function decimals() public view returns(uint8) {
    return _decimals;
  }
}








 
contract Pausable is PauserRole {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() public {
    _paused = false;
  }

   
  function paused() public view returns(bool) {
    return _paused;
  }

   
  modifier whenNotPaused() {
    require(!_paused);
    _;
  }

   
  modifier whenPaused() {
    require(_paused);
    _;
  }

   
  function pause(address from) public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused(from);
  }

   
  function unpause(address from) public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused(from);
  }
}


 
contract ERC20Pausable is ERC20, Pausable {

  function transfer(
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(msg.sender,to, value);
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(msg.sender, from, to, value);
  }

  function approve(
    address spender,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(msg.sender, spender, value);
  }

  function increaseAllowance(
    address spender,
    uint addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseAllowance(msg.sender, spender, addedValue);
  }

  function decreaseAllowance(
    address spender,
    uint subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseAllowance(msg.sender, spender, subtractedValue);
  }
}








 
contract ERC20Mintable is ERC20, MinterRole, ERC20Pausable {
   
  function mint(
    
    address Minter,
    address to,
    uint256 value
  )
    public
      onlyMinter whenNotPaused
    returns (bool)
  {
    _mint(Minter, to, value);
    return true;
  }
}


 
contract ERC20Capped is ERC20Mintable {

  uint256 private _cap;

  constructor(uint256 cap)
    public
  {
    require(cap > 0);
    _cap = cap;
  }

   
  function cap() public view returns(uint256) {
    return _cap;
  }

  function Mint(address Minter, address account, uint256 value)  public {
    
    require(totalSupply().add(value) <= _cap);
    super.mint(Minter, account, value);
  }
}





 
contract ERC20Burnable is ERC20, ERC20Pausable {

   
  function burn(address from, uint256 value) public whenNotPaused {
    _burn(from, value);
  }

   
  function burnFrom(address makeBurn, address from, uint256 value) public whenNotPaused {
    _burnFrom(makeBurn, from, value);
  }
}



 
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

   
  constructor() internal {
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

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

   
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


contract DncToken is ERC20Detailed , ERC20Pausable, ERC20Capped , ERC20Burnable , Ownable {

    string public _name = "DinarCoin";
    string public _symbol = "DNC";
    uint8 public _decimals = 18;
    uint256 public _cap = 1500 * 1 ether;

    constructor() 
        ERC20Detailed(_name, _symbol, _decimals)
        ERC20Capped (_cap)
        public {
    }
}



 
contract Crowdsale is ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

   
  DncToken private _token;
 
   
  address private _wallet;

   
   
   
   
  uint256 private _rate;

   
  uint256 private _weiRaised;

   

  bool private _paused;

   
  event TokensPurchased(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

   
  constructor(uint256 rate, address wallet) internal {
    require(rate > 0);
    require(wallet != address(0));

    _rate = rate;
    _wallet = wallet;
    _token = createTokenContract();
    _paused = false;
  }

  function createTokenContract() internal returns (DncToken){
        return new DncToken();
    }
   
   
   

   
  function () external payable {
    buyTokens(msg.sender);
  }

   
  function token() public view returns(DncToken) {
    return _token;
  }

   
  function wallet() public view returns(address) {
    return _wallet;
  }

   
  function rate() public view returns(uint256) {
    return _rate;
  }

   
  function weiRaised() public view returns (uint256) {
    return _weiRaised;
  }

   
  function buyTokens(address beneficiary) public nonReentrant payable  {

    uint256 weiAmount = msg.value;

     
    uint256 tokens = _getTokenAmount(weiAmount);

     
    _weiRaised = _weiRaised.add(weiAmount);

    _preValidatePurchase(beneficiary, weiAmount);
    _processPurchase(beneficiary, tokens);

    emit TokensPurchased(
      msg.sender,
      beneficiary,
      weiAmount,
      tokens
    );

     
    _forwardFunds();
    
  }

   
   
   

   
  function _preValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal
    view
  {
    require(beneficiary != address(0));
    require(weiAmount != 0);
  }

   
  function _postValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal
    view
  {
     
  }

   
  function _deliverTokens(
    address beneficiary,
    uint256 tokenAmount
  )
    internal
  {
    _token.Mint(msg.sender, beneficiary, tokenAmount);
  }

   
  function _processPurchase(
    address beneficiary,
    uint256 tokenAmount
  )
    internal
  {
    _deliverTokens(beneficiary, tokenAmount);
  }

   
    function _updatePurchasingState(
    address beneficiary,
    uint256 weiAmount
  )
    internal
  {
     
  }

   
  function _getTokenAmount(uint256 weiAmount)
    internal view returns (uint256)
  {
    return weiAmount.mul(_rate);
  }

   
  function _forwardFunds() internal {
    _wallet.transfer(msg.value);
  }

  function getTokenAddress() public view returns (address) {
    return _token;
  }

   function Pause() public {
    _token.pause(msg.sender);
    _paused = true;
  }

  function UnPause() public {
    _token.unpause(msg.sender);
    _paused = false;
  }

  function Paused() public view returns(bool){
    return _paused;
  }

  function burnToken(uint256 value) public {
    _token.burn(msg.sender, value);
  }
  
  function burnFromToken(address from, uint256 value) public{
    _token.burnFrom(msg.sender, from, value);
  }

  function approveToken(address spender, uint256 value) public {
      _token.approve(msg.sender, spender,value);
  }
  
  function TotalSupply() public view returns (uint256) {
    return _token.totalSupply();
  }

  function transferToken(address to, uint256 value) public {
    _token.transfer(msg.sender,to,value);
  }

  function transferFromToken(address from, address to, uint256 value ) public {
    _token.transferFrom(msg.sender, from, to, value );
  }
   
  function increaseAllowanceToken(address spender, uint256 addedValue) public {
    _token.increaseAllowance(msg.sender, spender, addedValue);
  }

  function decreaseAllowanceToken(address spender,uint256 subtractedValue) public {
    _token.decreaseAllowance(msg.sender, spender, subtractedValue);
  }

    function mintToken(address to, uint256 value)  public  {
      
        _token.Mint(msg.sender, to, value);
    }
}

contract MintDnc is Crowdsale{

    uint256 private _rate = 1000;
    address private _wallet = 0x88951e18fEd6D792d619B4A472d5C0D2E5B9b5F0;

    constructor()
        Crowdsale(_rate, _wallet)
        public
    {}

    function createTokenContract() internal returns (DncToken){
        return new DncToken();
    }

  

}