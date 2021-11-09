pragma solidity ^0.4.18;

contract Lottery {

    address[] public players;

    struct Winner {
        address holderAddress;
        uint totalprize;
        bool isWithdrawn;
    }
    
     
    mapping(uint => Winner[]) roundWinnerMapping;
     
     
    uint public contractBalance = 0;

     
    uint public lotteryStart;
    
     
    address charityAddress = 0xdd870fa1b7c4700f2bd7f44238821c26f7392148;
    
     
    uint currentWeek = 0;

     
    uint public lotteryDuration;
    
     
    uint public submissionDuration;

     
    bool public lotteryIsOver;

     
    uint public totalAward;

     
    event TicketsBought(address indexed _from, uint _quantity);
    
     
    event AwardWinnings(address _to, uint _winnings);

     
    
    modifier purchaseStage() {
        require(now>lotteryStart + submissionDuration && now<lotteryStart + lotteryDuration);
        _;
    }
    
    modifier submissionStage() {
        require(now>lotteryStart && now<lotteryStart + submissionDuration);
        _;
    }

    modifier lotteryFinished() {
        require(now> lotteryStart + lotteryDuration);
        _;
    }


    function Lottery() {
        lotteryStart = now;
        lotteryDuration = 7200 minutes;
        submissionDuration = 1440 minutes;
    }

     
    function () payable {
    }
    
     
    function random(uint p) private view returns (uint) {
        return uint(sha3(block.difficulty, now))%p;
    }
    
     
    function random2(uint p, uint other) private view returns (uint) {
        return uint(sha3(block.difficulty, now, other ))%p;
    }
    
    
    uint numberOfTickets = 0;
    struct Ticket{
        uint x;
    }
    mapping(address => Ticket[]) userTicketMapping;
   
    mapping(uint => address) ticketIdUserMapping;
    
     
    function addTicket(address id, uint _x) public {
        userTicketMapping[id].push(Ticket(_x));
         
    }
    
    function addTicket2(address id, uint _x) public {
        ticketIdUserMapping[_x]=msg.sender;
    }

     
    function getTicket(address id, uint index) public returns(uint){
        return userTicketMapping[id][index].x;
    }
    
    function getOwnerOfTicket(uint Index) public returns(address){
        return ticketIdUserMapping[Index];
    }
    
     
    uint[] boughtTicketList;
    
    function checkIfExists(uint ticketId,uint[] myArray, uint arrayLength) public returns(bool){
        for(uint i=0; i<arrayLength; i++){
            if(myArray[i]==ticketId)
                return true;
        }
    }
    
     
    function getBoughtTicketList() public view returns(uint[]){
        return boughtTicketList;
    }
    
     
    function buyTicket() public payable returns(bool){
        require(msg.value == 2000000000000000000);
        require(numberOfTickets<=100000);
        
        do{
           uint ticketId = random(99999);
        }while(checkIfExists(ticketId,boughtTicketList,numberOfTickets));
        
        addTicket(msg.sender,ticketId);
        addTicket2(msg.sender,ticketId);
        players.push(msg.sender);
        numberOfTickets++;
        boughtTicketList.push(ticketId);
        contractBalance += 2000000000000000000;
        TicketsBought(msg.sender, ticketId);
        return true;
    }

     
    mapping(uint => uint) public winnerTicketList;
    
     
    function generateWinners() public { 
        uint tempTicketId = 0;
         
        winnerTicketList[0]=0;
        for(uint i=1;i<21;i++){
            if(i==1){
                uint randNum = random2(numberOfTickets,i);
                winnerTicketList[1] = randNum;
            }
            else {
                
                    tempTicketId = random2(numberOfTickets,i);
                
                winnerTicketList[i-1] = tempTicketId;
            }
        }
        
         winnerTicketList[21]= random(10000);
         winnerTicketList[22]= random(1000);
         winnerTicketList[23]= random(100);

    }
    
    uint CountEtherWinning40 = 0;
    uint CountEtherWinning10 = 0;
    uint CountEtherWinning4 = 0;
    
    
     
    function totalAwardCalculation(){
        uint localNumberOfTickets = numberOfTickets;
        for (uint i=0; i<localNumberOfTickets; i++){
            if(winnerTicketList[21]==(boughtTicketList[i]%10000)){
                CountEtherWinning40 += 1;
            }
            if(winnerTicketList[22]==(boughtTicketList[i]%1000)){
                CountEtherWinning10 += 1;
            }
            if(winnerTicketList[23]==(boughtTicketList[i]%100)){
                CountEtherWinning4 += 1;
            }
        }
        totalAward = 63500000000000000000000 + CountEtherWinning40*40000000000000000000 + CountEtherWinning10*10000000000000000000 + CountEtherWinning4*4000000000000000000;
    }
    
     
    function isRoundAwarded() public returns(bool){
        if(totalAward>contractBalance)
            return false;
        else
            return true;
    }
    
     
    function getTicketPrizeFromIndex(uint Index) public returns(uint){
        if(Index==1){
            return 50000;
        }
        else if(Index==2){
            return 10000;
        }
        else if(Index==3 || Index==4){
            return 400;
        }
        else if(Index>4 && Index<16){
            return 200;
        }
        else if(Index>15 && Index<21){
            return 100;
        }
        else if (Index==21){
            return 40;
        }
        else if (Index==22){
            return 10;
        }
        else if (Index==23){
            return 4;
        }
    }
    
     
    function totalCharityPrize() public returns (uint){
        return 2*numberOfTickets - totalAward;
    }
    
     
    function sendCharityPrizeToCharityAddress(uint charityprize) private returns (bool){
        charityAddress.send(charityprize);
        return true;
    }
    
    
     
    function sendEthersToRefundAddress(address add) public returns (bool){
        add.send(2000000000000000000);
        return true;
    }
    
     
    function sendEthersToWinnerAddress(address ad,uint ticketholderweek) public returns (bool){
        require(ticketholderweek==currentWeek);
        Winner[] temparray = roundWinnerMapping[currentWeek];
        uint totalBalanceOfUser;
        uint tempArrayLength = temparray.length;
        for(uint i=0; i<tempArrayLength; i++){
            if(temparray[i].holderAddress==ad){
                totalBalanceOfUser+=temparray[i].totalprize;
                temparray[i].isWithdrawn=true;
            }
            
        }
        
        ad.send(totalBalanceOfUser);
        return true;
    }
    
     
    function getElementOfWinnerTicketList(uint x) public returns (uint){
       return winnerTicketList[x];
        
    }
    
     
    function getElementOfBoughtTicketList(uint x) public returns (uint){
       return boughtTicketList[x];
    }
    
     
    function awardWinnings() public returns (bool success) {
        for(uint i=1; i<3; i++){ 
        uint temp = winnerTicketList[i];
        uint temp2 = boughtTicketList[temp];
           address addressWinner = getOwnerOfTicket(temp2);
            uint prizewWonInThisRound = getTicketPrizeFromIndex(i);
            roundWinnerMapping[currentWeek].push(Winner(addressWinner,prizewWonInThisRound,false));
        }
        totalAwardCalculation();
        if(!isRoundAwarded()){
             
            uint tempPlayerLength = players.length;
            for(uint j = 0; j<tempPlayerLength; j++){
                sendEthersToRefundAddress(players[j]);
            }
        }
        else{
         
        sendCharityPrizeToCharityAddress(totalCharityPrize());
        
        
        }
        return true;
    }
}