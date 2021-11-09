pragma solidity ^0.4.24;

contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Ownable() public {
        owner = msg.sender; 
    }

     
    function transferTo(address _to) public onlyOwner returns (bool) {
        require(_to != address(0));
        owner = _to;
        return true;
    } 
} 

contract BytesUtils {
    function readBytes32(bytes data, uint256 index) internal pure returns (bytes32 o) {
        require(data.length / 32 > index);
        assembly {
            o := mload(add(data, add(32, mul(32, index))))
        }
    }
}

interface IERC721Receiver {
    function onERC721Received(
        address _oldOwner,
        uint256 _tokenId,
        bytes   _userData
    ) external returns (bytes4);
}

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x + y;
        require((z >= x) && (z >= y));
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns(uint256) {
        require(x >= y);
        uint256 z = x - y;
        return z;
    }

    function mult(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x * y;
        require((x == 0)||(z/x == y));
        return z;
    }
}

contract ERC721Base {
    using SafeMath for uint256;

    uint256 private _count;

    mapping(uint256 => address) private _holderOf;
    mapping(address => uint256[]) private _assetsOf;
    mapping(address => mapping(address => bool)) private _operators;
    mapping(uint256 => address) private _approval;
    mapping(uint256 => uint256) private _indexOfAsset;

    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

     
     
     

     
    function totalSupply() external view returns (uint256) {
        return _totalSupply();
    }
    function _totalSupply() internal view returns (uint256) {
        return _count;
    }

     
     
     

     
    function ownerOf(uint256 assetId) external view returns (address) {
        return _ownerOf(assetId);
    }
    function _ownerOf(uint256 assetId) internal view returns (address) {
        return _holderOf[assetId];
    }

    function assetsOf(address owner) external view returns (uint256[]) {
        return _assetsOf[owner];
    }

     
     
     
     
     
     
     
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {
        return _assetsOf[_owner][_index];
    }

     
     
     
     
    function balanceOf(address owner) external view returns (uint256) {
        return _balanceOf(owner);
    }
    function _balanceOf(address owner) internal view returns (uint256) {
        return _assetsOf[owner].length;
    }

     
     
     

     
    function isApprovedForAll(address operator, address assetHolder)
        external view returns (bool)
    {
        return _isApprovedForAll(operator, assetHolder);
    }
    function _isApprovedForAll(address operator, address assetHolder)
        internal view returns (bool)
    {
        return _operators[assetHolder][operator];
    }

     
    function getApprovedAddress(uint256 assetId) external view returns (address) {
        return _getApprovedAddress(assetId);
    }
    function _getApprovedAddress(uint256 assetId) internal view returns (address) {
        return _approval[assetId];
    }

     
    function isAuthorized(address operator, uint256 assetId) external view returns (bool) {
        return _isAuthorized(operator, assetId);
    }
    function _isAuthorized(address operator, uint256 assetId) internal view returns (bool){
        require(operator != 0);
        address owner = _ownerOf(assetId);
        if (operator == owner) {
            return true;
        }
        return _isApprovedForAll(operator, owner) || _getApprovedAddress(assetId) == operator;
    }

     
     
     

     
    function setApprovalForAll(address operator, bool authorized) external returns (bool) {
        return _setApprovalForAll(operator, authorized);
    }

    function _setApprovalForAll(address operator, bool authorized) internal returns (bool) {
        if (authorized) {
            require(!_isApprovedForAll(operator, msg.sender));
            _addAuthorization(operator, msg.sender);
        } else {
            require(_isApprovedForAll(operator, msg.sender));
            _clearAuthorization(operator, msg.sender);
        }
        emit ApprovalForAll(operator, msg.sender, authorized);
        return true;
    }

    function _addAuthorization(address operator, address holder) private {
        _operators[holder][operator] = true;
    }

    function _clearAuthorization(address operator, address holder) private {
        _operators[holder][operator] = false;
    }

     
    function approve(address operator, uint256 assetId) external returns (bool) {
        address holder = _ownerOf(assetId);
        require(msg.sender == holder || _isApprovedForAll(msg.sender, holder));
        if (_getApprovedAddress(assetId) != operator) {
            _approval[assetId] = operator;
            emit Approval(holder, operator, assetId);
        }
        return true;
    }

     
     
     

    function _addAssetTo(address to, uint256 assetId) internal {
        _holderOf[assetId] = to;

        uint256 length = _balanceOf(to);

        _assetsOf[to].push(assetId);

        _indexOfAsset[assetId] = length;

        _count = _count.add(1);
    }

    function _removeAssetFrom(address from, uint256 assetId) internal {
        uint256 assetIndex = _indexOfAsset[assetId];
        uint256 lastAssetIndex = _balanceOf(from).sub(1);
        uint256 lastAssetId = _assetsOf[from][lastAssetIndex];

        _holderOf[assetId] = 0;

         
        _assetsOf[from][assetIndex] = lastAssetId;

         
        _assetsOf[from][lastAssetIndex] = 0;
        _assetsOf[from].length--;

         
        if (_assetsOf[from].length == 0) {
            delete _assetsOf[from];
        }

         
        _indexOfAsset[assetId] = 0;
        _indexOfAsset[lastAssetId] = assetIndex;

        _count = _count.sub(1);
    }

    function _clearApproval(address holder, uint256 assetId) internal {
        if (_ownerOf(assetId) == holder && _approval[assetId] != 0) {
            _approval[assetId] = 0;
            emit Approval(holder, 0, assetId);
        }
    }

     
     
     

    function _generate(uint256 assetId, address beneficiary) internal {
        require(_holderOf[assetId] == 0);

        _addAssetTo(beneficiary, assetId);

        emit Transfer(0x0, beneficiary, assetId);
    }

    function _destroy(uint256 assetId) internal {
        address holder = _holderOf[assetId];
        require(holder != 0);

        _removeAssetFrom(holder, assetId);

        emit Transfer(holder, 0x0, assetId);
    }

     
     
     

    modifier onlyHolder(uint256 assetId) {
        require(_ownerOf(assetId) == msg.sender);
        _;
    }

    modifier onlyAuthorized(uint256 assetId) {
        require(_isAuthorized(msg.sender, assetId));
        _;
    }

    modifier isCurrentOwner(address from, uint256 assetId) {
        require(_ownerOf(assetId) == from);
        _;
    }

     
    function safeTransferFrom(address from, address to, uint256 assetId) external returns (bool) {
        return _doTransferFrom(from, to, assetId, "", true);
    }

     
    function safeTransferFrom(address from, address to, uint256 assetId, bytes userData) external returns (bool) {
        return _doTransferFrom(from, to, assetId, userData, true);
    }

     
    function transferFrom(address from, address to, uint256 assetId) external returns (bool) {
        return _doTransferFrom(from, to, assetId, "", false);
    }

    function _doTransferFrom(
        address from,
        address to,
        uint256 assetId,
        bytes userData,
        bool doCheck
    )
        onlyAuthorized(assetId)
        internal
        returns (bool)
    {
        _moveToken(from, to, assetId, userData, doCheck);
        return true;
    }

    function _moveToken(
        address from,
        address to,
        uint256 assetId,
        bytes userData,
        bool doCheck
    )
        isCurrentOwner(from, assetId)
        internal
    {
        address holder = _holderOf[assetId];
        _removeAssetFrom(holder, assetId);
        _clearApproval(holder, assetId);
        _addAssetTo(to, assetId);

        if (doCheck && _isContract(to)) {
             
            bytes4 ERC721_RECEIVED = bytes4(0xf0b9e5ba);
            require(
                IERC721Receiver(to).onERC721Received(
                    holder, assetId, userData
                ) == ERC721_RECEIVED
            );
        }

        emit Transfer(holder, to, assetId);
    }

     

     
    function supportsInterface(bytes4 _interfaceID) external view returns (bool) {

        if (_interfaceID == 0xffffffff) {
            return false;
        }
        return _interfaceID == 0x01ffc9a7 || _interfaceID == 0x80ac58cd;
    }

     
     
     

    function _isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}


