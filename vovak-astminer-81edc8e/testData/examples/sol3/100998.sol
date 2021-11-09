 

 

pragma solidity >=0.6.0 <0.7.0;

interface IAMB {
    function messageSender() external view returns (address);
    function maxGasPerTx() external view returns (uint256);
    function transactionHash() external view returns (bytes32);
    function messageId() external view returns (bytes32);
    function messageSourceChainId() external view returns (bytes32);
    function messageCallStatus(bytes32 _messageId) external view returns (bool);
    function failedMessageDataHash(bytes32 _messageId) external view returns (bytes32);
    function failedMessageReceiver(bytes32 _messageId) external view returns (address);
    function failedMessageSender(bytes32 _messageId) external view returns (address);
    function requireToPassMessage(address _contract, bytes calldata _data, uint256 _gas) external returns (bytes32);
}


 

pragma solidity >=0.6.0 <0.7.0;

interface ITokenManagement {

  function mint(address to, uint256 tokenId, string calldata inkUrl, string calldata jsonUrl) external returns (uint256);
  function fixFailedMessage(bytes32 _dataHash) external;

}


 

 

pragma solidity ^0.6.0;

 
contract Context {
     
     
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}


 

 

pragma solidity ^0.6.0;

 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


 

 

pragma solidity ^0.6.2;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


 

pragma solidity >=0.6.0 <0.7.0;





contract AMBMediator is Ownable {
    using Address for address;

    constructor() public {
    }

    address public bridgeContractAddress;
    address private otherSideContractAddress;
    uint256 public requestGasLimit;

    mapping (bytes32 => bool) public messageFixed;

    function setBridgeContract(address _bridgeContract) external onlyOwner {
        _setBridgeContract(_bridgeContract);
    }

    function _setBridgeContract(address _bridgeContract) internal {
        require(_bridgeContract.isContract(), 'provided address is not a contract');
        bridgeContractAddress = _bridgeContract;
    }

    function bridgeContract() public view returns (IAMB) {
        return IAMB(bridgeContractAddress);
    }

    function setMediatorContractOnOtherSide(address _mediatorContract) external onlyOwner {
        _setMediatorContractOnOtherSide(_mediatorContract);
    }

    function _setMediatorContractOnOtherSide(address _mediatorContract) internal {
        otherSideContractAddress = _mediatorContract;
    }

    function mediatorContractOnOtherSide() public view returns (address) {
        return otherSideContractAddress;
    }

    function setRequestGasLimit(uint256 _requestGasLimit) external onlyOwner {
        _setRequestGasLimit(_requestGasLimit);
    }

    function _setRequestGasLimit(uint256 _requestGasLimit) internal {
        require(_requestGasLimit <= bridgeContract().maxGasPerTx(),'gas limit is higher than the Bridge maximum');
        requestGasLimit = _requestGasLimit;
    }

     
    function messageSender() internal view returns (address) {
        return bridgeContract().messageSender();
    }

     
    function messageId() internal view returns (bytes32) {
        return bridgeContract().messageId();
    }


    function setMessageFixed(bytes32 _txHash) internal {
        messageFixed[_txHash] = true;
    }

    function requestFailedMessageFix(bytes32 _txHash) external {
        require(!bridgeContract().messageCallStatus(_txHash));
        require(bridgeContract().failedMessageReceiver(_txHash) == address(this));
        require(bridgeContract().failedMessageSender(_txHash) == mediatorContractOnOtherSide());
        bytes32 dataHash = bridgeContract().failedMessageDataHash(_txHash);

        bytes4 methodSelector = ITokenManagement(address(0)).fixFailedMessage.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, dataHash);
        bridgeContract().requireToPassMessage(mediatorContractOnOtherSide(), data, requestGasLimit);
    }

}


 

 

pragma solidity ^0.6.0;

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
         
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


 

 

pragma solidity ^0.6.0;


 
library Counters {
    using SafeMath for uint256;

    struct Counter {
         
         
         
        uint256 _value;  
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
         
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}


 

 
 

pragma solidity ^0.6.2;


library LibBytesRichErrorsV06 {

    enum InvalidByteOperationErrorCodes {
        FromLessThanOrEqualsToRequired,
        ToLessThanOrEqualsLengthRequired,
        LengthGreaterThanZeroRequired,
        LengthGreaterThanOrEqualsFourRequired,
        LengthGreaterThanOrEqualsTwentyRequired,
        LengthGreaterThanOrEqualsThirtyTwoRequired,
        LengthGreaterThanOrEqualsNestedBytesLengthRequired,
        DestinationLengthGreaterThanOrEqualSourceLengthRequired
    }

     
    bytes4 internal constant INVALID_BYTE_OPERATION_ERROR_SELECTOR =
        0x28006595;

     
    function InvalidByteOperationError(
        InvalidByteOperationErrorCodes errorCode,
        uint256 offset,
        uint256 required
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INVALID_BYTE_OPERATION_ERROR_SELECTOR,
            errorCode,
            offset,
            required
        );
    }
}


 

 
 

pragma solidity ^0.6.2;


library LibRichErrorsV06 {

     
    bytes4 internal constant STANDARD_ERROR_SELECTOR = 0x08c379a0;

     
     
     
     
     
     
    function StandardError(string memory message)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            STANDARD_ERROR_SELECTOR,
            bytes(message)
        );
    }
     

     
     
    function rrevert(bytes memory errorData)
        internal
        pure
    {
        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }
}


 

 
 

pragma solidity ^0.6.2;




