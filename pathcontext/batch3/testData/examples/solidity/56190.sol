pragma solidity ^0.4.24;

 

 
library Math {
     

     
    function max(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a >= _b ? _a : _b;
    }
}

 

 
library Merkle {
     
    
     
    function checkMembership(
        bytes32 _leaf,
        uint256 _index,
        bytes32 _rootHash,
        bytes _proof
    ) internal pure returns (bool) {
         
        require(_proof.length % 32 == 0);

         
        bytes32 proofElement;
        bytes32 computedHash = _leaf;
        uint256 index = _index;
        for (uint256 i = 32; i <= _proof.length; i += 32) {
            assembly {
                proofElement := mload(add(_proof, i))
            }
            if (_index % 2 == 0) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
            index = index / 2;
        }

         
        return computedHash == _rootHash;
    }
}

 

 
library ECRecovery {
     

     
    function recover(bytes32 _hash, bytes _sig) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

         
        if (_sig.length != 65) {
            return address(0);
        }

         
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }

         
        if (v < 27) {
            v += 27;
        }

         
        if (v != 27 && v != 28) {
            return address(0);
        } else {
            return ecrecover(_hash, v, r, s);
        }
    }
}

 

 
library ByteUtils {
     
    
     
    function concat(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bytes) {
        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let length := mload(_preBytes)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31)
            ))
        }

        return tempBytes;
    }

     
    function slice(bytes _bytes, uint _start, uint _length) internal pure returns (bytes) {
        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }
}

 

 
library RLPDecode {
     

    uint internal constant DATA_SHORT_START = 0x80;
    uint internal constant DATA_LONG_START = 0xB8;
    uint internal constant LIST_SHORT_START = 0xC0;
    uint internal constant LIST_LONG_START = 0xF8;

    uint internal constant DATA_LONG_OFFSET = 0xB7;
    uint internal constant LIST_LONG_OFFSET = 0xF7;

    struct RLPItem {
        uint _unsafe_memPtr;     
        uint _unsafe_length;     
    }

    struct Iterator {
        RLPItem _unsafe_item;    
        uint _unsafe_nextPtr;    
    }


     

     
    function toRLPItem(bytes memory self)
        internal
        pure
        returns (RLPItem memory)
    {
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

     
    function toRLPItem(bytes memory self, bool strict)
        internal
        pure
        returns (RLPItem memory)
    {
        RLPItem memory item = toRLPItem(self);
        if (strict) {
            uint len = self.length;
            if (_payloadOffset(item) > len) {
                revert();
            }
            if (_itemLength(item._unsafe_memPtr) != len) {
                revert();
            }
            if (!_validate(item)) {
                revert();
            }
        }
        return item;
    }

     
    function isNull(RLPItem memory self)
        internal
        pure
        returns (bool ret)
    {
        return self._unsafe_length == 0;
    }

     
    function isList(RLPItem memory self)
        internal
        pure
        returns (bool ret)
    {
        if (self._unsafe_length == 0) {
            return false;
        }
        uint memPtr = self._unsafe_memPtr;
        assembly {
            ret := iszero(lt(byte(0, mload(memPtr)), 0xC0))
        }
    }

     
    function isData(RLPItem memory self)
        internal
        pure
        returns (bool ret)
    {
        if (self._unsafe_length == 0) {
            return false;
        }
        uint memPtr = self._unsafe_memPtr;
        assembly {
            ret := lt(byte(0, mload(memPtr)), 0xC0)
        }
    }

     
    function isEmpty(RLPItem memory self)
        internal
        pure
        returns (bool ret)
    {
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

     
    function items(RLPItem memory self)
        internal
        pure
        returns (uint)
    {
        if (!isList(self)) {
            return 0;
        }
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

     
    function iterator(RLPItem memory self)
        internal
        pure
        returns (Iterator memory it)
    {
        if (!isList(self)) {
            revert();
        }
        uint ptr = self._unsafe_memPtr + _payloadOffset(self);
        it._unsafe_item = self;
        it._unsafe_nextPtr = ptr;
    }

     
    function toBytes(RLPItem memory self)
        internal
        view
        returns (bytes memory bts)
    {
        uint len = self._unsafe_length;
        if (len == 0) {
            return;
        }
        bts = new bytes(len);
        _copyToBytes(self._unsafe_memPtr, bts, len);
    }

     
    function toData(RLPItem memory self)
        internal
        view
        returns (bytes memory bts)
    {
        if (!isData(self)) {
            revert();
        }
        uint rStartPos;
        uint len;
        (rStartPos, len) = _decode(self);
        bts = new bytes(len);
        _copyToBytes(rStartPos, bts, len);
    }

     
    function toList(RLPItem memory self)
        internal
        pure
        returns (RLPItem[] memory list)
    {
        if (!isList(self)) {
            revert();
        }
        uint numItems = items(self);
        list = new RLPItem[](numItems);
        Iterator memory it = iterator(self);
        uint idx;
        while (_hasNext(it)) {
            list[idx] = _next(it);
            idx++;
        }
    }

     
    function toAscii(RLPItem memory self)
        internal
        view
        returns (string memory str)
    {
        if (!isData(self)) {
            revert();
        }
        uint rStartPos;
        uint len;
        (rStartPos, len) = _decode(self);
        bytes memory bts = new bytes(len);
        _copyToBytes(rStartPos, bts, len);
        str = string(bts);
    }

     
    function toUint(RLPItem memory self)
        internal
        pure
        returns (uint data)
    {
        if (!isData(self)) {
            revert();
        }
        uint rStartPos;
        uint len;
        (rStartPos, len) = _decode(self);
        if (len > 32) {
            revert();
        }
        assembly {
            data := div(mload(rStartPos), exp(256, sub(32, len)))
        }
    }

     
    function toBool(RLPItem memory self)
        internal
        pure
        returns (bool data)
    {
        if (!isData(self)) {
            revert();
        }
        uint rStartPos;
        uint len;
        (rStartPos, len) = _decode(self);
        if (len != 1) {
            revert();
        }
        uint temp;
        assembly {
            temp := byte(0, mload(rStartPos))
        }
        if (temp > 1) {
            revert();
        }
        return temp == 1 ? true : false;
    }

     
    function toByte(RLPItem memory self)
        internal
        pure
        returns (byte data)
    {
        if (!isData(self)) {
            revert();
        }
        uint rStartPos;
        uint len;
        (rStartPos, len) = _decode(self);
        if (len != 1) {
            revert();
        }
        uint temp;
        assembly {
            temp := byte(0, mload(rStartPos))
        }
        return byte(temp);
    }

     
    function toInt(RLPItem memory self)
        internal
        pure
        returns (int data)
    {
        return int(toUint(self));
    }

     
    function toBytes32(RLPItem memory self)
        internal
        pure
        returns (bytes32 data)
    {
        return bytes32(toUint(self));
    }

     
    function toAddress(RLPItem memory self)
        internal
        pure
        returns (address data)
    {
        if (!isData(self)) {
            revert();
        }
        uint rStartPos;
        uint len;
        (rStartPos, len) = _decode(self);
        if (len != 20) {
            revert();
        }
        assembly {
            data := div(mload(rStartPos), exp(256, 12))
        }
    }


     

     
    function _next(Iterator memory self)
        private
        pure
        returns (RLPItem memory subItem)
    {
        if (_hasNext(self)) {
            uint ptr = self._unsafe_nextPtr;
            uint itemLength = _itemLength(ptr);
            subItem._unsafe_memPtr = ptr;
            subItem._unsafe_length = itemLength;
            self._unsafe_nextPtr = ptr + itemLength;
        } else {
            revert();
        }
    }

     
    function _next(Iterator memory self, bool strict)
        private
        pure
        returns (RLPItem memory subItem)
    {
        subItem = _next(self);
        if (strict && !_validate(subItem)) {
            revert();
        }
        return;
    }

     
    function _hasNext(Iterator memory self)
        private
        pure
        returns (bool)
    {
        RLPItem memory item = self._unsafe_item;
        return self._unsafe_nextPtr < item._unsafe_memPtr + item._unsafe_length;
    }

     
    function _payloadOffset(RLPItem memory self)
        private 
        pure
        returns (uint)
    {
        if (self._unsafe_length == 0) {
            return 0;
        }
        uint b0;
        uint memPtr = self._unsafe_memPtr;
        assembly {
            b0 := byte(0, mload(memPtr))
        }
        if (b0 < DATA_SHORT_START) {
            return 0;
        }
        if (b0 < DATA_LONG_START || (b0 >= LIST_SHORT_START && b0 < LIST_LONG_START)) {
            return 1;
        }
        if (b0 < LIST_SHORT_START) {
            return b0 - DATA_LONG_OFFSET + 1;
        }
        return b0 - LIST_LONG_OFFSET + 1;
    }

     
    function _itemLength(uint memPtr)
        private
        pure
        returns (uint len)
    {
        uint b0;
        assembly {
            b0 := byte(0, mload(memPtr))
        }
        if (b0 < DATA_SHORT_START) {
            len = 1;
        }
        else if (b0 < DATA_LONG_START) {
            len = b0 - DATA_SHORT_START + 1;
        }
        else if (b0 < LIST_SHORT_START) {
            assembly {
                let bLen := sub(b0, 0xB7)  
                let dLen := div(mload(add(memPtr, 1)), exp(256, sub(32, bLen)))  
                len := add(1, add(bLen, dLen))  
            }
        }
        else if (b0 < LIST_LONG_START) {
            len = b0 - LIST_SHORT_START + 1;
        }
        else {
            assembly {
                let bLen := sub(b0, 0xF7)  
                let dLen := div(mload(add(memPtr, 1)), exp(256, sub(32, bLen)))  
                len := add(1, add(bLen, dLen))  
            }
        }
    }

     
    function _decode(RLPItem memory self)
        private
        pure
        returns (uint memPtr, uint len)
    {
        if (!isData(self)) {
            revert();
        }
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

     
    function _copyToBytes(uint btsPtr, bytes memory tgt, uint btsLen)
        private
        view
    {
         
         
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

     
    function _validate(RLPItem memory self)
        private
        pure
        returns (bool ret)
    {
         
        uint b0;
        uint b1;
        uint memPtr = self._unsafe_memPtr;
        assembly {
            b0 := byte(0, mload(memPtr))
            b1 := byte(1, mload(memPtr))
        }
        if (b0 == DATA_SHORT_START + 1 && b1 < DATA_SHORT_START) {
            return false;
        }
        return true;
    }
}

 

 
library RLPEncode {
     

     
    function encodeBytes(bytes memory self) internal pure returns (bytes) {
        bytes memory encoded;
        if (self.length == 1 && uint(self[0]) <= 128) {
            encoded = self;
        } else {
            encoded = ByteUtils.concat(encodeLength(self.length, 128), self);
        }
        return encoded;
    }

     
    function encodeAddress(address self) internal pure returns (bytes) {
        bytes memory inputBytes;
        assembly {
            let m := mload(0x40)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, self))
            mstore(0x40, add(m, 52))
            inputBytes := m
        }
        return encodeBytes(inputBytes);
    }

     
    function encodeUint(uint self) internal pure returns (bytes) {
        return encodeBytes(toBinary(self));
    }

     
    function encodeInt(int self) internal pure returns (bytes) {
        return encodeUint(uint(self));
    }

     
    function encodeBool(bool self) internal pure returns (bytes) {
        bytes memory encoded = new bytes(1);
        if (self) {
            encoded[0] = bytes1(1);
        }
        return encoded;
    }

     
    function encodeList(bytes[] memory self) internal pure returns (bytes) {
        bytes memory list = flatten(self);
        return ByteUtils.concat(encodeLength(list.length, 192), list);
    }

     
    function encodeLength(uint len, uint offset) private pure returns (bytes) {
        bytes memory encoded;
        if (len < 56) {
            encoded = new bytes(1);
            encoded[0] = byte(len + offset);
        } else {
            uint lenLen;
            uint i = 1;
            while (len / i != 0) {
                lenLen++;
                i *= 256;
            }

            encoded = new bytes(lenLen + 1);
            encoded[0] = byte(lenLen + offset + 55);
            for(i = 1; i <= lenLen; i++) {
                encoded[i] = byte((len / (256**(lenLen-i))) % 256);
            }
        }
        return encoded;
    }

     
    function toBinary(uint x) internal pure returns (bytes) {
        bytes memory b = new bytes(32);
        assembly { 
            mstore(add(b, 32), x) 
        }
        for (uint i = 0; i < 32; i++) {
            if (b[i] != 0) {
                break;
            }
        }
        bytes memory res = new bytes(32 - i);
        for (uint j = 0; j < res.length; j++) {
            res[j] = b[i++];
        }
        return res;
    }

     
    function memcpy(uint dest, uint src, uint len) private pure {
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

     
    function flatten(bytes[] memory self) private pure returns (bytes) {
        if (self.length == 0) {
            return new bytes(0);
        }

        uint len;
        for (uint i = 0; i < self.length; i++) {
            len += self[i].length;
        }

        bytes memory flattened = new bytes(len);
        uint flattenedPtr;
        assembly { flattenedPtr := add(flattened, 0x20) }

        for(i = 0; i < self.length; i++) {
            bytes memory item = self[i];
            
            uint selfPtr;
            assembly { selfPtr := add(item, 0x20)}

            memcpy(flattenedPtr, selfPtr, item.length);
            flattenedPtr += self[i].length;
        }

        return flattened;
    }
}

 

 
library PlasmaUtils {
    using RLPEncode for bytes;
    using RLPDecode for bytes;
    using RLPDecode for RLPDecode.RLPItem;


     

    uint256 constant internal BLOCK_OFFSET = 1000000000;
    uint256 constant internal TX_OFFSET = 10000;

    struct TransactionInput {
        uint256 blknum;
        uint256 txindex;
        uint256 oindex;
    }

    struct TransactionOutput {
        address owner;
        uint256 amount;
    }

    struct Transaction {
        TransactionInput[2] inputs;
        TransactionOutput[2] outputs;
    }

    
     

     
    function decodeTx(bytes memory _tx) internal pure returns (Transaction) {
        RLPDecode.RLPItem[] memory txList = _tx.toRLPItem().toList();
        RLPDecode.RLPItem[] memory inputs = txList[0].toList();
        RLPDecode.RLPItem[] memory outputs = txList[1].toList();

        Transaction memory decodedTx;
        for (uint i = 0; i < 2; i++) {
            RLPDecode.RLPItem[] memory input = inputs[i].toList();
            decodedTx.inputs[i] = TransactionInput({
                blknum: input[0].toUint(),
                txindex: input[1].toUint(),
                oindex: input[2].toUint()
            });

            RLPDecode.RLPItem[] memory output = outputs[i].toList();
            decodedTx.outputs[i] = TransactionOutput({
                owner: output[0].toAddress(),
                amount: output[1].toUint()
            });
        }

        return decodedTx;
    }

     
    function getBlockNumber(uint256 _utxoPosition) internal pure returns (uint256) {
        return _utxoPosition / BLOCK_OFFSET;
    }

     
    function getTxIndex(uint256 _utxoPosition) internal pure returns (uint256) {
        return (_utxoPosition % BLOCK_OFFSET) / TX_OFFSET;
    }

     
    function getOutputIndex(uint256 _utxoPosition) internal pure returns (uint8) {
        return uint8(_utxoPosition % TX_OFFSET);
    }

     
    function encodeUtxoPosition(
        uint256 _blockNumber,
        uint256 _txIndex,
        uint256 _outputIndex
    ) internal pure returns (uint256) {
        return (_blockNumber * BLOCK_OFFSET) + (_txIndex * TX_OFFSET) + (_outputIndex * 1);
    }

     
    function getInputPosition(TransactionInput memory _txInput) internal pure returns (uint256) {
        return encodeUtxoPosition(_txInput.blknum, _txInput.txindex, _txInput.oindex); 
    }

     
    function getDepositRoot(bytes _encodedDepositTx) internal pure returns (bytes32) {
        bytes32 root = keccak256(abi.encodePacked(_encodedDepositTx, new bytes(130)));
        bytes32 zeroHash = keccak256(abi.encodePacked(uint256(0)));
        for (uint256 i = 0; i < 10; i++) {
            root = keccak256(abi.encodePacked(root, zeroHash));
            zeroHash = keccak256(abi.encodePacked(zeroHash, zeroHash));
        }
        return root;
    }

     
    function getDepositTransaction(address _owner, uint256 _amount) internal pure returns (bytes) {
         
        bytes memory encodedInputs = "\xc8\xc3\x80\x80\x80\xc3\x80\x80\x80";
        bytes memory encodedSecondOutput = "\xd6\x94\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x80";
    
         
        bytes[] memory firstOutput = new bytes[](2);
        firstOutput[0] = RLPEncode.encodeAddress(_owner);
        firstOutput[1] = RLPEncode.encodeUint(_amount);
        bytes memory encodedFirstOutput = RLPEncode.encodeList(firstOutput);

         
        bytes[] memory outputs = new bytes[](2);
        outputs[0] = encodedFirstOutput;
        outputs[1] = encodedSecondOutput;
        bytes memory encodedOutputs = RLPEncode.encodeList(outputs);

         
        bytes[] memory transaction = new bytes[](2);
        transaction[0] = encodedInputs;
        transaction[1] = encodedOutputs;
        return RLPEncode.encodeList(transaction);
    }

     
    function validateSignatures(
        bytes32 _txHash,
        bytes _signatures,
        bytes _confirmationSignatures
    ) internal pure returns (bool) {
         
        require(_signatures.length % 65 == 0, "Invalid signature length.");
        require(_signatures.length == _confirmationSignatures.length, "Mismatched signature count.");

        for (uint256 offset = 0; offset < _signatures.length; offset += 65) {
             
            bytes memory signature = ByteUtils.slice(_signatures, offset, 65);
            bytes memory confirmationSigature = ByteUtils.slice(_confirmationSignatures, offset, 65);

             
            bytes32 confirmationHash = keccak256(abi.encodePacked(_txHash));
            if (ECRecovery.recover(_txHash, signature) != ECRecovery.recover(confirmationHash, confirmationSigature)) {
                return false;
            }
        }

        return true;
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

 

 
contract PriorityQueue {
    using SafeMath for uint256;

     

    address owner;
    uint256[] heapList;
    uint256 public currentSize;


     

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


     

    constructor() public {
        owner = msg.sender;
        heapList = [0];
        currentSize = 0;
    }


     

     
    function insert(uint256 _priority, uint256 _value) public onlyOwner {
        uint256 element = _priority << 128 | _value;
        heapList.push(element);
        currentSize = currentSize.add(1);
        _percUp(currentSize);
    }

     
    function getMin() public view returns (uint256, uint256) {
        return _splitElement(heapList[1]);
    }

     
    function delMin() public onlyOwner returns (uint256, uint256) {
        uint256 retVal = heapList[1];
        heapList[1] = heapList[currentSize];
        delete heapList[currentSize];
        currentSize = currentSize.sub(1);
        _percDown(1);
        heapList.length = heapList.length.sub(1);
        return _splitElement(retVal);
    }


     

     
    function _minChild(uint256 _index) private view returns (uint256) {
        if (_index.mul(2).add(1) > currentSize) {
            return _index.mul(2);
        } else {
            if (heapList[_index.mul(2)] < heapList[_index.mul(2).add(1)]) {
                return _index.mul(2);
            } else {
                return _index.mul(2).add(1);
            }
        }
    }

     
    function _percUp(uint256 _index) private {
        uint256 index = _index;
        uint256 j = index;
        uint256 newVal = heapList[index];
        while (newVal < heapList[index.div(2)]) {
            heapList[index] = heapList[index.div(2)];
            index = index.div(2);
        }
        if (index != j) heapList[index] = newVal;
    }

     
    function _percDown(uint256 _index) private {
        uint256 index = _index;
        uint256 j = index;
        uint256 newVal = heapList[index];
        uint256 mc = _minChild(index);
        while (mc <= currentSize && newVal > heapList[mc]) {
            heapList[index] = heapList[mc];
            index = mc;
            mc = _minChild(index);
        }
        if (index != j) heapList[index] = newVal;
    }

     
    function _splitElement(uint256 _element) private pure returns (uint256, uint256) {
        uint256 priority = _element >> 128;
        uint256 value = uint256(uint128(_element));
        return (priority, value);
    }
}

 

 
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

 

 
contract RootChain {
     

    event DepositCreated(
        address indexed owner,
        uint256 amount,
        uint256 depositBlock
    );

    event PlasmaBlockRootCommitted(
        uint256 blockNumber,
        bytes32 root
    );

    event ExitStarted(
        address indexed owner,
        uint256 utxoPosition,
        uint256 amount
    );


     

    uint256 constant public CHALLENGE_PERIOD = 1 weeks;
    uint256 constant public EXIT_BOND = 123456789;

    PriorityQueue exitQueue;
    uint256 public currentPlasmaBlockNumber;
    address public operator;

    mapping (uint256 => PlasmaBlock) public plasmaBlocks;
    mapping (uint256 => PlasmaExit) public plasmaExits;

    IERC20 token;

    struct PlasmaBlock {
        bytes32 root;
        uint256 timestamp;
    }

    struct PlasmaExit {
        address owner;
        uint256 amount;
        bool isStarted;
        bool isValid;
    }


     

    modifier onlyOperator() {
        require(msg.sender == operator, "Sender must be operator.");
        _;
    }

    modifier onlyWithValue(uint256 value) {
        require(msg.value == value, "Sent value must be equal to requried value.");
        _;
    }


     

    constructor(address _token) public {
        operator = msg.sender;
        currentPlasmaBlockNumber = 1;
        exitQueue = new PriorityQueue();
        token = IERC20(_token);
    }


     

     
    function deposit(uint256 _amount) public {
        require(_amount > 0, "Deposit value must be greater than zero.");

         
         
        require(token.transferFrom(msg.sender, address(this), _amount));

         
        bytes memory encodedDepositTx = PlasmaUtils.getDepositTransaction(msg.sender, _amount);

         
        plasmaBlocks[currentPlasmaBlockNumber] = PlasmaBlock({
            root: PlasmaUtils.getDepositRoot(encodedDepositTx),
            timestamp: block.timestamp
        });

        emit DepositCreated(msg.sender, _amount, currentPlasmaBlockNumber);
        currentPlasmaBlockNumber++;
    }

     
    function commitPlasmaBlockRoot(bytes32 _root) public onlyOperator {
        plasmaBlocks[currentPlasmaBlockNumber] = PlasmaBlock({
            root: _root,
            timestamp: block.timestamp
        });

        emit PlasmaBlockRootCommitted(currentPlasmaBlockNumber, _root);
        currentPlasmaBlockNumber++;
    }

     
    function startExit(
        uint256 _utxoBlockNumber,
        uint256 _utxoTxIndex,
        uint256 _utxoOutputIndex,
        bytes _encodedTx,
        bytes _txInclusionProof,
        bytes _txSignatures,
        bytes _txConfirmationSignatures
    ) public payable onlyWithValue(EXIT_BOND) {
        uint256 utxoPosition = PlasmaUtils.encodeUtxoPosition(_utxoBlockNumber, _utxoTxIndex, _utxoOutputIndex);
        PlasmaUtils.TransactionOutput memory transactionOutput = PlasmaUtils.decodeTx(_encodedTx).outputs[_utxoOutputIndex];

         
        require(transactionOutput.owner == msg.sender, "Only output owner can withdraw this output.");
        require(transactionOutput.amount > 0, "Output value must be greater than zero.");
        require(!plasmaExits[utxoPosition].isStarted, "Exit must not already exist.");

         
        bytes32 txHash = keccak256(_encodedTx);
        require(PlasmaUtils.validateSignatures(txHash, _txSignatures, _txConfirmationSignatures), "Signatures must match.");

         
        PlasmaBlock memory plasmaBlock = plasmaBlocks[_utxoBlockNumber];
        bytes32 merkleHash = keccak256(abi.encodePacked(_encodedTx, _txSignatures));
        require(Merkle.checkMembership(merkleHash, _utxoTxIndex, plasmaBlock.root, _txInclusionProof), "Transaction must be in block.");

         
        uint256 exitableAt = Math.max(plasmaBlock.timestamp + 2 weeks, block.timestamp + 1 weeks);

        exitQueue.insert(exitableAt, utxoPosition);
        plasmaExits[utxoPosition] = PlasmaExit({
            owner: transactionOutput.owner,
            amount: transactionOutput.amount,
            isStarted: true,
            isValid: true
        });

        emit ExitStarted(msg.sender, utxoPosition, transactionOutput.amount);
    }

     
    function challengeExit(
        uint256 _exitingUtxoBlockNumber,
        uint256 _exitingUtxoTxIndex,
        uint256 _exitingUtxoOutputIndex,
        bytes _encodedSpendingTx,
        bytes _spendingTxConfirmationSignature
    ) public {
        PlasmaUtils.Transaction memory transaction = PlasmaUtils.decodeTx(_encodedSpendingTx);
        uint256 exitingUtxoPosition = PlasmaUtils.encodeUtxoPosition(_exitingUtxoBlockNumber, _exitingUtxoTxIndex, _exitingUtxoOutputIndex);

         
        bool spendsExitingUtxo = false;
        for (uint8 i = 0; i < transaction.inputs.length; i++) {
            if (exitingUtxoPosition == PlasmaUtils.getInputPosition(transaction.inputs[i])) {
                spendsExitingUtxo = true;
                break;
            }
        }
        require(spendsExitingUtxo, "Transaction must spend exiting UTXO.");

         
        bytes32 confirmationHash = keccak256(abi.encodePacked(keccak256(_encodedSpendingTx)));
        address owner = plasmaExits[exitingUtxoPosition].owner;
        require(owner == ECRecovery.recover(confirmationHash, _spendingTxConfirmationSignature), "Transaction must be confirmed.");

         
        plasmaExits[exitingUtxoPosition].isValid = false;
    }

     
    function processExits() public {
        uint256 exitableAt;
        uint256 utxoPosition;

         
        while(exitQueue.currentSize() > 0){
            (exitableAt, utxoPosition) = exitQueue.getMin();

             
            if (exitableAt > block.timestamp){
                return;
            }

            PlasmaExit memory currentExit = plasmaExits[utxoPosition];

             
            if (currentExit.isValid){
                require(token.transfer(currentExit.owner, currentExit.amount));

                 
                delete plasmaExits[utxoPosition].owner;
            }

            exitQueue.delMin();
        }
    }
}