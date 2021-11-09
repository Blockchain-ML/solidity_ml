pragma solidity 0.4.24;


 
 
 
 
 
contract Database {

     
     
     
    mapping(bytes32 => uint) public uintStorage;
    mapping(bytes32 => string) public stringStorage;
    mapping(bytes32 => address) public addressStorage;
    mapping(bytes32 => bytes) public bytesStorage;
    mapping(bytes32 => bytes32) public bytes32Storage;
    mapping(bytes32 => bool) public boolStorage;
    mapping(bytes32 => int) public intStorage;



     
     
     
     
    constructor(address _ownerOne, address _ownerTwo, address _ownerThree)
    public {
        boolStorage[keccak256(abi.encodePacked("owner", _ownerOne))] = true;
        boolStorage[keccak256(abi.encodePacked("owner", _ownerTwo))] = true;
        boolStorage[keccak256(abi.encodePacked("owner", _ownerThree))] = true;
        emit LogInitialized(_ownerOne, _ownerTwo, _ownerThree);
    }


     
     
     
     
     
    function setContractManager(address _contractManager)
    external {
        require(_contractManager != address(0));
        require(boolStorage[keccak256(abi.encodePacked("owner", msg.sender))]);
         
        addressStorage[keccak256(abi.encodePacked("contract", "ContractManager"))] = _contractManager;
        boolStorage[keccak256(abi.encodePacked("contract", _contractManager))] = true;
        emit LogContractManager(_contractManager, msg.sender); 
    }

     
     
     

    function setAddress(bytes32 _key, address _value)
    onlyMyBitContract
    external {
        addressStorage[_key] = _value;
    }

    function setUint(bytes32 _key, uint _value)
    onlyMyBitContract
    external {
        uintStorage[_key] = _value;
    }

    function setString(bytes32 _key, string _value)
    onlyMyBitContract
    external {
        stringStorage[_key] = _value;
    }

    function setBytes(bytes32 _key, bytes _value)
    onlyMyBitContract
    external {
        bytesStorage[_key] = _value;
    }

    function setBytes32(bytes32 _key, bytes32 _value)
    onlyMyBitContract
    external {
        bytes32Storage[_key] = _value;
    }

    function setBool(bytes32 _key, bool _value)
    onlyMyBitContract
    external {
        boolStorage[_key] = _value;
    }

    function setInt(bytes32 _key, int _value)
    onlyMyBitContract
    external {
        intStorage[_key] = _value;
    }


     
     
     

    function deleteAddress(bytes32 _key)
    onlyMyBitContract
    external {
        delete addressStorage[_key];
    }

    function deleteUint(bytes32 _key)
    onlyMyBitContract
    external {
        delete uintStorage[_key];
    }

    function deleteString(bytes32 _key)
    onlyMyBitContract
    external {
        delete stringStorage[_key];
    }

    function deleteBytes(bytes32 _key)
    onlyMyBitContract
    external {
        delete bytesStorage[_key];
    }

    function deleteBytes32(bytes32 _key)
    onlyMyBitContract
    external {
        delete bytes32Storage[_key];
    }

    function deleteBool(bytes32 _key)
    onlyMyBitContract
    external {
        delete boolStorage[_key];
    }

    function deleteInt(bytes32 _key)
    onlyMyBitContract
    external {
        delete intStorage[_key];
    }



     
     
     
    modifier onlyMyBitContract() {
        require(boolStorage[keccak256(abi.encodePacked("contract", msg.sender))]);
        _;
    }

     
     
     
    event LogInitialized(address indexed _ownerOne, address indexed _ownerTwo, address indexed _ownerThree);
    event LogContractManager(address indexed _contractManager, address indexed _initiator); 
}

   

   
   
   
library SafeMath {

   
   
   
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

   
   
   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
   
   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
   
   
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

   
   
   
  function getFractionalAmount(uint256 _amount, uint256 _percentage)
  internal
  pure
  returns (uint256) {
    return div(mul(_amount, _percentage), 100);
  }

   
   
   
   
  function bytesToUint(bytes b) internal pure returns (uint256) {
      uint256 number;
      for(uint i=0; i < b.length; i++){
          number = number + uint(b[i]) * (2**(8 * (b.length - (i+1))));
      }
      return number;
  }

}

 
 
 
 
