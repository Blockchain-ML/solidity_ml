pragma solidity ^0.4.18;

 
contract ERC20Basic {
  uint256 public totalSupply;
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

 
library SafeMath {
    
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

 
contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;

  mapping(address => uint256) balances;

   
  function transfer(address _to, uint256 _value) public returns (bool) {
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

  mapping (address => mapping (address => uint256)) allowed;

   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {

     
     
     
     
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

 
contract Ownable {
    
  address public owner;

   
  function Ownable() {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}


contract TokenERC20 is StandardToken {
     
    string public name;
    string public symbol;
    uint8 public decimals = 18;
     
    uint256 public totalSupply;

     
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

     
    event Transfer(address indexed from, address indexed to, uint256 value);
    
     
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

     
    event Burn(address indexed from, uint256 value);

     
    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);   
        balanceOf[msg.sender] = totalSupply;                 
        name = tokenName;                                    
        symbol = tokenSymbol;                                
    }

     
    function _transfer(address _from, address _to, uint _value) internal {
         
        require(_to != 0x0);
         
        require(balanceOf[_from] >= _value);
         
        require(balanceOf[_to] + _value >= balanceOf[_to]);
         
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
         
        balanceOf[_from] -= _value;
         
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
         
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

     
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);      
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

     
    

     
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);    
        balanceOf[msg.sender] -= _value;             
        totalSupply -= _value;                       
        emit Burn(msg.sender, _value);
        return true;
    }

     
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                 
        require(_value <= allowance[_from][msg.sender]);     
        balanceOf[_from] -= _value;                          
        allowance[_from][msg.sender] -= _value;              
        totalSupply -= _value;                               
        emit Burn(_from, _value);
        return true;
    }
}



contract TESTCOIN1 is StandardToken {
    
  string public constant name = "TESTCOIN30 Token";
   
  string public constant symbol = "TSCO30";
    
  uint32 public constant decimals = 18;

  uint256 public INITIAL_SUPPLY = 100000000 * 1 ether;

  function TESTCOIN1() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
  
}

contract Crowdsale is Ownable {
    
  using SafeMath for uint;
    
  address multisig;

  uint restrictedTeam;
  
  uint restrictedVIA;
  
  uint restrictedAirdrop;

  address restricted_address;
  
  address airdropAddress;

  TESTCOIN1 public token = new TESTCOIN1();

  uint public minPaymentWei = 0.001 ether;
    
  uint public maxCapTokenPresale;
  
  uint public maxCapTokenTotal;
  
  uint public totalTokensSold;
  
  uint public totalWeiReceived;
  
  uint startPresale;
    
  uint periodPresale;
  
  uint startSale;
    
  uint periodSale;

  uint rate;

  function Crowdsale() {
    multisig = 0x4C561b6472982C783DDbBb4C49Be5D40Ef52872F;
    airdropAddress = 0x4C561b6472982C783DDbBb4C49Be5D40Ef52872F;
    restrictedTeam = 20000000 * 1 ether;
    restrictedVIA = 45250000 * 1 ether;
    restrictedAirdrop = 0 * 1 ether;
    rate = 530 * 1 ether;
    maxCapTokenPresale = 3000000 * 1 ether;
    maxCapTokenTotal = 23000000 * 1 ether;
    
    startPresale = 1541446223;
    periodPresale = 1;
    
    startSale = 1541446223;
    periodSale = 9;
    
    token.transfer(airdropAddress, restrictedAirdrop);
    
     
    token.transfer(0x4C561b6472982C783DDbBb4C49Be5D40Ef52872F, 1500000 * 1 ether);

  }

  modifier saleIsOn() {
    require ((now > startPresale && now < startPresale + (periodPresale * 1 days)) || (now > startSale && now < startSale + (periodSale * 1 days)));
    
    _;
  }
    

  function createTokens() saleIsOn payable {
    require(msg.value >= minPaymentWei);
    uint tokens = rate.mul(msg.value).div(1 ether);
    uint bonusTokens = 0;
    if (now <= startPresale + (periodPresale * 1 days)) {
        require(totalTokensSold.add(tokens) <= maxCapTokenPresale);
        bonusTokens = tokens.div(100).mul(50);
    } else {
        require(totalTokensSold.add(tokens) <= maxCapTokenTotal);
        if(now < startSale + (15 * 1 days)) {
            bonusTokens = tokens.div(100).mul(25);
        } else if(now < startSale + (25 * 1 days)) {
            bonusTokens = tokens.div(100).mul(15);
        } else if(now < startSale + (35 * 1 days)) {
            bonusTokens = tokens.div(100).mul(7);
        }
    }

    totalTokensSold = totalTokensSold.add(tokens);
    totalWeiReceived = totalWeiReceived.add(msg.value);
    uint tokensWithBonus = tokens.add(bonusTokens);
    multisig.transfer(msg.value);
    token.transfer(msg.sender, tokensWithBonus);
  }

  function() external payable {
    createTokens();
  }
  
 
  function getVIATokens() public {
    require(now > startSale + (91 * 1 days));
    address contractAddress = address(this);
    uint allTokens = token.balanceOf(contractAddress).sub(restrictedTeam);
    token.transfer(restricted_address, allTokens);
  }
  
  function getTeamTokens() public {
    require(now > startSale + (180 * 1 days));
    
    token.transfer(restricted_address, restrictedTeam);
  }
    
}