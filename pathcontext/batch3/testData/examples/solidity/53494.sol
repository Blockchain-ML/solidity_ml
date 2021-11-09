pragma solidity ^0.4.23;

 


 




 
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


contract Galleasset is Ownable {

  address public galleass;

  constructor(address _galleass) public {
    galleass=_galleass;
  }

  function upgradeGalleass(address _galleass) public returns (bool) {
    require(msg.sender == galleass);
    galleass=_galleass;
    return true;
  }

  function getContract(bytes32 _name) public view returns (address){
    Galleass galleassContract = Galleass(galleass);
    return galleassContract.getContract(_name);
  }

  function hasPermission(address _contract,bytes32 _permission) public view returns (bool){
    Galleass galleassContract = Galleass(galleass);
    return galleassContract.hasPermission(_contract,_permission);
  }

  function getGalleassTokens(address _from,bytes32 _name,uint256 _amount) internal returns (bool) {
    return StandardTokenInterface(getContract(_name)).galleassTransferFrom(_from,address(this),_amount);
  }

  function getTokens(address _from,bytes32 _name,uint256 _amount) internal returns (bool) {
    return StandardTokenInterface(getContract(_name)).transferFrom(_from,address(this),_amount);
  }

  function approveTokens(bytes32 _name,address _to,uint256 _amount) internal returns (bool) {
    return StandardTokenInterface(getContract(_name)).approve(_to,_amount);
  }

  function withdraw(uint256 _amount) public onlyOwner isBuilding returns (bool) {
    require(address(this).balance >= _amount);
    assert(owner.send(_amount));
    return true;
  }
  function withdrawToken(address _token,uint256 _amount) public onlyOwner isBuilding returns (bool) {
    StandardTokenInterface token = StandardTokenInterface(_token);
    token.transfer(msg.sender,_amount);
    return true;
  }

   
   
   
  modifier isGalleasset(bytes32 _name) {
    Galleass galleassContract = Galleass(galleass);
    require(address(this) == galleassContract.getContract(_name));
    _;
  }

  modifier isBuilding() {
    Galleass galleassContract = Galleass(galleass);
    require(galleassContract.stagedMode() == Galleass.StagedMode.BUILD);
    _;
  }

}


contract Galleass {
  function getContract(bytes32 _name) public constant returns (address) { }
  function hasPermission(address _contract, bytes32 _permission) public view returns (bool) { }
  enum StagedMode {PAUSED,BUILD,STAGE,PRODUCTION}
  StagedMode public stagedMode;
}

contract StandardTokenInterface {
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) { }
  function galleassTransferFrom(address _from, address _to, uint256 _value) public returns (bool) { }
  function transfer(address _to, uint256 _value) public returns (bool) { }
  function approve(address _spender, uint256 _value) public returns (bool) { }
}


 


contract DataParser{

  function getX(bytes _data) internal constant returns (uint16 _x){
    return uint16(_data[1]) << 8 | uint16(_data[2]);
  }

  function getY(bytes _data) internal constant returns (uint16 _y){
    return uint16(_data[3]) << 8 | uint16(_data[4]);
  }

  function getTile(bytes _data) internal constant returns (uint8 _tile){
    return uint8(_data[5]);
  }

  function getRemainingBytesLeadingZs(uint8 _offset, bytes _data) internal constant returns (bytes32 result){
    uint8 b = 31;
    uint8 d = uint8(_data.length-1);
    while(d>_offset-1){
      result |= bytes32(_data[d--] & 0xFF) >> (b-- * 8);
    }
    return result;
  }


  function getRemainingBytesTrailingZs(uint _offset,bytes _data) internal constant returns (bytes32 result) {
    for (uint i = 0; i < 32; i++) {
      uint8 adjusted = uint8(_offset + i);
      if(adjusted<_data.length){
          result |= bytes32(_data[adjusted] & 0xFF) >> (i * 8);
      }else{
          result |= bytes32(0x00) >> (i * 8);
      }
    }
    return result;
  }

  function getRemainingUint(uint8 _offset,bytes _data) internal constant returns (uint) {
    uint result = 0;
    uint endsAt = _data.length;
    uint8 d = uint8(endsAt-1);
    while(d>_offset-1){
      uint c = uint(_data[d]);
      uint to_inc = c * ( 16 ** ((endsAt - d-1) * 2));
      result += to_inc;
      d--;
    }
    return result;
  }

  function getAddressFromBytes(uint8 _offset,bytes _data) internal constant returns (address) {
    uint result = 0;
    uint endsAt = _offset+20;
    uint8 d = uint8(endsAt-1);
    while(d>_offset-1){
      uint c = uint(_data[d]);
      uint to_inc = c * ( 16 ** ((endsAt - d-1) * 2));
      result += to_inc;
      d--;
    }
    return address(result);
  }


}


