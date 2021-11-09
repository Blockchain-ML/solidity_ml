pragma solidity ^0.4.23;

 
contract LotteryTest {
    struct Bet {
        uint8 betType;  
        uint8 betHash;  
        uint8 blockNum;  
        uint value;  
    }
    mapping (address => Bet) bets;
    address[] private betaddrs;
    mapping(address => uint256) winners;
    
    int256[][][] private betData;
    mapping(address => uint256) betDatas;

     
    uint public maxWin = 0;  
    uint public hashFirst = 0;  
    uint public hashLast = 0;  
    uint public hashNext = 0;  
    uint public hashBetSum = 0;  
    uint public hashBetMax = 5 ether;  
    uint[] public hashes;  
    uint8 public Periods = 0;  
    bool public betclose = true;  

     
    event LogBet(address indexed player, uint8 bettype, uint8 bethash, uint blocknumber, uint betsize, bool betclose);
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
        require(betclose != _betclose);
        betclose = _betclose;
        emit getStatus(Periods,betclose);
    }
     
    function setPeriods(uint8 _periods) external onlyAuthorized {
        require(_periods != Periods && betclose==true);
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

    function placeBet(uint8 _type, uint8 _hash, uint8 _periods, int _tik) public payable returns (bool) {
        uint _wei = msg.value;
        require(betclose == false && _periods == Periods);
         
        
        require(_wei == 20000000000000000);
         

        cumulativeHash = keccak256(abi.encodePacked(blockhash(latestBlockNumber), cumulativeHash));
        latestBlockNumber = block.number;
        betaddrs.push(msg.sender);
        uint8 betType = uint8(_type);
        uint8 bethash = uint8(_hash);
        uint8 blockNum = uint8(_periods);
        betData[betType][bethash][uint256(msg.sender)]+=_tik;
        bets[msg.sender] = Bet({value: uint(msg.value), betType: uint8(betType), betHash: uint8(bethash), blockNum: uint8(blockNum)});
        emit LogBet(msg.sender,uint8(betType),uint8(bethash),uint8(blockNum),msg.value,bool(betclose));
        return true;
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