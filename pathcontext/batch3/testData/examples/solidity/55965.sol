pragma solidity ^0.4.24;


contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) public view returns (uint);
  
  function name() public view returns (string _name);
  function symbol() public view returns (string _symbol);
  function decimals() public view returns (uint8 _decimals);
  function totalSupply() public view returns (uint256 _supply);

  function transfer(address to, uint value) public returns (bool ok);
  function transfer(address to, uint value, bytes data) public returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) public returns (bool ok);
  
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}


contract ContractReceiver {
  function tokenFallback(address _from, uint256 _value, bytes _data) public;
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

library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

   
  function add(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = true;
  }

   
  function remove(Role storage role, address account) internal {
    require(account != address(0));
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

library Address {

   
  function isContract(address account) internal view returns (bool) {
    uint256 size;
     
     
     
     
     
     
     
    assembly { size := extcodesize(account) }
    return size > 0;
  }

}

interface IERC165 {

   
  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}

contract MinterRole {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private minters;

  constructor() public {
    minters.add(msg.sender);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender));
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyMinter {
    minters.add(account);
    emit MinterAdded(account);
  }

  function renounceMinter() public {
    minters.remove(msg.sender);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}

contract ERC165 is IERC165 {

  bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;
   

   
  mapping(bytes4 => bool) internal _supportedInterfaces;

   
  constructor()
    public
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

contract IERC721Metadata is IERC721 {
  function name() external view returns (string);
  function symbol() external view returns (string);
  function tokenURI(uint256 tokenId) public view returns (string);
}

contract IERC721Enumerable is IERC721 {
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(
    address owner,
    uint256 index
  )
    public
    view
    returns (uint256 tokenId);

  function tokenByIndex(uint256 index) public view returns (uint256);
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
     
    require(_checkAndCallSafeTransfer(from, to, tokenId, _data));
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

   
  function _clearApproval(address owner, uint256 tokenId) internal {
    require(ownerOf(tokenId) == owner);
    if (_tokenApprovals[tokenId] != address(0)) {
      _tokenApprovals[tokenId] = address(0);
    }
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

   
  function _checkAndCallSafeTransfer(
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
}

contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
   
  string internal _name;

   
  string internal _symbol;

   
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

   
  function tokenURI(uint256 tokenId) public view returns (string) {
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

contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {
   
  mapping(address => uint256[]) private _ownedTokens;

   
  mapping(uint256 => uint256) private _ownedTokensIndex;

   
  uint256[] private _allTokens;

   
  mapping(uint256 => uint256) private _allTokensIndex;

  bytes4 private constant _InterfaceId_ERC721Enumerable = 0x780e9d63;
   

   
  constructor() public {
     
    _registerInterface(_InterfaceId_ERC721Enumerable);
  }

   
  function tokenOfOwnerByIndex(
    address owner,
    uint256 index
  )
    public
    view
    returns (uint256)
  {
    require(index < balanceOf(owner));
    return _ownedTokens[owner][index];
  }

   
  function totalSupply() public view returns (uint256) {
    return _allTokens.length;
  }

   
  function tokenByIndex(uint256 index) public view returns (uint256) {
    require(index < totalSupply());
    return _allTokens[index];
  }

   
  function _addTokenTo(address to, uint256 tokenId) internal {
    super._addTokenTo(to, tokenId);
    uint256 length = _ownedTokens[to].length;
    _ownedTokens[to].push(tokenId);
    _ownedTokensIndex[tokenId] = length;
  }

   
  function _removeTokenFrom(address from, uint256 tokenId) internal {
    super._removeTokenFrom(from, tokenId);

     
     
    uint256 tokenIndex = _ownedTokensIndex[tokenId];
    uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
    uint256 lastToken = _ownedTokens[from][lastTokenIndex];

    _ownedTokens[from][tokenIndex] = lastToken;
     
    _ownedTokens[from].length--;

     
     
     

    _ownedTokensIndex[tokenId] = 0;
    _ownedTokensIndex[lastToken] = tokenIndex;
  }

   
  function _mint(address to, uint256 tokenId) internal {
    super._mint(to, tokenId);

    _allTokensIndex[tokenId] = _allTokens.length;
    _allTokens.push(tokenId);
  }

   
  function _burn(address owner, uint256 tokenId) internal {
    super._burn(owner, tokenId);

     
    uint256 tokenIndex = _allTokensIndex[tokenId];
    uint256 lastTokenIndex = _allTokens.length.sub(1);
    uint256 lastToken = _allTokens[lastTokenIndex];

    _allTokens[tokenIndex] = lastToken;
    _allTokens[lastTokenIndex] = 0;

    _allTokens.length--;
    _allTokensIndex[tokenId] = 0;
    _allTokensIndex[lastToken] = tokenIndex;
  }
}

contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {
  constructor(string name, string symbol) ERC721Metadata(name, symbol)
    public
  {
  }
}

contract ERC721Mintable is ERC721Full, MinterRole {
  event MintingFinished();

  bool private _mintingFinished = false;

  modifier onlyBeforeMintingFinished() {
    require(!_mintingFinished);
    _;
  }

   
  function mintingFinished() public view returns(bool) {
    return _mintingFinished;
  }

   
  function mint(
    address to,
    uint256 tokenId
  )
    public
    onlyMinter
    onlyBeforeMintingFinished
    returns (bool)
  {
    _mint(to, tokenId);
    return true;
  }

  function mintWithTokenURI(
    address to,
    uint256 tokenId,
    string tokenURI
  )
    public
    onlyMinter
    onlyBeforeMintingFinished
    returns (bool)
  {
    mint(to, tokenId);
    _setTokenURI(tokenId, tokenURI);
    return true;
  }

   
  function finishMinting()
    public
    onlyMinter
    onlyBeforeMintingFinished
    returns (bool)
  {
    _mintingFinished = true;
    emit MintingFinished();
    return true;
  }
}

contract Secondary {
  address private _primary;

   
  constructor() public {
    _primary = msg.sender;
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
    address schema,
    address license,
    uint256 durationSec,
    uint256 bidPrice,
    uint256 updatedAt
  );

  event BidAuctionStatusChange(bytes32 indexed hash, uint8 indexed auctionStatus, uint256 updatedAt);
  event BidStateChange(bytes32 indexed hash, uint8 indexed bidState, uint256 updatedAt);
  event BidClearingPriceChange(bytes32 indexed hash, uint256 clearingPrice, uint256 updatedAt);

  function hashBid(
    address _creator,
    uint256 _auction,
    address _bidder,
    address _schema,
    address _license,
    uint256 _durationSec,
    uint256 _bidPrice
  ) public constant returns(bytes32);

  function verifyStoredData(bytes32 hash) public view returns(bool);

  function creator(bytes32 hash) public view returns(address);
  function auction(bytes32 hash) public view returns(uint256);
  function bidder(bytes32 hash) public view returns(address);
  function schema(bytes32 hash) public view returns(address);
  function license(bytes32 hash) public view returns(address);
  function durationSec(bytes32 hash) public view returns(uint256);
  function bidPrice(bytes32 hash) public view returns(uint256);

  function clearingPrice(bytes32 hash) public view returns(uint256);
  function auctionStatus(bytes32 hash) public view returns(uint8);
  function bidState(bytes32 hash) public view returns(uint8);
  function allocationFee(bytes32 hash) public view returns(uint256);

  function createBid(
    uint256 _auction,
    address _bidder,
    address _schema,
    address _license,
    uint256 _durationSec,
    uint256 _bidPrice
  ) public;

  function setAllocationFee(bytes32 hash, uint256 fee) public;
  function setAuctionStatus(bytes32 hash, uint8 _auctionStatus) public;
  function setBidState(bytes32 hash, uint8 _bidState) public;
  function setClearingPrice(bytes32 hash, uint256 _clearingPrice) public;
}

contract IAuctionHouseClearingPriceComponent {
  event ClearingPriceSubmitted(
    address indexed submitter,
    uint256 indexed auctionId,
    bytes32 bidHash,
    uint256 clearingPrice
  );

  event ClearingPriceRejected(
    address indexed rejector,
    address indexed submitter,
    uint256 indexed auctionId,
    bytes32 bidHash,
    uint256 correctedClearingPrice
  );

  event ClearingPriceSubmitterRejected(
    address indexed rejector,
    address indexed submitter,
    uint256 indexed auctionId,
    bytes32 bidHash,
    uint256 correctedClearingPrice
  );

  function bidRegistry() public view returns(address);
  function clearingPriceCode() public view returns(bytes);
  function submissionDeposit() public view returns(uint256);
  function percentAllocationFeeNumerator() public returns(uint256);
  function percentAllocationFeeDenominator() public returns(uint256);

  function setBidRegistry(address registry) public;
  function setClearingPriceCode(bytes reference) public;
  function setSubmissionDeposit(uint256 deposit) public;
  function setPercentAllocationFee(uint256 numerator, uint256 denominator) public;

  function setSubmissionOpen(uint256 auctionId) public;
  function setSubmissionClosed(uint256 auctionId) public;

  function payDeposit(uint256 auctionId, address submitter, uint256 value) public;
  function submitClearingPrice(address submitter, bytes32 bidHash, uint256 clearingPrice) public;

  function setValidationOpen(uint256 auctionId) public;
  function setValidationClosed(uint256 auctionId) public;

  function rejectClearingPriceSubmission(
    address validator,
    address submitter,
    bytes32 bidHash,
    uint256 correctedClearingPrice
  ) public;

  function isSubmitterAccepted(uint256 auctionId, address submitter) public view returns(bool);
  function isValidSubmitter(address submitter, bytes32 bidHash) public view returns(bool);
  function hasClearingPrice(address anyValidSubmitter, bytes32 bidHash) public view returns(bool);
  function clearingPrice(address anyValidSubmitter, bytes32 bidHash) public view returns(uint256);

  function paidBidAllocationFee(bytes32 bidHash) public view returns(bool);
  function calcBidAllocationFee(bytes32 bidHash) public view returns(uint256);
  function payBidAllocationFee(bytes32 bidHash, uint256 fee) public;

  function setRewardOpen(uint256 auctionId) public;
  function setRewardClosed(uint256 auctionId) public;

  function rewarded(uint256 auctionId, address clearingPriceSubmitter) public view returns(bool);
  function calcReward(uint256 auctionId, address clearingPriceSubmitter) public view returns(uint256);
  function payReward(uint256 auctionId, address clearingPriceSubmitter, uint256 reward) public;
}

contract ClearingPriceValidatorRole {
  using Roles for Roles.Role;

  event ClearingPriceValidatorAdded(address indexed account);
  event ClearingPriceValidatorRemoved(address indexed account);

  Roles.Role private proxyManagers;

  constructor() public {
    proxyManagers.add(msg.sender);
  }

  modifier onlyClearingPriceValidator() {
    require(isClearingPriceValidator(msg.sender));
    _;
  }

  function isClearingPriceValidator(address account) public view returns (bool) {
    return proxyManagers.has(account);
  }

  function addClearingPriceValidator(address account) public onlyClearingPriceValidator {
    proxyManagers.add(account);
    emit ClearingPriceValidatorAdded(account);
  }

  function renounceClearingPriceValidator() public {
    proxyManagers.remove(msg.sender);
  }

  function _removeClearingPriceValidator(address account) internal {
    proxyManagers.remove(account);
    emit ClearingPriceValidatorRemoved(account);
  }
}

contract IBlindBidRegistry is IBidRegistry {
  event BlindBidCreated(
    bytes32 indexed hash,
    address creator,
    uint256 indexed auction,
    uint256 updatedAt
  );

  event BlindBidRevealed(
    bytes32 indexed hash,
    address creator,
    uint256 indexed auction,
    address indexed bidder,
    address schema,
    address license,
    uint256 durationSec,
    uint256 bidPrice,
    uint256 updatedAt
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
    address _schema,
    address _license,
    uint256 _durationSec,
    uint256 _bidPrice
  ) public;
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

contract AuctionHouseClearingPriceComponent is Secondary, IAuctionHouseClearingPriceComponent, Proxiable, ClearingPriceValidatorRole {
  struct CostParams {
    uint256 submissionDeposit;
    uint256 percentAllocationFeeNumerator;
    uint256 percentAllocationFeeDenominator;
  }

  struct State {
    bool submissionOpen;
    bool validationOpen;
    bool finalized;
    bool rewardOpen;
  }

  struct Submitter {
    bool accepted;
    bool rewarded;

    uint depositCollected;

     
    mapping(bytes32 => uint256) clearingPrices;
    mapping(bytes32 => bool) hasClearingPrices;
  }

  IBlindBidRegistry private _bidRegistry;
  bytes private _clearingPriceCode;
  CostParams private _costParams;

  mapping(uint256 => State) private _state;

   
  mapping(bytes32 => bool) private _paidFees;

   
  mapping(uint256 => uint256) private _feeAllocationPool;
  mapping(uint256 => uint256) private _feeAllocationPoolRemainder;

   
  mapping(uint256 => mapping(address => mapping(address => mapping(bytes32 => uint256)))) private _rejectPrices;

   
  mapping(uint256 => mapping(address => Submitter)) private _submitter;

   
  mapping(uint256 => uint32) private _numAcceptedSubmitters;

  constructor(address auctionHouse) public {
    transferPrimary(auctionHouse);
  }

  function bidRegistry() public view returns(address) {
    return address(_bidRegistry);
  }

  function clearingPriceCode() public view returns(bytes) {
    return _clearingPriceCode;
  }

  function submissionDeposit() public view returns(uint256) {
    return _costParams.submissionDeposit;
  }

  function percentAllocationFeeNumerator() public returns(uint256) {
    return _costParams.percentAllocationFeeNumerator;
  }

  function percentAllocationFeeDenominator() public returns(uint256) {
    return _costParams.percentAllocationFeeDenominator;
  }

  function setBidRegistry(address registry) public onlyPrimary {
    _bidRegistry = IBlindBidRegistry(registry);
  }

  function setClearingPriceCode(bytes reference) public onlyPrimary {
    _clearingPriceCode = reference;
  }

  function setSubmissionDeposit(uint256 deposit) public onlyPrimary {
    _costParams.submissionDeposit = deposit;
  }

  function setPercentAllocationFee(uint256 numerator, uint256 denominator) public onlyPrimary {
    _costParams.percentAllocationFeeNumerator = numerator;
    _costParams.percentAllocationFeeDenominator = denominator;
  }

  function setSubmissionOpen(uint256 auctionId) public onlyPrimary {
    _state[auctionId].submissionOpen = true;
    _state[auctionId].finalized = false;
  }

  function setSubmissionClosed(uint256 auctionId) public onlyPrimary {
    _state[auctionId].submissionOpen = false;
    _state[auctionId].finalized = false;
  }

  function payDeposit(uint256 auctionId, address submitter, uint256 value) public onlyPrimary {
    require(_submitter[auctionId][submitter].depositCollected == 0);
    require(value == _costParams.submissionDeposit);
    require(_state[auctionId].submissionOpen);
    _feeAllocationPool[auctionId] += value;
    _submitter[auctionId][submitter].depositCollected += value;
    _numAcceptedSubmitters[auctionId] += 1;
    _submitter[auctionId][submitter].accepted = true;
  }

  function submitClearingPrice(address submitter, bytes32 bidHash, uint256 clearingPrice) public proxyOrSender(submitter) {
    uint256 auctionId = _bidRegistry.auction(bidHash);
    require(_state[auctionId].submissionOpen);
    require(_submitter[auctionId][submitter].depositCollected >= _costParams.submissionDeposit);
    _submitter[auctionId][submitter].clearingPrices[bidHash] = clearingPrice;
    _submitter[auctionId][submitter].hasClearingPrices[bidHash] = true;
    emit ClearingPriceSubmitted(submitter, auctionId, bidHash, clearingPrice);
  }

  function setValidationOpen(uint256 auctionId) public onlyPrimary {
    _state[auctionId].validationOpen = true;
    _state[auctionId].finalized = false;
  }

  function setValidationClosed(uint256 auctionId) public onlyPrimary {
    _state[auctionId].validationOpen = false;
    _state[auctionId].finalized = true;
  }

  function rejectClearingPriceSubmission(
    address validator,
    address submitter,
    bytes32 bidHash,
    uint256 correctedClearingPrice
  ) public proxyOrSender(validator) {
    uint256 auctionId = _bidRegistry.auction(bidHash);
    require(_state[auctionId].validationOpen);

    uint256 submittedClearingPrice = _submitter[auctionId][submitter].clearingPrices[bidHash];
    require(correctedClearingPrice != submittedClearingPrice);

    _rejectPrices[auctionId][validator][submitter][bidHash] = correctedClearingPrice;
    emit ClearingPriceRejected(validator, submitter, auctionId, bidHash, correctedClearingPrice);

    if (isClearingPriceValidator(validator)) {
      if (_submitter[auctionId][submitter].accepted) {
        _numAcceptedSubmitters[auctionId] -= 1;
        _submitter[auctionId][submitter].accepted = false;
      }
      emit ClearingPriceSubmitterRejected(validator, submitter, auctionId, bidHash, correctedClearingPrice);
    }
  }

  function isSubmitterAccepted(uint256 auctionId, address submitter) public view returns(bool) {
    return _submitter[auctionId][submitter].accepted;
  }

  function isValidSubmitter(address submitter, bytes32 bidHash) public view returns(bool) {
    uint256 auctionId = _bidRegistry.auction(bidHash);
    return _state[auctionId].finalized && _submitter[auctionId][submitter].accepted;
  }

  function hasClearingPrice(address anyValidSubmitter, bytes32 bidHash) public view returns(bool) {
    address submitter = anyValidSubmitter;
    uint256 auctionId = _bidRegistry.auction(bidHash);
    return
      _state[auctionId].finalized &&
      _submitter[auctionId][submitter].accepted &&
      _submitter[auctionId][submitter].hasClearingPrices[bidHash];
  }

  function clearingPrice(address anyValidSubmitter, bytes32 bidHash) public view returns(uint256) {
    address submitter = anyValidSubmitter;
    uint256 auctionId = _bidRegistry.auction(bidHash);
    require(hasClearingPrice(submitter, bidHash));
    return _submitter[auctionId][submitter].clearingPrices[bidHash];
  }

  function paidBidAllocationFee(bytes32 bidHash) public view returns(bool) {
    return _paidFees[bidHash];
  }

  function calcBidAllocationFee(bytes32 bidHash) public view returns(uint256) {
    if (_bidRegistry.auctionStatus(bidHash) == uint8(IBidRegistry.AuctionStatus.Won)) {
      uint256 bidClearingPrice = _bidRegistry.clearingPrice(bidHash);
      return (_costParams.percentAllocationFeeNumerator * bidClearingPrice) / _costParams.percentAllocationFeeDenominator;
    } else {
      return 0;
    }
  }

  function payBidAllocationFee(bytes32 bidHash, uint256 fee) public onlyPrimary {
    require(!_paidFees[bidHash]);
    uint256 auctionId = _bidRegistry.auction(bidHash);
    _feeAllocationPool[auctionId] += fee;
    _paidFees[bidHash] = true;
  }

  function setRewardOpen(uint256 auctionId) public onlyPrimary {
    _state[auctionId].rewardOpen = true;

    if (_numAcceptedSubmitters[auctionId] > 0) {
      uint256 avgReward = _feeAllocationPool[auctionId] / _numAcceptedSubmitters[auctionId];
      uint256 totalReward = avgReward * _numAcceptedSubmitters[auctionId];
      _feeAllocationPoolRemainder[auctionId] = _feeAllocationPool[auctionId] - totalReward;
    }
  }

  function setRewardClosed(uint256 auctionId) public onlyPrimary {
    _state[auctionId].rewardOpen = false;
  }

  function rewarded(uint256 auctionId, address clearingPriceSubmitter) public view returns(bool) {
    return _submitter[auctionId][clearingPriceSubmitter].rewarded;
  }

  function calcReward(uint256 auctionId, address clearingPriceSubmitter) public view returns(uint256) {
    uint reward = 0;
    if (_submitter[auctionId][clearingPriceSubmitter].accepted) {
      reward = _feeAllocationPool[auctionId] / _numAcceptedSubmitters[auctionId];
      if (_feeAllocationPoolRemainder[auctionId] > 0) {
        reward += 1;
      }
    }
    return reward;
  }

  function payReward(uint256 auctionId, address clearingPriceSubmitter, uint256 reward) public onlyPrimary {
    require(reward == calcReward(auctionId, clearingPriceSubmitter));
    require(_state[auctionId].rewardOpen);
    require(!_submitter[auctionId][clearingPriceSubmitter].rewarded);

    _submitter[auctionId][clearingPriceSubmitter].rewarded = true;

    if (_feeAllocationPoolRemainder[auctionId] > 0) {
      _feeAllocationPoolRemainder[auctionId] -= 1;
    }
  }
}