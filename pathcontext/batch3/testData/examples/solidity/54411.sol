pragma solidity ^0.4.24;

 

 
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

   
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

   
  function owner() public view returns(address) {
    return _owner;
  }

   
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

   
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

   
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

 

 
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

 

 
contract ERC20Detailed is IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

   
  function name() public view returns(string) {
    return _name;
  }

   
  function symbol() public view returns(string) {
    return _symbol;
  }

   
  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

 

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);  
    uint256 c = a / b;
     

    return c;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

   
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

 

 
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

   
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

   
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

   
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

   
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

   
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

   
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

   
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

   
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

   
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

   
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

   
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

   
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

     
     
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

 

 
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

   
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

   
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

   
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

 

contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}

 

 
contract Pausable is PauserRole {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() internal {
    _paused = false;
  }

   
  function paused() public view returns(bool) {
    return _paused;
  }

   
  modifier whenNotPaused() {
    require(!_paused);
    _;
  }

   
  modifier whenPaused() {
    require(_paused);
    _;
  }

   
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

   
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }
}

 

 
contract ERC20Pausable is ERC20, Pausable {

  function transfer(
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(to, value);
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(from, to, value);
  }

  function approve(
    address spender,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(spender, value);
  }

  function increaseAllowance(
    address spender,
    uint addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseAllowance(spender, addedValue);
  }

  function decreaseAllowance(
    address spender,
    uint subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseAllowance(spender, subtractedValue);
  }
}

 

contract SignkeysToken is ERC20Pausable, ERC20Detailed, Ownable {

    uint8 public constant DECIMALS = 18;

    uint256 public constant INITIAL_SUPPLY = 2E10 * (10 ** uint256(DECIMALS));

     
    constructor() public ERC20Detailed("SignkeysToken", "KEYS", DECIMALS) {
        _mint(owner(), INITIAL_SUPPLY);
    }

    function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool success) {
        require(_spender != address(this));
        require(super.approve(_spender, _value));
        require(_spender.call(_data));
        return true;
    }

    function() payable external {
        revert();
    }
}

contract SignkeysReferralSmartContract is Ownable {
    using SafeMath for uint256;

     
    SignkeysToken token;

     
    SignkeysCrowdsale signkeysCrowdsale;

    uint256[] public buyingAmountRanges = [199, 1000, 10000, 100000, 1000000, 10000000];
    uint256[] public referrerRewards = [5, 50, 500, 5000, 50000];
    uint256[] public refereeRewards = [5, 50, 500, 5000, 50000];

    event BonusSent(
        address indexed referrerAddress,
        uint256 referrerAmount,
        address indexed refereeAddress,
        uint256 refereeAmount
    );

    constructor(address _token) public {
        token = SignkeysToken(_token);
    }

    function setCrowdsaleContract(address _crowdsale) public {
        signkeysCrowdsale = SignkeysCrowdsale(_crowdsale);
    }

    function calcBonus(uint256 amount, bool isReferrer) private view returns (uint256) {
        uint256 multiplier = 10 ** uint256(token.decimals());
        if (amount < multiplier.mul(buyingAmountRanges[0])) {
            return 0;
        }
        for (uint i = 1; i < buyingAmountRanges.length; i++) {
            uint min = buyingAmountRanges[i - 1];
            uint max = buyingAmountRanges[i];
            if (amount > min.mul(multiplier) && amount <= max.mul(multiplier)) {
                return isReferrer ? multiplier.mul(referrerRewards[i - 1]) : multiplier.mul(refereeRewards[i - 1]);
            }
        }
    }

    function sendBonus(address referrer, address referee, uint256 _amount) external returns (uint256)  {
        require(msg.sender == address(signkeysCrowdsale), "Bonus may be sent only by crowdsale contract");

        uint256 referrerBonus;
        uint256 refereeBonus;

        uint256 referrerBonusAmount = calcBonus(_amount, true);
        uint256 refereeBonusAmount = calcBonus(_amount, false);

        if (token.balanceOf(this) > referrerBonusAmount) {
            token.transfer(referrer, referrerBonusAmount);
            referrerBonus = referrerBonusAmount;
        } else {
            referrerBonus = 0;
        }

        if (token.balanceOf(this) > refereeBonusAmount) {
            token.transfer(referee, refereeBonusAmount);
            refereeBonus = refereeBonusAmount;
        } else {
            refereeBonus = 0;
        }

        emit BonusSent(referrer, referrerBonus, referee, refereeBonus);
    }

    function getBuyingAmountRanges() public onlyOwner view returns (uint256[]) {
        return buyingAmountRanges;
    }

    function getReferrerRewards() public onlyOwner view returns (uint256[]) {
        return referrerRewards;
    }

    function getRefereeRewards() public onlyOwner view returns (uint256[]) {
        return refereeRewards;
    }

    function setBuyingAmountRanges(uint[] ranges) public onlyOwner {
        buyingAmountRanges = ranges;
    }

    function setReferrerRewards(uint[] rewards) public onlyOwner {
        require(rewards.length == buyingAmountRanges.length - 1);
        referrerRewards = rewards;
    }

    function setRefereeRewards(uint[] rewards) public onlyOwner {
        require(rewards.length == buyingAmountRanges.length - 1);
        refereeRewards = rewards;
    }
}

