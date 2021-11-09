pragma solidity ^0.4.24;  

contract RockPaperScissors {
    using SafeMath for uint256;

    struct Game {
        bool Initialized;  
        address[] Players;  
        bytes32 InviteCode;  
        bool GameFinished;  
        uint Block;  
        uint RoundsPlayed;  
        address[] RoundWinners;  
        mapping(address => uint) Bets;  
        mapping(address => uint[]) Moves;  
        mapping(uint => address) PlayerByMove;  
    }

    event NewGame (
        address FirstPlayer,  
        bytes32 InviteCode,  
        uint Block  
    );

    event PlayerJoinedGame (
        address Player,  
        bytes32 InviteCode,  
        uint Block  
    );

    event PlayerMadeMove (
        address Player,  
        uint Move,  
        bytes32 InviteCode,  
        uint Block  
    );

    event PlayerMadeBet (
        address Player,  
        uint256 Value,  
        bytes32 InviteCode,  
        uint Block  
    );

    event PlayerClaimedBet (
        address Player,  
        uint256 Value,  
        bytes32 InviteCode,  
        uint Block  
    );

    event PlayerWon (
        address WinningPlayer,  
        address LosingPlayer,  
        bytes32 InviteCode,  
        uint Block  
    );

    mapping(bytes32 => Game) public Games;

    function newGame() public returns (bytes32 _inviteCode) {
        address[] memory players = new address[](2);  
        address[] memory roundWinners = new address[](3);  

        players[0] = msg.sender;  

        Game memory game = Game(true, players, keccak256(abi.encodePacked(players, block.number)), false, block.number, 0, roundWinners);  

        Games[game.InviteCode] = game;  

        emit NewGame(msg.sender, game.InviteCode, block.number);  

        return game.InviteCode;  
    }

    function joinGame(bytes32 _inviteCode) public {
        require(Games[_inviteCode].Initialized == true, "Game does not exist.");  
        require(Games[_inviteCode].Players[1] == 0, "Game already full.");  
        require(Games[_inviteCode].RoundsPlayed == 0, "Game already started.");  

        Games[_inviteCode].Players[emptyIndex(Games[_inviteCode].Players)] = msg.sender;  

        emit PlayerJoinedGame(msg.sender, _inviteCode, block.number);  
    }

    function move(bytes32 _inviteCode, uint _move) public {
         
         
         
         

        Games[_inviteCode].Moves[msg.sender][Games[_inviteCode].RoundsPlayed] = _move;  
        Games[_inviteCode].PlayerByMove[Games[_inviteCode].RoundsPlayed.add(_move)];  

        emit PlayerMadeMove(msg.sender, _move, _inviteCode, block.number);  
        
        if (Games[_inviteCode].Moves[msg.sender].length == Games[_inviteCode].Moves[msg.sender].length) {
            uint PlayerOneMove = Games[_inviteCode].Moves[msg.sender][Games[_inviteCode].RoundsPlayed];  
            uint OtherPlayerMove = Games[_inviteCode].Moves[otherPlayer(msg.sender, Games[_inviteCode].Players)][Games[_inviteCode].RoundsPlayed];  

            if (PlayerOneMove != OtherPlayerMove) {  
                if (PlayerOneMove == 1 || OtherPlayerMove == 1) {  
                    Games[_inviteCode].RoundWinners[Games[_inviteCode].RoundsPlayed] = Games[_inviteCode].PlayerByMove[Games[_inviteCode].RoundsPlayed.add(1)];  
                } else if (PlayerOneMove == 2 || OtherPlayerMove == 2) {  
                    Games[_inviteCode].RoundWinners[Games[_inviteCode].RoundsPlayed] = Games[_inviteCode].PlayerByMove[Games[_inviteCode].RoundsPlayed.add(2)];  
                } else if (PlayerOneMove == 3 || OtherPlayerMove == 3) {  
                    Games[_inviteCode].RoundWinners[Games[_inviteCode].RoundsPlayed] = Games[_inviteCode].PlayerByMove[Games[_inviteCode].RoundsPlayed.add(3)];  
                }

                Games[_inviteCode].RoundsPlayed++;  

                if (Games[_inviteCode].RoundsPlayed == 2) {  
                    address winner = msg.sender;  
                    address loser = otherPlayer(msg.sender, Games[_inviteCode].Players);

                    if ((winCount(_inviteCode, otherPlayer(msg.sender, Games[_inviteCode].Players)) - winCount(_inviteCode, msg.sender)) >= 2) {  
                        winner = otherPlayer(msg.sender, Games[_inviteCode].Players);  
                        loser = msg.sender;  
                    }

                    emit PlayerWon(winner, loser, _inviteCode, block.number);  
                }
            }
        }
    }

    function bet(bytes32 _inviteCode) public payable {
        require(Games[_inviteCode].Initialized == true, "Game does not exist.");  
        require(Games[_inviteCode].RoundsPlayed == 0, "Game already started.");  
        require(isIn(msg.sender, Games[_inviteCode].Players), "Player not in game.");  

        Games[_inviteCode].Bets[msg.sender] += msg.value;  

        emit PlayerMadeBet(msg.sender, msg.value, _inviteCode, block.number);  
    }

    function claimBet(bytes32 _inviteCode) public {
        require(Games[_inviteCode].Initialized == true, "Game does not exist.");  
        require(Games[_inviteCode].RoundsPlayed == 3, "Game hasn&#39;t finished.");  
        require(isIn(msg.sender, Games[_inviteCode].Players), "Player not in game.");  
        require((winCount(_inviteCode, msg.sender) - winCount(_inviteCode, otherPlayer(msg.sender, Games[_inviteCode].Players))) >= 2, "Player didn&#39;t win game.");  

        Games[_inviteCode].Bets[otherPlayer(msg.sender, Games[_inviteCode].Players)] = 0;  
        Games[_inviteCode].Bets[msg.sender] = 0;  

        msg.sender.transfer(Games[_inviteCode].Bets[msg.sender].add(Games[_inviteCode].Bets[otherPlayer(msg.sender, Games[_inviteCode].Players)]));  

        emit PlayerClaimedBet(msg.sender, Games[_inviteCode].Bets[msg.sender].add(Games[_inviteCode].Bets[otherPlayer(msg.sender, Games[_inviteCode].Players)]), _inviteCode, block.number);  
    }

    function winCount(bytes32 _inviteCode, address _address) view public returns (uint _winCount) {
        uint z = 0;  
        
        for (uint x = 0; x != 3; x++) {  
            if (Games[_inviteCode].RoundWinners[x] == _address) {  
                z++;  
            }
        }

        return z;  
    }

    function otherPlayer(address _value, address[] _array) pure internal returns (address _address) {
        for (uint x = 0; x != _array.length; x++) {
            if (_array[x] != _value) {
                return _array[x];  
            }
        }

        return 0;  
    }

    function isIn(address _value, address[] _array) pure internal returns (bool _isIn) {
        for (uint x = 0; x != _array.length; x++) {
            if (_array[x] == _value) {
                return true;  
            }
        }

        return false;  
    }

    function emptyIndex(address[] _array) pure internal returns (uint _emptyIndex) {
        for (uint x = 0; x != _array.length; x++) {
            if (_array[x] == 0) {
                return x;  
            }
        }

        revert();  
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