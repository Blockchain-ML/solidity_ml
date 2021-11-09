pragma solidity 0.4.24;

 

 
contract Token {
   
   
  uint public totalSupply;

   
   
  function balanceOf(address _owner) public view returns (uint balance);

   
   
   
   
  function transfer(address _to, uint _value) public returns (bool success);

   
   
   
   
   
  function transferFrom(address _from, address _to, uint _value) public returns (bool success);

   
   
   
   
  function approve(address _spender, uint _value) public returns (bool success);

   
   
   
  function allowance(address _owner, address _spender) public view returns (uint remaining);

  event Transfer(address indexed _from, address indexed _to, uint _value);
  event Approval(address indexed _owner, address indexed _spender, uint _value);
}

 

interface Registry {

  function contains(address apiKey) view external returns (bool);

  function register(address apiKey) external;
  function registerWithUserAgreement(address apiKey, bytes32 userAgreement) external;
  event Registered(address apiKey, address indexed account);

  function translate(address apiKey) view external returns (address);
}

 

contract MerkleProof {

   
  function checkProof(bytes proof, bytes32 root, bytes32 leaf) public pure returns (bool) {
    if (proof.length % 32 != 0) return false;  

    bytes memory elements = proof;
    bytes32 element;
    bytes32 hash = leaf;
    for (uint i = 32; i <= proof.length; i += 32) {
      assembly {
       
        element := mload(add(elements, i))
      }
      hash = keccak256(hash < element ? abi.encodePacked(hash, element) : abi.encodePacked(element, hash));
    }
    return hash == root;
  }

   
  function checkProofOrdered(bytes proof, bytes32 root, bytes32 leaf, uint index) public pure returns (bool) {
    if (proof.length % 32 != 0) return false;  

     
    bytes32 element;
    bytes32 hash = leaf;
    uint remaining;
    for (uint j = 32; j <= proof.length; j += 32) {
      assembly {
        element := mload(add(proof, j))
      }

       
      remaining = (proof.length - j + 32) / 32;

       
       
       
      while (remaining > 0 && index % 2 == 1 && index > 2 ** remaining) {
        index = uint(index) / 2 + 1;
      }

      if (index % 2 == 0) {
        hash = keccak256(abi.encodePacked(element, hash));
        index = index / 2;
      } else {
        hash = keccak256(abi.encodePacked(hash, element));
        index = uint(index) / 2 + 1;
      }
    }
    return hash == root;
  }
}

 

 
contract Stoppable {

   
  modifier onlyOwner { _; }
   

  bool public isOn = true;

  modifier whenOn() { require(isOn, "must be on"); _; }
  modifier whenOff() { require(!isOn, "must be off"); _; }

  function switchOff() onlyOwner external {
    if (isOn) {
      isOn = false;
      emit Off();
    }
  }
  event Off();
}

 

contract Validating {

  modifier notZero(uint number) { require(number != 0, "invalid 0 value"); _; }
  modifier notEmpty(string text) { require(bytes(text).length != 0, "invalid empty string"); _; }
  modifier validAddress(address value) { require(value != address(0x0), "invalid address");  _; }

}

 

contract HasOwners is Validating {

  mapping(address => bool) public isOwner;
  address[] private owners;

  constructor(address[] _owners) public {
    for (uint i = 0; i < _owners.length; i++) _addOwner_(_owners[i]);
    owners = _owners;
  }

  modifier onlyOwner { require(isOwner[msg.sender], "invalid sender; must be owner"); _; }

  function getOwners() public view returns (address[]) { return owners; }

  function addOwner(address owner) external onlyOwner {  _addOwner_(owner); }

  function _addOwner_(address owner) validAddress(owner) private {
    if (!isOwner[owner]) {
      isOwner[owner] = true;
      owners.push(owner);
      emit OwnerAdded(owner);
    }
  }
  event OwnerAdded(address indexed owner);

  function removeOwner(address owner) external onlyOwner {
    if (isOwner[owner]) {
      require(owners.length > 1, "removing the last owner is not allowed");
      isOwner[owner] = false;
      for (uint i = 0; i < owners.length - 1; i++) {
        if (owners[i] == owner) {
          owners[i] = owners[owners.length - 1];  
          delete owners[owners.length - 1];
          break;
        }
      }
      owners.length -= 1;
      emit OwnerRemoved(owner);
    }
  }
  event OwnerRemoved(address indexed owner);
}

 