library LibBytesV06 {

    using LibBytesV06 for bytes;

     
     
     
     
     
    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }

     
     
     
    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

     
     
     
     
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {
        if (length < 32) {
             
             
             
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
             
            if (source == dest) {
                return;
            }

             
             
             
             
             
             
             
             
             
             
             
             
             
             
             
            if (source > dest) {
                assembly {
                     
                     
                     
                     
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                     
                     
                     
                     
                    let last := mload(sEnd)

                     
                     
                     
                     
                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                     
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                     
                     
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                     
                     
                     
                     
                    let first := mload(source)

                     
                     
                     
                     
                     
                     
                     
                     
                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                     
                    mstore(dest, first)
                }
            }
        }
    }

     
     
     
     
     
    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
         
         
        if (from > to) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

         
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }

     
     
     
     
     
     
     
    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
         
         
        if (from > to) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

         
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

     
     
     
    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        if (b.length == 0) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanZeroRequired,
                b.length,
                0
            ));
        }

         
        result = b[b.length - 1];

        assembly {
             
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

     
     
     
     
    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
         
         
         
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

     
     
     
     
    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        if (b.length < index + 20) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20  
            ));
        }

         
         
         
        index += 20;

         
        assembly {
             
             
             
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

     
     
     
     
    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    )
        internal
        pure
    {
        if (b.length < index + 20) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20  
            ));
        }

         
         
         
        index += 20;

         
        assembly {
             
             
             
             

             
             
             
            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )

             
             
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

             
            mstore(add(b, index), xor(input, neighbors))
        }
    }

     
     
     
     
    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        if (b.length < index + 32) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

         
        index += 32;

         
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

     
     
     
     
    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    )
        internal
        pure
    {
        if (b.length < index + 32) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

         
        index += 32;

         
        assembly {
            mstore(add(b, index), input)
        }
    }

     
     
     
     
    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

     
     
     
     
    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
    }

     
     
     
     
    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        if (b.length < index + 4) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsFourRequired,
                b.length,
                index + 4
            ));
        }

         
        index += 32;

         
        assembly {
            result := mload(add(b, index))
             
             
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

     
     
     
     
     
    function writeLength(bytes memory b, uint256 length)
        internal
        pure
    {
        assembly {
            mstore(b, length)
        }
    }
}


 

 
pragma solidity ^0.6.2;

 
abstract contract IRelayRecipient {

     
    function isTrustedForwarder(address forwarder) public virtual view returns(bool);

     
    function _msgSender() internal virtual view returns (address payable);

    function versionRecipient() external virtual view returns (string memory);
}


 

 
pragma solidity ^0.6.2;



 
abstract contract BaseRelayRecipient is IRelayRecipient {

     
     
    address internal trustedForwarder;

     
    modifier trustedForwarderOnly() {
        require(msg.sender == address(trustedForwarder), "Function can only be called through trustedForwarder");
        _;
    }

    function isTrustedForwarder(address forwarder) public override view returns(bool) {
        return forwarder == trustedForwarder;
    }

     
    function _msgSender() internal override virtual view returns (address payable) {
        if (msg.data.length >= 24 && isTrustedForwarder(msg.sender)) {
             
             
             
            return address(uint160(LibBytesV06.readAddress(msg.data, msg.data.length - 20)));
        }
        return msg.sender;
    }
}


 

 

