pragma solidity ^0.4.23;

 
 
 
 

 

contract ZTHReceivingContract {
     
    function tokenFallback(address _from, uint _value, bytes _data) public;
}


contract ZTHInterface {
    function getFrontEndTokenBalanceOf(address who) public view returns (uint);
    function transfer(address _to, uint _value) public returns (bool);
    function approve(address spender, uint tokens) public returns (bool);
}

contract Zethroll is ZTHReceivingContract {
    using SafeMath for uint;

     
    modifier betIsValid(uint _betSize, uint _playerNumber) {
        require( calculateProfit(_betSize, _playerNumber) < maxProfit
                 && _betSize > minBet
                 && _playerNumber > minNumber
                 && _playerNumber < maxNumber);
		_;
    }

     
    modifier gameIsActive {
        require(gamePaused == false);
		_;
    }

     
    modifier payoutsAreActive {
        require(payoutsPaused == false);
		_;
    }

     
    modifier onlyOwner {
         require(msg.sender == owner);
         _;
    }

     
    modifier onlyBankroll {
         require(msg.sender == bankroll);
         _;
    }

     
    uint constant private MAX_INT         = 2**256 - 1;
    uint constant public maxProfitDivisor = 1000000;
    uint constant public maxNumber = 99;
    uint constant public minNumber = 2;
	bool public gamePaused;
    address public owner;
    bool public payoutsPaused;
    address public bankroll;
    uint public contractBalance;
    uint public          houseEdge;
    uint constant public houseEdgeDivisor = 1000;
    uint public maxProfit;
    uint public maxProfitAsPercentOfHouse;
    uint public minBet;
    int  public totalBets = 0;
    uint public totalBetsWon = 0;
    uint public totalZTHWagered = 0;
    uint internal _seed;

     
    uint public rngId;
    mapping (uint => address) playerAddress;
    mapping (uint => uint)    playerBetId;
    mapping (uint => uint)    playerBetValue;
    mapping (uint => uint)    playerDieResult;
    mapping (uint => uint)    playerNumber;
    mapping (uint => uint)    playerProfit;
    mapping (address => uint) playerTargetBet;
    mapping (uint => uint) playerBlock;
    mapping (uint => TKN) playerTKN;
    mapping (uint => uint) playerRollUnder;

     
     
    event LogBet(uint indexed BetID, address indexed PlayerAddress, uint indexed RewardValue, uint ProfitValue, uint BetValue, uint PlayerNumber);
     
     
	event LogResult(uint indexed BetID, address indexed PlayerAddress, uint PlayerNumber, uint DiceResult, uint Value, int Status);
     
    event LogRefund(uint indexed BetID, address indexed PlayerAddress, uint indexed RefundValue);
     
    event LogOwnerTransfer(address indexed SentToAddress, uint indexed AmountTransferred);

    address public constant ZTHTKNADDR  = 0xf1dFc1447f8AbDb766151FB4De130F079c345bd1;
    address internal        ZTHBANKROLL = 0x5C07E52d25418DBE5CA3Bc8279eEe09258671086;
    ZTHInterface public     ZTHTKN;

     
    constructor () public {
         
        owner    = msg.sender;
         
        ZTHTKN = ZTHInterface(ZTHTKNADDR);
         
        houseEdge = 990;
         
        ownerSetMaxProfitAsPercentOfHouse(10000);
         
        ownerSetMinBet(1e18);
         
        ZTHTKN.approve(ZTHBANKROLL, MAX_INT);
         
        bankroll = ZTHBANKROLL;
    }

    function maxRandom(uint blockn) public returns (uint256 randomNumber) {
        _seed = uint256(keccak256(
            abi.encodePacked(_seed,
                blockhash(blockn),
                block.coinbase,
                block.difficulty)
        ));
        return _seed;
    }

    function random(uint256 upper, uint256 blockn) internal returns (uint256 randomNumber) {
        return maxRandom(blockn) % upper;
    }

    function calculateProfit(uint _initBet, uint _roll)
        private
        view
        returns (uint)
    {
     return ((((_initBet * (100-(_roll.sub(1)))) / (_roll.sub(1))+_initBet))*houseEdge/houseEdgeDivisor)-_initBet;
    }

     
    function _playerRollDice(uint _rollUnder, TKN _tkn) private
        gameIsActive
        betIsValid(_tkn.value, _rollUnder)
	{
         
    	 
    	require(_humanSender(_tkn.sender));  
    	require(_zthToken(msg.sender));  

	     
	    rngId++;
	    
	    require(block.number != playerBlock[playerTargetBet[_tkn.sender]]);
	        	
        if (playerBlock[playerTargetBet[_tkn.sender]] != 0){
            _finishBet(playerTargetBet[_tkn.sender]);
        }

         
		playerBetId[rngId] = rngId;
         
		playerNumber[rngId] = _rollUnder;
         
        playerBetValue[rngId] = _tkn.value;
         
        playerAddress[rngId] = _tkn.sender;
         
        playerProfit[rngId] = 0;
        
        playerBlock[rngId] = block.number;
        playerTargetBet[_tkn.sender] = rngId;
        playerTKN[rngId] = _tkn;
        playerRollUnder[rngId] = _rollUnder;

         
        emit LogBet(playerBetId[rngId], playerAddress[rngId], playerBetValue[rngId].add(playerProfit[rngId]), playerProfit[rngId], playerBetValue[rngId], playerNumber[rngId]);

         
        totalBets += 1;

         
        totalZTHWagered += playerBetValue[rngId];
    }
    
    function _finishBet(uint _rngId) public {
         
        
         
        if (block.number - playerBlock[_rngId] > 255){
            playerDieResult[_rngId] = 1000;  
        }
        else{
            playerDieResult[_rngId] = random(99, playerBlock[_rngId]) + 1;
        }
        
        TKN storage _tkn = playerTKN[_rngId];
        uint _rollUnder = playerRollUnder[_rngId];
        if(playerDieResult[_rngId] < playerNumber[_rngId]){
             
            playerProfit[_rngId] = calculateProfit(_tkn.value, _rollUnder);

             
            contractBalance = contractBalance.sub(playerProfit[_rngId]);


            emit LogResult(playerBetId[_rngId], playerAddress[_rngId], playerNumber[_rngId]
                         , playerDieResult[_rngId], playerProfit[_rngId], 1);

             
            setMaxProfit();

             
            ZTHTKN.transfer(playerAddress[_rngId], playerProfit[_rngId] + _tkn.value);

            return;
        } else {
             
            emit LogResult(playerBetId[_rngId], playerAddress[_rngId], playerNumber[_rngId]
                         , playerDieResult[_rngId], playerBetValue[_rngId], 0);

             
            contractBalance = contractBalance.add(playerBetValue[_rngId]-1);

             
            setMaxProfit();

             
            ZTHTKN.transfer(playerAddress[_rngId], 1);

            return;
        }
    }

    struct TKN { address sender; uint value; }
    function tokenFallback(address _from, uint _value, bytes _data) public {
        if(_from == bankroll) {
            contractBalance = contractBalance.add(_value);
             
             
            setMaxProfit();
            return;
        } else {
            TKN memory          _tkn;
            _tkn.sender       = _from;
            _tkn.value        = _value;
            uint chosenNumber = uint(_data[0]);
            _playerRollDice(chosenNumber, _tkn);
        }
    }

     
    function setMaxProfit() internal {
        maxProfit = (contractBalance*maxProfitAsPercentOfHouse)/maxProfitDivisor;
    }

     
    function ownerUpdateContractBalance(uint newContractBalance) public
		onlyOwner
    {
       contractBalance = newContractBalance;
    }

     
    function ownerSetMaxProfitAsPercentOfHouse(uint newMaxProfitAsPercent) public
		onlyOwner
    {
         
        require(newMaxProfitAsPercent <= 10000);
        maxProfitAsPercentOfHouse = newMaxProfitAsPercent;
        setMaxProfit();
    }

     
    function ownerSetMinBet(uint newMinimumBet) public
		onlyOwner
    {
        minBet = newMinimumBet;
    }

     
    function ownerTransferZTH(address sendTo, uint amount) public
		onlyOwner
    {
         
        contractBalance = contractBalance.sub(amount);
         
        setMaxProfit();
        require(ZTHTKN.transfer(sendTo, amount));
        emit LogOwnerTransfer(sendTo, amount);
    }

     
    function ownerPauseGame(bool newStatus) public
		onlyOwner
    {
		gamePaused = newStatus;
    }

     
    function ownerPausePayouts(bool newPayoutStatus) public
		onlyOwner
    {
		payoutsPaused = newPayoutStatus;
    }

     
    function ownerSetBankroll(address newBankroll) public
		onlyOwner
	{
        ZTHTKN.approve(bankroll, 0);
        bankroll = newBankroll;
        ZTHTKN.approve(newBankroll, MAX_INT);
    }

     
    function ownerChangeOwner(address newOwner) public
		onlyOwner
	{
        owner = newOwner;
    }

     
    function ownerkill() public
		onlyOwner
	{
        ZTHTKN.transfer(owner, contractBalance);
		selfdestruct(owner);
	}

    function _zthToken(address _tokenContract) private pure returns (bool) {
        return _tokenContract == ZTHTKNADDR;  
    }

     
    function _humanSender(address _from) private view returns (bool) {
      uint codeLength;
      assembly {
          codeLength := extcodesize(_from)
      }
      return (codeLength == 0);  
    }

}

 
library SafeMath {

     
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }

     
    function div(uint a, uint b) internal pure returns (uint) {
         
        uint c = a / b;
         
        return c;
    }

     
    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

     
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}