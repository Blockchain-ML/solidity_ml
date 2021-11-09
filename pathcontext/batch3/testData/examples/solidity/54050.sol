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

 

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

 

 
library RLP {

 uint constant DATA_SHORT_START = 0x80;
 uint constant DATA_LONG_START = 0xB8;
 uint constant LIST_SHORT_START = 0xC0;
 uint constant LIST_LONG_START = 0xF8;

 uint constant DATA_LONG_OFFSET = 0xB7;
 uint constant LIST_LONG_OFFSET = 0xF7;


 struct RLPItem {
     uint _unsafe_memPtr;     
     uint _unsafe_length;     
 }

 struct Iterator {
     RLPItem _unsafe_item;    
     uint _unsafe_nextPtr;    
 }

  

 function next(Iterator memory self) internal constant returns (RLPItem memory subItem) {
     if(hasNext(self)) {
         var ptr = self._unsafe_nextPtr;
         var itemLength = _itemLength(ptr);
         subItem._unsafe_memPtr = ptr;
         subItem._unsafe_length = itemLength;
         self._unsafe_nextPtr = ptr + itemLength;
     }
     else
         revert();
 }

 function next(Iterator memory self, bool strict) internal constant returns (RLPItem memory subItem) {
     subItem = next(self);
     if(strict && !_validate(subItem))
         revert();
     return;
 }

 function hasNext(Iterator memory self) internal constant returns (bool) {
     var item = self._unsafe_item;
     return self._unsafe_nextPtr < item._unsafe_memPtr + item._unsafe_length;
 }

  

  
  
  
 function toRLPItem(bytes memory self) internal constant returns (RLPItem memory) {
     uint len = self.length;
     if (len == 0) {
         return RLPItem(0, 0);
     }
     uint memPtr;
     assembly {
         memPtr := add(self, 0x20)
     }
     return RLPItem(memPtr, len);
 }

  
  
  
  
 function toRLPItem(bytes memory self, bool strict) internal constant returns (RLPItem memory) {
     var item = toRLPItem(self);
     if(strict) {
         uint len = self.length;
         if(_payloadOffset(item) > len)
             revert();
         if(_itemLength(item._unsafe_memPtr) != len)
             revert();
         if(!_validate(item))
             revert();
     }
     return item;
 }

  
  
  
 function isNull(RLPItem memory self) internal pure returns (bool ret) {
     return self._unsafe_length == 0;
 }

  
  
  
 function isList(RLPItem memory self) internal pure returns (bool ret) {
     if (self._unsafe_length == 0)
         return false;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         ret := iszero(lt(byte(0, mload(memPtr)), 0xC0))
     }
 }

  
  
  
 function isData(RLPItem memory self) internal pure returns (bool ret) {
     if (self._unsafe_length == 0)
         return false;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         ret := lt(byte(0, mload(memPtr)), 0xC0)
     }
 }

  
  
  
 function isEmpty(RLPItem memory self) internal pure returns (bool ret) {
     if (isNull(self)) {
         return false;
     }
     uint b0;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         b0 := byte(0, mload(memPtr))
     }
     return (b0 == DATA_SHORT_START || b0 == LIST_SHORT_START);
 }

  
  
  
 function items(RLPItem memory self) internal constant returns (uint) {
     if (!isList(self))
         return 0;
     uint b0;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         b0 := byte(0, mload(memPtr))
     }
     uint pos = memPtr + _payloadOffset(self);
     uint last = memPtr + self._unsafe_length - 1;
     uint itms;
     while (pos <= last) {
         pos += _itemLength(pos);
         itms++;
     }
     return itms;
 }

  
  
  
 function iterator(RLPItem memory self) internal constant returns (Iterator memory it) {
     if (!isList(self))
         revert();
     uint ptr = self._unsafe_memPtr + _payloadOffset(self);
     it._unsafe_item = self;
     it._unsafe_nextPtr = ptr;
 }

  
  
  
 function toBytes(RLPItem memory self) internal constant returns (bytes memory bts) {
     var len = self._unsafe_length;
     if (len == 0)
         return;
     bts = new bytes(len);
     _copyToBytes(self._unsafe_memPtr, bts, len);
 }

  
  
  
  
 function toData(RLPItem memory self) internal constant returns (bytes memory bts) {
     if(!isData(self))
         revert();
     var (rStartPos, len) = _decode(self);
     bts = new bytes(len);
     _copyToBytes(rStartPos, bts, len);
 }

  
  
  
  
 function toList(RLPItem memory self) internal constant returns (RLPItem[] memory list) {
     if(!isList(self))
         revert();
     var numItems = items(self);
     list = new RLPItem[](numItems);
     var it = iterator(self);
     uint idx;
     while(hasNext(it)) {
         list[idx] = next(it);
         idx++;
     }
 }

  
  
  
  
 function toAscii(RLPItem memory self) internal constant returns (string memory str) {
     if(!isData(self))
         revert();
     var (rStartPos, len) = _decode(self);
     bytes memory bts = new bytes(len);
     _copyToBytes(rStartPos, bts, len);
     str = string(bts);
 }

  
  
  
  
 function toUint(RLPItem memory self) internal constant returns (uint data) {
     if(!isData(self))
         revert();
     var (rStartPos, len) = _decode(self);
     if (len > 32 || len == 0)
         revert();
     assembly {
         data := div(mload(rStartPos), exp(256, sub(32, len)))
     }
 }

  
  
  
  
 function toBool(RLPItem memory self) internal constant returns (bool data) {
     if(!isData(self))
         revert();
     var (rStartPos, len) = _decode(self);
     if (len != 1)
         revert();
     uint temp;
     assembly {
         temp := byte(0, mload(rStartPos))
     }
     if (temp > 1)
         revert();
     return temp == 1 ? true : false;
 }

  
  
  
  
 function toByte(RLPItem memory self) internal constant returns (byte data) {
     if(!isData(self))
         revert();
     var (rStartPos, len) = _decode(self);
     if (len != 1)
         revert();
     uint temp;
     assembly {
         temp := byte(0, mload(rStartPos))
     }
     return byte(temp);
 }

  
  
  
  
 function toInt(RLPItem memory self) internal constant returns (int data) {
     return int(toUint(self));
 }

  
  
  
  
 function toBytes32(RLPItem memory self) internal constant returns (bytes32 data) {
     return bytes32(toUint(self));
 }

  
  
  
  
 function toAddress(RLPItem memory self) internal constant returns (address data) {
     if(!isData(self))
         revert();
     var (rStartPos, len) = _decode(self);
     if (len != 20)
         revert();
     assembly {
         data := div(mload(rStartPos), exp(256, 12))
     }
 }

  
 function _payloadOffset(RLPItem memory self) private constant returns (uint) {
     if(self._unsafe_length == 0)
         return 0;
     uint b0;
     uint memPtr = self._unsafe_memPtr;
     assembly {
         b0 := byte(0, mload(memPtr))
     }
     if(b0 < DATA_SHORT_START)
         return 0;
     if(b0 < DATA_LONG_START || (b0 >= LIST_SHORT_START && b0 < LIST_LONG_START))
         return 1;
     if(b0 < LIST_SHORT_START)
         return b0 - DATA_LONG_OFFSET + 1;
     return b0 - LIST_LONG_OFFSET + 1;
 }

  
 function _itemLength(uint memPtr) private constant returns (uint len) {
     uint b0;
     assembly {
         b0 := byte(0, mload(memPtr))
     }
     if (b0 < DATA_SHORT_START)
         len = 1;
     else if (b0 < DATA_LONG_START)
         len = b0 - DATA_SHORT_START + 1;
     else if (b0 < LIST_SHORT_START) {
         assembly {
             let bLen := sub(b0, 0xB7)  
             let dLen := div(mload(add(memPtr, 1)), exp(256, sub(32, bLen)))  
             len := add(1, add(bLen, dLen))  
         }
     }
     else if (b0 < LIST_LONG_START)
         len = b0 - LIST_SHORT_START + 1;
     else {
         assembly {
             let bLen := sub(b0, 0xF7)  
             let dLen := div(mload(add(memPtr, 1)), exp(256, sub(32, bLen)))  
             len := add(1, add(bLen, dLen))  
         }
     }
 }

  
 function _decode(RLPItem memory self) private constant returns (uint memPtr, uint len) {
     if(!isData(self))
         revert();
     uint b0;
     uint start = self._unsafe_memPtr;
     assembly {
         b0 := byte(0, mload(start))
     }
     if (b0 < DATA_SHORT_START) {
         memPtr = start;
         len = 1;
         return;
     }
     if (b0 < DATA_LONG_START) {
         len = self._unsafe_length - 1;
         memPtr = start + 1;
     } else {
         uint bLen;
         assembly {
             bLen := sub(b0, 0xB7)  
         }
         len = self._unsafe_length - 1 - bLen;
         memPtr = start + bLen + 1;
     }
     return;
 }

  
 function _copyToBytes(uint btsPtr, bytes memory tgt, uint btsLen) private constant {
      
      
     assembly {
         {
                 let i := 0  
                 let words := div(add(btsLen, 31), 32)
                 let rOffset := btsPtr
                 let wOffset := add(tgt, 0x20)
             tag_loop:
                 jumpi(end, eq(i, words))
                 {
                     let offset := mul(i, 0x20)
                     mstore(add(wOffset, offset), mload(add(rOffset, offset)))
                     i := add(i, 1)
                 }
                 jump(tag_loop)
             end:
                 mstore(add(tgt, add(0x20, mload(tgt))), 0)
         }
     }
 }

      
     function _validate(RLPItem memory self) private constant returns (bool ret) {
          
         uint b0;
         uint b1;
         uint memPtr = self._unsafe_memPtr;
         assembly {
             b0 := byte(0, mload(memPtr))
             b1 := byte(1, mload(memPtr))
         }
         if(b0 == DATA_SHORT_START + 1 && b1 < DATA_SHORT_START)
             return false;
         return true;
     }
}

 

 
pragma solidity ^0.4.8;