contract StandardTile is Galleasset, DataParser{

  constructor(address _galleass) public Galleasset(_galleass) { }
  function () public {revert();}

   
  mapping(uint16 => mapping(uint16 => mapping(uint8 => address))) public landOwners;

   
   
  mapping(uint16 => mapping(uint16 => mapping(uint8 => mapping(address => uint256)))) public tokenBalance;

   
   
  function onPurchase(uint16 _x,uint16 _y,uint8 _tile,address _owner,uint _amount) public returns (bool) {
    require(msg.sender==getContract("Land") || msg.sender==getContract("LandLib"));
    landOwners[_x][_y][_tile] = _owner;
    emit LandOwner(_x,_y,_tile,_owner);
    return true;
  }
  event LandOwner(uint16 _x,uint16 _y,uint8 _tile,address _owner);

  modifier isLandOwner(uint16 _x,uint16 _y,uint8 _tile) {
    require(msg.sender==landOwners[_x][_y][_tile]);
    _;
  }

   
  function _sendToken(address _sender, uint _amount, bytes _data) internal returns (bool) {
    uint16 _x = getX(_data);
    uint16 _y = getY(_data);
    uint8 _tile = getTile(_data);
    _incrementTokenBalance(_x,_y,_tile,msg.sender,_amount);
    return true;
  }

   
  function _incrementTokenBalance(uint16 _x,uint16 _y,uint8 _tile,address _token,uint _amount) internal {
    tokenBalance[_x][_y][_tile][_token]+=_amount;
    require(tokenBalance[_x][_y][_tile][_token]>=_amount,"Overflow?");
  }
  function _decrementTokenBalance(uint16 _x,uint16 _y,uint8 _tile,address _token,uint _amount) internal {
    require(tokenBalance[_x][_y][_tile][_token]>=_amount,"This tile does not have enough of this token");
    tokenBalance[_x][_y][_tile][_token]-=_amount;
  }
}


