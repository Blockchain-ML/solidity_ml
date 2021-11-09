pragma solidity ^0.4.23;

 
 
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

 
 
 
contract IBidRegistry {
  enum AuctionStatus {
    Undetermined,
    Lost,
    Won
  }
  enum BidState {
    Created,
    Submitted,
    Lost,
    Won,
    Refunded,
    Allocated,
    Redeemed
  }
  event BidCreated(
    bytes32 indexed hash,
    address creator,
    uint256 indexed auction,
    address indexed bidder,
    bytes32 schema,
    bytes32 licenseTerms,
    uint256 durationSec,
    uint256 bidPrice,
    uint256 updatedAtUtcSec
  );
  event BidAuctionStatusChange(bytes32 indexed hash, uint8 indexed auctionStatus, uint256 updatedAtUtcSec);
  event BidStateChange(bytes32 indexed hash, uint8 indexed bidState, uint256 updatedAtUtcSec);
  event BidClearingPriceChange(bytes32 indexed hash, uint256 clearingPrice, uint256 updatedAtUtcSec);
  function hashBid(
    address _creator,
    uint256 _auction,
    address _bidder,
    bytes32 _schema,
    bytes32 _licenseTerms,
    uint256 _durationSec,
    uint256 _bidPrice
  ) public constant returns(bytes32);
  function verifyStoredData(bytes32 hash) public view returns(bool);
  function creator(bytes32 hash) public view returns(address);
  function auction(bytes32 hash) public view returns(uint256);
  function bidder(bytes32 hash) public view returns(address);
  function schema(bytes32 hash) public view returns(bytes32);
  function licenseTerms(bytes32 hash) public view returns(bytes32);
  function durationSec(bytes32 hash) public view returns(uint256);
  function bidPrice(bytes32 hash) public view returns(uint256);
  function clearingPrice(bytes32 hash) public view returns(uint256);
  function auctionStatus(bytes32 hash) public view returns(uint8);
  function bidState(bytes32 hash) public view returns(uint8);
  function allocationFee(bytes32 hash) public view returns(uint256);
  function createBid(
    uint256 _auction,
    address _bidder,
    bytes32 _schema,
    bytes32 _licenseTerms,
    uint256 _durationSec,
    uint256 _bidPrice
  ) public;
  function setAllocationFee(bytes32 hash, uint256 fee) public;
  function setAuctionStatus(bytes32 hash, uint8 _auctionStatus) public;
  function setBidState(bytes32 hash, uint8 _bidState) public;
  function setClearingPrice(bytes32 hash, uint256 _clearingPrice) public;
}

 
contract IBlindBidRegistry is IBidRegistry {
  event BlindBidCreated(
    bytes32 indexed hash,
    address creator,
    uint256 indexed auction,
    uint256 updatedAtUtcSec
  );
  event BlindBidRevealed(
    bytes32 indexed hash,
    address creator,
    uint256 indexed auction,
    address indexed bidder,
    bytes32 schema,
    bytes32 licenseTerms,
    uint256 durationSec,
    uint256 bidPrice,
    uint256 updatedAtUtcSec
  );
  enum BlindBidState {
     
    Created,
    Submitted,
    Lost,
    Won,
    Refunded,
    Allocated,
    Redeemed,
     
    Revealed
  }
  function createBid(bytes32 hash, uint256 _auction) public;
  function revealBid(
    bytes32 hash,
    uint256 _auction,
    address _bidder,
    bytes32 _schema,
    bytes32 _licenseTerms,
    uint256 _durationSec,
    uint256 _bidPrice
  ) public;
}

 
 
 
 
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

 
contract IAuctionHouseBiddingComponent {
  event BidRegistered(address registeree, bytes32 bidHash, uint256 updatedAtUtcSec);
  function transferPrimary(address recipient) public;
  function bidRegistry() public view returns(address);
  function licenseNFT() public view returns(address);
  function bidDeposit(bytes32 bidHash) public view returns(uint256);
  function submissionOpen(uint256 auctionId) public view returns(bool);
  function revealOpen(uint256 auctionId) public view returns(bool);
  function allocationOpen(uint256 auctionId) public view returns(bool);
  function setBidRegistry(address registry) public;
  function setLicenseNFT(address licenseNFTContract) public;
  function setSubmissionOpen(uint256 auctionId) public;
  function setSubmissionClosed(uint256 auctionId) public;
  function payBid(bytes32 bidHash, uint256 value) public;
  function submitBid(address registeree, bytes32 bidHash) public;
  function setRevealOpen(uint256 auctionId) public;
  function setRevealClosed(uint256 auctionId) public;
  function revealBid(bytes32 bidHash) public;
  function setAllocationOpen(uint256 auctionId) public;
  function setAllocationClosed(uint256 auctionId) public;
  function allocateBid(bytes32 bidHash, uint clearingPrice) public;
  function doNotAllocateBid(bytes32 bidHash) public;
  function payBidAllocationFee(bytes32 bidHash, uint256 fee) public;
  function calcRefund(bytes32 bidHash) public view returns(uint256);
  function payRefund(bytes32 bidHash, uint256 refund) public;
  function issueLicenseNFT(bytes32 bidHash) public;
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

contract AuctionHouseBiddingComponent is IAuctionHouseBiddingComponent, Secondary, Proxiable {
  IBlindBidRegistry private _bidRegistry;
  ILicenseNFT private _licenseNFT;
  mapping(uint256 => bool) private _submissionOpen;
  mapping(uint256 => bool) private _revealOpen;
  mapping(uint256 => bool) private _allocationOpen;
  mapping(bytes32 => uint256) private _bidDeposit;
  constructor(address auctionHouse) public {
    transferPrimary(auctionHouse);
  }
  function bidRegistry() public view returns(address) {
    return address(_bidRegistry);
  }
  function licenseNFT() public view returns(address) {
    return address(_licenseNFT);
  }
  function bidDeposit(bytes32 bidHash) public view returns(uint256) {
    return _bidDeposit[bidHash];
  }
  function submissionOpen(uint256 auctionId) public view returns(bool) {
    return _submissionOpen[auctionId];
  }
  function revealOpen(uint256 auctionId) public view returns(bool) {
    return _revealOpen[auctionId];
  }
  function allocationOpen(uint256 auctionId) public view returns(bool) {
    return _allocationOpen[auctionId];
  }
  function setBidRegistry(address registry) public onlyPrimary {
    _bidRegistry = IBlindBidRegistry(registry);
  }
  function setLicenseNFT(address licenseNFTContract) public onlyPrimary {
    _licenseNFT = ILicenseNFT(licenseNFTContract);
  }
  function setSubmissionOpen(uint256 auctionId) public onlyPrimary {
    _submissionOpen[auctionId] = true;
  }
  function setSubmissionClosed(uint256 auctionId) public onlyPrimary {
    _submissionOpen[auctionId] = false;
  }
  function payBid(bytes32 bidHash, uint256 value) public onlyPrimary {
    uint256 auctionId = _bidRegistry.auction(bidHash);
    require(_submissionOpen[auctionId]);
    require(_bidRegistry.bidState(bidHash) == uint8(IBlindBidRegistry.BlindBidState.Created));
    _bidDeposit[bidHash] += value;
  }
  function submitBid(address registeree, bytes32 bidHash) public proxyOrSender(registeree) {
    require(_bidRegistry.bidState(bidHash) == uint8(IBlindBidRegistry.BlindBidState.Created));
    uint256 auctionId = _bidRegistry.auction(bidHash);
    require(_submissionOpen[auctionId]);
    require(_bidDeposit[bidHash] > 0);
    _bidRegistry.setBidState(bidHash, uint8(IBlindBidRegistry.BlindBidState.Submitted));
    emit BidRegistered(registeree, bidHash, now);  
  }
  function setRevealOpen(uint256 auctionId) public onlyPrimary {
    _revealOpen[auctionId] = true;
  }
  function setRevealClosed(uint256 auctionId) public onlyPrimary {
    _revealOpen[auctionId] = false;
  }
  function revealBid(bytes32 bidHash) public {
    require(_bidRegistry.bidState(bidHash) == uint8(IBlindBidRegistry.BlindBidState.Submitted));
    require(_bidRegistry.verifyStoredData(bidHash));
    uint256 auctionId = _bidRegistry.auction(bidHash);
    require(_revealOpen[auctionId]);
    uint256 bidPrice = _bidRegistry.bidPrice(bidHash);
    require(_bidDeposit[bidHash] >= bidPrice);
    _bidRegistry.setBidState(bidHash, uint8(IBlindBidRegistry.BlindBidState.Revealed));
  }
  function setAllocationOpen(uint256 auctionId) public onlyPrimary {
    _allocationOpen[auctionId] = true;
  }
  function setAllocationClosed(uint256 auctionId) public onlyPrimary {
    _allocationOpen[auctionId] = false;
  }
  function allocateBid(bytes32 bidHash, uint clearingPrice) public onlyPrimary {
    uint256 auctionId = _bidRegistry.auction(bidHash);
    require(_allocationOpen[auctionId]);
    require(_bidRegistry.bidState(bidHash) == uint8(IBlindBidRegistry.BlindBidState.Revealed));
    _bidRegistry.setClearingPrice(bidHash, clearingPrice);
    if (_bidRegistry.bidPrice(bidHash) >= clearingPrice) {
      _bidRegistry.setBidState(bidHash, uint8(IBlindBidRegistry.BlindBidState.Won));
      _bidRegistry.setAuctionStatus(bidHash, uint8(IBidRegistry.AuctionStatus.Won));
    } else {
      _bidRegistry.setBidState(bidHash, uint8(IBlindBidRegistry.BlindBidState.Lost));
      _bidRegistry.setAuctionStatus(bidHash, uint8(IBidRegistry.AuctionStatus.Lost));
    }
  }
  function doNotAllocateBid(bytes32 bidHash) public onlyPrimary {
    uint256 auctionId = _bidRegistry.auction(bidHash);
    require(_allocationOpen[auctionId]);
    require(_bidRegistry.bidState(bidHash) == uint8(IBlindBidRegistry.BlindBidState.Revealed));
    _bidRegistry.setBidState(bidHash, uint8(IBlindBidRegistry.BlindBidState.Lost));
    _bidRegistry.setAuctionStatus(bidHash, uint8(IBidRegistry.AuctionStatus.Lost));
  }
  function payBidAllocationFee(bytes32 bidHash, uint256 fee) public onlyPrimary {
    uint256 auctionId = _bidRegistry.auction(bidHash);
    require(_allocationOpen[auctionId]);
    require(_bidRegistry.allocationFee(bidHash) == 0);
    _bidRegistry.setAllocationFee(bidHash, fee);
  }
  function calcRefund(bytes32 bidHash) public view returns(uint256) {
    uint8 auctionStatus = _bidRegistry.auctionStatus(bidHash);
    uint256 deposit = _bidDeposit[bidHash];
    uint256 bidPrice = _bidRegistry.bidPrice(bidHash);
    require(deposit >= bidPrice);
    uint256 refund = 0;
    if (auctionStatus == uint8(IBidRegistry.AuctionStatus.Lost)) {
      uint256 allocationFee = _bidRegistry.allocationFee(bidHash);
      require(deposit >= allocationFee);
      refund = deposit - allocationFee;
    } else if (auctionStatus == uint8(IBidRegistry.AuctionStatus.Won)) {
      uint256 clearingPrice = _bidRegistry.clearingPrice(bidHash);
      require(deposit >= clearingPrice);
      refund = deposit - clearingPrice;
    }
    return refund;
  }
  function payRefund(bytes32 bidHash, uint256) public onlyPrimary {
    uint8 bidState = _bidRegistry.bidState(bidHash);
    require(
      bidState == uint8(IBlindBidRegistry.BlindBidState.Lost) ||
      bidState == uint8(IBlindBidRegistry.BlindBidState.Won)
    );
    _bidRegistry.setBidState(bidHash, uint8(IBlindBidRegistry.BlindBidState.Refunded));
  }
  function issueLicenseNFT(bytes32 bidHash) public onlyPrimary {
    uint8 bidState = _bidRegistry.bidState(bidHash);
    require(bidState == uint8(IBlindBidRegistry.BlindBidState.Refunded));
    if (_bidRegistry.auctionStatus(bidHash) == uint8(IBidRegistry.AuctionStatus.Won)) {
      address bidder = _bidRegistry.bidder(bidHash);
      uint256 tokenId = uint256(bidHash);
      bytes32 schema = _bidRegistry.schema(bidHash);
      bytes32 licenseTerms = _bidRegistry.licenseTerms(bidHash);
      uint256 durationSec = _bidRegistry.durationSec(bidHash);
      _licenseNFT.setMintableProperty(tokenId, _licenseNFT.BID_HASH_KEY(), bidHash);
      _licenseNFT.mintDataStream(bidder, tokenId, schema, licenseTerms, durationSec);
      _bidRegistry.setBidState(bidHash, uint8(IBlindBidRegistry.BlindBidState.Allocated));
    }
  }
}