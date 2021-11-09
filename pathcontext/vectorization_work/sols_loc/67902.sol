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

contract ProxyManagerRole {
  using Roles for Roles.Role;
  event ProxyManagerAdded(address indexed account);
  event ProxyManagerRemoved(address indexed account);
  Roles.Role private proxyManagers;
  constructor() public {
    proxyManagers.add(msg.sender);
  }
  modifier onlyProxyManager() {
    require(isProxyManager(msg.sender));
    _;
  }
  function isProxyManager(address account) public view returns (bool) {
    return proxyManagers.has(account);
  }
  function addProxyManager(address account) public onlyProxyManager {
    proxyManagers.add(account);
    emit ProxyManagerAdded(account);
  }
  function renounceProxyManager() public {
    proxyManagers.remove(msg.sender);
  }
  function _removeProxyManager(address account) internal {
    proxyManagers.remove(account);
    emit ProxyManagerRemoved(account);
  }
}

 
contract Proxiable is ProxyManagerRole {
  mapping(address => bool) private _globalProxies;  
  mapping(address => mapping(address => bool)) private _senderProxies;  
  event ProxyAdded(address indexed proxy, uint256 updatedAtUtcSec);
  event ProxyRemoved(address indexed proxy, uint256 updatedAtUtcSec);
  event ProxyForSenderAdded(address indexed proxy, address indexed sender, uint256 updatedAtUtcSec);
  event ProxyForSenderRemoved(address indexed proxy, address indexed sender, uint256 updatedAtUtcSec);
  modifier proxyOrSender(address claimedSender) {
    require(isProxyOrSender(claimedSender));
    _;
  }
  function isProxyOrSender(address claimedSender) public view returns (bool) {
    return msg.sender == claimedSender ||
    _globalProxies[msg.sender] ||
    _senderProxies[claimedSender][msg.sender];
  }
  function isProxy(address proxy) public view returns (bool) {
    return _globalProxies[proxy];
  }
  function isProxyForSender(address proxy, address sender) public view returns (bool) {
    return _senderProxies[sender][proxy];
  }
  function addProxy(address proxy) public onlyProxyManager {
    require(!_globalProxies[proxy]);
    _globalProxies[proxy] = true;
    emit ProxyAdded(proxy, now);  
  }
  function removeProxy(address proxy) public onlyProxyManager {
    require(_globalProxies[proxy]);
    delete _globalProxies[proxy];
    emit ProxyRemoved(proxy, now);  
  }
  function addProxyForSender(address proxy, address sender) public proxyOrSender(sender) {
    require(!_senderProxies[sender][proxy]);
    _senderProxies[sender][proxy] = true;
    emit ProxyForSenderAdded(proxy, sender, now);  
  }
  function removeProxyForSender(address proxy, address sender) public proxyOrSender(sender) {
    require(_senderProxies[sender][proxy]);
    delete _senderProxies[sender][proxy];
    emit ProxyForSenderRemoved(proxy, sender, now);  
  }
}

 
 
 
 
 
 
 
 
interface IERC165 {
   
  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}

 
contract IERC721 is IERC165 {
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 indexed tokenId
  );
  event Approval(
    address indexed owner,
    address indexed approved,
    uint256 indexed tokenId
  );
  event ApprovalForAll(
    address indexed owner,
    address indexed operator,
    bool approved
  );
  function balanceOf(address owner) public view returns (uint256 balance);
  function ownerOf(uint256 tokenId) public view returns (address owner);
  function approve(address to, uint256 tokenId) public;
  function getApproved(uint256 tokenId)
    public view returns (address operator);
  function setApprovalForAll(address operator, bool _approved) public;
  function isApprovedForAll(address owner, address operator)
    public view returns (bool);
  function transferFrom(address from, address to, uint256 tokenId) public;
  function safeTransferFrom(address from, address to, uint256 tokenId)
    public;
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes data
  )
    public;
}

 
 
