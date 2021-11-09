pragma solidity 0.4.24;

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function Ownable() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Lottery is Ownable{
    uint public minBet;
    uint public totalBets;
    uint public maxPlayers;
    uint public numberofBets;
    uint public maxAmountofBets;
    address[] public players;
    

    struct Player {
        uint betAmount;
        uint numSelect;
    }

     
    mapping (address => Player) public playerInfo;

    function() public payable {}

    function kill() public {
        if(msg.sender == owner) selfdestruct(owner);
    }

     
    function Lottery(uint256 _minBet, uint _maxPlayers, uint _maxAmountofBets) public {
        owner = msg.sender;
        if (_minBet > 0 ) minBet = _minBet;
        maxPlayers = _maxPlayers;
        maxAmountofBets = _maxAmountofBets;
    }
    
     
    function bet(uint numberSelect) public payable {
        require (numberSelect >= 1 && numberSelect <= 10);
        require (msg.value >= minBet);

        playerInfo[msg.sender].betAmount = msg.value;
        playerInfo[msg.sender].numSelect = numberSelect;
        numberofBets++;
        players.push(msg.sender);
        totalBets += msg.value;
        if(numberofBets >= maxAmountofBets) generateNum2Win();
    }
    
    uint public numberGenerated;
     
    function generateNum2Win() public {
        numberGenerated = block.number % 10 + 1;
        distributePrices(numberGenerated);
    }
    
     
    function distributePrices (uint numberWinner) public {
         
         
        address[10] memory winners;
         
        uint count = 0;
        for(uint i = 0; i < players.length; i++){
             
            address playerAddress = players[i];
            if (playerInfo[playerAddress].numSelect == numberWinner) {
                 
                winners[count] = playerAddress;
                count ++;
            }
             
            delete playerInfo[playerAddress];
        }
         
        players.length = 0;
         
        uint winnerEtherAmount = totalBets / winners.length;
         
        for(uint j = 0; j < count; j++){
            winners[j].transfer(winnerEtherAmount);
        }
        totalBets = 0;
        numberofBets = 0;
    }
}