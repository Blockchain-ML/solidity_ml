pragma solidity ^0.4.25;

 

 contract Justice {

   using SafeMath for uint;

    
   address public admin;
   uint256 public endTime;  
   uint256 public limitTime;  
   uint256 public constant fee = 8;  

   mapping (address => uint256) public agreeMap;  
   mapping (address => uint256) public disagreeMap;  
   string public statement;
   address[] public agreeList;  
   address[] public disagreeList;
   uint256 public totalAgree;
   uint256 public totalDisagree;
   uint256 private iterA;
   uint256 private iterB;

   function agreeCount() public view returns(uint) {
      return agreeList.length;
   }

   function disagreeCount() public view returns(uint) {
      return disagreeList.length;
   }

    
   event Deposit(address receiver, bool agree);
   event Withdraw(bool agree, uint value);
   event Result(string msg);

   modifier isAdmin() {
       require(msg.sender == admin);
       _;
   }

   constructor ( string statement_, uint256 endTime_,  uint256 limitTime_) public {
     admin = msg.sender;
     statement = statement_;
     endTime = endTime_;
     limitTime = limitTime_;
     iterA = 0;
     iterB = 0;
   }

    

    
   function() external payable{
       agree(msg.sender);
   }

   function agree(address recipient) public payable {
     require(block.timestamp < endTime && agreeMap[recipient].add(msg.value) >= 0.02 ether);
     uint i=0;
     for (; i<agreeList.length && agreeList[i] != recipient; i++) {}
     if (agreeList.length == i) { agreeList.push(recipient); }
     agreeMap[recipient] = agreeMap[recipient].add(msg.value);
     totalAgree =totalAgree.add(msg.value);
     emit Deposit(recipient, true);
   }

   function agreeWithdraw(uint amount) public {
     require(agreeMap[msg.sender] >= amount && block.timestamp < endTime);
     agreeMap[msg.sender] = agreeMap[msg.sender].sub(amount);
     totalAgree = totalAgree.sub(amount);
     msg.sender.transfer(amount);
     emit Withdraw(true, amount);
   }

   function disagree(address recipient) public payable {
     require(block.timestamp < endTime && disagreeMap[recipient].add(msg.value) >= 0.02 ether);
     uint i=0;
     for (; i < disagreeList.length && disagreeList[i] != recipient; i++) {}
     if ( disagreeList.length == i ) { disagreeList.push(recipient); }
     disagreeMap[recipient] = disagreeMap[recipient].add(msg.value);
     totalDisagree =totalDisagree.add(msg.value);
     emit Deposit(recipient, false);
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

     if(iterA != agreeList.length)
     multiSendA(1000 - fee, 1000);
     else {
         if(iterB != disagreeList.length)
         multiSendB(1000 - fee, 1000);
         if(iterB == disagreeList.length) {
             admin.transfer(address(this).balance);
             emit Result("draw");
         }
     }
   }

   function resultAccept() public isAdmin {
     require( endTime < block.timestamp);
     multiSendA((totalDisagree+totalAgree).mul(1000 - fee), totalAgree.mul(1000));
     if(iterA == agreeList.length) {
         admin.transfer(address(this).balance);
         emit Result("agree");
     }
   }

   function resultReject() public isAdmin {
     require( endTime < block.timestamp);
     multiSendB((totalDisagree+totalAgree).mul(1000 - fee), totalDisagree.mul(1000));
     if(iterB == disagreeList.length) {
         admin.transfer(address(this).balance);
         emit Result("disagree");
     }
   }

   function multiSendA( uint256 numer, uint256 denom ) internal isAdmin {
     for (uint initi = iterA; iterA < initi + 10 && iterA < agreeList.length; iterA++) {
         if(!agreeList[iterA].send(agreeMap[agreeList[iterA]].mul(numer).div(denom))) {}
     }
   }

   function multiSendB( uint256 numer, uint256 denom ) internal isAdmin {
     for (uint initi = iterB; iterB < initi + 10 && iterB < disagreeList.length; iterB++) {
         if(!disagreeList[iterB].send(disagreeMap[disagreeList[iterB]].mul(numer).div(denom))) {}
     }
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