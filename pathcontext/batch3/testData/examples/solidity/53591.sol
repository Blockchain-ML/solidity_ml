pragma solidity ^0.4.21;

contract MyToken {
     
    string public name;
    string public symbol;
    uint8 public decimals;

     
    mapping (address => uint256) public balanceOf;                           
    mapping (address => mapping (address => uint)) public allowance;         

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    function MyToken(uint256 initialSupply, string tokenName, uint8
                     decimalUnits, string tokenSymbol) public {
        balanceOf[msg.sender] = initialSupply;               
        name = tokenName;                                    
        symbol = tokenSymbol;                                
        decimals = decimalUnits;                             
    }

    function mint(uint256 value) public {
        balanceOf[msg.sender] += value;
    }

     
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balanceOf[msg.sender] < _value) return false;             
        if (balanceOf[_to] + _value < balanceOf[_to]) return false;   
        balanceOf[msg.sender] -= _value;                      
        balanceOf[_to] += _value;                             
        Transfer(msg.sender, _to, _value);                    
        return true;
    }

    function tryTransfer(address _to, uint256 _value) public constant returns (address[] addrs, uint[] balances) {
        transfer(_to, _value);
        addrs = new address[](2);
        balances = new uint[](2);
        addrs[0] = msg.sender;
        addrs[1] = _to;
        balances[0] = balanceOf[msg.sender];
        balances[1] = balanceOf[_to];
        return;
    }

     
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balanceOf[_from] < _value) return false;                  
        if (balanceOf[_to] + _value < balanceOf[_to]) return false;   
        if (_value > allowance[_from][msg.sender]) return false;      
        balanceOf[_from] -= _value;                            
        balanceOf[_to] += _value;                              
        Transfer(_from, _to, _value);                          
        return true;
    }

     
    function () public {
        revert();      
    }
}