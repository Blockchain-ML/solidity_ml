pragma solidity ^0.4.24;

contract ERC20Token {
    function transferFrom(address from, address to, uint value) public returns (bool);
}

contract StandardToken {
    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);
}

contract AirDropT {

     
    ERC20Token public ORSToken;

    constructor() public {
        ORSToken = ERC20Token(0x0A22dccF5Bd0fAa7E748581693E715afefb2F679);
    }

    function() payable public {}

     
    function batchTransferORS(address[] _addresses, uint _value) public {
         
        for (uint i = 0; i < _addresses.length; i++) {
            ORSToken.transferFrom(msg.sender, _addresses[i], _value);
        }
    }

     
    function batchTransferORSB(address[] _addresses, uint _value) public {
        ERC20Token token = ERC20Token(0x0A22dccF5Bd0fAa7E748581693E715afefb2F679);
         
        for (uint i = 0; i < _addresses.length; i++) {
            token.transferFrom(msg.sender, _addresses[i], _value);
        }
    }

     
    function batchTransferToken(address _contractAddress, address[] _addresses, uint _value) public {
         
        require(_addresses.length > 0);

        StandardToken token = StandardToken(_contractAddress);
         
        for (uint i = 0; i < _addresses.length; i++) {
            token.transferFrom(msg.sender, _addresses[i], _value);
        }
    }
}