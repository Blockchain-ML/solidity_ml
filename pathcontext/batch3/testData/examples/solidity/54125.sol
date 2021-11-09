pragma solidity ^0.4.25;

 
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

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  

  uint256 totalSupply_;
  
  
  address public constant restOfTokens = 0x73193200105449c144281C9E5b4c39B255e13d80;
  uint256 public constant endOfFreezing = 1578528000;  

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    


     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
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
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract PIETAToken is StandardToken
{   
    string public constant name = "Pieta Token";
    string public constant symbol = "PIETA";
    uint public constant decimals = 18;
    
    constructor() public
    {
        totalSupply_ = 2000000 * 10 ** decimals;
        uint ownersPart = 2000000;
        
        balances[msg.sender] = totalSupply_ - ownersPart;
        emit Transfer(0x0, msg.sender, totalSupply_ - ownersPart);
        
        address owners = 0xa5adabc88d6abbfebf9b9348bd53090ab4f5df1b;
        balances[owners] = ownersPart;
        emit Transfer(0x0, owners, ownersPart);
    }
}


contract Crowdsale is Ownable
{   
    using SafeMath for uint256;
    
    uint256 public constant icoStart = 1540425661;  
    uint256 public constant icoEnd = 1543104061;  
    
    enum States { NotStarted, PreICO, ICO, Finished }
    States public state;
    
    PIETAToken public token;
    address public constant wallet = 0xa5adabc88d6abbfebf9b9348bd53090ab4f5df1b;
    uint256 public constant rate = 40;  

    uint256 public constant preIcoSaleLimit = 2000000 * 10 ** 18;  
    
    uint256 public constant minIcoPurchase = 120 finney;  
    uint256 public constant maxIcoPurchase = 5000 ether;

    uint256 public constant softCap = 5000 ether;
    uint256 public constant hardCap = 50000 ether;
    
    uint256 public soldTokens;
    
    address public constant restOfTokens = 0x73193200105449c144281C9E5b4c39B255e13d80;
    
    uint256 public totalBalance;
    
    mapping(address => uint256) internal balances;

    constructor() public
    {
        token = new PIETAToken();
        state = States.NotStarted;
    }
    
    function nextState() onlyOwner public
    {
        require(state == States.NotStarted || state == States.PreICO || state == States.ICO);
        
        if(state == States.NotStarted)
        {
            state = States.PreICO;
        }
        else if(state == States.PreICO)
        {
            state = States.ICO;
        }
        else if(state == States.ICO)
        {
            state = States.Finished;
            
            if(totalBalance >= softCap)
            {
                address contractAddress = this;
                wallet.transfer(contractAddress.balance);
                uint256 tokens = token.balanceOf(contractAddress);
                token.transfer(restOfTokens, tokens);
            }
        }
    }

    function getBonus(uint time, uint256 tokens, uint256 weiAmount) public constant returns (uint256) 
    {
        uint256 bonus = 0;

        if(state == States.ICO)
        {
             

            if(time >= icoStart && time <= (icoStart + 5 days))
            {
                bonus = tokens.mul(15).div(100);
            }
            else if (time >= (icoStart + 6 days) && time <= (icoStart + 10 days))
            {
                bonus = tokens.mul(10).div(100);
            }
            else if(time >= (icoStart + 11 days) && time <= (icoStart + 15 days))
            {
                bonus = tokens.mul(5).div(100);
            }
            else if(time >= (icoStart + 16 days) && time <= (icoStart + 22 days))
            {
                bonus = tokens.mul(3).div(100);
            }
            else if(time >= (icoStart + 22 days) && time < icoEnd)
            {
                bonus = tokens.mul(1).div(100);
            }
            
             
            
            if(weiAmount >= 260 ether)
            {
                bonus = bonus.add(tokens.mul(15).div(100));
            }
            else if(weiAmount >= 130 ether)
            {
                bonus = bonus.add(tokens.mul(10).div(100));
            }
            else if(weiAmount >= 26 ether)
            {
                bonus = bonus.add(tokens.mul(5).div(100));
            }
            else if(weiAmount >= 12500 finney)  
            {
                bonus = bonus.add(tokens.mul(3).div(100));
            }
        }
        
        return bonus;
    }


    function isValidPeriod(uint time) public constant returns (bool)
    {
        if(state == States.ICO)
        {
            if(time >= icoStart && time <= icoEnd) return true;
        }
        
        return true;
    }

    function isReachedHardCap(uint256 weiAmount) public constant returns (bool)
    {
        address contractAddress = this;
        return weiAmount.add(contractAddress.balance) > hardCap;
    }


    function buyTokens(address to, uint256 weiAmount) internal
    {
        uint256 tokens = calcTokens(weiAmount);
        uint256 bonus = getBonus(now, tokens, weiAmount);
        tokens = tokens.add(bonus);
        totalBalance = totalBalance.add(weiAmount);
        token.transfer(to, tokens);
        soldTokens = soldTokens.add(tokens);
        balances[to] = balances[to].add(msg.value);
    }

    function calcTokens(uint256 weiAmount) public constant returns (uint256) 
    {
        return weiAmount.mul(rate);
    }

    function () public payable 
    {
        require(msg.sender != address(0));
      
        
        
        buyTokens(msg.sender, msg.value);
    }

    function refund() public returns (bool)
    {
        require(state == States.Finished);
        require(totalBalance < softCap);
        uint256 value = balances[msg.sender];
        require(value > 0);
        balances[msg.sender] = 0;
        msg.sender.transfer(value);
        return true;
    }
    
     
    function manualTransfer(address to, uint256 weiAmount) onlyOwner public 
    {
        require(to != address(0));
        require(weiAmount > 0);
        
        
        buyTokens(to, weiAmount);
    }
}