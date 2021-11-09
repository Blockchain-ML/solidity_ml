pragma solidity 0.4.25;


 
 
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
  function Ownable() {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {  
    require(msg.sender == owner);               
    _;
  }


   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

 
 
library SafeMath {
    function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
    }
    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
    }
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
    }
    function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
    return c;
    }
}

 
 
 
 
 

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


 

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

   
  function pauseContribution() public view returns(bool) {
    return paused;
  }

   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

   
  modifier whenPaused() {
    require(paused);
    _;
  }

   
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}



 
contract DigipayToken is ERC20, Ownable, Pausable {
  using SafeMath for uint256;
  string  public symbol; 
  string  public name;
  uint8   public decimals;
  uint256 public fundsRaised;
  uint256 public preSaleTokens;
  uint256 public saleTokens;
  uint256 public teamAdvTokens;
  uint256 public bountyTokens;
  uint256 public hardCap;
  string  internal minTxSize;
  string  internal maxTxSize;
  string  public TokenPrice;
  uint    internal totalSupply;
  address public wallet;
  uint256 internal presaleopeningTime;
  uint256 internal presaleclosingTime;
  uint256 internal saleopeningTime;
  uint256 internal saleclosingTime;
  bool    internal presaleOpen;
  bool    internal saleOpen;
  bool    internal Open;
  bool    public   locked;
  
  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) allowed;
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event Burned(address burner, uint burnedAmount);

    modifier onlyWhileOpen {
        require(now >= presaleopeningTime && now <= saleclosingTime && Open && fundsRaised <= hardCap);
        _;
    }
    
     
    modifier onlyUnlocked() {
        require(msg.sender == wallet || !locked);
        _;
    }


     
     
     
    constructor (address _owner, address _wallet) public {
        _allocateTokens();
        _setTimes();
        
        locked = true;   
        symbol = "DIP";
        name = "Digipay Token";
        decimals = 18;
        hardCap = 5 ether;
        owner = _owner;
        wallet = _wallet;
        totalSupply = 180000000e18;
        Open = true;
        balances[this] = totalSupply;
        emit Transfer(address(0x0),this, totalSupply);
    }

    function updatewallet(address _wallet) public onlyOwner() {
        wallet = _wallet;
    }

    
    function unlock() public onlyOwner {
        locked = false;
    }

    function lock() public onlyOwner {
        locked = true;
    }

    
    function _setTimes() internal{   
        presaleopeningTime        = 1539849600;  
        presaleclosingTime        = 1539851400;  
        saleopeningTime           = 1539853200;  
        saleclosingTime           = 1539853380;  
    }
  
    function _allocateTokens() internal{
        
        preSaleTokens         = 36000000;    
        saleTokens            = 90000000;    
        teamAdvTokens         = 36000000;    
        bountyTokens          = 18000000;    
        hardCap               = 20000;       
        minTxSize             = "0,5 ETH";  
        maxTxSize             = "1000 ETH";  
        TokenPrice            = "$0.05";
        presaleOpen           = true;
    }

     
    
     
     
     
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

     
     
     
     
     
    function transfer(address to, uint256 tokens) public onlyUnlocked returns (bool) {
         
        require(to != 0x0);
        require(balances[msg.sender] >= tokens );
        require(balances[to] + tokens >= balances[to]);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender,to,tokens);
        return true;
    }
    
     
     
     
     
    function approve(address spender, uint256 tokens) public returns (bool){
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, uint tokens) public onlyUnlocked returns (bool){
        require(to != 0x0);
        require(tokens <= allowed[from][msg.sender]);  
        require(balances[from] >= tokens);
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        emit Transfer(from,to,tokens);
        return true;
    }
     
     
     
     
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
    function _checkOpenings() internal{
        
        if(now >= presaleopeningTime && now <= presaleclosingTime){
          presaleOpen = true;
          saleOpen = false;
        }
        else if(now >= saleopeningTime && now <= saleclosingTime){
            presaleOpen = false;
            saleOpen = true;
        }
        else{
          presaleOpen = false;
          saleOpen = false;
        }
    }
    
    function () external payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address _beneficiary) public payable onlyWhileOpen whenNotPaused {
    
        uint256 weiAmount = msg.value;
    
        _preValidatePurchase(_beneficiary, weiAmount);
    
        _checkOpenings();
        
        if(presaleOpen){
            require(weiAmount >= 2e18  && weiAmount <= 2e20 ,"FUNDS should be MIN 2 ETH and Max 200 ETH");
        }
        else {
            require(weiAmount >= 2e17  && weiAmount <= 5e20 ,"FUNDS should be MIN 0,2 ETH and Max 500 ETH");
        }
        
        uint256 tokens = _getTokenAmount(weiAmount);
        
        if(weiAmount >= 10e18){  
             
            tokens = tokens.add((tokens.mul(10)).div(100));
        }
        
         
        fundsRaised = fundsRaised.add(weiAmount);

        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase(this, _beneficiary, weiAmount, tokens);

        _forwardFunds(msg.value);
    }
    
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal{
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
         
    }
  
    function _getTokenAmount(uint256 _weiAmount) internal returns (uint256) {
        uint256 rate;
        if(presaleOpen){
            rate = 7500;  
        }
        else if(saleOpen){
            rate = 5000;  
        }
        
        return _weiAmount.mul(rate);
    }
    
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        _transfer(_beneficiary, _tokenAmount);
    }

    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
    }
    
    function _forwardFunds(uint256 _amount) internal {
        wallet.transfer(_amount);
    }
    
    function _transfer(address to, uint256 tokens) internal returns (bool success) {
         
        require(to != 0x0);
        require(balances[this] >= tokens );
        require(balances[to] + tokens >= balances[to]);
        balances[this] = balances[this].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(this,to,tokens);
        return true;
    }
    
    function freeTokens(address _beneficiary, uint256 _tokenAmount) public onlyOwner{
       _transfer(_beneficiary, _tokenAmount);
    }
    
    function stopICO() public onlyOwner{
        Open = false;
    }
    
    function multipleTokensSend (address[] _addresses, uint256[] _values) public onlyOwner{
        for (uint256 i = 0; i < _addresses.length; i++){
            _transfer(_addresses[i], _values[i]*10**uint(decimals));
        }
    }


    event Burn(address indexed burner, uint tokens);

     
    function burn(address this, uint256 tokens) public onlyOwner returns (bool){
        balances[this] = balances[this].sub(tokens);
        totalSupply = totalSupply.sub(tokens);
        Burn(msg.sender, tokens);
        Transfer(this, address(0x0), tokens);
        return true;
    }

     
    function burnFrom(address from, uint256 tokens) public onlyOwner returns(bool){
        assert(transferFrom(from, this, tokens));
        return burn(from, tokens);
    }
    
     
}