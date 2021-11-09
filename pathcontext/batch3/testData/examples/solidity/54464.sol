pragma solidity ^0.4.0;

 
library Integers {
     
    function parseInt(string _value) 
        public
        returns (uint _ret) {
        bytes memory _bytesValue = bytes(_value);
        uint j = 1;
        for(uint i = _bytesValue.length-1; i >= 0 && i < _bytesValue.length; i--) {
            assert(_bytesValue[i] >= 48 && _bytesValue[i] <= 57);
            _ret += (uint(_bytesValue[i]) - 48)*j;
            j*=10;
        }
    }
    
     
    function toString(uint _base) 
        internal
        returns (string) {
        bytes memory _tmp = new bytes(32);
        uint i;
        for(i = 0;_base > 0;i++) {
            _tmp[i] = byte((_base % 10) + 48);
            _base /= 10;
        }
        bytes memory _real = new bytes(i--);
        for(uint j = 0; j < _real.length; j++) {
            _real[j] = _tmp[i--];
        }
        return string(_real);
    }

     
    function toByte(uint8 _base) 
        public
        returns (byte _ret) {
        assembly {
            let m_alloc := add(msize(),0x1)
            mstore8(m_alloc, _base)
            _ret := mload(m_alloc)
        }
    }

     
    function toBytes(uint _base) 
        internal
        returns (bytes _ret) {
        assembly {
            let m_alloc := add(msize(),0x1)
            _ret := mload(m_alloc)
            mstore(_ret, 0x20)
            mstore(add(_ret, 0x20), _base)
        }
    }
}

