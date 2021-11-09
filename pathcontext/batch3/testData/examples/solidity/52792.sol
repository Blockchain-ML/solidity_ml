pragma solidity ^0.5.1;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;

   
  constructor() public {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) onlyOwner public {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract LockRequestable {
     
    uint256 public lockRequestCount;
    bool public isLocked = false;

    constructor() public {
        lockRequestCount = 0;
    }
    
     
    function generateLockId() internal returns (bytes32 lockId) {
        return keccak256(abi.encodePacked(blockhash(block.number - 1), address(this), ++lockRequestCount));
    }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) view public returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed _from, address indexed _to, uint _value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) view public returns (uint256 balance) {
    return balances[_owner];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) view public returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) allowed;

   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
    uint256 _allowance = allowed[_from][msg.sender];
    require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool){
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) view public returns (uint256 remaining){
    return allowed[_owner][_spender];
  }
}

contract ERC20Impl {
    struct PendingPrint {
        address receiver;
        uint256 value;
    }
    mapping(address => bool) blackListMapping;
    mapping (bytes32 => PendingPrint) public pendingPrintMap;
    
    event UpdateBlackListMapping(address indexed _trader, bool _value);
    event IsLocked(bool _isLock);
    event Burn(address indexed _burner, uint _value);
    event PrintingLocked(bytes32 _lockId, address _receiver, uint256 _value);
    event PrintingConfirmed(bytes32 _lockId, address _receiver, uint256 _value);    
}

contract MORCoin is StandardToken, Ownable, LockRequestable, ERC20Impl {
    string  public  constant name = "MOR Coin";
    string  public  constant symbol = "mcoin";
    uint    public  constant decimals = 18;

     
     
     

    modifier onlyWhenTransferEnabled() {
         
         
         
        require(isLocked == false);
        _;
    }

    modifier validDestination(address to) {
        require(to != address(0x0));
        require(to != address(this) );
        _;
    }
    
    modifier notInBlackList(address to) {
        require(blackListMapping[msg.sender] == false);
        require(blackListMapping[to] == false);
        _;
    }

    constructor(uint tokenTotalAmount, address admin) public {
        balances[msg.sender] = tokenTotalAmount;
        totalSupply = tokenTotalAmount;
        emit Transfer(address(0x0), msg.sender, tokenTotalAmount);
        transferOwnership(admin);
    }

    function transfer(address _to, uint _value)
        onlyWhenTransferEnabled()
        notInBlackList(_to)
        validDestination(_to)
        public
        returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value)
        onlyWhenTransferEnabled()
        notInBlackList(_to)
        validDestination(_to)
        public
        returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
    
    function approve(address _spender, uint256 _value)
        notInBlackList(_spender)
        public
        returns (bool) {
        return super.approve(_spender, _value);
    }

    function burn(uint _value) public
        onlyWhenTransferEnabled()
        notInBlackList(msg.sender)
        returns (bool){
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0x0), _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public
        onlyWhenTransferEnabled()
        notInBlackList(msg.sender)
        returns (bool) {
        assert( transferFrom( _from, msg.sender, _value ) );
        return burn(_value);
    }
    
    function updateBlackListTrader(address _trader, bool _value) onlyOwner public returns (bool isBlackList) {
        blackListMapping[_trader] = _value;
        emit UpdateBlackListMapping(_trader, _value);
        return _value;
    }
    
    function checkBlackListAddress(address _trader) view public returns (bool isBlackList) {
        return blackListMapping[_trader];
    }
    
    function updateLock(bool _value) onlyOwner public returns (bool) {
        isLocked = _value;
        emit IsLocked(_value);
        return _value;
    }
    
     
    function requestPrint(address _receiver, uint256 _value) public returns (bytes32 lockId) {
        require(_receiver != address(0));

        lockId = generateLockId();

        pendingPrintMap[lockId] = PendingPrint({
            receiver: _receiver,
            value: _value
        });

        emit PrintingLocked(lockId, _receiver, _value);
    }

     
    function confirmPrint(bytes32 _lockId) public onlyOwner {
        PendingPrint memory print = pendingPrintMap[_lockId];

        address receiver = print.receiver;
        require (receiver != address(0));
        uint256 value = print.value;

        delete pendingPrintMap[_lockId];

        uint256 newSupply = totalSupply + value;
        if (newSupply >= totalSupply) {
          totalSupply = newSupply;
          balances[receiver] = balances[receiver].add(value);

          emit PrintingConfirmed(_lockId, receiver, value);
          emit Transfer(address(0), receiver, value);
        }
    }
}