contract Ledger {

  function extractEntry(address[] addresses, uint[] uints) internal view returns (Entry result) {
    addresses[0]   = address(this);
    result.account = addresses[1];
    result.asset = addresses[2];
    result.entryType = EntryType(uints[0]);
    result.action = uints[1];
    result.timestamp = uints[2];
    result.id = uints[3];
    result.quantity = uints[4];
    result.balance = uints[5];
    result.previous = uints[6];
    result.addresses = addresses;
    result.uints = uints;
    result.hash = calculateEvmConstrainedHash(result.entryType, addresses, uints);
  }

   
  function calculateEvmConstrainedHash(EntryType entryType, address[] addresses, uint[] uints) internal view returns (bytes32) {
    bytes32 entryHash = calculateEntryHash(addresses, uints);
    bytes32 witnessHash = calculateWitnessHash(entryType, addresses, uints);
    return keccak256(abi.encodePacked(entryHash, witnessHash));
  }
  function calculateEntryHash(address[] addresses, uint[] uints) private pure returns (bytes32) {
    return keccak256(abi.encodePacked(
        addresses[0],
        addresses[1],
        addresses[2],
        uints[0],
        uints[1],
        uints[2],
        uints[3],
        uints[4],
        uints[5],
        uints[6]
      ));
  }
  function calculateWitnessHash(EntryType entryType, address[] addresses, uint[] uints) private view returns (bytes32) {
    if (entryType == EntryType.Deposit) return calculateDepositInfoWitnessHash(uints);
    if (entryType == EntryType.Withdrawal) return calculateWithdrawalRequestWitnessHash(addresses, uints);
    if (entryType == EntryType.Trade || entryType == EntryType.Fee) return calculateMatchWitnessHash(addresses, uints);
    return keccak256(abi.encodePacked(uint(0)));
  }
  function calculateDepositInfoWitnessHash(uint[] uints) private view returns (bytes32) {
    return keccak256(abi.encodePacked(
        uints[offsets.uints.witness + 0],
        uints[offsets.uints.witness + 1]
      ));
  }
  function calculateWithdrawalRequestWitnessHash(address[] addresses, uint[] uints) private view returns (bytes32) {
    return keccak256(abi.encodePacked(
        addresses[offsets.addresses.witness + 0],
        addresses[offsets.addresses.witness + 1],
        uints[offsets.uints.witness + 0],
        uints[offsets.uints.witness + 1]
      ));
  }
  function calculateMatchWitnessHash(address[] addresses, uint[] uints) private view returns (bytes32) {
    return keccak256(abi.encodePacked(
        calculateFillHash(addresses, uints, offsets.addresses.witness, offsets.uints.witness),     
        calculateOrderHash(addresses, uints, offsets.addresses.maker, offsets.uints.maker),  
        calculateOrderHash(addresses, uints, offsets.addresses.taker, offsets.uints.taker)   
      ));
  }
  function calculateFillHash(address[] addresses, uint[] uints, uint8 addressesOffset, uint8 uintsOffset) private pure returns (bytes32) {
    return keccak256(abi.encodePacked(
        addresses[addressesOffset + 0],
        uints[uintsOffset + 0],
        uints[uintsOffset + 1],
        uints[uintsOffset + 2]
      ));
  }
  function calculateOrderHash(address[] addresses, uint[] uints, uint8 addressesOffset, uint8 uintsOffset) private pure returns (bytes32) {
    return keccak256(abi.encodePacked(
        addresses[addressesOffset + 0],
        addresses[addressesOffset + 1],
        uints[uintsOffset + 0],
        uints[uintsOffset + 1],
        uints[uintsOffset + 2],
        uints[uintsOffset + 3],
        uints[uintsOffset + 4],
        uints[uintsOffset + 5],
        uints[uintsOffset + 6]
      ));
  }

  function getDepositWitness(Entry entry) internal view returns (DepositInfo result) {
    require(entry.entryType == EntryType.Deposit, "entry must be of type Deposit");
    result.nonce = entry.uints[offsets.uints.witness + 1];
    result.designatedGblock = entry.uints[offsets.uints.witness + 1];
  }

  function getWithdrawalRequestWitness(Entry entry) internal view returns (WithdrawalRequest result) {
    require(entry.entryType == EntryType.Withdrawal, "entry must be of type Withdrawal");
    result.account = entry.addresses[offsets.addresses.witness + 0];
    result.asset = entry.addresses[offsets.addresses.witness + 1];
    result.quantity = entry.uints[offsets.uints.witness + 0];
    result.originatorTimestamp = entry.uints[offsets.uints.witness + 1];
  }

  function getMatchWitness(Entry entry) internal view returns (Match match_) {
    require(entry.entryType == EntryType.Trade || entry.entryType == EntryType.Fee, "entry must of type Trade or Fee");
    match_.fill = getFill(entry, offsets.addresses.witness, offsets.uints.witness);
    match_.maker = getOrder(entry, offsets.addresses.maker, offsets.uints.maker);
    match_.taker = getOrder(entry, offsets.addresses.taker, offsets.uints.taker);
  }

  function getFill(Entry entry, uint8 addressesOffset, uint8 uintsOffset) private pure returns (Fill result) {
    result.token = entry.addresses[addressesOffset + 0];
    result.timestamp = entry.uints[uintsOffset + 0];
    result.quantity = entry.uints[uintsOffset + 1];
    result.price = entry.uints[uintsOffset + 2];
  }

  function getOrder(Entry entry, uint8 addressesOffset, uint8 uintsOffset) private pure returns (Order result) {
    result.account = entry.addresses[addressesOffset + 0];
    result.token = entry.addresses[addressesOffset + 1];
    result.originatorTimestamp = entry.uints[uintsOffset + 0];
    result.orderType = entry.uints[uintsOffset + 1];
    result.side = entry.uints[uintsOffset + 2];
    result.quantity = entry.uints[uintsOffset + 3];
    result.price = entry.uints[uintsOffset + 4];
    result.operatorTimestamp = entry.uints[uintsOffset + 5];
    result.filled = entry.uints[uintsOffset + 6];
  }

  enum EntryType { Unknown, Origin, Deposit, Withdrawal, Exited, Trade, Fee }

  struct Entry {
    EntryType entryType;
    uint action;
    uint timestamp;
    uint id;
    address account;
    address asset;
    uint quantity;
    uint balance;
    uint previous;
    address[] addresses;
    uint[] uints;
    bytes32 hash;
  }

  struct DepositCommitmentRecord {
    address account;
    address asset;
    uint quantity;
    uint nonce;
    uint designatedGblock;
    bytes32 hash;
  }

  struct DepositInfo {
    uint nonce;
    uint designatedGblock;
  }

  struct WithdrawalRequest {
    address account;
    address asset;
    uint quantity;
    uint originatorTimestamp;
  }

  struct Match { Fill fill; Order maker; Order taker; }

  struct Fill {
    uint timestamp;
    address token;
    uint quantity;
    uint price;
  }

  struct Order {
    uint originatorTimestamp;
    uint orderType;
    address account;
    address token;
    uint side;
    uint quantity;
    uint price;
    uint operatorTimestamp;
    uint filled;
  }

  Offsets private offsets = getOffsets();
  function getOffsets() private pure returns (Offsets) {
    uint8 addressesInEntry = 3;
    uint8 uintsInEntry = 7;
    uint8 addressesInFill = 1;
    uint8 uintsInFill = 3;
    uint8 addressesInOrder = 2;
    uint8 uintsInOrder = 7;
    uint8 addressesInDeposit = 3;
    uint8 uintsInDeposit = 3;
    return Offsets({
      addresses: OffsetKind({
        deposit: addressesInDeposit,
        witness: addressesInEntry,
        maker: addressesInEntry + addressesInFill,
        taker: addressesInEntry + addressesInFill + addressesInOrder
        }),
      uints: OffsetKind({
        deposit: uintsInDeposit,
        witness: uintsInEntry,
        maker: uintsInEntry + uintsInFill,
        taker: uintsInEntry + uintsInFill + uintsInOrder
        })
      });
  }
  struct OffsetKind { uint8 deposit; uint8 witness; uint8 maker; uint8 taker; }
  struct Offsets { OffsetKind addresses; OffsetKind uints; }
}

 

