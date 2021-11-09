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

 
contract HasNoEther is Ownable {

   
  constructor() public payable {
    require(msg.value == 0);
  }

   
  function() external {
  }

   
  function reclaimEther() external onlyOwner {
    owner.transfer(address(this).balance);
  }
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

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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

 
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

 
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

   
  function reclaimToken(ERC20Basic _token) external onlyOwner {
    uint256 balance = _token.balanceOf(this);
    _token.safeTransfer(owner, balance);
  }

}

 
contract HasNoTokens is CanReclaimToken {

  
  function tokenFallback(
    address _from,
    uint256 _value,
    bytes _data
  )
    external
    pure
  {
    _from;
    _value;
    _data;
    revert();
  }

}

 
contract HasNoContracts is Ownable {

   
  function reclaimContract(address _contractAddr) external onlyOwner {
    Ownable contractInst = Ownable(_contractAddr);
    contractInst.transferOwnership(owner);
  }
}

 
contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {
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

 
contract TokenLockup is ERC20 {
    using SafeMath for uint256;  

     
    struct LockedUp {
        uint256 amount;  
        uint256 release;  
    }

     
    mapping (address => LockedUp[]) public lockedup;

     
    event Lockup(address indexed to, uint256 amount, uint256 release);

     
    function lockedUpCount(address _who) public view returns (uint256) {
        return lockedup[_who].length;
    }

         
    function hasLockedUp(address _who) public view returns (bool) {
        return lockedup[_who].length > 0;
    }    

            
    function balanceLockedUp(address _who) public view returns (uint256) {
        uint256 _balanceLokedUp = 0;
        for (uint256 i = 0; i < lockedup[_who].length; i++) {
            if (lockedup[_who][i].release > block.timestamp)  
                _balanceLokedUp = _balanceLokedUp.add(lockedup[_who][i].amount);
        }
        return _balanceLokedUp;
    }    

          
    function _lockup(address _who, uint256 _amount, uint256 _release) internal {
        if (_release > 0) {
            require(_who != address(0), "Lockup target address can&#39;t be zero.");
            require(_amount > 0, "Lockup amount should be > 0.");   
            require(_release > block.timestamp, "Lockup release time should be > now.");  
            lockedup[_who].push(LockedUp(_amount, _release));
            emit Lockup(_who, _amount, _release);
        }            
    }      
}

 
contract DiscoperiToken is TokenLockup, MintableToken, NoOwner {
    using SafeMath for uint256;

     
    string public constant name = "Discoperi Token";  
    string public constant symbol = "DISC";  
    uint8 public constant decimals = 18;  

     
    uint256 public constant TOTAL_SUPPLY = 200000000000 * (10 ** uint256(decimals));  

     
    uint256 public constant SALES_SUPPLY = 50000000000 * (10 ** uint256(decimals));  
    uint256 public constant MARKET_DEV_SUPPLY = 50000000000 * (10 ** uint256(decimals));  
    uint256 public constant TEAM_SUPPLY = 30000000000 * (10 ** uint256(decimals));  
    uint256 public constant RESERVE_SUPPLY = 30000000000 * (10 ** uint256(decimals));  
    uint256 public constant INVESTORS_ADVISORS_SUPPLY = 20000000000 * (10 ** uint256(decimals));  
    uint256 public constant PR_ADVERSTISING_SUPPLY = 20000000000 * (10 ** uint256(decimals));  

     
    uint256 public constant SEED_FUNDING_HARD_CAP = 1550000;  
    uint256 public constant PRIVATE_PRESALE_HARD_CAP = 40000000;  
    uint256 public constant PUBLIC_PRESALE_HARD_CAP = 40000000;  
    uint256 public constant ICO_HARD_CAP = 50000000;  

     
    address public privatePresale;

     
    address public publicPresale;

     
    address public ico;

     
    uint256 public saleDitributed;

     
    event Allocate(address indexed to, uint256 amount);

     
    modifier onlySaleContract() {
        require(_isSaleContract(), "Unauthorized attempt");
        _;
    }

     
    modifier spotTransfer(address _from, uint256 _value) {
        require(_value <= balanceSpot(_from), "Attempt to transfer more than balance spot");
        _;
    }

       
    function setSaleContracts(address _privatePresale, address _publicPresale, address _ico) external onlyOwner {
        require(_privatePresale != address(0), "Private pre-sale address should not be equal to zero address");
        require(_publicPresale != address(0), "Public Pre-sale address should not be equal to zero address");
        require(_ico != address(0), "ICO address should not be equal to zero address");

        require(privatePresale == address(0), "Attempt to override already existing private pre-sale address");
        require(publicPresale == address(0), "Attempt to override already existing public pre-sale address");
        require(ico == address(0), "Attempt to override already existing ICO address");

        privatePresale = _privatePresale;
        publicPresale = _publicPresale;
        ico = _ico;
    }

      
    function allocate(address _to, uint256 _amount, uint256 _releaseTime) external onlySaleContract {
        require(_to != address(0), "Allocate To address can&#39;t be zero");
        require(_amount > 0, "Allocate amount should be > 0.");
       
        totalSupply_ = totalSupply_.add(_amount);
        saleDitributed = saleDitributed.add(_amount);  
        balances[_to] = balances[_to].add(_amount);

        require(saleDitributed <= SALES_SUPPLY, "Can&#39;t allocate more than SALES SUPPLY.");
        require(totalSupply_ <= TOTAL_SUPPLY, "Can&#39;t allocate more than TOTAL SUPPLY.");

        emit Transfer(address(0), _to, _amount);

        mint(_to, _amount);  

        if (_releaseTime != uint256(0)) {
            _lockup(_to, _amount, _releaseTime);
        }
    }  

        
    function balanceSpot(address _who) public view returns (uint256) {
        uint256 _balanceSpot = balanceOf(_who);
        _balanceSpot = _balanceSpot.sub(balanceLockedUp(_who));      
        return _balanceSpot;
    }     
       
     
    function transfer(address _to, uint256 _value) public spotTransfer(msg.sender, _value) returns (bool) {
        return super.transfer(_to, _value);
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public spotTransfer(_from, _value) returns (bool) {    
        return super.transferFrom(_from, _to, _value);
    }

     
    function _isSaleContract() internal view returns (bool) {
        if (msg.sender == ico || msg.sender == publicPresale || msg.sender == privatePresale)
            return true;
        return false;
    }
}

 
contract DiscoperiPrivatePresale is HasNoEther {
    using SafeMath for uint256;

     
    DiscoperiToken public token;

     
    uint256 public privatePresaleDistributed;

     
    address[] public privatePresaleFunders;

     
    struct PrivatePresaleBalance {
        uint256 amount;  
        uint256 release;  
    }

     
    mapping (address => PrivatePresaleBalance) public privatePresaleBalances;

     
    bool public privatePresaleTokensAllocated;

     
    event PrivatePresaleDistribute(address indexed to, uint256 amount);
    

     
    constructor(DiscoperiToken _token) public {
        require(_token != address(0), "Token address can&#39;t be zero.");
        token = DiscoperiToken(_token); 
    }

     
    function getPrivatePresaleFundersCount() public view returns(uint256) {
        return privatePresaleFunders.length;
    }

     
    function allocatePrivatePresaleTokens() external {
        require(!privatePresaleTokensAllocated, "Attemp to allocate private pre-sale tokens twice");

        for (uint256 i = 0; i < getPrivatePresaleFundersCount(); i++) {
            address _funder = privatePresaleFunders[i];
            uint256 _tokens = privatePresaleBalances[_funder].amount;

            token.allocate(_funder, _tokens, 0);
            privatePresaleDistributed = privatePresaleDistributed.add(_tokens);

            emit PrivatePresaleDistribute(_funder, _tokens);
        }
        
        privatePresaleTokensAllocated = true;
    } 

}