pragma solidity ^0.6.0;

 
library EnumerableSet {
     
     
     
     
     
     
     
     

    struct Set {
         
        bytes32[] _values;

         
         
        mapping (bytes32 => uint256) _indexes;
    }

     
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
             
             
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

     
    function _remove(Set storage set, bytes32 value) private returns (bool) {
         
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {  
             
             
             

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

             
             

            bytes32 lastvalue = set._values[lastIndex];

             
            set._values[toDeleteIndex] = lastvalue;
             
            set._indexes[lastvalue] = toDeleteIndex + 1;  

             
            set._values.pop();

             
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

     
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

     
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

     

    struct AddressSet {
        Set _inner;
    }

     
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

     
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

     
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

     
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


     

    struct UintSet {
        Set _inner;
    }

     
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

     
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

     
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

     
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}


 

 

pragma solidity ^0.6.0;

 
library ECDSA {
     
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
         
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

         
        bytes32 r;
        bytes32 s;
        uint8 v;

         
         
         
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

         
         
         
         
         
         
         
         
         
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

         
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

     
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
         
         
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


 

 
pragma solidity >=0.5.0 <0.7.0;

 
interface IERC1271 {

 
 

     
    function isValidSignature(
        bytes32 _hash,  
        bytes calldata _signature
    )
    external
    view
    returns (bytes4 magicValue);
}


 

pragma solidity >=0.6.0 <0.7.0;





contract SignatureChecker is Ownable {
    using ECDSA for bytes32;
    using Address for address;
    bool public checkSignatureFlag;

    bytes4 internal constant _INTERFACE_ID_ERC1271 = 0x1626ba7e;
    bytes4 internal constant _ERC1271FAILVALUE = 0xffffffff;

    function setCheckSignatureFlag(bool newFlag) public onlyOwner {
      checkSignatureFlag = newFlag;
    }

    function getSigner(bytes32 signedHash, bytes memory signature) public pure returns (address)
    {
        return signedHash.toEthSignedMessageHash().recover(signature);
    }

    function checkSignature(bytes32 signedHash, bytes memory signature, address checkAddress) public view returns (bool) {
      if(checkAddress.isContract()) {
        return IERC1271(checkAddress).isValidSignature(signedHash, signature) == _INTERFACE_ID_ERC1271;
      } else {
        return getSigner(signedHash, signature) == checkAddress;
      }
    }

}


 

pragma solidity >=0.6.0 <0.7.0;







contract Liker is Ownable, BaseRelayRecipient, SignatureChecker {
  using ECDSA for bytes32;
  using Counters for Counters.Counter;
  using EnumerableSet for EnumerableSet.UintSet;
  using SafeMath for uint256;

  Counters.Counter public totalLikes;

  event liked(uint256 LikeId, address targetContract, uint256 target, uint256 targetId, address liker);
  event contractAdded(address targetContract, address contractOwner);
  event contractRemoved(address targetContract, address contractOwner);

  struct Like {
    uint256 id;
    address liker;
    uint256 targetId;
    address contractAddress;
    uint256 target;
    bool exists;
  }

  EnumerableSet.UintSet private likeIds;
  mapping(address => bool) public registeredContracts;
  mapping(address => address) public contractOwner;
  mapping(uint256 => Like) private likeById;
  mapping(address => EnumerableSet.UintSet) private addressLikes;
  mapping(uint256 => EnumerableSet.UintSet) private targetLikes;
  mapping(address => EnumerableSet.UintSet) private contractLikes;

  function getTargetId(address contractAddress, uint256 target) public view returns (uint256) {
    return uint256(keccak256(
        abi.encodePacked(
            byte(0x19),
            byte(0),
            address(this),
            contractAddress,
            target
    )));
  }

  function _newLike(address contractAddress, uint256 target, address liker) internal returns (uint256) {
    require(registeredContracts[contractAddress],"this contract is not registered");
    uint256 targetId = getTargetId(contractAddress, target);
    uint256 likeId = uint256(keccak256(abi.encodePacked(byte(0x19),byte(0),address(this),contractAddress,target,liker)));
    require(!likeById[likeId].exists,"this like has already been liked");

    totalLikes.increment();

    Like memory _like = Like({
      id: likeId,
      liker: liker,
      targetId: targetId,
      contractAddress: contractAddress,
      target: target,
      exists: true
    });

    likeIds.add(likeId);
    likeById[likeId] = _like;
    addressLikes[liker].add(likeId);
    targetLikes[targetId].add(likeId);
    contractLikes[contractAddress].add(likeId);

    emit liked(likeId, contractAddress, target, targetId, liker);
  }

  function like(address contractAddress, uint256 target) public returns (uint256) {
    return _newLike(contractAddress, target, _msgSender());
  }

  function likeWithSignature(address contractAddress, uint256 target, address liker, bytes memory signature) public returns (uint256) {
    bytes32 messageHash = keccak256(abi.encodePacked(byte(0x19),byte(0),address(this),contractAddress,target,liker));
    bool isArtistSignature = checkSignature(messageHash, signature, liker);
    require(isArtistSignature || !checkSignatureFlag, "Unable to verify the artist signature");
    return _newLike(contractAddress, target, liker);
  }

  function checkLike(address contractAddress, uint256 target, address liker) public view returns (bool) {
    require(registeredContracts[contractAddress],"this contract is not registered");
    uint256 likeId = uint256(keccak256(abi.encodePacked(byte(0x19),byte(0),address(this),contractAddress,target,liker)));
    return likeById[likeId].exists;
  }

  function getLikeIdByIndex(uint256 index) public view returns (uint256) {
    return likeIds.at(index);
  }

  function getLikeInfoById(uint256 likeId) public view returns (uint256, address, uint256, address, uint256) {
    require(likeById[likeId].exists, 'like does not exist');
    Like storage _like = likeById[likeId];
    return (likeId, _like.liker, _like.targetId, _like.contractAddress, _like.target);
  }

  function getLikesByTargetId(uint256 targetId) public view returns (uint256) {
    return targetLikes[targetId].length();
  }

  function getLikesByTarget(address contractAddress, uint256 target) public view returns (uint256) {
    uint256 targetId = getTargetId(contractAddress, target);
    return targetLikes[targetId].length();
  }

  function getLikesByContract(address contractAddress) public view returns (uint256) {
    require(registeredContracts[contractAddress],"this contract is not registered");
    return contractLikes[contractAddress].length();
  }

  function getLikesByLiker(address liker) public view returns (uint256) {
    return addressLikes[liker].length();
  }

  function addContract(address contractAddress) public returns (bool) {
    require(!registeredContracts[contractAddress],"this contract is already registered");
    registeredContracts[contractAddress] = true;
    address _contractOwner = _msgSender();
    contractOwner[contractAddress] = _contractOwner;
    emit contractAdded(contractAddress, _contractOwner);
    return true;
  }

  function removeContract(address contractAddress) public returns (bool) {
    require(registeredContracts[contractAddress],"this contract is not registered");
    address _contractOwner = _msgSender();
    require(contractOwner[contractAddress] == _contractOwner, 'only the contract owner can remove');
    registeredContracts[contractAddress] = false;
    emit contractRemoved(contractAddress, _contractOwner);
    return false;
  }

  function versionRecipient() external virtual view override returns (string memory) {
    return "1.0";
  }

  function setTrustedForwarder(address _trustedForwarder) public onlyOwner {
    trustedForwarder = _trustedForwarder;
  }

  function getTrustedForwarder() public view returns(address) {
    return trustedForwarder;
  }

  function _msgSender() internal override(BaseRelayRecipient, Context) view returns (address payable) {
      return BaseRelayRecipient._msgSender();
  }
}


 

 

pragma solidity ^0.6.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


 

 

pragma solidity ^0.6.2;


 
interface IERC721 is IERC165 {
     
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

     
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

     
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

     
    function balanceOf(address owner) external view returns (uint256 balance);

     
    function ownerOf(uint256 tokenId) external view returns (address owner);

     
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

     
    function transferFrom(address from, address to, uint256 tokenId) external;

     
    function approve(address to, uint256 tokenId) external;

     
    function getApproved(uint256 tokenId) external view returns (address operator);

     
    function setApprovalForAll(address operator, bool _approved) external;

     
    function isApprovedForAll(address owner, address operator) external view returns (bool);

     
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}


 

 

pragma solidity ^0.6.2;


 
interface IERC721Metadata is IERC721 {

     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


 

 

pragma solidity ^0.6.2;


 
interface IERC721Enumerable is IERC721 {

     
    function totalSupply() external view returns (uint256);

     
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

     
    function tokenByIndex(uint256 index) external view returns (uint256);
}


 

 

pragma solidity ^0.6.0;

 
abstract contract IERC721Receiver {
     
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public virtual returns (bytes4);
}


 

 

pragma solidity ^0.6.0;


 
contract ERC165 is IERC165 {
     
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

     
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
         
         
        _registerInterface(_INTERFACE_ID_ERC165);
    }

     
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

     
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


 

 

pragma solidity ^0.6.0;

 
library EnumerableMap {
     
     
     
     
     
     
     
     

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
         
        MapEntry[] _entries;

         
         
        mapping (bytes32 => uint256) _indexes;
    }

     
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
         
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) {  
            map._entries.push(MapEntry({ _key: key, _value: value }));
             
             
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

     
    function _remove(Map storage map, bytes32 key) private returns (bool) {
         
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) {  
             
             
             

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;

             
             

            MapEntry storage lastEntry = map._entries[lastIndex];

             
            map._entries[toDeleteIndex] = lastEntry;
             
            map._indexes[lastEntry._key] = toDeleteIndex + 1;  

             
            map._entries.pop();

             
            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

     
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

     
    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

    
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

     
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        return _get(map, key, "EnumerableMap: nonexistent key");
    }

     
    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage);  
        return map._entries[keyIndex - 1]._value;  
    }

     

    struct UintToAddressMap {
        Map _inner;
    }

     
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(value)));
    }

     
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

     
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

     
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

    
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint256(value)));
    }

     
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key))));
    }

     
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));
    }
}


 

 

