pragma solidity ^0.4.24;

 
 
 
 
 
 
 
 
 
 
 


 
 
 
contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
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
    event SellToken(address indexed buyedFrom, uint tokens, uint ethGiven);
    event BuyToken(address Buyer, uint ethSpent);
    event Kill(string killConfirmed);
    event RefundETH(address refundTo, uint ETH);
    
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

 
 
 
contract Start is Owned {
    bool public sale;

    event eSaleStart(bool saleStart);

    constructor() public {
        sale = true;
        emit eSaleStart(true);
    }

    modifier started {
        require(sale == true);
        _;
    }

    function startSale(bool starter) public onlyOwner {
        sale = starter;
        emit eSaleStart(starter);
    }
}

 
 
 
 
contract PaNaKeMu is ERC20Interface, Owned, Start, SafeMath {
     
    string public constant symbol = "PNKM";
    string public constant name = "PaNaKeMu";
    uint256 public constant decimals = 18;
    
     
    uint256 public sellPrice = 10000;
    uint256 public buyPrice = 10000;
    
     
    uint public _totalSupply;
	uint public _devTokens;

     
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
     

    mapping(address => uint) public buyersEth;
    mapping(address => uint) public buyersToken;
    

     
    string[] public debug_varString;
    uint[] public debug_uInt;
    bool[] public debug_bool;
    address[] public debug_address;

     
     
     
    
     
     
     
    constructor() public {
		_devTokens = 200000000 * 10**decimals;
        _totalSupply = 1200000000 * 10**decimals;
        
        balances[owner] = _totalSupply;
        emit Transfer(address(this), owner, _devTokens);
    }
 
     
     
     
    function totalSupply() public constant returns (uint) {
        return _totalSupply - balances[address(0)];
    }


     
     
     
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


     
     
     
     
     
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens *10**decimals);
        balances[to] = safeAdd(balances[to], tokens*10**decimals);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


     
     
     
     
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


     
     
     
     
     
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

 
     
     
     
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
     
     

     
     
    function sellToken(uint256 amount) public {
        uint balance = address(this).balance;
        uint etherToSend = amount / sellPrice;
        require(balance >= etherToSend, "nicht gen&#252;gend Ether im Smartcontract");       
        transferFrom(msg.sender, address(this), amount);               
        
        msg.sender.transfer(etherToSend);           
        emit SellToken(msg.sender, amount, etherToSend);
    }
    
     
    function kill() onlyOwner public {
        selfdestruct(owner);
        emit Kill("Contract is dead");
    }
}