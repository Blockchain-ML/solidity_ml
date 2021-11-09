pragma solidity ^0.4.21;

library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
     
     
     
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract HotelRank {
    struct HotelStruct {
        bytes32 name;
        uint rank;
        bytes32 rankDescription;
        uint lastUpdate;
        uint updates;
    }
    
     
    address owner;
    mapping(bytes32 => HotelStruct) public hotelStructs;
 
    modifier onlyOwner {
        if (msg.sender != owner) revert();
        _;
    }
 
    event UpdateRank(bytes32 id, bytes32 name, uint rank, bytes32 rankDescription, uint date);
                  
    constructor() public {
        owner=msg.sender;
    }
 
    function updateRank(bytes32 id, bytes32 name, uint rank, bytes32 rankDescription, uint date) public onlyOwner returns(bool success) {
        hotelStructs[id].name = name;
        hotelStructs[id].rank = rank;
        hotelStructs[id].lastUpdate = date;
        hotelStructs[id].rankDescription = rankDescription;
        hotelStructs[id].updates = SafeMath.add(hotelStructs[id].updates, 1);
        emit UpdateRank(id,name,rank,rankDescription,date);
        return true;
    } 
 }