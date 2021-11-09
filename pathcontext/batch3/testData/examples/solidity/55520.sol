pragma solidity 0.4.24;

 

 
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

 

 
contract Claimable is Ownable {
  address public pendingOwner;

   
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

   
  function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

 

contract Adminable is Claimable {
    address[] public adminArray;

    struct AdminInfo {
        bool valid;
        uint index;
    }

    mapping(address => AdminInfo) public adminTable;

    event AdminAccepted(address indexed admin);
    event AdminRejected(address indexed admin);

     
    modifier onlyAdmin() {
        require(adminTable[msg.sender].valid);
        _;
    }

     
    function accept(address admin) external onlyOwner {
        require(admin != address(0));
        AdminInfo storage adminInfo = adminTable[admin];
        require(!adminInfo.valid);
        adminInfo.valid = true;
        adminInfo.index = adminArray.length;
        adminArray.push(admin);
        emit AdminAccepted(admin);
    }

     
    function reject(address admin) external onlyOwner {
        AdminInfo storage adminInfo = adminTable[admin];
        require(adminInfo.index < adminArray.length);
        require(admin == adminArray[adminInfo.index]);
        address lastAdmin = adminArray[adminArray.length - 1];
        adminTable[lastAdmin].index = adminInfo.index;
        adminArray[adminInfo.index] = lastAdmin;
        adminArray.length -= 1;
        delete adminTable[admin];
        emit AdminRejected(admin);
    }

     
    function getAdminArray() external view returns (address[]) {
        return adminArray;
    }

     
    function getAdminCount() external view returns (uint) {
        return adminArray.length;
    }
}

 

interface IAuthorizationDataSource {
    function isAuthorized(address wallet) external view returns (bool);
    function isRestricted(address wallet) external view returns (bool);
    function tradingClass(address wallet) external view returns (uint);
}

 

contract AuthorizationDataSource is IAuthorizationDataSource, Adminable {
    uint public walletCount;

    struct WalletInfo {
        uint sequenceNum;
        bool isAuthorized;
        bool isRestricted;
        uint tradingClass;
    }

    mapping(address => WalletInfo) public walletTable;

    event WalletSaved(address indexed wallet);
    event WalletDeleted(address indexed wallet);
    event WalletNotSaved(address indexed wallet);
    event WalletNotDeleted(address indexed wallet);

    function isAuthorized(address wallet) external view returns (bool) {
        return walletTable[wallet].isAuthorized;
    }

    function isRestricted(address wallet) external view returns (bool) {
        return walletTable[wallet].isRestricted;
    }

    function tradingClass(address wallet) external view returns (uint) {
        return walletTable[wallet].tradingClass;
    }

    function upsertOne(address wallet, uint sequenceNum, bool isAuthorizedVal, bool isRestrictedVal, uint tradingClassVal) external onlyAdmin {
        _upsert(wallet, sequenceNum, isAuthorizedVal, isRestrictedVal, tradingClassVal);
    }

    function removeOne(address wallet) external onlyAdmin {
        _remove(wallet);
    }

    function upsertAll(address[] wallets, uint sequenceNum, bool isAuthorizedVal, bool isRestrictedVal, uint tradingClassVal) external onlyAdmin {
        for (uint i = 0; i < wallets.length; i++)
            _upsert(wallets[i], sequenceNum, isAuthorizedVal, isRestrictedVal, tradingClassVal);
    }

    function removeAll(address[] wallets) external onlyAdmin {
        for (uint i = 0; i < wallets.length; i++)
            _remove(wallets[i]);
    }

     
    function _upsert(address wallet, uint sequenceNum, bool isAuthorizedVal, bool isRestrictedVal, uint tradingClassVal) private {
        require(wallet != address(0));
        WalletInfo storage walletInfo = walletTable[wallet];
        if (walletInfo.sequenceNum < sequenceNum) {
            if (walletInfo.sequenceNum == 0)
                walletCount += 1;
            walletInfo.sequenceNum = sequenceNum;
            walletInfo.isAuthorized = isAuthorizedVal;
            walletInfo.isRestricted = isRestrictedVal;
            walletInfo.tradingClass = tradingClassVal;
            emit WalletSaved(wallet);
        }
        else {
            emit WalletNotSaved(wallet);
        }
    }

     
    function _remove(address wallet) private {
        require(wallet != address(0));
        WalletInfo storage walletInfo = walletTable[wallet];
        if (walletInfo.sequenceNum > 0) {
            walletCount -= 1;
            delete walletTable[wallet];
            emit WalletDeleted(wallet);
        }
        else {
            emit WalletNotDeleted(wallet);
        }
    }
}