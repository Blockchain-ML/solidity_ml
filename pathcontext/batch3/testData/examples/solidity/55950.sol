pragma solidity ^0.4.4;


 
 
 
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


 
 
 
 
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

 
 
 
 
 
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


 
 
 
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

 
contract Disableable is Owned {
  event Enable();
  event Disable();

  bool public isEnabled = true;


   
  modifier enabled {
    require(isEnabled);
    _;
  }

   
  modifier disabled {
    require(!isEnabled);
    _;
  }

   
  function enable() onlyOwner disabled returns (bool) {
    isEnabled = true;
    emit Enable();
    return true;
  }

   
  function disable() onlyOwner enabled returns (bool) {
    isEnabled = false;
    emit Disable();
    return true;
  }
}


 
contract PayableToken is Disableable {
  event PaymentEnable();
  event PaymentDisable();

  bool public isPaymentEnabled = true;


   
  modifier paymentEnabled {
    require(isPaymentEnabled);
    _;
  }

   
  modifier paymentDisabled {
    require(!isPaymentEnabled);
    _;
  }

   
  function paymentEnable() onlyOwner paymentDisabled returns (bool) {
    isPaymentEnabled = true;
    emit PaymentEnable();
    return true;
  }

   
  function paymentDisable() onlyOwner paymentEnabled returns (bool) {
    isPaymentEnabled = false;
    emit PaymentDisable();
    return true;
  }
}


 
 
 
 
contract BaseToken is ERC20Interface, PayableToken {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


     
     
     
    function totalSupply() public view returns (uint) {
        return totalSupply.sub(balances[address(0)]);
    }


     
     
     
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


     
     
     
     
     
    function transfer(address to, uint tokens) public validDestination(to) enabled returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
    function approve(address spender, uint tokens) public returns (bool success) {
        require((tokens == 0) || (allowed[msg.sender][spender] == 0));
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, uint tokens)  public validDestination(to) enabled returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


     
     
     
     
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


     
     
     
     
     
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }
    
    modifier validDestination(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }


     
     
     
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}

contract LoveyToken is BaseToken {
    
    uint averageEthPrice = 550000;  
    uint lastAmount = 0;
    uint totalEth = 0;
    uint integers = 12;
    uint totalCapInDollars = 10**uint(5);  
    bool isTotalCapReached = false;
    uint totalTokensSold = 0;
    
    uint[] tokenCaps = new uint[](5);
    uint[] tokenDisc = new uint[](5);
    uint totalTokenCap;
    
    
    constructor() public {
        symbol = "Lovey";
        name = "Lovey Token";
        decimals = 6;
        totalSupply = 1 * 10**uint(integers + decimals);
        balances[owner] = totalSupply;
        
        totalTokenCap = totalSupply / 2;
        
        tokenCaps[0] = totalSupply / 100;  
        tokenCaps[1] = tokenCaps[0] * 2;  
        tokenCaps[2] = tokenCaps[0] * 10;  
        tokenCaps[3] = tokenCaps[0] * 15;   
        tokenCaps[4] = totalTokenCap - tokenCaps[0] - tokenCaps[1] - tokenCaps[2] - tokenCaps[3];  
        
        tokenDisc[0] = 1000;
        tokenDisc[1] = 500;
        tokenDisc[2] = 200;
        tokenDisc[3] = 125;
        tokenDisc[4] = 100;
        
        emit Transfer(address(0), owner, totalSupply);
    }
    
    
    function () public payable enabled paymentEnabled {
        if(isTotalCapReached) throw;
        if (msg.value == 0) { return; }
        
        uint rate = ethToLoveyRate();
        uint amount = (msg.value * rate) / (10**uint(18 - decimals));
        
        if(amount == 0) throw;
        if(amount < (dollarToLoveyRate() * 10)) throw;  
        
        require(balances[owner] >= amount);
        
        lastAmount = amount;
        totalEth = totalEth + msg.value;
        
        uint totalBoughtAmount = 0;
        
        do
        {
            if(amount == 0) break;
            
            uint8 stage = getStage();
            uint discount = tokenDisc[stage];
            uint amountWithDiscount = (amount * discount) / 100;
            
            if(tokenCaps[stage] < amountWithDiscount)
                amountWithDiscount = tokenCaps[stage];
            
            if(amountWithDiscount == 0) break;
            
            tokenCaps[stage] = tokenCaps[stage].sub(amountWithDiscount);
            totalBoughtAmount += amountWithDiscount;
            
            if(amount > ((amountWithDiscount * 100) / discount))
                amount = amount.sub((amountWithDiscount * 100) / discount);
            else
                amount = 0;
            
            require(balances[owner] >= amountWithDiscount);
            balances[owner] = balances[owner].sub(amountWithDiscount);
            balances[msg.sender] = balances[msg.sender].add(amountWithDiscount);
            totalTokensSold += amountWithDiscount;
            
        }while((stage < (tokenCaps.length - 1)) && (amount > 0));
        
        if(totalBoughtAmount == 0) throw;
        lastAmount = totalBoughtAmount;
        
        emit Transfer(owner, msg.sender, totalBoughtAmount);  
        
         
        owner.transfer(msg.value);   
        
        if(totalTokensSold >= totalTokenCap)
            isTotalCapReached = true;
    }
    
    function getStage() returns (uint8) {
        for(uint8 i = 0; i < tokenCaps.length; i++) {
            if(tokenCaps[i] > 0) {
                return i;
            }
        }
        throw;
    }
    
    
    function setEthPrice(uint ethPrice) public onlyOwner {
        if(ethPrice == 0) throw;
        averageEthPrice = ethPrice;
    }
    
    
    function ethToLoveyRate() public returns (uint) {
        uint oneDollarRate = dollarToLoveyRate();
        uint rate = averageEthPrice * oneDollarRate;
        return rate;
    }
    
    function dollarToLoveyRate() public returns (uint) {
        uint oneDollarRate = totalSupply / (totalCapInDollars * 10**uint(decimals)); 
        return oneDollarRate;
    }
    
    

}