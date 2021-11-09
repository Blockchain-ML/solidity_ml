pragma solidity ^0.4.24;


contract Ownable {

    address public owner;

    mapping(address => uint8) public operators;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor()public {
        owner = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    modifier onlyOperator() {
        require(operators[msg.sender] == uint8(1));
        _;
    }

     
    function operatorManager(address[] _operators,uint8 flag)
    public
    onlyOwner
    returns(bool){
        for(uint8 i = 0; i< _operators.length; i++) {
            if(flag == uint8(0)){
                operators[_operators[i]] = 1;
            } else {
                delete operators[_operators[i]];
            }
        }
    }

     
    function transferOwnership(address newOwner)
    public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }

}


 
contract Pausable is Ownable {

    event Pause();

    event Unpause();

    bool public paused = false;

     
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

     
    modifier whenPaused {
        require(paused);
        _;
    }

     
    function pause() public onlyOwner whenNotPaused
    returns (bool) {
        paused = true;
        emit Pause();
        return true;
    }

     
    function unpause() public onlyOwner whenPaused
    returns (bool) {
        paused = false;
        emit Unpause();
        return true;
    }
}

 
contract ERC20Token {

    function balanceOf(address _owner) constant public returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);
}

 
contract GuessBaseBiz is Pausable {



     

     
    event CreateGuess(uint256 indexed id, address indexed creator);

     
    event DepositAgent(address indexed participant, uint256 indexed id, uint256 optionId, uint256 totalBean);

     
    event PublishOption(uint256 indexed id, uint256 indexed optionId);

     
    event Abortive(uint256 indexed id);

    event CreateActivity(uint256 indexed id, address indexed creator);

    struct Guess {
         
        uint256 id;
         
        string info;
         
        uint8 disabled;
         
        uint256 startAt;
         
        uint256 endAt;
         
        uint8 finished;
         
        uint8 abortive;
         
        uint256 winMultiple;
    }

     
    struct AgentOrder {
        address participant;
        string ipfsBase58;
        string dataHash;
        uint256 bean;
    }

    struct Option {
         
        uint256 id;
         
        bytes32 name;
    }

     
    struct Activity {
         
        uint256 id;
         
        address creator;
         
        string title;
         
        uint256 startAt;
         
        uint256 endAt;
    }


     
    mapping (uint256 => mapping (uint256 => Guess)) public guesses;
     
    mapping (uint256 => Option[]) public options;
     
    mapping (uint256 => Activity) public activities;
     
    mapping (uint256 => uint256[]) public guessIds;

     
    mapping (uint256 => mapping (uint256 => AgentOrder[])) public agentOrders;

     
    mapping (uint256 => uint256) public guessTotalBean;

     
    mapping (uint256 => mapping(uint256 => uint256)) public optionTotalBean;

     
    enum GuessStatus {
         
        NotStarted,
         
        Progress,
         
        Deadline,
         
        Finished,
         
        Abortive
    }

     
    function disabled(uint256 id,uint256 activityId) public view returns(bool) {
        if(guesses[activityId][id].disabled == 0){
            return false;
        }else {
            return true;
        }
    }

    function showGuessIds(uint256 activityId) public view returns(uint256[]){
        return guessIds[activityId];
    }

     
    function getGuessStatus(uint256 guessId ,uint256 activityId)
    internal
    view
    returns(GuessStatus) {
        GuessStatus gs;
        Guess memory guess = guesses[activityId][guessId];
        uint256 _now = now;
        if(guess.startAt > _now) {
            gs = GuessStatus.NotStarted;
        } else if((guess.startAt <= _now && _now <= guess.endAt)
        && guess.finished == 0
        && guess.abortive == 0 ) {
            gs = GuessStatus.Progress;
        } else if(_now > guess.endAt && guess.finished == 0) {
            gs = GuessStatus.Deadline;
        } else if(_now > guess.endAt && guess.finished == 1 && guess.abortive == 0) {
            gs = GuessStatus.Finished;
        } else if(guess.abortive == 1 && guess.finished == 1){
            gs = GuessStatus.Abortive;
        }
        return gs;
    }

     
    function optionExist(uint256 guessId,uint256 optionId)
    internal
    view
    returns(bool){
        Option[] memory _options = options[guessId];
        for (uint8 i = 0; i < _options.length; i++) {
            if(optionId == _options[i].id){
                return true;
            }
        }
        return false;
    }

     
    function activityExist(uint256 activityId) internal view returns(bool){
        if(activities[activityId].id == uint256(0)){
            return false;
        }
        return true;
    }


    function() public payable {
    }


     
    function createActivity(uint256 _id,string _title,uint256 _startAt,uint256 _endAt)
    public
    whenNotPaused {
        require(!activityExist(_id), "The current activity already exists !!!");
        activities[_id] = Activity(_id,msg.sender,_title,_startAt,_endAt);
        emit CreateActivity(_id, msg.sender);
    }

     
    function auditActivity(uint256 _id,string _title,uint256 _startAt,uint256 _endAt)
    public
    onlyOwner
    whenNotPaused {
        require(activityExist(_id), "The current activity not exists !!!");
        Activity storage activity = activities[_id];
        activity.title = _title;
        activity.startAt = _startAt;
        activity.endAt = _endAt;

    }

     
    function createGuess(
        uint256 _id,
        uint256 _activityId,
        string _info,
        uint8 _disabled,
        uint256 _startAt,
        uint256 _endAt,
        uint256[] _optionId,
        bytes32[] _optionName,
        uint256 _winMultiple
    )
    public
    whenNotPaused {
        require(activityExist(_activityId), "The current activity not exists !!!");
        require(guesses[_activityId][_id].id == uint256(0), "The current guess already exists !!!");
        require(_optionId.length == _optionName.length, "please check options !!!");

        guesses[_activityId][_id] = Guess(
            _id,
            _info,
            _disabled,
            _startAt,
            _endAt,
            0,
            0,
            _winMultiple
        );
        Option[] storage _options = options[_id];
        for (uint8 i = 0;i < _optionId.length; i++) {
            require(!optionExist(_id,_optionId[i]),"The current optionId already exists !!!");
            _options.push(Option(_optionId[i],_optionName[i]));
        }
        uint256[] storage _guessIds = guessIds[_activityId];
        _guessIds.push(_id);
        emit CreateGuess(_id, msg.sender);
    }

     
    function auditGuess(uint256 _id,string _info,uint8 _disabled,uint256 _endAt,uint256 _winMultiple,uint256 _activityId)
    public
    onlyOwner
    {
        require(activityExist(_activityId), "The current activity not exists !!!");
        require(guesses[_activityId][_id].id != uint256(0), "The current guess not exists !!!");
        require(getGuessStatus(_id,_activityId) == GuessStatus.NotStarted, "The guess cannot audit !!!");
        Guess storage guess = guesses[_activityId][_id];
        guess.info = _info;
        guess.disabled = _disabled;
        guess.endAt = _endAt;
        guess.winMultiple = _winMultiple;
    }

     
    function depositAgent
    (
        uint256 id,
        uint256 activityId,
        uint256 optionId,
        string ipfsBase58,
        uint256 totalBean,
        string dataHash
    )
    public
    onlyOperator
    whenNotPaused
    returns (bool) {
        require(activityExist(activityId), "The current activity not exists !!!");
        require(guesses[activityId][id].id != uint256(0), "The current guess not exists !!!");
        require(optionExist(id, optionId),"The current optionId not exists !!!");
        require(!disabled(id,activityId), "The guess disabled!!!");
        require(getGuessStatus(id,activityId) == GuessStatus.Deadline, "The guess cannot participate !!!");
         
        AgentOrder[] storage _agentOrders = agentOrders[id][optionId];
        AgentOrder memory agentOrder = AgentOrder(msg.sender,ipfsBase58,dataHash,totalBean);
        _agentOrders.push(agentOrder);
         
        optionTotalBean[id][optionId] += totalBean;
         
        guessTotalBean[id] += totalBean;
        emit DepositAgent(msg.sender, id, optionId, totalBean);
        return true;
    }

     
    function publishOption(uint256 id, uint256 optionId ,uint256 activityId)
    public
    onlyOwner
    whenNotPaused
    returns (bool) {
        require(guesses[activityId][id].id != uint256(0), "The current guess not exists !!!");
        require(optionExist(id, optionId),"The current optionId not exists !!!");
        require(!disabled(id,activityId), "The guess disabled!!!");
        require(getGuessStatus(id,activityId) == GuessStatus.Deadline, "The guess cannot publish !!!");
        Guess storage guess = guesses[activityId][id];
        guess.finished = 1;
        emit PublishOption(id, optionId);
        return true;
    }


     
    function abortive(uint256 id,uint256 activityId)
    public
    onlyOwner
    returns(bool) {
        require(guesses[activityId][id].id != uint256(0), "The current guess not exists !!!");
        require(getGuessStatus(id,activityId) == GuessStatus.Progress ||
        getGuessStatus(id,activityId) == GuessStatus.Deadline, "The guess cannot abortive !!!");
        Guess storage guess = guesses[activityId][id];
        guess.abortive = 1;
        guess.finished = 1;
        emit Abortive(id);
        return true;
    }

}
contract MosesActivityContract is GuessBaseBiz {


    constructor(address[] _operators) public {
        for(uint8 i = 0; i< _operators.length; i++) {
            operators[_operators[i]] = uint8(1);
        }
    }

     
    function collectEtherBack(address collectorAddress) public onlyOwner {
        uint256 b = address(this).balance;
        require(b > 0);
        require(collectorAddress != 0x0);
        collectorAddress.transfer(b);
    }

     
    function collectOtherTokens(address tokenContract, address collectorAddress) onlyOwner public returns (bool) {
        ERC20Token t = ERC20Token(tokenContract);

        uint256 b = t.balanceOf(address(this));
        return t.transfer(collectorAddress, b);
    }

}