contract Fishmonger is StandardTile {

  uint8 public constant FILLETSPERFISH = 4;

  constructor(address _galleass) public StandardTile(_galleass) { }

   
   
  mapping(uint16 => mapping(uint16 => mapping(uint8 => mapping (address => uint256)))) public price;

   
   
  mapping(uint16 => mapping(uint16 => mapping(uint8 => uint256))) public filletPrice;


  function onPurchase(uint16 _x,uint16 _y,uint8 _tile,address _owner,uint _amount) public returns (bool) {
    require(super.onPurchase(_x,_y,_tile,_owner,_amount));
     
    filletPrice[_x][_y][_tile] = 3;
    return true;
  }

  function setPrice(uint16 _x,uint16 _y,uint8 _tile,address _species,uint256 _price) public isGalleasset("Fishmonger") isLandOwner(_x,_y,_tile) returns (bool) {
    assert( _species != address(0) );
    price[_x][_y][_tile][_species]=_price;
  }

  function setFilletPrice(uint16 _x,uint16 _y,uint8 _tile,uint256 _price) public isGalleasset("Fishmonger") isLandOwner(_x,_y,_tile) returns (bool) {
    filletPrice[_x][_y][_tile]=_price;
  }

  function sellFish(uint16 _x,uint16 _y,uint8 _tile,address _species,uint256 _amount) public isGalleasset("Fishmonger") returns (bool) {
     
    require( _species != address(0) );
     
    uint256 fishPrice = _getFishPrice(_x,_y,_tile,_species);
    require( fishPrice>0 );
     
    require( _amount>0 );
     
    StandardToken fishContract = StandardToken(_species);
    require( fishContract.galleassTransferFrom(msg.sender,address(this),_amount) );
     
    _restockBay(fishContract,_x,_y,_species,_amount);
     
    StandardToken filletContract = StandardToken(getContract("Fillet"));
    require( filletContract.galleassMint(address(this),_amount*FILLETSPERFISH) );  
     
    _incrementTokenBalance(_x,_y,_tile,getContract("Fillet"),_amount);

     
    address copperContractAddress = getContract("Copper");
     
    _decrementTokenBalance(_x,_y,_tile,copperContractAddress,fishPrice*_amount);
    StandardToken copperContract = StandardToken(copperContractAddress);
    require( copperContract.transfer(msg.sender,fishPrice*_amount) );


    _updateExperience(msg.sender);
    return true;
  }

  function _restockBay(StandardToken fishContract,uint16 _x,uint16 _y,address _species,uint256 _amount) internal {
    address bayContractAddress = getContract("Bay");
    Bay bayContract = Bay(bayContractAddress);
    require( fishContract.approve(bayContractAddress,_amount) );
    require( bayContract.stock(_x,_y,_species,_amount) );
  }

  function onTokenTransfer(address _sender, uint _amount, bytes _data) public isGalleasset("Fishmonger") returns (bool){
    emit TokenTransfer(msg.sender,_sender,_amount,_data);
    uint8 action = uint8(_data[0]);
    if(action==0){
      return _sendToken(_sender,_amount,_data);
    } else if(action==1){
      return _buyFillet(_sender,_amount,_data);
    } else if(action==2){
       
    } else {
      revert("unknown action");
    }
  }
  event TokenTransfer(address token,address sender,uint amount,bytes data);

   
  function _buyFillet(address _sender, uint _amount, bytes _data) internal returns (bool) {
    uint16 _x = getX(_data);
    uint16 _y = getY(_data);
    uint8 _tile = getTile(_data);
    require(msg.sender == getContract("Copper"),"Requires copper is sent in");
    address filletAddress = getContract("Fillet");
    require(filletAddress != address(0), "Fillet must have address");
    require(filletPrice[_x][_y][_tile] > 0, "Fillet must have a price");
    uint filletAmount = _amount / filletPrice[_x][_y][_tile];
    require(filletAmount>0,"Amount was too low?");
     
    _decrementTokenBalance(_x,_y,_tile,filletAddress,filletAmount);
     
    _incrementTokenBalance(_x,_y,_tile,msg.sender,_amount);
     
    StandardToken filletContract = StandardToken(filletAddress);
    require(filletContract.transfer(_sender,filletAmount), "Failed to transfer fillets");
    return true;
  }

   
  function _getFishPrice(uint16 _x,uint16 _y,uint8 _tile,address _species) internal returns (uint256) {
    return  price[_x][_y][_tile][_species];
  }
  function _updateExperience(address _player) internal returns (bool){
    address experienceContractAddress = getContract("Experience");
    require( experienceContractAddress!=address(0) );
    Experience experienceContract = Experience(experienceContractAddress);
    experienceContract.update(_player,3,true); 
  }

}

  contract Bay{
    function stock(uint16 _x,uint16 _y,address _species,uint256 _amount) public returns (bool) { }
  }

  contract StandardToken {
    bytes32 public image;
    function approve(address _spender, uint256 _value) public returns (bool) { }
    function galleassMint(address _to, uint256 _amount) public returns (bool) { }
    function hasPermission(address _contract,bytes32 _permission) public view returns (bool){ }
    function galleassTransferFrom(address _from, address _to, uint256 _value) public returns (bool) { }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) { }
    function transfer(address _to, uint256 _value) public returns (bool) { }
    function balanceOf(address _owner) public view returns (uint256 balance) { }
  }

  contract Experience{
    function update(address _player,uint16 _milestone,bool _value) public returns (bool) { }
  }