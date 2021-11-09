pragma solidity ^0.4.24;


 

 
 contract Ownable {
  
  address private _owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred( address indexed previousOwner, address indexed newOwner);

   
  
  constructor() public {_owner = msg.sender;}

   
  
  function owner() public view returns(address) {return _owner;}

   
  
  modifier onlyOwner() {require(isOwner());
  _;}

   
  
  function isOwner() public view returns(bool) {return msg.sender == _owner;}

   
   
  function renounceOwnership() public onlyOwner {
  emit OwnershipRenounced(_owner);
    _owner = address(0);}

   
   
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);}

   
   
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;}
}

 

 library SafeMath {

   
  
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
	
    if (a == 0) {return 0;}

    uint256 c = a * b;
    require(c / a == b);
    return c;}

   
 
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); 
	 
    uint256 c = a / b;
     
	 
    return c;}

   
  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;}

   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;}

   
  
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;}
}

 
 
library SafeERC20 {

function safeTransfer(IERC20 token,address to, uint256 value) internal{
    require(token.transfer(to, value));}

  function safeTransferFrom(IERC20 token, address from,address to,uint256 value) internal {
    require(token.transferFrom(from, to, value));}

  function safeApprove(IERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));}
}

 
interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender,uint256 value);
}

 
 
 contract ERC20 is IERC20 {
 
 using SafeMath for uint256;
  
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;
  
  uint256 private _totalSupply;

   
  function totalSupply() public view returns (uint256) { return _totalSupply; }

   
  
  function balanceOf(address owner) public view returns (uint256) { return _balances[owner];}

   
  
  function allowance( address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender]; }

   
  
  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= _balances[msg.sender]);
    require(to != address(0));
    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;  }

   
  
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true; }

   
  
  function transferFrom(address from, address to, uint256 value ) public returns (bool) {
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));
    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    emit Transfer(from, to, value);
    return true; }

   
  
  function increaseAllowance( address spender,  uint256 addedValue ) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;  }

   
 
 function decreaseAllowance( address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = ( _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;}

   
   
  function _burn(address account, uint256 amount) internal {
    require(account != 0);
    require(amount <= _balances[account]);
    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount); }

   
   
  function _burnFrom(address account, uint256 amount) internal {
    require(amount <= _allowed[account][msg.sender]);

     
	
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub( amount);
    _burn(account, amount); }
}

 

 contract ERC20Burnable is ERC20 {

   
  
  function burn(uint256 value) public { _burn(msg.sender, value); }

   
   
  function burnFrom(address from, uint256 value) public { _burnFrom(from, value);}

   
  
  function _burn(address who, uint256 value) internal { super._burn(who, value); }
}

 
contract MCSToken is Ownable, IERC20, ERC20Burnable {
  using SafeERC20 for IERC20;
  mapping (address => uint256) public balances;
  
  string public constant name = "IDMCOSAS";
   
  string public constant symbol = "MCS";
    
  uint32 public constant decimals = 18;
  
  uint256 public totalSupply = (10 ** 8) * (10 ** 18);  

    function MCS() public onlyOwner {
        balances[msg.sender] = totalSupply;
    }
}



 
contract Crowdsale is Ownable {
  using SafeMath for uint256;
 
  address multisig;

  uint restrictedPercent;

  address restricted;
   
  MCSToken public token;

  uint public start;

  uint public period;

  uint256 public totalSupply;
      
  uint public hardcap;

  uint public softcap;
    
  address public wallet;
  
   
   
   
  uint256 public rate;
   
  uint256 public weiRaised;

   
   
  event TokensPurchased(address indexed purchaser,address indexed beneficiary,uint256 value,uint256 amount);

   
 
 
 

  function PRESALE ( ) public  {

     token = MCSToken(0x2Af6c5c925127b59Cfa4b6e2b263EBD4Ef2F7935);
     multisig = 0xd0C7eFd2acc5223c5cb0A55e2F1D5f1bB904035d;
     restricted = 0xd0C7eFd2acc5223c5cb0A55e2F1D5f1bB904035d;
     restrictedPercent = 15;
     rate = 189;
     start = 1538352000;
     period = 15;
     hardcap = 2000000000000000000000000;
     softcap = 498393000000000000000000;
	 totalSupply = token.totalSupply(); 
	 wallet = 0xd0C7eFd2acc5223c5cb0A55e2F1D5f1bB904035d;
    }  

   
   
   
 
  function buyTokens(address beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(beneficiary, weiAmount);

     
	
    uint256 tokens = _getTokenAmount(weiAmount);

     
	
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(beneficiary, tokens);
    emit TokensPurchased( msg.sender, beneficiary, weiAmount, tokens);
    _updatePurchasingState(beneficiary, weiAmount);
    _forwardFunds();
    _postValidatePurchase(beneficiary, weiAmount);
  }
  
   modifier saleIsOn() {
    require(now > start && now < start + period * 1 days);
    _;
  }

  function BonusTokens() public saleIsOn payable {
    multisig.transfer(msg.value);
    uint tokens = rate.mul(msg.value).div(1 ether);
    uint bonusTokens = 0;
    if(now < start + (period * 1 days).div(4)) {
      bonusTokens = tokens.div(4);
    } else if(now >= start + (period * 1 days).div(4) && now < start + (period * 1 days).div(4).mul(2)) {
      bonusTokens = tokens.div(10);
    } else if(now >= start + (period * 1 days).div(4).mul(2) && now < start + (period * 1 days).div(4).mul(3)) {
      bonusTokens = tokens.div(20);
    }
    uint tokensWithBonus = tokens.add(bonusTokens);
    token.transfer(msg.sender, tokensWithBonus);
    uint restrictedTokens = tokens.mul(restrictedPercent).div(100 - restrictedPercent);
    token.transfer(restricted, restrictedTokens);
  }

   
   
   
     
   
   function _preValidatePurchase( address beneficiary, uint256 weiAmount ) internal {
    require(beneficiary != address(0));
    require(weiAmount != 0); }

   
   
  function _postValidatePurchase( address beneficiary, uint256 weiAmount) internal {
     
	}

   
   
  function _updatePurchasingState( address beneficiary, uint256 weiAmount) internal {
     
  }
  
   
   
  function _deliverTokens( address beneficiary, uint256 tokenAmount) internal {
    
   token.transfer(beneficiary, tokenAmount); }

   
   
  function _processPurchase( address beneficiary, uint256 tokenAmount) internal {
    _deliverTokens(beneficiary, tokenAmount); }



   
  
  function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
    return weiAmount.mul(rate); }

   
  
  function _forwardFunds() internal {
    wallet.transfer(msg.value);}


}