pragma solidity ^0.4.11;
 

contract ERC20Interface {
   
  function transfer(address _to, uint256 _value) public returns (bool success);
   
  function balanceOf(address _owner) public constant returns (uint256 balance);
}
 
contract Forwarder {
   
  address public parentAddress = 0x576e62d095692b1b635b458869eaaaf3ab6fc033;
  event ForwarderDeposited(address from, uint value, bytes data);

   
  function Forwarder() public {
  }

   
  modifier onlyParent {
    if (msg.sender != parentAddress) {
      revert();
    }
    _;
  }

   
  function() public payable {
     
    parentAddress.transfer(msg.value);
     
    ForwarderDeposited(msg.sender, msg.value, msg.data);
  }

   
  function flushTokens(address tokenContractAddress) public {
    ERC20Interface instance = ERC20Interface(tokenContractAddress);
    var forwarderAddress = address(this);
    var forwarderBalance = instance.balanceOf(forwarderAddress);
    if (forwarderBalance == 0) {
      return;
    }
    if (!instance.transfer(parentAddress, forwarderBalance)) {
      revert();
    }
  }

   
  function flush() public {
     
    parentAddress.transfer(this.balance);
  }
}

 
 
contract ForwarderTarget {
  uint public data;

  function ForwarderTarget() public {
  }

  function createForwarder() public returns (address) {
    return new Forwarder();
  }

  function() public payable {
     
  }
}