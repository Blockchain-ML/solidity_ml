pragma solidity ^0.4.24;

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

library WadMath {
  uint constant WAD = 10 ** 18;

  function wmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), WAD / 2) / WAD;
  }

  function wdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, WAD), y / 2) / y;
  }
}

 

contract ERC20 {
  using SafeMath for uint;

  string _name;
  string _symbol;
  uint8 _decimals = 18;

  uint _totalSupply;

  mapping (address => uint) _balanceOf;
  mapping (address => mapping (address => uint)) _allowance;

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);

  constructor(string name, string symbol) public {
    _totalSupply = 0;
    _name = name;
    _symbol = symbol;
  }

   

  function name() public view returns (string) {
    return _name;
  }

   

  function symbol() public view returns (string) {
    return _symbol;
  }

   

  function decimals() public view returns (uint8) {
    return _decimals;
  }

   

  function totalSupply() public view returns (uint) {
    return _totalSupply.sub(_balanceOf[address(0)]);
  }

   

  function balanceOf(address owner) public view returns (uint256 balance) {
    return _balanceOf[owner];
  }

   

  function allowance(address owner, address spender) public view returns (uint256 remaining) {
    return _allowance[owner][spender];
  }

   

  function _transfer(address from, address to, uint value) internal {
    require(_balanceOf[from] >= value);
    _balanceOf[from] = _balanceOf[from].sub(value);
    _balanceOf[to] = _balanceOf[to].add(value);
    emit Transfer(from, to, value);
  }

   
 
  function transfer(address to, uint value) public returns (bool success) {
    _transfer(msg.sender, to, value);
    return true;
  }

   

  function transferFrom(address from, address to, uint value) public returns (bool success) {
    require(value <= _allowance[from][msg.sender]);
    _allowance[from][msg.sender] = _allowance[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

   

  function approve(address spender, uint value) public returns (bool success) {
    _allowance[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }
}

 

 contract Owned {

  address public _owner;
  address public _ownerCandidate;

  event OwnershipTransferred(address indexed _from, address indexed _to);

   

  constructor() public {
    _owner = msg.sender;
  }


   

  modifier onlyOwner {
    require(msg.sender == _owner);
    _;
  }

   
  function transferOwnership(address candidate) public onlyOwner {
    _ownerCandidate = candidate;
  }

   

  function acceptOwnership() public {
    require(msg.sender == _ownerCandidate);
    emit OwnershipTransferred(_owner, _ownerCandidate);
    _owner = _ownerCandidate;
    _ownerCandidate = address(0);
  }
}

 

contract Pausable {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;
  address private _pauser;

  constructor() internal {
    _paused = false;
    _pauser = msg.sender;
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

   
  modifier onlyPauser() {
    require(msg.sender == _pauser);
    _;
  }

   
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

   
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }

   
  function setPauser(address pauser) public onlyPauser {
    _pauser = pauser;
  }
}

 
 
contract TweetCoin is ERC20, Owned, Pausable {
  using SafeMath for uint;
  using WadMath for uint;

   

  constructor() ERC20("TweetCoin", "TWC") Owned() Pausable() public {}

   

  event Purchase(address indexed from, address indexed to, uint eth, uint value);

   

  function tokenMultiplier() public view returns (uint tokens) {
    return SafeMath.add(1 ether, WadMath.wdiv(1 ether, (_totalSupply.wdiv(500 ether)).add(1 ether)));
  }

   

  function buy(address recepient) payable public whenNotPaused returns (uint amount) {
    amount = tokenMultiplier().wmul(msg.value);
    _balanceOf[recepient] = _balanceOf[recepient].add(amount);
    _totalSupply = _totalSupply.add(amount);
    emit Purchase(msg.sender, recepient, msg.value, amount);

     
    emit Transfer(0x0, recepient, amount);

    return amount;
  }

   

  function () payable public {
    buy(msg.sender);
  }

   

  event Withdrawal(address indexed recepient, uint amount);

   

  function withdraw(address recepient, uint amount) public onlyOwner {
    require(amount <= address(this).balance);
    recepient.transfer(amount);
    emit Withdrawal(recepient, amount);
  }

}