contract IERC721Receiver {
   
  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes data
  )
    public
    returns(bytes4);
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

 
 
library Address {
   
  function isContract(address account) internal view returns (bool) {
    uint256 size;
     
     
     
     
     
     
     
    assembly { size := extcodesize(account) }
    return size > 0;
  }
}

 
 
contract ERC165 is IERC165 {
  bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;
   
   
  mapping(bytes4 => bool) private _supportedInterfaces;
   
  constructor()
    internal
  {
    _registerInterface(_InterfaceId_ERC165);
  }
   
  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool)
  {
    return _supportedInterfaces[interfaceId];
  }
   
  function _registerInterface(bytes4 interfaceId)
    internal
  {
    require(interfaceId != 0xffffffff);
    _supportedInterfaces[interfaceId] = true;
  }
}

 
contract ERC721 is ERC165, IERC721 {
  using SafeMath for uint256;
  using Address for address;
   
   
  bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
   
  mapping (uint256 => address) private _tokenOwner;
   
  mapping (uint256 => address) private _tokenApprovals;
   
  mapping (address => uint256) private _ownedTokensCount;
   
  mapping (address => mapping (address => bool)) private _operatorApprovals;
  bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;
   
  constructor()
    public
  {
     
    _registerInterface(_InterfaceId_ERC721);
  }
   
  function balanceOf(address owner) public view returns (uint256) {
    require(owner != address(0));
    return _ownedTokensCount[owner];
  }
   
  function ownerOf(uint256 tokenId) public view returns (address) {
    address owner = _tokenOwner[tokenId];
    require(owner != address(0));
    return owner;
  }
   
  function approve(address to, uint256 tokenId) public {
    address owner = ownerOf(tokenId);
    require(to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));
    _tokenApprovals[tokenId] = to;
    emit Approval(owner, to, tokenId);
  }
   
  function getApproved(uint256 tokenId) public view returns (address) {
    require(_exists(tokenId));
    return _tokenApprovals[tokenId];
  }
   
  function setApprovalForAll(address to, bool approved) public {
    require(to != msg.sender);
    _operatorApprovals[msg.sender][to] = approved;
    emit ApprovalForAll(msg.sender, to, approved);
  }
   
  function isApprovedForAll(
    address owner,
    address operator
  )
    public
    view
    returns (bool)
  {
    return _operatorApprovals[owner][operator];
  }
   
  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  )
    public
  {
    require(_isApprovedOrOwner(msg.sender, tokenId));
    require(to != address(0));
    _clearApproval(from, tokenId);
    _removeTokenFrom(from, tokenId);
    _addTokenTo(to, tokenId);
    emit Transfer(from, to, tokenId);
  }
   
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  )
    public
  {
     
    safeTransferFrom(from, to, tokenId, "");
  }
   
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes _data
  )
    public
  {
    transferFrom(from, to, tokenId);
     
    require(_checkOnERC721Received(from, to, tokenId, _data));
  }
   
  function _exists(uint256 tokenId) internal view returns (bool) {
    address owner = _tokenOwner[tokenId];
    return owner != address(0);
  }
   
  function _isApprovedOrOwner(
    address spender,
    uint256 tokenId
  )
    internal
    view
    returns (bool)
  {
    address owner = ownerOf(tokenId);
     
     
     
    return (
      spender == owner ||
      getApproved(tokenId) == spender ||
      isApprovedForAll(owner, spender)
    );
  }
   
  function _mint(address to, uint256 tokenId) internal {
    require(to != address(0));
    _addTokenTo(to, tokenId);
    emit Transfer(address(0), to, tokenId);
  }
   
  function _burn(address owner, uint256 tokenId) internal {
    _clearApproval(owner, tokenId);
    _removeTokenFrom(owner, tokenId);
    emit Transfer(owner, address(0), tokenId);
  }
   
  function _addTokenTo(address to, uint256 tokenId) internal {
    require(_tokenOwner[tokenId] == address(0));
    _tokenOwner[tokenId] = to;
    _ownedTokensCount[to] = _ownedTokensCount[to].add(1);
  }
   
  function _removeTokenFrom(address from, uint256 tokenId) internal {
    require(ownerOf(tokenId) == from);
    _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
    _tokenOwner[tokenId] = address(0);
  }
   
  function _checkOnERC721Received(
    address from,
    address to,
    uint256 tokenId,
    bytes _data
  )
    internal
    returns (bool)
  {
    if (!to.isContract()) {
      return true;
    }
    bytes4 retval = IERC721Receiver(to).onERC721Received(
      msg.sender, from, tokenId, _data);
    return (retval == _ERC721_RECEIVED);
  }
   
  function _clearApproval(address owner, uint256 tokenId) private {
    require(ownerOf(tokenId) == owner);
    if (_tokenApprovals[tokenId] != address(0)) {
      _tokenApprovals[tokenId] = address(0);
    }
  }
}

 
 
