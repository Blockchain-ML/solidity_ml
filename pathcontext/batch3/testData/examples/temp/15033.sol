 
 
 
 
pragma solidity ^0.4.19;

contract owned {
  address public owner;

  function owned() { owner = msg.sender; }

  modifier onlyOwner {
    if (msg.sender != owner) { revert(); }
    _;
  }

  function changeOwner( address newowner ) onlyOwner {
    owner = newowner;
  }

  function closedown() onlyOwner {
    selfdestruct( owner );
  }
}

 
interface HashBux {
  function transfer(address to, uint256 value);
  function balanceOf( address owner ) constant returns (uint);
}

contract HashBuxICO is owned {

  uint public constant STARTTIME = 1522072800;    
  uint public constant ENDTIME = 1522764000;      
  uint public constant HASHPERETH = 1000;        

  HashBux public tokenSC = HashBux(0x06F8d7043F77E20DF94bc2fab39BF90d702CBd15);

  function HashBuxICO() {}

  function setToken( address tok ) onlyOwner {
    if ( tokenSC == address(0) )
      tokenSC = HashBux(tok);
  }

  function() payable {
    if (now < STARTTIME || now > ENDTIME)
      revert();

     
     
    uint qty =
      div(mul(div(mul(msg.value, HASHPERETH),1000000000000000000),(bonus()+100)),100);

    if (qty > tokenSC.balanceOf(address(this)) || qty < 1)
      revert();

    tokenSC.transfer( msg.sender, qty );
  }

   
  function claimUnsold() onlyOwner {
    if ( now < ENDTIME )
      revert();

    tokenSC.transfer( owner, tokenSC.balanceOf(address(this)) );
  }

  function withdraw( uint amount ) onlyOwner returns (bool) {
    if (amount <= this.balance)
      return owner.send( amount );

    return false;
  }

  function bonus() constant returns(uint) {
    uint elapsed = now - STARTTIME;

    if (elapsed < 24 hours) return 50;
    if (elapsed < 48 hours) return 30;
    if (elapsed < 72 hours) return 20;
    if (elapsed < 96 hours) return 10;
    return 0;
  }

   
   
   
  function mul(uint256 a, uint256 b) constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) constant returns (uint256) {
    uint256 c = a / b;
    return c;
  }
}