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

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

   
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

   
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

 
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract bigPayToken is Ownable, PausableToken {
    using SafeMath for uint256;

    uint256 public totalPresetedTokens;
    address[] presetedAddressesList;
    mapping (address => uint256) arrayIndexes;
    mapping(address => uint256) presetTransfers;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 constant INITIAL_SUPPLY = 10000000000000;

    event Preset(address indexed spender, uint256 value);

    constructor(string _name, string _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply_ = INITIAL_SUPPLY;
        balances[owner] = totalSupply_;
    }

     
    function _addAddress(address _addr) private {
        uint id = presetedAddressesList.length;
        arrayIndexes[_addr] = id;
        presetedAddressesList.push(_addr);
    }

     
    function _removeAddress(address _addr) private {
        uint id = arrayIndexes[_addr];
        delete presetedAddressesList[id];
    }

     
    function addPresetTransfer(address _to, uint256 _value) public onlyOwner returns(bool) {
        require(_to != address(0));
        require(balances[owner].sub(totalPresetedTokens) >= _value);

        if (presetTransfers[_to] == 0) {
            _addAddress(_to);
        } else {
            totalPresetedTokens = totalPresetedTokens.sub(presetTransfers[_to]);
        }
        presetTransfers[_to] = _value;
        totalPresetedTokens = totalPresetedTokens.add(_value);
        emit Preset(_to,  presetTransfers[_to]);
        return true;
    }

     
    function removePresetTransfer(address _to) public onlyOwner returns(bool) {
        totalPresetedTokens = totalPresetedTokens.sub(presetTransfers[_to]);
        presetTransfers[_to] = 0;
        _removeAddress(_to);
        emit Preset(_to,  0);
        return true;
    }

     
    function increasePresetTransfer(address _to, uint256 _value) public onlyOwner returns(bool) {
        require(balances[owner].sub(totalPresetedTokens) >= _value);

        if (presetTransfers[_to] == 0) {
            _addAddress(_to);
        }
        presetTransfers[_to] = presetTransfers[_to].add(_value);
        totalPresetedTokens = totalPresetedTokens.add(_value);
        emit Preset(_to,  presetTransfers[_to]);
        return true;
    }

     
    function decreasePresetTransfer(address _to, uint256 _value) public onlyOwner returns(bool) {
        require(_value <= presetTransfers[_to]);
        presetTransfers[_to] = presetTransfers[_to].sub(_value);
        totalPresetedTokens = totalPresetedTokens.sub(_value);
        emit Preset(_to,  presetTransfers[_to]);
        return true;
    }

     
    function allowancePresetTransfer(address _to) public view returns(uint256) {
        return presetTransfers[_to];
    }

     
    function submitPresetTransfer(address _to) public onlyOwner returns(bool) {
        uint256 tokensCount = presetTransfers[_to];

        if (tokensCount > 0) {
            transfer(_to, tokensCount);
            presetTransfers[_to] = 0;
        }
    }

     
    function submitPresetTransferes() public onlyOwner returns(bool) {
        require(balances[owner] >= totalPresetedTokens);

        address _to;

        for (uint i = 0; i<=presetedAddressesList.length-1; i++){
            _to = presetedAddressesList[i];
            submitPresetTransfer(_to);
        }
        totalPresetedTokens = 0;
        return true;
    }
}