contract InitialVariables {
  using SafeMath for uint; 

Database public database;

 
 
 
constructor(address _database)
public {
  database = Database(_database);
}
 
 
 
function startDapp(address _myBitFoundation, address _installerEscrow)
external  {
  require(database.boolStorage(keccak256(abi.encodePacked("owner", msg.sender))));
  require(_myBitFoundation != address(0) && _installerEscrow != address(0));
   
  database.setAddress(keccak256(abi.encodePacked("MyBitFoundation")), _myBitFoundation);
  database.setAddress(keccak256(abi.encodePacked("InstallerEscrow")), _installerEscrow);
   
  database.setUint(keccak256(abi.encodePacked("myBitFoundationPercentage")), uint(1));
  database.setUint(keccak256(abi.encodePacked("installerPercentage")), uint(99));
   
  database.setUint(keccak256(abi.encodePacked("accessTokenFee", uint(1))), uint(25).mul(10**21));     
  database.setUint(keccak256(abi.encodePacked("accessTokenFee", uint(2))), uint(75).mul(10**21));     
  database.setUint(keccak256(abi.encodePacked("accessTokenFee", uint(3))), uint(100).mul(10**21));    
   
  database.setUint(keccak256(abi.encodePacked("priceUpdateTimeline")), uint(86400));      
  emit LogInitialized(msg.sender, address(database));
}

 
 
 
function changeFoundationAddress(address _signer, string _functionName, address _newAddress)
external
noEmptyAddress(_newAddress)
anyOwner
multiSigRequired(_signer, _functionName, keccak256(abi.encodePacked(_newAddress))) {
  database.setAddress(keccak256(abi.encodePacked("MyBitFoundation")), _newAddress);
}

 
 
 
function changeInstallerEscrowAddress(address _signer, string _functionName, address _newAddress)
external
noEmptyAddress(_newAddress)
anyOwner
multiSigRequired(_signer, _functionName, keccak256(abi.encodePacked(_newAddress))) {
  database.setAddress(keccak256(abi.encodePacked("InstallerEscrow")), _newAddress);
}

 
 
 
function changeAccessTokenFee(address _signer, string _functionName, uint _accessLevel, uint _newPrice)
external
anyOwner
multiSigRequired(_signer, _functionName, keccak256(abi.encodePacked(_accessLevel, _newPrice))) {
  database.setUint(keccak256(abi.encodePacked("accessTokenFee", _accessLevel)), _newPrice);
}

 
 
 
function setDailyPrices(uint _ethPrice, uint _mybPrice)
external 
anyOwner 
returns (bool) { 
    uint priceExpiration = database.uintStorage(keccak256(abi.encodePacked("priceUpdateTimeline"))).add(now);
    emit LogPriceUpdate(database.uintStorage(keccak256(abi.encodePacked("ethUSDPrice"))),database.uintStorage(keccak256(abi.encodePacked("mybUSDPrice")))); 
    database.setUint(keccak256(abi.encodePacked("ethUSDPrice")), _ethPrice);
    database.setUint(keccak256(abi.encodePacked("mybUSDPrice")), _mybPrice);
    database.setUint(keccak256(abi.encodePacked("priceExpiration")), priceExpiration);
    return true; 
}


 
 
 

 
 
 
modifier anyOwner {
  require(database.boolStorage(keccak256(abi.encodePacked("owner", msg.sender))));
  _;
}

 
 
 
modifier noEmptyAddress(address _contract) {
  require(_contract != address(0));
  _;
}

 
 
 
modifier multiSigRequired(address _signer, string _functionName, bytes32 _keyParam) {
  require(msg.sender != _signer);
  require(database.boolStorage(keccak256(abi.encodePacked(address(this), _signer, _functionName, _keyParam))));
  database.setBool(keccak256(abi.encodePacked(address(this), _signer, _functionName, _keyParam)), false);
  _;
}


 
 
 
event LogInitialized(address _sender, address _database);
event LogPriceUpdate(uint _oldETHPrice, uint _oldMYBPrice); 

}