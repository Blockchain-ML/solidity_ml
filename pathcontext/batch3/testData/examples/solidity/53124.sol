pragma solidity ^0.4.24;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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
contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes data) public returns (bytes4);
}

library SafeMath {
    int256 constant private INT256_MIN = -2**255;

 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
     
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

  
    function mul(int256 a, int256 b) internal pure returns (int256) {
       
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN));  

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        require(b > 0);
        uint256 c = a / b;
         

        return c;
    }

     
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0);  
        require(!(b == -1 && a == INT256_MIN));  

        int256 c = a / b;

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

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

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

     
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract AgriCultureContracts is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;

     
     
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

     
     
    struct AgriCultureContract {
        uint256 tokenId;
        uint64 creationDate;
        uint64 expirationDate;
         
    }
    AgriCultureContract[] acContracts;

     
    mapping (uint256 => address) private _tokenOwner;

     
    mapping (uint256 => address) private _tokenApprovals;

     
     
    mapping (address => AgriCultureContract[]) public _ownedTokens;

     
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;
     

    constructor () public {
         
        _registerInterface(_InterfaceId_ERC721);
    }
    
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0));
        return _ownedTokens[owner].length;
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

    function _isExpired(uint _tokenId) public view returns(bool) {
        require(_tokenId <= acContracts.length, "invalid token id");
        return now > acContracts[_tokenId].expirationDate;
    }

    function transfer(address _to, uint256 _tokenId) external {
        require(_exists(_tokenId));
        require(ownerOf(_tokenId) == msg.sender);
        require(_to != address(0));
        _transfer(msg.sender, _to, _tokenId);
    }
    
    function _createContract(address _owner, uint64 _expirationDate) public returns(uint256) {
        uint id = acContracts.length;
        AgriCultureContract memory c = AgriCultureContract(id, uint64(now), _expirationDate);
        acContracts.push(c);
        _transfer(address(0x0), _owner, id);
        return id;
    }
    

    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    } 

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        
        _tokenOwner[_tokenId] = _to;
        _ownedTokens[_to].push(acContracts[_tokenId]);

        if (_from != address(0)) {
            _removeContract(_from, _tokenId);            
        }
        emit Transfer(_from, _to, _tokenId);
    }

    function _removeContract(address _owner, uint _tokenId) internal {
        uint len = _ownedTokens[_owner].length;
        for (uint i=0; i<len; i++) {
            if(_ownedTokens[_owner][i].tokenId == _tokenId) {
                _ownedTokens[_owner][i] = _ownedTokens[_owner][len-1];
                delete _ownedTokens[_owner][len-1];
                break;
            }
        }
    }


    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from);
        require(to != address(0));
        require(!_isExpired(tokenId));

        _clearApproval(tokenId);
        _transfer(from, to, tokenId);
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
contract AgriCultureMeta is AgriCultureContracts, Ownable {

      
    string private _name;

     
    string private _symbol;

     
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => bytes) private _tokenMetas;

    bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
     

     
    constructor (string name, string symbol) AgriCultureContracts() public {
        _name = name;
        _symbol = symbol;

         
        _registerInterface(InterfaceId_ERC721Metadata);
    }

    function () payable public {
        createContractWithMeta(msg.sender, uint64(now), msg.data, string(msg.data));
    }

    function createContractWithMeta(address _to, uint64 _expirationDate, bytes _meta, string _tokenURI) public onlyOwner {
        uint id = _createContract(_to, _expirationDate);
        _setTokenURI(id, _tokenURI);
        _setTokenMeta(id, _meta);
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

    function tokenMeta(uint256 tokenId) external view returns (bytes) {
        require(_exists(tokenId));
        return _tokenMetas[tokenId];
    }

     
    function _setTokenURI(uint256 tokenId, string uri) internal {
        require(_exists(tokenId));
        _tokenURIs[tokenId] = uri;
    }

    function _setTokenMeta(uint256 tokenId, bytes meta) internal {
        require(_exists(tokenId));
        _tokenMetas[tokenId] = meta;
    }

}