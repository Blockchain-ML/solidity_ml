pragma solidity 0.4.24;

 

 
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() public {
        owner = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

 

 
contract Lockable is Ownable {
    event Lock();
    event Unlock();

    bool public locked = false;

     
    modifier whenNotLocked() {
        require(!locked);
        _;
    }

     
    modifier whenLocked() {
        require(locked);
        _;
    }

     
    modifier preLockUnlock() {
      _;
    }

     
    function lock() public onlyOwner whenNotLocked preLockUnlock {
        locked = true;
        emit Lock();
    }

     
    function unlock() public onlyOwner whenLocked preLockUnlock {
        locked = false;
        emit Unlock();
    }
}

 

contract BaseFixedERC20Token is Lockable {
    using SafeMath for uint;

     
    uint public totalSupply;

    mapping(address => uint) public balances;

    mapping(address => mapping(address => uint)) private allowed;

     
    event Transfer(address indexed from, address indexed to, uint value);

     
    event Approval(address indexed owner, address indexed spender, uint value);

     
    function balanceOf(address owner_) public view returns (uint balance) {
        return balances[owner_];
    }

     
    function transfer(address to_, uint value_) public whenNotLocked returns (bool) {
        require(to_ != address(0) && value_ <= balances[msg.sender]);
         
        balances[msg.sender] = balances[msg.sender].sub(value_);
        balances[to_] = balances[to_].add(value_);
        emit Transfer(msg.sender, to_, value_);
        return true;
    }

     
    function transferFrom(address from_, address to_, uint value_) public whenNotLocked returns (bool) {
        require(to_ != address(0) && value_ <= balances[from_] && value_ <= allowed[from_][msg.sender]);
        balances[from_] = balances[from_].sub(value_);
        balances[to_] = balances[to_].add(value_);
        allowed[from_][msg.sender] = allowed[from_][msg.sender].sub(value_);
        emit Transfer(from_, to_, value_);
        return true;
    }

     
    function approve(address spender_, uint value_) public whenNotLocked returns (bool) {
        if (value_ != 0 && allowed[msg.sender][spender_] != 0) {
            revert();
        }
        allowed[msg.sender][spender_] = value_;
        emit Approval(msg.sender, spender_, value_);
        return true;
    }

     
    function allowance(address owner_, address spender_) public view returns (uint) {
        return allowed[owner_][spender_];
    }
}

 

 
contract BaseICOToken is BaseFixedERC20Token {

     
    uint public availableSupply;

     
    address public ico;

     
    uint public ethTokenExchangeRatio;

     
    event ICOTokensInvested(address indexed to, uint amount);

     
    event ICOChanged(address indexed icoContract);

    modifier onlyICO() {
        require(msg.sender == ico);
        _;
    }

     
    constructor(uint totalSupply_) public {
        locked = true;
        totalSupply = totalSupply_;
        availableSupply = totalSupply_;
    }

     
    function changeICO(address ico_) public onlyOwner {
        ico = ico_;
        emit ICOChanged(ico);
    }

    function isValidICOInvestment(address to_, uint amount_) internal view returns (bool) {
        return to_ != address(0) && amount_ <= availableSupply;
    }

     
    function icoInvestmentWei(address to_, uint amountWei_) public returns (uint);
}

 

 
contract BaseICOMintableToken is BaseICOToken {

    event TokensMinted(uint mintedAmount, uint totalSupply);

    constructor(uint totalSupplyWei_) public BaseICOToken(totalSupplyWei_) {
    }

     
    function mintToken(uint mintedAmount_) public onlyOwner {
        mintCheck(mintedAmount_);
        totalSupply = totalSupply.add(mintedAmount_);
        emit TokensMinted(mintedAmount_, totalSupply);
    }

    function mintCheck(uint) internal;
}

 

 
contract ESRToken is BaseICOMintableToken {
  using SafeMath for uint;

  string public constant name = "EsperantoToken";

  string public constant symbol = "ESRT";

  uint8 public constant decimals = 18;

   

  uint8 public constant RESERVED_PARTNERS_GROUP = 0x1;

  uint8 public constant RESERVED_TEAM_GROUP = 0x2;

  uint8 public constant RESERVED_BOUNTY_GROUP = 0x4;

  uint internal ONE_TOKEN = 1e18;  

   
  event ReservedTokensDistributed(address indexed to, uint8 group, uint amount);

   
  event EthTokenExchangeRatioUpdated(uint ethTokenExchangeRatio);

   
  event SellToken(address indexed to, uint amount);

   
  mapping(uint8 => uint) public reserved;

  constructor(uint ethTokenExchangeRatio_,
              uint totalSupplyTokens_,
              uint teamTokens_,
              uint bountyTokens_,
              uint partnersTokens_) public BaseICOMintableToken(totalSupplyTokens_ * ONE_TOKEN) {
    require(availableSupply == totalSupply);
    ethTokenExchangeRatio = ethTokenExchangeRatio_;
    availableSupply = availableSupply
            .sub(teamTokens_ * ONE_TOKEN)
            .sub(bountyTokens_ * ONE_TOKEN)
            .sub(partnersTokens_ * ONE_TOKEN);
    reserved[RESERVED_TEAM_GROUP] = teamTokens_ * ONE_TOKEN;
    reserved[RESERVED_BOUNTY_GROUP] = bountyTokens_ * ONE_TOKEN;
    reserved[RESERVED_PARTNERS_GROUP] = partnersTokens_ * ONE_TOKEN;
  }

  function mintCheck(uint) internal {
     
    require(block.timestamp >= 1590969600);
  }

  modifier preLockUnlock() {
     
    require(block.timestamp >= 1569888000);
    _;
  }

   
  function() external payable {
    revert();
  }

   
  function getReservedTokens(uint8 group_) public view returns (uint) {
      return reserved[group_];
  }

   
  function assignReserved(address to_, uint8 group_, uint amount_) public onlyOwner {
      require(to_ != address(0) && (group_ & 0x7) != 0);
       
      reserved[group_] = reserved[group_].sub(amount_);
      balances[to_] = balances[to_].add(amount_);
      emit ReservedTokensDistributed(to_, group_, amount_);
  }

   
  function updateTokenExchangeRatio(uint ethTokenExchangeRatio_) public onlyOwner {
    ethTokenExchangeRatio = ethTokenExchangeRatio_;
    emit EthTokenExchangeRatioUpdated(ethTokenExchangeRatio);
  }


   
  function sellToken(address to_, uint amountWei_) public onlyOwner returns (uint)  {
    uint amount = amountWei_ * ethTokenExchangeRatio;
    require(to_ != address(0) && amount <= availableSupply);
    availableSupply = availableSupply.sub(amount);
    balances[to_] = balances[to_].add(amount);
    emit SellToken(to_, amount);
    return amount;
  }

   
  function icoInvestmentWei(address to_, uint amountWei_) public onlyICO returns (uint) {
    uint amount = amountWei_ * ethTokenExchangeRatio;
    require(isValidICOInvestment(to_, amount));
    availableSupply = availableSupply.sub(amount);
    balances[to_] = balances[to_].add(amount);
    emit ICOTokensInvested(to_, amount);
    return amount;
  }
}