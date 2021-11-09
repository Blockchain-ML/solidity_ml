pragma solidity ^0.4.4;

contract LuckyDraw {

    address[] private validTickets ;
    mapping(address =>bool) validTicketMapping;

    address[] public receivedTickets ;
    mapping(address =>bool) receivedTicketMapping;

    address private owner; 
    address[] private winners;
    uint[] private seeds;
    bool public isTimeUp;
    uint public stopBlockNumber; 
    uint public startBlockNumber; 
    uint[] public drawBlockNumbers; 

    constructor (address[] _tickets, uint firstTimeSeed) public {
        
        for (uint index = 0; index < _tickets.length; index++) {
            validTickets.push(_tickets[index]);
            validTicketMapping[_tickets[index]] = true;
            
        }
        isTimeUp = true;  
        seeds.push(firstTimeSeed);
        owner = msg.sender;
    } 

    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }

    event TicketReceive(address ticket, bool isvalidTicket, bool inExisted);
    event LogAddress(uint index, address anAddress);
    event LogNumber(uint value);
    event LogValue(string name, uint value);
     
     
     
     
     
     

    function generateRand() private returns (uint) { 
	     
        uint lastSeed = seeds[seeds.length -1];
        lastSeed = ((lastSeed*3 + 1) / 2)% 10**12;
        
        uint number = block.number;  
       
        uint diff = block.difficulty;  
        uint time = block.timestamp;  
        uint gas = block.gaslimit;  
        uint blockhash1 = uint(block.blockhash(number -1 ))%10**12;  
        uint blockhash2 = uint(block.blockhash(number -2 ))%10**12;  
        
         
        uint total = lastSeed * number + diff + time + gas + blockhash1 + blockhash2;
        
         
        emit LogValue("number",number);
        emit LogValue("diff",diff);
        emit LogValue("time",time);
        emit LogValue("gas",gas);
        emit LogValue("blockhash1",blockhash1);
        emit LogValue("blockhash2",blockhash2);
        emit LogValue("lastSeed",lastSeed);
        emit LogValue("total",total);

        return total;
    }

    function stopReceiveTicket() public onlyOwner
    {
        isTimeUp = true;
        seeds[seeds.length-1] = receivedTickets.length;
        stopBlockNumber = block.number;
    }

    function startReceiveTicket() public onlyOwner
    {
        isTimeUp = false;
        startBlockNumber = block.number;
    }

    function receiveTicket(address ticket) public 
    {
        emit TicketReceive(ticket,validTicketMapping[ticket],receivedTicketMapping[ticket]);
        if (validTicketMapping[ticket] && !receivedTicketMapping[ticket] && !isTimeUp ) {
            receivedTicketMapping[ticket] = true;
            receivedTickets.push(ticket);
        } 
    }

    function draw() onlyOwner public 
    {
        uint256 rand = 0;
        if (isTimeUp && receivedTickets.length > 0) {
             
            do{
                rand = generateRand()%(receivedTickets.length);
            }while(!receivedTicketMapping[receivedTickets[rand]]  );
            winners.push(receivedTickets[rand]);
             
            drawBlockNumbers.push(block.number);
             
            seeds.push(rand);
             
            receivedTicketMapping[receivedTickets[rand]] = false;
             
            receivedTickets[rand] = receivedTickets[receivedTickets.length-1];
           
            receivedTickets.length--;
        }  
    }

    function reset(address[] _newTickets) public onlyOwner
    {
        emit LogAddress( _newTickets.length,  _newTickets[_newTickets.length-1]);
         
        for (uint index = 0; index < receivedTickets.length; index++) {
            receivedTicketMapping[receivedTickets[index]] = false;
        }
        delete receivedTickets;

          
        for (uint i = 0; i < validTickets.length; i++) {
            validTicketMapping[validTickets[i]] = false;
        }
        delete validTickets;

         
        delete winners;

         
        delete seeds;
         
        seeds.push(_newTickets.length);

        delete drawBlockNumbers;

         
        for (uint k = 0; k < _newTickets.length; k++) {
            emit LogAddress(k,_newTickets[k]);
            validTickets.push(_newTickets[k]);
            validTicketMapping[_newTickets[k]] = true;
            
        }
        
        
        isTimeUp = false;  
    }

    function getSeedByWinner(address winner) view public returns(uint) {
        for(uint index = 0; index < winners.length; index++) {
            if (winner == winners[index] && index < drawBlockNumbers.length){
                return seeds[index];
            }
        }
    }

    function getLastSeed() view public returns(uint) {
        return seeds[seeds.length-1];
    }

    function getLastDrawBlockNumber() view public returns(uint)
    {
        return drawBlockNumbers[drawBlockNumbers.length-1];
    }
    
    function getDrawBlockNumberByWinner(address winner) view public returns(uint)
    {
        for(uint index = 0; index < winners.length; index++) {
            if (winner == winners[index] && index < drawBlockNumbers.length){
                return drawBlockNumbers[index];
            }
        }
    }

    function getAllWinner() view public returns(address[])
    {
        return winners;
    }

    function getWinnerByDrawBlockNumber(uint blockNumber) view public returns(address)
    {
        for(uint index = 0; index < drawBlockNumbers.length; index++) {
            if (blockNumber == drawBlockNumbers[index] && index < winners.length){
                return winners[index];
            }
        }
    }

    function getstartBlockNumber() view public returns(uint)
    {
        return startBlockNumber;
    }
    function getstopBlockNumber() view public returns(uint)
    {
        return stopBlockNumber;
    }
    
    function getWinner(uint index) view public returns (address)
    {
        return winners[index];
    }

    function checkReceive(address ticket) view public returns(bool)
    {
        return receivedTicketMapping[ticket];
    }

    function checkWinner(address ticket) view public returns(bool)
    {
        for (uint8 index = 0; index < winners.length; index++) {
            
            if (winners[index] == ticket) {
                return true;
            } 
        }
        return false;
    }

    function gettotalReceivedTicket() view public returns(uint)
    {
        return receivedTickets.length;
    }

    function getTotalValidTk() view public returns (uint)
    {
        return validTickets.length;
    }

    function checkValidTk(address tk) view public returns (bool)
    {
        return validTicketMapping[tk];
    }


}