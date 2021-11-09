pragma solidity ^0.4.25;

 
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

   
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

   
  function owner() public view returns(address) {
    return _owner;
  }

   
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

   
  function isOwner() public view returns(bool) {
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

 

 
library AddressUtils {

   
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
     
     
     
     
     
     
     
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}

contract WhiteList is Ownable {
    
    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);
    
    address private BLAddress;    
    
    struct Customer {
        address addr;
        address KYCAddr;
        address ACCAddr;
        bool isReqACC;
    }
    
    mapping (address => Customer) public customers;
    
    modifier isCustomerNotAdded(address addr) {
        require(addr != ZERO_ADDRESS);
        require(customers[addr].addr == ZERO_ADDRESS);
        _;
    }
    
    modifier isCustomerAdded(address addr) {
        require(addr != ZERO_ADDRESS);
        require(customers[addr].addr != ZERO_ADDRESS);
        _;
    }
    
    modifier isContract(address addr){
        require(addr != ZERO_ADDRESS);
        require(AddressUtils.isContract(addr));
        _;
    }
    
    constructor () public{
    } 
    
    function updateBLAddress(address _BLAddr) public onlyOwner isContract(_BLAddr) returns(bool){
        BLAddress = _BLAddr;
        return true;
    }
    
    function addCustomerNReqAcc(address _address, address _KYCAddress) public onlyOwner isCustomerNotAdded(_address) returns(bool){
        require(_KYCAddress != ZERO_ADDRESS);
        require(AddressUtils.isContract(_KYCAddress));
        customers[_address] = Customer(_address, _KYCAddress, ZERO_ADDRESS, false);
        return true;
    }
    
    function addCustomerReqACC(address _address, address _KYCAddress, address _ACCAddress) public onlyOwner isCustomerNotAdded(_address) returns(bool){
        require(AddressUtils.isContract(_ACCAddress));
        require(AddressUtils.isContract(_KYCAddress));
        customers[_address] = Customer(_address, _KYCAddress, _ACCAddress, true);
        return true;
    }
    
    function updateCustomerKYC(address _address, address _KYCAddress) public onlyOwner isCustomerAdded(_address) isContract(_KYCAddress) returns(bool){
        Customer storage c = customers[_address];
        c.KYCAddr = _KYCAddress;
        return true;
    }
    
    function updateCustomerACC(address _address, address _ACCAddress) public onlyOwner isCustomerAdded(_address) isContract(_ACCAddress) returns(bool){
        Customer storage c = customers[_address];
        require(c.isReqACC);
        c.ACCAddr = _ACCAddress;
        return true;
    }
    
    function checkCustomer(address _address) public onlyOwner isCustomerAdded(_address) returns(bool){
        Customer storage c = customers[_address];
        
        if(BLAddress == ZERO_ADDRESS || BLAddress.call(bytes4(keccak256("isBLCustomer(address)")), _address)){
            return false;
        }
        
        if(c.KYCAddr == ZERO_ADDRESS || !c.KYCAddr.call(bytes4(keccak256("isCustomerHasKYC(address)")), _address) ){
            return false;
        } 
        if(c.isReqACC && (c.ACCAddr == ZERO_ADDRESS || !c.ACCAddr.call(bytes4(keccak256("isCustomerHasACC(address)")), _address) ) ){
            return false;
        }
        return true;
    }
    
}