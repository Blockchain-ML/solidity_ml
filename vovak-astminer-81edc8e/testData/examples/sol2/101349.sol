 

 

pragma solidity 0.5.7;


 
library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);  
        uint256 c = a / b;
         

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

 

 

pragma solidity 0.5.7;



contract Aggregator {
    function latestAnswer() public view returns (int);
}


contract NXMDSValue {

    using SafeMath for uint;

     
     
    function read() public view returns (bytes32)
    {

         
        Aggregator aggregator = Aggregator(0x773616E4d11A78F511299002da57A0a94577F1f4);
        int rate = aggregator.latestAnswer();

         
        require(rate > 0, "Rate should be a positive integer");

         
         
        return bytes32(uint(10**36).div(uint(rate)));
    }
}