 

pragma solidity ^0.5.0;

 
contract Context {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity ^0.5.0;

 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

pragma solidity 0.5.10;

interface IPosition {
    event PositionCreated(
        address indexed position,
        address indexed seller,
        uint256 indexed tokenId,
        uint256 price,
        address tokenAddress,
        address marketPlaceAddress,
        uint256 timestamp
    );

    event PositionBought(
        address indexed position,
        address indexed seller,
        uint256 indexed tokenId,
        uint256 tokenAddress,
        uint256 price,
        address buyer,
        uint256 mktFee,
        uint256 sellerProfit,
        uint256 timestamp
    );

    function init(
        address payable _seller,
        uint256 _MPFee,
        uint256 _price,
        address _tokenAddress,
        uint256 _tokenId,
        address payable _marketPlaceAddress
    ) external returns (bool);

    function isTemplateContract() external view returns (bool);

    function buyPosition() external payable;
}

 

pragma solidity 0.5.10;

interface IPositionDispatcher {
    event PositionDispatcherCreated(
        address indexed positionDispatcher,
        uint256 timestamp,
        address mpAddress,
        uint256 mpFee
    );
    event UpdateMPFee(address indexed positionDispatcher, uint256 newFee);
    event PositionOpened(
        address indexed positionDispatcher,
        address indexed newPosition,
        uint256 timestamp,
        address seller,
        address tokenAddress,
        uint256 tokenId,
        address marketPlaceAddress,
        uint256 price
    );
    event UpdateMPAddress(address indexed positionDispatcher, address mkpAddress);
    event UpdatedPositionContract(address indexed positionDispatcher, address positionContract);

    function updateMarketPlaceAddress(address payable newMarketPlaceAddress) external;

    function updateMPFee(uint256 newFee) external;

    function setPositionTemplate(address newPositionTemplate) external;

    function createPosition(
        uint256 price,
        address tokenAddress,
        uint256 tokenId
    ) external returns (address);

    function isAddressAPosition(address positionAddress) external view returns (bool);

    function isCloned(address target, address query) external view returns (bool result);
}

 

pragma solidity 0.5.10;

interface I721Kitty {
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function kittyIndexToApproved(uint256 tokenId) external view returns (address owner);
     
}

interface I721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
}

interface I721Meta {
    function symbol() external view returns (string memory);
}
library Wrapper721 {
    function safeTransferFrom(address _token, address _from, address _to, uint256 _tokenId)
        external
    {
        if (isIssuedToken(_token)) {
            I721Kitty(_token).transferFrom(_from, _to, _tokenId);
        } else {
            I721(_token).safeTransferFrom(_from, _to, _tokenId);
        }

    }
    function getApproved(address _token, uint256 _tokenId) external view returns (address) {
        if (isIssuedToken(_token)) {
            return I721Kitty(_token).kittyIndexToApproved(_tokenId);
        } else {
            return I721(_token).getApproved(_tokenId);
        }
    }
    function ownerOf(address _token, uint256 _tokenId) public view returns (address owner) {
        if (isIssuedToken(_token)) {
            return I721Kitty(_token).ownerOf(_tokenId);
        } else {
            return I721(_token).ownerOf(_tokenId);
        }
    }
    function isIssuedToken(address _token) private view returns (bool) {
        return (keccak256(abi.encodePacked((I721Meta(_token).symbol()))) ==
            keccak256(abi.encodePacked(("CK"))));
    }

}

 

pragma solidity 0.5.10;

 
 
 

contract CloneFactory {
    function createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
    }

    function isClone(address target, address query) internal view returns (bool result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
            mstore(add(clone, 0xa), targetBytes)
            mstore(
                add(clone, 0x1e),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )

            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
                eq(mload(clone), mload(other)),
                eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
    }
}

 

pragma solidity 0.5.10;






contract PositionDispatcher is IPositionDispatcher, CloneFactory, Ownable {
    uint256 public contractCreated;
    uint256 public MPFee;

    address payable public marketPlaceAddress;
    address public positionTemplate;

    mapping(address => bool) public isPosition;

    event PositionDispatcherCreated(
        address indexed positionDispatcher,
        uint256 timestamp,
        address mpAddress,
        uint256 mpFee
    );
    event UpdateMPFee(address indexed positionDispatcher, uint256 newFee);
    event PositionOpened(
        address indexed positionDispatcher,
        address indexed newPosition,
        uint256 timestamp,
        address seller,
        address tokenAddress,
        uint256 tokenId,
        address marketPlaceAddress,
        uint256 price
    );
    event UpdateMPAddress(address indexed positionDispatcher, address mkpAddress);
    event UpdatedPositionContract(address indexed positionDispatcher, address positionContract);

    constructor() public {
        contractCreated = block.timestamp;
        marketPlaceAddress = 0x4f86A75764710683DAC3833dF49c72de3ec65465;
        MPFee = 1e18;
        emit PositionDispatcherCreated(address(this), block.timestamp, marketPlaceAddress, MPFee);
    }

    function updateMarketPlaceAddress(address payable newMarketPlaceAddress) external onlyOwner {
        marketPlaceAddress = newMarketPlaceAddress;
        emit UpdateMPAddress(address(this), marketPlaceAddress);
    }

    function updateMPFee(uint256 newFee) external onlyOwner {
        MPFee = newFee;
        emit UpdateMPFee(address(this), newFee);
    }

    function setPositionTemplate(address newPositionTemplate) external onlyOwner {
        positionTemplate = newPositionTemplate;
        emit UpdatedPositionContract(address(this), positionTemplate);
    }

    function createPosition(
        uint256 price,
        address tokenAddress,
        uint256 tokenId
    ) external returns (address) {
        require(
            sellerIsTokenOwner(msg.sender, tokenAddress, tokenId),
            "Seller is not the token owner"
        );

        require(positionTemplate != address(0), "position contract needs to be set");

        address positionContract = createClone((positionTemplate));

        require(
            IPosition(positionContract).init(
                msg.sender,
                MPFee,
                price,
                tokenAddress,
                tokenId,
                marketPlaceAddress
            ),
            "Failed to init position"
        );

        isPosition[positionContract] = true;

        emit PositionOpened(
            address(this),
            positionContract,
            block.timestamp,
            msg.sender,
            tokenAddress,
            tokenId,
            marketPlaceAddress,
            price
        );

        return positionContract;
    }

    function isAddressAPosition(address positionAddress) external view returns (bool) {
        return isPosition[positionAddress];
    }

    function sellerIsTokenOwner(
        address seller,
        address tokenAddress,
        uint256 tokenId
    ) internal view returns (bool) {
        address tokenOwner = Wrapper721.ownerOf(tokenAddress, tokenId);
        return tokenOwner == seller;
    }

    function isCloned(address target, address query) external view returns (bool result) {
        return isClone(target, query);
    }
}