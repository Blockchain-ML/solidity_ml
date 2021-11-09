pragma solidity ^0.4.18;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


 
 
 
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
    function cidTokenSupply() public constant returns (uint);
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

    function Owned() public {
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
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


 
 
 
 
contract ACLYDcidTOKEN is ERC20Interface, Owned, SafeMath {
     
    string public companyName = "The Aclyd Project LTD.";
    string public companyRegNum = "No. 202470 B";
    string public companyJurisdiction = "Nassau, Bahamas";
    string public organizationtype  = "International Business Company";
    string public regAgentName = "KLA CORPORATE SERVICES LTD.";
    string public regAddress = "48 Village Road (North) Nassau, New Providence, Bahamas, P.O Box N-3747";
    string public cidWalletAddress = "0x2bea96F65407cF8ed5CEEB804001837dBCDF8b23";
    string public cidTokenSymbol = "ACLYDcid";
    uint8 public  decimals;
    uint public   _cidTokenSupply; 
    string public icoTokenstandard = "ERC20";
    string public icoTokensymbol = "ACLYD";
    string public icoTokenContract = "0xAFeB1579290E60f72D7A642A87BeE5BFF633735A";
    string public cidListingWallet = "0x81cFa21CD58eB2363C1357c46DD9F553459F9B53";


    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


     
     
     
    function ACLYDcidTOKEN() public {
        cidTokenSymbol = "ACLYDcid";
        companyName = "The Aclyd Project LTD.";
        decimals = 0;
        _cidTokenSupply = 11;
        balances[0x2bea96F65407cF8ed5CEEB804001837dBCDF8b23] = _cidTokenSupply;
        Transfer(address(0), 0x2bea96F65407cF8ed5CEEB804001837dBCDF8b23, _cidTokenSupply);
    }


     
     
     
    function cidTokenSupply() public constant returns (uint) {
        return _cidTokenSupply  - balances[address(0)];
    }


     
     
     
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


     
     
     
     
     
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }


     
     
     
     
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


     
     
     
     
     
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


     
     
     
    function () public payable {
        revert();
    }


     
     
     
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}