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

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract KYC is Ownable{
    
    address constant private ZERO_ADDRESS = address(0);

    struct ExpectedTransfer{
        bool isPaid;
        uint expectedFee;
        uint expectedTime;
        bool isEth;
        address inComingAddress;
    }
    
    struct Customer {
        address addr;
        bool isLocked;
        uint expiredTime;
        bytes signature;
        address[] expectedAddresses;
        uint count;
        mapping( uint => ExpectedTransfer) expectedInfo;
    }
    
    string public partnerName;
    address private partnerAddress;

    address private WLAddress;
    
    mapping(address => Customer) private customers;
    mapping(address => address) private linkedAddress;
    
    uint256 private totalIncomingWei = 0;
    uint256 private totalOutgoingWei = 0;
    
     
    
    modifier isValidAddress(address addr) {
        require(addr != ZERO_ADDRESS);
        _;
    }
    
    modifier isWLAddress(address addr) {
        require(addr == WLAddress);
        _;
    }
    
    modifier isContract(address addr){
        require(AddressUtils.isContract(addr));
        _;
    }
    
     
    
     
    
    modifier isCustomerNotAdded(address addr) {
        require(addr != ZERO_ADDRESS);
        require(customers[addr].addr == ZERO_ADDRESS);
        require(linkedAddress[addr] == ZERO_ADDRESS);
        _;
    }
    
    modifier isCustomerAdded(address addr) {
        require(addr != ZERO_ADDRESS);
        require(customers[addr].addr != ZERO_ADDRESS);
        require(linkedAddress[addr] == addr);
        _;
    }
    
    modifier checkSecondaryAddress(address secondaryAddress){
        require(secondaryAddress != ZERO_ADDRESS);
        require(linkedAddress[secondaryAddress] == ZERO_ADDRESS);
        _;
    }
    
    modifier isSecondaryAddrAdded(address addr, address secondaryAddress){
        require(addr != ZERO_ADDRESS);
        require(secondaryAddress != ZERO_ADDRESS);
        require(secondaryAddress != addr);
        require(linkedAddress[secondaryAddress] == addr);
        _;
    }
    modifier verifiedCustomer(uint _expiredTime, bytes _signature) {
        require(_expiredTime > now);
        require(_signature.length > 0 );
        _;
    }
    
    modifier isLockedCustomer(address addr) {
        require(addr != ZERO_ADDRESS);
        require(customers[addr].isLocked);
        _;
    }
    
    modifier isUnLockedCustomer(address addr) {
        require(addr != ZERO_ADDRESS);
        require(!customers[addr].isLocked);
        _; 
    }
    
     
    
     
    
    modifier isAvailableTokenBalance(address tokenAddr, uint tokenAmount) {
        require(tokenAmount > 0);
        require(ERC20(tokenAddr).balanceOf(this) >= tokenAmount);
        _;
    }
    
    modifier isAvailableETHBalance(uint amount) {
        require(amount > 0);
        require(address(this).balance > amount);
        _;
    }
    
     
    
    
    constructor(string _name, address _address, address _wlAddress) public isValidAddress(_address) isContract(_wlAddress) {
        partnerName = _name;
        partnerAddress = _address; 
        WLAddress = _wlAddress;
    }
    
     
    
    function getWLAddress() public view onlyOwner returns(address){
        return WLAddress;
    }
    
    function setWLAddress(address _wlAddress) public onlyOwner isValidAddress(_wlAddress) isContract(_wlAddress) returns(bool){
        WLAddress = _wlAddress;
        return true;
    }
    
     
    
     
    
    function addCustomerwithETH(address customerAddress, uint expectedFee, uint expectedTime) public onlyOwner isCustomerNotAdded(customerAddress) returns (bool){
        address[] memory addressList = new address[](1);
        addressList[0] = customerAddress;
        customers[customerAddress] = Customer(customerAddress, false, now, "", addressList, 1);
        customers[customerAddress].expectedInfo[1]=ExpectedTransfer(false, expectedFee, expectedTime, true, ZERO_ADDRESS);
        linkedAddress[customerAddress] = customerAddress;
        return true;
    }

    function addCustomerwithToken(address customerAddress, uint expectedFee, address tokenContractAddress) public onlyOwner isCustomerNotAdded(customerAddress) returns (bool){
        address[] memory addressList = new address[](1);
        addressList[0] = customerAddress;
        customers[customerAddress] = Customer(customerAddress, false, now, "", addressList, 1);
        customers[customerAddress].expectedInfo[1]=ExpectedTransfer(true, expectedFee, 0, false, tokenContractAddress);
        linkedAddress[customerAddress] = customerAddress;
        return true;
    }
    
    function addSecondaryAddress(address _customerAddress, address _secondaryAddress) public onlyOwner isCustomerAdded(_customerAddress) 
        checkSecondaryAddress(_secondaryAddress) returns(bool){
            Customer storage c = customers[_customerAddress];
            c.expectedAddresses.push(_secondaryAddress);
            linkedAddress[_secondaryAddress] = _customerAddress;
            return true;
    }
    
    function deleteSecondaryAddress(address _customerAddress, address _secondaryAddress) public onlyOwner isCustomerAdded(_customerAddress)
        isSecondaryAddrAdded(_customerAddress, _secondaryAddress) returns(bool){
            Customer storage c = customers[_customerAddress];
            bool isExist = false;
            uint length = c.expectedAddresses.length;
            address[] memory addressList = new address[](length-1);
            uint l = 0;
            for (uint k=0; k<length; ++k) {
                if(c.expectedAddresses[k] !=_secondaryAddress){
                    addressList[l] = c.expectedAddresses[k];
                    l++;
                }else{
                    isExist = true;
                }
            }
            if(isExist){
                c.expectedAddresses = addressList;
                linkedAddress[_secondaryAddress] = ZERO_ADDRESS;
                return true;
            }
            return false;
    }
    
    function setETHExpectedFee(address _customerAddress, uint expectedFee, uint expectedTime) public onlyOwner isCustomerAdded(_customerAddress)
        returns(bool){
            Customer storage c = customers[_customerAddress];
            c.count = c.count+1;
            c.expectedInfo[c.count]=ExpectedTransfer(false, expectedFee, expectedTime, true, ZERO_ADDRESS);
            return true;
    }
    
    function setTokenExpectedFee(address _customerAddress, uint expectedFee, uint expectedTime, address tokenContractAddress) public onlyOwner
        isCustomerAdded(_customerAddress) returns(bool){
            Customer storage c = customers[_customerAddress];
            c.count = c.count+1;
            c.expectedInfo[c.count]=ExpectedTransfer(true, expectedFee, expectedTime, false, tokenContractAddress);
            return true;
    }
    
    function setCustomerSignature(address _customerAddress, uint _expiredTime, bytes _signature) public onlyOwner
        isCustomerAdded(_customerAddress) verifiedCustomer(_expiredTime, _signature) returns(bool){
            Customer storage c = customers[_customerAddress];
            c.expiredTime = _expiredTime;
            c.signature = _signature;
            return true;
    }
    
    function getCustomer(address _customerAddress) public view onlyOwner isCustomerAdded(_customerAddress) returns (address, bool, uint, bytes){
        Customer storage c = customers[_customerAddress];
        return (c.addr, c.isLocked, c.expiredTime, c.signature);
    }
    
    function isCustomerHasKYC(address _customerAddress) public view isCustomerAdded(_customerAddress) isWLAddress(msg.sender) returns (bool){
        Customer memory c = customers[_customerAddress];
        return (!c.isLocked && c.expiredTime > now && c.signature.length>0);
    }
    
    function lockedCustomer(address _customerAddress) public onlyOwner  
        isCustomerAdded(_customerAddress) isUnLockedCustomer(_customerAddress) returns(bool){
        Customer storage c = customers[_customerAddress];
        c.isLocked = true;
        return true;
    }
    
    function unlockedCustomer(address _customerAddress) public onlyOwner  
        isCustomerAdded(_customerAddress) isLockedCustomer(_customerAddress) returns(bool){
        Customer storage c = customers[_customerAddress];
        c.isLocked = false;
        return true;
    }
    
    function getLinkedAddress(address _address) public view onlyOwner isValidAddress(_address) returns(address){
        require(linkedAddress[_address] != ZERO_ADDRESS);
        return(linkedAddress[_address]);
    }
    
     
    
     
    
    function() public payable {
        require(msg.sender != ZERO_ADDRESS);
        require(linkedAddress[msg.sender] != ZERO_ADDRESS);
        require(msg.value > 0);
        address customerAddress = linkedAddress[msg.sender];
        Customer storage c = customers[customerAddress];
        require(c.addr != ZERO_ADDRESS);
        require(!c.isLocked);
        uint count = c.count;
        ExpectedTransfer storage eT = c.expectedInfo[count];
        require(eT.expectedTime > now);
        require(msg.value == eT.expectedFee);
        eT.isPaid = true;
        eT.inComingAddress = msg.sender;
        totalIncomingWei += msg.value;
    }
    
    function tokenTransfertoKYC(address tokenAddress, uint tokenAmount) public onlyOwner isAvailableTokenBalance(tokenAddress, tokenAmount) returns(bool){
        ERC20(tokenAddress).transfer(WLAddress, tokenAmount);
        return true;
    }
    
    function ethTransfertoKYC(uint amount) public onlyOwner isAvailableETHBalance(amount) returns(bool){
        address(WLAddress).transfer(amount);
        totalOutgoingWei += amount;
        return true;
    }
    
    function refundETHToCustomer(address _address, uint refundAmount) public onlyOwner isCustomerAdded(_address) returns(bool){
        require(refundAmount > 0);
        Customer storage c = customers[_address];
        require(c.expectedInfo[c.count].isPaid);
        require(c.expectedInfo[c.count].isEth);
        _address.transfer(refundAmount);
        return true;
    }
    
    function refundTokenToCustomer(address _address, uint refundAmount, address tokenAddress) public onlyOwner isCustomerAdded(_address)
        isAvailableTokenBalance(tokenAddress, refundAmount) returns(bool){
            Customer storage c = customers[_address];
            require(c.expectedInfo[c.count].isPaid);
            require(!c.expectedInfo[c.count].isEth);
            require(c.expectedInfo[c.count].inComingAddress == tokenAddress);
            ERC20(tokenAddress).transfer(_address, refundAmount);
            return true;
    }
    
    function getETHBalanceInfo() public view onlyOwner returns(uint, uint){
        return (totalIncomingWei, totalOutgoingWei);
    }
    
     
    
}