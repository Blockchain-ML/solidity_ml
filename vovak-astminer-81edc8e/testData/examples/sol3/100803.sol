 

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;


interface IChainlink {
    function latestAnswer() external view returns (uint256);
}


 

contract ChainlinkLENDUSDCPriceOracleProxy {
    address public chainlink = 0x4aB81192BB75474Cf203B56c36D6a13623270A67;

    function getPrice() external view returns (uint256) {
        return IChainlink(chainlink).latestAnswer() / 100;
    }
}