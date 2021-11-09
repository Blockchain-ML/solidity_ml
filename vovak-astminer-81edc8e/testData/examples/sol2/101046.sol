 

pragma solidity ^0.5.0;

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
         
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

 

pragma solidity ^0.5.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity ^0.5.5;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

 

pragma solidity ^0.5.0;




 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function callOptionalReturn(IERC20 token, bytes memory data) private {
         
         

         
         
         
         
         
        require(address(token).isContract(), "SafeERC20: call to non-contract");

         
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 

pragma solidity >=0.4.24 <0.7.0;


 
contract Initializable {

   
  bool private initialized;

   
  bool private initializing;

   
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

   
  function isConstructor() private view returns (bool) {
     
     
     
     
     
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

   
  uint256[50] private ______gap;
}

 

pragma solidity ^0.5.0;


 
contract Context is Initializable {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity ^0.5.0;





 
contract ERC20 is Initializable, Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

     
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    uint256[50] private ______gap;
}

 

pragma solidity ^0.5.0;



 
contract ERC20Detailed is Initializable, IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

     
    function name() public view returns (string memory) {
        return _name;
    }

     
    function symbol() public view returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    uint256[50] private ______gap;
}

 

pragma solidity ^0.5.0;


 
contract ReentrancyGuard is Initializable {
     
    uint256 private _guardCounter;

    function initialize() public initializer {
         
         
        _guardCounter = 1;
    }

     
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }

    uint256[50] private ______gap;
}

 

pragma solidity ^0.5.0;



 
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}

 

pragma solidity ^0.5.0;

 
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

     
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

     
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

     
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

 

pragma solidity ^0.5.0;




contract PauserRole is Initializable, Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    function initialize(address sender) public initializer {
        if (!isPauser(sender)) {
            _addPauser(sender);
        }
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }

    uint256[50] private ______gap;
}

 

pragma solidity ^0.5.0;




 
contract Pausable is Initializable, Context, PauserRole {
     
    event Paused(address account);

     
    event Unpaused(address account);

    bool private _paused;

     
    function initialize(address sender) public initializer {
        PauserRole.initialize(sender);

        _paused = false;
    }

     
    function paused() public view returns (bool) {
        return _paused;
    }

     
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

     
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

     
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

     
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[50] private ______gap;
}

 

pragma solidity 0.5.16;

interface iERC20Fulcrum {
  function mint(
    address receiver,
    uint256 depositAmount)
    external
    returns (uint256 mintAmount);

  function burn(
    address receiver,
    uint256 burnAmount)
    external
    returns (uint256 loanAmountPaid);

  function tokenPrice()
    external
    view
    returns (uint256 price);

  function supplyInterestRate()
    external
    view
    returns (uint256);

  function rateMultiplier()
    external
    view
    returns (uint256);
  function baseRate()
    external
    view
    returns (uint256);

  function borrowInterestRate()
    external
    view
    returns (uint256);

  function avgBorrowInterestRate()
    external
    view
    returns (uint256);

  function protocolInterestRate()
    external
    view
    returns (uint256);

  function spreadMultiplier()
    external
    view
    returns (uint256);

  function totalAssetBorrow()
    external
    view
    returns (uint256);

  function totalAssetSupply()
    external
    view
    returns (uint256);

  function nextSupplyInterestRate(uint256)
    external
    view
    returns (uint256);

  function nextBorrowInterestRate(uint256)
    external
    view
    returns (uint256);
  function nextLoanInterestRate(uint256)
    external
    view
    returns (uint256);
  function totalSupplyInterestRate(uint256)
    external
    view
    returns (uint256);

  function claimLoanToken()
    external
    returns (uint256 claimedAmount);

  function dsr()
    external
    view
    returns (uint256);

  function chaiPrice()
    external
    view
    returns (uint256);
}

 

pragma solidity 0.5.16;

interface ILendingProtocol {
  function mint() external returns (uint256);
  function redeem(address account) external returns (uint256);
  function nextSupplyRate(uint256 amount) external view returns (uint256);
  function nextSupplyRateWithParams(uint256[] calldata params) external view returns (uint256);
  function getAPR() external view returns (uint256);
  function getPriceInToken() external view returns (uint256);
  function token() external view returns (address);
  function underlying() external view returns (address);
  function availableLiquidity() external view returns (uint256);
}

 

