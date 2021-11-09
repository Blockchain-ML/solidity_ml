pragma solidity ^0.4.13;

contract SupplyManager {
    using SafeMath for uint256;

    UtilityToken utilityToken;
    SecurityToken securityToken;

     
     
    uint256 mint_capacity_multiplier = 1;

    mapping (address=>uint256) mintBalance;

    constructor() public {
        utilityToken = new UtilityToken(this);
        securityToken = new SecurityToken(this);
    }

    function finalizeMintUtility(address _account, uint256 _amount) public {
        require(msg.sender == address(utilityToken));
        require(_account != address(0));

        uint256 current_balance_security = securityToken.balanceOf(_account);
        uint256 mint_capacity = current_balance_security.mul(mint_capacity_multiplier);

        uint256 newMintBalance = mintBalance[_account].add(_amount);

        assert(mint_capacity >= mintBalance[_account]);
        require(mint_capacity >= newMintBalance);
        mintBalance[_account] = newMintBalance;
    }

    function finalizeBurnUtility(address _account, uint256 _amount) public {
        require(msg.sender == address(utilityToken));
        require(_account != address(0));
        require(_amount <= mintBalance[_account]);

        mintBalance[_account] = mintBalance[_account].sub(_amount);
    }

     
    function canMintUtility(address _account, uint256 _amount) public view returns (bool){                
        require(msg.sender == address(utilityToken));
        require(_account != address(0));

        uint256 current_balance_security = securityToken.balanceOf(_account);
        uint256 mint_capacity = current_balance_security.mul(mint_capacity_multiplier);

        assert(mint_capacity >= mintBalance[_account]);

        return _amount <= mint_capacity.sub(mintBalance[_account]);
    }

     
    function canBurnUtility(address _account, uint256 _amount) public view returns (bool){                
        require(msg.sender == address(utilityToken));
        require(_account != address(0));

        return _amount <= mintBalance[_account];
    }

     
    function canBurnSecurity(address _account, uint256 _amount) public view returns (bool){                
        require(msg.sender == address(securityToken));
        require(_account != address(0));

        uint256 current_balance_security = securityToken.balanceOf(_account);
        uint256 mint_capacity = current_balance_security.mul(mint_capacity_multiplier);

        assert(mint_capacity >= mintBalance[_account]);

        uint256 unstaked_capacity = mint_capacity.sub(mintBalance[_account]);
        uint256 unstaked_tokens = unstaked_capacity.div(mint_capacity_multiplier);
        
        assert(current_balance_security >= unstaked_tokens);

        return unstaked_tokens >= _amount;
    }
}

library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
     
     
     
    if (a == 0) {
      return 0;
    }

    c = a * b;
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

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
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

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

   
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
     
     

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


   
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract UtilityToken is StandardToken, Ownable, BurnableToken {
    using SafeMath for uint256;

    event Mint(address indexed to, uint256 amount);

    SupplyManager supplyManager;

    constructor(SupplyManager _supplyManager) public {
        owner = msg.sender;
        supplyManager = _supplyManager;
    }

    function mint(uint256 _amount) public {
        require(supplyManager.canMintUtility(msg.sender, _amount));

        totalSupply_ = totalSupply_.add(_amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);
        
        emit Mint(msg.sender, _amount);
        emit Transfer(address(0), msg.sender, _amount);

        supplyManager.finalizeMintUtility(msg.sender, _amount);
    }


    function burn(uint256 _value) public {
        require(supplyManager.canBurnUtility(msg.sender, _value));
        
        BurnableToken.burn(_value);
        supplyManager.finalizeBurnUtility(msg.sender, _value);
    }

}

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

   
  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

contract SecurityToken is StandardToken, MintableToken, BurnableToken {
    using SafeMath for uint256;

    SupplyManager supplyManager;

    constructor(SupplyManager _supplyManager) public {
        owner = msg.sender;
        supplyManager = _supplyManager;
    }
    
    function burn(uint256 _value) public {
        require(supplyManager.canBurnSecurity(msg.sender, _value));
        
        BurnableToken.burn(_value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(supplyManager.canBurnSecurity(_from, _value));

        StandardToken.transferFrom(_from, _to, _value);
    }


    function transfer(address _to, uint256 _value) public returns (bool) {
        require(supplyManager.canBurnSecurity(msg.sender, _value));

        BasicToken.transfer(_to, _value);
    }

}