pragma solidity ^0.6.0;

 
library Strings {
     
    function toString(uint256 value) internal pure returns (string memory) {
         
         

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}


 

 

pragma solidity ^0.6.0;












 
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

     
     
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

     
    mapping (address => EnumerableSet.UintSet) private _holderTokens;

     
    EnumerableMap.UintToAddressMap private _tokenOwners;

     
    mapping (uint256 => address) private _tokenApprovals;

     
    mapping (address => mapping (address => bool)) private _operatorApprovals;

     
    string private _name;

     
    string private _symbol;

     
    mapping(uint256 => string) private _tokenURIs;

     
    string private _baseURI;

     
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

     
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

     
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

         
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

     
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

     
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

     
    function name() public view override returns (string memory) {
        return _name;
    }

     
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

     
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

         
        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
         
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
         
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

     
    function baseURI() public view returns (string memory) {
        return _baseURI;
    }

     
    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

     
    function totalSupply() public view override returns (uint256) {
         
        return _tokenOwners.length();
    }

     
    function tokenByIndex(uint256 index) public view override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

     
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

     
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

     
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

     
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

     
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
         
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

     
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

     
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

     
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

     
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

     
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

     
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

     
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

     
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

     
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

         
        _approve(address(0), tokenId);

         
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

     
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

         
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

     
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

     
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

     
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
         
        (bool success, bytes memory returndata) = to.call(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ));
        if (!success) {
            if (returndata.length > 0) {
                 
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("ERC721: transfer to non ERC721Receiver implementer");
            }
        } else {
            bytes4 retval = abi.decode(returndata, (bytes4));
            return (retval == _ERC721_RECEIVED);
        }
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}


 

pragma solidity >=0.6.0 <0.7.0;