contract IERC721Metadata is IERC721 {
  function name() external view returns (string);
  function symbol() external view returns (string);
  function tokenURI(uint256 tokenId) external view returns (string);
}

contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
   
  string private _name;
   
  string private _symbol;
   
  mapping(uint256 => string) private _tokenURIs;
  bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
   
   
  constructor(string name, string symbol) public {
    _name = name;
    _symbol = symbol;
     
    _registerInterface(InterfaceId_ERC721Metadata);
  }
   
  function name() external view returns (string) {
    return _name;
  }
   
  function symbol() external view returns (string) {
    return _symbol;
  }
   
  function tokenURI(uint256 tokenId) external view returns (string) {
    require(_exists(tokenId));
    return _tokenURIs[tokenId];
  }
   
  function _setTokenURI(uint256 tokenId, string uri) internal {
    require(_exists(tokenId));
    _tokenURIs[tokenId] = uri;
  }
   
  function _burn(address owner, uint256 tokenId) internal {
    super._burn(owner, tokenId);
     
    if (bytes(_tokenURIs[tokenId]).length != 0) {
      delete _tokenURIs[tokenId];
    }
  }
}

 
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

 
contract ERC721MetadataMintable is ERC721, ERC721Metadata, MinterRole {
   
  function mintWithTokenURI(
    address to,
    uint256 tokenId,
    string tokenURI
  )
    public
    onlyMinter
    returns (bool)
  {
    _mint(to, tokenId);
    _setTokenURI(tokenId, tokenURI);
    return true;
  }
}

 
contract ILicenseNFTDataStream {
   
   
  bytes32 public constant LICENSE_TERMS_KEY = 0xb275e7ea4f8ae6075626a6bc37c558f4265ba49512523cf4d68c05b249cf20b9;
   
  bytes32 public constant SCHEMA_KEY = 0xa91efd13169e3bceace525b23b7f968b3cc611248271e35f04c5c917311fc7f7;
   
   
  bytes32 public constant DATA_STREAM_HASH_KEY = 0xa0aa0714617b83af6568cf05c25404b309565ed9fdda7f53f4f6f60105eb0337;
   
  bytes32 public constant HASHED_DATA_STREAM_LICENSE_TERMS_KEY = 0x5fbb821d7c8660396e9025a6eae37db36accc5621c22f0bc3e7f6ce9ea20a9b8;
   
  bytes32 public constant START_TIME_UTC_SEC_KEY = 0xf3f6170cfbf7600c536f76f63bd1f6cd1df950659eea69fca42323a7b8918538;
  function mintDataStream(
    address to,
    uint256 tokenId,
    bytes32 schema,
    bytes32 licenseTerms,
    uint256 durationSec
  ) public returns(bool);
  function sealDataStream(
    address dataStreamSealer,
    uint256 tokenId,
    bytes32 dataStreamHash,
    uint256 startTimeUtcSec,
    bytes32 hashedDataStreamLicenseTerms
  ) public returns(bool);
}

