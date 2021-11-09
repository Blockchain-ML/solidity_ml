pragma solidity ^0.4.14;

interface token { 
    function transfer(address receiver, uint amount) external;
}

contract Crowdsale {
    address public beneficiary;  
    uint public fundingGoal;  
    uint public amountRaised;  
    uint public deadline;  
    uint public price;  
    token public tokenReward;  
    Funder[] public funders;  
 
    struct Funder {  
        address addr;
        uint amount;
    }
 
     
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    constructor(address _beneficiary, uint _fundingGoal, uint _duration, uint _price, address _reward) public {
        beneficiary = _beneficiary;  
        fundingGoal = _fundingGoal;  
        deadline = now + _duration * 1 minutes;  
        price = _price;  
        tokenReward = token(_reward);  
    }
    
    function () payable public {
        uint amount = msg.value;  
         
        funders[funders.length++] = Funder({addr: msg.sender, amount: amount});
         
        amountRaised += amount;
         
        tokenReward.transfer(msg.sender, amount / price);
         
        emit FundTransfer(msg.sender, amount, true);
    }
    
    modifier afterDeadline() { if (now >= deadline) _; }
 
    function checkGoalReached() public afterDeadline {
        if (amountRaised >= fundingGoal){  
            beneficiary.transfer(amountRaised);  
            emit FundTransfer(beneficiary, amountRaised, false);  
        } else {  
             
            for (uint i = 0; i < funders.length; ++i) {
              funders[i].addr.transfer(funders[i].amount);
              emit FundTransfer(funders[i].addr, funders[i].amount, false);
            }
        }
         
        selfdestruct(beneficiary);
    }
    
    
    
}