library MerklePatriciaProof {
   
  function verify(bytes value, bytes encodedPath, bytes rlpParentNodes, bytes32 root) internal constant returns (bool) {
    RLP.RLPItem memory item = RLP.toRLPItem(rlpParentNodes);
    RLP.RLPItem[] memory parentNodes = RLP.toList(item);

    bytes memory currentNode;
    RLP.RLPItem[] memory currentNodeList;

    bytes32 nodeKey = root;
    uint pathPtr = 0;

    bytes memory path = _getNibbleArray(encodedPath);
    if (path.length == 0) {return false;}

    for (uint i = 0; i < parentNodes.length; i++) {
      if (pathPtr > path.length) {return false;}

      currentNode = RLP.toBytes(parentNodes[i]);
      if (nodeKey != keccak256(currentNode)) {return false;}
      currentNodeList = RLP.toList(parentNodes[i]);

      if (currentNodeList.length == 17) {
        if (pathPtr == path.length) {
          if (keccak256(RLP.toBytes(currentNodeList[16])) == keccak256(value)) {
            return true;
          } else {
            return false;
          }
        }

        uint8 nextPathNibble = uint8(path[pathPtr]);
        if (nextPathNibble > 16) {return false;}
        nodeKey = RLP.toBytes32(currentNodeList[nextPathNibble]);
        pathPtr += 1;
      } else if (currentNodeList.length == 2) {
        pathPtr += _nibblesToTraverse(RLP.toData(currentNodeList[0]), path, pathPtr);

        if (pathPtr == path.length) { 
          if (keccak256(RLP.toData(currentNodeList[1])) == keccak256(value)) {
            return true;
          } else {
            return false;
          }
        }
         
        if (_nibblesToTraverse(RLP.toData(currentNodeList[0]), path, pathPtr) == 0) {
          return false;
        }

        nodeKey = RLP.toBytes32(currentNodeList[1]);
      } else {
        return false;
      }
    }
  }

  function _nibblesToTraverse(bytes encodedPartialPath, bytes path, uint pathPtr) private constant returns (uint) {
    uint len;
     
     
    bytes memory partialPath = _getNibbleArray(encodedPartialPath);
    bytes memory slicedPath = new bytes(partialPath.length);

     
     
    for (uint i=pathPtr; i<pathPtr+partialPath.length; i++) {
      byte pathNibble = path[i];
      slicedPath[i-pathPtr] = pathNibble;
    }

    if (keccak256(partialPath) == keccak256(slicedPath)) {
      len = partialPath.length;
    } else {
      len = 0;
    }
    return len;
  }

   
  function _getNibbleArray(bytes b) private constant returns (bytes) {
    bytes memory nibbles;
    if (b.length>0) {
      uint8 offset;
      uint8 hpNibble = uint8(_getNthNibbleOfBytes(0,b));
      if (hpNibble == 1 || hpNibble == 3) {
        nibbles = new bytes(b.length*2-1);
        byte oddNibble = _getNthNibbleOfBytes(1,b);
        nibbles[0] = oddNibble;
        offset = 1;
      } else {
        nibbles = new bytes(b.length*2-2);
        offset = 0;
      }

      for (uint i = offset; i < nibbles.length; i++) {
        nibbles[i] = _getNthNibbleOfBytes(i-offset+2,b);
      }
    }
    return nibbles;
  }
  
  
  function _getNthNibbleOfBytes(uint n, bytes str) private constant returns (byte) {
    return byte(n%2==0 ? uint8(str[n/2])/0x10 : uint8(str[n/2])%0x10);
  }
}

 