pragma solidity 0.5.16;

interface IGovToken {
  function redeemGovTokens() external;
}

 

 
pragma solidity 0.5.16;

interface IIdleTokenV3_1 {
   
   
  function tokenPrice() external view returns (uint256 price);

   
  function token() external view returns (address);
   
  function getAPRs() external view returns (address[] memory addresses, uint256[] memory aprs);

   
   

   
  function mintIdleToken(uint256 _amount, bool _skipRebalance, address _referral) external returns (uint256 mintedTokens);

   
  function redeemIdleToken(uint256 _amount) external returns (uint256 redeemedTokens);
   
  function redeemInterestBearingTokens(uint256 _amount) external;

   
  function rebalance() external returns (bool);
}

 

 
pragma solidity 0.5.16;

interface IIdleRebalancerV3 {
  function getAllocations() external view returns (uint256[] memory _allocations);
  function setAllocations(uint256[] calldata _allocations, address[] calldata _addresses) external;
}

 

pragma solidity 0.5.16;

interface Comptroller {
  function claimComp(address) external;
  function compSpeeds(address _cToken) external view returns (uint256);
  function claimComp(address[] calldata holders, address[] calldata cTokens, bool borrowers, bool suppliers) external;
}

 

pragma solidity 0.5.16;

interface CERC20 {
  function mint(uint256 mintAmount) external returns (uint256);
  function comptroller() external view returns (address);
  function redeem(uint256 redeemTokens) external returns (uint256);
  function exchangeRateStored() external view returns (uint256);
  function supplyRatePerBlock() external view returns (uint256);

  function borrowRatePerBlock() external view returns (uint256);
  function totalReserves() external view returns (uint256);
  function getCash() external view returns (uint256);
  function totalBorrows() external view returns (uint256);
  function reserveFactorMantissa() external view returns (uint256);
  function interestRateModel() external view returns (address);
}

 

pragma solidity 0.5.16;

interface GasToken {
  function freeUpTo(uint256 value) external returns (uint256 freed);
  function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);
  function balanceOf(address from) external returns (uint256 balance);
}

 

pragma solidity 0.5.16;



contract GST2ConsumerV2 is Initializable {
  GasToken public gst2;

  function initialize() initializer public {
    gst2 = GasToken(0x0000000000b3F879cb30FE243b4Dfee438691c04);
  }

  modifier gasDiscountFrom(address from) {
    uint256 initialGasLeft = gasleft();
    _;
    _makeGasDiscount(initialGasLeft - gasleft(), from);
  }

  function _makeGasDiscount(uint256 gasSpent, address from) internal {
     
     
     
    uint256 tokens = (gasSpent + 14154) / 41130;
    uint256 safeNumTokens;
    uint256 gas = gasleft();

     
    if (gas >= 27710) {
      safeNumTokens = (gas - 27710) / 7020;
    }

    if (tokens > safeNumTokens) {
      tokens = safeNumTokens;
    }

    if (tokens > 0) {
      gst2.freeFromUpTo(from, tokens);
    }
  }
}

 

 
pragma solidity 0.5.16;

















