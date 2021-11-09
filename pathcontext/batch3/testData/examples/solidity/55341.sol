pragma solidity 0.5.1;

 
library SafeMath
{

   
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
    require(product / _factor1 == _factor2);
  }

   
  function div(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 quotient)
  {
     
    require(_divisor > 0);
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
    require(_subtrahend <= _minuend);
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
    require(sum >= _addend1);
  }

   
  function mod(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 remainder) 
  {
    require(_divisor != 0);
    remainder = _dividend % _divisor;
  }

}

 
interface Proxy {

   
  function execute(
    address _target,
    address _a,
    address _b,
    uint256 _c
  )
    external;
    
}

 
interface ERC20
{

   
  function name()
    external
    view
    returns (string memory _name);

   
  function symbol()
    external
    view
    returns (string memory _symbol);

   
  function decimals()
    external
    view
    returns (uint8 _decimals);

   
  function totalSupply()
    external
    view
    returns (uint256 _totalSupply);

   
  function balanceOf(
    address _owner
  )
    external
    view
    returns (uint256 _balance);

   
  function transfer(
    address _to,
    uint256 _value
  )
    external
    returns (bool _success);

   
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    external
    returns (bool _success);

   
  function approve(
    address _spender,
    uint256 _value
  )
    external
    returns (bool _success);

   
  function allowance(
    address _owner,
    address _spender
  )
    external
    view
    returns (uint256 _remaining);

   
  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 _value
  );

   
  event Approval(
    address indexed _owner,
    address indexed _spender,
    uint256 _value
  );

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

 
contract TokenTransferProxy is 
  Proxy,
  Abilitable 
{

   
  uint8 constant ABILITY_TO_EXECUTE = 1;

   
  string constant TRANSFER_FAILED = "012001";

   
  function execute(
    address _target,
    address _a,
    address _b,
    uint256 _c
  )
    public
    hasAbility(ABILITY_TO_EXECUTE)
  {
    require(
      ERC20(_target).transferFrom(_a, _b, _c),
      TRANSFER_FAILED
    );
  }
  
}