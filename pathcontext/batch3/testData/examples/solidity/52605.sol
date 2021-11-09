pragma solidity ^0.4.23;

contract Config {
    uint256 internal increaseLimit1 = 0.02  ether;
    uint256 internal increaseLimit2 = 0.5  ether;
    uint256 internal increaseLimit3 = 2.0  ether;
    uint256 internal increaseLimit4 = 5.0  ether;  

    uint256 internal initPrice = 0.01 ether;

    uint256 internal period = 3600 * 24 * 30;

    uint256 internal devCut1 = 5;
    uint256 internal devCut2 = 4;
    uint256 internal devCut3 = 3;
    uint256 internal devCut4 = 2;
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

     
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}


 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


 
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes data) public;
}


 
contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}


 
contract IERC721Receiver {
     
    function onERC721Received(address operator, address from, uint256 tokenId, bytes data) public returns (bytes4);
}


 
contract IERC721Metadata is IERC721 {
    function name() external view returns (string);
    function symbol() external view returns (string);
    function tokenURI(uint256 tokenId) external view returns (string);
}


 
contract ERC165 is IERC165 {
    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;
     

     
    mapping(bytes4 => bool) private _supportedInterfaces;

     
    constructor () internal {
        _registerInterface(_InterfaceId_ERC165);
    }

     
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

     
    function _registerInterface(bytes4 interfaceId) internal {
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
     

    constructor () public {
         
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

     
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

     
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId));

        _transferFrom(from, to, tokenId);
    }

     
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
         
        safeTransferFrom(from, to, tokenId, "");
    }

     
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes _data) public {
        transferFrom(from, to, tokenId);
         
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

     
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

     
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
         
         
         
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

     
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0));
        _addTokenTo(to, tokenId);
        emit Transfer(address(0), to, tokenId);
    }

     
    function _burn(address owner, uint256 tokenId) internal {
        _clearApproval(tokenId);
        _removeTokenFrom(owner, tokenId);
        emit Transfer(owner, address(0), tokenId);
    }

     
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
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

     
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from);
        require(to != address(0));

        _clearApproval(tokenId);

        _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

     
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes _data) internal returns (bool) {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

     
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}


 
contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {
     
    mapping(address => uint256[]) private _ownedTokens;

     
    mapping(uint256 => uint256) private _ownedTokensIndex;

     
    uint256[] internal _allTokens;

     
    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _InterfaceId_ERC721Enumerable = 0x780e9d63;
     

     
    constructor () public {
         
        _registerInterface(_InterfaceId_ERC721Enumerable);
    }

     
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
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

        _addTokenToOwnerEnumeration(to, tokenId);
    }

     
    function _removeTokenFrom(address from, uint256 tokenId) internal {
        super._removeTokenFrom(from, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

         
         
        _ownedTokensIndex[tokenId] = 0;
    }

     
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
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

     
    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _ownedTokens[owner];
    }

     
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 newOwnedTokensLength = _ownedTokens[to].push(tokenId);
         
        _ownedTokensIndex[tokenId] = newOwnedTokensLength - 1;
    }

     
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
         
         

        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        _ownedTokens[from][tokenIndex] = lastTokenId;  
        _ownedTokensIndex[lastTokenId] = tokenIndex;  

         
         
         

         
        _ownedTokens[from].length--;

         
         
    }
}


contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
     
    string private _name;

     
    string private _symbol;

     
    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
     

     
    constructor (string name, string symbol) public {
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


 
contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {
}


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}


 
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

     
    function paused() public view returns (bool) {
        return _paused;
    }

     
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

     
    modifier whenPaused() {
        require(_paused);
        _;
    }

     
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

     
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}


 
contract ERC721Pausable is ERC721, Pausable {
    function approve(address to, uint256 tokenId) public whenNotPaused {
        super.approve(to, tokenId);
    }

    function setApprovalForAll(address to, bool approved) public whenNotPaused {
        super.setApprovalForAll(to, approved);
    }

    function transferFrom(address from, address to, uint256 tokenId) public whenNotPaused {
        super.transferFrom(from, to, tokenId);
    }
}


contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}


 
contract ERC721Mintable is ERC721, MinterRole {
     
    function mint(address to, uint256 tokenId) internal onlyMinter returns (bool) {
        _mint(to, tokenId);
        return true;
    }
}


contract ERC721Holder is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes) public returns (bytes4) {
        return this.onERC721Received.selector;
    }
}


