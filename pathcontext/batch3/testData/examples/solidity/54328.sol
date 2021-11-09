pragma solidity ^0.4.24;

 

 
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() public {
        owner = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

 

 
contract Claimable is Ownable {
    address public pendingOwner;

     
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner);
        _;
    }

     
    function transferOwnership(address newOwner) onlyOwner public {
        pendingOwner = newOwner;
    }

     
    function claimOwnership() onlyPendingOwner public {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}

 

contract AddressList is Claimable {
    string public name;
    mapping(address => bool) public onList;

    constructor(string _name, bool nullValue) public {
        name = _name;
        onList[0x0] = nullValue;
    }

    event ChangeWhiteList(address indexed to, bool onList);

     
     
    function changeList(address _to, bool _onList) onlyOwner public {
        require(_to != 0x0);
        if (onList[_to] != _onList) {
            onList[_to] = _onList;
            emit ChangeWhiteList(_to, _onList);
        }
    }
}

 

contract NamableAddressList is AddressList {
    constructor(string _name, bool nullValue)
    AddressList(_name, nullValue) public {}

    function changeName(string _name) onlyOwner public {
        name = _name;
    }
}