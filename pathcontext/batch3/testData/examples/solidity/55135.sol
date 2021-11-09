pragma solidity ^0.4.25;

 

 
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

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

   
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

   
  function owner() public view returns(address) {
    return _owner;
  }

   
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

   
  function isOwner() public view returns(bool) {
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

 

contract Vote is Ownable {
    using SafeMath for uint256;

    struct Ballot {
        uint256 weight;
        bool voted;
        bool vote;
    }

    uint256 public votesInFavor;
    uint256 public votesAgainst;
    
    mapping(address => Ballot) private ballotByAddress;
    address[] private voters;

    uint256 public endtime;
    string public proposal;

    modifier activeVote {
         
        require(endtime > now, "should be an active vote");
        _;
    }

    modifier inactiveVote {
         
        require(now > endtime, "should be an inactive vote");
        _;
    }

    constructor(uint _endtime, string _proposal, address[] _voters) public {
        endtime = _endtime;
        proposal = _proposal;

        for(uint i = 0; i < _voters.length; i++) {
            ballotByAddress[_voters[i]] = Ballot(1, false, false);
        }

        voters = _voters; 
    }

    function countAbstentions() internal view returns(uint256) {
        return (voters.length.sub(votesAgainst)).sub(votesInFavor);
    }

    function getResult() public view inactiveVote returns(bool) {
         
        require(now > endtime, "vote has not ended, yet");
        return (votesInFavor > votesAgainst.add(countAbstentions()));
    }

    function submitBallot(bool _vote) public activeVote returns(bool) {
         
        require(ballotByAddress[msg.sender].voted == false, "has already voted");
        uint256 weight = ballotByAddress[msg.sender].weight;
        require(weight > 0, "voter has to have voting rights");
        ballotByAddress[msg.sender].voted = true;
        ballotByAddress[msg.sender].vote = _vote;

        if(_vote == true) {
            votesInFavor = votesInFavor.add(weight);
        } else {
            votesAgainst = votesAgainst.add(weight);
        }

        return true;
    }

    function getBallotOfSender() public view returns(uint256, bool, bool) {
        Ballot storage ballot = ballotByAddress[msg.sender];
        return (ballot.weight, ballot.voted, ballot.vote);
    }
}