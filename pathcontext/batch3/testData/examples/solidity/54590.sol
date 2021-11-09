pragma solidity ^0.4.24;


 
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

   
  function add(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = true;
  }

   
  function remove(Role storage role, address account) internal {
    require(account != address(0));
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

  constructor() public {
    minters.add(msg.sender);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender));
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyMinter {
    minters.add(account);
    emit MinterAdded(account);
  }

  function renounceMinter() public {
    minters.remove(msg.sender);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}


library SafeMathMain {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
     
    uint256 c = a / b;
     
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}







contract ERC20Basic {
  uint256 public totalSupply;
  uint8   public decimals;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
contract BasicToken is ERC20Basic {
  using SafeMathMain for uint256;

  mapping(address => uint256) balances;

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
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

   
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

     
  function _mint(address account, uint256 amount) internal {
    require(account != 0);
    totalSupply = totalSupply.add(amount);
    balances[account] = balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }
}










 
contract ERC20Mintable is StandardToken, MinterRole {
  event MintingFinished();

  bool private _mintingFinished = false;

  modifier onlyBeforeMintingFinished() {
    require(!_mintingFinished);
    _;
  }

   
  function mintingFinished() public view returns(bool) {
    return _mintingFinished;
  }

   
  function mint(
    address to,
    uint256 amount
  )
    public
    onlyMinter
    onlyBeforeMintingFinished
    returns (bool)
  {
    _mint(to, amount);
    return true;
  }

   
  function finishMinting()
    public
    onlyMinter
    onlyBeforeMintingFinished
    returns (bool)
  {
    _mintingFinished = true;
    emit MintingFinished();
    return true;
  }
}


contract ERC20Demo is ERC20Mintable {
  string public name        = "ERC20Demo";
  string public symbol      = "ERC20Demo";
  uint   public decimals    = 18;
  uint   public totalSupply = 0;

  function contructor() {
    
  }


}



contract Main  {
  using SafeMathMain for uint256;

  address public admin;

  event Contribution(address indexed _token, address _contributor, uint256 _amount, uint256 _time);

  mapping(address => bool) public allowedToken;

  address MainERC20 = 0x0;


  
  function Main() {

  admin = msg.sender;



   
  MainERC20 = new ERC20Demo();
  
    
  }
 
  
   

  function fund(uint _amount, address token) {
   

     
    if (!allowedToken[token]) {
    revert();
    }

     
    ERC20 depositToken = ERC20(token);

    
     

    bool success = depositToken.transferFrom(msg.sender, address(this), _amount);

    if (!success) { revert(); }

    if (!allowedToken[token]) {
    revert();
    }



     
    uint to98 = (_amount.mul(98)).div(100);
     
    uint to2 = _amount.sub(to98);

     

     

    
     

    ERC20Demo mainErc20 = ERC20Demo(MainERC20);

    success = mainErc20.mint(msg.sender,to98);
    if (!success) {
    revert();
    }

     
    success = mainErc20.mint(address(this),to2);
    if (!success) {
    revert();
    }

    


    emit Contribution(msg.sender, token, _amount, now);



    
  }

  function  () payable {
     
    revert();
  }

   
  function register(address erc20token) {

     
    require(!allowedToken[erc20token]);

     
    require(msg.sender == admin);  

  
     
    allowedToken[erc20token] = true;


  }

  

  function unregister(address erc20token) {

    
    require(allowedToken[erc20token]);

     
    require(msg.sender == admin);  

      
    allowedToken[erc20token] = false;


  }


    
  function winthdraw(address _tokenToWith, address _destination, uint _amountTo) returns (bool) {

     
    require(msg.sender == admin);  

     

 
     

     
    ERC20 erc20 = ERC20(_tokenToWith);

     

    require(erc20.transfer(_destination, _amountTo));
    

    return true;

    
   



  }

 

     
function showMainERC20() constant returns (address) {
      return MainERC20;
    }


}