pragma solidity ^0.4.18;


 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  constructor() public{
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

 

pragma solidity ^0.4.14;

library strings {
    struct slice {
        uint _len;
        uint _ptr;
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

     
    function toSlice(string self) internal pure returns (slice) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

     
    function len(bytes32 self) internal pure returns (uint) {
        uint ret;
        if (self == 0)
            return 0;
        if (self & 0xffffffffffffffffffffffffffffffff == 0) {
            ret += 16;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);
        }
        if (self & 0xffffffffffffffff == 0) {
            ret += 8;
            self = bytes32(uint(self) / 0x10000000000000000);
        }
        if (self & 0xffffffff == 0) {
            ret += 4;
            self = bytes32(uint(self) / 0x100000000);
        }
        if (self & 0xffff == 0) {
            ret += 2;
            self = bytes32(uint(self) / 0x10000);
        }
        if (self & 0xff == 0) {
            ret += 1;
        }
        return 32 - ret;
    }

     
    function toSliceB32(bytes32 self) internal pure returns (slice ret) {
         
        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x20))
            mstore(ptr, self)
            mstore(add(ret, 0x20), ptr)
        }
        ret._len = len(self);
    }

     
    function copy(slice self) internal pure returns (slice) {
        return slice(self._len, self._ptr);
    }

     
    function toString(slice self) internal pure returns (string) {
        string memory ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

     
    function len(slice self) internal pure returns (uint l) {
         
        uint ptr = self._ptr - 31;
        uint end = ptr + self._len;
        for (l = 0; ptr < end; l++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if(b < 0xE0) {
                ptr += 2;
            } else if(b < 0xF0) {
                ptr += 3;
            } else if(b < 0xF8) {
                ptr += 4;
            } else if(b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
    }

     
    function empty(slice self) internal pure returns (bool) {
        return self._len == 0;
    }

     
    function compare(slice self, slice other) internal pure returns (int) {
        uint shortest = self._len;
        if (other._len < self._len)
            shortest = other._len;

        uint selfptr = self._ptr;
        uint otherptr = other._ptr;
        for (uint idx = 0; idx < shortest; idx += 32) {
            uint a;
            uint b;
            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                 
                uint256 mask = uint256(-1);  
                if(shortest < 32) {
                  mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                }
                uint256 diff = (a & mask) - (b & mask);
                if (diff != 0)
                    return int(diff);
            }
            selfptr += 32;
            otherptr += 32;
        }
        return int(self._len) - int(other._len);
    }

     
    function equals(slice self, slice other) internal pure returns (bool) {
        return compare(self, other) == 0;
    }

     
    function nextRune(slice self, slice rune) internal pure returns (slice) {
        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }

        uint l;
        uint b;
         
        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }
        if (b < 0x80) {
            l = 1;
        } else if(b < 0xE0) {
            l = 2;
        } else if(b < 0xF0) {
            l = 3;
        } else {
            l = 4;
        }

         
        if (l > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }

        self._ptr += l;
        self._len -= l;
        rune._len = l;
        return rune;
    }

     
    function nextRune(slice self) internal pure returns (slice ret) {
        nextRune(self, ret);
    }

     
    function ord(slice self) internal pure returns (uint ret) {
        if (self._len == 0) {
            return 0;
        }

        uint word;
        uint length;
        uint divisor = 2 ** 248;

         
        assembly { word:= mload(mload(add(self, 32))) }
        uint b = word / divisor;
        if (b < 0x80) {
            ret = b;
            length = 1;
        } else if(b < 0xE0) {
            ret = b & 0x1F;
            length = 2;
        } else if(b < 0xF0) {
            ret = b & 0x0F;
            length = 3;
        } else {
            ret = b & 0x07;
            length = 4;
        }

         
        if (length > self._len) {
            return 0;
        }

        for (uint i = 1; i < length; i++) {
            divisor = divisor / 256;
            b = (word / divisor) & 0xFF;
            if (b & 0xC0 != 0x80) {
                 
                return 0;
            }
            ret = (ret * 64) | (b & 0x3F);
        }

        return ret;
    }

     
    function keccak(slice self) internal pure returns (bytes32 ret) {
        assembly {
            ret := keccak256(mload(add(self, 32)), mload(self))
        }
    }

     
    function startsWith(slice self, slice needle) internal pure returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        if (self._ptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let selfptr := mload(add(self, 0x20))
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }
        return equal;
    }

     
    function beyond(slice self, slice needle) internal pure returns (slice) {
        if (self._len < needle._len) {
            return self;
        }

        bool equal = true;
        if (self._ptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let selfptr := mload(add(self, 0x20))
                let needleptr := mload(add(needle, 0x20))
                equal := eq(sha3(selfptr, length), sha3(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
            self._ptr += needle._len;
        }

        return self;
    }

     
    function endsWith(slice self, slice needle) internal pure returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        uint selfptr = self._ptr + self._len - needle._len;

        if (selfptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }

        return equal;
    }

     
    function until(slice self, slice needle) internal pure returns (slice) {
        if (self._len < needle._len) {
            return self;
        }

        uint selfptr = self._ptr + self._len - needle._len;
        bool equal = true;
        if (selfptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
        }

        return self;
    }

    event log_bytemask(bytes32 mask);

     
     
    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr = selfptr;
        uint idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                uint end = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr >= end)
                        return selfptr + selflen;
                    ptr++;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr;
            } else {
                 
                bytes32 hash;
                assembly { hash := sha3(needleptr, needlelen) }

                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly { testHash := sha3(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

     
     
    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                ptr = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr <= selfptr)
                        return selfptr;
                    ptr--;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr + needlelen;
            } else {
                 
                bytes32 hash;
                assembly { hash := sha3(needleptr, needlelen) }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly { testHash := sha3(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

     
    function find(slice self, slice needle) internal pure returns (slice) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len -= ptr - self._ptr;
        self._ptr = ptr;
        return self;
    }

     
    function rfind(slice self, slice needle) internal pure returns (slice) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len = ptr - self._ptr;
        return self;
    }

     
    function split(slice self, slice needle, slice token) internal pure returns (slice) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
             
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

     
    function split(slice self, slice needle) internal pure returns (slice token) {
        split(self, needle, token);
    }

     
    function rsplit(slice self, slice needle, slice token) internal pure returns (slice) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
             
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }

     
    function rsplit(slice self, slice needle) internal pure returns (slice token) {
        rsplit(self, needle, token);
    }

     
    function count(slice self, slice needle) internal pure returns (uint cnt) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            cnt++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

     
    function contains(slice self, slice needle) internal pure returns (bool) {
        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
    }

     
    function concat(slice self, slice other) internal pure returns (string) {
        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

     
    function join(slice self, slice[] parts) internal pure returns (string) {
        if (parts.length == 0)
            return "";

        uint length = self._len * (parts.length - 1);
        for(uint i = 0; i < parts.length; i++)
            length += parts[i]._len;

        string memory ret = new string(length);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        for(i = 0; i < parts.length; i++) {
            memcpy(retptr, parts[i]._ptr, parts[i]._len);
            retptr += parts[i]._len;
            if (i < parts.length - 1) {
                memcpy(retptr, self._ptr, self._len);
                retptr += self._len;
            }
        }

        return ret;
    }
}


pragma solidity ^0.4.20;
 
 
 

 
 
contract Guesses is Ownable{
    using strings for *;
    address internal owner; 
    uint internal maxId = 4*(10**9); 
    uint private currentId=0; 
    uint internal winPercent=100; 
     
    
     
    struct Guess {
        address drawer; 
        uint id;  
        uint price; 
        uint startTimestamp; 
        uint endTimestamp;  
        uint totOptionNum; 
        bool stoped; 
        bool reward; 
        mapping(uint=>GuessOption) options; 
    }
    
     
    struct GuessOption{
        uint optionIndex; 
        uint totNum; 
        address[] players; 
        mapping(address=>uint) bets; 
        mapping(address=>uint) wins; 
    }
  
     
    mapping(uint=>Guess) internal allGuesses;
  
    bool private locked=false;
     
    modifier noReentrancy() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    constructor() public payable{
	}
	
	
	 
	function createGuess(uint _price, uint _startTimestamp, uint _endTimestamp, uint _totOptionNum) public returns (uint){
	    require(now<_startTimestamp && _endTimestamp>_startTimestamp);
	    require(_price>0);
	    uint _id=getNextGuessId();
	    allGuesses[_id].id=_id;
	    allGuesses[_id].drawer=msg.sender;
	    allGuesses[_id].price=_price *(10**15);
	    allGuesses[_id].startTimestamp=_startTimestamp;
	    allGuesses[_id].endTimestamp=_endTimestamp;
	    allGuesses[_id].totOptionNum =_totOptionNum;
	    for(uint i=1;i<=_totOptionNum;i++){
	        allGuesses[_id].options[i]=GuessOption({optionIndex:i,totNum:0,players:new address[](10)});
	    }
	    return _id;
	}
	
	 
	function getNextGuessId() internal noReentrancy returns(uint) {
	    uint result = ++currentId;
	    result=result<maxId?result:1;
	    return result;
	}
	
	 
    function modifyGuess(uint _id,uint _startTimestamp,uint _endTimestamp) public returns(bool){
        require(allGuesses[_id].startTimestamp>now && allGuesses[_id].drawer==msg.sender);
        allGuesses[_id].startTimestamp=_startTimestamp;
        allGuesses[_id].endTimestamp=_endTimestamp;
        return true;
    }
    
     
    function stopGuess(uint _id,bool stoped) public returns(bool){
        require(allGuesses[_id].endTimestamp>now && allGuesses[_id].drawer==msg.sender);
        allGuesses[_id].stoped=stoped;
        return true;
    }
    
      
	function setwinPercent(uint _winPercent) public onlyOwner returns(uint){
	    winPercent=_winPercent;
	    return _winPercent;
	}
	
	function getWinPercent() public view returns(uint){
	    return winPercent;
	}
	
	
    
     
    function guess(string bet) public payable returns(bool){
        var splits=splitStr(bet,";");
        uint totPrice=0;
        var intInfo=new uint[](splits.length*3);
        for(uint i=0;i<splits.length;i++){
            var singleBet=splitStr2Int(splits[i],",");
            totPrice +=allGuesses[singleBet[0]].price * singleBet[2] ;
            intInfo[i*3]=singleBet[0];
            intInfo[i*3+1]=singleBet[1];
            intInfo[i*3+2]=singleBet[2];
             
        }
        uint overspend = msg.value - totPrice;
        require(overspend > 0);
        
        for(uint j=0;j<splits.length;j++){
            innerGuess(intInfo[j*3],intInfo[j*3+1],intInfo[j*3+2],msg.sender);
        }
        
          
        if(overspend > 0) {
            msg.sender.transfer(overspend);
        }
        return true;
    }
    
    function innerGuess(uint _id,uint optionIndex,uint num,address player) internal{
        require(num>0);
        require(optionIndex<=allGuesses[_id].totOptionNum);
         
        require(allGuesses[_id].id==_id);
         
        require(!allGuesses[_id].stoped);
         
        require(allGuesses[_id].startTimestamp>now||allGuesses[_id].endTimestamp<now);
        
        GuessOption storage option=allGuesses[_id].options[optionIndex];
        option.optionIndex=optionIndex;
        option.totNum +=num;
        uint count=option.bets[player];
        if(count>0){
            option.bets[player]=count+num;
        }else{
            option.bets[player]=num;
            option.players.push(player);
        }
    }
    
    function splitStr(string oriStr,string _delim) internal returns(string[]){
        var s = oriStr.toSlice();
        var delim = _delim.toSlice();
        var parts = new string[](s.count(delim) + 1);
        for(uint i = 0; i < parts.length; i++) {
            parts[i] = s.split(delim).toString();
        }
        return parts;
    }
    
    function splitStr2Int(string oriStr,string _delim) public returns(uint[]){
        var s = oriStr.toSlice();
        var delim = _delim.toSlice();
        var parts = new uint[](s.count(delim) + 1);
        for(uint i = 0; i < parts.length; i++) {
            parts[i] = Integers.parseInt(s.split(delim).toString());
        }
        return parts;
    }
    
     
    function setGuessAnswer(string answers) public noReentrancy returns(bool){
        var splits=splitStr(answers,";");
        uint totWin=0;
        uint totLost=0;
        uint winOptionIndex;
        for(uint i=0;i<splits.length;i++){
            var singleGuess=splitStr2Int(splits[i],",");
            var guess=allGuesses[singleGuess[0]];
            winOptionIndex=singleGuess[1];
             
            require(guess.id==singleGuess[0]);
             
            require(guess.stoped||guess.endTimestamp>now);
            
            require(!guess.reward);
            guess.reward=true;
            totWin=0;
            totLost=0;
            for(uint j=1;j<=guess.totOptionNum;j++){
                if(j==winOptionIndex){
                    totWin +=guess.options[j].totNum * guess.price;
                }else{
                    totLost += guess.options[j].totNum * guess.price;
                }
            }
            var option=guess.options[winOptionIndex];
            for(uint x=0;x<option.players.length;x++){
                var player=option.players[x];
                 
                var winMoney=option.bets[player]*guess.price*(1+totLost/totWin)*winPercent/100;
                player.transfer(winMoney);
            }
        }
        
        return true;
    }
    
    
      
    function getGuessInfo(string ids) public view returns(string){
        var splits=splitStr2Int(ids,",");
        var result=new strings.slice[](splits.length);
        for(uint i=0;i<splits.length;i++){
            result[i]=getSingleGuessInfo(splits[i]).toSlice();
        }
        return strings.join(";".toSlice(),result);
    }
    
      
    function getSingleGuessInfo(uint id) internal view returns(string){
        if(allGuesses[id].id!=id){
            return "";
        }
         var options =allGuesses[id].options; 
         uint num=allGuesses[id].totOptionNum;
         
         var result=new strings.slice[](num+1);
         result[0]=Integers.toString(id).toSlice();
         for(uint i=1;i<=num;i++){
             var s=Integers.toString(options[i].totNum);
             if(bytes(s).length==0){
                 s="0";
             }
             result[i]=s.toSlice();
         }
         return strings.join(",".toSlice(),result);
    }

}