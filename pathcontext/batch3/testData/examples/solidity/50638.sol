pragma solidity ^0.4.18 ;

 
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

contract ContractiumInterface {
    function balanceOf(address who) public view returns (uint256);
    function contractSpend(address _from, uint256 _value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint256);

    function owner() public view returns (address);

    function bonusRateOneEth() public view returns (uint256);
    function currentTotalTokenOffering() public view returns (uint256);
    function currentTokenOfferingRaised() public view returns (uint256);

    function isOfferingStarted() public view returns (bool);
    function offeringEnabled() public view returns (bool);
    function startTime() public view returns (uint256);
    function endTime() public view returns (uint256);
}


contract ContractiumWatchdog is Ownable {

    using SafeMath for uint256;

    ContractiumInterface ctuContract;
    address public constant WATCHDOG = 0x3c99c11AEA3249EE2B80dcC0A7864dCC2b54be78;
    address public constant CONTRACTIUM = 0x0dc319Fa14b3809ea2f0f9Ae28311f957a9bE4a3;
    address public ownerCtuContract;
    address public owner;

    uint8 public constant decimals = 18;
    uint256 public unitsOneEthCanBuy = 15000;
    uint256 public bonusRateOneEth;
    uint256 public currentTotalTokenOffering;
    uint256 public currentTokenOfferingRaised;

    bool public isOfferingStarted;
    bool public offeringEnabled;
    uint256 public startTime;
    uint256 public endTime;


    function() public payable {

        require(msg.sender != owner);

         
        uint256 amount = msg.value.mul(unitsOneEthCanBuy);

         
        uint256 amountBonus = msg.value.mul(bonusRateOneEth);
        
         
        amount = amount.add(amountBonus);

         
        uint256 remain = ctuContract.balanceOf(ownerCtuContract);
        require(remain >= amount);
        preValidatePurchase(amount);

        address _from = ownerCtuContract;
        address _to = msg.sender;
        ctuContract.transferFrom(_from, _to, amount);

        currentTokenOfferingRaised = currentTokenOfferingRaised.add(amount);  

         
        uint256 oneTenth = msg.value.div(10);
        uint256 nineTenth = msg.value.sub(oneTenth);

        WATCHDOG.transfer(oneTenth);
        ownerCtuContract.transfer(nineTenth);  
                              
    }

    constructor() public {
        ctuContract =  ContractiumInterface(CONTRACTIUM);
        ownerCtuContract = ctuContract.owner();
        owner = msg.sender;

        bonusRateOneEth = ctuContract.bonusRateOneEth();
        currentTotalTokenOffering = ctuContract.currentTotalTokenOffering();
        
        isOfferingStarted = ctuContract.isOfferingStarted();
        offeringEnabled = ctuContract.offeringEnabled();
        startTime = ctuContract.startTime();
        endTime = ctuContract.endTime();
    }

     
    function preValidatePurchase(uint256 _amount) internal {
        require(_amount > 0);
        require(isOfferingStarted);
        require(offeringEnabled);
        require(currentTokenOfferingRaised.add(ctuContract.currentTokenOfferingRaised().add(_amount)) <= currentTotalTokenOffering);
        require(block.timestamp >= startTime && block.timestamp <= endTime);
    }
    
     
    function setCtuContract(address _ctuAddress) public onlyOwner {
        require(_ctuAddress != address(0x0));

        ctuContract = ContractiumInterface(_ctuAddress);
        ownerCtuContract = ctuContract.owner();

        bonusRateOneEth = ctuContract.bonusRateOneEth();
        currentTotalTokenOffering = ctuContract.currentTotalTokenOffering();

        isOfferingStarted = ctuContract.isOfferingStarted();
        offeringEnabled = ctuContract.offeringEnabled();
        startTime = ctuContract.startTime();
        endTime = ctuContract.endTime();
    }

     
    function setRateAgain() public onlyOwner {
        ownerCtuContract = ctuContract.owner();

        bonusRateOneEth = ctuContract.bonusRateOneEth();
        currentTotalTokenOffering = ctuContract.currentTotalTokenOffering();

        isOfferingStarted = ctuContract.isOfferingStarted();
        offeringEnabled = ctuContract.offeringEnabled();
        startTime = ctuContract.startTime();
        endTime = ctuContract.endTime();
    }

     
    function resetCurrentTokenOfferingRaised() public onlyOwner {
        currentTokenOfferingRaised = 0;
    }

    function transferOwnership(address _addr) public onlyOwner{
        super.transferOwnership(_addr);
    }

}