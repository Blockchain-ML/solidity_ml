pragma solidity ^0.4.21;

contract SmartBetLive {
     
    uint public winnerPercentage;

     
    uint public othersPercentage;

     
    uint public expirationTime;

     
    address public currentWinner;

     
    uint public minimumAmount;

     
    address[] public uniquePlayers;

     
    mapping (address=>bool) private allPlayers;

     
    address public owner;

     
    uint public totalRaised;

     
    event NotifyNewPayment();

     
    constructor(uint wP, uint oP, uint ma, uint gameDurationInMinutes) public {
         
        require(wP > 0 && wP < 101);
        winnerPercentage = wP;

         
        require(oP > 0 && oP < 101);
        othersPercentage = oP;

         
        owner = msg.sender;

         
        minimumAmount = ma;

         
        expirationTime = (gameDurationInMinutes * 60) + now;
    }

     
    function () public payable {
        
         
        require(expirationTime > now);

         
        require(msg.value >= minimumAmount);

         
        if(allPlayers[msg.sender] == false) {
            allPlayers[msg.sender] = true;
            uniquePlayers.push(msg.sender);
        }
        
         
        currentWinner = msg.sender;

         
        totalRaised += msg.value;

         
        emit NotifyNewPayment();
    }

     
    function sendPrizes() public {

         
        require(expirationTime < now);

         
        require(msg.sender == owner);

         
        uint amount = address(this).balance;

         
        require(amount > 0);

         
        uint prizeForWinner = amount * winnerPercentage / 100;

         
        currentWinner.transfer(prizeForWinner);

         
        uint remainingMoneyForTeam = amount - prizeForWinner;

         
        if(uniquePlayers.length > 1) {

             
            uint prizeForOthers = amount * othersPercentage / 100;

             
            remainingMoneyForTeam = remainingMoneyForTeam - prizeForOthers;

             
            prizeForOthers = prizeForOthers / (uniquePlayers.length - 1);

             
            for(uint i = 0; i < uniquePlayers.length; i++) {
                 
                if(uniquePlayers[i] != currentWinner) {
                    uniquePlayers[i].transfer(prizeForOthers);
                }
            }
        }

         
        owner.transfer(remainingMoneyForTeam);

         
        emit NotifyNewPayment();
    }

     
     
    function getData() public view returns (uint, uint, uint, address, uint, uint, uint, uint, uint, uint) {
         
        uint prizeForWinner = totalRaised * winnerPercentage / 100;

         
        uint prizeForOthers = 0;

         
        if(uniquePlayers.length > 1) {
             
            prizeForOthers = totalRaised * othersPercentage / 100;

             
            prizeForOthers = prizeForOthers / (uniquePlayers.length - 1);
        }
        return (
            winnerPercentage, 
            othersPercentage, 
            minimumAmount, 
            currentWinner, 
            uniquePlayers.length, 
            expirationTime,
            totalRaised,
            prizeForWinner, 
            prizeForOthers,
            address(this).balance
        );
    }
}