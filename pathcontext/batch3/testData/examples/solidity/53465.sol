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
  event ProxyAdded(address indexed proxy, uint256 updatedAt);
  event ProxyRemoved(address indexed proxy, uint256 updatedAt);
  event ProxyForSenderAdded(address indexed proxy, address indexed sender, uint256 updatedAt);
  event ProxyForSenderRemoved(address indexed proxy, address indexed sender, uint256 updatedAt);
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

 
contract ILicenseNFTProxiable {
  function split(
    address tokenOwner,
    uint256 tokenId,
    uint256 secondTokenId,
    uint256 secondDurationSec
  ) public returns(bool);
  function merge(
    address tokenOwner,
    uint256 tokenId,
    uint256 secondTokenId
  ) public returns(bool);
  function setSealableProperty(
    address tokenOwner,
    uint256 tokenId,
    bytes32 key,
    bytes32 value
  ) public returns(bool);
  function seal(
    address dataStreamSealer,
    address tokenOwner,
    uint256 tokenId
  ) public returns(bool);
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

contract ILicenseNFT is ERC721MetadataMintable {
   
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

contract LicenseNFT is ILicenseNFT {
  event Sealed(uint256 tokenId);
  string private constant NFT_NAME = "Open City License NFT";
  string private constant NFT_SYMBOL = "OCL";
   
  mapping(uint256 => mapping(bytes32 => bytes32)) private _mintableProperties;
  mapping(uint256 => mapping(bytes32 => bytes32)) private _sealableProperties;
   
  mapping(uint256 => address) private _tokenSealer;
   
  bytes4 private constant LICENSENFT_SEALED = 0x8f3de282;
  modifier onlyTokenOwner(uint256 tokenId) {
    require(ownerOf(tokenId) == msg.sender);
    _;
  }
   
  constructor() public ERC721Metadata(NFT_NAME, NFT_SYMBOL) {}
  function mintableProperties(uint256 tokenId, bytes32 key) public view returns(bytes32) {
    uint256 splitParent = uint256(_mintableProperties[tokenId][SPLIT_PARENT_KEY]);
    if (splitParent == 0 || key == SPLIT_PARENT_KEY || key == DURATION_SEC_KEY) {
      return _mintableProperties[tokenId][key];
    } else {
      return _mintableProperties[splitParent][key];
    }
  }
  function sealableProperties(uint256 tokenId, bytes32 key) public view returns(bytes32) {
    return _sealableProperties[tokenId][key];
  }
  function tokenSealer(uint256 tokenId) public view returns(address) {
    return _tokenSealer[tokenId];
  }
  function transferFrom(address, address, uint256) public {
    revert();
  }
  function setMintableProperty(
    uint256 tokenId,
    bytes32 key,
    bytes32 value
  ) public onlyMinter returns(bool) {
    require(!_exists(tokenId));
    _mintableProperties[tokenId][key] = value;
    return true;
  }
  function split(
    uint256 tokenId,
    uint256 secondTokenId,
    uint256 secondDurationSec
  ) public onlyTokenOwner(tokenId) returns(bool) {
    return _split(tokenId, secondTokenId, secondDurationSec);
  }
  function merge(
    uint256 firstTokenId,
    uint256 secondTokenId
  ) public onlyTokenOwner(firstTokenId) onlyTokenOwner(secondTokenId) returns(bool) {
    return _merge(firstTokenId, secondTokenId);
  }
  function setSealableProperty(
    uint256 tokenId,
    bytes32 key,
    bytes32 value
  ) public onlyTokenOwner(tokenId) returns(bool) {
    return _setSealableProperty(tokenId, key, value);
  }
  function seal(
    address dataStreamSealer,
    uint256 tokenId
  ) public onlyTokenOwner(tokenId) returns(bool) {
    return _seal(dataStreamSealer, msg.sender, tokenId);
  }
  function mint(address to, uint256 tokenId) public onlyMinter returns (bool) {
    _mint(to, tokenId);
    return true;
  }
  function _split(
    uint256 tokenId,
    uint256 secondTokenId,
    uint256 secondDurationSec
  ) internal returns(bool) {
    require(_exists(tokenId) && !_exists(secondTokenId));
    require(_tokenSealer[tokenId] == 0);
    require(_mintableProperties[secondTokenId][DURATION_SEC_KEY] == 0);
    require(_mintableProperties[secondTokenId][SPLIT_PARENT_KEY] == 0);
    uint256 durationSec = uint256(_mintableProperties[tokenId][DURATION_SEC_KEY]);
    require(secondDurationSec < durationSec);
    uint256 firstDurationSec = durationSec - secondDurationSec;
    _mintableProperties[tokenId][DURATION_SEC_KEY] = bytes32(firstDurationSec);
    _mintableProperties[secondTokenId][DURATION_SEC_KEY] = bytes32(secondDurationSec);
    bytes32 splitParent = _mintableProperties[tokenId][SPLIT_PARENT_KEY];
    if (splitParent == 0) {
      splitParent = bytes32(tokenId);
    }
    _mintableProperties[secondTokenId][SPLIT_PARENT_KEY] = splitParent;
    _mint(ownerOf(tokenId), secondTokenId);
    return true;
  }
  function _merge(uint256 tokenId, uint256 secondTokenId) internal returns(bool) {
    require(tokenId != secondTokenId);
    require(ownerOf(tokenId) == ownerOf(secondTokenId));
    require(_tokenSealer[tokenId] == 0 && _tokenSealer[secondTokenId] == 0);
    bytes32 firstSplitParent = _mintableProperties[tokenId][SPLIT_PARENT_KEY];
    bytes32 secondSplitParent = _mintableProperties[secondTokenId][SPLIT_PARENT_KEY];
    require(secondSplitParent != 0);
    require(bytes32(tokenId) == secondSplitParent || firstSplitParent == secondSplitParent);
    uint256 firstDurationSec = uint256(_mintableProperties[tokenId][DURATION_SEC_KEY]);
    uint256 secondDurationSec = uint256(_mintableProperties[secondTokenId][DURATION_SEC_KEY]);
    uint256 totalDuration = firstDurationSec + secondDurationSec;
    _mintableProperties[secondTokenId][DURATION_SEC_KEY] = 0x0;
    _mintableProperties[tokenId][DURATION_SEC_KEY] = bytes32(totalDuration);
    _burn(ownerOf(secondTokenId), secondTokenId);
    return true;
  }
  function _burn(address owner, uint256 tokenId) internal {
    require(_exists(tokenId));
    delete _mintableProperties[tokenId][SPLIT_PARENT_KEY];
    delete _mintableProperties[tokenId][DURATION_SEC_KEY];
    delete _tokenSealer[tokenId];
    require(ownerOf(tokenId) == owner);
    require(1 <= balanceOf(owner));
    super._burn(owner, tokenId);
  }
  function _setSealableProperty(
    uint256 tokenId,
    bytes32 key,
    bytes32 value
  ) internal returns(bool) {
    require(_tokenSealer[tokenId] == 0x0);
    _sealableProperties[tokenId][key] = value;
    return true;
  }
  function _seal(
    address dataStreamSealer,
    address tokenOwner,
    uint256 tokenId
  ) internal returns(bool) {
    require(_tokenSealer[tokenId] == 0x0);
    _tokenSealer[tokenId] = dataStreamSealer;
    require(_checkSeal(this, dataStreamSealer, tokenOwner, tokenId));
    emit Sealed(tokenId);
    return true;
  }
  function _checkSeal(
    address licenseNFT,
    address sealer,
    address tokenOwner,
    uint256 tokenId
  ) internal returns(bool) {
    bytes4 retval = ILicenseNFTSealer(sealer).onSealed(licenseNFT, tokenOwner, tokenId);
    return (retval == LICENSENFT_SEALED);
  }
}

contract LicenseNFTProxiable is ILicenseNFTProxiable, LicenseNFT, Proxiable {
  modifier onlyClaimedTokenOwner(address tokenOwner, uint256 tokenId) {
    require(ownerOf(tokenId) == tokenOwner);
    _;
  }
  function split(
    address tokenOwner,
    uint256 tokenId,
    uint256 secondTokenId,
    uint256 secondDurationSec
  ) public proxyOrSender(tokenOwner) onlyClaimedTokenOwner(tokenOwner, tokenId) returns(bool) {
    return _split(tokenId, secondTokenId, secondDurationSec);
  }
  function merge(
    address tokenOwner,
    uint256 tokenId,
    uint256 secondTokenId
  ) public
    proxyOrSender(tokenOwner)
    onlyClaimedTokenOwner(tokenOwner, tokenId)
    onlyClaimedTokenOwner(tokenOwner, secondTokenId) 
    returns(bool)
  {
    return _merge(tokenId, secondTokenId);
  }
  function setSealableProperty(
    address tokenOwner,
    uint256 tokenId,
    bytes32 key,
    bytes32 value
  ) public proxyOrSender(tokenOwner) onlyClaimedTokenOwner(tokenOwner, tokenId) returns(bool) {
    return _setSealableProperty(tokenId, key, value);
  }
  function seal(
    address dataStreamSealer,
    address tokenOwner,
    uint256 tokenId
  ) public proxyOrSender(tokenOwner) onlyClaimedTokenOwner(tokenOwner, tokenId) returns(bool) {
    return _seal(dataStreamSealer, tokenOwner, tokenId);
  }
}