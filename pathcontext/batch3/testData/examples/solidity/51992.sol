pragma solidity ^0.4.25;

 
 
 
 
 
 
 
 
 
 
 

 
 

 

library SafeMath {
    
     
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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


 

contract owned {
    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract ERC20 is owned {
    
    using SafeMath for uint;
     
    string public name = "Cannabnc Token";
    string public symbol = "CNB";
    uint8 public decimals = 18;
    uint256 public totalSupply = 400000000 * 10 ** uint256(decimals);
    
     
    uint256 public BuyPrice = 4000;
    
     
    uint256 public SellPrice = 4000;
    
     
    address public ICO_Contract;

     
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;
   
     
    event Transfer(address indexed from, address indexed to, uint256 value);
    
     
    event FrozenFunds(address target, bool frozen);
    
     
    event Burn(address indexed from, uint256 value);
    
     
    event BuyRateChanged(uint256 oldValue, uint256 newValue);
    
     
    event SellRateChanged(uint256 oldValue, uint256 newValue);
    
    
     
    event LogDepositMade(address indexed accountAddress, uint amount);
    
     
    constructor (address _owner) public {
        owner = _owner;
        balanceOf[owner] = totalSupply;
    }
    
    function _transfer(address _from, address _to, uint256 _value)  internal {
         
        require(_to != 0x0);
         
        require(balanceOf[_from] >= _value);
         
        require(balanceOf[_to] + _value > balanceOf[_to]);
         
        require(!frozenAccount[_from]);
         
        require(!frozenAccount[_to]);
         
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
         
        balanceOf[_from] -= _value;
         
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
         
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

     
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);      
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

     
     
     
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
    
      
     
     
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(this, target, mintedAmount);
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
    
      
    
    function setBuyRate(uint256 value) onlyOwner public {
        require(value > 0);
        emit BuyRateChanged(BuyPrice, value);
        BuyPrice = value;
    }
    
      
    
    function setSellRate(uint256 value) onlyOwner public {
        require(value > 0);
        emit SellRateChanged(SellPrice, value);
        SellPrice = value;
    }
    
     
    
    function buy() payable public returns (uint amount){
          require(msg.value > 0);
          amount = ((msg.value.mul(BuyPrice)).mul( 10 ** uint256(decimals))).div(1 ether);
          balanceOf[this] -= amount;                         
          balanceOf[msg.sender] += amount; 
          _transfer(this, msg.sender, amount);
          return amount;
    }
    
     
    
    function sell(uint amount) public returns (uint revenue){
        
        require(balanceOf[msg.sender] >= amount);          
        balanceOf[this] += amount;                         
        balanceOf[msg.sender] -= amount;                   
        revenue = (amount.mul(1 ether)).div(SellPrice.mul(10 ** uint256(decimals))) ;
        msg.sender.transfer(revenue);                      
        _transfer(msg.sender, this, amount);                
       return revenue;                                    
        
    }
    
     
    
    function deposit() public payable  {
       
    }
    
     
     function withdraw(uint withdrawAmount) onlyOwner public  {
          if (withdrawAmount <= address(this).balance) {
            owner.transfer(withdrawAmount);
        }
        
     }
    
    function () public payable {
        buy();
    }
    
     
     
    function setICO_Contract(address _ICO_Contract) onlyOwner public {
        ICO_Contract = _ICO_Contract;
    }
    
}

contract Killable is owned {
    function kill() onlyOwner public {
        selfdestruct(owner);
    }
}

contract ERC20_ICO is Killable {
    
      
    ERC20 public token;

     
    uint256 public startsAt = 1544875200;

     
    uint256 public endsAt = 1547985600;

     
    uint256 public TokenPerETH = 5000;

     
    bool public finalized = false;
    
      
    uint256 public tokensSold = 0;

     
    uint256 public weiRaised = 0;

     
    uint256 public investorCount = 0;
    
      
    mapping (address => uint256) public investedAmountOf;

     
    event Invested(address investor, uint256 weiAmount, uint256 tokenAmount);
     
    event StartsAtChanged(uint256 startsAt);
     
    event EndsAtChanged(uint256 endsAt);
     
    event RateChanged(uint256 oldValue, uint256 newValue);
    
    
    constructor (address _token) public {
        token = ERC20(_token);
    }

    function investInternal(address receiver) private {
        require(!finalized);
        require(startsAt <= now && endsAt > now);

        if(investedAmountOf[receiver] == 0) {
             
            investorCount++;
        }

         
        uint256 tokensAmount = msg.value * TokenPerETH;
        investedAmountOf[receiver] += msg.value;
         
        tokensSold += tokensAmount;
        weiRaised += msg.value;

         
        emit Invested(receiver, msg.value, tokensAmount);
        
         
        token.transfer(receiver, tokensAmount);

         
        owner.transfer(address(this).balance);

    }
     function () public payable {
        investInternal(msg.sender);
    }

    function setStartsAt(uint256 time) onlyOwner public {
        require(!finalized);
        startsAt = time;
        emit StartsAtChanged(startsAt);
    }
    
    function setEndsAt(uint256 time) onlyOwner public {
        require(!finalized);
        endsAt = time;
        emit EndsAtChanged(endsAt);
    }
    
    function setRate(uint256 value) onlyOwner public {
        require(!finalized);
        require(value > 0);
        emit RateChanged(TokenPerETH, value);
        TokenPerETH = value;
    }
    function finalize() public onlyOwner {
         
        finalized = true;
        uint256 tokensAmount = token.balanceOf(this);
        token.transfer(owner, tokensAmount);
    }
}