 

pragma solidity ^0.4.26;


 
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

 

pragma solidity ^0.4.26;


 
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

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 

pragma solidity ^0.4.26;




 
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
    uint _addedValue
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
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
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
  event Mintai(address indexed owner, address indexed msgSender, uint256 msgSenderBalance, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;

  mapping(address=>uint256) mintPermissions;

  uint256 public maxMintLimit;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(checkMintPermission(msg.sender));
    _;
  }

  function checkMintPermission(address _minter) private view returns (bool) {
    if (_minter == owner) {
      return true;
    }

    return mintPermissions[_minter] > 0;

  }

  function setMinter(address _minter, uint256 _amount) public onlyOwner {
    require(_minter != owner);
    mintPermissions[_minter] = _amount;
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
    return mintInternal(_to, _amount);
  }

   
  function mintInternal(address _to, uint256 _amount) internal returns (bool) {
    if (msg.sender != owner) {
      mintPermissions[msg.sender] = mintPermissions[msg.sender].sub(_amount);
    }

    totalSupply_ = totalSupply_.add(_amount);
    require(totalSupply_ <= maxMintLimit);

    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  function mintAllowed(address _minter) public view returns (uint256) {
    return mintPermissions[_minter];
  }

   
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}


contract GatherToken is MintableToken {

  string public constant name = "Gather";
  string public constant symbol = "GTH";
  uint32 public constant decimals = 18;

  bool public transferPaused = true;

  constructor() public {
    maxMintLimit = 400000000 * (10 ** uint(decimals));
  }

  function unpauseTransfer() public onlyOwner {
    transferPaused = false;
  }

  function pauseTransfer() public onlyOwner {
    transferPaused = true;
  }

   
  modifier tranferable() {
    require(!transferPaused, "Gath3r: Token transfer is pauses");
    _;
  }

  function transferFrom(address _from, address _to, uint256 _value) public tranferable returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function transfer(address _to, uint256 _value) public tranferable returns (bool) {
    return super.transfer(_to, _value);
  }
}

 

pragma solidity ^0.4.26;





