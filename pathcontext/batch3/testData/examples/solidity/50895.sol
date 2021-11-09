pragma solidity ^ 0.4.25;

 

 

 
 
 
 
 
 
 
 
 
 
 
 

 
contract Ownable {

  address public owner;


   

constructor() public {owner = msg.sender;}


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
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
 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value)public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value)public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20 {

    function transfer(address _to, uint _value) public returns (bool) {
         
        if (balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

  function balanceOf(address _owner) public constant returns (uint) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint public totalSupply;
}

contract UnlimitedAllowanceToken is StandardToken {

    uint constant MAX_UINT = 2**256 - 1;
    
     
     
     
     
     
    function transferFrom(address _from, address _to, uint _value)
        public
        returns (bool)
    {
        uint allowance = allowed[_from][msg.sender];
        if (balances[_from] >= _value
            && allowance >= _value
            && balances[_to] + _value >= balances[_to]
        ) {
            balances[_to] += _value;
            balances[_from] -= _value;
            if (allowance < MAX_UINT) {
                allowed[_from][msg.sender] -= _value;
            }
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }
}

contract IDMCOSAS is Ownable, UnlimitedAllowanceToken {

    string public constant name = "IDMCOSAS";
   
  string public constant symbol = "MCS";
    
  uint32 public constant decimals = 18;
  
  uint256 public totalSupply = (10 ** 8) * (10 ** 18);  

    function MCS() public onlyOwner {
        balances[msg.sender] = totalSupply;
    }
}

contract PRESALE_IDMCOSAS is Ownable {   
 
  using SafeMath for uint;

  address multisig;

  uint restrictedPercent;

  address restricted;

  IDMCOSAS public token;

  uint public start;

  uint public period;

  uint256 public totalSupply;
      
  uint public hardcap;

  uint public softcap;
  
  address public wallet;

  uint256 public rate;

  uint256 public weiRaised;



  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

 
 
 
  function PRESALE () public  {
	 token = IDMCOSAS(0x005dd5f95e135cd739945d50113fbe492c43bf2b4b);
     multisig = 0xd0C7eFd2acc5223c5cb0A55e2F1D5f1bB904035d;
     restricted = 0xd0C7eFd2acc5223c5cb0A55e2F1D5f1bB904035d;
     restrictedPercent = 15;
     rate = 189000000000000000000;
     start = 1538352000;
     period = 15;
     hardcap = 2000000000000000000000000;
     softcap = 498393000000000000000000;
	 totalSupply = (10 ** 8) * (10 ** 18);  
	 wallet = 0xd0C7eFd2acc5223c5cb0A55e2F1D5f1bB904035d;
    }

    
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);

    uint256 weiAmount = msg.value;
    uint256 updatedWeiRaised = weiRaised.add(weiAmount);
     
    uint256 tokens = weiAmount.mul(rate);

        
    weiRaised = updatedWeiRaised;

    token.transfer(beneficiary, tokens);
    emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

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

 function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
    return weiAmount.mul(rate); }
    
  function() external payable {
    buyTokens(msg.sender);
    BonusTokens();
  }

}