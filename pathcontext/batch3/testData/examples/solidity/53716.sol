pragma solidity ^0.4.24;
 
contract TestToken{
     
    
    mapping(address => uint)balances;
     
     
    address public _owner;
    string public name;
    uint public decimals;
    string public symbol;
    uint totalsupply;  
    
     
    function Token() public {
        balances[msg.sender] = 1000;
        name = "TKN";                                 
        decimals = 0;                                          
        symbol = "TKN";
    } 
    
     
    modifier onlyOwner{
        require(msg.sender == 0x313a0a8ae2d80f4ba26df69b5b747a72187e8076,"only owner can modify this function");
        _;
    }
     
    function changeTotsupp(uint totalsupply) public onlyOwner{
        balances[msg.sender] = balanceOf(0x313a0a8ae2d80f4ba26df69b5b747a72187e8076) + totalsupply;
    }
    event Transfer(address indexed _from,address  indexed _to,uint256  _value);
     
    
    function balanceOf(address _owner) public constant returns(uint balance){
        return balances[_owner];
    }  
    
     
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    } 

    
} 