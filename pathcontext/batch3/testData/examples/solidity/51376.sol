 
 
 

pragma solidity 0.4.24;

 
 
 
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
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

    function transferOwnership(address _newOwner) public 
    onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

 
 
 
contract Lock is Owned{
    
     
    bool public isGlobalLocked;
     
    mapping( address => bool) public isAddressLockedMap;

    event AddressLocked(address lockedAddress);
    event AddressUnlocked(address unlockedaddress);
    event GlobalLocked();
    event GlobalUnlocked();

     
    modifier checkGlobalLocked {
        require(!isGlobalLocked);
        _;
    }

     
    modifier checkAddressLocked {
        require(!isAddressLockedMap[msg.sender]);
        _;
    }

    function lockGlobalToken() public
    onlyOwner
    returns (bool)
    {
        isGlobalLocked = true;
        return isGlobalLocked;
        emit GlobalLocked();
    }

    function unlockGlobalToken() public
    onlyOwner
    returns (bool)
    {
        isGlobalLocked = false;
        return isGlobalLocked;
        emit GlobalUnlocked();
    }

    function lockAddressToken(address target) public
    onlyOwner
    returns (bool)
    {
        isAddressLockedMap[target] = true;
        emit AddressLocked(target);
        return isAddressLockedMap[target];
    }

    function unlockAddressToken(address target) public
    onlyOwner
    returns (bool)
    {
        isAddressLockedMap[target] = false;
        emit AddressUnlocked(target);
        return isAddressLockedMap[target];
    }
}

 
 
 
 
contract VANTA is ERC20Interface, Owned, SafeMath, Lock {
    string public symbol;
    string public  name;
    uint8 public decimals = 18;
     
    uint256 public totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    event Burn();



     
     
     
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        symbol = tokenSymbol;
        name = tokenName;
        totalSupply = initialSupply;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }


     
     
     
    function totalSupply() public constant returns (uint) {
        return totalSupply;
    }


     
     
     
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


     
     
     
     
     
    function transfer(address to, uint tokens) public  
    checkGlobalLocked
    checkAddressLocked
    returns (bool success){
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, uint tokens) public 
    checkGlobalLocked
    returns (bool success) {
         
        require(!isAddressLockedMap[from]);
        
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


     
     
     
     
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

     
     
     
    function () public payable {
    }
    
     
     
     
    function burn(uint256 tokens) public
    onlyOwner
    returns (bool)
    {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        totalSupply = safeSub(totalSupply, tokens);
        emit Burn();
        
        return true;
    }
}