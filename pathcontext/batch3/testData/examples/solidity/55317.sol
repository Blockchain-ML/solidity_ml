pragma solidity ^0.4.13;
 
 
 


contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
 

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
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
 
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
 
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
 
}
 
contract StandardToken is ERC20, BasicToken {
 
  mapping (address => mapping (address => uint256)) allowed;
 
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
 
  function approve(address _spender, uint256 _value) returns (bool) {
 
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
 
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
 
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
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
 
 
contract MintableToken is StandardToken, Ownable {
    
  event Mint(address indexed to, uint256 amount);
  
  function mint(address _to, uint256 _amount) onlyOwner returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }
  
}
 
contract iUventaToken is MintableToken {
    
    string public constant name = "iUventa022";
    
    string public constant symbol = "iUv022";
    
    uint32 public constant decimals = 18;
    
}
 
 
contract Thankfulness is Ownable {
    
    using SafeMath for uint;
    
    address multisig;
 
    address restricted;
 
    iUventaToken public token = new iUventaToken();
 
    uint start;
 
    uint emissionRate;
    uint TokenSumm;
    uint Emission;
    uint EmissionGrowthCoefficient;
    uint EmissionRateCoefficient;
    string pause;    
 
    function Thankfulness() {

        multisig = 0x26c36256d607A30C758995EF8CD062Ab28d2d527;
        restricted = 0xA47DEb9A9dbAab3EA48398D97071f27285B241e4;
    
     
     
     
     
     

    }
 
    modifier EmissionIsOn() {
      require(emissionRate > 0);
      _;
    }
    modifier Paused() {
      require(keccak256(pause) != keccak256("On"));
      _;
    }  


    event MintedTokens (uint _value);
    event EmissionGrows (uint _value);
    event EmissionRateDecrease (uint _value);

    function createTokens() EmissionIsOn Paused payable {
    uint tokens = emissionRate.mul(msg.value).div(1 ether);
    uint hundred = 100;


    uint DeltaEmission = (Emission).sub(TokenSumm);

      if (DeltaEmission > tokens) {
        multisig.transfer(msg.value);
         
        TokenSumm = (TokenSumm).add(tokens);
        token.mint(msg.sender, tokens);
        token.mint(restricted, tokens);
        MintedTokens(tokens);
      }
      else if (DeltaEmission == tokens){
        multisig.transfer(msg.value);
        token.mint(msg.sender, tokens);
        token.mint(restricted, tokens);
        MintedTokens(tokens);   
        Emission=Emission.mul(EmissionGrowthCoefficient.add(hundred)).div(hundred);
        EmissionGrows(Emission);
        emissionRate = emissionRate.mul((hundred).sub(EmissionRateCoefficient)).div(hundred);
        EmissionRateDecrease(emissionRate);        
        TokenSumm=0;
      }
      else {
        token.mint(msg.sender, DeltaEmission);
        token.mint(restricted, DeltaEmission);
        MintedTokens(DeltaEmission);
        Emission=Emission.mul(EmissionGrowthCoefficient.add(hundred)).div(hundred);
        EmissionGrows(Emission);

        uint UsedValue = DeltaEmission.mul(1 ether).div(emissionRate);

        uint balance = msg.value.sub(UsedValue);
        emissionRate = emissionRate.mul((hundred).sub(EmissionRateCoefficient)).div(hundred);
        EmissionRateDecrease(emissionRate);

        tokens = emissionRate.mul(balance).div(1 ether);
        DeltaEmission = Emission;
        
        if (DeltaEmission > tokens) {
          multisig.transfer(msg.value);
          TokenSumm = tokens;
          token.mint(msg.sender, tokens);
          token.mint(restricted, tokens);
          MintedTokens(tokens);
        }
        else if (DeltaEmission == tokens){
          multisig.transfer(msg.value);
          token.mint(msg.sender, tokens);
          token.mint(restricted, tokens);
          MintedTokens(tokens);   
          Emission=Emission.mul(EmissionGrowthCoefficient.add(hundred)).div(hundred);
          EmissionGrows(Emission);
          emissionRate = emissionRate.mul((hundred).sub(EmissionRateCoefficient)).div(hundred);
          EmissionRateDecrease(emissionRate);          
          TokenSumm=0;
        }
        else {
          uint UsedValue2 = DeltaEmission.mul(1 ether).div(emissionRate);
          multisig.transfer(UsedValue2.add(UsedValue)); 
          msg.sender.transfer((msg.value).sub(UsedValue2).sub(UsedValue));
          token.mint(msg.sender, DeltaEmission);
          token.mint(restricted, DeltaEmission);  
          MintedTokens(DeltaEmission);
          Emission=Emission.mul((EmissionGrowthCoefficient).add(hundred)).div(hundred);
          EmissionGrows(Emission);
          emissionRate = emissionRate.mul((hundred).sub(EmissionRateCoefficient)).div(hundred);
          EmissionRateDecrease(emissionRate);          
          TokenSumm=0;
        }
      }
    }
 
    function() external payable {
        createTokens();
    }

    event ChangeRate (uint _value);
    event ChangeEmission (uint _value);
    event ChangeEmissionCoefficient (uint _value);    
    event ChangeRateCoefficient (uint _value); 
    event Pause (string _value);


    function ChangeEmissionRate(uint n) onlyOwner {    
      emissionRate = n;
      ChangeRate(emissionRate);
    }

    function ChangeEmissionSumm(uint n) onlyOwner {     
      Emission = n;
      ChangeEmission(Emission);
    }

    function ChangeEmissionGrowthCoefficient(uint8 n) onlyOwner {     
      EmissionGrowthCoefficient = n;
      ChangeEmissionCoefficient(EmissionGrowthCoefficient);
    }  

    function ChangeEmissionRateCoefficient(uint8 n) onlyOwner {    
      EmissionRateCoefficient = n;
      ChangeRateCoefficient(EmissionRateCoefficient);
    }    

    function PauseOn(uint8 n) onlyOwner {    
      pause = "On";
      Pause(pause);
    }    

    function PauseOff(uint8 n) onlyOwner {     
      pause = "Off";
      Pause(pause);
    }        
    
}