contract Custodian is Stoppable, HasOwners, MerkleProof, Ledger {

  address public constant ETH = address(0x0);
  uint public constant confirmationDelay = 2;
  uint public visibilityDelay = 3;
  uint private nonceGenerator = 0;

  address public operator;
  address public registry;
  string public version;

  constructor(address[] _owners, address _registry, address _operator, uint _submissionInterval, string _version)
    HasOwners(_owners)
    public validAddress(_registry) validAddress(_operator)
  {
    operator = _operator;
    registry = _registry;
    submissionInterval = _submissionInterval;
    version = _version;
  }

  function transfer(uint quantity, address asset, address account) internal {
    asset == ETH ?
      require(account.send(quantity), "failed to transfer ether") :
      require(Token(asset).transfer(account, quantity), "failed to transfer token");
  }

   
  function recover(bytes32 hash, bytes signature) private pure returns (address) {
    bytes32 r; bytes32 s; uint8 v;
    if (signature.length != 65) return (address(0));  

     
    assembly {
      r := mload(add(signature, 32))
      s := mload(add(signature, 64))
      v := byte(0, mload(add(signature, 96)))
    }

     
    if (v < 27) v += 27;

     
    return (v != 27 && v != 28) ? (address(0)) : ecrecover(hash, v, r, s);
  }

  function verifySignedBy(bytes32 hash, bytes signature, address signer) internal pure {
    require(recover(hash, signature) == signer, "failed to verify signature");
  }

   

  mapping (bytes32 => bool) public deposits;

  modifier validToken(address value) { require(value != ETH, "value must be a valid ERC20 token address"); _; }

  function () external payable { deposit(msg.sender, ETH, msg.value); }
  function depositEther() external payable { deposit(msg.sender, ETH, msg.value); }

   
  function depositToken(address token, uint quantity) validToken(token) external {
    require(Token(token).transferFrom(msg.sender, this, quantity), "failure to transfer quantity from token");
    deposit(msg.sender, token, quantity);
  }

  function deposit(address account, address asset, uint quantity) private {
    uint nonce = ++nonceGenerator;
    uint designatedGblock = currentGblockNumber + visibilityDelay;
    DepositCommitmentRecord memory record = toDepositCommitmentRecord(account, asset, quantity, nonce, designatedGblock);
    deposits[record.hash] = true;
    emit Deposited(address(this), account, asset, quantity, nonce, designatedGblock);
  }

  function reclaimDeposit(address[] addresses, uint[] uints, bytes32[] leaves, uint[] indexes, bytes predecessor, bytes successor) external {
    ProofOfExclusion memory proof = extractProofOfExclusion(addresses, uints, leaves, indexes, predecessor, successor);
    DepositCommitmentRecord memory excluded = proof.excluded;
    require(deposits[excluded.hash], "unknown deposit");
    require(currentGblockNumber > excluded.designatedGblock && excluded.designatedGblock != 0, "unknown designated gblock");

    Gblock memory designatedGblock = gblocksByNumber[excluded.designatedGblock];
    require(proveIsExcluded(designatedGblock.depositsRoot, proof), "failed to proof exclusion of deposit");

    delete deposits[excluded.hash];
    transfer(excluded.quantity, excluded.asset, excluded.account);
    emit DepositReclaimed(address(this), excluded.account, excluded.asset, excluded.quantity, excluded.nonce);
  }

  function calculateDepositCommitmentRecordHash(DepositCommitmentRecord result) private view returns (bytes32) {
    return keccak256(abi.encodePacked(
      address(this),
      result.account,
      result.asset,
      result.quantity,
      result.nonce,
      result.designatedGblock
    ));
  }

  function extractProofOfExclusion(address[] addresses, uint[] uints, bytes32[] leaves, uint[] indexes, bytes predecessor, bytes successor) private view returns (ProofOfExclusion result) {
    result.excluded = extractDepositCommitmentRecord(addresses, uints);
    result.predecessor = ProofOfInclusionAtIndex(leaves[0], indexes[0], predecessor);
    result.successor = ProofOfInclusionAtIndex(leaves[1], indexes[1], successor);
  }

  function extractDepositCommitmentRecord(address[] addresses, uint[] uints) private view returns (DepositCommitmentRecord) {
    return toDepositCommitmentRecord(
      addresses[1],
      addresses[2],
      uints[0],
      uints[1],
      uints[2]
    );
  }

  function toDepositCommitmentRecord(address account, address asset, uint quantity, uint nonce, uint designatedGblock) private view returns (DepositCommitmentRecord result) {
    result.account = account;
    result.asset = asset;
    result.quantity = quantity;
    result.nonce = nonce;
    result.designatedGblock = designatedGblock;
    result.hash = keccak256(abi.encodePacked(
      address(this),
      account,
      asset,
      quantity,
      nonce,
      designatedGblock
    ));
  }

  event Deposited(address indexed custodian, address indexed account, address indexed asset, uint quantity, uint nonce, uint designatedGblock);
  event DepositReclaimed(address indexed custodian, address indexed account, address indexed asset, uint quantity, uint nonce);

  struct ProofOfInclusionAtIndex { bytes32 leaf; uint index; bytes proof; }
  struct ProofOfExclusion { DepositCommitmentRecord excluded; ProofOfInclusionAtIndex predecessor; ProofOfInclusionAtIndex successor; }

   

  mapping (bytes32 => bool) public withdrawn;
  mapping (bytes32 => ExitClaim) public exitClaims;
  mapping (address => mapping (address => bool)) public exited;  

  function withdraw(address[] addresses, uint[] uints, bytes signature, bytes proof, bytes32 root) external {
    Entry memory entry = extractEntry(addresses, uints);
    verifySignedBy(entry.hash, signature, operator);
    require(entry.entryType == EntryType.Withdrawal, "entry must be of type Withdrawal");
    require(proveInConfirmedGblock(proof, root, entry.hash), "invalid entry proof");
    require(!withdrawn[entry.hash], "entry already withdrawn");
    withdrawn[entry.hash] = true;
    transfer(entry.quantity, entry.asset, entry.account);
    emit Withdrawn(entry.hash, entry.account, entry.asset, entry.quantity);
  }

  function claimExit(address[] addresses, uint[] uints, bytes signature, bytes proof, bytes32 root) external {
    Entry memory entry = extractEntry(addresses, uints);
    verifySignedBy(entry.hash, signature, operator);
    require(entry.account == msg.sender, "claimant must be entry&#39;s account");
    require(!hasExited(entry.account, entry.asset), "previously exited");
    require(proveInConfirmedBalances(proof, root, entry.hash), "invalid balance proof");

    uint confirmationThreshold = currentGblockNumber + confirmationDelay;
    exitClaims[entry.hash] = ExitClaim(entry, confirmationThreshold);
    emit ExitClaimed(entry.hash, entry.account, entry.asset, entry.balance, entry.timestamp, confirmationThreshold);
  }

  function exit(bytes32 entryHash, bytes proof, bytes32 root) external {
    ExitClaim memory claim = exitClaims[entryHash];
    require(claim.confirmationThreshold != 0, "no prior claim found to withdraw");
    require(currentGblockNumber >= claim.confirmationThreshold, "balances are yet to be confirmed");
    require(proveInConfirmedBalances(proof, root, entryHash), "invalid balance proof");
    delete exitClaims[entryHash];
    _exit_(claim.entry);
  }

  function exitOnHalt(address[] addresses, uint[] uints, bytes signature, bytes proof, bytes32 root) external whenOff {
    Entry memory entry = extractEntry(addresses, uints);
    verifySignedBy(entry.hash, signature, operator);
    require(entry.account == msg.sender, "claimant must be entry&#39;s account");
    require(proveInConfirmedBalances(proof, root, entry.hash), "invalid balance proof");
    _exit_(entry);
  }

  function _exit_(Entry entry) private {
    require(!hasExited(entry.account, entry.asset), "previously exited");
    exited[entry.account][entry.asset] = true;
    transfer(entry.balance, entry.asset, entry.account);
    emit Exited(entry.account, entry.asset, entry.balance);
  }

  function hasExited(address account, address asset) public view returns (bool) { return exited[account][asset]; }

  function canExit(bytes32 entryHash) public view returns (bool) {
    return
      exitClaims[entryHash].confirmationThreshold != 0   &&
      currentGblockNumber >= exitClaims[entryHash].confirmationThreshold;
  }

  event ExitClaimed(bytes32 hash, address indexed account, address indexed asset, uint quantity, uint timestamp, uint confirmationThreshold);
  event Exited(address indexed account, address indexed asset, uint quantity);
  event Withdrawn(bytes32 hash, address indexed account, address indexed asset, uint quantity);

  struct ExitClaim { Entry entry; uint confirmationThreshold; }

   

  uint public currentGblockNumber;
  mapping(bytes32 => Gblock) public gblocksByRoot;
  mapping(uint => Gblock) public gblocksByNumber;
  uint public submissionInterval;
  uint public submissionBlock = block.number;
  uint public voteTally = 0;

  function canSubmit() public view returns (bool) { return block.number >= submissionBlock; }

  function submit(uint gblockNumber, bytes32 ledgerRoot, bytes32 depositsRoot, bytes32 balancesRoot) external {
    require(canSubmit(), "cannot submit yet");
    require(msg.sender == operator, "submitter must be the operator");
    require(gblockNumber == currentGblockNumber + 1, "gblock must be the next in sequence");
    Gblock memory gblock = Gblock(gblockNumber, ledgerRoot, depositsRoot, balancesRoot);
    gblocksByRoot[ledgerRoot] = gblock;
    gblocksByNumber[gblockNumber] = gblock;
    currentGblockNumber = gblockNumber;
    emit Submitted(gblockNumber, ledgerRoot, depositsRoot, balancesRoot);
  }

   
  function verifyIncluded(bytes proof, bytes32 root, bytes32 leaf) public pure returns (bool) {
    return checkProof(proof, root, leaf);
  }

   
  function verifyIncludedAtIndex(bytes proof, bytes32 root, bytes32 leaf, uint index) public pure returns (bool) {
    return checkProofOrdered(proof, root, leaf, index);
  }

  function proveInConfirmedGblock(bytes proof, bytes32 root, bytes32 entryHash) public view returns (bool) {
    return isConfirmedGblock(root) && verifyIncluded(proof, root, entryHash);
  }

  function isConfirmedGblock(bytes32 root) public view returns (bool) {
    return includesGblock(root) && !isUnconfirmedGblock(root);
  }

  function isUnconfirmedGblock(bytes32 root) public view returns (bool) {
    return gblocksByRoot[root].gblockNumber == currentGblockNumber;
  }

  function includesGblock(bytes32 root) view public returns (bool) {
    return gblocksByRoot[root].gblockNumber != 0;
  }

  function proveInConfirmedBalances(bytes proof, bytes32 root, bytes32 entryHash) public view returns (bool) {
    return root == getGblockWithOffsetFromCurrent(1).balancesRoot && verifyIncluded(proof, root, entryHash);
  }

  function proveInUnconfirmedBalances(bytes proof, bytes32 root, bytes32 entryHash) public view returns (bool) {
    return root == getGblockWithOffsetFromCurrent(0).balancesRoot && verifyIncluded(proof, root, entryHash);
  }

  function getGblockWithOffsetFromCurrent(uint8 offset) private view returns (Gblock) {
    return gblocksByNumber[currentGblockNumber - offset];
  }

  function proveIsExcluded(bytes32 root, ProofOfExclusion proof) pure private returns (bool) {
    return proof.successor.index == proof.predecessor.index + 1 &&  
      verifyIncludedAtIndex(proof.predecessor.proof, root, proof.predecessor.leaf, proof.predecessor.index) &&
      verifyIncludedAtIndex(proof.successor.proof, root, proof.successor.leaf, proof.successor.index);
  }

  event Submitted(uint gblockNumber, bytes32 ledgerRoot, bytes32 depositsRoot, bytes32 balancesRoot);

  struct Gblock { uint gblockNumber; bytes32 ledgerRoot; bytes32 depositsRoot; bytes32 balancesRoot; }

   
}

 

 
library Math {

  function min(uint x, uint y) internal pure returns (uint) { return x <= y ? x : y; }
  function max(uint x, uint y) internal pure returns (uint) { return x >= y ? x : y; }


   
  function plus(uint x, uint y) internal pure returns (uint z) { require((z = x + y) >= x, "bad addition"); }

   
  function minus(uint x, uint y) internal pure returns (uint z) { require((z = x - y) <= x, "bad subtraction"); }


   
  function times(uint x, uint y) internal pure returns (uint z) { require(y == 0 || (z = x * y) / y == x, "bad multiplication"); }

   
  function mod(uint x, uint y) internal pure returns (uint z) {
    require(y != 0, "bad modulo; using 0 as divisor");
    z = x % y;
  }

   
  function dividePerfectlyBy(uint x, uint y) internal pure returns (uint z) {
    require((z = x / y) * y == x, "bad division; leaving a reminder");
  }

   
   
  function div(uint a, uint b) internal pure returns (uint c) {
     
    c = a / b;
     
  }

}

 

 
contract StandardToken is Token {

  function transfer(address _to, uint _value) public returns (bool success) {
     
     
     
     
    require(balances[msg.sender] >= _value, "sender has insufficient token balance");
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
     
     
    require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value,
      "either from address has insufficient token balance, or insufficient amount was approved for sender");
    balances[_to] += _value;
    balances[_from] -= _value;
    allowed[_from][msg.sender] -= _value;
    emit Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint remaining) {
    return allowed[_owner][_spender];
  }

  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;
}

 

 
contract Fee is HasOwners, StandardToken {

   
  event Burn(address indexed from, uint value);

  string public name;                    
  uint8 public decimals;                 
  string public symbol;                  
  string public version = "F0.2";        
  address public minter;

  modifier onlyMinter { require(msg.sender == minter, "invalid sender; must be minter"); _; }

  constructor(address[] owners, string tokenName, uint8 decimalUnits, string tokenSymbol)
    HasOwners(owners)
    public notEmpty(tokenName) notEmpty(tokenSymbol)
  {
    name = tokenName;
    decimals = decimalUnits;
    symbol = tokenSymbol;
  }

  function setMinter(address _minter) external onlyOwner validAddress(_minter) {
    minter = _minter;
  }

   
   
  function burnTokens(uint quantity) public notZero(quantity) {
    require(balances[msg.sender] >= quantity, "fixme: need a message");
    balances[msg.sender] = Math.minus(balances[msg.sender], quantity);
    totalSupply = Math.minus(totalSupply, quantity);
    emit Burn(msg.sender, quantity);
  }

   
   
   
   
  function sendTokens(address to, uint quantity) public onlyMinter validAddress(to) notZero(quantity) {
    balances[to] = Math.plus(balances[to], quantity);
    totalSupply = Math.plus(totalSupply, quantity);
    emit Transfer(0x0, to, quantity);
  }
}

 

