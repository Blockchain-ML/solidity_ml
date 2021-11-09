pragma solidity ^0.4.18;

 

 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  function Ownable() public {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 

 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

 
 

contract TokenLoot is Ownable {

   
   
  address public neverdieSigner;
   
  mapping (address => uint256) public nonces;
   
  address[] public tokens;


   
  event ReceiveLoot(address indexed sender,
                    uint256 nonce,
                    address[] tokens,
                    uint256[] amounts);
 

   
  function setNeverdieSignerAddress(address _to) public onlyOwner {
    neverdieSigner = _to;
  }

  function setTokens(address[] _tokens) public onlyOwner {
    for (uint256 i = 0; i < _tokens.length; i++) {
      tokens[i] = _tokens[i];
    }
  }

   
   
  constructor(address[] _tokens, address _signer) {
    for (uint256 i = 0; i < _tokens.length; i++) {
      tokens.push(_tokens[i]);
    }
    neverdieSigner = _signer;
  }

  function receiveTokenLoot(uint256[] _amounts, 
                            uint256 _nonce, 
                            uint8 _v, 
                            bytes32 _r, 
                            bytes32 _s) {

     
    require(_nonce > nonces[msg.sender]);
    nonces[msg.sender] = _nonce;

     
    address signer = ecrecover(keccak256(msg.sender, 
                                         _nonce,
                                         _amounts), _v, _r, _s);
    require(signer == neverdieSigner);

     
    
    for (uint256 i = 0; i < _amounts.length; i++) {
      if (_amounts[i] > 0) {
        assert(ERC20(tokens[i]).transfer(msg.sender, _amounts[i]));
      }
    }
    

     
    ReceiveLoot(msg.sender, _nonce, tokens, _amounts);
  }

   
  function () payable public { 
      revert(); 
  }

   
  function withdraw() public onlyOwner {
    for (uint256 i = 0; i < tokens.length; i++) {
      uint256 amount = ERC20(tokens[i]).balanceOf(this);
      if (amount > 0) ERC20(tokens[i]).transfer(msg.sender, amount);
    }
  }

   
  function kill() onlyOwner public {
    withdraw();
    selfdestruct(owner);
  }

}