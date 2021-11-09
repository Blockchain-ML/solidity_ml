pragma solidity ^0.4.24;

 

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
     
     
     
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

 

 
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

   
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

   
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

 

contract Lottery is Ownable {

  using SafeMath for uint;

  uint public LIMIT = 100;

  uint public RANGE = 1000000000;

  uint public ticketPrice = 100000000000000000;

  uint public PERCENT_RATE = 100;

  uint public index;

  uint public start;

  uint public period;

  uint public feePercent;

  uint public summaryNumbers;
  
  uint public summaryInvested;
 
  address public feeWallet;

  mapping(address => uint) public invested;

  address[] investors;

  mapping(address => uint) public numbers;

  mapping(address => uint) public winBalances;

  mapping(address => uint) public toPayBalances;

  enum LotteryState { Init, Accepting, Processing, Rewarding, Finished }

  LotteryState public state;

  modifier notContract(address to) {
    uint codeLength;
    assembly {
       
      codeLength := extcodesize(to)
    }
    require(codeLength == 0, "Contracts can not participate!");
    _;
  }

  modifier investPeriodFininshed() {
    require(start + period < now, "Lottery invest period finished!");
    _;
  }

  modifier initState() {
    require(state == LotteryState.Init, "Lottery should be on Init state!");
    _;
  }

  modifier acceptingState() {
    require(state == LotteryState.Accepting, "Lottery should be on Accepting state!");
    _;
  }

  modifier investTime() {
    require(now >= start && now <= start + period, "Wrong time to invest!");
    _;
  }

  function setTicketPrice(uint newTicketPrice) public onlyOwner initState {
    ticketPrice = newTicketPrice;
  }

  function setFeeWallet(address newFeeWallet) public onlyOwner initState {
    feeWallet = newFeeWallet;
  }

  function setStart(uint newStart) public onlyOwner initState {
    start = newStart;
  }

  function setPeriod(uint newPeriod) public onlyOwner initState {
    period = newPeriod;
  }

  function setFeePercent(uint newFeePercent) public onlyOwner initState {
    require(newFeePercent < PERCENT_RATE);
    feePercent = newFeePercent;
  }

  function startLottery() public onlyOwner {
    require(state == LotteryState.Init);
    state = LotteryState.Accepting;
  }

  function () public payable investTime acceptingState notContract(msg.sender) {
    require(msg.value >= ticketPrice, "Not enough funds to buy ticket!");
    require(RANGE.mul(RANGE) > investors.length, "Player number error!");
    require(RANGE.mul(RANGE).mul(address(this).balance.add(msg.value)) > 0, "Limit error!");
    uint invest = invested[msg.sender];
    require(invest == 0, "Already invested!");
     
    investors.push(msg.sender);
     
    invested[msg.sender] = invest.add(ticketPrice);
    summaryInvested = summaryInvested.add(ticketPrice);
    uint diff = msg.value - ticketPrice;
    if(diff > 0) {
      msg.sender.transfer(diff);
    }
  }

  function prepareToRewardProcess() public investPeriodFininshed onlyOwner {
    if(state == LotteryState.Accepting) {
      state = LotteryState.Processing;
    } 

    require(state == LotteryState.Processing, "Lottery state should be Processing!");

    uint limit = investors.length - index;
    if(limit > LIMIT) {
      limit = LIMIT;
    }

    uint number = block.number;

    limit += index;

    for(; index < limit; index++) {
      number = uint(keccak256(abi.encodePacked(number)))%RANGE;
      numbers[investors[index]] = number;
      summaryNumbers = summaryNumbers.add(number);
    }

    if(index == investors.length) {
      feeWallet.transfer(address(this).balance.mul(feePercent).div(PERCENT_RATE));
      state = LotteryState.Rewarding;
      index = 0;
    }

  }

  function processReward() public onlyOwner {    
    require(state == LotteryState.Rewarding, "Lottery state should be Rewarding!");

    uint limit = investors.length - index;
    if(limit > LIMIT) {
      limit = LIMIT;
    }

    limit += index;

    for(; index < limit; index++) {
      address investor = investors[index];
      uint number = numbers[investor];
      if(number > 0) {
        winBalances[investor] = address(this).balance.mul(number).div(summaryNumbers);
        investor.transfer(winBalances[investor]);
      }
    }

    if(index == investors.length) {
      state = LotteryState.Finished;
    }
   
  }

}

 

contract LotteryController is Ownable {

  using SafeMath for uint;

  uint public PERCENT_RATE = 100;

  address[] public lotteries;

  address[] public finishedLotteries;

  address public feeWallet = address(this);

  uint public feePercent = 5;

  event LotteryCreated(address newAddress);

  function setFeeWallet(address newFeeWallet) public onlyOwner {
    feeWallet = newFeeWallet;
  }

  function setFeePercent(uint newFeePercent) public onlyOwner {
    feePercent = newFeePercent;
  }

  function newLottery(uint period, uint ticketPrice) public onlyOwner returns(address) {
    return newFutureLottery(now, period, ticketPrice);
  } 

  function newFutureLottery(uint start, uint period, uint ticketPrice) public onlyOwner returns(address) {
    return newCustomFutureLottery(start, ticketPrice, period, feeWallet, feePercent);
  } 

  function newCustomFutureLottery(uint start, uint period, uint ticketPrice, address cFeeWallet, uint cFeePercent) public onlyOwner returns(address) {
    require(start + period > now && feePercent < PERCENT_RATE);
    Lottery lottery = new Lottery();
    emit LotteryCreated(lottery);
    lottery.setStart(start);
    lottery.setPeriod(period);
    lottery.setFeeWallet(cFeeWallet);
    lottery.setFeePercent(cFeePercent);
    lottery.setTicketPrice(ticketPrice);
    lottery.startLottery();
    lotteries.push(lottery);
  }

  function processFinishLottery(address lotAddr) public onlyOwner returns(bool) {
    Lottery lot = Lottery(lotAddr);
    if(lot.state() == Lottery.LotteryState.Accepting ||
         lot.state() == Lottery.LotteryState.Processing) {
      lot.prepareToRewardProcess();
    } else if(lot.state() == Lottery.LotteryState.Rewarding) {
      lot.processReward(); 
      if(lot.state() == Lottery.LotteryState.Finished) {
        finishedLotteries.push(lotAddr);
        return true;
      }
    } else {
      revert();
    }
    return false;
  }

  function retrieveEth() public onlyOwner {
    msg.sender.transfer(address(this).balance);
  }

}