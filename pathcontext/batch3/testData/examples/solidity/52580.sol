pragma solidity 0.4.21;

interface MyTestToken {
    function transfer(address receiver, uint amount) external;

    function totalSupply() external constant returns (uint);
}
 
 
 
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

 
 
 
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Crowdsale is Owned, SafeMath {
    address owner;
    address tokenAddress;
    address escrowAddress;

     

    uint start = 1500379200;
    uint period = 28;
    uint amountPerEther = 750;

    function Crowdsale() public {
        owner = this;
        tokenAddress = 0x0;
        escrowAddress = 0x0;
    }

    function setTokenAddress(address newAddress)
    public onlyOwner returns (bool success) {
        tokenAddress = newAddress;

        return true;
    }

    function setEscrowAddress(address newAddress)
    public onlyOwner returns (bool success) {
        escrowAddress = newAddress;

        return true;
    }


    function getBalance() public constant returns (uint) {
        require(tokenAddress != 0x0);

        MyTestToken token = MyTestToken(tokenAddress);
         
        return token.totalSupply();
    }

    modifier isUnderHardCap() {
        _;
    }

    modifier saleIsOn() {
         
        _;
    }

    function contribute() public isUnderHardCap saleIsOn payable {
         
         
         
         
         
         
         

         

        MyTestToken token = MyTestToken(tokenAddress);
        token.transfer(msg.sender, safeMul(msg.value, amountPerEther));
         
        if (msg.value > 0) {
            require(escrowAddress != 0x0);
            if (!escrowAddress.send(msg.value)) revert();
        }
    }

    function() external payable {
        contribute();
    }
}