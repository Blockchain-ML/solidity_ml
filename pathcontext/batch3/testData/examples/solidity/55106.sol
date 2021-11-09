pragma solidity ^0.4.22;

contract Logger {

     
    mapping(address => uint) pendingReturns;

     
    bool ended;

     
    event LogEvent(bytes data);

     
     
    function() payable public {
        emit LogEvent(msg.data);
    }
}