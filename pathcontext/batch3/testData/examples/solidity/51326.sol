pragma solidity 0.4.25;

 
 
 
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint tokens, address token, bytes data) public;
}

 
 
 
 
contract MyBitToken {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}



 
 
 
 
 
interface Database {

     

    function setAddress(bytes32 _key, address _value)
    external;

    function setUint(bytes32 _key, uint _value)
    external;

    function setString(bytes32 _key, string _value)
    external;

    function setBytes(bytes32 _key, bytes _value)
    external;

    function setBytes32(bytes32 _key, bytes32 _value)
    external;

    function setBool(bytes32 _key, bool _value)
    external;

    function setInt(bytes32 _key, int _value)
    external;


      

    function deleteAddress(bytes32 _key)
    external;

    function deleteUint(bytes32 _key)
    external;

    function deleteString(bytes32 _key)
    external;

    function deleteBytes(bytes32 _key)
    external;

    function deleteBytes32(bytes32 _key)
    external;

    function deleteBool(bytes32 _key)
    external;

    function deleteInt(bytes32 _key)
    external;

     

    function uintStorage(bytes32 _key)
    external
    returns (uint);

    function stringStorage(bytes32 _key)
    external
    returns (string);

    function addressStorage(bytes32 _key)
    external
    returns (address);

    function bytesStorage(bytes32 _key)
    external
    returns (bytes);

    function bytes32Storage(bytes32 _key)
    external
    returns (bytes32);

    function boolStorage(bytes32 _key)
    external
    returns (bool);

    function intStorage(bytes32 _key)
    external
    returns (bool);
}


 

   
   
   
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
     
     
     
    return a / b;
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

 
 
contract TokenFaucet {
  using SafeMath for uint; 

  MyBitToken public mybToken;
  Database public database; 

  uint public mybTokensInFaucet;
  uint public balanceWEI; 

  uint public dripAmountMYB = uint(10e21);      
  uint public dripAmountWEI = 500 finney;     

  bytes32 private accessPass; 

  uint public oneYear = uint(31536000);     


  constructor(address _database, address _mybTokenAddress, bytes32 _accessPass)
  public  {
    database = Database(_database); 
    mybToken = MyBitToken(_mybTokenAddress);
    accessPass = _accessPass; 
  }

   
   
  function receiveApproval(address _from, uint _amount, address _mybToken, bytes _data)
  external {
    require(_mybToken == msg.sender && _mybToken == address(mybToken));
    require(mybToken.transferFrom(_from, this, _amount));
    mybTokensInFaucet = mybTokensInFaucet.add(_amount);
    emit LogMYBDeposited(_from, _amount, _data);
  }

   
  function depositWEI()
  external 
  payable { 
    balanceWEI = balanceWEI.add(msg.value); 
    emit LogEthDeposited(msg.sender, msg.value); 
  }

     
  function withdraw(string _pass)
  external {
    require (keccak256(abi.encodePacked(_pass)) == accessPass); 
    uint expiry = now.add(oneYear);
    uint accessLevel = database.uintStorage(keccak256(abi.encodePacked("userAccess", msg.sender))); 
    if (accessLevel < 1){ 
      database.setUint(keccak256(abi.encodePacked("userAccess", msg.sender)), 1);   
      database.setUint(keccak256(abi.encodePacked("userAccessExpiration", msg.sender)), expiry);
      emit LogNewUser(msg.sender);
    }
    if (mybToken.balanceOf(msg.sender) < dripAmountMYB) { 
      uint amountMYB = dripAmountMYB.sub(mybToken.balanceOf(msg.sender)); 
      mybTokensInFaucet = mybTokensInFaucet.sub(amountMYB);
      mybToken.transfer(msg.sender, amountMYB); 
    }
    if (msg.sender.balance < dripAmountWEI) { 
      uint amountWEI = dripAmountWEI.sub(msg.sender.balance); 
      balanceWEI = balanceWEI.sub(amountWEI); 
      msg.sender.transfer(amountWEI);
    }
    emit LogWithdraw(msg.sender, amountMYB, amountWEI);
  }

  function changePass(bytes32 _newPass)
  external 
  anyOwner
  returns (bool) { 
    accessPass = _newPass; 
    return true; 
  }

  function changeDripAmounts(uint _newAmountWEI, uint _newAmountMYB)
  external 
  anyOwner
  returns (bool) { 
    dripAmountWEI = _newAmountWEI; 
    dripAmountMYB = _newAmountMYB; 
    return true; 
  }

   
   
   
  modifier anyOwner {
    require(database.boolStorage(keccak256(abi.encodePacked("owner", msg.sender))));
    _;
  }

  event LogWithdraw(address _sender, uint _amountMYB, uint _amountWEI);
  event LogMYBDeposited(address _depositer, uint _amount, bytes _data);
  event LogEthDeposited(address _depositer, uint _amountWEI); 
  event LogEthWithdraw(address _withdrawer, uint _amountWEI); 
  event LogNewUser(address _user); 
}