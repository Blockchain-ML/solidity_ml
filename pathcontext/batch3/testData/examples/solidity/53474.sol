pragma solidity 0.4.25;

 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
    uint256 c = a / b;
     
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

 
 
 
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Token{
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
}


 
contract Airdrop2bothdynamic is Owned {
  using SafeMath for uint256;
  Token public token;
  uint256 private constant decimalFactor = 10**uint256(18);
   
  mapping (address => bool) public airdrops;
  
   
  constructor(address _tokenContractAdd, address _owner) public {
     
    token = Token(_tokenContractAdd);
    owner = _owner;
  }
  
   
  function airdropTokens(address[] _recipient, uint256[] _tokens) public onlyOwner{
    uint airdropped;
    for(uint256 i = 0; i< _recipient.length; i++)
    {
        if (!airdrops[_recipient[i]]) {
          airdrops[_recipient[i]] = true;
          require(token.transferFrom(msg.sender, _recipient[i], _tokens[i] * decimalFactor));
          airdropped = airdropped.add(_tokens[i] * decimalFactor);
        }
    }
  }
}