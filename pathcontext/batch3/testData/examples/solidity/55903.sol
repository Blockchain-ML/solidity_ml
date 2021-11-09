pragma solidity ^0.4.25;

contract OverflowDemo {
    
    mapping (address => uint8) public balanceOf;
    address owner;
    
     
    constructor(address otherAdress) public {
        owner = msg.sender;
        balanceOf[otherAdress] = 2^8 - 1;
        balanceOf[msg.sender] = 5;
    }
    
    function transfer(address targetAdress, uint8 amount) public {
        if(balanceOf[msg.sender] < amount) {
            revert();
        }
         
        uint8 oldBalanceOfTargetAddress = balanceOf[targetAdress];
        uint8 newBalanceOfTargetAddress =  oldBalanceOfTargetAddress + amount;
        balanceOf[targetAdress] = newBalanceOfTargetAddress;
    }
}