contract NFTINK is BaseRelayRecipient, ERC721, Ownable, SignatureChecker {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter public totalInks;
    using SafeMath for uint256;

    uint artistTake;

    function setArtistTake(uint _take) public onlyOwner {
      artistTake = _take;
    }

    constructor() ERC721("🎨 Nifty.Ink", "🎨") public {
      _setBaseURI('ipfs://ipfs/');
      setCheckSignatureFlag(true);
      setArtistTake(1);
    }

    event newInk(uint256 id, address indexed artist, string inkUrl, string jsonUrl, uint256 limit);
    event mintedInk(uint256 id, string inkUrl, address to);
    event boughtInk(uint256 id, string inkUrl, address buyer, uint256 price);

    struct Ink {
      uint256 id;
      address payable artist;
      address patron;
      string jsonUrl;
      string inkUrl;
      uint256 limit;
      uint256 count;
      bool exists;
      uint256 price;
    }

    mapping (string => uint256) private _inkIdByUrl;
    mapping (uint256 => Ink) private _inkById;
    mapping (string => EnumerableSet.UintSet) private _inkTokens;
    mapping (address => EnumerableSet.UintSet) private _artistInks;
    mapping (string => bytes) private _inkSignatureByUrl;
    mapping (uint256 => uint256) private _inkIdByTokenId;

    mapping (uint256 => uint256) public tokenPrice;

    mapping (bytes32 => uint256) private msgTokenId;
    mapping (bytes32 => address) private msgRecipient;

    function _createInk(string memory inkUrl, string memory jsonUrl, uint256 limit, address payable artist, address patron) internal returns (uint256) {

      totalInks.increment();

      Ink memory _ink = Ink({
        id: totalInks.current(),
        artist: artist,
        patron: patron,
        inkUrl: inkUrl,
        jsonUrl: jsonUrl,
        limit: limit,
        count: 0,
        exists: true,
        price: 0
        });

        _inkIdByUrl[inkUrl] = _ink.id;
        _inkById[_ink.id] = _ink;
        _artistInks[artist].add(_ink.id);

        emit newInk(_ink.id, _ink.artist, _ink.inkUrl, _ink.jsonUrl, _ink.limit);

        return _ink.id;
    }

    function createInk(string memory inkUrl, string memory jsonUrl, uint256 limit) public returns (uint256) {
      require(!(_inkIdByUrl[inkUrl] > 0), "this ink already exists!");

      uint256 inkId = _createInk(inkUrl, jsonUrl, limit, _msgSender(), _msgSender());

      _mintInkToken(_msgSender(), inkId, inkUrl, jsonUrl);

      return inkId;
    }

    function _mintInkToken(address to, uint256 inkId, string memory inkUrl, string memory jsonUrl) internal returns (uint256) {
      _inkById[inkId].count += 1;

      _tokenIds.increment();
      uint256 id = _tokenIds.current();
      _inkTokens[inkUrl].add(id);
      _inkIdByTokenId[id] = inkId;

      _mint(to, id);
      _setTokenURI(id, jsonUrl);

      emit mintedInk(id, inkUrl, to);

      return id;
    }

    function mint(address to, string memory inkUrl) public returns (uint256) {
        uint256 _inkId = _inkIdByUrl[inkUrl];
        require(_inkId > 0, "this ink does not exist!");
        Ink storage _ink = _inkById[_inkId];
        require(_ink.artist == _msgSender(), "only the artist can mint!");
        require(_ink.count < _ink.limit || _ink.limit == 0, "this ink is over the limit!");

        uint256 tokenId = _mintInkToken(to, _inkId, _ink.inkUrl, _ink.jsonUrl);

        return tokenId;
    }


    function setPrice(string memory inkUrl, uint256 price) public returns (uint256) {
      uint256 _inkId = _inkIdByUrl[inkUrl];
      require(_inkId > 0, "this ink does not exist!");
      Ink storage _ink = _inkById[_inkId];
      require(_ink.artist == _msgSender(), "only the artist can set the price!");
      require(_ink.count < _ink.limit || _ink.limit == 0, "this ink is over the limit!");

      _inkById[_inkId].price = price;

      return price;
    }

    function buyInk(string memory inkUrl) public payable returns (uint256) {
      uint256 _inkId = _inkIdByUrl[inkUrl];
      require(_inkId > 0, "this ink does not exist!");
      Ink storage _ink = _inkById[_inkId];
      require(_ink.count < _ink.limit || _ink.limit == 0, "this ink is over the limit!");
      require(_ink.price > 0, "this ink does not have a price set");
      require(msg.value >= _ink.price, "Amount of Ether sent too small");
      address buyer = _msgSender();
      uint256 tokenId = _mintInkToken(buyer, _inkId, inkUrl, _ink.jsonUrl);
       
      _ink.artist.transfer(msg.value);
      emit boughtInk(tokenId, inkUrl, buyer, msg.value);
      return tokenId;
    }


    function setTokenPrice(uint256 _tokenId, uint256 _price) public returns (uint256) {
      require(_exists(_tokenId), "this token does not exist!");
      require(ownerOf(_tokenId) == _msgSender(), "only the owner can set the price!");

      tokenPrice[_tokenId] = _price;

      return _price;
    }

    function buyToken(uint256 _tokenId) public payable {
      uint256 _price = tokenPrice[_tokenId];
      require(_price > 0, "this token is not for sale");
      require(msg.value >= _price, "Amount of Ether sent too small");
      address _buyer = _msgSender();
      address payable _seller = address(uint160(ownerOf(_tokenId)));
      _transfer(_seller, _buyer, _tokenId);
       

      uint256 _artistTake = artistTake.mul(msg.value).div(100);
      uint256 _sellerTake = msg.value.sub(_artistTake);

      Ink storage _ink = _inkById[_inkIdByTokenId[_tokenId]];

      _ink.artist.transfer(_artistTake);
      _seller.transfer(_sellerTake);
      delete tokenPrice[_tokenId];
      emit boughtInk(_tokenId, _ink.inkUrl, _buyer, msg.value);
    }

    function createInkFromSignature(string memory inkUrl, string memory jsonUrl, uint256 limit, address payable artist, bytes memory signature) public returns (uint256) {
      require(!(_inkIdByUrl[inkUrl] > 0), "this ink already exists!");

      require(artist!=address(0), "Artist must be specified.");
      bytes32 messageHash = getHash(artist,inkUrl,jsonUrl,limit);
      bool isArtistSignature = checkSignature(messageHash, signature, artist);
      require(isArtistSignature, "Unable to verify the artist signature");

      uint256 inkId = _createInk(inkUrl, jsonUrl, limit, artist, _msgSender());

      _mintInkToken(_msgSender(), inkId, inkUrl, jsonUrl);

      _inkSignatureByUrl[inkUrl] = signature;

      return inkId;
    }

    function getHash(address artist, string memory inkUrl, string memory jsonUrl, uint256 limit) public view returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                byte(0x19),
                byte(0),
                address(this),
                artist,
                inkUrl,
                jsonUrl,
                limit
        ));
    }

    function inkTokenByIndex(string memory inkUrl, uint256 index) public view returns (uint256) {
      uint256 _inkId = _inkIdByUrl[inkUrl];
      require(_inkId > 0, "this ink does not exist!");
      Ink storage _ink = _inkById[_inkId];
      require(_ink.count >= index + 1, "this token index does not exist!");
      return _inkTokens[inkUrl].at(index);
    }

    function inkInfoByInkUrl(string memory inkUrl) public view returns (uint256, address, uint256, string memory, bytes memory, uint256) {
      uint256 _inkId = _inkIdByUrl[inkUrl];
      require(_inkId > 0, "this ink does not exist!");
      Ink storage _ink = _inkById[_inkId];
      bytes memory signature = _inkSignatureByUrl[inkUrl];

      return (_inkId, _ink.artist, _ink.count, _ink.jsonUrl, signature, _ink.price);
    }

    function inkIdByUrl(string memory inkUrl) public view returns (uint256) {
      return _inkIdByUrl[inkUrl];
    }

    function inksCreatedBy(address artist) public view returns (uint256) {
      return _artistInks[artist].length();
    }

    function inkOfArtistByIndex(address artist, uint256 index) public view returns (uint256) {
        return _artistInks[artist].at(index);
    }

    function inkInfoById(uint256 id) public view returns (string memory, address, uint256, string memory, bytes memory, uint256) {
      require(_inkById[id].exists, "this ink does not exist!");
      Ink storage _ink = _inkById[id];
      bytes memory signature = _inkSignatureByUrl[_ink.inkUrl];

      return (_ink.jsonUrl, _ink.artist, _ink.count, _ink.inkUrl, signature, _ink.price);
    }

    function versionRecipient() external virtual view override returns (string memory) {
  		return "1.0";
  	}

    function setTrustedForwarder(address _trustedForwarder) public onlyOwner {
      trustedForwarder = _trustedForwarder;
  	}

  	function getTrustedForwarder() public view returns(address) {
  		return trustedForwarder;
  	}

    function _msgSender() internal override(BaseRelayRecipient, Context) view returns (address payable) {
        return BaseRelayRecipient._msgSender();
    }

}


 

pragma solidity >=0.6.0 <0.7.0;

interface INiftyToken {
    function inkTokenCount(string calldata) external view returns (uint256);
    function firstMint(address, string calldata, string calldata) external returns (uint256);
    function mint(address, string calldata) external returns (uint256);
    function buyInk(string calldata) external payable returns (uint256);
    function buyToken(uint256) external payable;
    function lock(uint256) external;
    function unlock(uint256, address) external;
    function ownerOf(uint256) external view returns (address);
    function tokenInk(uint) external view returns (string memory);
}


 

pragma solidity ^0.6.6;

interface INiftyRegistry {
    function inkAddress() external view returns (address);
    function tokenAddress() external view returns (address);
    function bridgeMediatorAddress() external view returns (address);
    function trustedForwarder() external view returns (address);
}


 

pragma solidity >=0.6.0 <0.7.0;