pragma solidity ^0.4.24;

 
contract ReentrancyGuard {

   
  uint256 private _guardCounter;

  constructor() internal {
     
     
    _guardCounter = 1;
  }

   
  modifier nonReentrant() {
    _guardCounter += 1;
    uint256 localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter);
  }

}


contract SignkeysCrowdsale is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

     
    SignkeysToken signkeysToken;

     
    SignkeysVesting signkeysVesting;

     
    SignkeysReferralSmartContract referralSmartContract;

     
    address public signer;

     
    address public wallet;

     
    event BuyTokens(
        address indexed buyer,
        address indexed tokenReceiver,
        uint256 tokenPrice,
        uint256 amount,
        uint256 indexed customerId
    );

     
    event StartsAtChanged(uint newStartsAtUTC);

     
    event EndsAtChanged(uint newEndsAtUTC);

     
    event WalletChanged(address newWallet);

     
    event CrowdsaleSignerChanged(address newSigner);

    constructor(
        address _token,
        address _vesting,
        address _referralSmartContract,
        address _wallet,
        address _signer
    ) public {
        require(_token != 0x0, "Token contract for crowdsale must be set");
        require(_vesting != 0x0, "Vesting contract for crowdsale must be set");
        require(_referralSmartContract != 0x0, "Referral smart contract for crowdsale must be set");

        require(_wallet != 0x0, "Wallet for fund transferring must be set");
        require(_signer != 0x0, "Signer must be set");

        signkeysToken = SignkeysToken(_token);
        signkeysVesting = SignkeysVesting(_vesting);
        referralSmartContract = SignkeysReferralSmartContract(_referralSmartContract);

        signer = _signer;
        wallet = _wallet;
    }

    function setSignerAddress(address _signer) external onlyOwner {
        signer = _signer;
        emit CrowdsaleSignerChanged(_signer);
    }

    function setWalletAddress(address _wallet) external onlyOwner {
        wallet = _wallet;
        emit WalletChanged(_wallet);
    }

    function setVestingContract(address _vesting) external onlyOwner {
        signkeysVesting = SignkeysVesting(_vesting);
    }

    function setReferralSmartContract(address _referralSmartContract) external onlyOwner {
        referralSmartContract = SignkeysReferralSmartContract(_referralSmartContract);
    }

    function getRemainingTokensToSell() external view returns (uint256) {
        return signkeysToken.balanceOf(this);
    }

     
    function buyTokens(
        address tokenReceiver,
        address referral,
        uint256 _tokenPrice,
        uint256 _minWei,
        uint256 _customerId,
        uint256 _expiration,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) payable external nonReentrant {
        require(_expiration >= now, "Signature expired");
        require(_customerId != 0, "Customer id must be defined to track the transactions");
        require(_minWei > 0, "Minimal amount to purchase must be greater than 0");

        require(msg.value >= _minWei, "Purchased amount is less than min amount to invest");

        address receivedSigner = ecrecover(
            keccak256(
                abi.encodePacked(
                    _tokenPrice, _minWei, _customerId, _expiration
                )
            ), _v, _r, _s);

        require(receivedSigner == signer, "Something wrong with signature");

        uint256 tokensAmount = msg.value.mul(10 ** uint256(signkeysToken.decimals())).div(_tokenPrice);
        require(signkeysToken.balanceOf(this) >= tokensAmount, "Not enough tokens in sale contract");
        uint256 amountForVesting = tokensAmount.mul(signkeysVesting.percentageToLock()).div(100);

        signkeysToken.transfer(tokenReceiver, tokensAmount.sub(amountForVesting));
        signkeysToken.approve(address(signkeysVesting), amountForVesting);
        signkeysVesting.lock(tokenReceiver, amountForVesting);

        if (referral != 0x0) {
             
            referralSmartContract.sendBonus(referral, tokenReceiver, tokensAmount);
        }

         
        if (wallet == 0x0 || !wallet.send(msg.value)) {
            revert();
        }

        emit BuyTokens(msg.sender, tokenReceiver, _tokenPrice, tokensAmount, _customerId);
    }

     
    function() payable external {
        revert();
    }
}

