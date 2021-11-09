pragma solidity ^0.4.24;



 
interface IRegistry {
     
    event ProxyCreated(address proxy);

     
    event VersionAdded(string version, address implementation);

     
    function addVersion(string version, address implementation) external;

     
    function getVersion(string version) external view returns (address);
}

 
contract UpgradeabilityStorage {
     
    IRegistry internal registry;

     
    address internal _implementation;

     
    function implementation() public view returns (address) {
        return _implementation;
    }
}





 
contract Upgradeable is UpgradeabilityStorage {
     
    function initialize(address sender) public payable {
        require(msg.sender == address(registry));
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

 
contract Marketplace is Upgradeable {
    
    using SafeMath for uint256;

    address public owner;
    address public cashout;

     
    uint256 public platformCommissionRate;

    struct User {
        bool exists;
        bool blocked;
        address[] productContracts;  
    }
    mapping (address => User) public users;

    struct ProductContract {
        bool exists;
        address user;   
    }
    mapping (address => ProductContract) productContracts;

    event UserRegistered(address userAddress);
    event UserBlocked(address userAddress);
    event UserUnblocked(address userAddress);
    event ProductContractRegistered(address userAddress, address contractAddress);
    event PlatformIncomingTransactionCommission(address contractAddress, uint256 amount, address clientAddress);
    event PlatformOutgoingTransactionCommission(address contractAddress, uint256 amount);
    event UserIncomingTransactionCommission(address contractAddress, uint256 amount, address clientAddress);
    event UserOutgoingTransactionCommission(address contractAddress, uint256 amount);

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    function initialize(address sender) public payable {
        super.initialize(sender);
        owner = sender;
        cashout = 0xb9520aD773139c4a127a6a2BF70c3728376194A0;
    }

     
    function setPlatformCommissionRate(uint256 newPlatformCommissionRate) public onlyOwner {
        platformCommissionRate = newPlatformCommissionRate;
    }

     
    function calculatePlatformCommission(uint256 weiAmount) public view returns (uint256) {
        return weiAmount.mul(platformCommissionRate).div(10000);
    }

     
    function registerUser(address userAddress) public onlyOwner {
         
        require(!users[userAddress].exists);
        
         
        users[userAddress] = User(true, false, new address[](0));
        emit UserRegistered(userAddress);
    }

     
    function isUserBlocked(address userAddress) public view onlyOwner returns (bool) {
         
        require(users[userAddress].exists);
        return users[userAddress].blocked;
    }

     
    function blockUser(address userAddress) public onlyOwner {
         
        require(users[userAddress].exists);
        users[userAddress].blocked = true;
        emit UserBlocked(userAddress);
    }

     
    function unblockUser(address userAddress) public onlyOwner {
         
        require(users[userAddress].exists);
        users[userAddress].blocked = false;
        emit UserUnblocked(userAddress);
    }

     
    function getUserProductContracts(address userAddress) public view onlyOwner returns (address[]) {
         
        require(users[userAddress].exists);
        return users[userAddress].productContracts;
    }

     
    function registerProductContract(address userAddress, address contractAddress) public onlyOwner {
         
        require(users[userAddress].exists);

         
        require(!productContracts[contractAddress].exists);

         
        users[userAddress].productContracts.push(contractAddress);

         
        productContracts[contractAddress] = ProductContract(true, userAddress);
        emit ProductContractRegistered(userAddress, contractAddress);
    }

     
    function getProductContractUser(address contractAddress) public view onlyOwner returns (address) {
         
        require(productContracts[contractAddress].exists);
        return productContracts[contractAddress].user;
    }

     
    function payPlatformIncomingTransactionCommission(address clientAddress) public payable {
         
        require(productContracts[msg.sender].exists);
        emit PlatformIncomingTransactionCommission(msg.sender, msg.value, clientAddress);
    }

     
    function payPlatformOutgoingTransactionCommission() public payable {
         
        require(productContracts[msg.sender].exists);
        emit PlatformOutgoingTransactionCommission(msg.sender, msg.value);
    }

     
    function payUserIncomingTransactionCommission(address clientAddress) public payable {
         
        require(productContracts[msg.sender].exists);
        emit UserIncomingTransactionCommission(msg.sender, msg.value, clientAddress);
    }

     
    function payUserOutgoingTransactionCommission() public payable {
         
        require(productContracts[msg.sender].exists);
        emit UserOutgoingTransactionCommission(msg.sender, msg.value);
    }

     
    function transferEth(uint256 amount) public onlyOwner {
        require(address(this).balance >= amount);
        cashout.transfer(amount);
    }

     
    function destroy() public onlyOwner {
        selfdestruct(cashout);
    }
}