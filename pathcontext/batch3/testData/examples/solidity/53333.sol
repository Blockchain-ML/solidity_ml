pragma solidity ^0.4.24;

 
interface BraidedInterface {
  function addStrand(uint, address, bytes32, string) external;
  function getStrandCount() external view returns (uint);
  function getStrandContract(uint) external view returns (address);
  function getStrandGenesisBlockHash(uint) external view returns (bytes32);
  function getStrandDescription(uint) external view returns (string);
  function addAgent(address, uint) external;
  function removeAgent(address, uint) external;
  function addBlock(uint, uint, bytes32) external;
  function getBlockHash(uint, uint) external view returns (bytes32);
  function getHighestBlockNumber(uint) external view returns (uint);
  function getPreviousBlockNumber(uint, uint) external view returns (uint);
  function getPreviousBlock(uint, uint) external view returns (uint, bytes32);
}

 
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

 
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

   
  function add(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = true;
  }

   
  function remove(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = false;
  }

   
  function check(Role storage _role, address _addr)
    internal
    view
  {
    require(has(_role, _addr));
  }

   
  function has(Role storage _role, address _addr)
    internal
    view
    returns (bool)
  {
    return _role.bearer[_addr];
  }
}

 
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);

   
  function checkRole(address _operator, string _role)
    public
    view
  {
    roles[_role].check(_operator);
  }

   
  function hasRole(address _operator, string _role)
    public
    view
    returns (bool)
  {
    return roles[_role].has(_operator);
  }

   
  function addRole(address _operator, string _role)
    internal
  {
    roles[_role].add(_operator);
    emit RoleAdded(_operator, _role);
  }

   
  function removeRole(address _operator, string _role)
    internal
  {
    roles[_role].remove(_operator);
    emit RoleRemoved(_operator, _role);
  }

   
  modifier onlyRole(string _role)
  {
    checkRole(msg.sender, _role);
    _;
  }

   
   
   
   
   
   
   
   
   

   

   
   
}

 
contract Superuser is Ownable, RBAC {
  string public constant ROLE_SUPERUSER = "superuser";

  constructor () public {
    addRole(msg.sender, ROLE_SUPERUSER);
  }

   
  modifier onlySuperuser() {
    checkRole(msg.sender, ROLE_SUPERUSER);
    _;
  }

  modifier onlyOwnerOrSuperuser() {
    require(msg.sender == owner || isSuperuser(msg.sender));
    _;
  }

   
  function isSuperuser(address _addr)
    public
    view
    returns (bool)
  {
    return hasRole(_addr, ROLE_SUPERUSER);
  }

   
  function transferSuperuser(address _newSuperuser) public onlySuperuser {
    require(_newSuperuser != address(0));
    removeRole(msg.sender, ROLE_SUPERUSER);
    addRole(_newSuperuser, ROLE_SUPERUSER);
  }

   
  function transferOwnership(address _newOwner) public onlyOwnerOrSuperuser {
    _transferOwnership(_newOwner);
  }
}

 
contract Braided is BraidedInterface, Superuser {

   
  struct Strand {
    uint strandID;
    address strandContract;  
    bytes32 genesisBlockHash;
    string description;
  }
  
   
  struct Block {
    uint blockNumber;
    bytes32 blockHash;
  }

   
  string constant INVALID_BLOCK = "invalid block";
  string constant INVALID_STRAND = "invalid strand";
  string constant NO_PERMISSION = "no permission";

   
  mapping (uint => Roles.Role) private addBlockRoles;

  Strand[] public strands;
  mapping(uint => uint) internal strandIndexByStrandID;
  mapping(uint => Block[]) internal blocks;
  mapping(uint => mapping(uint => uint)) internal blockByNumber;

  event BlockAdded(uint indexed strandID, uint indexed blockNumber, bytes32 blockHash);

  constructor() public {
     
    strands.push(Strand(0, 0, 0, ""));
  }

   
  function addStrand(uint strandID, address strandContract, bytes32 genesisBlockHash, string description) external onlyOwnerOrSuperuser() {
     
    require(strandID != 0, INVALID_STRAND);
     
    require(strandIndexByStrandID[strandID] == 0, INVALID_STRAND);
     
    strands.push(Strand(strandID, strandContract, genesisBlockHash, description));
     
    strandIndexByStrandID[strandID] = strands.length - 1;
  }

   
  modifier validStrandID(uint strandID) {
    require(strandIndexByStrandID[strandID] != 0, INVALID_STRAND);
    _;
  }

   
  function getStrandCount() external view returns (uint) {
    return strands.length - 1;
  }

   
   
   
  function getStrandContract(uint strandID) external view validStrandID(strandID) returns (address) {
    return strands[strandIndexByStrandID[strandID]].strandContract;
  }

   
  function getStrandGenesisBlockHash(uint strandID) external view validStrandID(strandID) returns (bytes32) {
    return strands[strandIndexByStrandID[strandID]].genesisBlockHash;
  }

   
  function getStrandDescription(uint strandID) external view validStrandID(strandID) returns (string) {
    return strands[strandIndexByStrandID[strandID]].description;
  }

   
  function addAgent(address agent, uint strandID) external onlyOwnerOrSuperuser() validStrandID(strandID) {
    addBlockRoles[strandID].add(agent);
  }

   
  function removeAgent(address agent, uint strandID) external onlyOwnerOrSuperuser() validStrandID(strandID) {
    addBlockRoles[strandID].remove(agent);
  }

   
  function addBlock(uint strandID, uint blockNumber, bytes32 blockHash) external validStrandID(strandID) {
     
    require(addBlockRoles[strandID].has(msg.sender), NO_PERMISSION);
     
    require(blocks[strandID].length == 0 || blocks[strandID][blocks[strandID].length - 1].blockNumber < blockNumber, INVALID_BLOCK);
     
    blocks[strandID].push(Block(blockNumber, blockHash));
     
    blockByNumber[strandID][blockNumber] = blocks[strandID].length - 1;
     
    emit BlockAdded(strandID, blockNumber, blockHash);
  }

   
  function getBlockHash(uint strandID, uint blockNumber) external view validStrandID(strandID) returns (bytes32) {
    Block memory theBlock = blocks[strandID][blockByNumber[strandID][blockNumber]];
     
     
    require(theBlock.blockNumber == blockNumber, INVALID_BLOCK);
    return theBlock.blockHash;
  }

   
  function getHighestBlockNumber(uint strandID) external view validStrandID(strandID) returns (uint) {
    return blocks[strandID][blocks[strandID].length - 1].blockNumber;
  }

   
   
  function getPreviousBlockNumber(uint strandID, uint blockNumber) external view validStrandID(strandID) returns (uint) {
    return blocks[strandID][blockByNumber[strandID][blockNumber] - 1].blockNumber;
  }

   
   
  function getPreviousBlock(uint strandID, uint blockNumber) external view validStrandID(strandID)
    returns (uint prevBlockNumber, bytes32 prevBlockHash) {  
    Block memory theBlock = blocks[strandID][blockByNumber[strandID][blockNumber] - 1];
    prevBlockNumber = theBlock.blockNumber;
    prevBlockHash = theBlock.blockHash;
  }
}