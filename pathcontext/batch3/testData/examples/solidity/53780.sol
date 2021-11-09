pragma solidity ^0.4.18;

contract ERC223Interface {
    uint public totalSupply;
    function balanceOf(address who) constant returns (uint);
    function transfer(address to, uint value);
    function transfer(address to, uint value, bytes data);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}


 
contract Ownable {
    address public owner;

     
    function Ownable() public {
        owner = msg.sender;
    }

     
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }
}




contract REMM is Ownable, ERC223Interface {
    
    string public constant symbol = "REM";
    string public constant name = "REM";
    uint8 public constant decimals = 18;
    uint256 private _unmintedTokens = 200000000000*uint(10)**decimals;

    mapping(address => uint) balances;  
    mapping (address => mapping (address => uint256)) internal allowed;
    
	
	 
    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }
    
     
    function transfer(address _to, uint _value, bytes _data) {
         
         


        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value, _data);
    }
    
     
    function transfer(address _to, uint _value) {
        bytes memory empty;

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value, empty);
    }
    
             
    function mintTokens(address _target, uint256 _mintedAmount) public onlyOwner returns (bool success){
        require(_mintedAmount <= _unmintedTokens);
        balances[_target] += _mintedAmount;
        _unmintedTokens -= _mintedAmount;
        totalSupply += _mintedAmount;
        return true;
    }
    
      
    function mintTokensWithApproval(address _target, uint256 _mintedAmount, address _spender) public onlyOwner returns (bool success){
        require(_mintedAmount <= _unmintedTokens);
        balances[_target] += _mintedAmount;
        _unmintedTokens -= _mintedAmount;
        totalSupply += _mintedAmount;
        allowed[_target][_spender] += _mintedAmount;
        return true;
    }
    
      
    function burnUnmintedTokens(uint256 _burnedAmount) public onlyOwner returns (bool success){
        require(_burnedAmount <= _unmintedTokens);
        _unmintedTokens -= _burnedAmount;
        return true;
    }

   
}