contract ILicenseNFT is ERC721MetadataMintable, ILicenseNFTDataStream {
   
  bytes32 public constant SPLIT_PARENT_KEY = 0x82f1bb612577f02f2d28d75a6004227778388d11803f2c7faa961f947a84c847;
   
  bytes32 public constant DURATION_SEC_KEY = 0x3354b151081a5dc2572c75853a10ef902217550496efb2ffa54494ae9b3ab99c;
   
  bytes32 public constant BID_HASH_KEY = 0x4eba03e4695ef490bd0d99b2e8fa2d0aa4c54ddfc1a74b32febd9142981e7176;
  event Sealed(uint256 tokenId);
  function mintableProperties(uint256 tokenId, bytes32 key) public view returns(bytes32);
  function sealableProperties(uint256 tokenId, bytes32 key) public view returns(bytes32);
  function tokenSealer(uint256 tokenId) public view returns(address);
  function setMintableProperty(
    uint256 tokenId,
    bytes32 key,
    bytes32 value
  ) public returns(bool);
  function split(uint256 tokenId, uint256 secondTokenId, uint256 secondDuration) public returns(bool);
  function merge(uint256 tokenId, uint256 secondTokenId) public returns(bool);
  function setSealableProperty(
    uint256 tokenId,
    bytes32 key,
    bytes32 value
  ) public returns(bool);
  function seal(address dataStreamSealer, uint256 tokenId) public returns(bool);
  function mint(address to, uint256 tokenId) public returns (bool);
}

 
 
contract ILicenseNFTSealer {
    
  function onSealed(address licenseNFT, address tokenOwner, uint256 tokenId) public returns(bytes4);
}

contract LicenseNFTSealer is ILicenseNFTSealer {
  function onSealed(address, address, uint256) public returns(bytes4) {
    return this.onSealed.selector;
  }
}

 
 
 
contract Secondary {
  address private _primary;
  event PrimaryTransferred(
    address recipient
  );
   
  constructor() internal {
    _primary = msg.sender;
    emit PrimaryTransferred(_primary);
  }
   
  modifier onlyPrimary() {
    require(msg.sender == _primary);
    _;
  }
   
  function primary() public view returns (address) {
    return _primary;
  }
   
  function transferPrimary(address recipient) public onlyPrimary {
    require(recipient != address(0));
    _primary = recipient;
    emit PrimaryTransferred(_primary);
  }
}

 
contract IDataStreamRegistry {
  event DataStreamAdded(bytes32 indexed hash, uint256 updatedAtUtcSec);
  event DataStreamLicenseTermsAdded(
    bytes32 indexed hash,
    bytes32 indexed licenseTerms,
    uint256 updatedAtUtcSec
  );
  event DataStreamLicenseTermsChanged(
    bytes32 indexed hash,
    bytes32 indexed licenseTerms,
    uint256 updatedAtUtcSec
  );
  event DataStreamLicenseTermsRemoved(
    bytes32 indexed hash,
    bytes32 indexed licenseTerms,
    uint256 updatedAtUtcSec
  );
  event DataStreamHeartBeat(
    bytes32 indexed hash,
    int longitude1e9,
    int latitude1e9,
    uint256 updatedAtUtcSec
  );
  event DataStreamRecord(
    bytes32 indexed hash,
    uint startTimeUtcSec,
    uint endTimeUtcSec,
    uint numAtoms,
    uint256 updatedAtUtcSec
  );
  event DataStreamFuture(
    bytes32 indexed hash,
    uint startTimeUtcSec,
    uint endTimeUtcSec,
    uint estimatedNumAtoms,
    uint256 updatedAtUtcSec
  );
  function hashDataStream(
    address creator,
    string name,
    bytes32 schema
  ) public pure returns(bytes32);
  function addDataStream(address creator, string name, bytes32 schema) public;
  function addLicenseTerms(
    bytes32 hash,
    bytes32 licenseTerms,
    bool hasMinCost,
    uint256 minCostPerSec,
    bool hasMaxCost,
    uint256 maxCostPerSec
  ) public;
  function changeLicenseTerms(
    bytes32 hash,
    bytes32 licenseTerms,
    bool hasMinCost,
    uint256 minCostPerSec,
    bool hasMaxCost,
    uint256 maxCostPerSec
  ) public;
  function removeLicenseTerms(bytes32 hash, bytes32 licenseTerms) public;
  function emitHeartBeat(bytes32 hash, int longitude1e9, int latitude1e9) public;
  function emitRecord(bytes32 hash, uint startTimeUtcSec, uint endTimeUtcSec, uint numAtoms) public;
  function emitFuture(
    bytes32 hash,
    uint startTimeUtcSec,
    uint endTimeUtcSec,
    uint estimatedNumAtoms
  ) public;
  function hasDataStream(bytes32 hash) public view returns(bool);
  function creator(bytes32 hash) public view returns(address);
  function name(bytes32 hash) public view returns(string);
  function schema(bytes32 hash) public view returns(bytes32);
  function hasLicenseTerms(bytes32 hash, bytes32 licenseTerms) public view returns(bool);
  function hashLicenseTerms(bytes32 hash, bytes32 licenseTerms) public view returns(bytes32);
  function licenseTermsHasMinCost(bytes32 hash, bytes32 licenseTerms) public view returns(bool);
  function licenseTermsMinCostPerSec(bytes32 hash, bytes32 licenseTerms) public view returns(uint256);
  function licenseTermsHasMaxCost(bytes32 hash, bytes32 licenseTerms) public view returns(bool);
  function licenseTermsMaxCostPerSec(bytes32 hash, bytes32 licenseTerms) public view returns(uint256);
}

