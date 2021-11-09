pragma solidity ^0.4.25;

contract ERC20Basic {
   function balanceOf(address _who) public constant returns (uint256);
   function transfer(address _to, uint256 _value) public returns (bool);
   event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
    function allowance(address _owner, address _spender) public constant returns (uint256);
    function approve(address _spender, uint256 _value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
}


contract BasicToken is ERC20Basic {
    
    mapping (address => uint) balances;
    
     
    function balanceOf(address _who) public view returns (uint256) {
        return balances[_who];
    }
    
    
     
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balanceOf(msg.sender) >= _value);
        require(balanceOf(_to) > balanceOf(_to) + _value);
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;  
    }
}


contract StandardToken is ERC20, BasicToken {
    
    mapping (address => mapping (address => uint)) public allowances;
    
     
    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return allowances[_owner][_spender];
    }
    
     
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    
     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(allowance(_from, msg.sender) >= _value);
        require(balanceOf(_from) >= _value);
        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value;
        allowances[_from][msg.sender] = allowances[_from][msg.sender] - _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}


contract HackSussexCoin is StandardToken {
    
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;
    
    constructor() public {
        name = "Hack Sussex Coin";
        symbol = "HSC";
        decimals = 18;
        totalSupply = 10000000e18;  
        balances[msg.sender] = totalSupply;
        emit Transfer(address(this),msg.sender, totalSupply);
    }
}