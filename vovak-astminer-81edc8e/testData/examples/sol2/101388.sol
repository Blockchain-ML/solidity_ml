pragma solidity ^0.6.0;

interface MemoryInterface {
    function getUint(uint _id) external returns (uint _num);
    function setUint(uint _id, uint _val) external;
}

contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
}


contract Helpers is DSMath {
     
    function getMemoryAddr() internal pure returns (address) {
        return 0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F;  
    }

     
    function getUint(uint getId, uint val) internal returns (uint returnVal) {
        returnVal = getId == 0 ? val : MemoryInterface(getMemoryAddr()).getUint(getId);
    }

     
    function setUint(uint setId, uint val) internal {
        if (setId != 0) MemoryInterface(getMemoryAddr()).setUint(setId, val);
    }

     
    function connectorID() public pure returns(uint _type, uint _id) {
        (_type, _id) = (1, 47);
    }
}

contract BasicResolver is Helpers {

     
    function addIds(uint[] calldata getIds, uint setId) external payable {
        uint amt;
        for (uint i = 0; i < getIds.length; i++) {
            amt = add(amt, getUint(getIds[i], 0));
        }

        setUint(setId, amt);
    }

     
    function subIds(uint getIdOne, uint getIdTwo, uint setId) external payable {
        uint amt = sub(getUint(getIdOne, 0), getUint(getIdTwo, 0));

        setUint(setId, amt);
    }
}

contract ConnectVariableMath is BasicResolver {
    string public name = "memory-variable-math-v1";
}