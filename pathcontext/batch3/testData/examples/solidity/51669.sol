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

contract ERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) _balances;

  mapping (address => mapping (address => uint256)) _allowed;

  uint256 _totalSupply;

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

   
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

   
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

   
  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }

   
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

   
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
     
     
     
    require((value == 0) || (_allowed[msg.sender][spender] == 0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

   
  function transferFrom(address from, address to, uint256 value) public returns (bool) {

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

   
  function burn(uint256 value) public {
    _burn(msg.sender, value);
  }

   
  function burnFrom(address from, uint256 value) public {
    _burnFrom(from, value);
	}

   
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

   
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
  	uint256 value;
    require(spender != address(0));
     
    if (subtractedValue >= _allowed[msg.sender][spender])
    	value = 0;
  	else
  		value = _allowed[msg.sender][spender].sub(subtractedValue);

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

   
   
   


   
  function _transfer(address from, address to, uint256 value) internal {
    require(to != address(0));
    require(value > 0);

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
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

 
contract Ownable {
  address internal _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
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

   
  function isOwner() internal view returns(bool) {
    return msg.sender == _owner;
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

contract Startable is ERC20, Ownable {
  bool internal _isTransferable = false;
  address internal _crowdsaleAddress;
    

function showCrowdsaleAddress() public view returns(address) {
    return _crowdsaleAddress;
  }
    
   
  function setCrowdsaleAddress(address crowdsaleAddress) public onlyOwner {
     
    require(_crowdsaleAddress == 0x0);
    require(crowdsaleAddress != 0x0);
    _crowdsaleAddress = crowdsaleAddress;
    _balances[_crowdsaleAddress] = _totalSupply;
  }

   
   
  modifier onlyWhenTransferEnabled() {
    if (!_isTransferable) {
      require(msg.sender == _owner || msg.sender == _crowdsaleAddress);
    }
    _;
  }

  function enableTransfer() public onlyOwner{
    _isTransferable = true;
  }

  function transfer(address to, uint256 value) public onlyWhenTransferEnabled returns (bool) {
    return super.transfer(to, value);
  }

  function transferFrom(address from, address to, uint256 value) public onlyWhenTransferEnabled returns (bool) {
    return super.transferFrom(from, to, value);
  }

  function burn(uint256 value) public onlyWhenTransferEnabled {
    return super.burn(value);
  }

  function burnFrom(address from, uint256 value) public onlyWhenTransferEnabled {
    return super.burnFrom(from, value);
  }

}

contract RD2Token is Startable {
	string internal _name;
  string internal _symbol;
  uint8 internal _decimals;
  bool internal _isTransferable = false;

  constructor(string name, string symbol, uint8 decimals, uint256 totalSupply) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  	_totalSupply = totalSupply;
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