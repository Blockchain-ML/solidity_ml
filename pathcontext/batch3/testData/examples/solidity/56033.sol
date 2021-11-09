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

contract TokensContract {
    function balanceOf(address who) public view returns (uint256);
}

contract Marketplace is Upgradeable {
    
    using SafeMath for uint256;

    address public owner;

     
    uint256 public platformCommissionRate;
    uint256 public userCommissionRate;

    address public tokensContractAddress;
    uint256 public tokensDecimals;
    uint256 public tokensMultiplier;     

    struct User {
        int256 balance;     
        bool exists;
        bool blocked;
        address[] productContracts;  
    }
    mapping (address => User) public users;

    struct ProductContract {
        address user;
        uint256 commissionWei;
        bool exists;
        address[] clients;   
    }
    mapping (address => ProductContract) productContracts;

    event UserRegistered(address userAddress);
    event UserBlocked(address userAddress);
    event UserUnblocked(address userAddress);
    event ProductContractRegistered(address userAddress, address contractAddress);
    event ClientAdded(address clientAddress, address contractAddress);
    event NintyPercentClientsReached(address userAddress);
    event PlatformIncomingTransactionCommission(address contractAddress, uint256 amount);
    event PlatformOutgoingTransactionCommission(address contractAddress, uint256 amount);
    event UserIncomingTransactionCommission(address contractAddress, uint256 amount);
    event UserOutgoingTransactionCommission(address contractAddress, uint256 amount);
    event SaasUserPaid(address userAddress, uint256 amount);
    event SaasPayment(address userAddress, uint256 amount);
    event UserBalanceBelowZero(address userAddress);

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function initialize(address sender) public payable {
        super.initialize(sender);
        owner = sender;
    }

    function setPlatformCommissionRate(uint256 newPlatformCommissionRate) public onlyOwner {
        platformCommissionRate = newPlatformCommissionRate;
    }

    function calculatePlatformCommission(uint256 weiAmount) public view returns (uint256) {
        return weiAmount.mul(platformCommissionRate).div(10000);
    }

    function setUserCommissionRate(uint256 newUserCommissionRate) public onlyOwner {
        userCommissionRate = newUserCommissionRate;
    }

    function calculateUserCommission(uint256 weiAmount) public view returns (uint256) {
        return weiAmount.mul(userCommissionRate).div(10000);
    }

    function registerUser(address userAddress) public onlyOwner returns (bool) {
         
        require(!users[userAddress].exists);
        
         
        users[userAddress] = User(0, true, false, new address[](0));
        emit UserRegistered(userAddress);

        return true;
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

    function getUserBalance(address userAddress) public view onlyOwner returns (int256) {
         
        require(users[userAddress].exists);

        return users[userAddress].balance;
    }

    function registerProductContract(address userAddress, address contractAddress) public onlyOwner returns (bool) {
         
        require(users[userAddress].exists);

         
        require(!productContracts[contractAddress].exists);

         
        users[userAddress].productContracts.push(contractAddress);

         
        productContracts[contractAddress] = ProductContract(userAddress, 0, true, new address[](0));
        emit ProductContractRegistered(userAddress, contractAddress);

        return true;
    }

    function getProductContractUser(address contractAddress) public view onlyOwner returns (address) {
         
        require(productContracts[contractAddress].exists);

        return productContracts[contractAddress].user;
    }

    function getProductContractCommissionWei(address contractAddress) public view onlyOwner returns (uint256) {
         
        require(productContracts[contractAddress].exists);

        return productContracts[contractAddress].commissionWei;
    }

    function getProductContractClients(address contractAddress) public view onlyOwner returns (address[]) {
         
        require(productContracts[contractAddress].exists);

        return productContracts[contractAddress].clients;
    }

    function addClient(address clientAddress, address contractAddress) private returns (bool) {
         
        require(productContracts[contractAddress].exists);

        ProductContract storage pc = productContracts[contractAddress];

         
        pc.clients.push(clientAddress);
        
        emit ClientAdded(clientAddress, contractAddress);

        return true;
    }

    function isClientAddedBefore(address clientAddress, address contractAddress) private view returns (bool) {
        ProductContract storage pc = productContracts[contractAddress];
        bool isClientAddedBeforeFlag = false;
        for(uint256 i = 0; i < pc.clients.length; i++) {
            if(pc.clients[i] == clientAddress) {
                isClientAddedBeforeFlag = true;
            }
        }
        return isClientAddedBeforeFlag;
    }

    function addCommissionAmount(uint256 _commissionWei, address contractAddress) private {
         
        require(productContracts[contractAddress].exists);

        ProductContract storage pc = productContracts[contractAddress];
        pc.commissionWei = pc.commissionWei.add(_commissionWei);
    }

    function getUserClientsCount(address userAddress) public view returns (uint256) {
         
        require(users[userAddress].exists);

        uint256 totalClientsCount = 0;

        address[] memory _productContracts = users[userAddress].productContracts;
        for(uint256 i = 0; i < _productContracts.length; i++) {
            totalClientsCount += productContracts[_productContracts[i]].clients.length;
        }

        return totalClientsCount;
    }

    function setTokensContractAddress(address _address) public onlyOwner {
        tokensContractAddress = _address;
    }

    function setTokensDecimals(uint256 _decimals) public onlyOwner {
        tokensDecimals = _decimals;
    }

    function setTokensMultiplier(uint256 _tokensMultiplier) public onlyOwner {
        tokensMultiplier = _tokensMultiplier;
    }

    function payPlatformIncomingTransactionCommission(address clientAddress) public payable {
         
        require(productContracts[msg.sender].exists);

         
        if(!isClientAddedBefore(clientAddress, msg.sender)) {
            if(canAddNewClient(productContracts[msg.sender].user)) {
                addClient(clientAddress, msg.sender);
            } else {
                revert();
            }
        }

        addCommissionAmount(msg.value, msg.sender);

        emit PlatformIncomingTransactionCommission(msg.sender, msg.value);
    }

    function payPlatformOutgoingTransactionCommission() public payable {
         
        require(productContracts[msg.sender].exists);

        addCommissionAmount(msg.value, msg.sender);

        emit PlatformOutgoingTransactionCommission(msg.sender, msg.value);
    }

    function payUserIncomingTransactionCommission(address clientAddress) public payable {
         
        require(productContracts[msg.sender].exists);

         
        if(!isClientAddedBefore(clientAddress, msg.sender)) {
            if(canAddNewClient(productContracts[msg.sender].user)) {
                addClient(clientAddress, msg.sender);
            } else {
                revert();
            }
        }

        addCommissionAmount(msg.value, msg.sender);

        emit UserIncomingTransactionCommission(msg.sender, msg.value);
    }

    function payUserOutgoingTransactionCommission() public payable {
         
        require(productContracts[msg.sender].exists);

        addCommissionAmount(msg.value, msg.sender);

        emit UserOutgoingTransactionCommission(msg.sender, msg.value);
    }

    function getUserTokensCount(address userAddress) private view returns (uint256) {
        TokensContract tokensContract = TokensContract(tokensContractAddress);

        uint256 tcBalance = tokensContract.balanceOf(userAddress);

        return tcBalance.div(tokensDecimals);
    }

    function canAddNewClient(address userAddress) private returns (bool) {
         
        require(users[userAddress].exists);

        uint256 userClientsCount = getUserClientsCount(userAddress);
        uint256 userTokensCountAvailable = getUserTokensCount(userAddress).mul(tokensMultiplier);

        if(userClientsCount >= userTokensCountAvailable) return false;

         
        if(userClientsCount.mul(10000).div(userTokensCountAvailable) >= 9000) emit NintyPercentClientsReached(userAddress);

        return true;
    }

    function saasPayUser() public payable {
         
        require(users[msg.sender].exists);

        users[msg.sender].balance += int(msg.value);

        emit SaasUserPaid(msg.sender, msg.value);
    }

    function saasPayment(address userAddress, uint256 amount) public onlyOwner {
         
        require(users[userAddress].exists);

         
        if(users[userAddress].balance < int(amount)) emit UserBalanceBelowZero(userAddress);

        users[userAddress].balance -= int(amount);

        emit SaasPayment(userAddress, amount);
    }
}