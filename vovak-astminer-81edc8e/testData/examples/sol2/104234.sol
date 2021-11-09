 

 

 

 
 
 
 

 
 
 
 

 
 

pragma solidity >=0.4.23;

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}


 

 

 

 
 
 

pragma solidity >0.4.20;

contract ERC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract ERC20 is ERC20Events {
    function totalSupply() public view returns (uint);
    function balanceOf(address guy) public view returns (uint);
    function allowance(address src, address guy) public view returns (uint);

    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(
        address src, address dst, uint wad
    ) public returns (bool);
}


 

 

 
 
 
 

 
 
 
 

 
 

pragma solidity >0.4.13;

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}


 

 

pragma solidity 0.5.8;


contract ERC20Extended is ERC20 {
  event Mint(address indexed guy, uint wad);
  event Burn(address indexed guy, uint wad);

  function mint(uint wad) public;
  function mint(address guy, uint wad) public;
  function burn(uint wad) public;
  function burn(address guy, uint wad) public;
}

 

 

 

 
 
 
 

 
 
 
 

 
 

pragma solidity >=0.4.23;

contract DSTokenBase is ERC20, DSMath {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    constructor(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
    }

    function totalSupply() public view returns (uint) {
        return _supply;
    }
    function balanceOf(address src) public view returns (uint) {
        return _balances[src];
    }
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "ds-token-insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "ds-token-insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}

 

 

pragma solidity 0.5.8;

contract Token is DSTokenBase(0), DSAuth, ERC20Extended {
  uint8 public decimals;
  string public symbol;
  string public name;

  bool public locked;

  modifier unlocked {
    if (locked) {
      require(isAuthorized(msg.sender, msg.sig), "colony-token-unauthorised");
    }
    _;
  }

  constructor(string memory _name, string memory _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    locked = true;
  }

  function transferFrom(address src, address dst, uint wad) public 
  unlocked
  returns (bool)
  {
    return super.transferFrom(src, dst, wad);
  }

  function mint(uint wad) public auth {
    mint(msg.sender, wad);
  }

  function burn(uint wad) public {
    burn(msg.sender, wad);
  }

  function mint(address guy, uint wad) public auth {
    _balances[guy] = add(_balances[guy], wad);
    _supply = add(_supply, wad);
    emit Mint(guy, wad);
    emit Transfer(address(0x0), guy, wad);
  }

  function burn(address guy, uint wad) public {
    if (guy != msg.sender) {
      require(_approvals[guy][msg.sender] >= wad, "ds-token-insufficient-approval");
      _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
    }

    require(_balances[guy] >= wad, "ds-token-insufficient-balance");
    _balances[guy] = sub(_balances[guy], wad);
    _supply = sub(_supply, wad);
    emit Burn(guy, wad);
  }

  function unlock() public
  auth
  {
    locked = false;
  }
}


