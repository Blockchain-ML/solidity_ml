pragma solidity 0.4.25;

 
 
 
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

 
 
 
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
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

 
contract HydrogenBlueICO is ERC20Interface, Owned {
  using SafeMath for uint256;
  string  public symbol; 
  string  public name;
  uint8   public decimals;
  uint256 public fundsRaised;
  uint256 public reserveTokens;
  string  public TokenPrice;
  uint256 public saleTokens;
  uint    internal _totalSupply;
  address public wallet;
  uint256 internal firststageopeningTime;
  uint256 internal secondstageopeningTime;
  uint256 internal laststageopeningTime;
  bool    internal Open;
  
  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event Burned(address burner, uint burnedAmount);

    modifier onlyWhileOpen {
        require(now >= firststageopeningTime && Open);
        _;
    }
  
     
     
     
    constructor (address _owner, address _wallet) public {
        Open = true;
        symbol = "HydroB";
        name = " HydrogenBlue";
        decimals = 18;
        owner = _owner;
        wallet = _wallet;
        _totalSupply = 2700000000;  
        balances[this] = totalSupply();
        emit Transfer(address(0),this, totalSupply());
        _allocateTokens();
        _setTimes();
    }
    
    function _setTimes() internal {
        
        firststageopeningTime = 1539129600;  
        secondstageopeningTime   = 1540166400;  
        laststageopeningTime     = 1540771200;  
    }
  
    function _allocateTokens() internal {
        reserveTokens         = (_totalSupply.mul(5)).div(100) *10 **uint(decimals);   
        saleTokens            = (_totalSupply.mul(95)).div(100) *10 **uint(decimals);  
        TokenPrice            = "0.00000023 ETH";
    }
    
    function () external payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address _beneficiary) public payable onlyWhileOpen {
    
        uint256 weiAmount = msg.value;
    
        _preValidatePurchase(_beneficiary, weiAmount);
        
        uint256 tokens = _getTokenAmount(weiAmount);
        
        tokens = _getBonus(tokens, weiAmount);
        
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
        uint256 rate = 4347826;  
        return _weiAmount.mul(rate);
    }
    
    function _getBonus(uint256 tokens, uint256 weiAmount) internal returns (uint256) {
         
        if(now >= firststageopeningTime && now <= secondstageopeningTime) { 
            if(weiAmount >= 10e18) {  
                 
                tokens = tokens.add((tokens.mul(80)).div(100));
            } else {
                 
                tokens = tokens.add((tokens.mul(60)).div(100));
            }
        } 
         
        else if (now >= secondstageopeningTime && now <= laststageopeningTime) { 
            if(weiAmount >= 10e18) {  
                 
                tokens = tokens.add((tokens.mul(60)).div(100));
            } else {
                 
                tokens = tokens.add((tokens.mul(30)).div(100));
            }
        } 
         
        else { 
            if(weiAmount >= 10e18) {  
                 
                tokens = tokens.add((tokens.mul(30)).div(100));
            } else {
                 
                tokens = tokens.add((tokens.mul(10)).div(100));
            }
        }
        
        return tokens;
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
    
    function _transfer(address to, uint tokens) internal returns (bool success) {
         
        require(to != 0x0);
        require(balances[this] >= tokens );
        require(balances[to] + tokens >= balances[to]);
        balances[this] = balances[this].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(this,to,tokens);
        return true;
    }
    
    function stopICO() public onlyOwner{
        Open = false;
        if(balances[this] != 0){
            _transfer(owner, (balances[this].mul(10)).div(100));  
            _transfer(wallet, (balances[this].mul(20)).div(100));  
            _burnRemainingTokens();  
        }
    }
    
    function _burnRemainingTokens() internal {
        balances[this] = 0;
    }
     
    function totalSupply() public constant returns (uint){
       return _totalSupply* 10**uint(decimals);
    }
    
     
     
     
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

     
     
     
     
     
    function transfer(address to, uint tokens) public returns (bool success) {
         
        require(to != 0x0);
        require(balances[msg.sender] >= tokens );
        require(balances[to] + tokens >= balances[to]);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender,to,tokens);
        return true;
    }
    
     
     
     
     
    function approve(address spender, uint tokens) public returns (bool success){
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, uint tokens) public returns (bool success){
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

}