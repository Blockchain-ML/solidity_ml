pragma solidity ^0.4.24;

contract Ownable {}
contract AddressesFilterFeature is Ownable {}
contract ERC20Basic {}
contract BasicToken is ERC20Basic {}
contract ERC20 {}
contract StandardToken is ERC20, BasicToken {}
contract MintableToken is AddressesFilterFeature, StandardToken {}

contract Token is MintableToken {
  mapping(address => uint256) balances;
  function transfer(address _to, uint256 _value) public returns (bool);
  function balanceOf(address owner) public view returns (uint256);
}

contract VestingContractWPT {
   
  address public owner;
  Token public company_token;

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


   
  constructor (Token _company_token) public {
    owner = msg.sender;
    PartnerAccount = 0xd7f2e333d208a820801fe6a5ab169cc1886cb90b;
    company_token = _company_token;
    originalBalance = 1785714 * 10**18;  
    currentBalance = originalBalance;
    alreadyTransfered = 0;
    startDateOfPayments = 1538251520;  
    endDateOfPayments = 1538265600;  
    periodOfOnePayments = 2 * 60;  
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