contract PeaceRelay {
  using RLP for RLP.RLPItem;
  using RLP for RLP.Iterator;
  using RLP for bytes;

  uint256 public genesisBlock;
  uint256 public highestBlock;
  address public owner;

  mapping (address => bool) authorized;
  mapping (uint256 => BlockHeader) public blocks;

  modifier onlyOwner() {
    if (owner == msg.sender) {
      _;
    }
  }

  modifier onlyAuthorized() {
    if (authorized[msg.sender]) {
      _;
    }
  }

  struct BlockHeader {
    uint      prevBlockHash;  
    bytes32   stateRoot;      
    bytes32   txRoot;         
    bytes32   receiptRoot;    
  }

  event SubmitBlock(uint256 blockHash, address submitter);

  constructor (uint256 blockNumber) public {
    genesisBlock = blockNumber;
    highestBlock = blockNumber;
    authorized[msg.sender] = true;
    owner = msg.sender;
  }

  function authorize(address user) onlyOwner public {
    authorized[user] = true;
  }

  function deAuthorize(address user) onlyOwner public {
    authorized[user] = false;
  }

  function resetGenesisBlock(uint256 blockNumber) onlyAuthorized public {
    genesisBlock = blockNumber;
    highestBlock = blockNumber;
  }

  function submitBlock(uint256 blockHash, bytes rlpHeader) onlyAuthorized public {
    BlockHeader memory header = parseBlockHeader(rlpHeader);
    uint256 blockNumber = getBlockNumber(rlpHeader);
    if (blockNumber > highestBlock) {
      highestBlock = blockNumber;
    }
    blocks[blockHash] = header;
     
    emit SubmitBlock(blockHash, msg.sender);
  }

  function checkTxProof(bytes value, uint256 blockHash, bytes path, bytes parentNodes) view public returns (bool) {
     
    bytes32 txRoot = blocks[blockHash].txRoot;
    return trieValue(value, path, parentNodes, txRoot);
  }

  function checkStateProof(bytes value, uint256 blockHash, bytes path, bytes parentNodes) view public returns (bool) {
    bytes32 stateRoot = blocks[blockHash].stateRoot;
    return trieValue(value, path, parentNodes, stateRoot);
  }

  function checkReceiptProof(bytes value, uint256 blockHash, bytes path, bytes parentNodes) view public returns (bool) {
    bytes32 receiptRoot = blocks[blockHash].receiptRoot;
    return trieValue(value, path, parentNodes, receiptRoot);
  }

  function parseBlockHeader(bytes rlpHeader) view internal returns (BlockHeader) {
    BlockHeader memory header;
    RLP.Iterator memory it = rlpHeader.toRLPItem().iterator();

    uint idx;
    while (it.hasNext()) {
      if (idx == 0) {
        header.prevBlockHash = it.next().toUint();
      } else if (idx == 3) {
        header.stateRoot = bytes32(it.next().toUint());
      } else if (idx == 4) {
        header.txRoot = bytes32(it.next().toUint());
      } else if (idx == 5) {
        header.receiptRoot = bytes32(it.next().toUint());
      } else {
        it.next();
      }
      idx++;
    }
    return header;
  }

  function getBlockNumber(bytes rlpHeader) view internal returns (uint blockNumber) {
    RLP.RLPItem[] memory rlpH = RLP.toList(RLP.toRLPItem(rlpHeader));
    blockNumber = RLP.toUint(rlpH[8]);
  }

  function getStateRoot(uint256 blockHash) view public returns (bytes32) {
    return blocks[blockHash].stateRoot;
  }

  function getTxRoot(uint256 blockHash) view public returns (bytes32) {
    return blocks[blockHash].txRoot;
  }

  function getReceiptRoot(uint256 blockHash) view public returns (bytes32) {
    return blocks[blockHash].receiptRoot;
  }

  function trieValue(bytes value, bytes encodedPath, bytes parentNodes, bytes32 root) view internal returns (bool) {
    return MerklePatriciaProof.verify(value, encodedPath, parentNodes, root);
  }

}

 

 
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
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

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

 

