pragma solidity 0.4.25;

 

contract FisherYates {
    using SafeMath for uint;

    function range(uint length) internal pure returns (uint[] memory r) {
        r = new uint[](length);
        for (uint i = 0; i < r.length; i++) {
          r[i] = i;
        }
    }
    
    function normaliseCardIndices(uint[] d) internal pure returns (uint[]) {
        for (uint i = 0; i < d.length; i++) {
            d[i] = d[i] % 52;
        }
        
    }

    function random(uint _upper, uint _blockn, address entropy, uint index) internal view returns (uint randomNumber)
      {
        return maxRandom(_blockn, entropy, index) % _upper;
      }

    function maxRandom(uint _blockn, address entropy, uint index) internal view returns (uint randomNumber) {
        return uint256(keccak256(abi.encodePacked(blockhash(_blockn), entropy, index)));
    }

    function fisherYates(uint _decks) internal view returns (uint[] memory) {
        uint numCards = _decks * 52;
        uint[] memory r = normaliseCardIndices(range(numCards));
        uint n = r.length - 1;
        for (uint i = n; i > 0; i--) {
            uint j = random(i, block.number, msg.sender, numCards);
            uint tmp = r[i];
            r[i] = r[j];
            r[j] = tmp;
        }
        return r;
    }

    function shuffleNDecks(uint _decks) public view returns (uint[] memory) {
        return fisherYates(_decks);
    }
}


 

 
library SafeMath {

     
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }

     
    function div(uint a, uint b) internal pure returns (uint) {
         
        uint c = a / b;
         
        return c;
    }

     
    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

     
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}