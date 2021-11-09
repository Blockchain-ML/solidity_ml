pragma solidity ^0.4.24;


contract Game   {

    using SafeMath for uint256;
    
    uint8 constant public STONE = 10;
    uint8 constant public PAPER = 20;
    uint8 constant public SCISSORS = 30;
    uint8 constant public NONE = 0;

    struct Game {
        address firstPlayer;
        bytes32 firstPlayerHash;
        uint firstPlayerChoice;
        uint firstPlayerValue;
        address secondPlayer;
        uint secondPlayerChoice;
        uint secondPlayerValue;
        uint result;
        bool closed;
    }

    mapping (uint => Game) public games;

    uint public gameId = 0;

    function createGame(bytes32 Hash) public payable returns (uint){

        gameId++;
        games[gameId].firstPlayer = msg.sender;
        games[gameId].firstPlayerHash = Hash;
        games[gameId].firstPlayerChoice = NONE;
        games[gameId].firstPlayerValue = msg.value;

        return gameId;
    }


    function joinToGame(uint gameId, uint8 choice) public payable returns (uint){

        games[gameId].secondPlayer = msg.sender;
        games[gameId].secondPlayerChoice = choice;
        games[gameId].secondPlayerValue = msg.value;

        return gameId;
    }

    function checkWinner(uint gameid, uint8 choice, bytes32 randomSecret) public returns (bool) {
        bytes32 proof = getProof(msg.sender, choice, randomSecret);

        Game memory game;
        game = games[gameId];

        require(!game.closed);
        require(game.firstPlayer == msg.sender && proof == game.firstPlayerHash );

        uint getPay = game.firstPlayerValue.add(game.secondPlayerValue);

        if (game.secondPlayerChoice == choice)  {
            msg.sender.send(game.firstPlayerValue);
            game.secondPlayer.send(game.secondPlayerValue);
        }

        if (game.secondPlayerChoice == STONE)  {
            if(choice == PAPER) {
                msg.sender.send(getPay);
            }
            if(choice == SCISSORS) {
                game.secondPlayer.send(getPay);
            }
        }

        if (game.secondPlayerChoice == PAPER)  {
            if(choice == STONE) {
                game.secondPlayer.send(getPay);
            }
            if(choice == SCISSORS) {
                msg.sender.send(getPay);
            }
        }

        if (game.secondPlayerChoice == SCISSORS)  {
            if(choice == STONE) {
                msg.sender.send(getPay);
            }
            if(choice == PAPER) {
                game.secondPlayer.send(getPay);
            }
        }

        games[gameId].closed = true;

        return true;
    }

    function getProof(address sender, uint8 choice, bytes32 randomSecret) public view returns (bytes32){
        return sha3(sender, choice, randomSecret);
    }

}


library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);  
        uint256 c = a / b;
         

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}