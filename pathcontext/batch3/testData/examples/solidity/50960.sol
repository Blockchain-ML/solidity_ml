pragma solidity ^0.4.24;

library MerkleMap {

    using MerkleMap for *;

     
    struct Node {
        bytes32 k;
        bytes32 v;
        bytes32 l;
        bytes32 r;
    }

     
    function verify(Node[] memory _list, bytes32 _root) internal pure returns (bool) {
         
        if (_list.length == 0)
            return false;

         
        for (uint i = 0; i < _list.length - 1; i++) {
            if (hashNode(_list[i]) == _list[i + 1].l) {  
                 
                 
                if (_list[i].k.greaterHash(_list[i + 1].k))
                    return false;
            } else if (hashNode(_list[i]) == _list[i + 1].r) {  
                 
                if (_list[i + 1].k.greaterHash(_list[i].k))
                    return false;
            } else {  
                return false;
            }
        }
         
        return hashNode(_list[_list.length - 1]) == _root;
    }

     
    function insertRec(Node[] memory _p, bytes32 _k, bytes32 _v, bytes32 _r) internal pure returns (bytes32) {
         
        Node memory temp;
        kvSet(temp, _k, _v);
         
        bytes32 temp_hash = hashNode(temp);
        
         
        if (_p.length == 0)
            return temp_hash;

         
        bytes32 prev = hashNode(_p[0]);

         
        if (_k == _p[0].k) {  
            _p[0].v = _v;
        } else {  
            if (_k.keyGt(_p[0].k)) {  
                 
                require(_p[0].r == 0, "Insufficient proof");
                _p[0].r = temp_hash;
            } else {  
                 
                require(_p[0].l == 0, "Insufficient proof");
                _p[0].l = temp_hash;
            }
        }

         
        bytes32 cur = hashNode(_p[0]);

         
        (cur, prev) = updateRoot(_p, temp, 1, _k, cur, prev);

         
        require(prev == _r, "Invalid proof at root");
        return cur;
    }

     
    function updateRoot(Node[] memory _p, Node memory _temp, uint _i, bytes32 _k, bytes32 _cur, bytes32 _prev) private pure returns (bytes32, bytes32) {
         
        if (_i == _p.length)
            return(_cur, _prev);

         
        require(_k != _p[_i].k, "Invalid insert proof - key exists higher up in tree");

         
        copy(_temp, _p[_i]);
        if (_prev == _p[_i].l)  
            _temp.l = _cur;
        else if (_prev == _p[_i].r)  
            _temp.r = _cur;
        else  
            revert("Invalid proof");

         
        return updateRoot(_p, _temp, _i + 1, _k, hashNode(_temp), hashNode(_p[_i]));
    }

     
    function copy(Node memory _target, Node memory _src) private pure {
        assembly {
            mstore(_target, mload(_src))
            mstore(add(0x20, _target), mload(add(0x20, _src)))
            mstore(add(0x40, _target), mload(add(0x40, _src)))
            mstore(add(0x60, _target), mload(add(0x60, _src)))
        }
    }

    function keyGt(bytes32 _a, bytes32 _b) internal pure returns (bool) {
        return uint(keccak256(abi.encodePacked(_a))) > uint(keccak256(abi.encodePacked(_b)));
    }

    function kvSet(Node memory _n, bytes32 _k, bytes32 _v) internal pure {
        assembly {
            mstore(_n, _k)
            mstore(add(0x20, _n), _v)
            mstore(add(0x40, _n), 0)
            mstore(add(0x60, _n), 0) 
        }
    }

     
    function hashNode(Node memory _n) internal pure returns (bytes32 h) {
        assembly {  
            let temp := mload(_n)
            mstore(_n, keccak256(_n, 0x20))
            h := keccak256(_n, 0x80)
            mstore(_n, temp)
        }
    }

    function hash(bytes32 _a) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_a));
    }

    function greaterHash(bytes32 _a, bytes32 _b) internal pure returns (bool) {
        return uint(_a.hash()) > uint(_b.hash());
    }

    function greaterThan(bytes32 _a, bytes32 _b) internal pure returns (bool) {
        return uint(_a) > uint(_b);
    }
}

contract MerkleToken {

    using MerkleMap for *;

     
    bytes32 public root;

     
    uint public constant totalSupply = 1000;
    string public constant name = "MerkleToken";
    string public constant symbol  = "MTK";
    uint8 public constant decimals = 18;

    event RootUpdate(bytes32 indexed prev, bytes32 indexed cur);
    event Transfer(address indexed owner, address indexed recipient, uint amount);

    constructor () public {
        MerkleMap.Node[] memory nodes;
        root = nodes.insertRec(balanceLoc(msg.sender), bytes32(totalSupply), 0);
        emit RootUpdate(0, root);
    }

     
    function balanceLoc(address _owner) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_owner, "balances"));
    }

     
    function transfer(address _to, uint _amt, bytes32[4][] memory _s_proof, bytes32[4][] memory _r_proof) public {
         
        bytes32 s_loc = balanceLoc(msg.sender);
        bytes32 r_loc = balanceLoc(_to);

         
        uint s_bal = uint(_s_proof[0][1]);  
        require(s_bal >= _amt, "Insufficient funds");

         
        uint r_bal;
        if (_r_proof[0][0] == r_loc)  
            r_bal = uint(_r_proof[0][1]);
        require(r_bal + _amt >= r_bal, "Overflow in recipient balance");
        
        MerkleMap.Node[] memory path;
        assembly { path := _s_proof }

         
        bytes32 updated = path.insertRec(s_loc, bytes32(s_bal - _amt), root);
         
        assembly { path := _r_proof }
        updated = path.insertRec(r_loc, bytes32(r_bal + _amt), updated);

         
        emit RootUpdate(root, updated);
        emit Transfer(msg.sender, _to, _amt);
        root = updated;
    }

}