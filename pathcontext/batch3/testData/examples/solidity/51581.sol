pragma solidity 0.4.24;

 


 
contract ERC20Token {
  function name() public view returns (string);
  function symbol() public view returns (string);
  function decimals() public view returns (uint);
  function totalSupply() public view returns (uint);
  function balanceOf(address account) public view returns (uint);
  function transfer(address to, uint amount) public returns (bool);
  function transferFrom(address from, address to, uint amount) public returns (bool);
  function approve(address spender, uint amount) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint);
}


 
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


 
contract INNBCAirdropDistribution is Ownable {
  address public tokenINNBCAddress;

  function setINNBCTokenAddress(address tokenAddress) external onlyOwner() {
    require(tokenAddress != address(0), "Token address cannot be null");

    tokenINNBCAddress = tokenAddress;
  }

  function airdropTokens(address[] recipients, uint amountPerRecipient) external onlyOwner() {
    require(recipients.length <= 200, "Recipients list is too long");
    require(tokenINNBCAddress != address(0));

    ERC20Token tokenINNBC = ERC20Token(tokenINNBCAddress);

    require(
      recipients.length * amountPerRecipient <= tokenINNBC.allowance(msg.sender, address(this)),
      "This contract cannot handle this amount"
    );

    for (uint i = 0; i < recipients.length; i += 1) {
      tokenINNBC.transferFrom(msg.sender, recipients[i], amountPerRecipient);
    }
  }
}