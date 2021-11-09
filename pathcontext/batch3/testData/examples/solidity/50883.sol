pragma solidity ^0.4.25;

 
 
 
contract Log {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event InterviewerTransferred(address indexed previousInterviewer, address indexed newInterviewer);
    
}
 
 
 
contract Ownable is Log {
    
    address public owner;
    address public interviewer;

    constructor() public {
        owner    = msg.sender;
        interviewer = 0x00006fdDd170B9B13e3FaA6b895998e280dF3540;
    }

    modifier onlyOwner() { require(msg.sender == owner); _; }
    modifier onlyInterviewer() { require(msg.sender == interviewer); _; }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
  
    function transferInterviewer(address _newInterviewer) external onlyOwner {
        require(_newInterviewer != address(0));
        emit InterviewerTransferred(interviewer, _newInterviewer);
        interviewer = _newInterviewer;
    }
}
 
 
 
 
 
contract BLiKTHON is Log, Ownable {
    
    mapping(uint32 => Applicant) ApplicantList;
    
    struct Applicant {
        uint64      name;
        uint32      birth;
        uint64      fingerprint;
        uint64      portfolioURL;
        bool[1]     confirmRound;
        uint8[1]    score;
    }
    
    function SetApplicant(uint32[] _ApplicantNumber, uint64[] _name, uint32[] _birth, uint64[] _fingerprint, uint64[] _portfolioURL) external onlyOwner {
        
        for (uint16 ui = 0; ui < _ApplicantNumber.length; ui++) {
            ApplicantList[_ApplicantNumber[ui]].name = _name[ui];
            ApplicantList[_ApplicantNumber[ui]].birth = _birth[ui];
            ApplicantList[_ApplicantNumber[ui]].fingerprint = _fingerprint[ui];
            ApplicantList[_ApplicantNumber[ui]].portfolioURL = _portfolioURL[ui];
        }
    }
    
    function GetApplicant(uint32 _ApplicantNumber) external view returns(uint64, uint32, uint64, uint64) {
        return (ApplicantList[_ApplicantNumber].name, ApplicantList[_ApplicantNumber].birth, ApplicantList[_ApplicantNumber].fingerprint, ApplicantList[_ApplicantNumber].portfolioURL);
    }
    
     
    function SetEvaluate(uint32 _ApplicantNumber, uint8 _round, uint8 _score) external onlyInterviewer {
        require(ApplicantList[_ApplicantNumber].score.length >= _round);
        
        ApplicantList[_ApplicantNumber].score[_round] = _score;
    }
    
    function GetEvaluate(uint32 _ApplicantNumber, uint8 _round) external view returns(uint8) {
        return ApplicantList[_ApplicantNumber].score[_round];
    }
    
     
    function SetConfirmRound(uint32 _ApplicantNumber, uint8 _round, bool _successOrFailure) external onlyInterviewer {
        require(ApplicantList[_ApplicantNumber].confirmRound.length >= _round);
        
        ApplicantList[_ApplicantNumber].confirmRound[_round] = _successOrFailure;
    }
    
    function GetConfirmRound(uint32 _ApplicantNumber, uint8 _round) external view returns(bool) {
        return ApplicantList[_ApplicantNumber].confirmRound[_round];
    }
}