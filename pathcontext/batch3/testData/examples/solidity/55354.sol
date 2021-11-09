pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() public {
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

contract TegTokens {
     
    string public name;
    string public symbol;
    uint8 public decimals = 18;                  
    uint256 public totalSupply;
    uint256 public coinunits;                  
    uint256 public ethereumWei;             
    address public tokensWallet;              
    address public owner;              
    address public salesaccount;            
    uint256 public sellPrice;              
    uint256 public buyPrice;              
    uint256 public investreturns;
    bool public isActive;  

     
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

     
    event Transfer(address indexed from, address indexed to, uint256 value);
     

     
    event Burn(address indexed from, uint256 value);

     
    function TegTokens(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
         
        totalSupply = initialSupply * 10 ** uint256(decimals);   
        balanceOf[msg.sender] = totalSupply;                 
        name = "TegTokens";                                    
        symbol = "TET";                                
        coinunits = 100;                                       
        tokensWallet = msg.sender;
        salesaccount = msg.sender;
        ethereumWei = 1000000000000000000;                                     
        isActive = true;                
        owner = msg.sender;
    }



     
    function _transfer(address _from, address _to, uint _value) internal {
         
        require(_to != 0x0);
         
        require(balanceOf[_from] >= _value);
         
        require(balanceOf[_to] + _value > balanceOf[_to]);
         
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

     
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function multiply(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
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
     
    function salesAddress(address sales) public returns (bool success){
        require(msg.sender == tokensWallet);
        salesaccount = sales;
        return true;
    }
     
    function coinsUnit(uint256 amount) public returns (bool success){
        require(msg.sender == tokensWallet);
        coinunits = amount;
        return true;
    }
     
  	function withdrawEther(uint256 amount) public returns (bool success){
  		require(msg.sender == tokensWallet);
       
      amount = amount * ethereumWei;
  		salesaccount.transfer(amount);
  		return true;
  	}

     
    function buy(uint256 amount) public payable{
       
        require(msg.value == multiply(amount, ethereumWei));
        _transfer(this,msg.sender, amount);               
    }
    function startSale() external {
      require(msg.sender == owner);
      isActive = true;
    }
    function stopSale() external {
      require(msg.sender == owner);
      isActive = false;
    }

    function() payable public {
     
     
       
       
      require(isActive);
      uint256 amount = msg.value * coinunits;
       
      require(balanceOf[tokensWallet] >= amount);

      balanceOf[tokensWallet] -= amount;
      balanceOf[msg.sender] += amount;

      Transfer(tokensWallet, msg.sender, amount);  

       
     
     
      }

}

 
 
 

contract TegTokensSale is owned, TegTokens {



    mapping (address => bool) public frozenAccount;

     
    event FrozenFunds(address target, bool frozen);

     
    function TegTokensSale(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TegTokens(initialSupply, tokenName, tokenSymbol) public {}

     
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                                
        require (balanceOf[_from] >= _value);                
        require (balanceOf[_to] + _value >= balanceOf[_to]);  
        require(!frozenAccount[_from]);                      
        require(!frozenAccount[_to]);                        
        balanceOf[_from] -= _value;                          
        balanceOf[_to] += _value;                            
        emit Transfer(_from, _to, _value);
    }

     
     
     
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }

     
     
     
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

     
     
     
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
    function multiply(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
     
     

     
     
    function sell(uint256 amount) public {
        address myAddress = this;
        require(myAddress.balance >= amount * sellPrice);       
        _transfer(msg.sender, owner, amount);               
        msg.sender.transfer(amount * sellPrice);           
    }

}