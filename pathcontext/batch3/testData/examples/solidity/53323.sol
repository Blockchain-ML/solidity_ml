pragma solidity ^0.4.24;

 
 
 

 
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

 

 
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

   
  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

   
  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

   
  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

   
  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
  }
}

 

 
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address addr, string roleName);
  event RoleRemoved(address addr, string roleName);

   
  function checkRole(address addr, string roleName)
    view
    public
  {
    roles[roleName].check(addr);
  }

   
  function hasRole(address addr, string roleName)
    view
    public
    returns (bool)
  {
    return roles[roleName].has(addr);
  }

   
  function addRole(address addr, string roleName)
    internal
  {
    roles[roleName].add(addr);
    emit RoleAdded(addr, roleName);
  }

   
  function removeRole(address addr, string roleName)
    internal
  {
    roles[roleName].remove(addr);
    emit RoleRemoved(addr, roleName);
  }

   
  modifier onlyRole(string roleName)
  {
    checkRole(msg.sender, roleName);
    _;
  }

   
   
   
   
   
   
   
   
   

   

   
   
}

 

 
contract Superuser is Ownable, RBAC {
  string public constant ROLE_SUPERUSER = "superuser";

  constructor () public {
    addRole(msg.sender, ROLE_SUPERUSER);
  }

   
  modifier onlySuperuser() {
    checkRole(msg.sender, ROLE_SUPERUSER);
    _;
  }

  modifier onlyOwnerOrSuperuser() {
    require(msg.sender == owner || isSuperuser(msg.sender));
    _;
  }

   
  function isSuperuser(address _addr)
    public
    view
    returns (bool)
  {
    return hasRole(_addr, ROLE_SUPERUSER);
  }

   
  function transferSuperuser(address _newSuperuser) public onlySuperuser {
    require(_newSuperuser != address(0));
    removeRole(msg.sender, ROLE_SUPERUSER);
    addRole(_newSuperuser, ROLE_SUPERUSER);
  }

   
  function transferOwnership(address _newOwner) public onlyOwnerOrSuperuser {
    _transferOwnership(_newOwner);
  }
}

 

 
library SafeMath {
   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function mul(uint256 a, uint256 b) 
      internal 
      pure 
      returns (uint256 c) 
  {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    require(c / a == b, "SafeMath mul failed");
    return c;
  }

   
  function sub(uint256 a, uint256 b)
      internal
      pure
      returns (uint256) 
  {
    require(b <= a, "SafeMath sub failed");
    return a - b;
  }

   
  function add(uint256 a, uint256 b)
      internal
      pure
      returns (uint256 c) 
  {
    c = a + b;
    require(c >= a, "SafeMath add failed");
    return c;
  }
  
   
  function sqrt(uint256 x)
      internal
      pure
      returns (uint256 y) 
  {
    uint256 z = ((add(x,1)) / 2);
    y = x;
    while (z < y) 
    {
      y = z;
      z = ((add((x / z),z)) / 2);
    }
  }
  
   
  function sq(uint256 x)
      internal
      pure
      returns (uint256)
  {
    return (mul(x,x));
  }
  
   
  function pwr(uint256 x, uint256 y)
      internal 
      pure 
      returns (uint256)
  {
    if (x==0)
        return (0);
    else if (y==0)
        return (1);
    else 
    {
      uint256 z = x;
      for (uint256 i=1; i < y; i++)
        z = mul(z,x);
      return (z);
    }
  }
}

 

 

interface IBuilding {

  function setPowerContract(address _powerContract) external;
  function influenceByToken(uint256 tokenId) external view returns(uint256);
  function levelByToken(uint256 tokenId) external view returns(uint256);
  function weightsApportion(uint256 ulevel1, uint256 ulevel2) external view returns(uint256);

  function building(uint256 tokenId) external view returns (uint256, int, int, uint8, uint256);
  function isBuilt(uint256 tokenId) external view returns (bool);

  function build(
    uint256 tokenId,
    int longitude,
    int latitude,
    uint8 popularity
    ) external;

  function batchBuild(
    uint256[] tokenIds,
    int[] longitudes,
    int[] latitudes,
    uint8[] popularitys
    ) external;

  function activenessUpgrade(uint256 tokenId, uint256 deltaActiveness) external;
  function batchActivenessUpgrade(uint256[] tokenIds, uint256[] deltaActiveness) external;

  function popularitySetting(uint256 tokenId, uint8 popularity) external;
  function batchPopularitySetting(uint256[] tokenIds, uint8[] popularitys) external;
  
   

  event Build (
    uint256 time,
    uint256 indexed tokenId,
    int longitude,
    int latitude,
    uint8 popularity
  );

  event ActivenessUpgrade (
    uint256 indexed tokenId,
    uint256 oActiveness,
    uint256 newActiveness
  );

  event PopularitySetting (
    uint256 indexed tokenId,
    uint256 oPopularity,
    uint256 newPopularity
  );
}

 

