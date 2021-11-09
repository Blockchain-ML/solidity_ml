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
    function remainder(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a % b;
    }
}


 
 
 
 
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
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


 
 
 
 
contract DividendToken is ERC20Interface, Owned {
    using SafeMath for uint256;
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 public _totalSupply;
	uint256 public soldTokens;
	uint256 public excludedTokens;
    uint256 public scaling = uint256(10) ** 8;
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => uint256) public dividendBalanceOf;
    mapping(address => uint256) dividendCreditedTo;
    
    mapping(address => bool) addressCounted;
    
     
    address[] public holders; 
    
    uint256 public dividendPerToken;
    
    
    mapping (address => bool) private frozenAccount;
   
    
    mapping (address => bool) private excludedWallets;
    
     
    bool frozen = false;
    
     
    event Freeze ();

     
    event Unfreeze ();
  
     
    event FrozenFunds(address target, bool frozen);
    
     
    event excludedWallet(address target, bool exclude);
    

    

     
     
     
    constructor(address _owner) public {
        symbol = "DDT";
        name = "DividendToken";
        decimals = 18;
        _totalSupply = totalSupply();
        owner = _owner;
         
        balances[owner] = _totalSupply;
         
		soldTokens = _totalSupply.sub(balances[owner]);
		excludedTokens = 0;
		excludedWallets[owner] = true;
        emit Transfer(address(0),owner, _totalSupply);
    }
    
    function record(address account) internal {
         
         
        if((!addressCounted[account]) && (balances[account] > 0)){
                 
                addressCounted[account] = true;
                holders.push(account);
        } 
         
         
        else if((addressCounted[account]) && (balances[account] == 0)){
             
             
			 
            uint256 amount = dividendBalanceOf[account];
            dividendBalanceOf[account] = 0;
            account.transfer(amount);
        }
    }
	
	function multipleTokensSend (address[] _addresses, uint256[] _values) external onlyOwner{ 
		for (uint i = 0; i < _addresses.length; i++){ 
			transfer(_addresses[i], _values[i]*10**uint(decimals));
		} 
	}
    
     
    function deposit() public payable{
		soldTokens = (_totalSupply.sub(balances[owner])).sub(excludedTokens);
		uint256 available = msg.value * scaling;
        dividendPerToken = (available).div(soldTokens);
        if(dividendPerToken == 0)
            dividendPerToken += (available).remainder(soldTokens);
        for(uint i=0; i< holders.length; i++){ 
            address account = holders[i];
             
            if(excludedWallets[account] == false)
                dividendBalanceOf[account] += balances[account].mul(dividendPerToken);
        }
    }
    
        
    function withDraw() public returns(bool success){
         
        uint256 amount = dividendBalanceOf[msg.sender].div(scaling);
        amount += dividendBalanceOf[msg.sender].remainder(scaling);
        dividendBalanceOf[msg.sender] = 0;
        msg.sender.transfer(amount);
        return true;
    }
    
     
    function freezeTransfers () public {
        require (msg.sender == owner);

        if (!frozen) {
            frozen = true;
            emit Freeze ();
        }
    }

     
    function unfreezeTransfers () public {
        require (msg.sender == owner);

        if (frozen) {
            frozen = false;
            emit Unfreeze ();
        }
    }
    
     
    function freezeAccount(address _target, bool freeze) public onlyOwner{
	  require (msg.sender != _target);
      frozenAccount[_target] = freeze;
      emit FrozenFunds(_target, freeze);
    }
    
     
    function excludeWallet(address _target, bool exclude) public onlyOwner{
	  require (msg.sender != _target);
	  require (balances[_target] != 0);
	  if(excludedWallets[_target] == false && exclude == true) {
        excludedWallets[_target] = exclude;
        excludedTokens= excludedTokens.add(balances[_target]);
        emit excludedWallet(_target, exclude);
	  } else if(excludedWallets[_target] == true && exclude == false){
	    excludedWallets[_target] = exclude;
        excludedTokens= excludedTokens.sub(balances[_target]);
        emit excludedWallet(_target, exclude);  
	  }
    }
    
     
    
    function totalSupply() public view returns (uint){
       return 1e28;  
    }
    
     
     
     
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

     
     
     
     
     
    function transfer(address to, uint tokens) public returns (bool success) {
        require(!frozenAccount[msg.sender]);
	        if (frozen) 
	            return false;
            else {
                 
                require(to != 0x0);
                require(balances[msg.sender] >= tokens );
                require(balances[to] + tokens >= balances[to]);
                balances[msg.sender] = balances[msg.sender].sub(tokens);
                balances[to] = balances[to].add(tokens);
                 
                record(to);
                record(msg.sender);
                emit Transfer(msg.sender,to,tokens);
                return true;
            }
    }
    
     
     
     
     
    function approve(address spender, uint tokens) public returns (bool success){
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, uint tokens) public returns (bool success){
	    require(!frozenAccount[from]);
        if (frozen) 
            return false;
        else {
            require(tokens <= allowed[from][msg.sender]);  
            require(balances[from] >= tokens);
            balances[from] = balances[from].sub(tokens);
            balances[to] = balances[to].add(tokens);
            allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
             
            record(to);
            record(from);
            emit Transfer(from,to,tokens);
            return true;
        }
    }
    
     
     
     
     
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
}