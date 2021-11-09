pragma solidity ^0.4.24;

contract GasForwardInterface{
    function forwardGas(address behalfOf, uint cUsage) public;
}

contract ERC20VaultInterface{
    function internalTransfer(int delta, address target, address from) public;
}

 


contract OffchainRolling {
    
    GasForwardInterface GasForwarder;
    ERC20VaultInterface ERC20UserVault;
     
    mapping(address => uint) public txCount;
    mapping(address => bool) public notary;
    
    uint public minBet = 1e18;
    uint public maxBet = 100e18;
    
    address owner = msg.sender;

    constructor(address GF, address UV) public {
        GasForwarder = GasForwardInterface(GF);
        ERC20UserVault = ERC20VaultInterface(UV);
    }
    
    function ownerSetMinBet(uint n) public {
        require(msg.sender == owner);
        minBet = n;   
    }
    
    function ownerSetMaxBet(uint n) public {
        require(msg.sender == owner);
        maxBet = n;           
    }

    function setNotary(address newNotary, bool targ) public {
        require(msg.sender == owner);
        notary[newNotary] = targ;
    }
    
    function getHashedData(uint Nonce, uint Value, bytes32 UserSeed, bytes32 ServerSeed, uint Rolls) public pure returns (bytes32){
        return keccak256(abi.encodePacked(Nonce, Value, UserSeed, ServerSeed, Rolls));
    }

    function soliditySha3(bytes32 hash) public pure returns (bytes32){
        return keccak256(abi.encodePacked(hash));
    }

     
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function checkHash(bytes32 chainstart, bytes32 endstart, uint rolls) public pure returns (bool){
        bytes32 sHash = chainstart;
        for (uint i=0; i<rolls; i++){
            sHash = keccak256(abi.encodePacked(sHash));
        }
        return (sHash == endstart);
    }

    function internalDoRoll(bytes32 unHashedSeed, bytes32 UserSeed, uint Rolls, uint bet, uint Nonce) internal pure returns (int, bytes32){
        int delta=0;
        bytes32 cHash;
        bytes32 sHash = unHashedSeed;
        for (uint i=0; i<Rolls; i++){
            cHash = keccak256(abi.encodePacked(sHash,UserSeed,Nonce+i)); 
            sHash = keccak256(abi.encodePacked(sHash));
            if (uint(cHash) % 100 <=44){
                delta += int(bet);
            }
            else{
                delta -= int(bet);
            }
        }
        return (delta, sHash);
    }
    
    function externalCheckSign(bytes32 hash, bytes Recover, address Gambler) public {
        bytes32 realhash = prefixed(hash);
        require(ecverify(realhash, Recover, Gambler));
    }

    function _roll(address Gambler, uint Nonce, uint Value, bytes32 UserSeed, bytes32 ServerSeed, bytes Recover, bytes32 unHashedSeed, uint Rolls) public{
     
        require( (txCount[Gambler] == 0 && Nonce == 0) || txCount[Gambler] == (Nonce));
         
        txCount[Gambler] = txCount[Gambler]+1;  
         
        require(notary[tx.origin]);


        bytes32 hash = prefixed(getHashedData(Nonce, Value, UserSeed, ServerSeed, Rolls));
        require(ecverify(hash, Recover, Gambler));
        uint bet = Value / Rolls;
        require(bet >= minBet);
        require(bet <= maxBet);
        require(Rolls > 0);
        (int delta, bytes32 cHash) = internalDoRoll(unHashedSeed, UserSeed, Rolls, bet, Nonce);

        require(cHash == ServerSeed);  
        ERC20UserVault.internalTransfer(delta, Gambler, tx.origin);
        
    }
     
    function getData(bytes data) internal pure returns (bytes32[] rem) {
            bytes32[] memory out_b;
            uint len = data.length/32;
            if (data.length % 32 != 0){
                len += 1;
            }
            assembly {
                out_b := mload(0x40)
                mstore(0x40, add(mload(0x40), add(mul(len, 0x20), 0x40))) 
                mstore(out_b, len)
                for { let i := 0 } lt(i, len) { i := add(i, 0x1) } {
                    let mem_slot := add(out_b, mul(0x20, add(i,1)))
                    let load_slot := add(data,mul(0x20, add(i,1)))
                    mstore(mem_slot, mload(load_slot))
                }
            }
        return (out_b);
    }
    
    function roll_normal(address Gambler, uint Nonce,uint Value,bytes32 UserSeed,bytes32 ServerSeed, bytes Recover, bytes32 unHashedSeed, uint Rolls) public {
        uint gas = gasleft();
         
        _roll(Gambler, Nonce, Value, UserSeed, ServerSeed, Recover, unHashedSeed, Rolls);
        GasForwarder.forwardGas(Gambler, gas - gasleft());

    }
    
     
    
    
 

    function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (bool, address) {
        bool ret;
        address addr;

        assembly {
            let size := mload(0x40)
            mstore(size, hash)
            mstore(add(size, 32), v)
            mstore(add(size, 64), r)
            mstore(add(size, 96), s)
            ret := call(3000, 1, 0, size, 128, size, 32)
            addr := mload(size)
        }

        return (ret, addr);
    }

    function ecrecovery(bytes32 hash, bytes sig) internal returns (bool, address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (sig.length != 65)
          return (false, 0);

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        if (v < 27)
          v += 27;
        if (v != 27 && v != 28)
            return (false, 0);
        return safer_ecrecover(hash, v, r, s);
    }

    function ecverify(bytes32 hash, bytes sig, address signer) internal returns (bool) {
        bool ret;
        address addr;
        (ret, addr) = ecrecovery(hash, sig);
        return ret == true && addr == signer;
    }

}