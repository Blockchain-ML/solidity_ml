pragma solidity 0.4.25;

 

 
contract Ownable {
    address public owner;
    address public dev;

     
    constructor() public {
        owner = msg.sender;
    }


     
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

     
    modifier onlyDev() {
        require(msg.sender == dev, "only dev");
        _;
    }

     
    modifier onlyDevOrOwner() {
        require(msg.sender == owner || msg.sender == dev, "only owner or dev");
        _;
    }

     
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

     
    function setDev(address newDev) onlyOwner public {
        if (newDev != address(0)) {
            dev = newDev;
        }
    }
}

 

 
 
 
 
 
 
 
 
library SafeMath {
    
     
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }


     
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }


     
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
    

     
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x, 1)) / 2);
        y = x;
        while (z < y) {
            y = z;
            z = ((add((x / z), z)) / 2);
        }
    }


     
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }


     
    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x == 0) {
            return (0);
        } else if (y == 0) {
            return (1);
        } else {
            uint256 z = x;
            for (uint256 i = 1; i < y; i++) {
                z = mul(z,x);
            }
            return (z);
        }
    }
}

 

 

contract TinyBanker is Ownable {
    using SafeMath for uint256;

    event RefundValue(address, uint256 value);
    event DepositValue(address investor, uint256 value);

    address public wallet;

    constructor(address _wallet)
        public
    {
        require(_wallet != address(0));
        wallet = _wallet;
    }

    mapping (address => uint256) public deposited;

    function deposit() public payable {
        emit DepositValue(msg.sender, msg.value);
    }

    function setWallet(address _wallet) onlyOwner public  {
        require(_wallet != address(0));
        wallet = _wallet;
    }

    function withDraw() onlyOwner public {
        wallet.transfer(address(this).balance);
        emit RefundValue(wallet, address(this).balance);
    }
}