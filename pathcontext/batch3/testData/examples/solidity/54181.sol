pragma solidity 0.4.20;

contract Election {
     
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    
    }
    
    function hasvote() public constant returns(bool answer){
       answer = !voters[msg.sender];
       
       return answer;
    }

     
    mapping(address => bool) public voters;
     
     
    mapping(uint => Candidate) public candidates;
     
    uint public candidatesCount;

     
    event votedEvent (
        uint indexed _candidateId
    );

    function Election () public {
        addCandidate("Candidate XZ");
        addCandidate("Candidate 2");
    }

    function addCandidate (string _name) private {
        candidatesCount ++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }



    function vote (uint _candidateId) public {

         
        require(!voters[msg.sender]);

hasvote();

         
        require(_candidateId > 0 && _candidateId <= candidatesCount);

         
        voters[msg.sender] = true;

         
        candidates[_candidateId].voteCount ++;

         
        votedEvent(_candidateId);
        
hasvote();
    }
}