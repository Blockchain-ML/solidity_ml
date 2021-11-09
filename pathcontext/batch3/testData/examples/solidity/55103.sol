pragma solidity 0.5.1;

 
library SafeMath
{

   
  string constant OVERFLOW = "008001";
  string constant SUBTRAHEND_GREATER_THEN_MINUEND = "008002";
  string constant DIVISION_BY_ZERO = "008003";

   
  function mul(
    uint256 _factor1,
    uint256 _factor2
  )
    internal
    pure
    returns (uint256 product)
  {
     
     
     
    if (_factor1 == 0)
    {
      return 0;
    }

    product = _factor1 * _factor2;
    require(product / _factor1 == _factor2, OVERFLOW);
  }

   
  function div(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 quotient)
  {
     
    require(_divisor > 0, DIVISION_BY_ZERO);
    quotient = _dividend / _divisor;
     
  }

   
  function sub(
    uint256 _minuend,
    uint256 _subtrahend
  )
    internal
    pure
    returns (uint256 difference)
  {
    require(_subtrahend <= _minuend, SUBTRAHEND_GREATER_THEN_MINUEND);
    difference = _minuend - _subtrahend;
  }

   
  function add(
    uint256 _addend1,
    uint256 _addend2
  )
    internal
    pure
    returns (uint256 sum)
  {
    sum = _addend1 + _addend2;
    require(sum >= _addend1, OVERFLOW);
  }

   
  function mod(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 remainder) 
  {
    require(_divisor != 0, DIVISION_BY_ZERO);
    remainder = _dividend % _divisor;
  }

}

 
contract Abilitable
{

  using SafeMath for uint;

   
  string constant NOT_AUTHORIZED = "017001";
  string constant ONE_ZERO_ABILITY_HAS_TO_EXIST = "017002";

   
  uint8 constant ABILITY_TO_MANAGE_ABILITIES = 0;

   
  mapping(address => mapping(uint8 => bool)) private addressToAbility;

   
  uint256 private zeroAbilityCount;

   
  event AssignAbility(
    address indexed _target,
    uint8 indexed _ability
  );

   
  event RevokeAbility(
    address indexed _target,
    uint8 indexed _ability
  );

   
  modifier hasAbility(
    uint8 _ability
  ) 
  {
    require(addressToAbility[msg.sender][_ability], NOT_AUTHORIZED);
    _;
  }

   
  constructor()
    public
  {
    addressToAbility[msg.sender][0] = true;
    zeroAbilityCount = 1;
    emit AssignAbility(msg.sender, 0);
  }

   
  function assignAbilities(
    address _target,
    uint8[] memory _abilities
  )
    public
    hasAbility(ABILITY_TO_MANAGE_ABILITIES)
  {
    for(uint8 i; i<_abilities.length; i++)
    {
      if(_abilities[i] == 0)
      {
        zeroAbilityCount = zeroAbilityCount.add(1);
      }

      addressToAbility[_target][_abilities[i]] = true;
      emit AssignAbility(_target, _abilities[i]);
    }
  }

   
  function revokeAbilities(
    address _target,
    uint8[] memory _abilities
  )
    public
    hasAbility(ABILITY_TO_MANAGE_ABILITIES)
  {
    for(uint8 i; i<_abilities.length; i++)
    {
      if(_abilities[i] == 0 )
      {
        require(zeroAbilityCount > 1, ONE_ZERO_ABILITY_HAS_TO_EXIST);
        zeroAbilityCount--;
      }

      addressToAbility[_target][_abilities[i]] = false;
      emit RevokeAbility(_target, _abilities[i]);
    }
  }

   
  function isAble(
    address _target,
    uint8 _ability
  )
    public
    view
    returns (bool)
  {
    return addressToAbility[_target][_ability];
  }
  
}

 
interface Xcert
{
 
   
  event IsPaused(bool isPaused);

   
  event TokenImprintUpdate(
    uint256 indexed _tokenId,
    bytes32 _imprint
  );

   
  function create(
    address _to,
    uint256 _id,
    bytes32 _imprint
  )
    external;

   
  function setUriBase(
    string calldata _uriBase
  )
    external;

   
  function revoke(
    uint256 _tokenId
  )
    external;

   
  function setPause(
    bool _isPaused
  )
    external;

   
  function updateTokenImprint(
    uint256 _tokenId,
    bytes32 _imprint
  )
    external;

   
  function destroy(
    uint256 _tokenId
  )
    external;

   
  function schemaId()
    external
    view
    returns (bytes32 _schemaId);

   
  function tokenImprint(
    uint256 _tokenId
  )
    external
    view
    returns(bytes32 imprint);
    
}

 
contract XcertCreateProxy is 
  Abilitable 
{

   
  uint8 constant ABILITY_TO_EXECUTE = 1;

   
  function create(
    address _xcert,
    address _to,
    uint256 _id,
    bytes32 _imprint
  )
    external
    hasAbility(ABILITY_TO_EXECUTE)
  {
    Xcert(_xcert).create(_to, _id, _imprint);
  }
  
}