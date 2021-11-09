pragma solidity ^0.4.24;

 
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

 
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

     
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Subscription is Ownable {
    using SafeMath for uint256;

    address private _wallet;
    uint256 private _periodDuration;
    uint256 private _price;
    uint256 private _count;

    mapping (address => subscriber) public subscribers;
    mapping (address => bool) public isExist;

    struct subscriber {
        bool _status;
        uint256 _endDate;
    }

    constructor (address wallet, uint256 periodDuration, uint256 price) public {
        require(wallet != address(0));
        require(periodDuration > 0);
        require(price > 0);
        _wallet = wallet;
        _periodDuration = periodDuration;
        _price = price;
    }

    function getCountSubscribers() public onlyOwner view returns (uint256) {
        return _count;
    }

    function wallet() public view returns (address) {
        return _wallet;
    }

    function updateWallet(address newWallet) public onlyOwner {
        require(newWallet != address(0));
        _wallet = newWallet;
    }

    function periodDuration() public view returns (uint256) {
        return _periodDuration;
    }

    function updatePeriodDuration(uint256 newPeriodDuration) public onlyOwner {
        require(newPeriodDuration > 0);
        _periodDuration = newPeriodDuration;
    }

    function price() public view returns (uint256) {
        return _price;
    }

    function updatePrice(uint256 newPrice) public onlyOwner {
        require(newPrice > 0);
        _price = newPrice;
    }

    function subscribe() public payable {
        require(msg.value == _price);
        require(!isExist[msg.sender]);
        subscribers[msg.sender] = subscriber(true, block.timestamp.add(_periodDuration));
        isExist[msg.sender] = true;
        _count++;
    }

    function updateSubscription(address _address, bool _status, uint256 _endDate) public onlyOwner {
        require(isExist[msg.sender]);
        require(_address != address(0));
        require(_endDate > 0);
        subscribers[_address] = subscriber(_status, _endDate);
    }
}