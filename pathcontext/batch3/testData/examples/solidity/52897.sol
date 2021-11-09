pragma solidity ^0.4.24;


 
contract Owned {
    address public owner;
    address public newOwner;
    mapping (address => bool) public admins;

    event OwnershipTransferred(
        address indexed _from, 
        address indexed _to
    );

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmins {
        require(admins[msg.sender]);
        _;
    }

    function transferOwnership(address _newOwner) 
        public 
        onlyOwner 
    {
        newOwner = _newOwner;
    }

    function acceptOwnership() 
        public 
    {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    function addAdmin(address _admin) 
        onlyOwner 
        public 
    {
        admins[_admin] = true;
    }

    function removeAdmin(address _admin) 
        onlyOwner 
        public 
    {
        delete admins[_admin];
    }

}


 
contract Pausable is Owned {
    event Pause();
    event Unpause();

    bool public paused = false;


     
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

     
    modifier whenPaused() {
        require(paused);
        _;
    }

     
    function pause() 
        onlyAdmins 
        whenNotPaused 
        public 
    {
        paused = true;
        emit Pause();
    }

     
    function unpause() 
        onlyAdmins 
        whenPaused 
        public 
    {
        paused = false;
        emit Unpause();
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
        assert(c / a == b);
        return c;
    }

     
    function div(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
         
         
         
        return a / b;
    }

     
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }

     
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        assert(c >= a);
        return c;
    }
}


 
contract Gateway is Pausable {
    using SafeMath for uint256;

    event Recharge(address indexed _user, uint256 indexed tatAmount);
    event Withdraw(address indexed _user, uint256 indexed tatAmount);
    event BackTo(address indexed _user, uint256 indexed tatAmount);

    address ERC20address;
    uint256 public lockTime = 1 days;
    mapping (address  => locker) lockers;

    struct locker{
        uint256 unlockTime;
        uint256 balance;
        bytes32 hashStr;
        address to;
    }


    constructor() public {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function setTatAddress(address _address)
        public
        onlyAdmins
    {
        ERC20address = _address;
    }

    function setLockTime(uint256 _time)
        public
        onlyAdmins
    {
        lockTime = _time;
    }


     
    function recharge(bytes32 _hash, uint256 _token, address _to) 
        public
        whenNotPaused
    {
        require(ERC20address != address(0), "Not nitialize");
        ERC20Interface token = ERC20Interface(ERC20address);

        if(token.transferFrom(msg.sender, address(this), _token)) {
            lockers[msg.sender].unlockTime = now.add(lockTime);
            lockers[msg.sender].balance = _token;
            lockers[msg.sender].hashStr = _hash;
            lockers[msg.sender].to = _to;
        }

        emit Recharge(msg.sender, _token);
    }

 
    function withdrawTo(string _key, address _addr)
        public
        whenNotPaused
    {
        bytes32 _hash = keccak256(abi.encodePacked(_key));
        require(_hash == lockers[_addr].hashStr, "key error");
        require(now < lockers[_addr].unlockTime, "unlocked");
        
        ERC20Interface token = ERC20Interface(ERC20address);

        if(token.transfer(lockers[_addr].to, lockers[_addr].balance)) {
            delete lockers[_addr];
        }

        emit Withdraw(lockers[_addr].to, lockers[_addr].balance);
    }


    function backTo(address _from)
        public
        whenNotPaused
    {
        require(lockers[_from].unlockTime >= now, "locked");
        
        ERC20Interface token = ERC20Interface(ERC20address);
        
        if(token.transfer(_from, lockers[_from].balance)) {
            delete lockers[msg.sender];
        }

        emit BackTo(msg.sender, lockers[msg.sender].balance);
    }
   
 
    function blanceOf(address _addr)
        public
        view
        returns (uint256)
    {
        return lockers[_addr].balance;
    }

    function getHashOf(address _addr)
        public
        view
        returns (bytes32)
    {   
        return  lockers[_addr].hashStr;
    }

    function getUnlockTime(address _addr)
        public
        view
        returns (uint256)
    {
        uint256 _time = lockers[_addr].unlockTime;
        require(_time > now, "end time");

        return _time.sub(now); 
    }

}

interface ERC20Interface {
    function transfer(address to, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
}