pragma solidity 0.4.24;

 

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

contract Token {
    function transfer(address _to, uint256 _value) public returns (bool);
}

contract LescovexProxySweeper is Ownable  {
    address public owner;

    constructor (address _owner) public {
        owner = _owner;
    }

    function () payable public {
        owner.transfer(msg.value);
    }

    function sweep(address _token, uint256 _amount) public onlyOwner {
        Token token = Token(_token);

        if(!token.transfer(owner, _amount)) {
            revert();
        }
    }
}