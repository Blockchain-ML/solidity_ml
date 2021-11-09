pragma solidity ^0.4.17;

 
contract VotingChallenge {
    uint public challengeDuration;
    uint public challengePrize;
    uint public creatorPrize;
    uint public challengeStarted;
    uint public candidatesNumber;
    address public creator;
    uint8 public creatorFee;     
    uint public winner;
    bool public isVotingPeriod;
    uint[] public votes;
    mapping( address => mapping (uint => uint)) public userVotesDistribution;

     
    modifier inVotingPeriod() {
        require(isVotingPeriod);
        _;
    }

    modifier afterVotingPeriod() {
        require(!isVotingPeriod);
        _;
    }

     
    event ChallengeBegan(address _creator, uint8 _creatorFee, uint _candidatesNumber, uint _challengeDuration);
    event NewVotesFor(uint _candidate, uint _votes);
    event TransferVotes(address _from, address _to, uint _candidateIndex, uint _votes);
    event EndOfChallenge(uint _winner, uint _winnerVotes, uint _challengePrize);
    event RewardWasPaid(address _participant, uint _amount);
    event CreatorRewardWasPaid(address _creator, uint _amount);

     
    function VotingChallenge() public {
        challengeDuration = 100;
        candidatesNumber = 3;
        votes.length = candidatesNumber + 1;  
        creator = msg.sender;
        creatorFee = 10;
        if(creatorFee > 100) creatorFee = 100;
        isVotingPeriod = true;
        challengeStarted = now;
        ChallengeBegan(creator, creatorFee, candidatesNumber, challengeDuration);
    }
    
     
    function getTime() public view returns (uint) {
        return now;
    }

     
    function getWinner() public view afterVotingPeriod returns (uint) {
        return winner;
    }

     
    function voteForCandidate(uint candidate) public payable inVotingPeriod {
        require(candidate <= candidatesNumber);
        require(candidate > 0);
        require(msg.value > 0);
         
         
         
         
        
         
        votes[candidate] += msg.value;

         
        userVotesDistribution[msg.sender][candidate] += msg.value;

         
        NewVotesFor(candidate, msg.value);
    }

     
    function transferVotes (address to, uint candidate) public inVotingPeriod {
        require(userVotesDistribution[msg.sender][candidate] > 0);
        uint votesToTransfer = userVotesDistribution[msg.sender][candidate];
        userVotesDistribution[msg.sender][candidate] = 0;
        userVotesDistribution[to][candidate] += votesToTransfer;
        
         
        TransferVotes(msg.sender, to, candidate, votesToTransfer);
    }

     
     
    function checkEndOfChallenge() public inVotingPeriod returns (bool) {
        if (challengeStarted + challengeDuration > now)
            return false;
        uint theWinner;
        uint winnerVotes;
        for (uint i = 1; i <= candidatesNumber; i++) {
            if (votes[i] > winnerVotes) {
                winnerVotes = votes[i];
                theWinner = i;
            }
        }
        winner = theWinner;
        creatorPrize = address(this).balance * creatorFee / 100;
        challengePrize = address(this).balance - creatorPrize;
        isVotingPeriod = false;

         
        EndOfChallenge(winner, winnerVotes, challengePrize);
        return true;
    }

     
    function getReward() public afterVotingPeriod {
        require(userVotesDistribution[msg.sender][winner] > 0);
        
         
        uint userVotesForWinner = userVotesDistribution[msg.sender][winner];
        userVotesDistribution[msg.sender][winner] = 0;
        uint reward = (challengePrize * userVotesForWinner) / votes[winner];
        msg.sender.transfer(reward);

         
        RewardWasPaid(msg.sender, reward);
    }

     
    function getCreatorReward() public afterVotingPeriod {
        require(creatorPrize > 0);
        require(msg.sender == creator);
        uint creatorReward = creatorPrize;
        creatorPrize = 0;
        msg.sender.transfer(creatorReward);

         
        CreatorRewardWasPaid(msg.sender, creatorReward);
    }
}