contract NiftyInk is BaseRelayRecipient, Ownable, SignatureChecker {

    constructor() public {
      setCheckSignatureFlag(true);
      setArtistTake(1);
    }

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    Counters.Counter public totalInks;

    uint public artistTake;

    function setArtistTake(uint _take) public onlyOwner {
      require(_take < 100, 'take is more than 99 percent');
      artistTake = _take;
    }

    address public niftyRegistry;

    function setNiftyRegistry(address _address) public onlyOwner {
      niftyRegistry = _address;
    }

    function niftyToken() private view returns (INiftyToken) {
      return INiftyToken(INiftyRegistry(niftyRegistry).tokenAddress());
    }

    event newInk(uint256 id, address indexed artist, string inkUrl, string jsonUrl, uint256 limit);

    struct Ink {
      uint256 id;
      address payable artist;
      string jsonUrl;
      string inkUrl;
      uint256 limit;
      bytes signature;
      uint256 price;
      Counters.Counter priceNonce;
    }

    mapping (string => uint256) public inkIdByInkUrl;
    mapping (uint256 => Ink) private _inkById;
    mapping (address => EnumerableSet.UintSet) private _artistInks;

    function _createInk(string memory inkUrl, string memory jsonUrl, uint256 limit, address payable artist) internal returns (uint256) {

      totalInks.increment();
      uint256 _inkId = totalInks.current();

      Ink storage _ink = _inkById[_inkId];

      _ink.id = _inkId;
      _ink.artist = artist;
      _ink.inkUrl = inkUrl;
      _ink.jsonUrl = jsonUrl;
      _ink.limit = limit;

      inkIdByInkUrl[inkUrl] = _inkId;
      _artistInks[artist].add(_inkId);

      emit newInk(_ink.id, _ink.artist, _ink.inkUrl, _ink.jsonUrl, _ink.limit);

      return _ink.id;
    }

    function createInk(string memory inkUrl, string memory jsonUrl, uint256 limit) public returns (uint256) {
      require(!(inkIdByInkUrl[inkUrl] > 0), "this ink already exists!");

      uint256 inkId = _createInk(inkUrl, jsonUrl, limit, _msgSender());

      niftyToken().firstMint(_msgSender(), inkUrl, jsonUrl);

      return inkId;
    }

    function createInkFromSignature(string memory inkUrl, string memory jsonUrl, uint256 limit, address payable artist, bytes memory signature) public returns (uint256) {
      require(!(inkIdByInkUrl[inkUrl] > 0), "this ink already exists!");

      require(artist!=address(0), "Artist must be specified.");
      bytes32 messageHash = keccak256(abi.encodePacked(byte(0x19), byte(0), address(this), artist, inkUrl, jsonUrl, limit));
      bool isArtistSignature = checkSignature(messageHash, signature, artist);
      require(isArtistSignature || !checkSignatureFlag, "Artist did not sign this ink");

      uint256 inkId = _createInk(inkUrl, jsonUrl, limit, artist);

      _inkById[inkId].signature = signature;

      niftyToken().firstMint(artist, inkUrl, jsonUrl);

      return inkId;
    }

    function _setPrice(uint256 _inkId, uint256 price) private returns (uint256) {

      _inkById[_inkId].price = price;
      _inkById[_inkId].priceNonce.increment();

      return price;
    }

    function setPrice(string memory inkUrl, uint256 price) public returns (uint256) {
      uint256 _inkId = inkIdByInkUrl[inkUrl];
      require(_inkId > 0, "this ink does not exist!");
      Ink storage _ink = _inkById[_inkId];
      require(_ink.artist == _msgSender(), "only the artist can set the price!");

      return _setPrice(_ink.id, price);
    }

    function setPriceFromSignature(string memory inkUrl, uint256 price, bytes memory signature) public returns (uint256) {
      uint256 _inkId = inkIdByInkUrl[inkUrl];
      require(_inkId > 0, "this ink does not exist!");
      Ink storage _ink = _inkById[_inkId];
      bytes32 messageHash = keccak256(abi.encodePacked(byte(0x19), byte(0), address(this), inkUrl, price, _ink.priceNonce.current()));
      bool isArtistSignature = checkSignature(messageHash, signature, _ink.artist);
      require(isArtistSignature || !checkSignatureFlag, "Artist did not sign this price");

      return _setPrice(_ink.id, price);
    }


    function inkInfoById(uint256 id) public view returns (uint256, address, string memory, bytes memory, uint256, uint256, string memory, uint256) {
      require(id > 0 && id <= totalInks.current(), "this ink does not exist!");
      Ink storage _ink = _inkById[id];

      return (id, _ink.artist, _ink.jsonUrl, _ink.signature, _ink.price, _ink.limit, _ink.inkUrl, _ink.priceNonce.current());
    }

    function inkInfoByInkUrl(string memory inkUrl) public view returns (uint256, address, string memory, bytes memory, uint256, uint256, string memory, uint256) {
      uint256 _inkId = inkIdByInkUrl[inkUrl];

      return inkInfoById(_inkId);
    }

    function inksCreatedBy(address artist) public view returns (uint256) {
      return _artistInks[artist].length();
    }

    function inkOfArtistByIndex(address artist, uint256 index) public view returns (uint256) {
        return _artistInks[artist].at(index);
    }

    function versionRecipient() external virtual view override returns (string memory) {
  		return "1.0";
  	}

    function setTrustedForwarder(address _trustedForwarder) public onlyOwner {
      trustedForwarder = _trustedForwarder;
    }

    function getTrustedForwarder() public view returns(address) {
      return trustedForwarder;
    }

    function _msgSender() internal override(BaseRelayRecipient, Context) view returns (address payable) {
        return BaseRelayRecipient._msgSender();
    }

}


 

pragma solidity >=0.6.0 <0.7.0;






contract NiftyMain is ERC721, Ownable, AMBMediator {

    constructor() ERC721("🎨 Nifty.Ink", "🎨") public {
      _setBaseURI('ipfs://ipfs/');
    }

    event mintedInk(uint256 id, string inkUrl, string jsonUrl, address to, bytes32 msgId);

    mapping (string => EnumerableSet.UintSet) private _inkTokens;
    mapping (uint256 => string) public tokenInk;

    function mint(address to, uint256 tokenId, string calldata inkUrl, string calldata jsonUrl) external returns (uint256) {
      require(msg.sender == address(bridgeContract()));
      require(bridgeContract().messageSender() == mediatorContractOnOtherSide());

      _inkTokens[inkUrl].add(tokenId);
      tokenInk[tokenId] = inkUrl;
      _safeMint(to, tokenId);
      _setTokenURI(tokenId, jsonUrl);
      bytes32 msgId = messageId();

      emit mintedInk(tokenId, inkUrl, jsonUrl, to, msgId);

      return tokenId;
    }

    function inkTokenCount(string memory _inkUrl) public view returns(uint256) {
      uint256 _inkTokenCount = _inkTokens[_inkUrl].length();
      return _inkTokenCount;
    }

    function inkTokenByIndex(string memory inkUrl, uint256 index) public view returns (uint256) {
      return _inkTokens[inkUrl].at(index);
    }

}


 

