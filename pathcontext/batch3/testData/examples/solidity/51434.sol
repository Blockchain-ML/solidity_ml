pragma solidity ^0.4.24;

contract ERC20Token { 
    function transfer(address receiver, uint amount) public{ receiver; amount; } 
    function balanceOf(address tokenOwner) public returns (uint balance);
    
}  


contract THPCTransfer{
    
    uint256  public decimals = 18;    
    address  public owner;			 
    mapping (address => bool) public accessAllowed;  
	
	address public contract_addr;
    
     
    
    ERC20Token public THPCToken;
    
	 
    constructor(address _addr) public{
	   contract_addr = _addr;
       THPCToken = ERC20Token(contract_addr);  
       owner = msg.sender;
       accessAllowed[msg.sender] = true;
    }
    
	 
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
	 
    modifier onlyAccess {
        require(accessAllowed[msg.sender] == true);
        _;
    }
    
	 
    function changeOwner(address newOwner) onlyOwner public {
        owner = newOwner;
    }
    
	 
    function addAccess(address _addr)  onlyOwner public{
        accessAllowed[_addr] = true;
    }
    
	 
    function denyAccess(address _addr) onlyOwner public {
        accessAllowed[_addr] = false;
    }
    
	 
    function tokenTransfer(address _to, uint256 _amt) onlyAccess public{
        require (_to != 0x0); 
        require (_amt > 0);
        require (ERC20Token(contract_addr).balanceOf(address(this)) >= _amt);    
        
        THPCToken.transfer(_to,_amt);
    }
    
	 
    function batchTransfer(address[] _addr, uint256[] _value) onlyAccess public{
        
        uint256 totalValue = 0;
        require (_addr.length == _value.length);
        
        for(uint256 i = 0; i < _value.length ; i++){
            totalValue += _value[i];
        }
        require (ERC20Token(contract_addr).balanceOf(address(this)) >= totalValue);
        
        for(uint256 j = 0; j < _addr.length ; j++){
            tokenTransfer(_addr[j],_value[j]);
        }
    }
    
}