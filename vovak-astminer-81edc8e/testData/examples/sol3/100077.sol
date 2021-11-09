pragma solidity 0.6.6;


 
library Address {
     
    function isContract(address account) internal view returns (bool) {
        uint256 size;
         
         
         
         
         
         
         
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


interface Aggregator {
    function latestAnswer() external view returns(uint256);
    function latestTimestamp() external view returns(uint256);
}


contract OracleResolver {
    using Address for address;

    Aggregator aggr;

    uint256 internal constant expiration = 3 hours;

    constructor() public {
        if (address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419).isContract()) {
             
            aggr = Aggregator(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        } else revert();
    }

    function ethUsdPrice() public view returns (uint256) {
        require(now < aggr.latestTimestamp() + expiration, "Oracle data are outdated");
        return aggr.latestAnswer() / 1000;
    }
}