pragma solidity ^0.4.11;

interface ERC223Token {
  function balanceOf(address addr) external view returns(uint);
  function transfer(address to, uint value) external;
}


contract TokenExample {
  address public addrFrom;
  address public msgSender;
  address public txOrigin;
  
  function tokenFallback(address _from, uint _value, bytes _data) public {
     
    
    addrFrom = _from;
    msgSender = msg.sender;
    txOrigin = tx.origin;
    
     
  }

  function getBalance(address tokenAddr) public view returns(uint) {
    ERC223Token token = ERC223Token(tokenAddr);
    return token.balanceOf(this);
  }

}