contract ETHToken is ERC20, Ownable {
    using SafeMath for uint256;
    using RLP for RLP.RLPItem;
    using RLP for RLP.Iterator;
    using RLP for bytes;
    
    struct Transaction {
        uint nonce;
        uint gasPrice;
        uint gasLimit;
        address to;
        uint value;
        bytes data;
    }
    
    struct ETHLockTxProof {
        bytes value;
        bytes32 blockhash;
        bytes path;
        bytes parentNodes;
    }
    
     
    string public name;
    string public symbol;
    uint8 public decimals;     
    string public version = "v0.1";
    uint public totalSupply;
    uint public DEPOSIT_GAS_MINIMUM = 500000;  
    bytes4 public LOCK_FUNCTION_SIG = 0xf435f5a7;

    mapping(address => uint) balances;
    mapping(address => mapping (address => uint)) allowed;
    mapping(bytes32 => bool) rewarded;

    PeaceRelay public ETHRelay;
    address public ETHLockingAddr;
    
    event Burn(address indexed from, address indexed ethAddr, uint indexed value);
    event Mint(address indexed to, uint value);
    
    constructor (address peaceRelayAddr) public {
        totalSupply = 0;
        name = "ETHToken";         
        symbol = "ETHT";            
        decimals = 9;              
        ETHRelay = PeaceRelay(peaceRelayAddr);
    }
    
    function changePeaceRelayAddr(address _peaceRelayAddr) onlyOwner public {
        ETHRelay = PeaceRelay(_peaceRelayAddr);
    }
    
    function changeETHLockingAddr(address _ETHLockingAddr) onlyOwner public {
        ETHLockingAddr = _ETHLockingAddr;
    }
    
    function mint(bytes value, uint256 blockHash, bytes path, bytes parentNodes) public returns (bool) {
        if (!rewarded[keccak256(value, bytes32(blockHash), path, parentNodes)] && ETHRelay.checkTxProof(value, blockHash, path, parentNodes)) {
            Transaction memory tx = getTransactionDetails(value);
            bytes4 functionSig = getSignature(tx.data);
          
            require(functionSig == LOCK_FUNCTION_SIG);
            require(tx.to == ETHLockingAddr);
            require(tx.gasLimit <= DEPOSIT_GAS_MINIMUM);

            address newAddress = getAddress(tx.data);

            totalSupply = totalSupply.add(tx.value);
            balances[newAddress] = balances[newAddress].add(tx.value);
            emit Mint(newAddress, tx.value);
            rewarded[keccak256(value, bytes32(blockHash), path, parentNodes)] = true;
            return true;
        }
        return false;
    }
    
    function burn(uint256 _value, address ethAddr) public returns (bool) {
         
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, ethAddr, _value);
        return true;
    }
    
    function checkIfRewarded(bytes value, uint256 blockHash, bytes path, bytes parentNodes) public view returns (bool) {
        return rewarded[keccak256(value, bytes32(blockHash),path,parentNodes)];
    }
    
    function checkProof(bytes value, uint256 blockHash, bytes path, bytes parentNodes) public view returns (bool) {
        return ETHRelay.checkTxProof(value, blockHash, path, parentNodes);
    }
    
    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }
    
    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint _value) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint) {
        return allowed[_owner][_spender];
    }
    
     
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
      
  
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

     
    
    function decreaseApproval(address _spender,uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

     
    function getSignature(bytes b) public pure returns (bytes4) {
        require(b.length >= 32);
        uint tmp = 0;
        for (uint i = 0; i < 4; i++) {
            tmp = tmp*(2**8)+uint8(b[i]);
        }
        return bytes4(tmp);
    }

     
     
    function getAddress(bytes b) public pure returns (address a) {
        if (b.length < 36) return address(0);
        assembly {
            let mask := 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            a := and(mask, mload(add(b, 36)))
             
             
        }
    }
    
     
    function getTransactionDetails(bytes txValue) view internal returns (Transaction memory tx) {
        RLP.RLPItem[] memory list = txValue.toRLPItem().toList();
        tx.gasPrice = list[1].toUint();
        tx.gasLimit = list[2].toUint();
        tx.to = address(list[3].toUint());
        tx.value = list[4].toUint();
    
         
        tx.data = new bytes(36);
        for (uint i = 0; i < 36; i++) {
            tx.data[i] = txValue[txValue.length - 103 + i];
        }
        return tx;
    }
}