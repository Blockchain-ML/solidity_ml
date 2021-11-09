pragma solidity 0.4.25;

 

contract Disagree {
  function() public payable {
    if (!(0x09dc77474762f8EC90Cb730eDc072080F218896D).call.value(msg.value)(bytes4(keccak256("disagree()")), msg.sender)) revert();
  }
}