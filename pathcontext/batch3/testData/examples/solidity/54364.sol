pragma solidity ^0.4.24;

contract ERC20Token {
    function transferFrom(address from, address to, uint256 value) public returns (bool);
}

contract AirDrop {

    function() payable public {}

     
    ERC20Token public ORSToken = ERC20Token(0x0A22dccF5Bd0fAa7E748581693E715afefb2F679);

     
    function batchTransferORS(address[] _addresses, uint _value) public {
         
        for (uint i = 0; i < _addresses.length; i++) {
            ORSToken.transferFrom(msg.sender, _addresses[i], _value);
        }
    }

     
    function batchTransferORSS(address[] _addresses, uint[] _value) public {
        require(_addresses.length == _value.length);

         
        for (uint i = 0; i < _addresses.length; i++) {
            ORSToken.transferFrom(msg.sender, _addresses[i], _value[i]);
        }
    }

     
    function batchTransferToken(address _contractAddress, address[] _addresses, uint _value) public {
        ERC20Token token = ERC20Token(_contractAddress);
         
        for (uint i = 0; i < _addresses.length; i++) {
            token.transferFrom(msg.sender, _addresses[i], _value);
        }
    }

     
    function batchTransferTokenS(address _contractAddress, address[] _addresses, uint[] _value) public {
        require(_addresses.length == _value.length);

        ERC20Token token = ERC20Token(_contractAddress);
         
        for (uint i = 0; i < _addresses.length; i++) {
            token.transferFrom(msg.sender, _addresses[i], _value[i]);
        }
    }

     
    function batchTransferETH(address[] _addresses) payable public {
         
        for (uint i = 0; i < _addresses.length; i++) {
            _addresses[i].transfer(msg.value / _addresses.length);
        }
    }

     
    function batchTransferETHS(address[] _addresses, uint[] _value) payable public {
        require(_addresses.length == _value.length);

         
        for (uint i = 0; i < _addresses.length; i++) {
            _addresses[i].transfer(_value[i]);
        }
    }
}