pragma solidity >=0.6.0 <0.7.0;

interface INiftyInk {
    function artistTake() external view returns (uint);
    function inkInfoById(uint256) external view returns (uint256, address payable, string memory, bytes memory, uint256, uint256, string memory);
    function inkInfoByInkUrl(string calldata) external view returns (uint256, address payable, string memory, bytes memory, uint256, uint256, string memory);
    function inkIdByInkUrl(string calldata) external view returns (uint256);
}


 

pragma solidity >=0.6.0 <0.7.0;








contract NiftyMediator is BaseRelayRecipient, Ownable, AMBMediator, SignatureChecker {

    constructor() public {
      setCheckSignatureFlag(true);
    }

    event tokenSentViaBridge(uint256 _tokenId, bytes32 _msgId);
    event failedMessageFixed(bytes32 _msgId, address _recipient, uint256 _tokenId);

    address public niftyRegistry;

    function setNiftyRegistry(address _address) public onlyOwner {
      niftyRegistry = _address;
    }

    function niftyToken() private view returns (INiftyToken) {
      return INiftyToken(INiftyRegistry(niftyRegistry).tokenAddress());
    }

    function niftyInk() private view returns (INiftyInk) {
      return INiftyInk(INiftyRegistry(niftyRegistry).inkAddress());
    }

    mapping (bytes32 => uint256) private msgTokenId;
    mapping (bytes32 => address) private msgRecipient;

    function _relayToken(uint256 _tokenId) internal returns (bytes32) {
      niftyToken().lock(_tokenId);

      string memory _inkUrl = niftyToken().tokenInk(_tokenId);

      (, , string memory _jsonUrl, , , , ) = niftyInk().inkInfoByInkUrl(_inkUrl);

      bytes4 methodSelector = ITokenManagement(address(0)).mint.selector;
      bytes memory data = abi.encodeWithSelector(methodSelector, _msgSender(), _tokenId, _inkUrl, _jsonUrl);
      bytes32 msgId = bridgeContract().requireToPassMessage(
          mediatorContractOnOtherSide(),
          data,
          requestGasLimit
      );

      msgTokenId[msgId] = _tokenId;
      msgRecipient[msgId] = _msgSender();

      emit tokenSentViaBridge(_tokenId, msgId);

      return msgId;
    }

    function relayToken(uint256 _tokenId) external returns (bytes32) {
      require(_msgSender() == niftyToken().ownerOf(_tokenId), 'only the owner can upgrade!');

      return _relayToken(_tokenId);
    }


    function relayTokenFromSignature(uint256 _tokenId, bytes calldata signature) external returns (bytes32) {
      address _owner = niftyToken().ownerOf(_tokenId);
      bytes32 messageHash = keccak256(abi.encodePacked(byte(0x19), byte(0), address(this), _owner, _tokenId));
      bool isOwnerSignature = checkSignature(messageHash, signature, _owner);
      require(isOwnerSignature || !checkSignatureFlag, "only the owner can upgrade!");

      return _relayToken(_tokenId);
    }

    function fixFailedMessage(bytes32 _msgId) external {
      require(msg.sender == address(bridgeContract()));
      require(bridgeContract().messageSender() == mediatorContractOnOtherSide());
      require(!messageFixed[_msgId]);

      address _recipient = msgRecipient[_msgId];
      uint256 _tokenId = msgTokenId[_msgId];

      messageFixed[_msgId] = true;
      niftyToken().unlock(_tokenId, _recipient);

      emit failedMessageFixed(_msgId, _recipient, _tokenId);
    }

    function versionRecipient() external virtual view override returns (string memory) {
  		return "1.0";
  	}

    function setTrustedForwarder(address _trustedForwarder) public onlyOwner {
      trustedForwarder = _trustedForwarder;
    }

    function getTrustedForwarder() public view returns(address) {
      return trustedForwarder;
    }

    function _msgSender() internal override(BaseRelayRecipient, Context) view returns (address payable) {
        return BaseRelayRecipient._msgSender();
    }

}


 

pragma solidity >=0.6.0 <0.7.0;


contract NiftyRegistry is Ownable {

    address public inkAddress;
    address public tokenAddress;
    address public bridgeMediatorAddress;
    address public trustedForwarder;

    function setInkAddress(address _address) public onlyOwner {
      inkAddress = _address;
  	}

    function setTokenAddress(address _address) public onlyOwner {
      tokenAddress = _address;
    }

    function setBridgeMediatorAddress(address _address) public onlyOwner {
      bridgeMediatorAddress = _address;
    }

    function setTrustedForwarder(address _trustedForwarder) public onlyOwner {
      trustedForwarder = _trustedForwarder;
  	}

}


 

pragma solidity >=0.6.0 <0.7.0;









