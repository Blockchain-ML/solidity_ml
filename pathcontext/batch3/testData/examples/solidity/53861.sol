pragma solidity ^0.4.13;

contract Justice {

  using SafeMath for uint;

   
  address public admin;  
  uint256 public feeTake;  
  uint256 public endTime;  
  uint256 public limitTime;  
  mapping (address => uint256) public agreeMap;  
  mapping (address => uint256) public disagreeMap;  
  address[] agreeList;  
  address[] disagreeList;
  uint256 public totalAgree;
  uint256 public totalDisagree;
  string public statement;

   
  event Deposit(bool agree);
  event Withdraw(bool agree, uint value);
  event Result(string msg);
   
  modifier isAdmin() {
      require(msg.sender == admin);
      _;
  }

   
  constructor (string statement_, uint256 endTime_,  uint256 limitTime_) public {
    admin = msg.sender;
    statement = statement_;
    endTime = endTime_;
    limitTime = limitTime_;
  }


   
   
   

  function() public payable {
    require(block.timestamp < endTime && agreeMap[msg.sender].add(msg.value) > 0.005 ether);
    if (agreeMap[msg.sender] == 0) { agreeList.push(msg.sender); }
    agreeMap[msg.sender] = agreeMap[msg.sender].add(msg.value);
    totalAgree =totalAgree.add(msg.value);
    emit Deposit(true);
  }

  function agreeWithdraw(uint amount) public {
    require(agreeMap[msg.sender] >= amount && block.timestamp < endTime);
    agreeMap[msg.sender] = agreeMap[msg.sender].sub(amount);
    totalAgree = totalAgree.sub(amount);
    msg.sender.transfer(amount);
    emit Withdraw(true, amount);
  }

  function disagree() public payable {
    require(block.timestamp < endTime && disagreeMap[tx.origin].add(msg.value) > 0.005 ether);
    if (disagreeMap[tx.origin] == 0) { disagreeList.push(tx.origin); }
    disagreeMap[tx.origin] = disagreeMap[tx.origin].add(msg.value);
    totalDisagree =totalDisagree.add(msg.value);
    emit Deposit(false);
  }

  function disagreeWithdraw(uint amount) public {
    require(disagreeMap[msg.sender] >= amount && block.timestamp < endTime);
    disagreeMap[msg.sender] = disagreeMap[msg.sender].sub(amount);
    totalDisagree = totalDisagree.sub(amount);
    msg.sender.transfer(amount);
    emit Withdraw(false, amount);
  }

   
   
  function lockBreak() public {
    require( limitTime < block.timestamp );
    endTime = 3000000000;
  }

   
  function endBetting() public isAdmin {
    endTime = block.timestamp.sub(900);
    emit Result("early");
  }

  function resultDraw() public isAdmin {
    require( endTime < block.timestamp);
    for (uint i; i < agreeList.length; i++) {
      agreeList[i].transfer(agreeMap[agreeList[i]].mul(998).div(1000) - 500 * tx.gasprice);
    }
    for (i = 0 ; i < disagreeList.length; i++) {
      disagreeList[i].transfer(disagreeMap[disagreeList[i]].mul(998).div(1000) - 500 * tx.gasprice);
    }
    admin.transfer(address(this).balance);
    emit Result("draw");
  }

  function resultAccept() public isAdmin {
    uint mul_ = (totalDisagree+totalAgree).mul(998);
    uint div_ = totalAgree.mul(1000);
    for (uint i; i< agreeList.length; i++) {
      if (agreeMap[agreeList[i]] > 0.005 ether) {
          agreeList[i].transfer(agreeMap[agreeList[i]].mul(mul_).div(div_) - 500 * tx.gasprice);
      }
    }
    admin.transfer(address(this).balance);
    emit Result("agree");
  }

  function resultReject() public isAdmin {
    uint mul_ = (totalDisagree+totalAgree).mul(998);
    uint div_ = totalDisagree.mul(1000);
    for (uint i; i< disagreeList.length; i++) {
      if (disagreeMap[disagreeList[i]] > 0.005 ether)
      disagreeList[i].transfer(disagreeMap[disagreeList[i]].mul(mul_).div(div_) - 500 * tx.gasprice);
    }
    admin.transfer(address(this).balance);
    emit Result("disagree");
  }

 }

library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);  
    uint256 c = a / b;
     

    return c;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

}