interface ERC721 {
    function transferFrom(address from, address to, uint256 id) external;
    function ownerOf(uint256 id) external view returns (address);
}

contract Bundle is ERC721Base, BytesUtils {
    uint256 private constant MAX_UINT256 = uint256(0) - uint256(1);

    Package[] private packages;

    event Created(address owner, uint256 id);
    event Deposit(address sender, uint256 bundle, address token, uint256 id);
    event Withdraw(address retriever, uint256 bundle, address token, uint256 id);

    struct Package {
        address[] tokens;
        uint256[] ids;
        mapping(address => mapping(uint256 => uint256)) order;
    }

    constructor() public {
        packages.length++;
    }

    modifier canWithdraw(uint256 packageId) {
        require(_isAuthorized(msg.sender, packageId), "Not authorized for withdraw");
        _;
    }

    function canDeposit(uint256 packageId) public view returns (bool) {
        return _isAuthorized(msg.sender, packageId);
    }

     
    function content(uint256 id) external view returns (address[] tokens, uint256[] ids) {
        Package memory package = packages[id];
        tokens = package.tokens;
        ids = package.ids;
    }

     
     
    function create() public returns (uint256 id) {
        id = packages.length;
        packages.length++;
        emit Created(msg.sender, id);
        _generate(id, msg.sender);
    }

     
    function deposit(
        uint256 _packageId,
        ERC721 token,
        uint256 tokenId
    ) external returns (bool) {
        uint256 packageId = _packageId == 0 ? create() : _packageId;
        require(canDeposit(packageId), "Not authorized for deposit");
        return _deposit(packageId, token, tokenId);
    }

     
    function depositBatch(
        uint256 _packageId,
        ERC721[] tokens,
        uint256[] ids
    ) external returns (bool) {
        uint256 packageId = _packageId == 0 ? create() : _packageId;
        require(canDeposit(packageId), "Not authorized for deposit");

        require(tokens.length == ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            require(_deposit(packageId, tokens[i], ids[i]));
        }

        return true;
    }

     
    function withdraw(
        uint256 packageId,
        ERC721 token,
        uint256 tokenId,
        address to
    ) public canWithdraw(packageId) returns (bool) {
        return _withdraw(packageId, token, tokenId, to);
    }

     
    function withdrawBatch(
        uint256 packageId,
        ERC721[] tokens,
        uint256[] ids,
        address to
    ) external canWithdraw(packageId) returns (bool) {
        for (uint256 i = 0; i < tokens.length; i++) {
            require(_withdraw(packageId, tokens[i], ids[i], to));
        }

        return true;
    }

     
    function withdrawAll(
        uint256 packageId,
        address to
    ) external canWithdraw(packageId) returns (bool) {
        Package storage package = packages[packageId];
        uint256 i = package.ids.length - 1;

        for (;i != MAX_UINT256; i--) {
            require(_withdraw(packageId, ERC721(package.tokens[i]), package.ids[i], to));
        }

        return true;
    }

     
     
     

    function _deposit(
        uint256 packageId,
        ERC721 token,
        uint256 tokenId
    ) internal returns (bool) {
        token.transferFrom(msg.sender, address(this), tokenId);
        require(token.ownerOf(tokenId) == address(this), "ERC721 transfer failed");

        Package storage package = packages[packageId];
        _add(package, token, tokenId);

        emit Deposit(msg.sender, packageId, token, tokenId);

        return true;
    }

    function _withdraw(
        uint256 packageId,
        ERC721 token,
        uint256 tokenId,
        address to
    ) internal returns (bool) {
        Package storage package = packages[packageId];
        _remove(package, token, tokenId);
        emit Withdraw(msg.sender, packageId, token, tokenId);

        token.transferFrom(this, to, tokenId);
        require(token.ownerOf(tokenId) == to, "ERC721 transfer failed");

        return true;
    }

    function _add(
        Package storage package,
        ERC721 token,
        uint256 id
    ) internal {
        uint256 position = package.order[token][id];
        require(!_isAsset(package, position, token, id), "Already exist");
        position = package.tokens.length;
        package.tokens.push(token);
        package.ids.push(id);
        package.order[token][id] = position;
    }

    function _remove(
        Package storage package,
        ERC721 token,
        uint256 id
    ) internal {
        uint256 delPosition = package.order[token][id];
        require(_isAsset(package, delPosition, token, id), "The token does not exist inside the package");

         
         
        uint256 lastPosition = package.tokens.length - 1;
        if (lastPosition != delPosition) {
            address lastToken = package.tokens[lastPosition];
            uint256 lastId = package.ids[lastPosition];
            package.tokens[delPosition] = lastToken;
            package.ids[delPosition] = lastId;
            package.order[lastToken][lastId] = delPosition;
        }

         
        package.tokens.length--;
        package.ids.length--;
        delete package.order[token][id];
    }

    function _isAsset(
        Package memory package,
        uint256 position,
        address token,
        uint256 id
    ) internal pure returns (bool) {
        return position != 0 ||
            (package.ids.length != 0 && package.tokens[position] == token && package.ids[position] == id);
    }
}