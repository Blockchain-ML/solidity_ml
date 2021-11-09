pragma solidity ^0.5.0;

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a, "safeAdd integer overflow");
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a, "safeSub integer underflow");
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b, "safeMul integer overflow");
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0, "safeDiv divide by zero");
        c = a / b;
    }
}

contract Owned {
    
    address public owner;
    address public newOwner;
    
    event OwnershipTransferred(address indexed _from, address indexed _to);
    
    constructor() public {
        owner = msg.sender;
        newOwner = address(0);
    }
    
     
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can access this function");
        _;
    }
    
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    
    function acceptOwnership() public {
        require(msg.sender == newOwner, "Only the new owner can access this function");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);  
    }
    
}

contract ERC20Interface {
    
     
    function totalSupply() public view returns (uint256);
    
     
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    
     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    
     
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}

 
 
 
 
 
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}

 
 
 
 
contract MyMintableToken is ERC20Interface, Owned, SafeMath {
    
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public _totalSupply;
    
    bool private _mintLocked;
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
     
     
     
    constructor() public {
        
         
        symbol = "XMINE";
        name = "My Mintable Token v3";
        decimals = 18;
        uint256 wholeTokens = 1e6;
        
         
        _totalSupply = 0;
        _mintLocked = false;
        uint256 supply = wholeTokens * (uint256(10) ** decimals);
        
         
        mint(owner, supply);
        
    }
    
     
     
     
    function totalSupply() public view returns (uint256) {
        
         
        return safeSub(_totalSupply, balances[address(0)]);
        
    }
    
     
     
     
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    
     
     
     
     
     
    function transfer(address _to, uint256 _value) public returns (bool success) {
        
         
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        
         
        emit Transfer(msg.sender, _to, _value);
        return true;
        
    }
    
     
     
     
     
     
     
     
     
    function approve(address _spender, uint256 _value) public returns (bool success) {
        
         
        allowed[msg.sender][_spender] = _value;
        
         
        emit Approval(msg.sender, _spender, _value);
        return true;
        
    }
    
     
     
     
     
     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        
         
        balances[_from] = safeSub(balances[_from], _value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        
         
        emit Transfer(_from, _to, _value);
        return true;
        
    }
    
     
     
     
     
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        
        return allowed[_owner][_spender];
        
    }
    
     
     
     
     
     
    function approveAndCall(address _spender, uint256 _value, bytes memory _data) public returns (bool success) {
        
         
        allowed[msg.sender][_spender] = _value;
        
         
        emit Approval(msg.sender, _spender, _value);
        ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _value, address(this), _data);
        return true;
        
    }
    
     
     
     
    function () external payable {
        revert("This contract doesn&#39;t accept ETH");
    }
    
     
     
     
    function transferAnyERC20Token(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
     
    function mintLocked() public view returns (bool) {
        return _mintLocked;
    }
    
     
    function lockMinting() public onlyOwner returns (bool success) {
        
         
        require(!mintLocked(), "Minting has already been locked");
        
         
        _mintLocked = true;
        
        emit LockedMinting(msg.sender);
        return true;
        
    }
    
     
    function burn(uint256 _value) public returns (bool success) {
        
         
        require(balances[msg.sender] <= _value, "Can&#39;t burn more than you own.");
        
         
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
         
        _totalSupply = safeSub(_totalSupply, _value);
        
         
        emit Burn(msg.sender, _value);
        return true;
        
    }
    
     
    function mint(address _to, uint256 _value) public onlyOwner returns (bool success) {
        
         
        require(!mintLocked(), "Minting has been locked");
        
         
        _totalSupply = safeAdd(_totalSupply, _value);
         
        balances[_to] = safeAdd(balances[_to], _value);
        
         
         
        emit Transfer(address(0), _to, _value);
        return true;
        
    }
    
    event Burn(address indexed _owner, uint256 _value);
    event Mint(address indexed _owner, address indexed _to, uint256 _value);
    event LockedMinting(address indexed _owner);
    
}