pragma solidity ^0.4.25;

 

contract InfoContract {

   uint info;

   function setInfo(uint _info) public {
       info = _info;
   }

   function getInfo() public constant returns (uint) {
       return info;
   }
}