contract Stake is HasOwners {
  using Math for uint;

  string public version;
  uint public weiPerFEE;  
  Token public LEV;
  Fee public FEE;
  address public wallet;
  address public operator;
  uint public intervalSize;

  bool public halted;
  uint public FEE2Distribute;
  uint public totalStakedLEV;
  uint public latest = 1;

  mapping (address => UserStake) public stakes;
  mapping (uint => Interval) public intervals;


   
  event Staked(address indexed user, uint levs, uint startBlock, uint endBlock, uint intervalId);
  event Restaked(address indexed user, uint levs, uint startBlock, uint endBlock, uint intervalId);
  event Redeemed(address indexed user, uint levs, uint feeEarned, uint startBlock, uint endBlock, uint intervalId);
  event FeeCalculated(uint feeCalculated, uint feeReceived, uint weiReceived, uint startBlock, uint endBlock, uint intervalId);
  event NewInterval(uint start, uint end, uint intervalId);
  event Halted(uint block, uint intervalId);

   
  struct UserStake {uint intervalId; uint quantity; uint worth;}
   
  struct Interval {uint worth; uint generatedFEE; uint start; uint end;}


  constructor(address[] _owners, address _operator, address _wallet, uint _weiPerFee, address _levToken, address _feeToken, uint _intervalSize, address registry, address apiKey, bytes32 userAgreement, string _version)
    HasOwners(_owners)
    public validAddress(_wallet) validAddress(_levToken) validAddress(_feeToken) notZero(_weiPerFee) notZero(_intervalSize)
  {
    wallet = _wallet;
    weiPerFEE = _weiPerFee;
    LEV = Token(_levToken);
    FEE = Fee(_feeToken);
    intervalSize = _intervalSize;
    intervals[latest].start = block.number;
    intervals[latest].end = intervals[latest].start + intervalSize;
    version = _version;
    operator = _operator;
    Registry(registry).registerWithUserAgreement(apiKey, userAgreement);
  }

  modifier notHalted { require(!halted, "exchange is halted"); _; }
  modifier onlyOperator { require(msg.sender == operator, "Only operator is allowed to perform this action"); _; }

  function() external payable {}

  function setWallet(address _wallet) external validAddress(_wallet) onlyOwner {
    ensureInterval();
    wallet = _wallet;
  }

  function setIntervalSize(uint _intervalSize) external notZero(_intervalSize) onlyOwner {
    ensureInterval();
    intervalSize = _intervalSize;
  }

   
  function ensureInterval() public notHalted {
    if (intervals[latest].end > block.number) return;

    Interval storage interval = intervals[latest];
    (uint feeEarned, uint ethEarned) = calculateIntervalEarning(interval.start, interval.end);
    interval.generatedFEE = feeEarned.plus(ethEarned.div(weiPerFEE));
    FEE2Distribute = FEE2Distribute.plus(interval.generatedFEE);
    if (ethEarned.div(weiPerFEE) > 0) FEE.sendTokens(this, ethEarned.div(weiPerFEE));
    emit FeeCalculated(interval.generatedFEE, feeEarned, ethEarned, interval.start, interval.end, latest);
    if (ethEarned > 0) wallet.transfer(ethEarned);

    uint diff = (block.number - intervals[latest].end) % intervalSize;
    latest += 1;
    intervals[latest].start = intervals[latest - 1].end;
    intervals[latest].end = block.number - diff + intervalSize;
    emit NewInterval(intervals[latest].start, intervals[latest].end, latest);
  }

  function restake(int signedQuantity) private {
    UserStake storage stake = stakes[msg.sender];
    if (stake.intervalId == latest || stake.intervalId == 0) return;
    uint lev = stake.quantity;
    uint withdrawLev = signedQuantity >= 0 ?
      0 :
      uint(signedQuantity * - 1) >= stake.quantity ?
        stake.quantity :
        uint(signedQuantity * - 1);
    redeem(withdrawLev);
    stake.quantity = lev.minus(withdrawLev);
    if (stake.quantity == 0) {
      delete stakes[msg.sender];
      return;
    }
    Interval storage interval = intervals[latest];
    stake.intervalId = latest;
    stake.worth = stake.quantity.times(interval.end.minus(interval.start));
    interval.worth = interval.worth.plus(stake.worth);
    emit Restaked(msg.sender, stake.quantity, interval.start, interval.end, latest);
  }

  function stake(int signedQuantity) external notHalted {
    ensureInterval();
    restake(signedQuantity);
    if (signedQuantity <= 0) return;
    stakeInCurrentPeriod(uint(signedQuantity));
  }

  function stakeInCurrentPeriod(uint quantity) private {
    require(LEV.allowance(msg.sender, this) >= quantity, "Approve LEV tokens first");
    Interval storage interval = intervals[latest];
    stakes[msg.sender].intervalId = latest;
    stakes[msg.sender].worth = stakes[msg.sender].worth.plus(quantity.times(intervals[latest].end.minus(block.number)));
    stakes[msg.sender].quantity = stakes[msg.sender].quantity.plus(quantity);
    interval.worth = interval.worth.plus(quantity.times(interval.end.minus(block.number)));
    require(LEV.transferFrom(msg.sender, this, quantity), "LEV token transfer was not successful");
    totalStakedLEV = totalStakedLEV.plus(quantity);
    emit Staked(msg.sender, quantity, interval.start, interval.end, latest);
  }

  function withdraw() external {
    if (!halted) ensureInterval();
    if (stakes[msg.sender].intervalId == 0 || stakes[msg.sender].intervalId == latest) return;
    redeem(stakes[msg.sender].quantity);
  }

  function halt() external notHalted onlyOwner {
    intervals[latest].end = block.number;
    ensureInterval();
    halted = true;
    emit Halted(block.number, latest - 1);
  }

  function transferToWalletAfterHalt() public onlyOwner {
    require(halted, "Stake is not halted yet.");
    uint feeEarned = FEE.balanceOf(this).minus(FEE2Distribute);
    uint ethEarned = address(this).balance;
    if (feeEarned > 0) FEE.transfer(wallet, feeEarned);
    if (ethEarned > 0) wallet.transfer(ethEarned);
  }

  function transferToken(address token) public validAddress(token) {
    if (token == address(FEE)) return;
    uint balance = Token(token).balanceOf(this);
    if (token == address(LEV)) balance = balance.minus(totalStakedLEV);
    if (balance > 0) Token(token).transfer(wallet, balance);
  }

  function redeem(uint howMuchLEV) private {
    uint intervalId = stakes[msg.sender].intervalId;
    Interval memory interval = intervals[intervalId];
    uint earnedFEE = stakes[msg.sender].worth.times(interval.generatedFEE).div(interval.worth);
    delete stakes[msg.sender];
    if (earnedFEE > 0) {
      FEE2Distribute = FEE2Distribute.minus(earnedFEE);
      require(FEE.transfer(msg.sender, earnedFEE), "Fee transfer to account failed");
    }
    if (howMuchLEV > 0) {
      totalStakedLEV = totalStakedLEV.minus(howMuchLEV);
      require(LEV.transfer(msg.sender, howMuchLEV), "Redeeming LEV token to account failed.");
    }
    emit Redeemed(msg.sender, howMuchLEV, earnedFEE, interval.start, interval.end, intervalId);
  }

   
  function calculateIntervalEarning(uint start, uint end) public view returns (uint earnedFEE, uint earnedETH) {
    earnedFEE = FEE.balanceOf(this).minus(FEE2Distribute);
    earnedETH = address(this).balance;
    earnedFEE = earnedFEE.times(end.minus(start)).div(block.number.minus(start));
    earnedETH = earnedETH.times(end.minus(start)).div(block.number.minus(start));
  }

  function registerApiKey(address registry, address apiKey, bytes32 userAgreement) public onlyOwner {
    Registry(registry).registerWithUserAgreement(apiKey, userAgreement);
  }

  function withdrawFromCustodian(address custodian, address[] addresses, uint[] uints, bytes signature, bytes proof, bytes32 root) public onlyOperator {
    Custodian(custodian).withdraw(addresses, uints, signature, proof, root);
  }

  function exitOnHaltFromCustodian(address custodian, address[] addresses, uint[] uints, bytes signature, bytes proof, bytes32 root) public onlyOperator {
    Custodian(custodian).exitOnHalt(addresses, uints, signature, proof, root);
  }
}