contract BuildingBase is IBuilding {
  using SafeMath for *;

  struct LDB {
    uint256 initAt;  
    int longitude;  
    int latitude;  
    uint8 popularity;  
    uint256 activeness;  
  }
  
  uint8 public constant decimals = 16;  

  mapping(uint256 => LDB) internal tokenLDBs;
  
  function _building(uint256 _tokenId) internal view returns (uint256, int, int, uint8, uint256) {
    LDB storage ldb = tokenLDBs[_tokenId];
    return (
      ldb.initAt, 
      ldb.longitude, 
      ldb.latitude, 
      ldb.popularity, 
      ldb.activeness
    );
  }
  
  function _isBuilt(uint256 _tokenId) internal view returns (bool){
    LDB storage ldb = tokenLDBs[_tokenId];
    return (ldb.initAt > 0);
  }

  function _build(
    uint256 _tokenId,
    int _longitude,
    int _latitude,
    uint8 _popularity
    ) internal {

     
    require(!_isBuilt(_tokenId));
    require(_isLongitude(_longitude));
    require(_isLatitude(_latitude));
    require(_popularity != 0);
    uint256 time = block.timestamp;
    LDB memory ldb = LDB(
      time, _longitude, _latitude, _popularity, uint256(0)
    );
    tokenLDBs[_tokenId] = ldb;
    emit Build(time, _tokenId, _longitude, _latitude, _popularity);
  }
  
  function _batchBuild(
    uint256[] _tokenIds,
    int[] _longitudes,
    int[] _latitudes,
    uint8[] _popularitys
    ) internal {
    uint256 i = 0;
    while (i < _tokenIds.length) {
      _build(
        _tokenIds[i],
        _longitudes[i],
        _latitudes[i],
        _popularitys[i]
      );
      i += 1;
    }

    
  }

  function _activenessUpgrade(uint256 _tokenId, uint256 _deltaActiveness) internal {
    require(_isBuilt(_tokenId));
    LDB storage ldb = tokenLDBs[_tokenId];
    uint256 oActiveness = ldb.activeness;
    uint256 newActiveness = ldb.activeness.add(_deltaActiveness);
    ldb.activeness = newActiveness;
    tokenLDBs[_tokenId] = ldb;
    emit ActivenessUpgrade(_tokenId, oActiveness, newActiveness);
  }
  function _batchActivenessUpgrade(uint256[] _tokenIds, uint256[] __deltaActiveness) internal {
    uint256 i = 0;
    while (i < _tokenIds.length) {
      _activenessUpgrade(_tokenIds[i], __deltaActiveness[i]);
      i += 1;
    }
  }

  function _popularitySetting(uint256 _tokenId, uint8 _popularity) internal {
    require(_isBuilt(_tokenId));
    uint8 oPopularity = tokenLDBs[_tokenId].popularity;
    tokenLDBs[_tokenId].popularity = _popularity;
    emit PopularitySetting(_tokenId, oPopularity, _popularity);
  }

  function _batchPopularitySetting(uint256[] _tokenIds, uint8[] _popularitys) internal {
    uint256 i = 0;
    while (i < _tokenIds.length) {
      _popularitySetting(_tokenIds[i], _popularitys[i]);
      i += 1;
    }
  }

  function _isLongitude (
    int _param
  ) internal pure returns (bool){
    
    return( 
      _param <= 180 * int(10 ** uint256(decimals))&&
      _param >= -180 * int(10 ** uint256(decimals))
      );
  } 

  function _isLatitude (
    int _param
  ) internal pure returns (bool){
    return( 
      _param <= 90 * int(10 ** uint256(decimals))&&
      _param >= -90 * int(10 ** uint256(decimals))
      );
  } 
}

 

interface IPower {
  function setBuildingContract(address building) external;
  function influenceByToken(uint256 tokenId) external view returns(uint256);
  function levelByToken(uint256 tokenId) external view returns(uint256);
  function weightsApportion(uint256 userLevel, uint256 lordLevel) external view returns(uint256);
}

 


contract Building is IBuilding, BuildingBase, Superuser {
  
  IPower public powerContract;

   
  function setPowerContract(address _powerContract) onlySuperuser external{
    powerContract = IPower(_powerContract);
  }

  
   
  function influenceByToken(uint256 tokenId) external view returns(uint256) {
    return powerContract.influenceByToken(tokenId);
  }


   
  function weightsApportion(uint256 userLevel, uint256 lordLevel) external view returns(uint256){
    return powerContract.weightsApportion(userLevel, lordLevel);
  }

   
  function levelByToken(uint256 tokenId) external view returns(uint256) {
    return powerContract.levelByToken(tokenId);
  }

   
  function building(uint256 tokenId) external view returns (uint256, int, int, uint8, uint256){
    return super._building(tokenId);
  }

   
  function isBuilt(uint256 tokenId) external view returns (bool){
    return super._isBuilt(tokenId);
  }

   
  function build(
    uint256 tokenId,
    int longitude,
    int latitude,
    uint8 popularity
  ) external onlySuperuser {
    super._build(tokenId, longitude, latitude, popularity);
  }

   
  function batchBuild(
    uint256[] tokenIds,
    int[] longitudes,
    int[] latitudes,
    uint8[] popularitys
    ) external onlySuperuser{

    super._batchBuild(
      tokenIds,
      longitudes,
      latitudes,
      popularitys
    );
  }

   
  function activenessUpgrade(uint256 tokenId, uint256 deltaActiveness) onlyOwnerOrSuperuser external {
    super._activenessUpgrade(tokenId, deltaActiveness);
  }

   
  function batchActivenessUpgrade(uint256[] tokenIds, uint256[] deltaActiveness) onlyOwnerOrSuperuser external {
    super._batchActivenessUpgrade(tokenIds, deltaActiveness);
  }

   
  function popularitySetting(uint256 tokenId, uint8 popularity) onlySuperuser external {
    super._popularitySetting(tokenId, popularity);
  }

   
  function batchPopularitySetting(uint256[] tokenIds, uint8[] popularitys) onlySuperuser external {
    super._batchPopularitySetting(tokenIds, popularitys);
  }
}