contract DataStreamRegistry is Secondary, IDataStreamRegistry {
  struct LicenseTermsProps {
    bool hasMinCost;
    uint256 minCostPerSec;
    bool hasMaxCost;
    uint256 maxCostPerSec;
  }
  struct Props {
    address creator;
    string name;
    bytes32 schema;
    mapping(bytes32 => bool) hasLicenseTerms;
    mapping(bytes32 => LicenseTermsProps) allLicenseTerms;
  }
  mapping(bytes32 => bool) private _hasDataStream;
  mapping(bytes32 => Props) private _dataStream;
  modifier onlyCreator(bytes32 hash) {
    require(creator(hash) == msg.sender);
    _;
  }
  function hashDataStream(
    address _creator,
    string _name,
    bytes32 _schema
  ) public pure returns(bytes32) {
    return keccak256(abi.encodePacked(_creator, _name, _schema));
  }
  function addDataStream(address _creator, string _name, bytes32 _schema) public {
    require(_creator == msg.sender);
    _addDataStream(_creator, _name, _schema);
  }
  function addLicenseTerms(
    bytes32 hash,
    bytes32 licenseTerms,
    bool hasMinCost,
    uint256 minCostPerSec,
    bool hasMaxCost,
    uint256 maxCostPerSec
  ) public onlyCreator(hash) {
    _addLicenseTerms(hash, licenseTerms, hasMinCost, minCostPerSec, hasMaxCost, maxCostPerSec);
  }
  function changeLicenseTerms(
    bytes32 hash,
    bytes32 licenseTerms,
    bool hasMinCost,
    uint256 minCostPerSec,
    bool hasMaxCost,
    uint256 maxCostPerSec
  ) public onlyCreator(hash) {
    _changeLicenseTerms(hash, licenseTerms, hasMinCost, minCostPerSec, hasMaxCost, maxCostPerSec);
  }
  function removeLicenseTerms(bytes32 hash, bytes32 licenseTerms) public onlyCreator(hash) {
    _removeLicenseTerms(hash, licenseTerms);
  }
  function emitHeartBeat(bytes32 hash, int longitude1e9, int latitude1e9) public onlyCreator(hash) {
    _emitHeartBeat(hash, longitude1e9, latitude1e9);
  }
  function emitRecord(
    bytes32 hash,
    uint startTimeUtcSec,
    uint endTimeUtcSec,
    uint numAtoms
  ) public onlyCreator(hash) {
    _emitRecord(hash, startTimeUtcSec, endTimeUtcSec, numAtoms);
  }
  function emitFuture(
    bytes32 hash,
    uint startTimeUtcSec,
    uint endTimeUtcSec,
    uint estimatedNumAtoms
  ) public onlyCreator(hash) {
    _emitFuture(hash, startTimeUtcSec, endTimeUtcSec, estimatedNumAtoms);
  }
  function hasDataStream(bytes32 hash) public view returns(bool) {
    return _hasDataStream[hash];
  }
  function creator(bytes32 hash) public view returns(address) {
    require(_hasDataStream[hash]);
    return _dataStream[hash].creator;
  }
  function name(bytes32 hash) public view returns(string) {
    require(_hasDataStream[hash]);
    return _dataStream[hash].name;
  }
  function schema(bytes32 hash) public view returns(bytes32) {
    require(_hasDataStream[hash]);
    return _dataStream[hash].schema;
  }
  function hasLicenseTerms(bytes32 hash, bytes32 licenseTerms) public view returns(bool) {
    require(_hasDataStream[hash]);
    return _dataStream[hash].hasLicenseTerms[licenseTerms];
  }
  function hashLicenseTerms(bytes32 hash, bytes32 licenseTerms) public view returns(bytes32) {
    require(_hasDataStream[hash]);
    return keccak256(abi.encodePacked(
      hash,
      licenseTerms,
      _dataStream[hash].hasLicenseTerms[licenseTerms],
      _dataStream[hash].allLicenseTerms[licenseTerms].hasMinCost,
      _dataStream[hash].allLicenseTerms[licenseTerms].minCostPerSec,
      _dataStream[hash].allLicenseTerms[licenseTerms].hasMaxCost,
      _dataStream[hash].allLicenseTerms[licenseTerms].maxCostPerSec
    ));
  }
  function licenseTermsHasMinCost(bytes32 hash, bytes32 licenseTerms) public view returns(bool) {
    require(_hasDataStream[hash] && _dataStream[hash].hasLicenseTerms[licenseTerms]);
    return _dataStream[hash].allLicenseTerms[licenseTerms].hasMinCost;
  }
  function licenseTermsMinCostPerSec(bytes32 hash, bytes32 licenseTerms) public view returns(uint256) {
    require(_hasDataStream[hash] && _dataStream[hash].hasLicenseTerms[licenseTerms]);
    require(_dataStream[hash].allLicenseTerms[licenseTerms].hasMinCost);
    return _dataStream[hash].allLicenseTerms[licenseTerms].minCostPerSec;
  }
  function licenseTermsHasMaxCost(bytes32 hash, bytes32 licenseTerms) public view returns(bool) {
    require(_hasDataStream[hash] && _dataStream[hash].hasLicenseTerms[licenseTerms]);
    return _dataStream[hash].allLicenseTerms[licenseTerms].hasMaxCost;
  }
  function licenseTermsMaxCostPerSec(bytes32 hash, bytes32 licenseTerms) public view returns(uint256) {
    require(_hasDataStream[hash] && _dataStream[hash].hasLicenseTerms[licenseTerms]);
    require(_dataStream[hash].allLicenseTerms[licenseTerms].hasMaxCost);
    return _dataStream[hash].allLicenseTerms[licenseTerms].maxCostPerSec;
  }
  function _addDataStream(address _creator, string _name, bytes32 _schema) internal {
    bytes32 hash = hashDataStream(_creator, _name, _schema);
    require(!_hasDataStream[hash]);
    _hasDataStream[hash] = true;
    _dataStream[hash] = Props({
      creator: _creator,
      name: _name,
      schema: _schema
    });
    emit DataStreamAdded(hash, now);  
  }
  function _addLicenseTerms(
    bytes32 hash,
    bytes32 licenseTerms,
    bool hasMinCost,
    uint256 minCostPerSec,
    bool hasMaxCost,
    uint256 maxCostPerSec
  ) internal {
    require(_hasDataStream[hash]);
    require(!_dataStream[hash].hasLicenseTerms[licenseTerms]);
    _dataStream[hash].hasLicenseTerms[licenseTerms] = true;
    _dataStream[hash].allLicenseTerms[licenseTerms] = LicenseTermsProps({
      hasMinCost: hasMinCost,
      minCostPerSec: minCostPerSec,
      hasMaxCost: hasMaxCost,
      maxCostPerSec: maxCostPerSec
    });
    emit DataStreamLicenseTermsAdded(hash, licenseTerms, now);  
  }
  function _changeLicenseTerms(
    bytes32 hash,
    bytes32 licenseTerms,
    bool hasMinCost,
    uint256 minCostPerSec,
    bool hasMaxCost,
    uint256 maxCostPerSec
  ) internal {
    require(_hasDataStream[hash]);
    require(_dataStream[hash].hasLicenseTerms[licenseTerms]);
    _dataStream[hash].allLicenseTerms[licenseTerms] = LicenseTermsProps({
      hasMinCost: hasMinCost,
      minCostPerSec: minCostPerSec,
      hasMaxCost: hasMaxCost,
      maxCostPerSec: maxCostPerSec
    });
    emit DataStreamLicenseTermsChanged(hash, licenseTerms, now);  
  }
  function _removeLicenseTerms(bytes32 hash, bytes32 licenseTerms) internal {
    require(_hasDataStream[hash]);
    require(_dataStream[hash].hasLicenseTerms[licenseTerms]);
    _dataStream[hash].hasLicenseTerms[licenseTerms] = false;
    emit DataStreamLicenseTermsRemoved(hash, licenseTerms, now);  
  }
  function _emitHeartBeat(bytes32 hash, int longitude1e9, int latitude1e9) internal {
    require(_hasDataStream[hash]);
    emit DataStreamHeartBeat(hash, longitude1e9, latitude1e9, now);  
  }
  function _emitRecord(
    bytes32 hash,
    uint startTimeUtcSec,
    uint endTimeUtcSec,
    uint numAtoms
  ) internal {
    require(_hasDataStream[hash]);
    emit DataStreamRecord(hash, startTimeUtcSec, endTimeUtcSec, numAtoms, now);  
  }
  function _emitFuture(
    bytes32 hash,
    uint startTimeUtcSec,
    uint endTimeUtcSec,
    uint estimatedNumAtoms
  ) internal {
    require(_hasDataStream[hash]);
    emit DataStreamFuture(hash, startTimeUtcSec, endTimeUtcSec, estimatedNumAtoms, now);  
  }
}

 
contract IDataStreamRegistrySealer is ILicenseNFTSealer {
  function licenseNFT() public view returns(address);
  function setLicenseNFT(address instance) public;
  function validateTokenProperties(uint256 tokenId) public view returns(bool);
}

