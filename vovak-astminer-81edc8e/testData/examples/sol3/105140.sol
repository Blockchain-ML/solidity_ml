 

pragma solidity ^0.5.0;

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
         
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

 

pragma solidity 0.5.16;


contract Event {

    using SafeMath for uint256;

    bytes5 constant public version = "2.2.0";
    uint8 constant private CLAPS_PER_ATTENDEE = 100;
    uint8 constant private MAX_ATTENDEES = 50;

    uint8 constant private ATTENDEE_UNREGISTERED = 0;
    uint8 constant private ATTENDEE_REGISTERED = 1;
    uint8 constant private ATTENDEE_CLAPPED = 2;
    bool distributionMade;

    uint64 public fee;
    uint32 public end;
    address payable[] private attendees;
    mapping(address => uint8) public states;
    mapping(address => uint256) public claps;
    uint256 public totalClaps;

    event Distribution (uint256 totalReward);
    event Transfer (address indexed attendee, uint256 reward);

    constructor (uint64 _fee, uint32 _end) public {
        require(block.timestamp < _end);
        fee = _fee;
        end = _end;
    }

    function getAttendees () external view returns (address payable[] memory) {
        return attendees;
    }

    function register (address payable _attendee, uint256 _fee) internal {
        require(_fee == fee);
        require(states[_attendee] == ATTENDEE_UNREGISTERED);
        require(attendees.length < MAX_ATTENDEES);
        require(block.timestamp < end);
        states[_attendee] = ATTENDEE_REGISTERED;
        attendees.push(_attendee);
        claps[_attendee] = 1;
        totalClaps += 1;
    }

    function register () external payable {
        register(msg.sender, msg.value);
    }

    function clap (
        address _clapper,
        address[] memory _attendees,
        uint256[] memory _claps
    ) internal {
        require(states[_clapper] == ATTENDEE_REGISTERED);
        require(_attendees.length == _claps.length);
        states[_clapper] = ATTENDEE_CLAPPED;
        uint256 givenClaps;
        for (uint256 i; i < _attendees.length; i = i.add(1)) {
            givenClaps = givenClaps.add(_claps[i]);
            if (_attendees[i] == _clapper) continue;
            if (states[_attendees[i]] == ATTENDEE_UNREGISTERED) continue;
            claps[_attendees[i]] = claps[_attendees[i]].add(_claps[i]);
        }
        require(givenClaps <= CLAPS_PER_ATTENDEE);
        totalClaps = totalClaps.add(givenClaps);
    }

    function clap (address[] calldata _attendees, uint256[] calldata _claps)
        external {
        clap(msg.sender, _attendees, _claps);
    }

    function distribute () external {
        require(distributionMade == false);
        require(block.timestamp >= end);
        require(totalClaps > 0);
        distributionMade = true;
        uint256 totalReward = address(this).balance;
        emit Distribution(totalReward);
        for (uint256 i; i < attendees.length; i = i.add(1)) {
            uint256 reward = claps[attendees[i]]
                .mul(totalReward)
                .div(totalClaps);
            (bool success, ) = attendees[i].call.value(reward)("");
            if (success) {
                emit Transfer(attendees[i], reward);
            }
        }
    }
}

 

pragma solidity 0.5.16;


contract ProxyEvent is Event {

    bytes5 constant public version = "2.0.0";
    mapping(address => address) public proxy;

    constructor(uint64 _fee, uint32 _end) Event(_fee, _end) public {}

    function registerFor (address payable _attendee) external payable {
        register(_attendee, msg.value);
        proxy[_attendee] = msg.sender;
    }

    function clapFor (
        address _clapper,
        address[] calldata _attendees,
        uint256[] calldata _claps
    ) external {
        require(proxy[_clapper] == msg.sender);
        clap(_clapper, _attendees, _claps);
    }
}