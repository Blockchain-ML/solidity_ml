pragma solidity 0.4.24;

contract SELTInterface{
    string public  name;
    uint256 public totalSupply;
    function () public payable;
    function balanceOf(address _owner) constant public returns(uint256);
    function transfer(address _to, uint256 _value) public returns(bool);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function burn(uint256 _value) public returns (bool success);
}

contract ElecR1 {

    SELTInterface SELT;
    
    string public  TokenName;
    address public TokenAddress = 0x7152bc3926b63f8fb32Ae2caa7E3b5A34bd40fc3;
    
     
    struct Candidate {
        uint8 id;
        string name;
        uint voteCount;
    }

     
    mapping(address => bool) public voters;
     
     
    mapping(uint8 => Candidate) public candidates;
     
    uint8 public candidatesCount = 0;
     
    uint public TotalVote;

    

    event SomeOneVoted(address indexed _from, address indexed _to, uint8 votes);

     
    event votedEvent (
        uint indexed _candidateId
    );
     
    modifier onlyValidAddress(address _to){
        require(_to != address(0x00));
        _;
    }

    modifier onlyValidSenderIsAcceptToken(address _to){
        require(_to == TokenAddress);
        _;
    }

    modifier onlyAccept5Vote(uint8 votes){
        require(countBit(votes) == 5);
        _;
    }


    constructor (
         
         
         
         
         
         
         
         
    ) 
    public {
         
        SELT = SELTInterface(TokenAddress);
        TokenName = SELT.name();
        addCandidate("_name1");
        addCandidate("_name2");
        addCandidate("_name3");
        addCandidate("_name4");
        addCandidate("_name5");
        addCandidate("_name6");
        addCandidate("_name7");
    }

    function countBit(uint8 data) private pure returns (uint8 totalBits){
        totalBits = 0;
        while (data > 0)
        {
            data &= (data - 1) ;
            totalBits++;
        }
        return totalBits;
    }

    function addCandidate (string _name) private {
        candidates[candidatesCount] = Candidate(uint8(1) << candidatesCount, _name, 0);
        candidatesCount ++;
    }

    function vote (uint8 _candidateid, address sender) public {
         
        require(!voters[sender]);


         
         

         
        candidates[_candidateid].voteCount ++;

         
        emit votedEvent(candidates[_candidateid].id);
    }
     
    function receiveApproval(address _from, uint8 votes
    )  
    onlyValidSenderIsAcceptToken(msg.sender)
     
    public {
        require(SELT.burn( 1 ));
        for(uint8 i = 0 ; i < 7; i++){
            if((votes & candidates[i].id) != 0){
                vote( i, _from );
            }
        }
        TotalVote += 1;
        emit SomeOneVoted(_from, this, votes);
    }

}