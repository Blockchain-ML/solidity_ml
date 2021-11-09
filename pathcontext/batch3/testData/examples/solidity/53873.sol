pragma solidity ^0.4.23;


 
library AddressUtils {

     
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

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
         
        uint256 c = a / b;
         
        return c;
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
}


 
contract ERC721Receiver {
     
    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

     
    function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}


 
contract ERC721Basic {
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function exists(uint256 _tokenId) public view returns (bool _exists);

    function approve(address _to, uint256 _tokenId) public;
    function getApproved(uint256 _tokenId) public view returns (address _operator);

    function setApprovalForAll(address _operator, bool _approved) public;
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public;
}


 
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
    constructor() public {
        owner = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

 
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


     
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

     
    modifier whenPaused() {
        require(paused);
        _;
    }

     
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

     
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}


 
contract ERC721BasicToken is ERC721Basic, Pausable {
    using SafeMath for uint256;
    using AddressUtils for address;

     
     
    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

     
    mapping (uint256 => address) internal tokenOwner;

     
    mapping (uint256 => address) internal tokenApprovals;

     
    mapping (address => uint256) internal ownedTokensCount;

     
    mapping (address => mapping (address => bool)) internal operatorApprovals;

     
    modifier onlyOwnerOf(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender);
        _;
    }

     
    modifier canTransfer(uint256 _tokenId) {
        require(isApprovedOrOwner(msg.sender, _tokenId));
        _;
    }

     
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0));
        return ownedTokensCount[_owner];
    }

     
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = tokenOwner[_tokenId];
        require(owner != address(0));
        return owner;
    }

     
    function exists(uint256 _tokenId) public view returns (bool) {
        address owner = tokenOwner[_tokenId];
        return owner != address(0);
    }

     
    function approve(address _to, uint256 _tokenId) public {
        address owner = ownerOf(_tokenId);
        require(_to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        if (getApproved(_tokenId) != address(0) || _to != address(0)) {
            tokenApprovals[_tokenId] = _to;
            emit Approval(owner, _to, _tokenId);
        }
    }

     
    function getApproved(uint256 _tokenId) public view returns (address) {
        return tokenApprovals[_tokenId];
    }


     
    function setApprovalForAll(address _to, bool _approved) public {
        require(_to != msg.sender);
        operatorApprovals[msg.sender][_to] = _approved;
        emit ApprovalForAll(msg.sender, _to, _approved);
    }

     
    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

     
    function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
         
        require(_to != address(0));

        clearApproval(_from, _tokenId);
        removeTokenFrom(_from, _tokenId);
        addTokenTo(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

     
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

     
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public canTransfer(_tokenId) {
        transferFrom(_from, _to, _tokenId);
        require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
    }

     
    function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
        address owner = ownerOf(_tokenId);
        return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
    }

     
    function _mint(address _to, uint256 _tokenId) internal {
        require(_to != address(0));
        addTokenTo(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
    }

     
 
 
 
 
 

     
    function clearApproval(address _owner, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _owner);
        if (tokenApprovals[_tokenId] != address(0)) {
            tokenApprovals[_tokenId] = address(0);
            emit Approval(_owner, address(0), _tokenId);
        }
    }

     
    function addTokenTo(address _to, uint256 _tokenId) internal {
        require(tokenOwner[_tokenId] == address(0));
        tokenOwner[_tokenId] = _to;
        ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
    }

     
    function removeTokenFrom(address _from, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from);
        ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
        tokenOwner[_tokenId] = address(0);
    }

     
    function checkAndCallSafeTransfer(address _from, address _to, uint256 _tokenId, bytes _data) internal returns (bool) {
        if (!_to.isContract()) {
            return true;
        }
        bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
        return (retval == ERC721_RECEIVED);
    }
}

