pragma solidity ^0.4.24;


 
contract Owned {
    address public owner;
    address public newOwner;
    mapping (address => bool) public admins;

    event OwnershipTransferred(
        address indexed _from, 
        address indexed _to
    );

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmins {
        require(admins[msg.sender]);
        _;
    }

    function transferOwnership(address _newOwner) 
        public 
        onlyOwner 
    {
        newOwner = _newOwner;
    }

    function acceptOwnership() 
        public 
    {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    function addAdmin(address _admin) 
        onlyOwner 
        public 
    {
        admins[_admin] = true;
    }

    function removeAdmin(address _admin) 
        onlyOwner 
        public 
    {
        delete admins[_admin];
    }

}

 
contract Pausable is Owned {
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

     
    function pause() 
        onlyAdmins 
        whenNotPaused 
        public 
    {
        paused = true;
        emit Pause();
    }

     
    function unpause() 
        onlyAdmins 
        whenPaused 
        public 
    {
        paused = false;
        emit Unpause();
    }
}


 
library AddressUtils {

     
    function isContract(address addr) 
        internal 
        view 
        returns (bool) 
    {
        uint256 size;
         
         
         
         
         
         
         
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

 
library SafeMath {
    
     
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        uint256 c = a / b;
         
        return c;
    }
    
     
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

     
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
    
     
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    
     
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }
    
     
    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else 
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}

 
 
 
interface ERC165 {

     
    function supportsInterface(bytes4 _interfaceId)
        external
        view
        returns (bool);
}

 
contract ERC721Basic is ERC165 {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function exists(uint256 _tokenId) public view returns (bool _exists);

    function approve(address _to, uint256 _tokenId) public;
    function getApproved(uint256 _tokenId)
        public view returns (address _operator);

    function setApprovalForAll(address _operator, bool _approved) public;
    function isApprovedForAll(address _owner, address _operator)
        public view returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
        public;
}

 
contract ERC721Enumerable is ERC721Basic {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(
        address _owner,
        uint256 _index
    )
        public
        view
        returns (uint256 _tokenId);

    function tokenByIndex(uint256 _index) public view returns (uint256);
}

 
contract ERC721Metadata is ERC721Basic {
    function name() external view returns (string _name);
    function symbol() external view returns (string _symbol);
    function tokenURI(uint256 _tokenId) public view returns (string);
}

 
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

 
contract ERC721Receiver {
     
    bytes4 internal constant ERC721_RECEIVED = 0xf0b9e5ba;

     
    function onERC721Received(
        address _from,
        uint256 _tokenId,
        bytes _data
    )
        public
        returns (bytes4);
}

contract ERC721Holder is ERC721Receiver {
    function onERC721Received(address, uint256, bytes) 
        public 
        returns (bytes4) 
    {
        return ERC721_RECEIVED;
    }
}

 
contract SupportsInterfaceWithLookup is ERC165 {
    bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;
     

     
    mapping(bytes4 => bool) internal supportedInterfaces;

     
    constructor()
        public
    {
        _registerInterface(InterfaceId_ERC165);
    }

     
    function supportsInterface(bytes4 _interfaceId)
        external
        view
        returns (bool)
    {
        return supportedInterfaces[_interfaceId];
    }

     
    function _registerInterface(bytes4 _interfaceId)
        internal
    {
        require(_interfaceId != 0xffffffff);
        supportedInterfaces[_interfaceId] = true;
    }
}


 
contract ERC721BasicToken is SupportsInterfaceWithLookup, ERC721Basic, Pausable {

    bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;
     

    bytes4 private constant InterfaceId_ERC721Exists = 0x4f558e79;
     

    using SafeMath for uint256;
    using AddressUtils for address;

     
     
    bytes4 private constant ERC721_RECEIVED = 0xf0b9e5ba;

     
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

    constructor()
        public
    {
         
        _registerInterface(InterfaceId_ERC721);
        _registerInterface(InterfaceId_ERC721Exists);
    }

     
    function balanceOf(address _owner) 
        public 
        view 
        returns (uint256) 
    {
        require(_owner != address(0));
        return ownedTokensCount[_owner];
    }

     
    function ownerOf(uint256 _tokenId) 
        public 
        view 
        returns (address) 
    {
        address owner = tokenOwner[_tokenId];
        require(owner != address(0));
        return owner;
    }

     
    function exists(uint256 _tokenId) 
        public 
        view 
        returns (bool) 
    {
        address owner = tokenOwner[_tokenId];
        return owner != address(0);
    }

     
    function approve(address _to, uint256 _tokenId) 
        public 
        whenNotPaused 
    {
        address owner = ownerOf(_tokenId);
        require(_to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        tokenApprovals[_tokenId] = _to;
        emit Approval(owner, _to, _tokenId);
    }

     
    function getApproved(uint256 _tokenId) 
        public 
        view 
        returns (address) 
    {
        return tokenApprovals[_tokenId];
    }

     
    function setApprovalForAll(address _to, bool _approved) 
        public 
        whenNotPaused 
    {
        require(_to != msg.sender);
        operatorApprovals[msg.sender][_to] = _approved;
        emit ApprovalForAll(msg.sender, _to, _approved);
    }

     
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        returns (bool)
    {
        return operatorApprovals[_owner][_operator];
    }

     
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
        whenNotPaused
        canTransfer(_tokenId)
    {
        require(_from != address(0));
        require(_to != address(0));

        clearApproval(_from, _tokenId);
        removeTokenFrom(_from, _tokenId);
        addTokenTo(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

     
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
        whenNotPaused
        canTransfer(_tokenId)
    {
         
        safeTransferFrom(_from, _to, _tokenId, "");
    }

     
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
        public
        whenNotPaused
        canTransfer(_tokenId)
    {
        transferFrom(_from, _to, _tokenId);
         
        require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
    }

     
    function isApprovedOrOwner(address _spender, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        address owner = ownerOf(_tokenId);
         
         
         
        return (
            _spender == owner ||
            getApproved(_tokenId) == _spender ||
            isApprovedForAll(owner, _spender)
        );
    }

     
    function _mint(address _to, uint256 _tokenId) 
        internal 
    {
        require(_to != address(0));
        addTokenTo(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
    }

     
    function _burn(address _owner, uint256 _tokenId) 
        internal 
    {
        clearApproval(_owner, _tokenId);
        removeTokenFrom(_owner, _tokenId);
        emit Transfer(_owner, address(0), _tokenId);
    }

     
    function clearApproval(address _owner, uint256 _tokenId) 
        internal 
    {
        require(ownerOf(_tokenId) == _owner);
        if (tokenApprovals[_tokenId] != address(0)) {
            tokenApprovals[_tokenId] = address(0);
            emit Approval(_owner, address(0), _tokenId);
        }
    }

     
    function addTokenTo(address _to, uint256 _tokenId) 
        internal 
    {
        require(tokenOwner[_tokenId] == address(0));
        tokenOwner[_tokenId] = _to;
        ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
    }

     
    function removeTokenFrom(address _from, uint256 _tokenId) 
        internal 
    {
        require(ownerOf(_tokenId) == _from);
        ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
        tokenOwner[_tokenId] = address(0);
    }

     
    function checkAndCallSafeTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
        internal	
        returns (bool)
    {
        if (!_to.isContract()) {
            return true;
        }
        bytes4 retval = ERC721Receiver(_to).onERC721Received(
            _from, _tokenId, _data);
        return (retval == ERC721_RECEIVED);
    }
}

 
contract ERC721Token is SupportsInterfaceWithLookup, ERC721BasicToken, ERC721 {

    bytes4 private constant InterfaceId_ERC721Enumerable = 0x780e9d63;
     

    bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
     

     
    string internal name_;

     
    string internal symbol_;

     
    mapping(address => uint256[]) internal ownedTokens;

     
    mapping(uint256 => uint256) internal ownedTokensIndex;

     
    uint256[] internal allTokens;

     
    mapping(uint256 => uint256) internal allTokensIndex;

     
    mapping(uint256 => string) internal tokenURIs;

     
    constructor(string _name, string _symbol) 
        public 
    {
        name_ = _name;
        symbol_ = _symbol;

         
        _registerInterface(InterfaceId_ERC721Enumerable);
        _registerInterface(InterfaceId_ERC721Metadata);
    }

     
    function name() 
        external 
        view 
        returns (string) 
    {
        return name_;
    }

     
    function symbol() 
        external 
        view 
        returns (string) 
    {
        return symbol_;
    }

     
    function tokenURI(uint256 _tokenId) 
        public 
        view 
        returns (string) 
    {
        require(exists(_tokenId));
        return tokenURIs[_tokenId];
    }

     
    function tokenOfOwnerByIndex(
        address _owner,
        uint256 _index
    )
        public
        view
        returns (uint256)
    {
        require(_index < balanceOf(_owner));
        return ownedTokens[_owner][_index];
    }

     
    function totalSupply() 
        public 
        view 
        returns (uint256) 
    {
        return allTokens.length;
    }

     
    function tokenByIndex(uint256 _index) 
        public 
        view 
        returns (uint256) 
    {
        require(_index < totalSupply());
        return allTokens[_index];
    }

     
    function _setTokenURI(uint256 _tokenId, string _uri) 
        internal 
    {
        require(exists(_tokenId));
        tokenURIs[_tokenId] = _uri;
    }

     
    function addTokenTo(address _to, uint256 _tokenId) 
        internal 
    {
        super.addTokenTo(_to, _tokenId);
        uint256 length = ownedTokens[_to].length;
        ownedTokens[_to].push(_tokenId);
        ownedTokensIndex[_tokenId] = length;
    }

     
    function removeTokenFrom(address _from, uint256 _tokenId) 
        internal
    {
        super.removeTokenFrom(_from, _tokenId);

        uint256 tokenIndex = ownedTokensIndex[_tokenId];
        uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
        uint256 lastToken = ownedTokens[_from][lastTokenIndex];

        ownedTokens[_from][tokenIndex] = lastToken;
        ownedTokens[_from][lastTokenIndex] = 0;
         
         
         

        ownedTokens[_from].length--;
        ownedTokensIndex[_tokenId] = 0;
        ownedTokensIndex[lastToken] = tokenIndex;
    }

     
    function _mint(address _to, uint256 _tokenId) 
        internal 
    {
        super._mint(_to, _tokenId);

        allTokensIndex[_tokenId] = allTokens.length;
        allTokens.push(_tokenId);
    }

     
    function _burn(address _owner, uint256 _tokenId) 
        internal 
    {
        super._burn(_owner, _tokenId);

         
        if (bytes(tokenURIs[_tokenId]).length != 0) {
            delete tokenURIs[_tokenId];
        }

         
        uint256 tokenIndex = allTokensIndex[_tokenId];
        uint256 lastTokenIndex = allTokens.length.sub(1);
        uint256 lastToken = allTokens[lastTokenIndex];

        allTokens[tokenIndex] = lastToken;
        allTokens[lastTokenIndex] = 0;

        allTokens.length--;
        allTokensIndex[_tokenId] = 0;
        allTokensIndex[lastToken] = tokenIndex;
    }
}

contract BP is ERC721Token {

     
    mapping(uint256 => address) tokenMaker;
     
    mapping(address => uint256) makedTokensCount;
     
    mapping(address => uint256[]) makedTokens;
     
    mapping(uint256 => uint256) makedTokensIndex;




    constructor(string _name, string _symbol)
        public
        ERC721Token(_name, _symbol)
    {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

     
    function amountsOf(address _maker) 
        public
        view 
        returns (uint256) 
    {
        require(_maker != address(0));
        return makedTokensCount[_maker];
    }

     
    function makerOf(uint256 _tokenId) 
        public 
        view 
        returns (address) 
    {
        address maker = tokenMaker[_tokenId];
        return maker;
    }


     
    function tokenOfMakerByIndex(
        address _maker,
        uint256 _index
    )
        public
        view
        returns (uint256)
    {
        require(_index < amountsOf(_maker));
        return makedTokens[_maker][_index];
    }


     
    function mint(address _to, uint256 _tokenId, address _maker) 
        public
        onlyAdmins
    {
        super._mint(_to, _tokenId);
        tokenMaker[_tokenId] = _maker;
        makedTokensCount[_maker] = makedTokensCount[_maker].add(1);
        makedTokens[_maker].push(_tokenId);
        makedTokensIndex[_tokenId] = makedTokens[_maker].length.sub(1);
    }

     
    function burn(address _owner, uint256 _tokenId, address _maker) 
        public
        onlyAdmins 
    {
        super._burn(_owner, _tokenId);

        require(makerOf(_tokenId) == _maker);
        makedTokensCount[_maker] = makedTokensCount[_maker].sub(1);
        tokenMaker[_tokenId] = address(0);

        uint256 _makerTokenIndex = makedTokensIndex[_tokenId];
        uint256 _makerLastTokenIndex = makedTokens[_maker].length.sub(1);
        uint256 _makerLastToken = makedTokens[_maker][_makerLastTokenIndex];
        makedTokens[_maker][_makerTokenIndex] = _makerLastToken;
        makedTokens[_maker][_makerLastTokenIndex] = 0;
        makedTokens[_maker].length--;
        makedTokensIndex[_tokenId] = 0;
        makedTokensIndex[_makerLastToken] = _makerTokenIndex;
    }
}