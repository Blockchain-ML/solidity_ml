pragma solidity ^0.4.24;

 


contract Example {

  constructor() public { }

   
  uint public count = 0;

   
  function () payable { emit Received(msg.sender, msg.value); }
  event Received (address indexed sender, uint value);

   
  function addAmount(uint256 amount) public returns (bool) {
    count = count + amount;
    return true;
  }
}