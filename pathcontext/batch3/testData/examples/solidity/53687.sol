pragma solidity 0.4.19;

contract ITokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract SampleToken {
     
    string public standard = "Token 0.1";
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

     
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Burn(address indexed from, uint256 value);

     
    function SampleToken(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
        ) {
        balanceOf[msg.sender] = initialSupply;               
        totalSupply = initialSupply;                         
        name = tokenName;                                    
        symbol = tokenSymbol;                                
        decimals = decimalUnits;                             
    }

     
    function transfer(address _to, uint256 _value) {
        if (_to == 0x0) revert();                                
        if (balanceOf[msg.sender] < _value) revert();            
        if (balanceOf[_to] + _value < balanceOf[_to]) revert();  
        balanceOf[msg.sender] -= _value;                      
        balanceOf[_to] += _value;                             
        Transfer(msg.sender, _to, _value);                    
    }

     
    function approve(address _spender, uint256 _value)
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        returns (bool success) {
        ITokenRecipient spender = ITokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

     
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) revert();                                 
        if (balanceOf[_from] < _value) revert();                  
        if (balanceOf[_to] + _value < balanceOf[_to]) revert();   
        if (_value > allowance[_from][msg.sender]) revert();      
        balanceOf[_from] -= _value;                            
        balanceOf[_to] += _value;                              
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value) returns (bool success) {
        if (balanceOf[msg.sender] < _value) revert();             
        balanceOf[msg.sender] -= _value;                       
        totalSupply -= _value;                                 
        Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) returns (bool success) {
        if (balanceOf[_from] < _value) revert();                 
        if (_value > allowance[_from][msg.sender]) revert();     
        balanceOf[_from] -= _value;                           
        totalSupply -= _value;                                
        Burn(_from, _value);
        return true;
    }
}