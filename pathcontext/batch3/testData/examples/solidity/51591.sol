pragma solidity ^0.4.23;

 
contract LotteryTest {
    struct Bet {
        uint192 value;  
        uint32 betType;  
        uint32 betHash;  
        uint32 blockNum;  
    }
    mapping (address => Bet) bets;
    address[] private betaddrs;
    mapping(address => uint256) winners;
    
     
    uint public maxWin = 0;  
    uint public hashFirst = 0;  
    uint public hashLast = 0;  
    uint public hashNext = 0;  
    uint public hashBetSum = 0;  
    uint public hashBetMax = 5 ether;  
    uint[] public hashes;  

     
    event LogBet(address indexed player, uint bettype, uint bethash, uint blocknumber, uint betsize);
    
  	address public owner;
    uint private latestBlockNumber;
    bytes32 private cumulativeHash;

    constructor() public {
		owner = msg.sender;
        latestBlockNumber = block.number;
        cumulativeHash = bytes32(0);
    }

  	 
  	modifier onlyOwner() {
    	require(msg.sender == owner);
    	_;
  	}

     
    function setBetMax(uint _maxsum) external onlyOwner {
        hashBetMax = _maxsum;
    }

     
    function resetBet() external onlyOwner {
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

    function placeBet(uint _type, uint _hash, uint _periods) public payable returns (bool) {
        uint _wei = msg.value;
        assert(_wei == 20000000000000000);
        cumulativeHash = keccak256(abi.encodePacked(blockhash(latestBlockNumber), cumulativeHash));
        latestBlockNumber = block.number;
        betaddrs.push(msg.sender);
        uint24 betType = uint24(_type);
        uint24 bethash = uint24(_hash);
        uint24 blockNum = uint24(_periods);
        bets[msg.sender] = Bet({value: uint192(msg.value), betType: uint32(betType), betHash: uint32(bethash), blockNum: uint32(blockNum)});
        emit LogBet(msg.sender,uint(betType),uint(bethash),uint(blockNum),msg.value);
        return true;
    }

    function drawWinner() public onlyOwner returns (address) {
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

    function withdraw() public returns (bool) {
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