contract DataStreamRegistrySealer is DataStreamRegistry, IDataStreamRegistrySealer, LicenseNFTSealer {
  ILicenseNFT private _licenseNFT;
  function licenseNFT() public view returns(address) {
    return _licenseNFT;
  }
  function setLicenseNFT(address instance) public onlyPrimary {
    _licenseNFT = ILicenseNFT(instance);
  }
  function validateTokenProperties(uint256 tokenId) public view returns(bool) {
    bytes32 mintedSchema = _licenseNFT.mintableProperties(tokenId, _licenseNFT.SCHEMA_KEY());
    bytes32 mintedLicenseTerms = _licenseNFT.mintableProperties(
      tokenId,
      _licenseNFT.LICENSE_TERMS_KEY()
    );
    uint256 duration = uint256(_licenseNFT.mintableProperties(tokenId, _licenseNFT.DURATION_SEC_KEY()));
    bytes32 hash = _licenseNFT.sealableProperties(tokenId, _licenseNFT.DATA_STREAM_HASH_KEY());
    uint256 startTimeUtcSec = uint256(_licenseNFT.sealableProperties(
      tokenId,
      _licenseNFT.START_TIME_UTC_SEC_KEY()
    ));
    bytes32 hashedDataStreamLicenseTerms = _licenseNFT.sealableProperties(
      tokenId,
      _licenseNFT.HASHED_DATA_STREAM_LICENSE_TERMS_KEY()
    );
     
     
    return hasDataStream(hash) &&
      mintedSchema == schema(hash) &&
      hasLicenseTerms(hash, mintedLicenseTerms) &&
      hashLicenseTerms(hash, mintedLicenseTerms) == hashedDataStreamLicenseTerms &&
      startTimeUtcSec > 0 &&
      duration > 0;
  }
  function onSealed(
    address callerLicenseNFT,
    address tokenOwner,
    uint256 tokenId
  ) public returns(bytes4) {
    require(callerLicenseNFT == address(_licenseNFT));
    require(validateTokenProperties(tokenId));
    return super.onSealed(callerLicenseNFT, tokenOwner, tokenId);
  }
}

