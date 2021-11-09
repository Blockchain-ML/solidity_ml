 
 


pragma solidity ^0.4.25;


contract incrementablenumber {
    
    uint256 private counter;
    address public owner;
    address public approvedAddress;
    
     
    constructor() public {
        owner = msg.sender;
}
     
    function getCount() public view returns (uint256){
        return counter;
    }
     
    function incCounter() public{
        if (msg.sender==owner || msg.sender == approvedAddress)
            counter++;
    }

     
    function setApprovedAddress(address _approvedAddress) public{
        if (msg.sender==owner)
            approvedAddress=_approvedAddress;
    }

 


 
}