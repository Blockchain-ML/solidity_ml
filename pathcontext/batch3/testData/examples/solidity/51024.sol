pragma solidity ^0.4.24;


 
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
    function Ownable() public {
        owner = msg.sender;
    }


     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


     
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract SafeMath {
    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) internal returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a < b ? a : b;
    }

}


 
library SafeMathLibExt {

    function times(uint a, uint b) returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function divides(uint a, uint b) returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function minus(uint a, uint b) returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function plus(uint a, uint b) returns (uint) {
        uint c = a + b;
        assert(c>=a);
        return c;
    }

}


contract Destructable is Ownable {

    function burn() public onlyOwner {
        selfdestruct(owner);
    }

}


contract TokensContract {
    function balanceOf(address who) public constant returns (uint256);
}

contract Insurance is Destructable, SafeMath  {

    uint start;
    uint payPeriodDays;
    uint rewardWeiCoefficient;
    uint256 buyPrice;
    address tokensContractAddress;
    uint256 amisDecimals;

    mapping (address => uint256) buyersBalances;

    struct ClientInsurance {
        uint256 tokensCount;
        bool isApplied;
        bool exists;
    }


    mapping(address => ClientInsurance) insurancesMap;
    uint256 clientsCount;


    function Insurance() public {
        tokensContractAddress = 0x949bed886c739f1a3273629b3320db0c5024c719;
        clientsCount = 0;
        start = 1536549366;
        payPeriodDays = 365;

         
        rewardWeiCoefficient = 1000000000;

         
        buyPrice = 50000000;

         
        amisDecimals = 1000000000;
    }

     
    function () public payable {
        revert();
    }

     
    function addEth() public payable onlyOwner {
    }

     
    function buy() public payable {
        require(buyersBalances[msg.sender] == 0);
        require(msg.value == buyPrice);
        require(hasTokens(msg.sender));

        buyersBalances[msg.sender] = safeAdd(buyersBalances[msg.sender], msg.value);
    }

    function isClient(address clientAddress) public constant onlyOwner returns(bool) {
        return insurancesMap[clientAddress].exists;
    }

    function addBuyer(address clientAddress, uint256 tokensCount) public onlyOwner {
        require( (clientAddress != address(0)) && (tokensCount > 0) );

         
        require(!insurancesMap[clientAddress].exists);

        insurancesMap[clientAddress] = ClientInsurance(tokensCount, false, true);
    }

    function claim(address to) public onlyOwner {

         
        require(now > start && now < start + payPeriodDays * 24 * 60 * 60);


         
        require( (to != address(0)) && (insurancesMap[to].exists) && (!insurancesMap[to].isApplied) );

         
        require(getTokensCount(to) >= insurancesMap[to].tokensCount);

         
        uint amount = getRewardWei(to);

        require(address(this).balance > amount);
        insurancesMap[to].isApplied = true;

        to.transfer(amount);
    }

     
    function setBuyPrice(uint256 priceWei) public onlyOwner {
        buyPrice = priceWei;
    }

     
    function setTokensContractAddress(address contractAddress) public onlyOwner {
        tokensContractAddress = contractAddress;
    }

     
    function getTokensContractAddress() public constant onlyOwner returns(address) {
        return tokensContractAddress;
    }

    function getRewardWei(address clientAddress) private constant returns (uint256) {
        uint tokensCount = insurancesMap[clientAddress].tokensCount;
        return safeMul(tokensCount, rewardWeiCoefficient);
    }

    function hasTokens(address clientAddress) private constant returns (bool) {
        return getTokensCount(clientAddress) > 0;
    }

    function getTokensCount(address clientAddress) private constant returns (uint256) {
        TokensContract tokensContract = TokensContract(tokensContractAddress);

        uint256 tcBalance = tokensContract.balanceOf(clientAddress);

        return safeDiv(tcBalance, amisDecimals);
    }
}