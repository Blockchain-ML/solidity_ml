pragma solidity ^0.4.23;

 
contract KingOfTheHill {

  event winnerAnnounced(address winner, string yourName);

   
  mapping(address => uint) public balances;
  address public king;
  uint public allowedChanges;
  uint public changesMade;
  bool public endOfGame;

  constructor(uint _allowedChanges) public {
    allowedChanges = _allowedChanges;
  }

  modifier onlyKing() {
    require(msg.sender == king);
    _;
  }

   
  function setKing() public payable {
    require(!endOfGame);
     
    require(msg.value == 100000000000000000);
    require(msg.sender != king);
    king = msg.sender;
    balances[king] = balances[king] + msg.value;
    changesMade += 1;
  }

   
  function announceEndOfGame() public onlyKing {
    require(changesMade >= allowedChanges);
    endOfGame = true;
  }

   
  function withdrawBalance() public {
    require(endOfGame);
    msg.sender.call.value(balances[msg.sender])();
    balances[msg.sender] = 0;
  }

   
  function announceVictory(string yourName) public onlyKing {
    require(endOfGame && address(this).balance == 0);
    emit winnerAnnounced(msg.sender, yourName);
  }
}