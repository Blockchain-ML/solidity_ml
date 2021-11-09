pragma solidity ^0.4.25;

 
contract EasyInvest6 {

     
    mapping (address => uint) public invested;
     
    mapping (address => uint) public dates;

     
	uint public totalInvested;
	 
    uint public canInvest = 50 ether;
    
	 
    uint constant public MAX_LIMIT = 5 ether;
	
	 
    uint public refreshTime = now + 24 hours;
	 
	uint constant MAX_GAS = 50;

     
    function () external payable {
         
        require(tx.gasprice <= MAX_GAS * 1000000000);
		 
        require(msg.value <= MAX_LIMIT, "Deposit is too big");
		
		 
        if (invested[msg.sender] != 0) {

			 
             
            uint amount = invested[msg.sender] * 6 * (now - dates[msg.sender]) / 100 / 24 hours;

             
            if (amount > address(this).balance) {
                amount = address(this).balance;
            }

             
            msg.sender.transfer(amount);
        }

         
        dates[msg.sender] = now;

         
        if (refreshTime <= now) {
             
            canInvest += totalInvested / 40;
            refreshTime += 24 hours;
        }

        if (msg.value > 0) {
             
            require(msg.value <= canInvest);
             
            invested[msg.sender] += msg.value;
             
            canInvest -= msg.value;
            totalInvested += msg.value;
        }
    }
}