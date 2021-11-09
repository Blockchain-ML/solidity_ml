 
pragma solidity ^0.4.24;

 
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

   
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

   
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

   
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

 
 
pragma solidity ^0.4.24;


contract MinterRole {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private minters;

  constructor() internal {
    _addMinter(msg.sender);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender));
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyMinter {
    _addMinter(account);
  }

  function renounceMinter() public {
    _removeMinter(msg.sender);
  }

  function _addMinter(address account) internal {
    minters.add(account);
    emit MinterAdded(account);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}

 
 
 
pragma solidity ^0.4.24;

 
interface IERC1400  {

     
    function getDocument(bytes32 name) external view returns (string, bytes32);  
    function setDocument(bytes32 name, string uri, bytes32 documentHash) external;  
    event Document(bytes32 indexed name, string uri, bytes32 documentHash);

     
    function isControllable() external view returns (bool);  

     
    function isIssuable() external view returns (bool);  
    function issueByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes data) external;  
    event IssuedByPartition(bytes32 indexed partition, address indexed operator, address indexed to, uint256 value, bytes data, bytes operatorData);

     
    function redeemByPartition(bytes32 partition, uint256 value, bytes data) external;  
    function operatorRedeemByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes data, bytes operatorData) external;  
    event RedeemedByPartition(bytes32 indexed partition, address indexed operator, address indexed from, uint256 value, bytes data, bytes operatorData);

     
    function canTransfer(bytes32 partition, address to, uint256 value, bytes data) external view returns (byte, bytes32, bytes32);  

}

 

 
 
 
pragma solidity ^0.4.24;

 
interface IERC1410 {

     
    function balanceOfByPartition(bytes32 partition, address tokenHolder) external view returns (uint256);  
    function partitionsOf(address tokenHolder) external view returns (bytes32[]);  

     
    function transferByPartition(bytes32 partition, address to, uint256 value, bytes data) external returns (bytes32);  
    function operatorTransferByPartition(bytes32 partition, address from, address to, uint256 value, bytes data, bytes operatorData) external returns (bytes32);  

     
    function getDefaultPartitions(address tokenHolder) external view returns (bytes32[]);  
    function setDefaultPartitions(bytes32[] partitions) external;  

     
    function controllersByPartition(bytes32 partition) external view returns (address[]);  
    function authorizeOperatorByPartition(bytes32 partition, address operator) external;  
    function revokeOperatorByPartition(bytes32 partition, address operator) external;  
    function isOperatorForPartition(bytes32 partition, address operator, address tokenHolder) external view returns (bool);  

     
    event TransferByPartition(
        bytes32 indexed fromPartition,
        address operator,
        address indexed from,
        address indexed to,
        uint256 value,
        bytes data,
        bytes operatorData
    );

    event ChangedPartition(
        bytes32 indexed fromPartition,
        bytes32 indexed toPartition,
        uint256 value
    );

     
    event AuthorizedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);
    event RevokedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);

}

 
 
pragma solidity ^0.4.24;

 
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

 
 
pragma solidity ^0.4.24;

 
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

 
 
pragma solidity ^0.4.24;


contract ERC820Registry {
    function setInterfaceImplementer(address _addr, bytes32 _interfaceHash, address _implementer) external;
    function getInterfaceImplementer(address _addr, bytes32 _interfaceHash) external view returns (address);
    function setManager(address _addr, address _newManager) external;
    function getManager(address _addr) public view returns(address);
}


 
contract ERC820Client {
    ERC820Registry constant ERC820REGISTRY = ERC820Registry(0x820b586C8C28125366C998641B09DCbE7d4cBF06);

    function setInterfaceImplementation(string _interfaceLabel, address _implementation) internal {
        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));
        ERC820REGISTRY.setInterfaceImplementer(this, interfaceHash, _implementation);
    }

    function interfaceAddr(address addr, string _interfaceLabel) internal view returns(address) {
        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));
        return ERC820REGISTRY.getInterfaceImplementer(addr, interfaceHash);
    }

    function delegateManagement(address _newManager) internal {
        ERC820REGISTRY.setManager(this, _newManager);
    }
}

 
 
pragma solidity ^0.4.24;


