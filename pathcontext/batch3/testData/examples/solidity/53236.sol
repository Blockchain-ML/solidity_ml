pragma solidity ^0.4.16;

 
contract owned {
    address public owner; 

    constructor () public {
        owner = msg.sender; 
    }
   
    
    modifier onlyOwner {
        require(msg.sender == owner); 
        _;
    }
   
     
    function transferOwnerShip(address newOwer) public onlyOwner {
        owner = newOwer;
    }
}

 
interface token {
    function transfer(address receiver, uint amount) external ;
}

 
contract Ico is owned{
    address public beneficiary; 
    uint public fundingGoal; 
    uint public amountRaised; 

    uint public deadline; 
    uint public price; 
    token public tokenReward; 

    mapping(address => uint256) public balanceOf; 
    bool crowdsaleClosed = false; 
    
    mapping (address => bool) public paradropStatus; 

     
    event FundTransfer(address backer, uint amount, bool isContribution);
     
    event GoalReached(address recipient, uint totalAmountRaised);

     
    constructor (
        uint fundingGoalInEthers, 
        uint durationInMinutes, 
        uint etherCostOfEachToken, 
        address addressOfTokenUsedAsReward  
    ) public {
        beneficiary = msg.sender;
        fundingGoal = fundingGoalInEthers * 1 ether;  
        deadline = now + durationInMinutes * 1 minutes;   
        price = etherCostOfEachToken * 1 ether;   
        tokenReward = token(addressOfTokenUsedAsReward); 
    }
 
    
   function setPrice(uint etherCostofEachToken) public onlyOwner{
price = etherCostofEachToken * 1 ether; 
   }

    
    function () public payable {
        require(!crowdsaleClosed); 

        uint amount = msg.value;   
        balanceOf[msg.sender] += amount;  
        amountRaised += amount; 
        uint tomkenAmount = 0;
     	if ( amount == 0 && !paradropStatus[msg.sender]) { 
     	    tomkenAmount = 10;
     	    paradropStatus[msg.sender] = true;
        }  else {
     	    tomkenAmount = amount / price; 
        }
        tokenReward.transfer(msg.sender, tomkenAmount ); 
       
         
        emit FundTransfer(msg.sender, amount, true);
    }
   
    
    modifier afterDeadline() {
        if (now >= deadline) {
            _;
        }
    }

     
    function checkGoalReached() public afterDeadline {
        if (amountRaised >= fundingGoal) {
            
            emit GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true; 
    }
     
      
     function safeWithdrawal() public afterDeadline {
        if (amountRaised < fundingGoal) { 
            uint amount = balanceOf[msg.sender]; 
            balanceOf[msg.sender] = 0; 
            if (amount > 0) {
                msg.sender.transfer(amount); 
                 
                emit FundTransfer(msg.sender, amount, false);
            }
        }

        if (fundingGoal <= amountRaised && beneficiary == msg.sender) { 
            beneficiary.transfer(amountRaised); 
             
            emit FundTransfer(beneficiary, amountRaised, false);
        }
    }

}