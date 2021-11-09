pragma solidity ^0.5.0;

 

 
interface PassportInterface {

  function hasActivePass(address owner) external view returns(bool);

  function getPassOwner(bytes32 pass) external view returns (address);

  function isPassOwner(bytes32 pass, address owner) external view returns (bool);

  function isOwner(address account) external view returns(bool);

  function isIssuer(address account) external view returns(bool);

  function isProvider(address account) external view returns(bool);

  function isClient(address account) external view returns(bool);

   
   
   
   
   
   
   
   
   
   
   
   
   
   
  event Passport(
    bytes32 indexed pass,
    address indexed owner,
    uint256 typePass
  );
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   


}

 

 
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

     
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

     
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

 



contract Passport is PassportInterface, Ownable {

    struct Pass {
       
      uint8 typePass;  
      address ownerPass;  
      bool isActive;
       
      bool isOwner;  
      bool isProvider;  
      bool isIssuer;  
      bool isClient;   
    }

    mapping (address => bytes32) attachment;
    mapping (bytes32 => Pass) passport;

     
    function hasActivePass(address account) public view returns(bool) {
      return passport[attachment[account]].isActive == true ?true : false;
    }

     
    function getPassOwner(bytes32 pass) public view returns(address) {
      return passport[pass].ownerPass;
    }

     
    function getPass(address account) public view returns(bytes32) {
       return attachment[account];
    }

     
    function isPassOwner(bytes32 pass, address owner) public view returns(bool) {
      if (passport[pass].ownerPass == owner){
        return true;
      } else {
        return false;
      }
    }

     

     
    function isOwner(address account) public view returns(bool) {
      require(hasActivePass(account));
      return passport[attachment[account]].isOwner == true ? true : false;
    }

     
    function isProvider(address account) public view returns(bool) {
      require(hasActivePass(account));
      return passport[attachment[account]].isProvider == true? true : false;
    }

     
    function isClient(address account) public view returns(bool) {
      require(hasActivePass(account));
      return passport[attachment[account]].isClient == true ?true : false;
    }

     
    function isIssuer(address account) public view returns(bool) {
      require(hasActivePass(account));
      return passport[attachment[account]].isIssuer == true ?true : false;
    }

     
    function grantProvider(address account) public onlyOwner returns(bool) {
      require(hasActivePass(account));
      passport[attachment[account]].isProvider = true;
      return true;
    }

     
    function grantIssuer(address account) public onlyOwner returns(bool) {
      require(hasActivePass(account));
      passport[attachment[account]].isIssuer = true;
      return true;
    }


    function issuePass(address account, bytes32 pass, uint8 typePass) public returns(bool){


      if (typePass == 3){
          require(isOwner());
          passport[pass].typePass = typePass;
          passport[pass].isActive = true;
          passport[pass].ownerPass = account;
      }
      else if (typePass == 1 || typePass == 2) {
        require(isProvider(msg.sender));
        passport[pass].typePass = typePass;
        passport[pass].isClient = true;
        passport[pass].isActive = true;
        passport[pass].ownerPass = account;
      }
      attachment[account] = pass;
      emit Passport(pass, account, typePass);
       
      return true;
    }
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     

}