contract CertificateController {

   
  mapping(address => bool) public certificateSigners;

   
  mapping(address => uint) public checkCount;

  event Checked(address sender);

  constructor(address _certificateSigner) public {
    require(_certificateSigner != address(0), "Constructor Blocked - Valid address required");
    certificateSigners[_certificateSigner] = true;
  }

   
  modifier isValidCertificate(bytes data) {

    require(_checkCertificate(data, msg.value, 0x00000000), "A3: Transfer Blocked - Sender lockup period not ended");

    checkCount[msg.sender] += 1;  

    emit Checked(msg.sender);
    _;
  }

   
  function _checkCertificate(
    bytes data,
    uint256 amount,
    bytes4 functionID
  )
    internal
    view
    returns(bool)
  {
    uint256 counter = checkCount[msg.sender];

    uint256 e;
    bytes32 r;
    bytes32 s;
    uint8 v;

     
    if (data.length != 97) {
      return false;
    }

     
    assembly {
       
       
      e := mload(add(data, 0x20))
      r := mload(add(data, 0x40))
      s := mload(add(data, 0x60))
      v := byte(0, mload(add(data, 0x80)))
    }

     
    if (e < now) {
      return false;
    }

    if (v < 27) {
      v += 27;
    }

     
    if (v == 27 || v == 28) {
       
      bytes memory payload;

      assembly {
        let payloadsize := sub(calldatasize, 160)
        payload := mload(0x40)  
        mstore(0x40, add(payload, and(add(add(payloadsize, 0x20), 0x1f), not(0x1f))))  
        mstore(payload, payloadsize)  
        calldatacopy(add(add(payload, 0x20), 4), 4, sub(payloadsize, 4))
      }

      if(functionID == 0x00000000) {
        assembly {
          calldatacopy(add(payload, 0x20), 0, 4)
        }
      } else {
        for (uint i = 0; i < 4; i++) {  
          payload[i] = functionID[i];
        }
      }

       
      bytes memory pack = abi.encodePacked(
        msg.sender,
        this,
        amount,
        payload,
        e,
        counter
      );
      bytes32 hash = keccak256(pack);

       
      if (certificateSigners[ecrecover(hash, v, r, s)]) {
        return true;
      }
    }
    return false;
  }
}

 
 
 
pragma solidity ^0.4.24;

 
interface IERC777 {

  function name() external view returns (string);  
  function symbol() external view returns (string);  
  function totalSupply() external view returns (uint256);  
  function balanceOf(address owner) external view returns (uint256);  
  function granularity() external view returns (uint256);  

  function controllers() external view returns (address[]);  
  function authorizeOperator(address operator) external;  
  function revokeOperator(address operator) external;  
  function isOperatorFor(address operator, address tokenHolder) external view returns (bool);  

  function transferWithData(address to, uint256 value, bytes data) external;  
  function transferFromWithData(address from, address to, uint256 value, bytes data, bytes operatorData) external;  

  function burn(uint256 value, bytes data) external;  
  function operatorBurn(address from, uint256 value, bytes data, bytes operatorData) external;  

  event Sent(
    address indexed operator,
    address indexed from,
    address indexed to,
    uint256 value,
    bytes data,
    bytes operatorData
  );
  event Minted(address indexed operator, address indexed to, uint256 value, bytes data, bytes operatorData);
  event Burned(address indexed operator, address indexed from, uint256 value, bytes data, bytes operatorData);
  event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
  event RevokedOperator(address indexed operator, address indexed tokenHolder);

}

 
 
 
pragma solidity ^0.4.24;

 
interface IERC777TokensSender {

  function canTransfer(
    bytes32 partition,
    address from,
    address to,
    uint value,
    bytes data,
    bytes operatorData
  ) external view returns(bool);

  function tokensToTransfer(
    address operator,
    address from,
    address to,
    uint value,
    bytes data,
    bytes operatorData
  ) external;

}

 
 
 
pragma solidity ^0.4.24;

 
interface IERC777TokensRecipient {

  function canReceive(
    bytes32 partition,
    address from,
    address to,
    uint value,
    bytes data,
    bytes operatorData
  ) external view returns(bool);

