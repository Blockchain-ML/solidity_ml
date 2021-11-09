pragma solidity ^0.4.18;

contract Token {

     
    function totalSupply() constant returns (uint256 supply) {}

     
    function balanceOf(address _owner) constant returns (uint256 balance) {}

     
    function transfer(address _to, uint256 _value) returns (bool success) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

contract StandToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
         
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    mapping (address => uint256) balances;
    uint256 public totalSupply;
}

contract test222 is StandToken {

     
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    
     
    constructor() {
        totalSupply = 3 * 1000 * 1000 * 1000;    
        balances[msg.sender] = totalSupply;               
        
        name = "test222";                        
        decimals = 18;                           
        symbol = "TS";                           
    }
}