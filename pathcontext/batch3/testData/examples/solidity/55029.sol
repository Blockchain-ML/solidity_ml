pragma solidity ^0.4.25;

contract FundEIF {
  
  mapping(address => uint256) public receivedFunds;  
  uint256 public totalSent;                          
  uint256 public totalOtherReceived;                 
  uint256 public totalInterestReinvested;            
  address public EIF;
  address public PoEIF;
  event INCOMING(address indexed sender, uint amount, uint256 timestamp);
  event OUTGOING(address indexed sender, uint amount, uint256 timestamp);

  constructor() public {
    EIF = 0x775C009Be15f6a7EC577C4172961F2bf82DB37f1;     
    PoEIF = 0x5706E4602643eFd7c49D1E25e4e32BD1a3eb1A41;   
  }
  
  function () external payable {
      emit INCOMING(msg.sender, msg.value, now);   
      if (msg.sender != EIF) {                     
          receivedFunds[msg.sender] += msg.value;  
          if (msg.sender != PoEIF) {               
              totalOtherReceived += msg.value;
          }
      }
  }
  
  function PayEIF() external {
      uint256 currentBalance=address(this).balance;
      totalSent += currentBalance;                                                  
      totalInterestReinvested = totalSent-receivedFunds[PoEIF]-totalOtherReceived;  
      emit OUTGOING(msg.sender, currentBalance, now);
      if(!EIF.call.value(currentBalance)()) revert();
  }
}