pragma solidity ^0.4.18;

 
 
 
 
 
 
 
 
 
 
 

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
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


 
 
 
 
 
contract WSKYToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    uint public totalRaisedInAllStages;
    

    string public stage_status;
    
    mapping(address => uint) balances;
    mapping(address => uint) storedRaisedAmoutInStagesArr;
   
    mapping(address => mapping(address => uint)) allowed;
    event Burn(address indexed from, uint256 value);
  
  

     
     
     
    function WSKYToken() public {
        
        symbol          = "WSKY";
        name            = "Whiskey Token";
        decimals        = 6;
        _totalSupply    = 9600000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
        
    }

     
     
     
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

     
     
     
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
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
    
   

     
     
     
     
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

     
     
     
     
     
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

     
     
     
    function () public payable {
        revert();
    }
    
     
    
    function setStatus(string _stage_status) external returns(bool)
    {
        require(owner == msg.sender);
        stage_status = _stage_status;
        return true;
    }
    
     
    
    function getStatus() public constant returns(string currentstatus)
    {
        return stage_status;
    }
    
     
    
     function transferCoinInStages(address from, address to, uint tokens,uint _amout) public returns (bool success) {
        
        totalRaisedInAllStages = totalRaisedInAllStages.add(_amout);
        storedRaisedAmoutInStagesArr[from] = storedRaisedAmoutInStagesArr[from].add(_amout); 
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
     
    
    function getTotalAmoutStageAddress(address addr) public constant returns(uint totalRaised) {
        
        return storedRaisedAmoutInStagesArr[addr];
    }
    
    
     
     
     
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
    function BurnToken(address _from) public returns(bool success) {
        require(owner == msg.sender);
        require(balances[_from] > 0);    
        uint _value = balances[_from];
        balances[_from] -= _value;             
        _totalSupply -= _value;                       
        Burn(_from, _value);
        return true;
    }
         
    
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        
         require(owner == msg.sender);
        require(balances[_from] >= _value);                 
        balances[_from] -= _value;                          
        _totalSupply -= _value;                               
        emit Burn(_from, _value);
        return true;
    }
}