contract VestingPool is Ownable {
  using SafeMath for uint256;

   
  GatherToken public token;

   
  bytes32 public privateCategory = keccak256("privateCategory");
  bytes32 public platformCategory = keccak256("platformCategory");
  bytes32 public seedCategory = keccak256("seedCategory");
  bytes32 public foundationCategory = keccak256("foundationCategory");
  bytes32 public marketingCategory = keccak256("marketingCategory");
  bytes32 public teamCategory = keccak256("teamCategory");
  bytes32 public advisorCategory = keccak256("advisorCategory");

  bool public isVestingStarted;
  uint256 public vestingStartDate;

  struct vestingInfo {
    uint256 limit;
    uint256 released;
    uint256[] scheme;
    mapping(address => bool) adminEmergencyFirstApprove;
    mapping(address => bool) adminEmergencySecondApprove;
    bool multiownedEmergencyFirstApprove;
    bool multiownedEmergencySecondApprove;
    uint256 initEmergencyDate;
  }

  mapping(bytes32 => vestingInfo) public vesting;

  uint32 private constant SECONDS_PER_DAY = 24 * 60 * 60;
  uint32 private constant SECONDS_PER_MONTH = SECONDS_PER_DAY * 30;

  address public admin1address;
  address public admin2address;

  event Withdraw(address _to, uint256 _amount);


  constructor(address _token) public {
    require(_token != address(0), "Gath3r: Token address must be set for vesting");

    token = GatherToken(_token);

     
    _initVestingData();
  }

  modifier isNotStarted() {
    require(!isVestingStarted, "Gath3r: Vesting is already started");
    _;
  }

  modifier isStarted() {
    require(isVestingStarted, "Gath3r: Vesting is not started yet");
    _;
  }

  modifier approvedByAdmins(bytes32 _category) {
    require(vesting[_category].adminEmergencyFirstApprove[admin1address], "Gath3r: Emergency transfer must be approved by Admin 1");
    require(vesting[_category].adminEmergencyFirstApprove[admin2address], "Gath3r: Emergency transfer must be approved by Admin 2");
    require(vesting[_category].adminEmergencySecondApprove[admin1address], "Gath3r: Emergency transfer must be approved twice by Admin 1");
    require(vesting[_category].adminEmergencySecondApprove[admin2address], "Gath3r: Emergency transfer must be approved twice by Admin 2");
    _;
  }

  modifier approvedByMultiowned(bytes32 _category) {
    require(vesting[_category].multiownedEmergencyFirstApprove, "Gath3r: Emergency transfer must be approved by Multiowned");
    require(vesting[_category].multiownedEmergencySecondApprove, "Gath3r: Emergency transfer must be approved twice by Multiowned");
    _;
  }

  function startVesting() public onlyOwner isNotStarted {
    vestingStartDate = now;
    isVestingStarted = true;
  }

   
  function addAdmin1address(address _admin) public onlyOwner {
    require(_admin != address(0), "Gath3r: Admin 1 address must be exist for emergency transfer");
    _resetAllAdminApprovals(_admin);
    admin1address = _admin;
  }

  function addAdmin2address(address _admin) public onlyOwner {
    require(_admin != address(0), "Gath3r: Admin 2 address must be exist for emergency transfer");
    _resetAllAdminApprovals(_admin);
    admin2address = _admin;
  }

  function multipleWithdraw(address[] _addresses, uint256[] _amounts, bytes32 _category) public onlyOwner isStarted {
    require(_addresses.length == _amounts.length, "Gath3r: Amount of adddresses must be equal withdrawal amounts length");

    uint256 withdrawalAmount;
    uint256 availableAmount = getAvailableAmountFor(_category);
    for(uint i = 0; i < _amounts.length; i++) {
      withdrawalAmount = withdrawalAmount.add(_amounts[i]);
    }
    require(withdrawalAmount <= availableAmount, "Gath3r: Withdraw amount more than available limit");

    for(i = 0; i < _addresses.length; i++) {
      _withdraw(_addresses[i], _amounts[i], _category);
    }
  }

  function getAvailableAmountFor(bytes32 _category) public view returns (uint256) {
    uint256 currentMonth = now.sub(vestingStartDate).div(SECONDS_PER_MONTH);
    uint256 totalUnlockedAmount;

    for(uint8 i = 0; i <= currentMonth; i++ ) {
      totalUnlockedAmount = totalUnlockedAmount.add(vesting[_category].scheme[i]);
    }

    return totalUnlockedAmount.sub(vesting[_category].released);
  }

  function firstAdminEmergencyApproveFor(bytes32 _category, address _admin) public onlyOwner {
    require(_admin == admin1address || _admin == admin2address, "Gath3r: Approve for emergency address must be from admin address");
    require(!vesting[_category].adminEmergencyFirstApprove[_admin]);

    if (vesting[_category].initEmergencyDate == 0) {
      vesting[_category].initEmergencyDate = now;
    }
    vesting[_category].adminEmergencyFirstApprove[_admin] = true;
  }

  function secondAdminEmergencyApproveFor(bytes32 _category, address _admin) public onlyOwner {
    require(_admin == admin1address || _admin == admin2address, "Gath3r: Approve for emergency address must be from admin address");
    require(vesting[_category].adminEmergencyFirstApprove[_admin]);
    require(now.sub(vesting[_category].initEmergencyDate) > SECONDS_PER_DAY);

    vesting[_category].adminEmergencySecondApprove[_admin] = true;
  }

  function firstMultiownedEmergencyApproveFor(bytes32 _category) public onlyOwner {
    require(!vesting[_category].multiownedEmergencyFirstApprove);

    if (vesting[_category].initEmergencyDate == 0) {
      vesting[_category].initEmergencyDate = now;
    }
    vesting[_category].multiownedEmergencyFirstApprove = true;
  }

  function secondMultiownedEmergencyApproveFor(bytes32 _category) public onlyOwner {
    require(vesting[_category].multiownedEmergencyFirstApprove, "Gath3r: Second multiowned approval must be after fisrt multiowned approval");
    require(now.sub(vesting[_category].initEmergencyDate) > SECONDS_PER_DAY);

    vesting[_category].multiownedEmergencySecondApprove = true;
  }

  function emergencyTransferFor(bytes32 _category, address _to) public onlyOwner approvedByAdmins(_category) approvedByMultiowned(_category) {
    require(_to != address(0), "Gath3r: Address must be transmit for emergency transfer");
    uint256 limit = vesting[_category].limit;
    uint256 released = vesting[_category].released;
    uint256 availableAmount = limit.sub(released);
    _withdraw(_to, availableAmount, _category);
  }

  function _withdraw(address _beneficiary, uint256 _amount, bytes32 _category) internal {
    token.transfer(_beneficiary, _amount);
    vesting[_category].released = vesting[_category].released.add(_amount);

    emit Withdraw(_beneficiary, _amount);
  }

  function _resetAllAdminApprovals(address _admin) internal {
    vesting[seedCategory].adminEmergencyFirstApprove[_admin] = false;
    vesting[seedCategory].adminEmergencySecondApprove[_admin] = false;
    vesting[foundationCategory].adminEmergencyFirstApprove[_admin] = false;
    vesting[foundationCategory].adminEmergencySecondApprove[_admin] = false;
    vesting[marketingCategory].adminEmergencyFirstApprove[_admin] = false;
    vesting[marketingCategory].adminEmergencySecondApprove[_admin] = false;
    vesting[teamCategory].adminEmergencyFirstApprove[_admin] = false;
    vesting[teamCategory].adminEmergencySecondApprove[_admin] = false;
    vesting[advisorCategory].adminEmergencyFirstApprove[_admin] = false;
    vesting[advisorCategory].adminEmergencySecondApprove[_admin] = false;
  }

  function _amountWithPrecision(uint256 _amount) internal view returns (uint256) {
    return _amount.mul(10 ** uint(token.decimals()));
  }

   
  function _initVestingData() internal {
     
    vesting[privateCategory].limit = _expandToDecimals(20000000);
    vesting[privateCategory].scheme = [
       
      10500000,
       
      10500000, 9000000
    ];

     
    vesting[platformCategory].limit = _expandToDecimals(30000000);
    vesting[platformCategory].scheme = [
       
      30000000
    ];

     
    vesting[seedCategory].limit = _expandToDecimals(22522500);
    vesting[seedCategory].scheme = [
       
      5630625,
       
      3378375, 3378375, 3378375, 3378375, 3378375
    ];

     
    vesting[foundationCategory].limit = _expandToDecimals(193477500);
    vesting[foundationCategory].scheme = [
       
      0,
       
      0, 0, 0, 0, 0, 6000000, 6000000, 6000000, 6000000, 6000000, 6000000, 6000000,
       
      4000000, 4000000, 4000000, 4000000, 4000000, 4000000, 4000000, 4000000, 4000000, 4000000, 4000000, 4000000,
       
      4000000, 4000000, 4000000, 4000000, 4000000, 4000000, 4000000, 4000000, 4000000, 4000000, 4000000, 4000000,
       
      3000000, 3000000, 3000000, 3000000, 3000000, 3000000, 3000000, 3000000, 3000000, 3000000, 3000000, 3000000,
       
      19477500
    ];

     
    vesting[marketingCategory].limit = _expandToDecimals(50000000);
    vesting[marketingCategory].scheme = [
       
      0,
       
      0, 0, 2000000, 2000000, 2000000, 2000000, 2000000, 2000000, 2000000, 2000000, 2000000, 2000000,
       
      1500000, 1500000, 1500000, 1500000, 1500000, 1500000, 1500000, 1500000, 1500000, 1500000, 1500000, 1500000,
       
      1000000, 1000000, 1000000, 1000000, 1000000, 1000000, 1000000, 1000000, 1000000, 1000000, 1000000, 1000000
    ];

     
    vesting[teamCategory].limit = _expandToDecimals(50000000);
    vesting[teamCategory].scheme = [
       
      0,
       
      0, 0, 0, 0, 0, 7000000, 0, 0, 0, 7000000, 0, 0,
       
      0, 7000000, 0, 0, 0, 7000000, 0, 0, 7000000, 0, 0, 0,
       
      0, 7500000, 0, 0, 0, 7500000
    ];

     
    vesting[advisorCategory].limit = _expandToDecimals(24000000);
    vesting[advisorCategory].scheme = [
       
      0,
       
      0, 0, 6000000, 6000000, 4500000, 4500000, 0, 1500000, 1500000
    ];

    _expandToDecimalsVestingScheme(privateCategory);
    _expandToDecimalsVestingScheme(platformCategory);
    _expandToDecimalsVestingScheme(seedCategory);
    _expandToDecimalsVestingScheme(foundationCategory);
    _expandToDecimalsVestingScheme(marketingCategory);
    _expandToDecimalsVestingScheme(teamCategory);
    _expandToDecimalsVestingScheme(advisorCategory);
  }

  function _expandToDecimalsVestingScheme(bytes32 _category) internal returns (uint256[]) {
    for(uint i = 0; i < vesting[_category].scheme.length; i++) {
      vesting[_category].scheme[i] = _expandToDecimals(vesting[_category].scheme[i]);
    }
  }

  function _expandToDecimals(uint256 _amount) internal view returns (uint256) {
    return _amount.mul(10 ** uint(18));
  }
}