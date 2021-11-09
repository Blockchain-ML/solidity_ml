pragma solidity ^0.4.24;

 

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
     
     
     
    if (a == 0) {
      return 0;
    }

    c = a * b;
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

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

 

 
contract IInterfaceToken {
  function exists(uint256 _tokenId) public view returns (bool);

  function hasTokens(address _owner) public view returns (bool);

  function firstToken(address _owner) public view returns (uint256 _tokenId);

  function blockhashOf(uint256 _tokenId) public view returns (bytes32 hash);
}

 
contract SimpleArtistContractV2 {

  using SafeMath for uint256;

  uint256 constant internal MAX_UINT = ~uint256(0);

  event Purchased(address indexed _funder, uint256 indexed _tokenId, uint256 _blocksPurchased, uint256 _totalValue);
  event PurchaseBlock(address indexed _funder, uint256 indexed _tokenId, bytes32 _blockhash, uint256 _block);

  modifier onlyValidAmounts() {
    require(msg.value >= 0);

     
    require(msg.value >= pricePerBlockInWei.mul(minBlockPurchaseInOneGo));

     
    require(msg.value <= pricePerBlockInWei.mul(maxBlockPurchaseInOneGo));
    _;
  }

   
  modifier onlyArtist() {
    require(msg.sender == artist, "Only callable by the artist");
    _;
  }

   
  modifier onlyWhenNotFixed() {
    require(!fixedContract, "Contract is locked");
    _;
  }

  address public artist;

  IInterfaceToken public token;

  uint256 public pricePerBlockInWei;
  uint256 public maxBlockPurchaseInOneGo;
  uint256 public minBlockPurchaseInOneGo;
  bool public onlyShowPurchased = false;

   
  address public foundationAddress = 0x2b54605eF16c4da53E32eC20b7F170389350E9F1;
  uint256 public foundationPercentage = 5;  

   
  address public optionalSplitAddress;
  uint256 public optionalSplitPercentage;

  mapping(uint256 => uint256) internal blocknumberToTokenId;
  mapping(uint256 => uint256[]) internal tokenIdToPurchasedBlocknumbers;

   
  bool public preventDoublePurchases = false;

   
  uint256 public maxInvocations = MAX_UINT;

   
  uint256[] public tokenInvocations;

   
  bytes32 public applicationChecksum;

  uint256 public lastPurchasedBlock = 0;

   
  bool public fixedContract = false;

   
  constructor(
    IInterfaceToken _token,
    uint256 _pricePerBlockInWei,
    uint256 _minBlockPurchaseInOneGo,
    uint256 _maxBlockPurchaseInOneGo,
    address _artist,
    uint256 _maxInvocations,
    bytes32 _applicationChecksum,
    bool _preventDoublePurchases,
    bool _fixedContract
  ) public {
    require(_artist != address(0));

    artist = _artist;
    token = _token;

    pricePerBlockInWei = _pricePerBlockInWei;
    minBlockPurchaseInOneGo = _minBlockPurchaseInOneGo;
    maxBlockPurchaseInOneGo = _maxBlockPurchaseInOneGo;

     
    if (_maxInvocations != 0) {
      maxInvocations = _maxInvocations;
    }

    preventDoublePurchases = _preventDoublePurchases;
    applicationChecksum = _applicationChecksum;
    fixedContract = _fixedContract;

     
    lastPurchasedBlock = block.number;
  }

   
  function() public payable {
    if (token.hasTokens(msg.sender)) {
      purchase(token.firstToken(msg.sender));
    }
    else {
      splitFunds();
    }
  }

   
  function purchase(uint256 _tokenId) public payable onlyValidAmounts {
    require(token.exists(_tokenId));

     
    if (preventDoublePurchases && tokenAlreadyUsed(_tokenId)) {
      revert("Cant buy any more blocks - token already used");
    }

     
    if (exceedsMaxInvocations()) {
      revert("Contract reach max invocations");
    }

     
    uint256 blocksToPurchased = msg.value / pricePerBlockInWei;

     
    uint256 nextBlockToPurchase = block.number + 1;

     
    if (nextBlockToPurchase < lastPurchasedBlock) {
       
      nextBlockToPurchase = lastPurchasedBlock;
    }

    uint8 purchased = 0;
    while (purchased < blocksToPurchased) {

      if (tokenIdOf(nextBlockToPurchase) == 0) {
        purchaseBlock(nextBlockToPurchase, _tokenId);
        purchased++;
      }

       
      nextBlockToPurchase = nextBlockToPurchase + 1;
    }

     
    lastPurchasedBlock = nextBlockToPurchase;

     
    splitFunds();

     
    tokenInvocations.push(_tokenId);

    emit Purchased(msg.sender, _tokenId, blocksToPurchased, msg.value);
  }

  function purchaseBlock(uint256 _blocknumber, uint256 _tokenId) internal {
     
    blocknumberToTokenId[_blocknumber] = _tokenId;

     
    tokenIdToPurchasedBlocknumbers[_tokenId].push(_blocknumber);

     
    emit PurchaseBlock(msg.sender, _tokenId, getPurchasedBlockhash(_blocknumber), _blocknumber);
  }

  function splitFunds() internal {
     
    uint foundationShare = msg.value / 100 * foundationPercentage;
    foundationAddress.transfer(foundationShare);

     
    uint256 optionalShare;
    if (optionalSplitAddress != address(0) && optionalSplitPercentage > 0) {
      optionalShare = msg.value.div(100).mul(optionalSplitPercentage);
      optionalSplitAddress.transfer(optionalShare);
    }

     
    uint artistTotal = msg.value - foundationShare - optionalShare;
    artist.transfer(artistTotal);
  }

   
  function tokenAlreadyUsed(uint256 _tokenId) public view returns (bool) {
    return tokenIdToPurchasedBlocknumbers[_tokenId].length > 0;
  }

   
  function exceedsMaxInvocations() public view returns (bool) {
    return tokenInvocations.length >= maxInvocations;
  }

   
  function totalInvocations() public view returns (uint256) {
    return tokenInvocations.length;
  }

   
  function getTokenInvocations() public view returns (uint256[] _tokenIds) {
    return tokenInvocations;
  }

   
  function remainingInvocations() public view returns (uint256) {
    return maxInvocations - tokenInvocations.length;
  }

   
  function nextPurchasableBlocknumber() public view returns (uint256 _nextFundedBlock) {
    if (block.number < lastPurchasedBlock) {
      return lastPurchasedBlock;
    }
    return block.number + 1;
  }

   
  function blocknumbersOf(uint256 _tokenId) public view returns (uint256[] _blocks) {
    return tokenIdToPurchasedBlocknumbers[_tokenId];
  }

   
  function tokenIdOf(uint256 _blockNumber) public view returns (uint256 _tokenId) {
    return blocknumberToTokenId[_blockNumber];
  }

   
  function getPurchasedBlockhash(uint256 _blocknumber) public view returns (bytes32 _tokenHash) {
     
    require(tokenIdOf(_blocknumber) != 0);

    uint256 tokenId = tokenIdOf(_blocknumber);
    return token.blockhashOf(tokenId);
  }

   
  function nativeBlockhash(uint256 _blocknumber) public view returns (bytes32 _tokenHash) {
    return blockhash(_blocknumber);
  }

   
  function nextHash() public view returns (bytes32 _tokenHash, uint256 _nextBlocknumber) {
    uint256 nextBlocknumber = block.number - 1;

     
    if (tokenIdOf(nextBlocknumber) != 0) {
      return (getPurchasedBlockhash(nextBlocknumber), nextBlocknumber);
    }

    if (onlyShowPurchased) {
      return (0x0, nextBlocknumber);
    }

     
    return (nativeBlockhash(nextBlocknumber), nextBlocknumber);
  }

   
  function blocknumber() public view returns (uint256 _blockNumber) {
    return block.number;
  }

   
  function togglePreventDoublePurchases() external onlyArtist onlyWhenNotFixed {
    preventDoublePurchases = !preventDoublePurchases;
  }

   
  function setMaxInvocations(uint256 _maxInvocations) external onlyArtist onlyWhenNotFixed {
    require(_maxInvocations > 0, "Cannot set max invocations to less then 1");
    maxInvocations = _maxInvocations;
  }

   
  function setApplicationChecksum(bytes32 _applicationChecksum) external onlyArtist onlyWhenNotFixed {
    applicationChecksum = _applicationChecksum;
  }

   
  function setOptionalFeeSplit(address _optionalSplitAddress, uint256 _optionalSplitPercentage) external onlyArtist {
    require(_optionalSplitAddress != address(0), "Cannot set blank address");
    require(_optionalSplitPercentage > 0, "Cannot set a zero fee split");
    require(_optionalSplitPercentage.add(foundationPercentage) <= 100, "Optional split plus founders fee cannot be more than 100%");

    optionalSplitAddress = _optionalSplitAddress;
    optionalSplitPercentage = _optionalSplitPercentage;
  }

   
  function setPricePerBlockInWei(uint256 _priceInWei) external onlyArtist {
    pricePerBlockInWei = _priceInWei;
  }

   
  function setMaxBlockPurchaseInOneGo(uint256 _maxBlockPurchaseInOneGo) external onlyArtist {
    maxBlockPurchaseInOneGo = _maxBlockPurchaseInOneGo;
  }

   
  function setMinBlockPurchaseInOneGo(uint256 _minBlockPurchaseInOneGo) external onlyArtist {
    minBlockPurchaseInOneGo = _minBlockPurchaseInOneGo;
  }

   
  function setOnlyShowPurchased(bool _onlyShowPurchased) external onlyArtist {
    onlyShowPurchased = _onlyShowPurchased;
  }
}