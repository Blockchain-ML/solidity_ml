pragma solidity ^0.4.18;

 
 
 
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);  
         
         
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}



interface token {
    function balanceOf(address who) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
}

contract Crowdsale {
    using SafeMath for uint256;

     
    address public wallet;

     
    address public contractAddress;

     
    token public tokenReward;

     
    uint256 public crowdSaleCoeff;

     
    uint public startDate;
    uint public endDate;

     
     


    function Crowdsale() public{
        wallet = msg.sender;
        contractAddress = address(0x8e72A97a158ACD1E7E14a7802e289f23afA54e24);
        tokenReward = token(contractAddress);
        crowdSaleCoeff = 8000000;
        startDate = now;
        endDate = now + 1 weeks;
    }

    function () public payable {
        require(msg.value > 0);
        require(startDate <= now && now <= endDate);
        uint256 numTokens = SafeMath.mul(msg.value, crowdSaleCoeff);
        require(numTokens <= tokenReward.balanceOf(wallet)); 
        tokenReward.transferFrom(wallet, msg.sender, numTokens);
        wallet.transfer(msg.value);
    }
 }