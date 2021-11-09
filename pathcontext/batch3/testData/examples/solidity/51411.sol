pragma solidity ^ 0.4.24;

 
 
 

contract owned {
    address public owner;

    constructor() public {
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

 
contract SafeMath { 
    function safeMul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}

contract ElephantToken is owned, SafeMath {
    string public name;
    string public symbol;
    uint8 public decimals = 8;
    uint256 public totalSupply;
    uint256 public sellPrice;
    uint256 public buyPrice;

     
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public freezeOf;
    mapping(address => mapping(address => uint256)) public allowance;

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

     
    event Burn(address indexed from, uint256 value);

     
    event Freeze(address indexed from, uint256 value);

     
    event Unfreeze(address indexed from, uint256 value);

     
    constructor (uint256 initialSupply, string tokenName, string tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  
        balanceOf[msg.sender] = totalSupply;  
        name = tokenName;  
        symbol = tokenSymbol;  
        owner = msg.sender;
    }

     
    function transfer(address _to, uint256 _value) internal {
        require(_to != 0x0);
        require(_value > 0);
        require(balanceOf[msg.sender] >= _value);    
        require(SafeMath.safeAdd(balanceOf[_to], _value) >= balanceOf[_to]);     
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);  
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);  
        emit Transfer(msg.sender, _to, _value);  
    }

     
    function approve(address _spender, uint256 _value) public returns(bool success) {
        require(_value > 0);
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) {
        require(_to != 0x0);  
        require(_value > 0);
        require(balanceOf[_from] >= _value);  
        require(SafeMath.safeAdd(balanceOf[_to], _value) >= balanceOf[_to]);  
        require(_value <= allowance[_from][msg.sender]);  
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);  
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);  
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value) public returns(bool success) {
        require(balanceOf[msg.sender] >= _value);  
        require(_value > 0);
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);  
        totalSupply = SafeMath.safeSub(totalSupply, _value);  
        emit Burn(msg.sender, _value);
        return true;
    }

    function freeze(uint256 _value) public returns(bool success) {
        require(balanceOf[msg.sender] >= _value);  
        require(_value > 0);
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);  
        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value);  
        emit Freeze(msg.sender, _value);
        return true;
    }

    function unfreeze(uint256 _value) public returns(bool success) {
        require(freezeOf[msg.sender] >= _value);  
        require(_value > 0);
        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);  
        balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);
        emit Unfreeze(msg.sender, _value);
        return true;
    }

     
    function withdrawEther(uint256 amount) public {
        require(msg.sender == owner);
        owner.transfer(amount);
    }

     
    function() payable public {}

     
    function increaseSupply(uint256 value, address to) onlyOwner public returns(bool) {
        value = value * 10 ** uint256(decimals);
        totalSupply = SafeMath.safeAdd(totalSupply, value);
        balanceOf[to] = SafeMath.safeAdd(balanceOf[to], value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

     
    function decreaseSupply(uint256 value, address from) onlyOwner public returns(bool) {
        value = value * 10 ** uint256(decimals);
        balanceOf[from] = SafeMath.safeSub(balanceOf[from], value);
        totalSupply = SafeMath.safeSub(totalSupply, value);
        emit Transfer(from, msg.sender, value);
        return true;
    }

     
     
     
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

     
    function buy() payable public {
        uint amount = SafeMath.safeSub(msg.value, buyPrice);                
        emit Transfer(this, msg.sender, amount);               
    }

     
     
    function sell(uint256 amount) public {
        address myAddress = this;
        require(myAddress.balance >= SafeMath.safeMul(amount, sellPrice));       
        emit Transfer(msg.sender, this, amount);               
        msg.sender.transfer(amount * sellPrice);           
    }
}