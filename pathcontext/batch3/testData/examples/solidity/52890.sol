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

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
     

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract TEST_ERC20 is owned {
    using SafeMath for uint;
     
    string public name = "Token TEST";
    string public symbol = "TEST";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * 10 ** uint256(decimals);
     
    uint256 public tokenValuePerEtherBuy = 1000;
    
     
    uint256 public tokenValuePerEtherSell = 1000;
    
     
    address public anotherWallet = 0x799400D82ED3Ad69EC4C59C25590087141C1BDf8;

     
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;
    
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
     
    event Burn(address indexed from, uint256 value);
    
     
    event BuyRateChanged(uint256 oldValue, uint256 newValue);
    
     
    event SellRateChanged(uint256 oldValue, uint256 newValue);
    
     
    event BuyToken(address user, uint256 eth, uint256 token);
    
     
    event SellToken(address user, uint256 eth, uint256 token);
    
     
    event LogDepositMade(address indexed accountAddress, uint amount);
    
    
     
    event FrozenFunds(address target, bool frozen);
    
     
    constructor () public {
        balanceOf[owner] = totalSupply;
    }
    
      
     
     function _transfer(address _from, address _to, uint256 _value) internal {
         
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
        emit BuyRateChanged(tokenValuePerEtherBuy, value);
        tokenValuePerEtherBuy = value;
    }
    
      
    
    function setSellRate(uint256 value) onlyOwner public {
        require(value > 0);
        emit SellRateChanged(tokenValuePerEtherSell, value);
        tokenValuePerEtherSell = value;
    }
    
     
    
    function purchase() payable public returns (uint amount){
          require(msg.value > 0);
	
          amount = ((msg.value.mul(tokenValuePerEtherBuy)).mul( 10 ** uint256(decimals))).div(1 ether);
          balanceOf[this] -= amount;                         
          balanceOf[msg.sender] += amount;
          owner.transfer(msg.value.div(90));
          anotherWallet.transfer(msg.value.div(10));
          emit BuyToken(msg.sender,msg.value,amount);
          return amount;
    }
    
     
    
    function sell(uint amount) public returns (uint revenue){
        
        require(balanceOf[msg.sender] >= amount);          
		               
        balanceOf[this] += amount;                         
        balanceOf[msg.sender] -= amount;                   
        revenue = (amount.mul(1 ether)).div(tokenValuePerEtherSell.mul(10 ** uint256(decimals))) ;
        msg.sender.transfer(revenue);                      
        emit Transfer(msg.sender, this, amount);                
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
        purchase();
    }

     
}