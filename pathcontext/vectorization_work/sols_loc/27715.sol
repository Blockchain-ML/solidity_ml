pragma solidity ^0.4.24;

 

 
contract IOwned {
    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
    function transferOwnershipNow(address newContractOwner) public;
}

 

 
contract Owned is IOwned {
    address public owner;
    address public newOwner;

    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

     
    constructor() public {
        owner = msg.sender;
    }

     
    modifier ownerOnly {
        require(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

     
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

     
    function transferOwnershipNow(address newContractOwner) ownerOnly public {
        require(newContractOwner != owner);
        emit OwnerUpdate(owner, newContractOwner);
        owner = newContractOwner;
    }

}

 

 
contract IRegistrar is IOwned {
    function addNewAddress(address _newAddress) public;
    function getAddresses() public view returns (address[]);
}

 

 
contract Registrar is Owned, IRegistrar {

    address[] addresses;
     
     
    function addNewAddress(address _newAddress) public ownerOnly {
        addresses.push(_newAddress);
    }

     
    function getAddresses() public view returns (address[]) {
        return addresses;
    }
}