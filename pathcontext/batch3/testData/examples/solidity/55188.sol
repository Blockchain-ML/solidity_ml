pragma solidity 0.4.24;

 

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
 
contract VendingMachine {
    address public owner;
    uint256 public price;
		
	modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    event releaseProduct(
        bool status,
        uint product
    );
	
    event updateBalance();
    
    constructor() public {
        owner= msg.sender;
        price=100000000000000000; 
    }
 
    function setPrice(uint256 newPrice) onlyOwner public {
        price=newPrice;
    }
 
    function pickupProduct(uint product) public payable returns (bool) {
        uint256 payment=msg.value;
        if (payment >= price ){
            uint256 cashBack=SafeMath.sub(payment,price);
            if (cashBack>0)
            {
                msg.sender.transfer(cashBack);
            }
            emit releaseProduct(true,product);
            return true;
        } else {
            return false;
        }
    }
    
    function takeMoney() public onlyOwner payable returns (bool) {
        uint balance = address(this).balance;
        owner.transfer(balance);
		emit updateBalance();
        return true;       
    }
	
    function ownerKill() public payable onlyOwner {
        selfdestruct(owner);
    }
}