pragma solidity 0.5.8;

 
contract Vesting is DSMath {
  Token public token;
  address public colonyMultiSig;
  address public refundRecipient;

  uint constant internal SECONDS_PER_MONTH = 2628000;

  event GrantAdded(address recipient, uint256 startTime, uint128 amount, uint16 vestingDuration, uint16 vestingCliff);
  event GrantRemoved(address recipient, uint128 amountVested, uint128 amountNotVested);
  event GrantTokensClaimed(address recipient, uint128 amountClaimed);

  struct Grant {
    uint startTime;
    uint128 amount;
    uint16 vestingDuration;
    uint16 vestingCliff;
    uint16 monthsClaimed;
    uint128 totalClaimed;
  }
  mapping (address => Grant) public tokenGrants;

  modifier onlyColonyMultiSig {
    require(msg.sender == colonyMultiSig, "colony-vesting-unauthorized");
    _;
  }

  modifier onlyRefundRecipient {
    require(msg.sender == refundRecipient, "colony-vesting-unauthorized");
    _;
  }

  modifier nonZeroAddress(address x) {
    require(x != address(0), "colony-token-zero-address");
    _;
  }

  modifier noGrantExistsForUser(address _user) {
    require(tokenGrants[_user].startTime == 0, "colony-token-user-grant-exists");
    _;
  }

  constructor(address _token, address _colonyMultiSig, address _refundRecipient) public
  nonZeroAddress(_token)
  nonZeroAddress(_colonyMultiSig)
  {
    token = Token(_token);
    colonyMultiSig = _colonyMultiSig;
    refundRecipient = _refundRecipient;
  }

   
   
   
   
   
   
   
   
   
  function addTokenGrant(address _recipient, uint256 _startTime, uint128 _amount, uint16 _vestingDuration, uint16 _vestingCliff) public 
  onlyColonyMultiSig
  noGrantExistsForUser(_recipient)
  {
    require(_vestingCliff > 0, "coony-token-zero-vesting-cliff");
    require(_vestingDuration > _vestingCliff, "colony-token-cliff-longer-than-duration");
    uint amountVestedPerMonth = _amount / _vestingDuration;
    require(amountVestedPerMonth > 0, "colony-token-zero-amount-vested-per-month");

     
    token.transferFrom(colonyMultiSig, address(this), _amount);

    Grant memory grant = Grant({
      startTime: _startTime == 0 ? now : _startTime,
      amount: _amount,
      vestingDuration: _vestingDuration,
      vestingCliff: _vestingCliff,
      monthsClaimed: 0,
      totalClaimed: 0
    });

    tokenGrants[_recipient] = grant;
    emit GrantAdded(_recipient, grant.startTime, _amount, _vestingDuration, _vestingCliff);
  }

   
   
   
   
  function removeTokenGrant(address _recipient) public 
  onlyRefundRecipient
  {
    Grant storage tokenGrant = tokenGrants[_recipient];
    uint16 monthsVested;
    uint128 amountVested;
    (monthsVested, amountVested) = calculateGrantClaim(_recipient);
    uint128 amountNotVested = uint128(sub(sub(tokenGrant.amount, tokenGrant.totalClaimed), amountVested));

    require(token.transfer(_recipient, amountVested), "colony-token-recipient-transfer-failed");
    require(token.transfer(refundRecipient, amountNotVested), "colony-token-refund-recipient-transfer-failed");

    tokenGrant.startTime = 0;
    tokenGrant.amount = 0;
    tokenGrant.vestingDuration = 0;
    tokenGrant.vestingCliff = 0;
    tokenGrant.monthsClaimed = 0;
    tokenGrant.totalClaimed = 0;

    emit GrantRemoved(_recipient, amountVested, amountNotVested);
  }

   
   
  function claimVestedTokens() public {
    uint16 monthsVested;
    uint128 amountVested;
    (monthsVested, amountVested) = calculateGrantClaim(msg.sender);
    require(amountVested > 0, "colony-token-zero-amount-vested");

    Grant storage tokenGrant = tokenGrants[msg.sender];
    tokenGrant.monthsClaimed = uint16(add(tokenGrant.monthsClaimed, monthsVested));
    tokenGrant.totalClaimed = uint128(add(tokenGrant.totalClaimed, amountVested));
    
    require(token.transfer(msg.sender, amountVested), "colony-token-sender-transfer-failed");
    emit GrantTokensClaimed(msg.sender, amountVested);
  }

   
   
   
  function calculateGrantClaim(address _recipient) public view returns (uint16, uint128) {
    Grant storage tokenGrant = tokenGrants[_recipient];

     
    if (now < tokenGrant.startTime) {
      return (0, 0);
    }

     
    uint elapsedTime = sub(now, tokenGrant.startTime);
    uint elapsedMonths = elapsedTime / SECONDS_PER_MONTH;
    
    if (elapsedMonths < tokenGrant.vestingCliff) {
      return (0, 0);
    }

     
    if (elapsedMonths >= tokenGrant.vestingDuration) {
      uint128 remainingGrant = tokenGrant.amount - tokenGrant.totalClaimed;
      return (tokenGrant.vestingDuration, remainingGrant);
    } else {
      uint16 monthsVested = uint16(sub(elapsedMonths, tokenGrant.monthsClaimed));
      uint amountVestedPerMonth = tokenGrant.amount / tokenGrant.vestingDuration;
      uint128 amountVested = uint128(mul(monthsVested, amountVestedPerMonth));
      return (monthsVested, amountVested);
    }
  }
}