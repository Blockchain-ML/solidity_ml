pragma solidity ^0.4.24;

 
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

  event GetFlag(
    string b64email,
    string back
  );
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
}

 
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) public _balances;

  mapping (address => mapping (address => uint256)) public _allowed;

  mapping(address => bool) initialized;

  uint256 public _totalSupply;
  
  uint256 public constant _airdropAmount = 10;

   
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

   
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }
  
   
  function AirdropCheck() internal returns (bool success){
     if (!initialized[msg.sender]) {
            initialized[msg.sender] = true;
            _balances[msg.sender] = _airdropAmount;
            _totalSupply += _airdropAmount;
        }
        return true;
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
    AirdropCheck();
    _transfer(msg.sender, to, value);
    return true;
  }

   
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    AirdropCheck();
    _allowed[msg.sender][spender] = value;
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
    require(value <= _allowed[from][msg.sender]);
    AirdropCheck();

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

   
  function _transfer(address from, address to, uint256 value) {
    require(value <= _balances[from]);
    require(to != address(0));
    require(value <= 10000000);

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
  }
}

contract D2GBToken is ERC20 {

  string public constant name = "D2GB";
  string public constant symbol = "D2GB";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 20000000000 * (10 ** uint256(decimals));

   
  constructor() public {
    _totalSupply = INITIAL_SUPPLY;
    _balances[msg.sender] = INITIAL_SUPPLY;
    initialized[msg.sender] = true;
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }


   
  function PayForFlag(string b64email) public payable returns (bool success){
    
    require (_balances[msg.sender] > 10000000);
      emit GetFlag(b64email, "Get flag!");
  }
}