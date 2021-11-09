pragma solidity ^0.4.24;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        uint256 c = a / b;
         
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface token {
    function transfer(address receiver, uint amount) external;
}

contract Ownable {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}


contract Switchable is Ownable {

    event On();
    event Off();

    bool public off = false;


     
    modifier whenOff() {
        require(!off);
        _;
    }

     
    modifier whenOn() {
        require(off);
        _;
    }

     
    function on() onlyOwner whenOff public {
        off = true;
        emit On();
    }

     
    function off() onlyOwner whenOn public {
        off = false;
        emit Off();
    }
}

contract OtherToken {
    function balanceOf(address _owner) constant public returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);
}

contract AirDropContract is Switchable {

    using SafeMath for uint256;

    token public tokenRewardContract;

    uint256 public totalAirDropToken;

    address public collectorAddress;

    mapping(address => uint256) public balanceOf;

    event FundTransfer(address backer, uint256 amount, bool isContribution);
    event Additional(uint amount);

     
    constructor(
        address _tokenRewardContract,
        address _collectorAddress
    ) public {
        totalAirDropToken = 1e7;
        tokenRewardContract = token(_tokenRewardContract);
        collectorAddress = _collectorAddress;
    }

     
    function() payable public {
        require(totalAirDropToken > 0);
        require(balanceOf[msg.sender] == 0);
        uint256 amount = getCurrentCandyAmount();
        require(amount > 0);

        totalAirDropToken = totalAirDropToken.sub(amount);
        balanceOf[msg.sender] = amount;

        tokenRewardContract.transfer(msg.sender, amount * 1e18);
        emit FundTransfer(msg.sender, amount, true);
    }

    function getCurrentCandyAmount() private view returns (uint256 amount){
        if (!off) {
            if (totalAirDropToken >= 200) {
                return 200;
            } else {
                return 0;
            }
        } else {
            if (totalAirDropToken >= 7.5e6) {
                return 200;
            } else if (totalAirDropToken >= 5e6) {
                return 150;
            } else if (totalAirDropToken >= 2.5e6) {
                return 100;
            } else if (totalAirDropToken >= 500) {
                return 50;
            } else {
                return 0;
            }
        }
    }

     
    function additional(uint256 amount) public onlyOwner {
        require(amount > 0);

        totalAirDropToken = totalAirDropToken.add(amount);
        emit Additional(amount);
    }

     
    function modifyCollectorAddress(address newCollectorAddress) public onlyOwner returns (bool) {
        collectorAddress = newCollectorAddress;
    }

     
    function collectBack() public onlyOwner {
        require(totalAirDropToken > 0);
        require(collectorAddress != 0x0);

        tokenRewardContract.transfer(collectorAddress, totalAirDropToken * 1e18);

        uint256 b = address(this).balance;
        collectorAddress.transfer(b);
        totalAirDropToken = 0;
    }


    function collectBack2() public onlyOwner {
        require(totalAirDropToken > 0);
        require(collectorAddress != 0x0);

        tokenRewardContract.transfer(collectorAddress, totalAirDropToken * 1e18);
        totalAirDropToken = 0;
    }

    function collectBack3() public onlyOwner {
        require(totalAirDropToken > 0);
        require(collectorAddress != 0x0);

        uint256 b = address(this).balance;
        collectorAddress.transfer(b);
    }


     
    function getTokenBalance(address tokenAddress, address who) view public returns (uint){
        OtherToken t = OtherToken(tokenAddress);
        return t.balanceOf(who);
    }

     
    function collectOtherTokens(address tokenContract) onlyOwner public returns (bool) {
        OtherToken t = OtherToken(tokenContract);

        uint256 b = t.balanceOf(address(this));
        return t.transfer(collectorAddress, b);
    }

}