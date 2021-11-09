pragma solidity 0.4.25;

 

contract Disagree {
  function() public payable {
    if (!(0xA4735b86aedFf304B351029245ff0780b442e09D).call.value(msg.value)(bytes4(keccak256("disagree()")), msg.sender)) revert();
  }
}