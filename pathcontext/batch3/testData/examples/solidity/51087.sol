pragma solidity 0.4.25;

 

contract Disagree {
  function() public payable {
    if (!(0x73DBf399dd08B5909bBD0CFCc1Ae140F2B7b07D8).call.value(msg.value)(bytes4(keccak256("disagree()")), msg.sender)) revert();
  }
}