  function tokensReceived(
    address operator,
    address from,
    address to,
    uint value,
    bytes data,
    bytes operatorData
  ) external;

}

 
 
 
pragma solidity ^0.4.24;




 
contract ERC777 is IERC777, Ownable, ERC820Client, CertificateController {
  using SafeMath for uint256;

  string internal _name;
  string internal _symbol;
  uint256 internal _granularity;
  uint256 internal _totalSupply;

   
  bool internal _isControllable;

   
  mapping(address => uint256) internal _balances;

   
   
  mapping(address => mapping(address => bool)) internal _authorizedOperator;

   
  address[] internal _controllers;

   
  mapping(address => bool) internal _isController;
   

   
  modifier controllableToken() {
    require(_isControllable, "A8: Transfer Blocked - Token restriction");
    _;
  }

   
  constructor(
    string name,
    string symbol,
    uint256 granularity,
    address[] controllers,
    address certificateSigner
  )
    public
    CertificateController(certificateSigner)
  {
    _name = name;
    _symbol = symbol;
    _totalSupply = 0;
    require(granularity >= 1, "Constructor Blocked - Token granularity can not be lower than 1");
    _granularity = granularity;

    for (uint i = 0; i < controllers.length; i++) {
      _addController(controllers[i]);
    }

    setInterfaceImplementation("ERC777Token", this);
  }

   

   
  function name() external view returns(string) {
    return _name;
  }

   
  function symbol() external view returns(string) {
    return _symbol;
  }

   
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

   
  function balanceOf(address tokenHolder) external view returns (uint256) {
    return _balances[tokenHolder];
  }

   
  function granularity() external view returns(uint256) {
    return _granularity;
  }

   
  function controllers() external view returns (address[]) {
    return _controllers;
  }

   
  function authorizeOperator(address operator) external {
    _authorizedOperator[operator][msg.sender] = true;
    emit AuthorizedOperator(operator, msg.sender);
  }

   
  function revokeOperator(address operator) external {
    _authorizedOperator[operator][msg.sender] = false;
    emit RevokedOperator(operator, msg.sender);
  }

   
  function isOperatorFor(address operator, address tokenHolder) external view returns (bool) {
    return _isOperatorFor(operator, tokenHolder);
  }

   
  function transferWithData(address to, uint256 value, bytes data)
    external
    isValidCertificate(data)
  {
    _transferWithData(msg.sender, msg.sender, to, value, data, "", true);
  }

   
  function transferFromWithData(address from, address to, uint256 value, bytes data, bytes operatorData)
    external
    isValidCertificate(operatorData)
  {
    address _from = (from == address(0)) ? msg.sender : from;

    require(_isOperatorFor(msg.sender, _from), "A7: Transfer Blocked - Identity restriction");

    _transferWithData(msg.sender, _from, to, value, data, operatorData, true);
  }

   
  function burn(uint256 value, bytes data)
    external
    isValidCertificate(data)
  {
    _burn(msg.sender, msg.sender, value, data, "");
  }

   
  function operatorBurn(address from, uint256 value, bytes data, bytes operatorData)
    external
    isValidCertificate(operatorData)
  {
    address _from = (from == address(0)) ? msg.sender : from;

    require(_isOperatorFor(msg.sender, _from), "A7: Transfer Blocked - Identity restriction");

    _burn(msg.sender, _from, value, data, operatorData);
  }

   

   
  function _isMultiple(uint256 value) internal view returns(bool) {
    return(value.div(_granularity).mul(_granularity) == value);
  }

   
  function _isRegularAddress(address addr) internal view returns(bool) {
    if (addr == address(0)) { return false; }
    uint size;
    assembly { size := extcodesize(addr) }  
    return size == 0;
  }

   
  function _isOperatorFor(address operator, address tokenHolder) internal view returns (bool) {
    return (operator == tokenHolder
      || _authorizedOperator[operator][tokenHolder]
      || (_isControllable && _isController[operator])
    );
  }

    
  function _transferWithData(
    address operator,
    address from,
    address to,
    uint256 value,
    bytes data,
    bytes operatorData,
    bool preventLocking
  )
    internal
  {
    require(_isMultiple(value), "A9: Transfer Blocked - Token granularity");
    require(to != address(0), "A6: Transfer Blocked - Receiver not eligible");
    require(_balances[from] >= value, "A4: Transfer Blocked - Sender balance insufficient");

    _callSender(operator, from, to, value, data, operatorData);

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);

    _callRecipient(operator, from, to, value, data, operatorData, preventLocking);

    emit Sent(operator, from, to, value, data, operatorData);
  }

   
  function _burn(address operator, address from, uint256 value, bytes data, bytes operatorData)
    internal
  {
    require(_isMultiple(value), "A9: Transfer Blocked - Token granularity");
    require(from != address(0), "A5: Transfer Blocked - Sender not eligible");
    require(_balances[from] >= value, "A4: Transfer Blocked - Sender balance insufficient");

    _callSender(operator, from, address(0), value, data, operatorData);

    _balances[from] = _balances[from].sub(value);
    _totalSupply = _totalSupply.sub(value);

    emit Burned(operator, from, value, data, operatorData);
  }

   
  function _callSender(
    address operator,
    address from,
    address to,
    uint256 value,
    bytes data,
    bytes operatorData
  )
    internal
  {
    address senderImplementation;
    senderImplementation = interfaceAddr(from, "ERC777TokensSender");

    if (senderImplementation != address(0)) {
      IERC777TokensSender(senderImplementation).tokensToTransfer(operator, from, to, value, data, operatorData);
    }
  }

   
  function _callRecipient(
    address operator,
    address from,
    address to,
    uint256 value,
    bytes data,
    bytes operatorData,
    bool preventLocking
  )
    internal
  {
    address recipientImplementation;
    recipientImplementation = interfaceAddr(to, "ERC777TokensRecipient");

    if (recipientImplementation != address(0)) {
      IERC777TokensRecipient(recipientImplementation).tokensReceived(operator, from, to, value, data, operatorData);
    } else if (preventLocking) {
      require(_isRegularAddress(to), "A6: Transfer Blocked - Receiver not eligible");
    }
  }

   
  function _mint(address operator, address to, uint256 value, bytes data, bytes operatorData) internal {
    require(_isMultiple(value), "A9: Transfer Blocked - Token granularity");
    require(to != address(0), "A6: Transfer Blocked - Receiver not eligible");       

    _totalSupply = _totalSupply.add(value);
    _balances[to] = _balances[to].add(value);

    _callRecipient(operator, address(0), to, value, data, operatorData, true);

    emit Minted(operator, to, value, data, operatorData);
  }

   

   
  function _addController(address operator) internal {
    require(!_isController[operator], "Action Blocked - Already a controller");
    _controllers.push(operator);
    _isController[operator] = true;
  }

   
  function _removeController(address operator) internal {
    require(_isController[operator], "Action Blocked - Not a controller");

    for (uint i = 0; i<_controllers.length; i++){
      if(_controllers[i] == operator) {
        _controllers[i] = _controllers[_controllers.length - 1];
        delete _controllers[_controllers.length-1];
        _controllers.length--;
        break;
      }
    }
    _isController[operator] = false;
  }
}

 
 
 
pragma solidity ^0.4.24;


 
contract ERC1410 is IERC1410, ERC777 {

   
   
  bytes32[] internal _totalPartitions;

   
  mapping (bytes32 => uint256) internal _totalSupplyByPartition;

   
  mapping (address => bytes32[]) internal _partitionsOf;

   
  mapping (address => mapping (bytes32 => uint256)) internal _balanceOfByPartition;

   
  mapping (address => bytes32[]) internal _defaultPartitionsOf;

   
  bytes32[] internal _tokenDefaultPartitions;
   

   
   
  mapping (address => mapping (bytes32 => mapping (address => bool))) internal _partitionAuthorizedOperator;

   
  mapping (bytes32 => address[]) internal _partitionControllers;

   
  mapping (bytes32 => mapping (address => bool)) internal _isPartitionController;
   

   
  constructor(
    string name,
    string symbol,
    uint256 granularity,
    address[] controllers,
    address certificateSigner,
    bytes32[] tokenDefaultPartitions
  )
    public
    ERC777(name, symbol, granularity, controllers, certificateSigner)
  {
    setInterfaceImplementation("ERC1410Token", this);
    _tokenDefaultPartitions = tokenDefaultPartitions;
  }

   

   
  function balanceOfByPartition(bytes32 partition, address tokenHolder) external view returns (uint256) {
    return _balanceOfByPartition[tokenHolder][partition];
  }

   
  function partitionsOf(address tokenHolder) external view returns (bytes32[]) {
    return _partitionsOf[tokenHolder];
  }

   
  function transferByPartition(
    bytes32 partition,
    address to,
    uint256 value,
    bytes data
  )
    external
    isValidCertificate(data)
    returns (bytes32)
  {
    return _transferByPartition(partition, msg.sender, msg.sender, to, value, data, "");
  }

   
  function operatorTransferByPartition(
    bytes32 partition,
    address from,
    address to,
    uint256 value,
    bytes data,
    bytes operatorData
  )
    external
    isValidCertificate(operatorData)
    returns (bytes32)
  {
    address _from = (from == address(0)) ? msg.sender : from;
    require(_isOperatorForPartition(partition, msg.sender, _from), "A7: Transfer Blocked - Identity restriction");

    return _transferByPartition(partition, msg.sender, _from, to, value, data, operatorData);
  }

   
  function getDefaultPartitions(address tokenHolder) external view returns (bytes32[]) {
    return _defaultPartitionsOf[tokenHolder];
  }

   
  function setDefaultPartitions(bytes32[] partitions) external {
    _defaultPartitionsOf[msg.sender] = partitions;
  }

   
  function controllersByPartition(bytes32 partition) external view returns (address[]) {
    return _partitionControllers[partition];
  }

   
  function authorizeOperatorByPartition(bytes32 partition, address operator) external {
    _partitionAuthorizedOperator[msg.sender][partition][operator] = true;
    emit AuthorizedOperatorByPartition(partition, operator, msg.sender);
  }

   
  function revokeOperatorByPartition(bytes32 partition, address operator) external {
    _partitionAuthorizedOperator[msg.sender][partition][operator] = false;
    emit RevokedOperatorByPartition(partition, operator, msg.sender);
  }

   
  function isOperatorForPartition(bytes32 partition, address operator, address tokenHolder) external view returns (bool) {
    return _isOperatorForPartition(partition, operator, tokenHolder);
  }

   

   
   function _isOperatorForPartition(bytes32 partition, address operator, address tokenHolder) internal view returns (bool) {
     return (_isOperatorFor(operator, tokenHolder)
       || _partitionAuthorizedOperator[tokenHolder][partition][operator]
       || (_isControllable && _isPartitionController[partition][operator])
     );
   }

   
  function _transferByPartition(
    bytes32 fromPartition,
    address operator,
    address from,
    address to,
    uint256 value,
    bytes data,
    bytes operatorData
  )
    internal
    returns (bytes32)
  {
    require(_balanceOfByPartition[from][fromPartition] >= value, "A4: Transfer Blocked - Sender balance insufficient");  

    bytes32 toPartition = fromPartition;
    if(operatorData.length != 0 && data.length != 0) {
      toPartition = _getDestinationPartition(data);
    }

    _removeTokenFromPartition(from, fromPartition, value);
    _transferWithData(operator, from, to, value, data, operatorData, true);
    _addTokenToPartition(to, toPartition, value);

    emit TransferByPartition(fromPartition, operator, from, to, value, data, operatorData);

    if(toPartition != fromPartition) {
      emit ChangedPartition(fromPartition, toPartition, value);
    }

    return toPartition;
  }

   
  function _removeTokenFromPartition(address from, bytes32 partition, uint256 value) internal {
    _balanceOfByPartition[from][partition] = _balanceOfByPartition[from][partition].sub(value);
    _totalSupplyByPartition[partition] = _totalSupplyByPartition[partition].sub(value);

     
    if(_balanceOfByPartition[from][partition] == 0) {
      for (uint i = 0; i < _partitionsOf[from].length; i++) {
        if(_partitionsOf[from][i] == partition) {
          _partitionsOf[from][i] = _partitionsOf[from][_partitionsOf[from].length - 1];
          delete _partitionsOf[from][_partitionsOf[from].length - 1];
          _partitionsOf[from].length--;
          break;
        }
      }
    }

     
    if(_totalSupplyByPartition[partition] == 0) {
      for (i = 0; i < _totalPartitions.length; i++) {
        if(_totalPartitions[i] == partition) {
          _totalPartitions[i] = _totalPartitions[_totalPartitions.length - 1];
          delete _totalPartitions[_totalPartitions.length - 1];
          _totalPartitions.length--;
          break;
        }
      }
    }
  }

   
  function _addTokenToPartition(address to, bytes32 partition, uint256 value) internal {
    if(value != 0) {
      if(_balanceOfByPartition[to][partition] == 0) {
        _partitionsOf[to].push(partition);
      }
      _balanceOfByPartition[to][partition] = _balanceOfByPartition[to][partition].add(value);

      if(_totalSupplyByPartition[partition] == 0) {
        _totalPartitions.push(partition);
      }
      _totalSupplyByPartition[partition] = _totalSupplyByPartition[partition].add(value);
    }
  }

   
  function _getDestinationPartition(bytes data) internal pure returns(bytes32 toPartition) {
    assembly {
      toPartition := mload(add(data, 32))
    }
  }

   
  function _getDefaultPartitions(address tokenHolder) internal view returns(bytes32[]) {
    if(_defaultPartitionsOf[tokenHolder].length != 0) {
      return _defaultPartitionsOf[tokenHolder];
    } else {
      return _tokenDefaultPartitions;
    }
  }


   

   
  function totalPartitions() external view returns (bytes32[]) {
    return _totalPartitions;
  }

   
  function _addControllerByPartition(bytes32 partition, address operator) internal {
    require(!_isPartitionController[partition][operator], "Action Blocked - Already a controller");
    _partitionControllers[partition].push(operator);
    _isPartitionController[partition][operator] = true;
  }

   
  function _removeControllerByPartition(bytes32 partition, address operator) internal {
    require(_isPartitionController[partition][operator], "Action Blocked - Not a controller");

    for (uint i = 0; i < _partitionControllers[partition].length; i++){
      if(_partitionControllers[partition][i] == operator) {
        _partitionControllers[partition][i] = _partitionControllers[partition][_partitionControllers[partition].length - 1];
        delete _partitionControllers[partition][_partitionControllers[partition].length-1];
        _partitionControllers[partition].length--;
        break;
      }
    }
    _isPartitionController[partition][operator] = false;
  }

   

   
  function transferWithData(address to, uint256 value, bytes data)
    external
    isValidCertificate(data)
  {
    _transferByDefaultPartitions(msg.sender, msg.sender, to, value, data, "");
  }

   
  function transferFromWithData(address from, address to, uint256 value, bytes data, bytes operatorData)
    external
    isValidCertificate(operatorData)
  {
    address _from = (from == address(0)) ? msg.sender : from;

    require(_isOperatorFor(msg.sender, _from), "A7: Transfer Blocked - Identity restriction");

    _transferByDefaultPartitions(msg.sender, _from, to, value, data, operatorData);
  }

   
  function burn(uint256  , bytes  ) external {  
  }

   
  function operatorBurn(address  , uint256  , bytes  , bytes  ) external {  
  }

   
  function _transferByDefaultPartitions(
    address operator,
    address from,
    address to,
    uint256 value,
    bytes data,
    bytes operatorData
  )
    internal
  {
    bytes32[] memory _partitions = _getDefaultPartitions(from);
    require(_partitions.length != 0, "A8: Transfer Blocked - Token restriction");

    uint256 _remainingValue = value;
    uint256 _localBalance;

    for (uint i = 0; i < _partitions.length; i++) {
      _localBalance = _balanceOfByPartition[from][_partitions[i]];
      if(_remainingValue <= _localBalance) {
        _transferByPartition(_partitions[i], operator, from, to, _remainingValue, data, operatorData);
        _remainingValue = 0;
        break;
      } else {
        _transferByPartition(_partitions[i], operator, from, to, _localBalance, data, operatorData);
        _remainingValue = _remainingValue - _localBalance;
      }
    }

    require(_remainingValue == 0, "A8: Transfer Blocked - Token restriction");
  }
}

 
 
 
pragma solidity ^0.4.24;




 
contract ERC1400 is IERC1400, ERC1410, MinterRole {

  struct Doc {
    string docURI;
    bytes32 docHash;
  }

   
  mapping(bytes32 => Doc) internal _documents;

   
  bool internal _isIssuable;

   
  modifier issuableToken() {
    require(_isIssuable, "A8, Transfer Blocked - Token restriction");
    _;
  }

   
  constructor(
    string name,
    string symbol,
    uint256 granularity,
    address[] controllers,
    address certificateSigner,
    bytes32[] tokenDefaultPartitions
  )
    public
    ERC1410(name, symbol, granularity, controllers, certificateSigner, tokenDefaultPartitions)
  {
    setInterfaceImplementation("ERC1400Token", this);
    _isControllable = true;
    _isIssuable = true;
  }

   

   
  function getDocument(bytes32 name) external view returns (string, bytes32) {
    require(bytes(_documents[name].docURI).length != 0, "Action Blocked - Empty document");
    return (
      _documents[name].docURI,
      _documents[name].docHash
    );
  }

   
  function setDocument(bytes32 name, string uri, bytes32 documentHash) external onlyOwner {
    _documents[name] = Doc({
      docURI: uri,
      docHash: documentHash
    });
    emit Document(name, uri, documentHash);
  }

   
  function isControllable() external view returns (bool) {
    return _isControllable;
  }

   
  function isIssuable() external view returns (bool) {
    return _isIssuable;
  }

   
  function issueByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes data)
    external
    onlyMinter
    issuableToken
    isValidCertificate(data)
  {
    _issueByPartition(partition, msg.sender, tokenHolder, value, data, "");
  }

   
  function redeemByPartition(bytes32 partition, uint256 value, bytes data)
    external
    isValidCertificate(data)
  {
    _redeemByPartition(partition, msg.sender, msg.sender, value, data, "");
  }

   
  function operatorRedeemByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes data, bytes operatorData)
    external
    isValidCertificate(operatorData)
  {
    address _from = (tokenHolder == address(0)) ? msg.sender : tokenHolder;
    require(_isOperatorForPartition(partition, msg.sender, _from), "A7: Transfer Blocked - Identity restriction");

    _redeemByPartition(partition, msg.sender, _from, value, data, operatorData);
  }

   
  function canTransfer(bytes32 partition, address to, uint256 value, bytes data)
    external
    view
    returns (byte, bytes32, bytes32)
  {
    if(!_checkCertificate(data, 0, 0xf3d490db))  
      return(hex"A3", "", partition);  

    if((_balances[msg.sender] < value) || (_balanceOfByPartition[msg.sender][partition] < value))
      return(hex"A4", "", partition);  

    if(to == address(0))
      return(hex"A6", "", partition);  

    address senderImplementation;
    address recipientImplementation;
    senderImplementation = interfaceAddr(msg.sender, "ERC777TokensSender");
    recipientImplementation = interfaceAddr(to, "ERC777TokensRecipient");

    if((senderImplementation != address(0))
      && !IERC777TokensSender(senderImplementation).canTransfer(partition, msg.sender, to, value, data, ""))
      return(hex"A5", "", partition);  

    if((recipientImplementation != address(0))
      && !IERC777TokensRecipient(recipientImplementation).canReceive(partition, msg.sender, to, value, data, ""))
      return(hex"A6", "", partition);  

    if(!_isMultiple(value))
      return(hex"A9", "", partition);  

    return(hex"A2", "", partition);   
  }

   

   
  function _issueByPartition(
    bytes32 toPartition,
    address operator,
    address to,
    uint256 value,
    bytes data,
    bytes operatorData
  )
    internal
  {
    _mint(operator, to, value, data, operatorData);
    _addTokenToPartition(to, toPartition, value);

    emit IssuedByPartition(toPartition, operator, to, value, data, operatorData);
  }

   
  function _redeemByPartition(
    bytes32 fromPartition,
    address operator,
    address from,
    uint256 value,
    bytes data,
    bytes operatorData
  )
    internal
  {
    require(_balanceOfByPartition[from][fromPartition] >= value, "A4: Transfer Blocked - Sender balance insufficient");

    _removeTokenFromPartition(from, fromPartition, value);
    _burn(operator, from, value, data, operatorData);

    emit RedeemedByPartition(fromPartition, operator, from, value, data, operatorData);
  }

   

   
  function renounceControl() external onlyOwner {
    _isControllable = false;
  }

   
  function renounceIssuance() external onlyOwner {
    _isIssuable = false;
  }

   
  function addController(address operator) external onlyOwner controllableToken {
    _addController(operator);
  }

   
  function removeController(address operator) external onlyOwner {
    _removeController(operator);
  }

   
  function addControllerByPartition(bytes32 partition, address operator) external onlyOwner controllableToken {
    _addControllerByPartition(partition, operator);
  }

   
  function removeControllerByPartition(bytes32 partition, address operator) external onlyOwner {
    _removeControllerByPartition(partition, operator);
  }

   

   
  function getTokenDefaultPartitions() external view returns (bytes32[]) {
    return _tokenDefaultPartitions;
  }

   
  function setTokenDefaultPartitions(bytes32[] defaultPartitions) external {
    _tokenDefaultPartitions = defaultPartitions;
  }


   
  function burn(uint256 value, bytes data)
    external
    isValidCertificate(data)
  {
    _redeemByDefaultPartitions(msg.sender, msg.sender, value, data, "");
  }

   
  function operatorBurn(address from, uint256 value, bytes data, bytes operatorData)
    external
    isValidCertificate(operatorData)
  {
    address _from = (from == address(0)) ? msg.sender : from;

    require(_isOperatorFor(msg.sender, _from), "A7: Transfer Blocked - Identity restriction");

    _redeemByDefaultPartitions(msg.sender, _from, value, data, operatorData);
  }

   
  function _redeemByDefaultPartitions(
    address operator,
    address from,
    uint256 value,
    bytes data,
    bytes operatorData
  )
    internal
  {
    bytes32[] memory _partitions = _getDefaultPartitions(from);
    require(_partitions.length != 0, "A8: Transfer Blocked - Token restriction");

    uint256 _remainingValue = value;
    uint256 _localBalance;

    for (uint i = 0; i < _partitions.length; i++) {
      _localBalance = _balanceOfByPartition[from][_partitions[i]];
      if(_remainingValue <= _localBalance) {
        _redeemByPartition(_partitions[i], operator, from, _remainingValue, data, operatorData);
        _remainingValue = 0;
        break;
      } else {
        _redeemByPartition(_partitions[i], operator, from, _localBalance, data, operatorData);
        _remainingValue = _remainingValue - _localBalance;
      }
    }

    require(_remainingValue == 0, "A8: Transfer Blocked - Token restriction");
  }

}

 
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

 
contract ERC1400ERC20 is IERC20, ERC1400 {

  bool internal _erc20compatible;

   
  mapping (address => mapping (address => uint256)) internal _allowed;

   
  modifier erc20Compatible() {
    require(_erc20compatible, "Action Blocked - Token restriction");
    _;
  }

   
  constructor(
    string name,
    string symbol,
    uint256 granularity,
    address[] controllers,
    address certificateSigner,
    bytes32[] tokenDefaultPartitions
  )
    public
    ERC1400(name, symbol, granularity, controllers, certificateSigner, tokenDefaultPartitions)
  {}

   
  function _transferWithData(
    address operator,
    address from,
    address to,
    uint256 value,
    bytes data,
    bytes operatorData,
    bool preventLocking
  )
    internal
  {
    ERC777._transferWithData(operator, from, to, value, data, operatorData, preventLocking);

    if(_erc20compatible) {
      emit Transfer(from, to, value);
    }
  }

   
  function _burn(address operator, address from, uint256 value, bytes data, bytes operatorData) internal {
    ERC777._burn(operator, from, value, data, operatorData);

    if(_erc20compatible) {
      emit Transfer(from, address(0), value);   
    }
  }

   
  function _mint(address operator, address to, uint256 value, bytes data, bytes operatorData) internal {
    ERC777._mint(operator, to, value, data, operatorData);

    if(_erc20compatible) {
      emit Transfer(address(0), to, value);  
    }
  }

   
  function decimals() external view erc20Compatible returns(uint8) {
    return uint8(18);
  }

   
  function allowance(address owner, address spender) external view erc20Compatible returns (uint256) {
    return _allowed[owner][spender];
  }

   
  function approve(address spender, uint256 value) external erc20Compatible returns (bool) {
    require(spender != address(0), "A5: Transfer Blocked - Sender not eligible");
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

   
  function transfer(address to, uint256 value) external erc20Compatible returns (bool) {
    _transferByDefaultPartitions(msg.sender, msg.sender, to, value, "", "");
    return true;
  }

   
  function transferFrom(address from, address to, uint256 value) external erc20Compatible returns (bool) {
    address _from = (from == address(0)) ? msg.sender : from;
    require( _isOperatorFor(msg.sender, _from)
      || (value <= _allowed[_from][msg.sender]), "A7: Transfer Blocked - Identity restriction");

    if(_allowed[_from][msg.sender] >= value) {
      _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(value);
    } else {
      _allowed[_from][msg.sender] = 0;
    }

    _transferByDefaultPartitions(msg.sender, _from, to, value, "", "");
    return true;
  }

   

   
  function setERC20compatibility(bool erc20compatible) external onlyOwner {
    _setERC20compatibility(erc20compatible);
  }

   
  function _setERC20compatibility(bool erc20compatible) internal {
    _erc20compatible = erc20compatible;
    if(_erc20compatible) {
      setInterfaceImplementation("ERC20Token", this);
    } else {
      setInterfaceImplementation("ERC20Token", address(0));
    }
  }

}


 