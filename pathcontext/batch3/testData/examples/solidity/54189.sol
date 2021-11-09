pragma solidity ^0.4.24;

 
interface BurnableERC20 { 

    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function burnFrom(address _tokenHolder, uint _amount) external returns (bool success); 

}

 
 
 
 
contract MyBitBurner {

  BurnableERC20 public mybToken;   
  address public owner;            

  mapping (address => bool) public authorizedBurner;     

   
   
  constructor(address _myBitTokenAddress)
  public {
    mybToken = BurnableERC20(_myBitTokenAddress);
    owner = msg.sender;
  }

   
   
   
  function burn(address _tokenHolder, uint _amount)
  external
  returns (bool) {
    require(authorizedBurner[msg.sender]);
    require(mybToken.allowance(_tokenHolder, address(this)) >= _amount); 
    require(mybToken.burnFrom(_tokenHolder, _amount));
    emit LogMYBBurned(_tokenHolder, msg.sender, _amount);
    return true;
  }

   
   
  function authorizeBurner(address _burningContract)
  external
  onlyOwner
  returns (bool) {
    require(!authorizedBurner[_burningContract]);
    authorizedBurner[_burningContract] = true;
    emit LogBurnerAuthorized(msg.sender, _burningContract);
    return true;
  }

   
   
  function removeBurner(address _burningContract)
  external
  onlyOwner
  returns (bool) {
    require(authorizedBurner[_burningContract]);
    delete authorizedBurner[_burningContract];
    emit LogBurnerRemoved(msg.sender, _burningContract); 
    return true;
  }

   
  function ()
  external { 
    revert(); 
  }

   
   
   

   
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  event LogMYBBurned(address indexed _tokenHolder, address indexed _burningContract, uint _amount);
  event LogBurnerAuthorized(address _owner, address _burningContract);
  event LogBurnerRemoved(address _owner, address _burningContract); 
}