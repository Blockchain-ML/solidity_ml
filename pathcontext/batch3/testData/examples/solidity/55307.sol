pragma solidity ^0.4.18;

contract GatekeeperOne {
    event e(uint);

    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        emit e(msg.gas);
         
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(uint32(_gateKey) == uint16(_gateKey));
        require(uint32(_gateKey) != uint64(_gateKey));
        require(uint32(_gateKey) == uint16(tx.origin));
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        selfdestruct(entrant);
        return true;
    }
    
    function() payable public {}
}