contract IdleTokenV3_1 is Initializable, ERC20, ERC20Detailed, ReentrancyGuard, Ownable, Pausable, IIdleTokenV3_1, GST2ConsumerV2 {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  uint256 private constant ONE_18 = 10**18;
   
   
  address public token;
   
  address private iToken;
   
  address private cToken;
   
  address public rebalancer;
   
  address public feeAddress;
   
  uint256 public lastITokenPrice;
   
  uint256 private tokenDecimals;
   
  uint256 public maxUnlentPerc;  
   
  uint256 public fee;
   
  address[] public allAvailableTokens;
   
  address[] public govTokens;
   
   
  uint256[] public lastAllocations;
   
  mapping(address => uint256) public userAvgPrices;
   
  mapping(address => address) public protocolWrappers;
   
  mapping (address => uint256) public govTokensLastBalances;
   
  mapping (address => mapping (address => uint256)) public usersGovTokensIndexes;
   
  mapping (address => uint256) public govTokensIndexes;
   
  mapping(address => uint256) private userNoFeeQty;
   
  bytes32 private _minterBlock;

   
  event Rebalance(address _rebalancer, uint256 _amount);
  event Referral(uint256 _amount, address _ref);

   
  function initialize(
    string memory _name,  
    string memory _symbol,  
    address _token,
    address _iToken,
    address _cToken,
    address _rebalancer
  )
    public initializer
     {
      require(_rebalancer != address(0), "IDLE:IS_0");
       
      ERC20Detailed.initialize(_name, _symbol, 18);
      Ownable.initialize(msg.sender);
      Pausable.initialize(msg.sender);
      ReentrancyGuard.initialize();
      GST2ConsumerV2.initialize();
       
      maxUnlentPerc = 1000;

      token = _token;
      tokenDecimals = ERC20Detailed(_token).decimals();
      iToken = _iToken;
      cToken = _cToken;
      rebalancer = _rebalancer;
  }

   
   
   
   
   
  modifier whenITokenPriceHasNotDecreased() {
    if (iToken != address(0)) {
      uint256 iTokenPrice = iERC20Fulcrum(iToken).tokenPrice();
      require(
        iTokenPrice >= lastITokenPrice,
        "IDLE:ITOKEN_PRICE"
      );

      _;

      if (iTokenPrice > lastITokenPrice) {
        lastITokenPrice = iTokenPrice;
      }
    } else {
      _;
    }
  }

   
   
  function setAllAvailableTokensAndWrappers(
    address[] calldata protocolTokens,
    address[] calldata wrappers
  ) external onlyOwner {
    require(protocolTokens.length == wrappers.length, "IDLE:LEN_DIFF");

    for (uint256 i = 0; i < protocolTokens.length; i++) {
      require(protocolTokens[i] != address(0) && wrappers[i] != address(0), "IDLE:IS_0");
      protocolWrappers[protocolTokens[i]] = wrappers[i];
    }
    allAvailableTokens = protocolTokens;
  }

   
  function setIToken(address _iToken)
    external onlyOwner {
      iToken = _iToken;
  }

   
  function setGovTokens(
    address[] calldata _newGovTokens
  ) external onlyOwner {
    govTokens = _newGovTokens;
  }

   
  function setRebalancer(address _rebalancer)
    external onlyOwner {
      require(_rebalancer != address(0), "IDLE:IS_0");
      rebalancer = _rebalancer;
  }

   
  function setFee(uint256 _fee)
    external onlyOwner {
       
      require(_fee <= 10000, "IDLE:TOO_HIGH");
      fee = _fee;
  }
   
  function setMaxUnlentPerc(uint256 _perc)
    external onlyOwner {
      require(_perc <= 100000, "IDLE:TOO_HIGH");
      maxUnlentPerc = _perc;
  }

   
  function setFeeAddress(address _feeAddress)
    external onlyOwner {
      require(_feeAddress != address(0), "IDLE:IS_0");
      feeAddress = _feeAddress;
  }

   
   
  function tokenPrice()
    external view
    returns (uint256) {
    return _tokenPrice();
  }

   
  function getAPRs()
    external view
    returns (address[] memory addresses, uint256[] memory aprs) {
      address currToken;
      addresses = new address[](allAvailableTokens.length);
      aprs = new uint256[](allAvailableTokens.length);
      for (uint256 i = 0; i < allAvailableTokens.length; i++) {
        currToken = allAvailableTokens[i];
        addresses[i] = currToken;
        aprs[i] = ILendingProtocol(protocolWrappers[currToken]).getAPR();
      }
  }

   
  function getAvgAPR()
    external view
    returns (uint256 avgApr) {
      (, uint256[] memory amounts, uint256 total) = _getCurrentAllocations();
      for (uint256 i = 0; i < allAvailableTokens.length; i++) {
        if (amounts[i] == 0) {
          continue;
        }
         
        avgApr = avgApr.add(
          ILendingProtocol(protocolWrappers[allAvailableTokens[i]]).getAPR().mul(
            amounts[i]
          )
        );
      }

      avgApr = avgApr.div(total);
  }

   
  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    _updateUserGovIdxTransfer(sender, recipient, amount);
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, allowance(sender, msg.sender).sub(amount, "ERC20: transfer amount exceeds allowance"));
    _updateUserFeeInfo(recipient, amount, userAvgPrices[sender]);
    return true;
  }

   
  function transfer(address recipient, uint256 amount) public returns (bool) {
    _updateUserGovIdxTransfer(msg.sender, recipient, amount);
    _transfer(msg.sender, recipient, amount);
    _updateUserFeeInfo(recipient, amount, userAvgPrices[msg.sender]);
    return true;
  }

   
  function _updateUserGovIdxTransfer(address _from, address _to, uint256 amount) internal {
    address govToken;
    uint256 govTokenIdx;
    uint256 sharePerTokenFrom;
    uint256 shareTo;
    uint256 balanceTo = balanceOf(_to);
    for (uint256 i = 0; i < govTokens.length; i++) {
      govToken = govTokens[i];
      if (balanceTo == 0) {
        usersGovTokensIndexes[govToken][_to] = usersGovTokensIndexes[govToken][_from];
        continue;
      }

      govTokenIdx = govTokensIndexes[govToken];
       
      sharePerTokenFrom = govTokenIdx.sub(usersGovTokensIndexes[govToken][_from]);
       
      shareTo = balanceTo.mul(govTokenIdx.sub(usersGovTokensIndexes[govToken][_to])).div(ONE_18);
       
       
      usersGovTokensIndexes[govToken][_to] = govTokenIdx.sub(
        shareTo.mul(ONE_18).add(sharePerTokenFrom.mul(amount)).div(
          balanceTo.add(amount)
        )
      );
    }
  }

   
  function getGovTokensAmounts(address _usr) external view returns (uint256[] memory _amounts) {
    address govToken;
    uint256 usrBal = balanceOf(_usr);
    _amounts = new uint256[](govTokens.length);
    for (uint256 i = 0; i < _amounts.length; i++) {
      govToken = govTokens[i];
      _amounts[i] = usrBal.mul(govTokensIndexes[govToken].sub(usersGovTokensIndexes[govToken][_usr])).div(ONE_18);
    }
  }

   
   
  function mintIdleToken(uint256 _amount, bool _skipRebalance, address _referral)
    external nonReentrant whenNotPaused whenITokenPriceHasNotDecreased
    returns (uint256 mintedTokens) {
    _minterBlock = keccak256(abi.encodePacked(tx.origin, block.number));
    _redeemGovTokens(msg.sender, true);
     
    uint256 idlePrice = _tokenPrice();
     
    IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);

    if (!_skipRebalance) {
       
      _rebalance();
    }

    mintedTokens = _amount.mul(ONE_18).div(idlePrice);
    _mint(msg.sender, mintedTokens);

     
    _updateUserFeeInfo(msg.sender, mintedTokens, idlePrice);
     
    _updateUserGovIdx(msg.sender, mintedTokens);

    if (_referral != address(0)) {
      emit Referral(_amount, _referral);
    }
  }

   
  function _updateUserGovIdx(address _to, uint256 _mintedTokens) internal {
    address govToken;
    uint256 usrBal = balanceOf(_to);
    uint256 _govIdx;
    uint256 _usrIdx;

    for (uint256 i = 0; i < govTokens.length; i++) {
      govToken = govTokens[i];
      _govIdx = govTokensIndexes[govToken];
      _usrIdx = usersGovTokensIndexes[govToken][_to];

       
      usersGovTokensIndexes[govToken][_to] = usrBal.mul(_usrIdx).add(
        _mintedTokens.mul(_govIdx.sub(_usrIdx))
      ).div(usrBal);
    }
  }

   
  function redeemIdleToken(uint256 _amount)
    external nonReentrant
    returns (uint256 redeemedTokens) {
       
      require(keccak256(abi.encodePacked(tx.origin, block.number)) != _minterBlock, "IDLE:REENTR");
      _redeemGovTokens(msg.sender, false);

      uint256 valueToRedeem = _amount.mul(_tokenPrice()).div(ONE_18);
      uint256 balanceUnderlying = IERC20(token).balanceOf(address(this));
      uint256 idleSupply = totalSupply();

      if (valueToRedeem <= balanceUnderlying) {
        redeemedTokens = valueToRedeem;
      } else {
        address currToken;
        for (uint256 i = 0; i < allAvailableTokens.length; i++) {
          currToken = allAvailableTokens[i];
          redeemedTokens = redeemedTokens.add(
            _redeemProtocolTokens(
              protocolWrappers[currToken],
              currToken,
               
              _amount.mul(IERC20(currToken).balanceOf(address(this))).div(idleSupply),  
              address(this)
            )
          );
        }
         
        redeemedTokens = redeemedTokens.add(_amount.mul(balanceUnderlying).div(idleSupply));
      }

      if (fee > 0 && feeAddress != address(0)) {
        redeemedTokens = _getFee(_amount, redeemedTokens);
      } else {
        userNoFeeQty[msg.sender] = balanceOf(msg.sender).sub(_amount);
      }

      _burn(msg.sender, _amount);
       
      IERC20(token).safeTransfer(msg.sender, redeemedTokens);
  }

   
  function redeemInterestBearingTokens(uint256 _amount)
    external nonReentrant {
      _redeemGovTokens(msg.sender, false);

      uint256 idleSupply = totalSupply();
      address currentToken;

      for (uint256 i = 0; i < allAvailableTokens.length; i++) {
        currentToken = allAvailableTokens[i];
        IERC20(currentToken).safeTransfer(
          msg.sender,
          _amount.mul(IERC20(currentToken).balanceOf(address(this))).div(idleSupply)  
        );
      }
       
      IERC20(token).safeTransfer(
        msg.sender,
        _amount.mul(IERC20(token).balanceOf(address(this))).div(idleSupply)  
      );

      _burn(msg.sender, _amount);
  }

   
  function rebalanceWithGST()
    external gasDiscountFrom(msg.sender)
    returns (bool) {
      return _rebalance();
  }

   
  function rebalance() external returns (bool) {
    return _rebalance();
  }

   
   
  function _tokenPrice() internal view returns (uint256 price) {
    uint256 totSupply = totalSupply();
    if (totSupply == 0) {
      return 10**(tokenDecimals);
    }

    address currToken;
    uint256 totNav = IERC20(token).balanceOf(address(this)).mul(ONE_18);  

    for (uint256 i = 0; i < allAvailableTokens.length; i++) {
      currToken = allAvailableTokens[i];
      totNav = totNav.add(
         
        ILendingProtocol(protocolWrappers[currToken]).getPriceInToken().mul(
          IERC20(currToken).balanceOf(address(this))
        )
      );
    }

    price = totNav.div(totSupply);  
  }

   
  function _rebalance()
    internal whenNotPaused whenITokenPriceHasNotDecreased
    returns (bool) {
       
      uint256[] memory rebalancerLastAllocations = IIdleRebalancerV3(rebalancer).getAllocations();
      bool areAllocationsEqual = rebalancerLastAllocations.length == lastAllocations.length;
      if (areAllocationsEqual) {
        for (uint256 i = 0; i < lastAllocations.length || !areAllocationsEqual; i++) {
          if (lastAllocations[i] != rebalancerLastAllocations[i]) {
            areAllocationsEqual = false;
            break;
          }
        }
      }

      uint256 balance = IERC20(token).balanceOf(address(this));
      uint256 maxUnlentBalance;

      if (areAllocationsEqual && balance == 0) {
        return false;
      }

      if (balance > 0) {
        maxUnlentBalance = _getCurrentPoolValue().mul(maxUnlentPerc).div(100000);
        if (lastAllocations.length == 0) {
           
          lastAllocations = rebalancerLastAllocations;
        }

        if (balance > maxUnlentBalance) {
           
          _mintWithAmounts(allAvailableTokens, _amountsFromAllocations(rebalancerLastAllocations, balance.sub(maxUnlentBalance)));
        }
      }

      if (areAllocationsEqual) {
        return false;
      }

       
       
       
      (address[] memory tokenAddresses, uint256[] memory amounts, uint256 totalInUnderlying) = _getCurrentAllocations();

      if (balance == 0 && maxUnlentPerc > 0) {
        totalInUnderlying = totalInUnderlying.sub(_getCurrentPoolValue().mul(maxUnlentPerc).div(100000));
      }
       
      uint256[] memory newAmounts = _amountsFromAllocations(rebalancerLastAllocations, totalInUnderlying);
      (uint256[] memory toMintAllocations, uint256 totalToMint, bool lowLiquidity) = _redeemAllNeeded(tokenAddresses, amounts, newAmounts);
       
       
      if (!lowLiquidity) {
         
        delete lastAllocations;
        lastAllocations = rebalancerLastAllocations;
      }

       
      if (maxUnlentBalance == 0 && maxUnlentPerc > 0) {
        maxUnlentBalance = _getCurrentPoolValue().mul(maxUnlentPerc).div(100000);
      }

      uint256 totalRedeemd = IERC20(token).balanceOf(address(this));

      if (totalRedeemd <= maxUnlentBalance) {
        return false;
      }

       
      uint256[] memory tempAllocations = new uint256[](toMintAllocations.length);
      for (uint256 i = 0; i < toMintAllocations.length; i++) {
         
        tempAllocations[i] = toMintAllocations[i].mul(100000).div(totalToMint);
      }

      uint256[] memory partialAmounts = _amountsFromAllocations(tempAllocations, totalRedeemd.sub(maxUnlentBalance));
      _mintWithAmounts(allAvailableTokens, partialAmounts);

      emit Rebalance(msg.sender, totalInUnderlying.add(maxUnlentBalance));

      return true;  
  }

   
  function _redeemGovTokens(address _to, bool _skipRedeem) internal {
    if (govTokens.length == 0) {
      return;
    }
    uint256 supply = totalSupply();
    uint256 usrBal = balanceOf(_to);
    address govToken;

    for (uint256 i = 0; i < govTokens.length; i++) {
      govToken = govTokens[i];

      if (supply > 0) {
        if (!_skipRedeem) {
           
          if (i == 0) {
            address[] memory holders = new address[](1);
            address[] memory cTokens = new address[](1);
            holders[0] = address(this);
            cTokens[0] = cToken;
            Comptroller(CERC20(allAvailableTokens[0]).comptroller()).claimComp(holders, cTokens, false, true);
          }
        }
         

         
        uint256 govBal = IERC20(govToken).balanceOf(address(this));
        if (govBal > 0) {
           
          govTokensIndexes[govToken] = govTokensIndexes[govToken].add(
             
            govBal.sub(govTokensLastBalances[govToken]).mul(ONE_18).div(supply)
          );
           
          govTokensLastBalances[govToken] = govBal;
        }
      }

      if (usrBal > 0) {
        if (!_skipRedeem) {
          uint256 usrIndex = usersGovTokensIndexes[govToken][_to];
           
          usersGovTokensIndexes[govToken][_to] = govTokensIndexes[govToken];
           
          uint256 delta = govTokensIndexes[govToken].sub(usrIndex);
          if (delta == 0) { continue; }
          uint256 share = usrBal.mul(delta).div(ONE_18);
          uint256 bal = IERC20(govToken).balanceOf(address(this));
           
          if (share > bal) {
            share = bal;
          }

          uint256 feeDue;
          if (feeAddress != address(0) && fee > 0) {
            feeDue = share.mul(fee).div(100000);
             
            IERC20(govToken).safeTransfer(feeAddress, feeDue);
          }
           
          IERC20(govToken).safeTransfer(_to, share.sub(feeDue));
           
          govTokensLastBalances[govToken] = IERC20(govToken).balanceOf(address(this));
        }
      } else {
         
        usersGovTokensIndexes[govToken][_to] = govTokensIndexes[govToken];
      }
    }
  }

   
  function _updateUserFeeInfo(address usr, uint256 qty, uint256 price) internal {
    if (fee == 0) {
      userNoFeeQty[usr] = userNoFeeQty[usr].add(qty);
      return;
    }

    uint256 totBalance = balanceOf(usr).sub(userNoFeeQty[usr]);
    uint256 oldAvgPrice = userAvgPrices[usr];
    uint256 oldBalance = totBalance.sub(qty);
    userAvgPrices[usr] = oldAvgPrice.mul(oldBalance).div(totBalance).add(price.mul(qty).div(totBalance));
  }

   
  function _getFee(uint256 amount, uint256 redeemed) internal returns (uint256) {
    uint256 noFeeQty = userNoFeeQty[msg.sender];
    uint256 currPrice = _tokenPrice();
    if (noFeeQty > 0 && noFeeQty > amount) {
      noFeeQty = amount;
    }

    uint256 totalValPaid = noFeeQty.mul(currPrice).add(amount.sub(noFeeQty).mul(userAvgPrices[msg.sender])).div(ONE_18);
    uint256 currVal = amount.mul(currPrice).div(ONE_18);
    if (currVal < totalValPaid) {
      return redeemed;
    }
    uint256 feeDue = currVal.sub(totalValPaid).mul(fee).div(100000);
    IERC20(token).safeTransfer(feeAddress, feeDue);
    userNoFeeQty[msg.sender] = userNoFeeQty[msg.sender].sub(noFeeQty);
    return currVal.sub(feeDue);
  }

   
  function _mintWithAmounts(address[] memory tokenAddresses, uint256[] memory protocolAmounts) internal {
     
    uint256 currAmount;
    address protWrapper;

    for (uint256 i = 0; i < protocolAmounts.length; i++) {
      currAmount = protocolAmounts[i];
      if (currAmount == 0) {
        continue;
      }
      protWrapper = protocolWrappers[tokenAddresses[i]];
       
      IERC20(token).safeTransfer(protWrapper, currAmount);
      ILendingProtocol(protWrapper).mint();
    }
  }

   
  function _amountsFromAllocations(uint256[] memory allocations, uint256 total)
    internal pure returns (uint256[] memory newAmounts) {
    newAmounts = new uint256[](allocations.length);
    uint256 currBalance;
    uint256 allocatedBalance;

    for (uint256 i = 0; i < allocations.length; i++) {
      if (i == allocations.length - 1) {
        newAmounts[i] = total.sub(allocatedBalance);
      } else {
        currBalance = total.mul(allocations[i]).div(100000);
        allocatedBalance = allocatedBalance.add(currBalance);
        newAmounts[i] = currBalance;
      }
    }
    return newAmounts;
  }

   
  function _redeemAllNeeded(
    address[] memory tokenAddresses,
    uint256[] memory amounts,
    uint256[] memory newAmounts
    ) internal returns (
      uint256[] memory toMintAllocations,
      uint256 totalToMint,
      bool lowLiquidity
    ) {
    toMintAllocations = new uint256[](amounts.length);
    ILendingProtocol protocol;
    uint256 currAmount;
    uint256 newAmount;
    address currToken;
     
    for (uint256 i = 0; i < amounts.length; i++) {
      currToken = tokenAddresses[i];
      newAmount = newAmounts[i];
      currAmount = amounts[i];
      protocol = ILendingProtocol(protocolWrappers[currToken]);
      if (currAmount > newAmount) {
        uint256 toRedeem = currAmount.sub(newAmount);
        uint256 availableLiquidity = protocol.availableLiquidity();
        if (availableLiquidity < toRedeem) {
          lowLiquidity = true;
          toRedeem = availableLiquidity;
        }
         
        _redeemProtocolTokens(
          protocolWrappers[currToken],
          currToken,
           
          toRedeem.mul(ONE_18).div(protocol.getPriceInToken()),
          address(this)  
        );
      } else {
        toMintAllocations[i] = newAmount.sub(currAmount);
        totalToMint = totalToMint.add(toMintAllocations[i]);
      }
    }
  }

   
  function _getCurrentAllocations() internal view
    returns (address[] memory tokenAddresses, uint256[] memory amounts, uint256 total) {
       
      tokenAddresses = new address[](allAvailableTokens.length);
      amounts = new uint256[](allAvailableTokens.length);

      address currentToken;
      uint256 currTokenPrice;

      for (uint256 i = 0; i < allAvailableTokens.length; i++) {
        currentToken = allAvailableTokens[i];
        tokenAddresses[i] = currentToken;
        currTokenPrice = ILendingProtocol(protocolWrappers[currentToken]).getPriceInToken();
        amounts[i] = currTokenPrice.mul(
          IERC20(currentToken).balanceOf(address(this))
        ).div(ONE_18);
        total = total.add(amounts[i]);
      }

       
      return (tokenAddresses, amounts, total);
  }

   
  function _getCurrentPoolValue() internal view
    returns (uint256 total) {
       
      address currentToken;

      for (uint256 i = 0; i < allAvailableTokens.length; i++) {
        currentToken = allAvailableTokens[i];
        total = total.add(ILendingProtocol(protocolWrappers[currentToken]).getPriceInToken().mul(
          IERC20(currentToken).balanceOf(address(this))
        ).div(ONE_18));
      }

       
      total = total.add(IERC20(token).balanceOf(address(this)));
  }

   
   
  function _redeemProtocolTokens(address _wrapperAddr, address _token, uint256 _amount, address _account)
    internal
    returns (uint256 tokens) {
      if (_amount == 0) {
        return tokens;
      }
       
      IERC20(_token).safeTransfer(_wrapperAddr, _amount);
      tokens = ILendingProtocol(_wrapperAddr).redeem(_account);
  }
}