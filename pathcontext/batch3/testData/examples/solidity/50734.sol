pragma solidity ^0.4.15;

 




 
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


contract Bay is Galleasset {

  constructor(address _galleass) public Galleasset(_galleass) { }

  uint16 public width = 65535;  
  uint16 public depth = 65535;  

  uint256 public shipSpeed = 512; 

   
  mapping(uint16 => mapping(uint16 => mapping(address => Ship))) public ships;
   
  mapping(uint16 => mapping(uint16 => mapping(bytes32 => address))) public fish;
   
  mapping(uint16 => mapping(uint16 => mapping(address => bool))) public species;

  uint8 updateNonce = 0;
  event ShipUpdate(uint16 indexed x,uint16 indexed y,uint256 id,address indexed owner,uint timestamp,bool floating,bool sailing,bool direction,bool fishing,uint64 blockNumber,uint16 location);
  function emitShipUpdate(uint16 _x, uint16 _y,Ship thisShip) internal {
    emit ShipUpdate(_x,_y,thisShip.id,msg.sender,now*1000+(updateNonce++),thisShip.floating,thisShip.sailing,thisShip.direction,thisShip.fishing,thisShip.blockNumber,thisShip.location);
  }
   


  struct Ship{
    uint256 id;
    bool floating;
    bool sailing;
    bool direction;  
    bool fishing;
    uint64 blockNumber;
    uint16 location;
     
    bytes32 bait;
    bytes32 fish;
  }

   

   
  function allowSpecies(uint16 _x, uint16 _y, address _species) onlyOwner public returns (bool) {
    assert( _species != address(0) );
    species[_x][_y][_species]=true;
  }

   

   
   
   
  uint256 nonce;
  function stock(uint16 _x, uint16 _y,address _species,uint256 _amount) public isGalleasset("Bay") returns (bool) {
     
    require( _species != address(0) );
     
    require( species[_x][_y][_species] );
     
    StandardToken fishContract = StandardToken(_species);
    require( fishContract.transferFrom(msg.sender,address(this),_amount) );
    while(_amount-->0){
      bytes32 id = keccak256(nonce++,block.blockhash(block.number-1),msg.sender);
       
      require(fish[_x][_y][id]==address(0));
       
      fish[_x][_y][id] = _species;
       
      emit Fish(_x,_y,id,now,fish[_x][_y][id],fishContract.image());
    }
    return true;
  }
  event Fish(uint16 indexed x,uint16 indexed y,bytes32 id, uint256 timestamp, address species, bytes32 image);



   
   
   
  function embark(uint16 _x, uint16 _y,uint256 shipId) public isGalleasset("Bay") returns (bool) {
     
    require( !ships[_x][_y][msg.sender].floating );
     
    NFT shipsContract = NFT(getContract("Dogger"));
    require( shipsContract.ownerOf(shipId)==msg.sender );
     
    shipsContract.galleassetTransferFrom(msg.sender,address(this),shipId);
     
    require( shipsContract.ownerOf(shipId)==address(this) );

     
    Ship thisShip = ships[_x][_y][msg.sender];
    thisShip.id = shipId;
    thisShip.floating=true;
    thisShip.sailing=false;
    thisShip.location=getHarborLocation(_x,_y);
    thisShip.blockNumber=uint64(block.number);
    thisShip.direction=false;

    emitShipUpdate(_x,_y,thisShip);
    return true;
  }



   
   
   
  function disembark(uint16 _x, uint16 _y,uint256 shipId) public isGalleasset("Bay") returns (bool) {
     
    require( ships[_x][_y][msg.sender].id==shipId );
     
    require( ships[_x][_y][msg.sender].floating );
     
    require( inRangeToDisembark(_x,_y,msg.sender) );
     
    NFT shipsContract = NFT(getContract("Dogger"));
    require( shipsContract.ownerOf(shipId)==address(this) );
    shipsContract.galleassetTransferFrom(address(this),msg.sender,shipId);
    require( shipsContract.ownerOf(shipId)==msg.sender );

     
    uint256 deletedId = ships[_x][_y][msg.sender].id;
    Ship thisShip = ships[_x][_y][msg.sender];
    thisShip.floating=false;
    thisShip.sailing=false;
    emit ShipUpdate(_x,_y,deletedId,msg.sender,now*1000+(updateNonce++),thisShip.floating,thisShip.sailing,thisShip.direction,thisShip.fishing,thisShip.blockNumber,thisShip.location);

    delete ships[_x][_y][msg.sender];
    return true;
  }




   
   
   
  function setSail(uint16 _x, uint16 _y,bool direction) public isGalleasset("Bay") returns (bool) {

    Ship thisShip = ships[_x][_y][msg.sender];

     
    require( thisShip.floating );
    require( !thisShip.fishing );
    require( !thisShip.sailing );

    thisShip.sailing=true;
    thisShip.blockNumber=uint64(block.number);
    thisShip.direction=direction;

    emitShipUpdate(_x,_y,thisShip);
    return true;
  }


   
   
   
  function dropAnchor(uint16 _x, uint16 _y) public isGalleasset("Bay") returns (bool) {

    Ship thisShip = ships[_x][_y][msg.sender];

    require( thisShip.floating );
    require( thisShip.sailing );

    thisShip.location = shipLocation(_x,_y,msg.sender);
    thisShip.blockNumber = uint64(block.number);
    thisShip.sailing = false;

    emitShipUpdate(_x,_y,thisShip);
    return true;
  }

   
   
   
  function castLine(uint16 _x, uint16 _y,bytes32 baitHash) public isGalleasset("Bay") returns (bool) {

    Ship thisShip = ships[_x][_y][msg.sender];

    require( thisShip.floating );
    require( !thisShip.sailing );
    require( !thisShip.fishing );

    thisShip.fishing = true;
    thisShip.blockNumber = uint64(block.number);
    thisShip.bait = baitHash;

    emitShipUpdate(_x,_y,thisShip);
    return true;
  }


   
   
   
  function reelIn(uint16 _x, uint16 _y,bytes32 _fish, bytes32 _bait) public isGalleasset("Bay") returns (bool) {

    Ship thisShip = ships[_x][_y][msg.sender];

    require( thisShip.floating );
    require( thisShip.fishing );
    require( block.number > thisShip.blockNumber); 
    if(_bait==0){
       
       
      thisShip.fishing = false;
      emitShipUpdate(_x,_y,thisShip);
      return false;
    }
    require( species[_x][_y][fish[_x][_y][_fish]] ); 
    require( keccak256(_bait) == thisShip.bait); 

    thisShip.fishing = false;
    emitShipUpdate(_x,_y,thisShip);

    if(_catchFish(thisShip,_fish,_bait)){
      _doCatchFish(_x,_y,_fish);
      return true;
    }else{
      return false;
    }
  }
  event Catch(uint16 indexed _x, uint16 indexed _y,address account, bytes32 id, uint256 timestamp, address species);

  function _doCatchFish(uint16 _x, uint16 _y,bytes32 _fish) internal {
    assert( fish[_x][_y][_fish]!=address(0) );

    StandardToken thisFishContract = StandardToken(fish[_x][_y][_fish]);
    require( thisFishContract.transfer(msg.sender,1) );
    Catch(_x,_y,msg.sender,_fish,now,fish[_x][_y][_fish]);
    Fish(_x,_y,_fish, now, fish[_x][_y][_fish],thisFishContract.image());

    fish[_x][_y][_fish] = address(0);

    address experienceContractAddress = getContract("Experience");
    require( experienceContractAddress!=address(0) );
    Experience experienceContract = Experience(experienceContractAddress);
    experienceContract.update(msg.sender,2,true); 
  }



   

  function getShip(uint16 _x, uint16 _y,address _address) public constant returns (
    uint256 id,
    bool floating,
    bool sailing,
    bool direction,
    bool fishing,
    uint64 blockNumber,
    uint16 location
  ) {
    uint16 loc = shipLocation(_x,_y,_address);
    Ship thisShip = ships[_x][_y][_address];
    return(
      thisShip.id,
      thisShip.floating,
      thisShip.sailing,
      thisShip.direction,
      thisShip.fishing,
      thisShip.blockNumber,
      loc
    );
  }



   
   
   
  function fishLocation(bytes32 id) public constant returns(uint16,uint16) {
    bytes16[2] memory parts = [bytes16(0), 0];
        assembly {
            mstore(parts, id)
            mstore(add(parts, 16), id)
        }
    return (uint16(uint(parts[0]) % width),uint16(uint(parts[1]) % depth));
  }

   
   
   
  function shipLocation(uint16 _x, uint16 _y,address _owner) public constant returns (uint16) {

    Ship thisShip = ships[_x][_y][_owner];

    if(!thisShip.sailing){
      return thisShip.location;
    }else{
      uint256 blocksTraveled = block.number - thisShip.blockNumber;
      uint256 pixelsTraveled = blocksTraveled * shipSpeed;
      uint16 location;
      if( thisShip.direction ){
        location = thisShip.location + uint16(pixelsTraveled);
      } else {
        location = thisShip.location - uint16(pixelsTraveled);
      }
      return location;
    }
  }

  function inRangeToDisembark(uint16 _x, uint16 _y,address _account) public constant returns (bool) {
     
    if(ships[_x][_y][_account].location==0 || !ships[_x][_y][_account].floating) return false;
     
    uint16 harborLocation = getHarborLocation(_x,_y);
     
    if(ships[_x][_y][_account].location >= harborLocation){
      return ((ships[_x][_y][_account].location-harborLocation) < 3000);
    }else{
      return ((harborLocation-ships[_x][_y][_account].location) < 3000);
    }
  }

  function getHarborLocation(uint16 _x, uint16 _y) public constant returns (uint16) {
    Land landContract = Land(getContract("Land"));
     
    uint16 harborLocation = landContract.getTileLocation(_x,_y,getContract("Harbor"));
    return uint16((65535 * uint256(harborLocation)) / 4000);
  }

   


   
   
   
   
  function _catchFish(Ship thisShip,bytes32 _fish, bytes32 bait) internal returns (bool) {

    bytes32 catchHash = keccak256(bait,block.blockhash(thisShip.blockNumber));
    bytes32 depthHash = keccak256(bait,catchHash,block.blockhash(thisShip.blockNumber));
    uint randomishWidthNumber = uint16( uint(catchHash) % width/5 );
    uint depthPlus = depth;
    depthPlus+=depth/3;
    uint randomishDepthNumber =  uint(depthHash) % (depthPlus) ;

    uint16 fishx;
    uint16 fishy;
    (fishx,fishy) = fishLocation(_fish);

    uint16 distanceToFish = 0;
    if(thisShip.location > fishx){
      distanceToFish+=thisShip.location-fishx;
    }else{
      distanceToFish+=fishx-thisShip.location;
    }
    bool result = ( distanceToFish < randomishWidthNumber && fishy < randomishDepthNumber);
    Attempt(msg.sender,randomishWidthNumber, randomishDepthNumber, fishx, fishy, distanceToFish, result);
    return result;
  }
  event Attempt(address account,uint randomishWidthNumber,uint randomishDepthNumber,uint16 fishx,uint16 fishy,uint16 distanceToFish,bool result);
}

contract Land {
  uint16 public mainX;
  uint16 public mainY;
  function getTileLocation(uint16 _x,uint16 _y,address _address) public constant returns (uint16) { }
  function findTileByAddress(uint16 _x,uint16 _y,address _address) public constant returns (uint8) { }
}

contract NFT {
  function transferFrom(address _from,address _to,uint256 _tokenId) external { }
  function galleassetTransferFrom(address _from,address _to,uint256 _tokenId) external { }
  function ownerOf(uint256 _tokenId) external view returns (address owner) { }
}

contract StandardToken {
  bytes32 public image;
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) { }
  function transfer(address _to, uint256 _value) public returns (bool) { }
}

contract Experience{
  function update(address _player,uint16 _milestone,bool _value) public returns (bool) { }
}