pragma solidity ^0.4.24;

contract SignkeysVesting is Ownable {
    using SafeMath for uint256;

    uint256 public INITIAL_VESTING_CLIFF_SECONDS = 180 days;
    uint256 public INITIAL_PERCENTAGE_TO_LOCK = 50;  

     
    SignkeysToken public signkeysToken;

     
    SignkeysCrowdsale public signkeysCrowdsale;

     
    uint public vestingStartDateTime;

     
    uint public vestingCliffDateTime;

     
    uint256 public percentageToLock;

     
    mapping(address => uint256) private _balances;

    event TokensLocked(address indexed user, uint amount);
    event TokensReleased(address indexed user, uint amount);

    constructor() public{
        vestingStartDateTime = now;
        vestingCliffDateTime = SafeMath.add(now, INITIAL_VESTING_CLIFF_SECONDS);
        percentageToLock = INITIAL_PERCENTAGE_TO_LOCK;
    }

    function setToken(address token) external onlyOwner {
        signkeysToken = SignkeysToken(token);
    }

    function setCrowdsaleContract(address crowdsaleContract) external onlyOwner {
        signkeysCrowdsale = SignkeysCrowdsale(crowdsaleContract);
    }

    function balanceOf(address tokenHolder) external view returns (uint256) {
        return _balances[tokenHolder];
    }

    function lock(address _user, uint256 _amount) external returns (uint256)  {
        require(msg.sender == address(signkeysCrowdsale), "Tokens may be locked only by crowdsale contract");
        require(signkeysToken.balanceOf(_user) >= _amount, "User balance is less than the requested size");

        signkeysToken.transferFrom(msg.sender, this, _amount);

        _balances[_user] = _balances[_user].add(_amount);

        emit TokensLocked(_user, _amount);

        return _balances[_user];
    }

     
    function release(address _user) private {
        require(vestingCliffDateTime <= now, "Cannot release vested tokens until vesting cliff date");
        uint256 unreleased = _balances[_user];

        if (unreleased > 0) {
            signkeysToken.transfer(_user, unreleased);
            _balances[_user] = _balances[_user].sub(unreleased);
        }

        emit TokensReleased(_user, unreleased);
    }

    function release() public {
        release(msg.sender);
    }

    function setVestingStartDateTime(uint _vestingStartDateTime) external onlyOwner {
        require(_vestingStartDateTime <= vestingCliffDateTime, "Start date should be less or equal than cliff date");
        vestingStartDateTime = _vestingStartDateTime;
    }

    function setVestingCliffDateTime(uint _vestingCliffDateTime) external onlyOwner {
        require(vestingStartDateTime <= _vestingCliffDateTime, "Cliff date should be greater or equal than start date");
        vestingCliffDateTime = _vestingCliffDateTime;
    }

    function setPercentageToLock(uint256 percentage) external onlyOwner {
        require(percentage >= 0 && percentage <= 100, "Percentage must be in range [0, 100]");
        percentageToLock = percentage;
    }


}