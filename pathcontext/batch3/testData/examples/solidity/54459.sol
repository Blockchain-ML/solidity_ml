pragma solidity ^0.4.18;


 
contract PureAirToken {
     
    string public standard = "Token 0.1";
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;

     
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    function PureAirToken(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
    ) public {
        balanceOf[msg.sender] = initialSupply;
        owner = msg.sender;

         
        totalSupply = initialSupply;
         
        name = tokenName;
         
        symbol = tokenSymbol;
         
        decimals = decimalUnits;
         
    }

     
    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);
         
        if (balanceOf[_to] + _value < balanceOf[_to]) revert();  
         
        balanceOf[msg.sender] -= _value;
         
        balanceOf[_to] += _value;
         
        emit Transfer(msg.sender, _to, _value);
         
    }

    function changeName(string newName) public {
        require (msg.sender == owner);
        name = newName;
    }

    function changeSymbol(string newSymbol) public {
        require (msg.sender == owner);
        symbol = newSymbol;
    }

    function issueOwnerMore(uint256 _value) public {
        require (msg.sender == owner);
        require (totalSupply + _value > totalSupply);  
        require (balanceOf[msg.sender] + _value > balanceOf[msg.sender]);  
        totalSupply += _value;
    }
}