contract Cryptomeetup is ERC721Full, ERC721Pausable, ERC721Mintable, ERC721Holder, Config {
    mapping (uint256 => uint256) private priceOf;

    struct Global {
        uint256 begin;
        uint256 end;
        address lastone;
    }

    mapping(uint256 => Global) global; 
    uint256 indexOfGlobal;

    event Bought(uint256 indexed _itemId, address indexed _owner, uint256 _price);
    event Sold(uint256 indexed _itemId, address indexed _owner, uint256 _price);    

    constructor() ERC721Metadata("cryptomeetup", "CMU") public {
    }

    function transferERC721Token(address contractaddr, uint256 tokenId) public onlyMinter {
        require(contractaddr.isContract());
        IERC721 _tokenobj = IERC721(contractaddr);
        _tokenobj.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function transferERC20Token(address contractaddr) public onlyMinter {
        require(contractaddr.isContract());
        IERC20 _tokenobj = IERC20(contractaddr);
        uint256 _amount = _tokenobj.balanceOf(address(this));
        _tokenobj.transfer(msg.sender, _amount);
    }

    function mint(address to, uint256 tokenId, uint256 tokenprice) public onlyMinter returns (bool) {
        mint(to, tokenId);
        priceOf[tokenId] = tokenprice;
        return true;
    }

    function init(uint256 l, uint256 r, uint256 price) public onlyMinter {
        for(uint256 i = l; i < r; i++) {
            mint(msg.sender, i, price);
        }

        indexOfGlobal = 1;
        global[indexOfGlobal].begin = now;
        global[indexOfGlobal].end = now.add(period);
        global[indexOfGlobal].lastone = address(0);
    }

    function calculateDevCut(uint256 price) public view returns (uint256 _devCut) {
        if (price < increaseLimit1) {
            return price.mul(devCut1).div(100);  
        } else if (price < increaseLimit2) {
            return price.mul(devCut2).div(100);  
        } else if (price < increaseLimit3) {
            return price.mul(devCut3).div(100);  
        } else if (price < increaseLimit4) {
            return price.mul(devCut3).div(100);  
        } else {
            return price.mul(devCut4).div(100);  
        }
    }

    function calculateNextPrice(uint256 _price) public view returns (uint256 _nextPrice) {
        if (_price < increaseLimit1) {
            return _price.mul(200).div(95);
        } else if (_price < increaseLimit2) {
            return _price.mul(135).div(96);
        } else if (_price < increaseLimit3) {
            return _price.mul(125).div(97);
        } else if (_price < increaseLimit4) {
            return _price.mul(117).div(97);
        } else {
            return _price.mul(115).div(98);
        }
    }  

    function nextPriceOf(uint256 tokenID) public view returns (uint256) {
        return calculateNextPrice(priceOfToken(tokenID));
    }    

    function buy(uint256 tokenId) payable public {
        require(priceOfToken(tokenId) > 0);
        require(ownerOf(tokenId) != address(0));        

        if(global[indexOfGlobal].end <= now) {
            newGlobal();
            buyinternal(tokenId, msg.sender, msg.value);
        } else {
            buyinternal(tokenId, msg.sender, msg.value);
        }
    }

    function buyinternal(uint256 tokenId, address payer, uint256 amount)  internal {
        require(priceOfToken(tokenId) > 0);
        require(ownerOf(tokenId) != address(0));
        require(amount >= priceOfToken(tokenId));
        require(ownerOf(tokenId) != payer);
        require(!payer.isContract());
        require(payer != address(0));
        require(global[indexOfGlobal].end > now);

        address oldOwner = ownerOf(tokenId);
        address newOwner = payer;
        uint256 price = priceOfToken(tokenId);
        uint256 excess = amount.sub(price);

        _transferFrom(oldOwner, newOwner, tokenId);
        priceOf[tokenId] = nextPriceOf(tokenId);

        emit Bought(tokenId, newOwner, price);
        emit Sold(tokenId, oldOwner, price);

         
         
        uint256 devCut = calculateDevCut(price);

         
        oldOwner.transfer(price.sub(devCut));

        if (excess > 0) {
            newOwner.transfer(excess);
        }

    }

    function newGlobal() internal {
        for (uint256 i = 1; i <= _allTokens.length; i++) {
            priceOf[i] = initPrice;
        }
        indexOfGlobal++;
        global[indexOfGlobal].begin = now;
        global[indexOfGlobal].end = now.add(period);
        global[indexOfGlobal].lastone = address(0);
    }


     
     
    function withdrawAll() onlyMinter public {
        msg.sender.transfer(address(this).balance);
    }

    function withdrawAmount(uint256 _amount) onlyMinter public {
        msg.sender.transfer(_amount);
    }

    function priceOfToken(uint256 tokenID) public view returns (uint256) {
        return priceOf[tokenID];
    }    

    function allOf (uint256 _itemId) external view returns (address _owner, uint256 _price, uint256 _nextPrice) {
        return (ownerOf(_itemId), priceOfToken(_itemId), nextPriceOf(_itemId));
    }

    function getIndexOfGlobal() public view returns(uint256) {
        return indexOfGlobal;
    }

    function getGlobal(uint256 index) public view returns(uint256 _begin, uint256 _end, address _lastone) {
        require(index <= indexOfGlobal);

        _begin = global[index].begin;
        _end = global[index].end;
        _lastone = global[index].lastone;
    }

    function getNowGlobal() public view returns(uint256, uint256, address) {
        getGlobal(indexOfGlobal);
    }
}