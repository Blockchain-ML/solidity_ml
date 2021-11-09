pragma solidity >=0.5.0;


interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
}

 
library FixedPoint {
     
     
    struct uq112x112 {
        uint224 _x;
    }

     
     
    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;

     
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

     
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

     
    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

     
     
    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

     
     
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

     
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

     
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }
}

 
library UniswapV2OracleLibrary {
    using FixedPoint for *;

     
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

     
    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

         
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
             
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
             
             
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
             
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}

contract UniswapV20OracleContract {
    function currentCumulativePrices(
        address pair
    ) external view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        return UniswapV2OracleLibrary.currentCumulativePrices(pair);
    }
    
    function debug1(
        address pair
    ) external view returns (
        uint price0Cumulative,
        uint price1Cumulative,
        uint32 blockTimestamp,
        uint reserve0,
        uint reserve1,
        uint32 blockTimestampLast
    ) {
        (price0Cumulative, price1Cumulative, blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(pair);
        (reserve0, reserve1, blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
    }
}