contract YummyBase is ERC721BasicToken {

    constructor() public {
        createGen0Token(0);
        pause();
    }

     
    string internal name_ = "TestToken";

     
    string internal symbol_ = "TT";

     
    function name() public view returns (string) {
        return name_;
    }

     
    function symbol() public view returns (string) {
        return symbol_;
    }

     
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

     
    event TokenCreation(address owner, uint256 tokenId, uint256 motherId, uint256 fatherId, uint256 dna, uint8 species);

     
    struct Token {

         
        uint256 dna;

         
        uint64 creationTime;

         
         
        uint64 cooldownEndBlock;

         
        uint32 motherId;

         
        uint32 fatherId;

         
        uint32 breedingWithId;

         
        uint16 generation;

         
        uint16 cooldownIndex;

         
        uint8 species;

    }

     
    Token[] tokens;

     
    mapping (uint256 => address) public breedingAllowedToAddress;

     
    uint32[14] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days),
        uint32(2 days),
        uint32(4 days),
        uint32(7 days)
    ];

     
    uint256 public secondsPerBlock = 15;

     
    function totalSupply() public view returns (uint) {
        return tokens.length;
    }

     
    function _createToken(
        uint256 _motherId,
        uint256 _fatherId,
        uint256 _generation,
        uint256 _dna,
        uint256 _species,
        address _owner
    )
        internal
        returns (uint)
    {
         
        uint16 cooldownIndex = uint16(_generation / 2);
        if (cooldownIndex > 13) {
            cooldownIndex = 13;
        }

        Token memory _token = Token({
            dna: _dna,
            creationTime: uint64(now),
            cooldownEndBlock: 0,
            motherId: uint32(_motherId),
            fatherId: uint32(_fatherId),
            breedingWithId: 0,
            cooldownIndex: cooldownIndex,
            generation: uint16(_generation),
            species: uint8(_species)
        });

        uint256 newTokenId = tokens.push(_token).sub(1);

        emit TokenCreation(_owner, newTokenId, _fatherId, _motherId, _dna, uint8(_species));

        _mint(_owner, newTokenId);

        return newTokenId;
    }

     
    function _generateRandomDna() internal view returns (uint256) {
        return uint256(keccak256(now));
    }

     
    function createGen0Token(uint8 _species) public onlyOwner {
        uint dna = _generateRandomDna();
        _createToken(0, 0, 0, dna, _species, owner);
    }

     
    function getToken(uint256 _tokenId)
        external
        view
        returns (
            bool isPregnant,
            bool isReady,
            uint256 dna,
            uint256 creationTime,
            uint256 cooldownEndBlock,
            uint32 motherId,
            uint32 fatherId,
            uint32 breedingWithId,
            uint16 generation,
            uint8 species
        )
    {
        Token storage token = tokens[_tokenId];

        isPregnant = (token.breedingWithId != 0);
        isReady = (token.cooldownEndBlock <= block.number);
        dna = token.dna;
        creationTime = uint256(token.creationTime);
        cooldownEndBlock = uint256(token.cooldownEndBlock);
        motherId = uint32(token.motherId);
        fatherId = uint32(token.fatherId);
        breedingWithId = uint32(token.breedingWithId);
        generation = uint16(token.generation);
        species = uint8(token.species);
    }

}

 
contract YummyBreeding is YummyBase {

     
    event Pregnant(address owner, uint256 motherId, uint256 fatherId, uint256 cooldownEndBlock);

     
    uint256 public autoBirthFee = 2 finney;

     
    uint256 public pregnantTokens;

     

     
    function _isReadyToBreed(Token _token) internal view returns (bool) {
        return (_token.breedingWithId == 0) && (_token.cooldownEndBlock <= uint64(block.number));
    }

     
    function _isBreedingPermitted(uint256 _fatherId, uint256 _motherId) internal view returns (bool) {
        address motherOwner = tokenOwner[_motherId];
        address fatherOwner = tokenOwner[_fatherId];

        return (motherOwner == fatherOwner || breedingAllowedToAddress[_fatherId] == motherOwner);
    }

     
    function _triggerCooldown(Token storage _token) internal {
        _token.cooldownEndBlock = uint64((cooldowns[_token.cooldownIndex] / secondsPerBlock) + block.number);
        if (_token.cooldownIndex < 13) {
            _token.cooldownIndex += 1;
        }
    }

     
    function approveBreeding(address _addr, uint256 _fatherId) external whenNotPaused {
        require(_owns(msg.sender, _fatherId));
        breedingAllowedToAddress[_fatherId] = _addr;
    }

     
    function setAutoBirthFee(uint256 val) external onlyOwner {
        autoBirthFee = val;
    }

     
    function _isReadyToGiveBirth(Token _mother) private view returns (bool) {
        return (_mother.breedingWithId != 0) && (_mother.cooldownEndBlock <= uint64(block.number));
    }

     
    function isReadyToBreed(uint256 _tokenId) public view returns (bool) {
        require(_tokenId > 0);  
        Token storage token = tokens[_tokenId];
        return _isReadyToBreed(token);
    }

     
    function isPregnant(uint256 _tokenId) public view returns (bool) {
        require(_tokenId > 0);
        return tokens[_tokenId].breedingWithId != 0;
    }

     
    function _isValidBreedingPair(
        Token storage _mother,
        uint256 _motherId,
        Token storage _father,
        uint256 _fatherId
    )
        private
        view
        returns (bool)
    {
         
        if (_motherId == _fatherId) { return false; }

         
        if (_mother.motherId == _fatherId || _mother.fatherId == _fatherId) {
            return false;
        }

         
        if (_father.motherId == _motherId || _mother.fatherId == _motherId) {
            return false;
        }

         
        if (_father.motherId == 0 || _mother.motherId == 0) { return true; }

         
        if (_father.motherId == _mother.motherId || _father.motherId == _mother.fatherId) {
            return false;
        }
        if (_father.fatherId == _mother.motherId || _father.fatherId == _mother.fatherId) {
            return false;
        }

        return true;
    }

     
    function _canBreedViaAuction(uint256 _motherId, uint256 _fatherId)
        internal
        view
        returns (bool)
    {
        Token storage mother = tokens[_motherId];
        Token storage father = tokens[_fatherId];
        return _isValidBreedingPair(mother, _motherId, father, _fatherId);
    }

     
    function canBreedWith(uint256 _motherId, uint256 _fatherId)
        external
        view
        returns (bool)
    {
        require(_motherId > 0);
        require(_fatherId > 0);
        Token storage mother = tokens[_motherId];
        Token storage father = tokens[_fatherId];
        return _isValidBreedingPair(mother, _motherId, father, _fatherId) &&
            _isBreedingPermitted(_fatherId, _motherId);
    }

     
    function _breedWith(uint256 _motherId, uint256 _fatherId) internal {
         
        Token storage mother = tokens[_motherId];
        Token storage father = tokens[_fatherId];

         
        mother.breedingWithId = uint32(_fatherId);

         
        _triggerCooldown(father);
        _triggerCooldown(mother);

         
        pregnantTokens++;

         
        emit Pregnant(tokenOwner[_motherId], _motherId, _fatherId, mother.cooldownEndBlock);
    }

     
    function breedWithAuto(uint256 _motherId, uint256 _fatherId)
        external
        payable
        whenNotPaused
    {
         
        require(msg.value >= autoBirthFee);
         
        require(_owns(msg.sender, _motherId));
         
        require(_isBreedingPermitted(_fatherId, _motherId));

         
        Token storage mother = tokens[_motherId];
        require(_isReadyToBreed(mother));
        Token storage father = tokens[_fatherId];
        require(_isReadyToBreed(father));

         
        require(_isValidBreedingPair(mother, _motherId, father, _fatherId));

         
        _breedWith(_motherId, _fatherId);

    }

     
    function giveBirth(uint256 _motherId)
        external
        whenNotPaused
        returns (uint256)
    {
         
        Token storage mother = tokens[_motherId];

         
        require(mother.creationTime != 0);
        require(_isReadyToGiveBirth(mother));

        uint256 fatherId = mother.breedingWithId;
        Token storage father = tokens[fatherId];

         
        uint16 parentGeneration = mother.generation;
        if (father.generation > mother.generation) {
            parentGeneration = father.generation;
        }

         
         
        uint256 dna = _generateRandomDna();
        uint8 species = 1;

         
        address owner = tokenOwner[_motherId];
        uint256 tokenId = _createToken(_motherId, fatherId, parentGeneration + 1, dna, species, owner);

         
        delete mother.breedingWithId;

        pregnantTokens--;

         
        msg.sender.transfer(autoBirthFee);

         
        return tokenId;
    }

     

     
    function _owns(address _addr, uint256 _tokenId) internal view returns (bool) {
        return tokenOwner[_tokenId] == _addr;
    }
}

contract YummyToken is YummyBreeding {}