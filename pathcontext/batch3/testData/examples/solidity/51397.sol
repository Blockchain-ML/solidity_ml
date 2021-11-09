pragma solidity ^0.4.17;

 
contract BatchTokenSender {
     
    address public creator;

     
    address public owner;

     
    Token public token;

     
    uint256 public lotSize;

     
    constructor (Token _token, uint256 _lotSize) public {
        token = _token;
        lotSize = _lotSize;
        owner = msg.sender;
        creator = msg.sender;
    }

     
    function transfer(address newOwner) public {
        require (msg.sender == owner);
        owner = newOwner;
    }

     
    function batchSendLotFrom (address [] _addresses) public {
        require (msg.sender == owner);
        for (uint256 i = 0; i < _addresses.length; i++) {
            if (!token.transferFrom (msg.sender, _addresses [i], lotSize)) revert ();
        }
    }

     
    function batchSendLot (address [] _addresses) public {
        require (msg.sender == owner);
        for (uint256 i = 0; i < _addresses.length; i++) {
            token.transfer (_addresses [i], lotSize);
        }
    }

     
    function batchSendFrom (uint256 [] _transfers) public {
        require (msg.sender == owner);
        for (uint256 i = 0; i < _transfers.length; i++) {
            uint256 _value = _transfers [i] >> 160;
            address _to = address (_transfers [i] & 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            if (!token.transferFrom (msg.sender, _to, _value)) revert ();
        }
    }

     
    function batchSend (uint256 [] _transfers) public payable {
        require (msg.sender == owner);
        for (uint256 i = 0; i < _transfers.length; i++) {
            uint256 _value = _transfers [i] >> 160;
            address _to = address (_transfers [i] & 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            token.transfer (_to, _value);
        }
    }

     
    function transfer (Token _token, uint160 _value, address _to) public {
        require (msg.sender == owner);
        _token.transfer (_to, _value);
    }

     
    function kill () public {
        require (msg.sender == owner);
        selfdestruct (owner);
    }
}

 
contract Token {
     
    function totalSupply ()
    public constant returns (uint256 supply);

     
    function balanceOf (address _owner)
    public constant returns (uint256 balance);

     
    function transfer (address _to, uint256 _value)
    public returns (bool success);

     
    function transferFrom (address _from, address _to, uint256 _value)
    public returns (bool success);

     
    function approve (address _spender, uint256 _value)
    public returns (bool success);

     
    function allowance (address _owner, address _spender)
    public constant returns (uint256 remaining);

     
    event Transfer (address indexed _from, address indexed _to, uint256 _value);

     
    event Approval (
        address indexed _owner, address indexed _spender, uint256 _value);
}