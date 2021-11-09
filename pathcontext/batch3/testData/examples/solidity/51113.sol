pragma solidity 0.4.24;

 
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

      
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

     
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract MessageOfTheMoment is Ownable {
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