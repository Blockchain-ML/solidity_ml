pragma solidity ^0.4.23;

 
contract LotteryTest {
    struct Bet {
        uint32 betType;  
        uint32 betHash;  
        uint32 blockNum;  
        uint192 value;  
    }
    mapping (address => Bet) bets;
    address[] private betaddrs;
    mapping(address => uint256) winners;
    
    uint256[][][] private betData;
    mapping(address => uint256) betDatas;

     
    uint public maxWin = 0;  
    uint public hashFirst = 0;  
    uint public hashLast = 0;  
    uint public hashNext = 0;  
    uint public hashBetSum = 0;  
    uint public hashBetMax = 5 ether;  
    uint[] public hashes;  
    uint public Periods = 0;  
    bool public betclose = true;  

     
    event LogBet(address indexed player, uint bettype, uint bethash, uint blocknumber, uint betsize, bool betclose);
    event getStatus(uint gnum,bool close);

  	address public owner;
    uint private latestBlockNumber;
    bytes32 private cumulativeHash;
    mapping(address => bool) public authorized;

    constructor() public {
		owner = msg.sender;
        authorized[owner] = true;
        latestBlockNumber = block.number;
        cumulativeHash = bytes32(0);
    }
    modifier onlyAuthorized() {
        require(authorized[msg.sender] || owner == msg.sender);
        _;
    }

    function addAuthorized(address _toAdd) onlyOwner public {
        require(_toAdd != 0);
        authorized[_toAdd] = true;
    }

    function removeAuthorized(address _toRemove) onlyOwner public {
        require(_toRemove != 0);
        require(_toRemove != msg.sender);
        authorized[_toRemove] = false;
    }

  	 
  	modifier onlyOwner() {
    	require(msg.sender == owner);
    	_;
  	}


    function getBetclose() constant external returns (bool) {
        return betclose;
    }

    function getPeriods() constant external returns (uint) {
        return Periods;
    }

     
    function setBetclose(bool _betclose) external onlyAuthorized {
        betclose = _betclose;
        emit getStatus(Periods,betclose);
    }
     
    function setPeriods(uint _periods) external onlyAuthorized {
        Periods = _periods;
        emit getStatus(Periods,betclose);
    }

     
    function resetBet() external onlyAuthorized {
        hashNext = block.number + 3;
        hashBetSum = 0;
    }

     
    function betValueOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].value);
    }

     
    function betHashOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].betHash);
    }

     
    function betBlockNumberOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].blockNum);
    }

    function placeBet(uint _type, uint _hash, uint _periods, uint _tik) public payable returns (uint ,uint) {
        uint _wei = msg.value;
        assert(betclose == false && _periods == Periods);
        uint _totalvalue=20000000000000000*_tik;
        assert(_wei == _totalvalue);
        return (_wei, _totalvalue);
         
         
         
         
         
         
         
         
         
         
    }
    function getbetData(uint _btype,uint _bnum,address _owner) constant external returns (uint) {
        return uint(betData[_btype][_bnum][uint256(_owner)]);
    }

    function drawWinner() public onlyAuthorized returns (address) {
        assert(betaddrs.length > 4);
        latestBlockNumber = block.number;
        bytes32 _finalHash = keccak256(abi.encodePacked(blockhash(latestBlockNumber-1), cumulativeHash));
        uint256 _randomInt = uint256(_finalHash) % betaddrs.length;
        address _winner = betaddrs[_randomInt];
        winners[_winner] = 20000000000000000 * betaddrs.length;
        cumulativeHash = bytes32(0);
        delete betaddrs;
        return _winner;
    }

    function withdraw() public onlyAuthorized returns (bool) {
        uint256 amount = winners[msg.sender];
        winners[msg.sender] = 0;
        if (msg.sender.send(amount)) {
            return true;
        } else {
            winners[msg.sender] = amount;
            return false;
        }
    }

    function getBet(uint256 betNumber) public view returns (address) {
        return betaddrs[betNumber];
    }

    function getNumberOfBets() public view returns (uint256) {
        return betaddrs.length;
    }
}