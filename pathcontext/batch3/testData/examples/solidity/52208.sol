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

 

 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

   
  modifier whenPaused() {
    require(paused);
    _;
  }

   
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

   
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

 

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

 
library SafeMath {

   
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
     
     
     
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

   
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
     
     
     
    return _a / _b;
  }

   
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

   
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

 

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

 

 
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
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
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

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
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
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
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

   
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
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

 

contract AccountLockableToken is Ownable {
    mapping(address => bool) public lockStates;

    event LockAccount(address indexed lockAccount);
    event UnlockAccount(address indexed unlockAccount);

     
    modifier whenNotLocked() {
        require(!lockStates[msg.sender]);
        _;
    }

     
    function lockAccount(address _target) public onlyOwner returns (bool) {
        require(_target != owner);
        require(!lockStates[_target]);

        lockStates[_target] = true;

        emit LockAccount(_target);

        return true;
    }

     
    function unlockAccount(address _target) public onlyOwner returns (bool) {
        require(_target != owner);
        require(lockStates[_target]);

        lockStates[_target] = false;

        emit UnlockAccount(_target);

        return true;
    }
}

 

contract WithdrawableToken is BasicToken, Ownable {
    using SafeMath for uint256;

    event Withdraw(address _from, address _to, uint256 _value);

     
    function withdraw(address _from, uint256 _value) public
        onlyOwner
        returns (bool)
    {
        require(_value <= balances[_from]);

        balances[_from] = balances[_from].sub(_value);
        balances[owner] = balances[owner].add(_value);

        emit Withdraw(_from, owner, _value);

        return true;
    }

     
    function withdrawFrom(address _from, address _to, uint256 _value) public
        onlyOwner
        returns (bool)
    {
        require(_value <= balances[_from]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Withdraw(_from, _to, _value);

        return true;
    }
}

 

 
library Math {
  function max64(uint64 _a, uint64 _b) internal pure returns (uint64) {
    return _a >= _b ? _a : _b;
  }

  function min64(uint64 _a, uint64 _b) internal pure returns (uint64) {
    return _a < _b ? _a : _b;
  }

  function max256(uint256 _a, uint256 _b) internal pure returns (uint256) {
    return _a >= _b ? _a : _b;
  }

  function min256(uint256 _a, uint256 _b) internal pure returns (uint256) {
    return _a < _b ? _a : _b;
  }
}

 

contract MilestoneLockToken is StandardToken, Ownable {
    using Math for uint256;
    using SafeMath for uint256;

    struct Policy {
        uint256 kickOff;
        uint256[] periods;
        uint8[] percentages;
    }

    struct LockedUser {
        uint8[] policies;
        uint256[] standardBalances;
    }

    uint8 constant MAX_POLICY = 100;
    uint256 constant MAX_PERCENTAGE = 100;

    mapping(uint8 => Policy) internal policies;
    mapping(address => LockedUser) internal lockedUsers;

    event SetPolicyKickOff(uint8 policy, uint256 kickOff);
    event PolicyAdded(uint8 policy);
    event PolicyRemoved(uint8 policy);
    event PolicyAttributeAdded(uint8 policy, uint256 period, uint8 percentage);
    event PolicyAttributeRemoved(uint8 policy, uint256 period);
    event PolicyAttributeModified(uint8 policy, uint256 period, uint8 percentage);

     
    function transfer(address _to, uint256 _value) public
        returns (bool)
    {
        require(getAvailableBalance(msg.sender) >= _value);

        return super.transfer(_to, _value);
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public
        returns (bool)
    {
        require(getAvailableBalance(_from) >= _value);

        return super.transferFrom(_from, _to, _value);
    }

     
    function distributeWithPolicy(address _to, uint256 _value, uint8 _policy) public
        onlyOwner
        returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[owner]);
        require(_policy > 0 && _policy < MAX_POLICY);

        balances[owner] = balances[owner].sub(_value);
        balances[_to] = balances[_to].add(_value);

        uint8 policyIndex = _getAppliedPolicyIndex(_to, _policy);
        if (policyIndex < MAX_POLICY) {
            lockedUsers[_to].standardBalances[policyIndex] = 
                lockedUsers[_to].standardBalances[policyIndex].add(_value);
        } else {
            lockedUsers[_to].policies.push(_policy);
            lockedUsers[_to].standardBalances.push(_value);
        }

        emit Transfer(owner, _to, _value);

        return true;
    }

     
    function addPolicy(uint8 _policy, uint256[] _periods, uint8[] _percentages) public
        onlyOwner
        returns (bool)
    {
        require(_policy > 0 && _policy < MAX_POLICY);
        require(_periods.length > 0);
        require(_percentages.length > 0);
        require(_periods.length == _percentages.length);
        require(policies[_policy].periods.length == 0);

        policies[_policy].periods = _periods;
        policies[_policy].percentages = _percentages;

        emit PolicyAdded(_policy);

        return true;
    }

     
    function removePolicy(uint8 _policy) public
        onlyOwner
        returns (bool)
    {
        require(_policy > 0 && _policy < MAX_POLICY);

        delete policies[_policy];

        emit PolicyRemoved(_policy);

        return true;
    }

     
    function getPolicy(uint8 _policy) public
        view
        returns (uint256, uint256[], uint8[])
    {
        require(_policy > 0 && _policy < MAX_POLICY);

        return (
            policies[_policy].kickOff,
            policies[_policy].periods,
            policies[_policy].percentages
        );
    }

     
    function addPolicyAttribute(uint8 _policy, uint256 _period, uint8 _percentage) public
        onlyOwner
        returns (bool)
    {
        require(_policy > 0 && _policy < MAX_POLICY);

        Policy storage policy = policies[_policy];

        for (uint256 i = 0; i < policy.periods.length; i++) {
            if (policy.periods[i] == _period) {
                revert();
                return false;
            }
        }

        policy.periods.push(_period);
        policy.percentages.push(_percentage);

        emit PolicyAttributeAdded(_policy, _period, _percentage);

        return true;
    }

     
    function removePolicyAttribute(uint8 _policy, uint256 _period) public
        onlyOwner
        returns (bool)
    {
        require(_policy > 0 && _policy < MAX_POLICY);

        Policy storage policy = policies[_policy];
        
        for (uint256 i = 0; i < policy.periods.length; i++) {
            if (policy.periods[i] == _period) {
                _removeElementAt256(policy.periods, i);
                _removeElementAt8(policy.percentages, i);

                emit PolicyAttributeRemoved(_policy, _period);

                return true;
            }
        }

        revert();

        return false;
    }

     
    function modifyPolicyAttribute(uint8 _policy, uint256 _period, uint8 _percentage) public
        onlyOwner
        returns (bool)
    {
        require(_policy > 0 && _policy < MAX_POLICY);

        Policy storage policy = policies[_policy];
        for (uint256 i = 0; i < policy.periods.length; i++) {
            if (policy.periods[i] == _period) {
                policy.periods[i] = _percentage;

                emit PolicyAttributeModified(_policy, _period, _percentage);

                return true;
            }
        }

        revert();

        return false;
    }

     
    function modifyPolicyTo(address _to, uint8 _prevPolicy, uint8 _newPolicy) public
        onlyOwner
        returns (bool)
    {
        require(_to != address(0));
        require(_prevPolicy > 0 && _prevPolicy < MAX_POLICY);
        require(_newPolicy > 0 && _newPolicy < MAX_POLICY);
        require(_prevPolicy != _newPolicy);
        require(policies[_prevPolicy].periods.length > 0);
        require(policies[_newPolicy].periods.length > 0);

        uint256 prevPolicyIndex = _getAppliedPolicyIndex(_to, _prevPolicy);
        require(prevPolicyIndex < MAX_POLICY);

        LockedUser storage lockedUser = lockedUsers[_to];

        uint256 prevLockedBalance = lockedUser.standardBalances[prevPolicyIndex];

        uint256 newPolicyIndex = _getAppliedPolicyIndex(_to, _newPolicy);
        if (newPolicyIndex < MAX_POLICY) {
            lockedUser.standardBalances[newPolicyIndex].add(prevLockedBalance);
        } else {
            lockedUser.policies.push(_newPolicy);
            lockedUser.standardBalances.push(prevLockedBalance);
        }

        return true;
    }

     
    function removePolicyFrom(address _from, uint8 _policy) public
        onlyOwner
        returns (bool)
    {
        require(_from != address(0));
        require(_policy > 0 && _policy < MAX_POLICY);

        uint256 policyIndex = _getAppliedPolicyIndex(_from, _policy);
        require(policyIndex < MAX_POLICY);

        _removeElementAt8(lockedUsers[_from].policies, policyIndex);
        _removeElementAt256(lockedUsers[_from].standardBalances, policyIndex);

        return true;
    }

     
    function getUserPolicy(address _account) public view
        returns (uint8[], uint256[])
    {
        return (
            lockedUsers[_account].policies,
            lockedUsers[_account].standardBalances
        );
    }

     
    function getAvailableBalance(address _account) public view
        returns (uint256)
    {
        return balances[_account].sub(_calculateTotalLockedBalance(_account));
    }

     
    function _getAppliedPolicyIndex(address _to, uint8 _policy) internal view
        returns (uint8)
    {
        require(_policy > 0 && _policy < MAX_POLICY);

        LockedUser storage lockedUser = lockedUsers[_to];
        for (uint8 i = 0; i < lockedUser.policies.length; i++) {
            if (lockedUser.policies[i] == _policy) {
                return i;
            }
        }

        return MAX_POLICY;
    }

     
    function _calculateLockedPercentage(uint8 _policy) internal view
        returns (uint256)
    {
        require(_policy > 0 && _policy < MAX_POLICY);

        if (policies[_policy].periods.length == 0) {
            return 0;
        }
        
        if (policies[_policy].kickOff < now) {
            return MAX_PERCENTAGE;
        }

        uint256 unlockedPercentage = 0;
        for (uint256 i = 0; i < policies[_policy].periods.length; ++i) {
            if (policies[_policy].kickOff + policies[_policy].periods[i] <= now) {
                unlockedPercentage.add(uint256(policies[_policy].percentages[i]));
            }
        }

        if (unlockedPercentage > MAX_PERCENTAGE) {
            return 0;
        }

        return MAX_PERCENTAGE - unlockedPercentage;
    }

     
    function _calculateLockedBalance(address _account, uint8 _policy) internal view
        returns (uint256)
    {
        require(_policy > 0 && _policy < MAX_POLICY);

        uint256 policyIndex = _getAppliedPolicyIndex(_account, _policy);
        if (policyIndex >= MAX_POLICY) {
            return 0;
        }

        LockedUser storage lockedUser = lockedUsers[_account];

        uint256 lockedPercentage =
            _calculateLockedPercentage(lockedUser.policies[policyIndex]);
        return lockedUser.standardBalances[policyIndex].sub(MAX_PERCENTAGE).mul(lockedPercentage);
    }

     
    function _calculateTotalLockedBalance(address _account) internal view
        returns (uint256)
    {
        LockedUser storage lockedUser = lockedUsers[_account];

        uint256 totalLockedBalance = 0;
        for (uint256 i = 0; i < lockedUser.policies.length; i++) {
            totalLockedBalance = totalLockedBalance.add(
                _calculateLockedBalance(_account, lockedUser.policies[i])
            );
        }

        return totalLockedBalance;
    }

    function _removeElementAt256(uint256[] storage array, uint256 index) internal
        returns (bool)
    {
        if (array.length <= index) {
            return false;
        }

        for (uint256 i = index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }

        delete array[array.length - 1];
        array.length--;

        return true;
    }

    function _removeElementAt8(uint8[] storage array, uint256 index) internal
        returns (bool)
    {
        if (array.length <= index) {
            return false;
        }

        for (uint256 i = index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }

        delete array[array.length - 1];
        array.length--;

        return true;
    }
}

 

 
contract dHena is
    MilestoneLockToken,
    MintableToken,
    BurnableToken,
    Pausable,
    AccountLockableToken,
    WithdrawableToken
{
    uint256 constant MAX_SUFFLY = 1500000000;

    string public name;
    string public symbol;
    uint8 public decimals;

    constructor() public {
        name = "dHena";
        symbol = "DHENA";
        decimals = 18;
        totalSupply_ = MAX_SUFFLY * 10 ** uint(decimals);

        balances[owner] = totalSupply_;

        emit Transfer(address(0), owner, totalSupply_);
    }

     
    function transfer(address _to, uint256 _value) public
        whenNotPaused
        whenNotLocked
        returns (bool)
    {
        return super.transfer(_to, _value);
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public
        whenNotPaused
        whenNotLocked
        returns (bool)
    {
        require(!lockStates[_from]);

        return super.transferFrom(_from, _to, _value);
    }

     
    function increaseApproval(address _spender, uint256 _addedValue) public
        whenNotPaused
        whenNotLocked
        returns (bool)
    {
        return super.increaseApproval(_spender, _addedValue);
    }

     
    function decreaseApproval(address _spender, uint256 _subtractedValue) public
        whenNotPaused
        whenNotLocked
        returns (bool)
    {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

     
    function distribute(address _to, uint256 _value) public
        onlyOwner
        returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[owner]);

        balances[owner] = balances[owner].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(owner, _to, _value);

        return true;
    }
}