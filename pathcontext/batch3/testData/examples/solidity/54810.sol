pragma solidity 0.4.24;                                                                         
 
 

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

 
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

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 

 
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

 

 
 
 
contract Lockable is Ownable {

    bool public locked;

    modifier onlyWhenUnlocked() {
        require(!locked, "Contract is locked");
        _;
    }

     
     
    function lock() external onlyOwner {
        locked = true;
    }

     
     
    function unlock() external onlyOwner {
        locked = false;
    }
}

 

 
 
 
contract ERC900 {
    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
    event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);

    function stake(uint256 amount, bytes data) public;
    function stakeFor(address user, uint256 amount, bytes data) public;
    function unstake(uint256 amount, bytes data) public;
    function totalStakedFor(address addr) public view returns (uint256);
    function totalStaked() public view returns (uint256);
    function token() public view returns (address);
    function supportsHistory() public pure returns (bool);

     
    function lastStakedFor(address addr) public view returns (uint256);
    function totalStakedForAt(address addr, uint256 blockNumber) public view returns (uint256);
    function totalStakedAt(uint256 blockNumber) public view returns (uint256);
}

 

 
 
 
 
 
 
 
contract ODEMEvent is ERC900, Lockable {

    using SafeMath for uint256;

    ERC20 public token;
    uint public eventId;

    uint256 public totalStaked;
    mapping (address => uint256) public totalStakedFor;
    mapping (address => mapping (address => uint256)) public totalStakedForBy;

     
     
    mapping (address => address[]) internal stakedForRecipients;

     
     
     
    constructor(uint _eventId, address tokenAddr) public {
        require(tokenAddr != address(0), "tokenAddr must not be zero");
        require(_eventId > 0, "eventId must not be zero");
        token = ERC20(tokenAddr);
        eventId = _eventId;
    }

     
     
     
     
     
     
     
     
    function stake(uint256 amount, bytes data) public onlyWhenUnlocked {
        stakeFor(msg.sender, amount, data);
    }

     
     
     
     
     
     
     
     
     
    function stakeFor(address addr, uint256 amount, bytes data) public onlyWhenUnlocked {
        if (totalStakedForBy[addr][msg.sender] == 0) {
            stakedForRecipients[msg.sender].push(addr);
        }
        totalStaked = totalStaked.add(amount);
        totalStakedFor[addr] = totalStakedFor[addr].add(amount);
        totalStakedForBy[addr][msg.sender] = totalStakedForBy[addr][msg.sender].add(amount);

        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        emit Staked(addr, amount, totalStakedFor[addr], data);
    }

     
     
     
     
     
    function unstake(uint256 amount, bytes data) public onlyWhenUnlocked {
        unstakeFor(msg.sender, amount, data);
    }

     
     
     
     
     
     
    function unstakeFor(address addr, uint256 amount, bytes data) public onlyWhenUnlocked {
        require(totalStakedForBy[addr][msg.sender] >= amount, "Unstake amount greater than currently staked amount");

        totalStaked = totalStaked.sub(amount);
        totalStakedFor[addr] = totalStakedFor[addr].sub(amount);
        totalStakedForBy[addr][msg.sender] = totalStakedForBy[addr][msg.sender].sub(amount);

        require(token.transfer(msg.sender, amount), "Token transfer failed");

        emit Unstaked(addr, amount, totalStakedFor[addr], data);
    }

     
     
     
    function unstakeAll() public onlyWhenUnlocked {
        uint unstaked = 0;
        for (uint i = 0; i < stakedForRecipients[msg.sender].length; i++) {
            address addr = stakedForRecipients[msg.sender][i];
            uint amount = totalStakedForBy[addr][msg.sender];

            unstaked = unstaked.add(amount);
            totalStaked = totalStaked.sub(amount);
            totalStakedFor[addr] = totalStakedFor[addr].sub(amount);
            totalStakedForBy[addr][msg.sender] = 0;

            emit Unstaked(addr, amount, totalStakedFor[addr], "");
        }
        stakedForRecipients[msg.sender].length = 0;

        require(token.transfer(msg.sender, unstaked), "Token transfer failed");
    }

     
     
    function token() public view returns (address) {
        return token;
    }

     
     
     
    function totalStaked() public view returns (uint256) {
        return totalStaked;
    }

     
     
     
     
    function totalStakedFor(address addr) public view returns (uint256) {
        return totalStakedFor[addr];
    }

     
     
     
    function supportsHistory() public pure returns (bool) {
        return false;
    }

     
    function lastStakedFor(address addr) public view returns (uint256) {
        revert();
    }

     
    function totalStakedForAt(address addr, uint256 blockNumber) public view returns (uint256) {
        revert();
    }

     
    function totalStakedAt(uint256 blockNumber) public view returns (uint256) {
        revert();
    }
}

 

 
 
contract RBACInterface {
    function hasRole(address addr, string role) public view returns (bool);
}

 

 
 
contract RBACManaged is Ownable {

    RBACInterface public rbac;

     
    constructor(address rbacAddr) public {
        rbac = RBACInterface(rbacAddr);
    }

    function roleAdmin() internal pure returns (string);

     
     
     
     
    function hasRole(address addr, string role) public view returns (bool) {
        return rbac.hasRole(addr, role);
    }

    modifier onlyRole(string role) {
        require(hasRole(msg.sender, role), "Access denied: missing role");
        _;
    }

    modifier onlyOwnerOrAdmin() {
        require(
            msg.sender == owner || hasRole(msg.sender, roleAdmin()), "Access denied: missing role");
        _;
    }

     
     
     
    function setRBACAddress(address rbacAddr) public onlyOwnerOrAdmin {
        rbac = RBACInterface(rbacAddr);
    }
}

 

 
 
 
 
 
 
contract ODEMEventFactory is RBACManaged {

    event EventCreated(uint indexed eventId, address eventAddress);

    string constant ROLE_ADMIN = "events__admin";
    string constant ROLE_CREATOR = "events__creator";

    ERC20 public token;

    mapping(uint => address) public events;

     
     
     
    constructor(address tokenAddr, address rbacAddr) RBACManaged(rbacAddr) public {
        require(tokenAddr != address(0), "Token address must not be zero");
        token = ERC20(tokenAddr);
    }

     
     
     
     
     
    function deployEventContract(uint eventId) public returns (address) {
        ODEMEvent deployed = new ODEMEvent(eventId, token);
        deployed.transferOwnership(msg.sender);
        address eventAddress = address(deployed);
        return eventAddress;
    }

     
     
     
     
     
     
    function createEventUnsafe(uint eventId) public onlyRole(ROLE_CREATOR) returns (address) {
        address eventAddress = deployEventContract(eventId);
        events[eventId] = eventAddress;
        emit EventCreated(eventId, eventAddress);
        return eventAddress;
    }

     
     
     
     
     
     
     
    function createEvent(uint eventId) public onlyRole(ROLE_CREATOR) returns (address) {
        require(eventId > 0, "eventId must not be zero");
        require(events[eventId] == address(0), "eventId already in use");
        return createEventUnsafe(eventId);
    }

     
     
     
     
     
    function softRemoveEvent(uint eventId) public onlyRole(ROLE_CREATOR) {
        delete events[eventId];
    }

     
     
     
    function eventContractAddress(uint eventId) public view returns (address) {
        return events[eventId];
    }

    function roleAdmin() internal pure returns (string) {
        return ROLE_ADMIN;
    }
}