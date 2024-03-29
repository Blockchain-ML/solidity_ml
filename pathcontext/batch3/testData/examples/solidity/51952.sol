pragma solidity ^0.4.11;
 
contract ERC20 {
    function totalSupply() public constant returns (uint supply);
    function balanceOf( address who ) public constant returns (uint value);
    function allowance( address owner, address spender ) public constant returns (uint _allowance);

    function transfer( address to, uint value) public returns (bool ok);
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value ) public returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}
 
contract Lockable {
    uint public creationTime;
    bool public lock;
    bool public tokenTransfer;
    address public owner;
    mapping( address => bool ) public unlockaddress;
     
    mapping( address => bool ) public lockaddress;

     
    event Locked(address lockaddress,bool status);
     
    event Unlocked(address unlockedaddress, bool status);


     
    modifier isTokenTransfer {
         
        if(!tokenTransfer) {
            require(unlockaddress[msg.sender]);
        }
        _;
    }

     
     
     
    modifier checkLock {
        assert(!lockaddress[msg.sender]);
        _;
    }

    modifier isOwner
    {
        require(owner == msg.sender);
        _;
    }

    function Lockable()
    public
    {
        creationTime = now;
        tokenTransfer = false;
        owner = msg.sender;
    }

     
    function lockAddress(address target, bool status)
    external
    isOwner
    {
        require(owner != target);
        lockaddress[target] = status;
        Locked(target, status);
    }

     
    function unlockAddress(address target, bool status)
    external
    isOwner
    {
        unlockaddress[target] = status;
        Unlocked(target, status);
    }
}
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
     
    uint c = a / b;
     
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

}
 
contract YeedToken is ERC20, Lockable {

     
    string public constant name = "YGGDRASH";
    string public constant symbol = "YEED";
    uint8 public constant decimals = 18;   
    bool public emergency;

    using SafeMath for uint;

    mapping( address => uint ) _balances;
    mapping( address => mapping( address => uint ) ) _approvals;
    uint _supply;

    event TokenBurned(address burnAddress, uint amountOfTokens);
    event TokenTransfer();
    event Emergency(bool emergency);

     
    modifier isEmergency {
        require(emergency);
        _;
    }

    function YeedToken( uint initial_balance)
    public
    {
        require(initial_balance != 0);
        _balances[msg.sender] = initial_balance;
        _supply = initial_balance;
    }

    function totalSupply()
    public
    constant
    returns (uint supply) {
        return _supply;
    }

    function balanceOf( address who )
    public
    constant
    returns (uint value) {
        return _balances[who];
    }

    function allowance(address owner, address spender)
    public
    constant
    returns (uint _allowance) {
        return _approvals[owner][spender];
    }

    function transfer( address to, uint value)
    public
    isTokenTransfer
    checkLock
    returns (bool success) {

        require( _balances[msg.sender] >= value );

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        Transfer( msg.sender, to, value );
        return true;
    }

    function transferFrom( address from, address to, uint value)
    public
    isTokenTransfer
    checkLock
    returns (bool success) {
         
        require( _balances[from] >= value );
         
        require( _approvals[from][msg.sender] >= value );
         
        _approvals[from][msg.sender] = _approvals[from][msg.sender].sub(value);
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        Transfer( from, to, value );
        return true;
    }

    function approve(address spender, uint value)
    public
    checkLock
    returns (bool success) {
        _approvals[msg.sender][spender] = value;
        Approval( msg.sender, spender, value );
        return true;
    }

     
     
    function burnTokens(uint tokensAmount)
    public
    {
        require( _balances[msg.sender] >= tokensAmount );

        _balances[msg.sender] = _balances[msg.sender].sub(tokensAmount);
        _supply = _supply.sub(tokensAmount);
        TokenBurned(msg.sender, tokensAmount);

    }

     
    function enableTokenTransfer()
    external
    isOwner
    {
        tokenTransfer = true;
        TokenTransfer();
    }

     
    function disableTokenTransfer()
    external
    isOwner
    {
        tokenTransfer = false;
        TokenTransfer();
    }

     
    function emergency(bool flag)
    public
    isOwner
    {
        emergency = flag;
        Emergency(flag);
    }

     
    function emergencyTransfer(address emergencyAddress)
    public
    isOwner
    isEmergency
    returns (bool success) {
        _balances[owner] = _balances[owner].add(_balances[emergencyAddress]);

         
        Transfer( emergencyAddress, owner, _balances[emergencyAddress] );

         
        _balances[emergencyAddress] = 0;
        return true;
    }


     
    function () public payable {
        revert();
    }

}