pragma solidity ^0.4.23;

contract ERC721 {
 
 
 
 
 
 
 
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);
 
 
 
 
 
 
}

contract YummyAccessControl {

     
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

     
    bool public paused = false;

     
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

     
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

     
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

     
    modifier onlyCLevel() {
        require(
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress ||
            msg.sender == cooAddress
        );
        _;
    }

     
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));
        ceoAddress = _newCEO;
    }

     
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));
        cfoAddress = _newCFO;
    }

     
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));
        cooAddress = _newCOO;
    }

     
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

     
    modifier whenPaused {
        require(paused);
        _;
    }

     
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

     
    function unpause() public onlyCEO whenPaused {
        paused = false;
    }

}

contract YummyBase is YummyAccessControl {

     
    event TokenCreation(address owner, uint256 tokenId, uint256 mmotherId, uint256 fatherId, uint256 genes);
    event Transfer(address from, address to, uint256 tokenId);

     
    struct Token {
        uint256 genes;
        uint64 creationTime;
        uint64 cooldownEndBlock;
        uint32 motherId;
        uint32 fatherId;
        uint32 breedingWithId;
        uint16 cooldownIndex;
        uint16 generation;
    }

     
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

     
    Token[] tokens;

     
    mapping (uint256 => address) public tokenIndexToOwner;

     
    mapping (address => uint256) ownershipTokenCount;

     
    mapping (uint256 => address) public tokenIndexToApproved;

     
    mapping (uint256 => address) public fatherAllowedToAddress;

     
 

     
    BreedingClockAuction public breedingAuction;

     
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownershipTokenCount[_to]++;
        tokenIndexToOwner[_tokenId] = _to;
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            delete fatherAllowedToAddress[_tokenId];
            delete tokenIndexToApproved[_tokenId];
        }
        emit Transfer(_from, _to, _tokenId);
    }

     
    function _createToken(
        uint256 _motherId,
        uint256 _fatherId,
        uint256 _generation,
        uint256 _genes,
        address _owner
    )
    internal
    returns (uint)
    {
        require(_motherId == uint256(uint32(_motherId)));
        require(_fatherId == uint256(uint32(_fatherId)));
        require(_generation == uint256(uint16(_generation)));

         
        uint16 cooldownIndex = uint16(_generation / 2);
        if (cooldownIndex > 13) {
            cooldownIndex = 13;
        }

        Token memory _token = Token({
            genes: _genes,
            creationTime: uint64(now),
            cooldownEndBlock: 0,
            motherId: uint32(_motherId),
            fatherId: uint32(_fatherId),
            breedingWithId: 0,
            cooldownIndex: cooldownIndex,
            generation: uint16(_generation)
        });

        uint256 newTokenId = tokens.push(_token) - 1;

        require(newTokenId == uint256(uint32(newTokenId)));

         
        emit TokenCreation(
            _owner,
            newTokenId,
            uint256(_token.motherId),
            uint256(_token.fatherId),
            _token.genes
        );

         
        _transfer(0, _owner, newTokenId);

        return newTokenId;
    }

     
    function setSecondsPerBlock(uint256 secs) external onlyCLevel {
        require(secs < cooldowns[0]);
        secondsPerBlock = secs;
    }
}

contract YummyOwnership is YummyBase, ERC721 {

    string public constant name = "Yummies";
    string public constant symbol = "YUMS";

     

    function transfer(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        require(_to != address(0));
        require(_to != address(this));
        require(_to != address(breedingAuction));
        require(_owns(msg.sender, _tokenId));

        _transfer(msg.sender, _to, _tokenId);
    }

    function _owns(
        address _claimant,
        uint256 _tokenId
    )
        internal
        view
        returns (bool)
    {
        return tokenIndexToOwner[_tokenId] == _claimant;
    }

    function _approvedFor(
        address _claimant,
        uint256 _tokenId
    )
        internal
        view
        returns (bool)
    {
        return tokenIndexToApproved[_tokenId] == _claimant;
    }

    function _approve(
        uint256 _tokenId,
        address _approved
    )
        internal
    {
        tokenIndexToApproved[_tokenId] = _approved;
    }

    function balanceOf(
        address _owner
    )
        public
        view
        returns (uint256 count)
    {
        return ownershipTokenCount[_owner];
    }

     

    function approve(
        address _approved,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        require(_owns(msg.sender, _tokenId));

        _approve(_tokenId, _approved);

        emit Approval(msg.sender, _approved, _tokenId);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        require(_to != address(0));
        require(_to != address(this));
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        _transfer(_from, _to, _tokenId);
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return tokens.length;
    }

    function ownerOf(
        uint256 _tokenId
    )
        external
        view
        returns (address owner)
    {
        owner = tokenIndexToOwner[_tokenId];
        require(owner != address(0));
    }

     
    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] ownerTokens)
    {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTokens = totalSupply();
            uint256 resultIndex = 0;
            uint256 tokenId;

            for (tokenId = 1; tokenId <= totalTokens; tokenId++) {
                if (tokenIndexToOwner[tokenId] == _owner) {
                    result[resultIndex] = tokenId;
                    resultIndex++;
                }
            }
        }

        return result;
    }


}

