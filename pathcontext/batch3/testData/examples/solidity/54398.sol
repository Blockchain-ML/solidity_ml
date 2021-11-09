pragma solidity ^0.4.4;

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

contract Insurance {
    mapping (address => uint256) insured;
    
     
    
    event watchNew(uint256 start, uint256 stop);
    event refunded(address id);
    
    modifier onlyServer() {
        require(msg.sender == 0x8649c813334c0Fb7c7aDF916B18ABbe20D48e813);
        _;
    }
    
    constructor() public {
        
    }
    
     
    function () public payable {
        insured[msg.sender] += msg.value;
        emit watchNew(now,now+604800);
    }
    
    function refund(address id) public onlyServer {
        id.transfer(insured[id]*10);  
        emit refunded(id);
    }
    
    function balanceOf(address id) public view returns (uint256) {
        return insured[id];
    }
}