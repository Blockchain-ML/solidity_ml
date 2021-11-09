pragma solidity ^0.4.24;

contract Owned {}
contract ERC20Interface {}

contract DataeumToken is Owned, ERC20Interface {
  mapping(address => uint256) balances;
  function transfer(address to, uint tokens) public returns (bool success);
  function balanceOf(address tokenOwner) public view returns (uint balance);
}

contract SwapContractDataeumToPDATA {
   
  address public owner;
  DataeumToken public company_token;

  address public PartnerAccount;
  uint public originalBalance;
  uint public currentBalance;
  uint public alreadyTransfered;
  uint public startDateOfPayments;
  uint public endDateOfPayments;
  uint public periodOfOnePayments;
  uint public limitPerPeriod;
  uint public daysOfPayments;

   
  modifier onlyOwner
  {
    require(owner == msg.sender);
    _;
  }
  
  
   
  event Transfer(address indexed to, uint indexed value);
  event OwnerChanged(address indexed owner);


   
  constructor (DataeumToken _company_token) public {
    owner = msg.sender;
    PartnerAccount = 0xd7f2E333D208A820801fe6A5ab169cc1886cB90B;
    company_token = _company_token;
    originalBalance = 10000000 * 10**18;  
    currentBalance = originalBalance;
    alreadyTransfered = 0;
    startDateOfPayments = 1543497300;  
    endDateOfPayments = 1572562800;  
    periodOfOnePayments = 60;  
    daysOfPayments = (endDateOfPayments - startDateOfPayments) / periodOfOnePayments;  
    limitPerPeriod = originalBalance / daysOfPayments;
  }


   
  function()
    public
    payable
  {
    revert();
  }


   
  function getBalance()
    constant
    public
    returns(uint)
  {
    return company_token.balanceOf(this);
  }


  function setOwner(address _owner) 
    public 
    onlyOwner 
  {
    require(_owner != 0);
    
    owner = _owner;
    emit OwnerChanged(owner);
  }
  
  function sendCurrentPayment() public {
	if (now > startDateOfPayments) {
      uint currentPeriod = (now - startDateOfPayments) / periodOfOnePayments;
      uint currentLimit = currentPeriod * limitPerPeriod;
      uint unsealedAmount = currentLimit - alreadyTransfered;
      if (unsealedAmount > 0) {
        if (currentBalance >= unsealedAmount) {
          company_token.transfer(PartnerAccount, unsealedAmount);
          alreadyTransfered += unsealedAmount;
          currentBalance -= unsealedAmount;
          emit Transfer(PartnerAccount, unsealedAmount);
        } else {
          company_token.transfer(PartnerAccount, currentBalance);
          alreadyTransfered += currentBalance;
          currentBalance -= currentBalance;
          emit Transfer(PartnerAccount, currentBalance);
        }
      }
    }
  }
}