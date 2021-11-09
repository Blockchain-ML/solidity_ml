pragma solidity ^0.4.24;


 
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

   
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

   
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract MyMessage is Ownable {

    string public message;
    uint public maxLength;   
    
    constructor() public {
        message = "Hello World";
        maxLength = 280;
    }
    
    function setMessage(string _message) public {
        require(bytes(_message).length <= maxLength, "That message is too long.");
        
        message = _message;
    }
    
    function setMaxLength(uint _maxLength) public onlyOwner {
        maxLength = _maxLength;
    }
}