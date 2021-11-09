pragma solidity ^0.4.24;


 
 
 
 
 





 

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

 
 
 

contract Blacklist is Owned {

    mapping(address=>bool) blacklisted; 

    modifier notBlacklisted{
    require(blacklisted[msg.sender]==false);
    _;
    }
    event Blacklisted(address toBlacklist, string text );

    function blacklisting (address toBlacklist) public onlyOwner returns(bool succes){
        blacklisted[toBlacklist] = true;
        emit Blacklisted(toBlacklist, "is blacklisted");
        return true;
    }

    function removeFromBlacklist (address toRemove) public onlyOwner {
        blacklisted[toRemove] = false; 
}

}


 
 
 
 

contract GIN is ERC20Interface, Owned, Blacklist {

    using SafeMath for uint;
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


     
     
     
    constructor() public {
        symbol = "GIN";
        name = "GIN";
        decimals = 18;
        _totalSupply = 10000000*10**uint(decimals); 
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }


     
    function totalSupply() public view returns (uint)  {
        return _totalSupply.sub(balances[address(0)]);
    }


     
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


     
     
     
    function transfer(address to, uint amount) public notBlacklisted returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[to] = balances[to].add(amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }


     
     
     
     
     
     
    function transferFrom(address from, address to, uint amount) public notBlacklisted returns (bool success) {
        balances[from] = balances[from].sub(amount);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
        balances[to] = balances[to].add(amount);
        emit Transfer(from, to, amount);
        return true;
    }

     
     
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

     
     
     
     
     
    function approve(address spender, uint amount) public returns (bool success) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

 
     
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
     
    function mint(address recipient, uint256 amount) public onlyOwner {   
        require(_totalSupply + amount >= _totalSupply);  
        _totalSupply += amount;
        balances[recipient] += amount;
        emit Transfer(address(0), recipient, amount);
    }

     
    function burn(uint256 amount) public notBlacklisted  {
        require(amount <= balances[msg.sender]);
        _totalSupply -= amount;
        balances[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

     
     
    function burnFrom(address from, uint256 amount) public notBlacklisted {
        require(amount <= balances[from]);
        require(amount <= allowed[from][msg.sender]);

        _totalSupply -= amount;
        balances[from] -= amount;
        allowed[from][msg.sender] -= amount;
        emit Transfer(from, address(0), amount);
    }
}