contract NiftyToken is BaseRelayRecipient, ERC721, SignatureChecker {

    constructor() ERC721("🎨 Nifty.Ink", "🎨") public {
      _setBaseURI('ipfs://ipfs/');
      setCheckSignatureFlag(true);
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    using SafeMath for uint256;

    address public niftyRegistry;

    function setNiftyRegistry(address _address) public onlyOwner {
      niftyRegistry = _address;
    }

    function niftyInk() private view returns (INiftyInk) {
      return INiftyInk(INiftyRegistry(niftyRegistry).inkAddress());
    }

    event mintedInk(uint256 id, string inkUrl, address to);
    event boughtInk(uint256 id, string inkUrl, address buyer, uint256 price);
    event boughtToken(uint256 id, string inkUrl, address buyer, uint256 price);
    event lockedInk(uint256 id, address recipient);
    event unlockedInk(uint256 id, address recipient);

    mapping (string => EnumerableSet.UintSet) private _inkTokens;
    mapping (uint256 => string) public tokenInk;

    mapping (uint256 => uint256) public tokenPrice;

    function inkTokenCount(string memory _inkUrl) public view returns(uint256) {
      uint256 _inkTokenCount = _inkTokens[_inkUrl].length();
      return _inkTokenCount;
    }

    function _mintInkToken(address to, string memory inkUrl, string memory jsonUrl) internal returns (uint256) {

      _tokenIds.increment();
      uint256 id = _tokenIds.current();
      _inkTokens[inkUrl].add(id);
      tokenInk[id] = inkUrl;

      _mint(to, id);
      _setTokenURI(id, jsonUrl);

      emit mintedInk(id, inkUrl, to);

      return id;
    }

    function firstMint(address to, string calldata inkUrl, string calldata jsonUrl) external returns (uint256) {
      require(_msgSender() == INiftyRegistry(niftyRegistry).inkAddress());
      _mintInkToken(to, inkUrl, jsonUrl);
    }

    function mint(address to, string memory _inkUrl) public returns (uint256) {
        uint256 _inkId = niftyInk().inkIdByInkUrl(_inkUrl);
        require(_inkId > 0, "this ink does not exist!");
        (, address _artist, string memory _jsonUrl, , , uint256 _limit, ) = niftyInk().inkInfoById(_inkId);

        require(_artist == _msgSender(), "only the artist can mint!");

        require(inkTokenCount(_inkUrl) < _limit || _limit == 0, "this ink is over the limit!");

        uint256 tokenId = _mintInkToken(to, _inkUrl, _jsonUrl);

        return tokenId;
    }

    function mintFromSignature(address to, string memory _inkUrl, bytes memory signature) public returns (uint256) {
        uint256 _inkId = niftyInk().inkIdByInkUrl(_inkUrl);
        require(_inkId > 0, "this ink does not exist!");

        uint256 _count = inkTokenCount(_inkUrl);
        (, address _artist, string memory _jsonUrl, , , uint256 _limit, ) = niftyInk().inkInfoById(_inkId);
        require(_count < _limit || _limit == 0, "this ink is over the limit!");

        bytes32 messageHash = keccak256(abi.encodePacked(byte(0x19), byte(0), address(this), to, _inkUrl, _count));
        bool isArtistSignature = checkSignature(messageHash, signature, _artist);
        require(isArtistSignature || !checkSignatureFlag, "only the artist can mint!");

        uint256 tokenId = _mintInkToken(to, _inkUrl, _jsonUrl);

        return tokenId;
    }

    function lock(uint256 _tokenId) external {
      address _bridgeMediatorAddress = INiftyRegistry(niftyRegistry).bridgeMediatorAddress();
      require(_bridgeMediatorAddress == _msgSender(), 'only the bridgeMediator can lock');
      address from = ownerOf(_tokenId);
      _transfer(from, _msgSender(), _tokenId);
    }

    function unlock(uint256 _tokenId, address _recipient) external {
      require(_msgSender() == INiftyRegistry(niftyRegistry).bridgeMediatorAddress(), 'only the bridgeMediator can unlock');
      require(_msgSender() == ownerOf(_tokenId), 'the bridgeMediator does not hold this token');
      safeTransferFrom(_msgSender(), _recipient, _tokenId);
    }

    function buyInk(string memory _inkUrl) public payable returns (uint256) {
      uint256 _inkId = niftyInk().inkIdByInkUrl(_inkUrl);
      require(_inkId > 0, "this ink does not exist!");
      (, address payable _artist, string memory _jsonUrl, , uint256 _price, uint256 _limit, ) = niftyInk().inkInfoById(_inkId);
      require(inkTokenCount(_inkUrl) < _limit || _limit == 0, "this ink is over the limit!");
      require(_price > 0, "this ink does not have a price set");
      require(msg.value >= _price, "Amount of Ether sent too small");
      address _buyer = _msgSender();
      uint256 _tokenId = _mintInkToken(_buyer, _inkUrl, _jsonUrl);
       
      _artist.transfer(msg.value);
      emit boughtInk(_tokenId, _inkUrl, _buyer, msg.value);
      return _tokenId;
    }

    function setTokenPrice(uint256 _tokenId, uint256 _price) public returns (uint256) {
      require(_exists(_tokenId), "this token does not exist!");
      require(ownerOf(_tokenId) == _msgSender(), "only the owner can set the price!");

      tokenPrice[_tokenId] = _price;

      return _price;
    }

    function buyToken(uint256 _tokenId) public payable {
      uint256 _price = tokenPrice[_tokenId];
      require(_price > 0, "this token is not for sale");
      require(msg.value >= _price, "Amount of Ether sent too small");
      address _buyer = _msgSender();
      address payable _seller = address(uint160(ownerOf(_tokenId)));
      _transfer(_seller, _buyer, _tokenId);
       

      uint256 _artistTake = niftyInk().artistTake().mul(msg.value).div(100);
      uint256 _sellerTake = msg.value.sub(_artistTake);
      string memory _inkUrl = tokenInk[_tokenId];

      (, address payable _artist, , , , , ) = niftyInk().inkInfoByInkUrl(_inkUrl);

      _artist.transfer(_artistTake);
      _seller.transfer(_sellerTake);
      delete tokenPrice[_tokenId];
      emit boughtInk(_tokenId, _inkUrl, _buyer, msg.value);
    }

    function inkTokenByIndex(string memory inkUrl, uint256 index) public view returns (uint256) {
      return _inkTokens[inkUrl].at(index);
    }

    function versionRecipient() external virtual view override returns (string memory) {
  		return "1.0";
  	}

    function setTrustedForwarder(address _trustedForwarder) public onlyOwner {
      trustedForwarder = _trustedForwarder;
    }

    function getTrustedForwarder() public view returns(address) {
      return trustedForwarder;
    }

    function _msgSender() internal override(BaseRelayRecipient, Context) view returns (address payable) {
        return BaseRelayRecipient._msgSender();
    }

}


 

pragma solidity >=0.6.0 <0.7.0;


contract ValidSignatureTester {

  bytes4 internal constant _ERC1271MAGICVALUE = 0x1626ba7e;
  bytes4 internal constant _ERC1271FAILVALUE = 0xffffffff;

  bool public setting;

  function changeSetting() public returns (bool) {
    setting = !setting;
    return setting;
  }

  function isValidSignature(
      bytes32 _hash,  
      bytes calldata _signature
  )
  external
  view
  returns (bytes4 magicValue) {
    if(setting==true) {
      return _ERC1271MAGICVALUE;
    } else {
      return _ERC1271FAILVALUE;
    }
  }
}