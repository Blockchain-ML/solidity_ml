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

 
library SafeMath {
     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        require(b > 0);
        uint256 c = a / b;
         

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
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

contract ACC is Ownable{
    using SafeMath for uint256;
    
    address constant private ZERO_ADDRESS = address(0);
     
    address constant private partnerMainAddress = 0xe7C2070CfeC702DdC090198B5F938E7C10C1F97E;
    
    struct Customer {
        address addr;
        bool isLocked;
        uint expiredTime;
        bool isApproved;
    }
    
    string public partnerName;
    mapping(address => bool) private adminAddresses;

    address private WLCAddress;
    address private PCAddress;
    
    mapping(address => Customer) private customers;
    
    
     
    
    modifier isValidAddress(address addr) {
        require(addr != ZERO_ADDRESS);
        _;
    }
    
    modifier isWLAddress(address addr) {
        require(addr != ZERO_ADDRESS);
        require(addr == WLCAddress);
        _;
    }
    
    modifier isContract(address addr){
        require(AddressUtils.isContract(addr));
        _;
    }
    
    modifier isAvailableTokenBalance(address tokenAddr, uint tokenAmount) {
        require(tokenAmount > 0);
        require(ERC20(tokenAddr).balanceOf(this) >= tokenAmount);
        _;
    }
    
    modifier isACCAddress(address addr) {
        require(addr != ZERO_ADDRESS);
        require(adminAddresses[addr]);
        _;
    }
    
    modifier isACCMainAddress(address addr) {
        require(addr != ZERO_ADDRESS);
        require(addr == partnerMainAddress);
        _;
    }
    
    modifier isCustomerNotAdded(address addr) {
        require(addr != ZERO_ADDRESS);
        require(customers[addr].addr == ZERO_ADDRESS);
        _;
    }
    
    modifier isCustomerAdded(address addr) {
        require(addr != ZERO_ADDRESS);
        require(customers[addr].addr == addr);
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
    
     
    
    constructor(string _name, address _wlCAddress, address _pCAddress) public isContract(_wlCAddress) isContract(_pCAddress) {
        partnerName = _name;
        WLCAddress = _wlCAddress;
        PCAddress = _pCAddress;
        adminAddresses[partnerMainAddress] = true;
    }
    
    
    function getWLAddress() public view returns(address){
        return WLCAddress;
    }
    
    function setWLAddress(address _wlCAddress) public onlyOwner isContract(_wlCAddress) returns(bool){
        WLCAddress = _wlCAddress;
        return true;
    }
    
    function getPCAddress() public view returns(address){
        return PCAddress;
    }
    
    function setPCAddress(address _pCAddress) public onlyOwner isContract(_pCAddress) returns(bool){
        PCAddress = _pCAddress;
        return true;
    }
    
    function addCustomer(address _customerAddress) public onlyOwner isCustomerNotAdded(_customerAddress) returns (bool){
        customers[_customerAddress] = Customer(_customerAddress, false, now, false);
        return true;
    }

    function getCustomer(address _customerAddress) public view isCustomerAdded(_customerAddress) returns (address, bool, uint, bool){
        Customer memory c = customers[_customerAddress];
        return (c.addr, c.isLocked, c.expiredTime, c.isApproved);
    }
    
    function lockCustomer(address _customerAddress) public onlyOwner  
        isCustomerAdded(_customerAddress) isUnLockedCustomer(_customerAddress) returns(bool){
        Customer storage c = customers[_customerAddress];
        c.isLocked = true;
        return true;
    }

    function unlockCustomer(address _customerAddress) public onlyOwner  
        isCustomerAdded(_customerAddress) isLockedCustomer(_customerAddress) returns(bool){
        Customer storage c = customers[_customerAddress];
        c.isLocked = false;
        return true;
    }
    
    function addApproval(address _customerAddress) public onlyOwner isCustomerAdded(_customerAddress) returns (bool){
        Customer storage c = customers[_customerAddress];
        c.isApproved = true;
        return true;
    }
    
    function removeApproval(address _customerAddress) public onlyOwner isCustomerAdded(_customerAddress) returns (bool){
        Customer storage c = customers[_customerAddress];
        c.isApproved = false;
        return true;
    }

    function addCustomerFromACC(address _customerAddress) public isACCAddress(msg.sender) isCustomerNotAdded(_customerAddress) returns (bool){
        customers[_customerAddress] = Customer(_customerAddress, false, now, false);
        return true;
    }
    

    function isCustomerHasACCfromWL(address _customerAddress) public view isCustomerAdded(_customerAddress) isWLAddress(msg.sender) returns (bool){
        Customer memory c = customers[_customerAddress];
        require (!c.isLocked && c.expiredTime > now);
        return true;
    }
    
    function addAdmin(address _adminAddress) public onlyOwner isValidAddress(_adminAddress) returns(bool){
        adminAddresses[_adminAddress] = true;
        return true;
    }
    
    function removeAdmin(address _adminAddress) public onlyOwner isValidAddress(_adminAddress) returns(bool){
        adminAddresses[_adminAddress] = false;
        return true;
    }
    
    function getAdmin(address _adminAddress) public view isValidAddress(_adminAddress) returns(bool){
        return adminAddresses[_adminAddress];
    }
    
     
    
    function setCustomerSignature(address _customerAddress, uint _expiredTime) public
        isACCAddress(msg.sender) isCustomerAdded(_customerAddress) returns(bool){ 
            require(_expiredTime > now);
            Customer storage c = customers[_customerAddress];
            require(c.isApproved);
            c.expiredTime = _expiredTime;
            c.isApproved = false;
            return true;
    }
    
    function startPaymentProcess(address _paymentAddress) public isACCMainAddress(msg.sender) isValidAddress(_paymentAddress) returns(bool){
        return PCAddress.call(bytes4(keccak256("payProviderFee(address)")), _paymentAddress);
    }
    
     
    
    function() public payable {
        revert(); 
    }
    
    function transferAnyERC20Token(address _address, address _tokenAddress, uint _tokenAmount) public onlyOwner isValidAddress(_address) 
        isContract(_tokenAddress) isAvailableTokenBalance(_tokenAddress, _tokenAmount) returns(bool){
            ERC20(_tokenAddress).transfer(_address, _tokenAmount);
            return true;
    }
    
     
    
}