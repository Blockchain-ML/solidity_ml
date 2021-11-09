 

pragma solidity ^0.4.25;

contract Auction {
    
    address owner;
    
    struct Bid {
      address bidder;
      uint value;
    }
    
    struct AuctionStruct {
        string name;
        uint expiryBlockHeight;
        Bid highestBid;
        Bid nextHighestBid;
    }
    
    mapping(bytes32 => AuctionStruct) public auctions;
    
    constructor() public {
        owner = msg.sender;
    }
    
     
     
    function createNewBid(string _name, uint _expiryBlockHeight) public{

        Bid memory initialBid = Bid({bidder: 0x0, value: 0});
        AuctionStruct memory newAuction = AuctionStruct({name: _name, expiryBlockHeight: _expiryBlockHeight, highestBid: initialBid, nextHighestBid: initialBid});
        bytes memory nameBytes = bytes(_name);
        bytes32 key_value = keccak256(nameBytes);
        auctions[key_value] = newAuction;
    }

     
     
     
    function submitBid(string _name) public payable {

        bytes memory nameBytes = bytes(_name);
        bytes32 key_value = keccak256(nameBytes);
        AuctionStruct memory retrievedAuction = auctions[key_value];
        
        require(block.number < retrievedAuction.expiryBlockHeight);
        require(msg.value > retrievedAuction.highestBid.value);
        
        Bid memory currentBid = Bid({bidder: msg.sender, value: msg.value});
        
         
         
        retrievedAuction.highestBid.bidder.transfer(retrievedAuction.highestBid.value);
        retrievedAuction.nextHighestBid = retrievedAuction.highestBid;
        retrievedAuction.highestBid = currentBid;
        auctions[key_value] = retrievedAuction;      
    }
    
     
    function twoHightestBidsDifference(string _name) public view returns(uint) {

        bytes memory nameBytes = bytes(_name);
        bytes32 key_value = keccak256(nameBytes);
        AuctionStruct memory retrievedAuction = auctions[key_value];
        
        return retrievedAuction.highestBid.value - retrievedAuction.nextHighestBid.value;
        
    }

     
     
    function executePayment(string _name) public {

        bytes memory nameBytes = bytes(_name);
        bytes32 key_value = keccak256(nameBytes);
        AuctionStruct memory retrievedAuction = auctions[key_value];
        
        require(block.number >= retrievedAuction.expiryBlockHeight);
        uint difference = retrievedAuction.highestBid.value - retrievedAuction.nextHighestBid.value;
        retrievedAuction.highestBid.bidder.transfer(difference);     
        address(0x0).transfer(address(this).balance);    
    }

     
    function winningBidder(string _name) public view returns (address) {
        
        bytes memory nameBytes = bytes(_name);
        bytes32 key_value = keccak256(nameBytes);
        AuctionStruct memory retrievedAuction = auctions[key_value];
        
        return retrievedAuction.highestBid.bidder;
    }

}