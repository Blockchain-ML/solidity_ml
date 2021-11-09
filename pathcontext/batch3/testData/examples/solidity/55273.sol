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

  uint256 private _totalSupply;

   
  function totalSupply() public view returns (uint256) {
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

   
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

   
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

   
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

   
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
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

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

   
  function _transfer(address from, address to, uint256 value) internal {
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

   
  function _mint(address account, uint256 value) internal {
    require(account != address(0));

    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

   
  function _burn(address account, uint256 value) internal {
    require(account != address(0));

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

   
  function _burnFrom(address account, uint256 value) internal {
     
     
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
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

 
contract ERC20Escrow is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  event Deposited(address indexed payee, uint256 weiAmount);
  event Withdrawn(address indexed payee, uint256 weiAmount);

  mapping(address => uint256) internal _deposits;

  ERC20 internal _token;

  constructor(address contractAddress) public {
      require(contractAddress != address(0));
      _token = ERC20(contractAddress);
  }

   
  function depositsOf(address payee) external view returns (uint256) {
    return _deposits[payee];
  }

   
  function deposit(address payee, uint256 amount) external onlyOwner {
    _deposit(payee, amount);
  }

   
  function _deposit(address payee, uint256 amount) internal {
    require(_token.allowance(payee, this) >= amount
      && (_token.balanceOf(payee) >= amount) );

    _token.safeTransferFrom(payee, this, amount);

    _deposits[payee] = _deposits[payee].add(amount);

    emit Deposited(payee, amount);
  }

   
  function withdraw(address payee) external onlyOwner {
    _withdraw(payee);
  }

   
  function _withdraw(address payee) internal {
    uint256 _deposit = _deposits[payee];

    _deposits[payee] = 0;

    _token.safeTransfer(payee, _deposit);

    emit Withdrawn(payee, _deposit);
  }
}



 
contract Exclusive is ERC20Escrow {

  enum State { Active, Refunding, Closed }

  event RefundsClosed();
  event RefundsEnabled();

  State private _state;

  string private _name;

  uint256 private _minStake;

  address[] private _stakers;

  constructor(address contractAddress, string name, uint256 minStake)
    public
    ERC20Escrow(contractAddress)
  {
      _name = name;
      _minStake = minStake;

      _state = State.Active;
  }

   
  function state() public view returns (State) {
    return _state;
  }

   
  function name() external view returns(string) {
    return _name;
  }

   
  function minStake() external view returns(uint256) {
    return _minStake;
  }

   
  function setMinStake(uint256 newMinStake) external onlyOwner {
    _minStake = newMinStake;
  }

   
  function canAccessExclusive(address payee) external view returns(bool) {
    return _deposits[payee] >= _minStake;
  }

   
  function beneficiaryDeposit(uint256 amount) external {
    require(_state == State.Active);
    _deposit(msg.sender, amount);
  }

   
  function beneficiaryWithdraw() external {
    require(_state == State.Refunding || _state == State.Closed);
    _withdraw(msg.sender);
  }

   
  function endExclusive() external onlyOwner {
    require(_state == State.Active);
    _state = State.Refunding;
    emit RefundsEnabled();
  }

   
  function close() external onlyOwner {
    require(_state == State.Active || _state == State.Refunding);
    _state = State.Closed;
    for (uint i = 0; i<_stakers.length; i++) {
      if(_deposits[_stakers[i]] != 0) {
        _withdraw(_stakers[i]);
      }
    }
    emit RefundsClosed();
  }

   
  function deposit(address payee, uint256 amount) external onlyOwner {
    require(_state == State.Active);
    _deposit(payee, amount);
  }

   
  function withdraw(address payee) external onlyOwner {
    require(_state == State.Refunding || _state == State.Closed);
    _withdraw(payee);
  }

   
  function _deposit(address payee, uint256 amount) internal {
    if(_deposits[payee] == 0) {
      _stakers.push(payee);
    }
    ERC20Escrow._deposit(payee, amount);
  }

   
  function _withdraw(address payee) internal {
    if(_deposits[payee] != 0) {
      for (uint i = 0; i<_stakers.length -1; i++) {
        if(_stakers[i] == payee) {
          _stakers[i] = _stakers[_stakers.length - 1];
          break;
        }
      }
      delete _stakers[_stakers.length - 1];
      _stakers.length--;

      ERC20Escrow._withdraw(payee);
    }
  }

}