contract Ownable {
    address public owner;

     
    constructor() public {
        owner = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

}

contract YummyBreeding is YummyOwnership {

     
    event Pregnant(address owner, uint256 motherId, uint256 fatherId, uint256 cooldownEndBlock);

     
    uint256 public autoBirthFee = 2 finney;

     
    uint256 public pregnantTokens;

     
    GeneScience public geneScience;

    function setGeneScienceAddress(address _address) external onlyCLevel {
        GeneScience candidateContract = GeneScience(_address);
        require(candidateContract.isGeneScience());
        geneScience = candidateContract;
    }

     
    function _isReadyToBreed(Token _token) internal view returns (bool) {
        return (_token.breedingWithId == 0) && (_token.cooldownEndBlock <= uint64(block.number));
    }

     
    function _isBreedingPermitted(uint256 _fatherId, uint256 _motherId) internal view returns (bool) {
        address motherOwner = tokenIndexToOwner[_motherId];
        address fatherOwner = tokenIndexToOwner[_fatherId];

        return (motherOwner == fatherOwner || fatherAllowedToAddress[_fatherId] == motherOwner);
    }

     
    function _triggerCooldown(Token storage _token) internal {
        _token.cooldownEndBlock = uint64((cooldowns[_token.cooldownIndex] / secondsPerBlock) + block.number);
        if (_token.cooldownIndex < 13) {
            _token.cooldownIndex += 1;
        }
    }

     
    function approveBreeding(address _addr, uint256 _fatherId) external whenNotPaused {
        require(_owns(msg.sender, _fatherId));
        fatherAllowedToAddress[_fatherId] = _addr;
    }

     
    function setAutoBirthFee(uint256 val) external onlyCLevel {
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

         
        emit Pregnant(
            tokenIndexToOwner[_motherId],
                _motherId,
                _fatherId,
                mother.cooldownEndBlock
        );
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

         
        uint256 dna = geneScience.randomGenes();

         
        address owner = tokenIndexToOwner[_motherId];
        uint256 tokenId = _createToken(_motherId, fatherId, parentGeneration + 1, dna, owner);

         
        delete mother.breedingWithId;

        pregnantTokens--;

         
        msg.sender.transfer(autoBirthFee);

         
        return tokenId;
    }
}

contract YummyAuction is YummyBreeding {

    function setBreedingAuctionAddress(address _address) external onlyCLevel {
        BreedingClockAuction candidateContract = BreedingClockAuction(_address);

        require(candidateContract.isBreedingClockAuction());

        breedingAuction = candidateContract;
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

     
    modifier whenPaused {
        require(paused);
        _;
    }

     
    function pause() onlyOwner whenNotPaused public returns (bool) {
        paused = true;
        emit Pause();
        return true;
    }

     
    function unpause() onlyOwner whenPaused public returns (bool) {
        paused = false;
        emit Unpause();
        return true;
    }
}

contract GeneScience {

    function isGeneScience() public pure returns (bool) {
        return true;
    }

    function uintToBytes(uint256 x) public pure returns (bytes b) {
        b = new bytes(32);
        for (uint i = 0; i < 32; i++) {
            b[i] = byte(uint8(x / (2**(8*(31 - i)))));
        }
    }

    function mixGenes(uint256 genes1, uint256 genes2) public pure returns (uint256) {
         
        bytes memory b1 = uintToBytes(genes1);
        bytes memory b2 = uintToBytes(genes2);

         
        bytes32 newGenes;

         
        for (uint i = 0; i < 32; i++) {
            if (i % 2 == 0) {
                newGenes |= bytes32(b1[i] & 0xFF) >> (i * 8);
            } else {
                newGenes |= bytes32(b2[i] & 0xFF) >> (i * 8);
            }
        }

        return uint256(newGenes);
    }

    function randomGenes() public view returns (uint256) {
        return uint256(keccak256(now));
    }
}

contract ClockAuctionBase {

}

contract ClockAuction is Pausable, ClockAuctionBase {

}

contract BreedingClockAuction is ClockAuction {

    bool public isBreedingClockAuction = true;

}

contract YummyMinting is YummyAuction {

}

contract YummyCore is YummyMinting {

    constructor() public {
        paused = true;

        ceoAddress = msg.sender;
        cooAddress = msg.sender;
        cfoAddress = msg.sender;

        _createToken(0, 0, 0, 0, msg.sender);

    }

    function() external payable {
        require(
            msg.sender == address(breedingAuction)
        );
    }


}