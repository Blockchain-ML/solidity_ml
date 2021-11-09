pragma solidity ^0.4.18;
contract MyToken {
   mapping (address => uint256) public balance;
   string public name;
   string public symbol;
   uint8 public decimals;
   uint256 public totalSupply;

   event Transfer(address indexed from, address indexed to, uint256 value);
    

   function MyToken(uint256 initialSupply, string tokenName,
   string tokenSymbol, uint8 decimalUnits) {
        
       balance[msg.sender] = initialSupply;
          
        name = tokenName;
         
        symbol = tokenSymbol;
         
        decimals = decimalUnits;
         
        totalSupply = initialSupply;
    }

     
    function transfer(address _to, uint256 _value) {
        
        require(balance[msg.sender] >= _value);
         
        require(balance[_to] + _value >= balance[_to]);
         
        balance[msg.sender] -= _value;
         
        balance[_to] += _value;
         

        Transfer(msg.sender, _to, _value);
    }

     
    function name() constant returns (string) {
     return name;
    }

     
    function symbol() constant returns (string) {
     return symbol;
    }

     
    function decimals() constant returns (uint8) {
     return decimals;
    }

     
    function totalSupply() constant returns (uint256) {
     return totalSupply;
    }
    
     
    function balanceOf(address _owner)  constant returns (uint256) {
     return balance[_owner];
    }
}