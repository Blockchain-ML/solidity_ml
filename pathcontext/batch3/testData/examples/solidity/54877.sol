pragma solidity^0.4.23;  

 
contract Splitter {
    address[] splitAddresses;

    function split(address[] destinationAddresses) public payable {
        splitAddresses = destinationAddresses;  

        sendEth();  
    }

    function sendEth() internal {
        for (uint x = 0; x < splitAddresses.length; x++) {
            splitAddresses[x].transfer(msg.value/splitAddresses.length);  
        }
    }
}