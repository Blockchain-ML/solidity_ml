pragma solidity ^0.4.22;

 

contract SampleToken {

     
    string public standard = "Token 0.1";
    string public name = "ZToken";
    string public symbol = "ZTK";
    uint8 public decimals = 0;
    uint256 public totalSupply;
    address public owner;

     
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    constructor() public {
        uint256 initialSupply = 100;
        balanceOf[msg.sender] = initialSupply;
        owner = msg.sender;

         
        totalSupply = initialSupply;
    }

     
    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);
         
        if (balanceOf[_to] + _value < balanceOf[_to]) revert();  
         
        balanceOf[msg.sender] -= _value;
         
        balanceOf[_to] += _value;
         
        emit Transfer(msg.sender, _to, _value);
         
    }
}

 

 
contract TokenVote1202 {
    uint[] internal options;
    mapping(uint => string) internal optionDescMap;
    bool internal isOpen;
    mapping (address => uint256) public weights;
    mapping (uint => uint256) public weightedVoteCounts;
    mapping (address => uint) public  ballots;
    SampleToken token;

     
    function init(address _tokenAddr, uint[] _options,
        address[] qualifiedVoters_) public {
        require(_options.length >= 2);
        options = _options;
        token = SampleToken(_tokenAddr);
        isOpen = true;
         
        for (uint i = 0; i < qualifiedVoters_.length; i++) {
            address voter = qualifiedVoters_[i];
            weights[voter] = token.balanceOf(voter);
        }

        optionDescMap[1] = "No";
        optionDescMap[2] = "Issue 100 more token";
        optionDescMap[3] = "Issue 200 more token";
    }

    function vote(uint option) public returns (bool success) {
        require(isOpen);
         

        uint256 weight = weights[msg.sender];
        weightedVoteCounts[option] += weight;   
        ballots[msg.sender] = option;
        emit OnVote(msg.sender, option);
        return true;
    }

    function setStatus(bool isOpen_) public returns (bool success) {
         
        isOpen = isOpen_;
        emit OnStatusChange(isOpen_);
        return true;
    }

    function ballotOf(address addr) public view returns (uint option) {
        return ballots[addr];
    }

    function weightOf(address addr) public view returns (uint weight) {
        return weights[addr];
    }

    function getStatus() public view returns (bool isOpen_) {
        return isOpen;
    }

    function weightedVoteCountsOf(uint option) public view returns (uint count) {
        return weightedVoteCounts[option];
    }

    function winningOption() public view returns (uint option) {
        uint ci = 0;
        for (uint i = 1; i < options.length; i++) {
            uint optionI = options[i];
            uint optionCi = options[ci];
            if (weightedVoteCounts[optionI] > weightedVoteCounts[optionCi]) {
                ci = i;
            }  
        }
        return options[ci];
    }

    function issueDescription() public pure returns (string desc) {
        return "Should we issue 100 more token?";
    }

    function availableOptions() public view returns (uint[] options_) {
        return options;
    }

    function optionDescription(uint option) public view returns (string desc) {
        return optionDescMap[option];
    }

    event OnVote(address indexed _from, uint _value);
    event OnStatusChange(bool newIsOpen);
    event DebugMsg(string msg);

}