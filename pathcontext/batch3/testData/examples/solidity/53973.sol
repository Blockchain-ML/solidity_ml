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


 
 
 
 
contract CrowdsalePreGenesis9 is ERC20Interface, Owned{
    
	using SafeMath for uint;
	address public token_contract;
    string public symbol;
    string public  name;
	uint8 public decimals;
	uint _totalSupply;
	uint public _totalSales;
	uint public softCap;
	uint public hardCap;
	uint public startDate;
	uint public bonusEnds50;
	uint public bonusEnds30;
	uint public bonusEnds20;
	uint public bonusEnds10;
	uint public bonusEnds5;
    uint public endDate;
    uint public nextEndDate;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) allowed;


     
     
     
    constructor() public {
		token_contract = 0x5FEaAB22dE79717B72D87AbF1E38444270c7bc30;
        symbol = "GENES";
        name = "Genesis Crowdsale";
		decimals = 18;
		_totalSupply = 100000000 * 10**uint(decimals);
		_totalSales = 0;
		softCap = 1000000;
		hardCap = 100000000;
		startDate = 1539129600;		 
		bonusEnds50 = 1539993600;
		bonusEnds30 = 1540512000;
		bonusEnds20 = 1540944000;
		bonusEnds10 = 1541462400;
		bonusEnds5 = 1544400000;	 
		endDate = 1541808000; 		 
		nextEndDate = 1544400000; 	 
    }

     
     
     
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }

     
     
     
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

     
     
     
     
     
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

     
     
     
     
     
     
     
     
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


     
     
     
     
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


     
     
     
     
     
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


     
     
     
    function () public payable {
	
		 

		uint rate = 2500;
		uint tokens;
		
		tokens = rate * msg.value;
		
         
        _totalSales.add(tokens);
		emit Transfer(token_contract, msg.sender, tokens);
    }
    
     
     
     
	function getOwnerEth() public onlyOwner returns(bool success) {
	    
	    if(_totalSales >= hardCap){
	        owner.transfer(address(this).balance);
	        return true;
	    }
	    
	    if(_totalSales >= softCap && endDate >= now){
	        owner.transfer(address(this).balance);
	        return true;
	    }

	    return false;
	}
	
	 
     
     
	function refund(uint amountRequested) public returns(bool success) {
		if(nextEndDate <= now){
			require(amountRequested > 0);
			require(amountRequested <= balances[msg.sender]);
			balances[msg.sender].sub(amountRequested);
			msg.sender.transfer(amountRequested);
			return true;
		}
		
		return false;
	}

     
     
     
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}