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

contract  AcceptEth {
    address public owner;
    uint public price;
    mapping (address => uint) balance;

    constructor() public {
         
        owner = msg.sender;
         
        price = 2 ether;
    }

    function accept() public payable {
         
        require(msg.value == price);

         
        balance[msg.sender] += msg.value;
    }
    
    function refund(uint amountRequested) public {
        require(amountRequested > 0 && amountRequested <= balance[msg.sender]);

        balance[msg.sender] -= amountRequested;

        msg.sender.transfer(amountRequested);  
    }
}

contract Nonpayable {

   
   
   
  function () public payable {
    revert();
  }
}

contract Ownable {
  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function DissolveBusiness() public onlyOwner { 
     
     
     
     
     
    selfdestruct(owner);
  }
}

 
 
 
 
contract ERC20Interface {
    function totalSharesIssued() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Regulated is Ownable {
  event ShareholderRegistered(address indexed shareholder);
  event CorpBlackBook(address indexed shareholder);            
  
  mapping(address => bool) regulationStatus;

  function RegisterShareholder(address shareholder) public onlyOwner {
    regulationStatus[shareholder] = true;
    emit ShareholderRegistered(shareholder);
  }

  function NevadaBlackBook(address shareholder) public onlyOwner {
    regulationStatus[shareholder] = false;
    emit CorpBlackBook(shareholder);
  }
  
  function ensureRegulated(address shareholder) public constant {
    require(regulationStatus[shareholder] == true);
  }

  function isRegulated(address shareholder) public constant returns (bool approved) { 
    return regulationStatus[shareholder];
  }
}

contract ERC20 {
  function totalSupply() public constant returns (uint);
  function balanceOf(address tokenOwner) public constant returns (uint balance);
  function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
  function transfer(address to, uint tokens) public returns (bool success);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
  
  
 
 

 
 


  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract RIUA is ERC20, Regulated, AcceptEth {
  using SafeMath for uint;

  string public symbol;
  string public  name;
  uint8 public decimals;
  uint public _totalShares;

  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;

  constructor() public {
    symbol = "RIU";                                      
    name = "Residual Income Unit DAO A";                       
     
    decimals = 0;                                        
     
    _totalShares = 100000 * 10**uint(decimals);        
    balances[owner] = _totalShares;
    emit Transfer(address(0), owner, _totalShares);      

    regulationStatus[owner] = true;
    emit ShareholderRegistered(owner);
  }

  function issue(address recipient, uint tokens) public onlyOwner returns (bool success) {
    require(recipient != address(0));
    require(recipient != owner);
    
    RegisterShareholder(recipient);
    transfer(recipient, tokens);
    return true;
  }

  function transferOwnership(address newOwner) public onlyOwner {
     
    require(newOwner != address(0));
    require(newOwner != owner);
   
    RegisterShareholder(newOwner);
    transfer(newOwner, balances[owner]);
    owner = newOwner;
  }

  function totalSupply() public constant returns (uint supply) {
    return _totalShares - balances[address(0)];
  }

  function balanceOf(address tokenOwner) public constant returns (uint balance) {
    return balances[tokenOwner];
  }

  function transfer(address to, uint tokens) public returns (bool success) {
    ensureRegulated(msg.sender);
    ensureRegulated(to);
    
    balances[msg.sender] = balances[msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(msg.sender, to, tokens);
    return true;
  }

  function approve(address spender, uint tokens) public returns (bool success) {
     
    require((tokens == 0) || (allowed[msg.sender][spender] == 0));
    
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
  }

  function transferFrom(address from, address to, uint tokens) public returns (bool success) {
    ensureRegulated(from);
    ensureRegulated(to);

    balances[from] = balances[from].sub(tokens);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(from, to, tokens);
    return true;
  }

  function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
    return allowed[tokenOwner][spender];
  }

   
   
   
   
  
   
   
   
  function transferOtherERC20Assets(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
  }
}