contract DataStreamRegistrySealerProxiable is DataStreamRegistrySealer, Proxiable {
  function addDataStream(address creator, string name, bytes32 schema) public proxyOrSender(creator) {
    _addDataStream(creator, name, schema);
  }
  function addLicenseTerms(
    bytes32 hash,
    bytes32 licenseTerms,
    bool hasMinCost,
    uint256 minCostPerSec,
    bool hasMaxCost,
    uint256 maxCostPerSec
  ) public proxyOrSender(creator(hash)) {
    _addLicenseTerms(hash, licenseTerms, hasMinCost, minCostPerSec, hasMaxCost, maxCostPerSec);
  }
  function changeLicenseTerms(
    bytes32 hash,
    bytes32 licenseTerms,
    bool hasMinCost,
    uint256 minCostPerSec,
    bool hasMaxCost,
    uint256 maxCostPerSec
  ) public proxyOrSender(creator(hash)) {
    _changeLicenseTerms(hash, licenseTerms, hasMinCost, minCostPerSec, hasMaxCost, maxCostPerSec);
  }
  function removeLicenseTerms(
    bytes32 hash,
    bytes32 licenseTerms
  ) public proxyOrSender(creator(hash)) {
    _removeLicenseTerms(hash, licenseTerms);
  }
  function emitHeartBeat(
    bytes32 hash,
    int longitude1e9,
    int latitude1e9
  ) public proxyOrSender(creator(hash)) {
    _emitHeartBeat(hash, longitude1e9, latitude1e9);
  }
  function emitRecord(
    bytes32 hash,
    uint startTimeUtcSec,
    uint endTimeUtcSec,
    uint numAtoms
  ) public proxyOrSender(creator(hash)) {
    _emitRecord(hash, startTimeUtcSec, endTimeUtcSec, numAtoms);
  }
  function emitFuture(
    bytes32 hash,
    uint startTimeUtcSec,
    uint endTimeUtcSec,
    uint estimatedNumAtoms
  ) public proxyOrSender(creator(hash)) {
    _emitFuture(hash, startTimeUtcSec, endTimeUtcSec, estimatedNumAtoms);
  }
}