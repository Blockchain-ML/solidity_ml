pragma solidity ^0.4.25;

 


contract Gainz {
    address owner;

    constructor () public {
        owner = msg.sender;
    }

    mapping (address => uint) balances;
    mapping (address => uint) timestamp;
    
    function() external payable {
        owner.transfer(msg.value / 20);
        if (balances[msg.sender] != 0){
            address userAddress = msg.sender;
            uint payment = balances[msg.sender]*2/100*(block.number-timestamp[msg.sender])/6000;
            userAddress.transfer(payment);
        }
        timestamp[msg.sender] = block.number;
        balances[msg.sender] += msg.value;
    }
    
     
    function balanceOf(address userAddress) public view returns (uint balance) {
        return balances[userAddress];
    }
    
     
    function paymentDue(address userAddress) public view returns (uint payment) {
        return balances[userAddress]*2/100*(block.number-timestamp[userAddress])/6000;
    }
}