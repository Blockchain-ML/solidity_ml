pragma solidity ^0.4.0;

 

contract SmartIdentityRegistry {

    address private owner;
    uint constant PENDING = 0;
    uint constant ACTIVE = 1;
    uint constant REJECTED = 2;

     
    function SmartIdentityRegistry() public {
        owner = msg.sender;
    }

     
    struct SIContract {
        bytes32 hash;
        address submitter;
        uint status;
    }

     
    mapping(bytes32 => SIContract) public sicontracts;

     
    modifier onlyBy(address _account) {
        if (msg.sender != _account) {
            revert();
        }
        _;
    }

     
    function submitContract(bytes32 _contractHash) public returns(bool) {
        var sicontract = sicontracts[_contractHash];
        sicontract.hash = _contractHash;
        sicontract.submitter = msg.sender;
        sicontract.status = PENDING;
        return true;
    }

     
    function approveContract(bytes32 _contractHash) onlyBy(owner) public returns(bool) {
        var sicontract = sicontracts[_contractHash];
        sicontract.status = ACTIVE;
        return true;
    }

     
    function rejectContract(bytes32 _contractHash) onlyBy(owner) public returns(bool) {
        var sicontract = sicontracts[_contractHash];
        sicontract.status = REJECTED;
        return true;
    }

     
    function deleteContract(bytes32 _contractHash) public returns(bool) {
        var sicontract = sicontracts[_contractHash];
        if (sicontract.status != REJECTED) {
            if (sicontract.submitter == msg.sender) {
                if (msg.sender == owner) {
                    delete sicontracts[_contractHash];
                    return true;
                }
            }
        } else {
            revert();
        }
    }

     
    function isValidContract(bytes32 _contractHash) public returns(bool) {
        if (sicontracts[_contractHash].status == ACTIVE) {
            return true;
        }
        if (sicontracts[_contractHash].status == REJECTED) {
            revert();
        } else {
            return false;
        }
    }

     
    function kill() onlyBy(owner) public returns(uint) {
        selfdestruct(owner);
    }

     
     

     

     

     

     
}