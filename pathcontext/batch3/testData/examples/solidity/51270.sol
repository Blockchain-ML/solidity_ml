pragma solidity ^0.4.24;

 


 
 
 
 

 
 
 
 
 

 
 
 
 
 

 
 
 
 

 
 
contract GasBoy {
   
  constructor() public {
     whitelist[msg.sender] = true;
  }
   
  mapping(address => uint) public nonce;
   
   
  mapping(address => bool) public whitelist;
  function updateWhitelist(address _account, bool _value) public returns(bool) {
   require(whitelist[msg.sender],"GasBoy::updateWhitelist Account Not Whitelisted");
   whitelist[_account] = _value;
   emit UpdateWhitelist(_account,_value);
   return true;
  }
  event UpdateWhitelist(address _account, bool _value);
   
  function () public payable { emit Received(msg.sender, msg.value); }
  event Received (address indexed sender, uint value);

  function getHash(address signer, address destination, uint value, bytes data, address rewardToken, uint rewardAmount) public view returns(bytes32){
    return keccak256(abi.encodePacked(address(this), signer, destination, value, data, rewardToken, rewardAmount, nonce[signer]));
  }


   
  function forward(bytes sig, address signer, address destination, uint value, bytes data, address rewardToken, uint rewardAmount) public {
       
      bytes32 _hash = getHash(signer, destination, value, data, rewardToken, rewardAmount);
       
      nonce[signer]++;
       
      require(signerIsWhitelisted(_hash,sig),"GasBoy::forward Signer is not whitelisted");
       
       
      if(rewardAmount>0){
         
        if(rewardToken==address(0)){
           
          require(msg.sender.call.value(rewardAmount).gas(36000)());
        }else{
           
          require((StandardToken(rewardToken)).transfer(msg.sender,rewardAmount));
        }
      }
       
      require(executeCall(destination, value, data));
      emit Forwarded(sig, signer, destination, value, data, rewardToken, rewardAmount, _hash);
  }
   
  event Forwarded (bytes sig, address signer, address destination, uint value, bytes data,address rewardToken, uint rewardAmount,bytes32 _hash);

   
   
   
  function executeCall(address to, uint256 value, bytes data) internal returns (bool success) {
    assembly {
       success := call(gas, to, value, add(data, 0x20), mload(data), 0, 0)
    }
  }

   
   
  function signerIsWhitelisted(bytes32 _hash, bytes _signature) internal view returns (bool){
    bytes32 r;
    bytes32 s;
    uint8 v;
     
    if (_signature.length != 65) {
      return false;
    }
     
     
     
     
    assembly {
      r := mload(add(_signature, 32))
      s := mload(add(_signature, 64))
      v := byte(0, mload(add(_signature, 96)))
    }
     
    if (v < 27) {
      v += 27;
    }
     
    if (v != 27 && v != 28) {
      return false;
    } else {
       
      return whitelist[ecrecover(keccak256(
        abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
      ), v, r, s)];
    }
  }
}

contract StandardToken {
  function transfer(address _to,uint256 _value) public returns (bool) { }
}