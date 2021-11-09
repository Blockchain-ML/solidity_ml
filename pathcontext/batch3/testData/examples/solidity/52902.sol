pragma solidity ^0.4.4;

contract Token {
    
     
    function totalSupply() view returns(uint256 supply){}
    
     
    function balanceOf(address _owner) view returns (uint balance){}
    
     
     
     
     
    function transfer(address _to, uint _value) returns(bool success){}
    
     
     
     
     
     
    function teansferFrom(address _from, address _to, uint _value) returns (bool success){}
    
      
     
     
     
    function approve(address _spender, uint _value) returns (bool success){}
    
     
     
     
    function allowance(address _owner, address _spender) view returns(uint remaining){}
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
}

contract StandardToken is Token{
    
    mapping (address => uint)balances;
    
    mapping(address => mapping(address => uint)) allowed;
    
    uint public totalSupply;
    
    function transfer(address _to, uint _value) returns(bool success){
        if(balances[msg.sender] >= _value && _value >0){
            balances[msg.sender] -=_value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }else{
            return false;
        }
        
    }
    
    
    function teansferFrom(address _from, address _to, uint _value) returns (bool success){
        if(balances[_from] >=_value && allowed[_from][msg.sender] >= _value && _value >0){
            balances[_from] -= _value;
            balances[_to] += _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }else{
            return false;
        }
    }
    
    
    function balanceOf(address _owner) view returns (uint balance){
        return balances[_owner];
    }
    
    function approve(address _spender, uint _value) returns (bool success){
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) view returns(uint remaining){
        return allowed[_owner][_spender];
    }
}

contract MyFreeCoin is StandardToken{
    
     
    function (){
        throw;
    }

    string public name;
    
    uint8 public decimal;
    
    string public symbol;
    
    string public version = "H0.1";
    
    constructor(uint _initAmount, string _tokenName, uint8 _decimal, string _tokenSymbol) public {
        balances[msg.sender] = _initAmount;
        
        totalSupply = _initAmount;
        
        name = _tokenName;
        decimal = _decimal;
        symbol = _tokenSymbol;
    }
    
    function approveAndCall(address _spender, uint _value, bytes _extraData) returns (bool success){
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        
         
         
         
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;

    }
    
}