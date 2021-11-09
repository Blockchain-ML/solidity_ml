 

pragma solidity ^0.5.0;

 
contract Context {
     
     
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




 
contract ERC20 is Context, IERC20 {
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



contract MinterRole is Context {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

 

pragma solidity ^0.5.0;



 
contract ERC20Mintable is ERC20, MinterRole {
     
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}

 

pragma solidity ^0.5.0;


 
contract ERC20Capped is ERC20Mintable {
    uint256 private _cap;

     
    constructor (uint256 cap) public {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

     
    function cap() public view returns (uint256) {
        return _cap;
    }

     
    function _mint(address account, uint256 value) internal {
        require(totalSupply().add(value) <= _cap, "ERC20Capped: cap exceeded");
        super._mint(account, value);
    }
}

 

pragma solidity ^0.5.0;


 
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol, uint8 decimals) public {
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

 

pragma solidity ^0.5.0;

 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
}

 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

pragma solidity 0.5.17;





 
contract TokenVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

   
  address internal mTokenContract;
   
  uint256 internal mPeriodsCount;
   
  uint256 internal mTotalVested;
   
  uint256 internal mCurrentVested;
   
  bool internal mBeneficiariesLocked;
   
  bool internal mTokensLocked;
   
  uint256[] internal mReleaseDates;

   
  mapping(uint256 => uint256) internal mVestReleaseDate;
   
  mapping(address => uint256) internal mVestReleaseAmount;
   
  mapping(address => mapping(uint256 => bool)) internal mVestingClaims;

   
  event BeneficiaryAdded(address indexed beneficiary, uint256 releaseAmount);
   
  event BeneficiaryRemoved(address indexed beneficiary, uint256 releaseAmount);
   
  event TokensClaimed(address indexed owner, uint256 amount);

   
  constructor(address _tokenContract, uint256[] memory _releaseDates) public {
    require(_releaseDates.length > 0, "There must be at least 1 release date");
    require(_releaseDates[0] > block.timestamp + 3600, "Release dates must be at least 1h the future");

    mTokenContract = _tokenContract;
    mPeriodsCount = _releaseDates.length;

    mVestReleaseDate[0] = _releaseDates[0];
    for (uint256 i = 1; i < _releaseDates.length; i++) {
      require(
        _releaseDates[i] > _releaseDates[i - 1],
        "Release dates should be in strictly ascending order"
      );
      mVestReleaseDate[i] = _releaseDates[i];
    }
    mReleaseDates = _releaseDates;
    mTotalVested = 0;
    mCurrentVested = 0;
    mBeneficiariesLocked = false;
    mTokensLocked = false;
  }

   
  function tokenContract() external view returns (address) {
    return mTokenContract;
  }

   
  function periodsCount() external view returns (uint256) {
    return mPeriodsCount;
  }

   
  function totalVested() external view returns (uint256) {
    return mTotalVested;
  }

   
  function currentVested() external view returns (uint256) {
    return mCurrentVested;
  }

   
  function beneficiariesLocked() external view returns (bool) {
    return mBeneficiariesLocked;
  }

   
  function tokensLocked() external view returns (bool) {
    return mTokensLocked;
  }

   
  function releaseDates() external view returns (uint256[] memory) {
    return mReleaseDates;
  }

   
  function releaseDate(uint256 _period) external view returns (uint256) {
    return mVestReleaseDate[_period];
  }

   
  function releaseAmount(address _beneficiary) external view returns (uint256) {
    return mVestReleaseAmount[_beneficiary];
  }

   
  function isReleased(address _beneficiary, uint256 _period) external view returns (bool) {
    return mVestingClaims[_beneficiary][_period];
  }

   
  function lockBeneficiaries() external onlyOwner {
    require(!mBeneficiariesLocked, "Already locked");
    require(block.timestamp < mReleaseDates[0], "Cannot lock beneficiaries late");
    require(mTotalVested > 0, "No beneficiaries present");
    mBeneficiariesLocked = true;
  }

   
  function lockTokens() external onlyOwner {
    require(!mTokensLocked, "Already locked");
    require(mBeneficiariesLocked, "Beneficiaries are not locked");
    require(block.timestamp < mReleaseDates[0], "Cannot lock tokens late");
    uint256 balance = IERC20(mTokenContract).balanceOf(address(this));
    require(balance >= mTotalVested, "Balance must equal to or greater than the total vested amount");
    mCurrentVested = mTotalVested;
    mTokensLocked = true;
  }

   
  function addBeneficiary(address _beneficiary, uint256 _releaseAmount) external onlyOwner {
    require(_beneficiary != address(0), "Beneficiary cannot be the zero-address");
    require(_beneficiary != address(this), "Beneficiary cannot be this vesting contract");
    require(_beneficiary != mTokenContract, "Beneficiary cannot be the token contract");
    require(mVestReleaseAmount[_beneficiary] == 0, "Beneficiary already exists");
    require(_releaseAmount != 0, "Vesting amount cannot be zero");
    require(!mBeneficiariesLocked, "Beneficiaries locked, cannot be added");

    mVestReleaseAmount[_beneficiary] = _releaseAmount;
    mTotalVested = mTotalVested.add(_releaseAmount.mul(mPeriodsCount));

    emit BeneficiaryAdded(_beneficiary, _releaseAmount);
  }

   
  function removeBeneficiary(address _beneficiary) external onlyOwner {
    require(_beneficiary != address(0), "Beneficiary cannot be the zero-address");
    require(_beneficiary != address(this), "Beneficiary cannot be this vesting contract");
    require(_beneficiary != mTokenContract, "Beneficiary cannot be the token contract");
    require(mVestReleaseAmount[_beneficiary] != 0, "Not a beneficiary");
    require(!mBeneficiariesLocked, "Beneficiaries locked, cannot be removed");

    uint256 beneficiaryReleaseAmount = mVestReleaseAmount[_beneficiary];
    mTotalVested = mTotalVested.sub(beneficiaryReleaseAmount.mul(mPeriodsCount));
    mVestReleaseAmount[_beneficiary] = 0;

    emit BeneficiaryRemoved(_beneficiary, beneficiaryReleaseAmount);
  }

   
  function withdraw(uint256 _amount) external onlyOwner {
    uint256 balance = IERC20(mTokenContract).balanceOf(address(this));
    uint256 freeBalance = balance.sub(mCurrentVested);
    require(_amount <= freeBalance, "Insufficient balance of non-vested tokens");
    IERC20(mTokenContract).safeTransfer(owner(), _amount);
  }

   
  function withdrawNonTokens(address _tokenContract, address _dumpSite, uint256 _amount) external onlyOwner {
    require(_tokenContract != mTokenContract, "Cannot withdraw vested tokens");
    IERC20(_tokenContract).safeTransfer(_dumpSite, _amount);
  }

   
  function withdrawETH(address payable _dumpSite, uint256 _amount) external onlyOwner {
    _dumpSite.transfer(_amount);
  }

   
  function adminSendTokens(address _beneficiary, uint256 _period) external onlyOwner {
    processTokenClaim(_beneficiary, _period);
  }

   
  function claimTokens(uint256 _period) external {
    processTokenClaim(msg.sender, _period);
  }

   
  function processTokenClaim(address _beneficiary, uint256 _period) internal {
    require(mTokensLocked, "Vesting has not started");
    require(mVestReleaseDate[_period] > 0, "Period does not exist");
    require(
      mVestReleaseDate[_period] < block.timestamp,
      "Release date of given period has not been reached yet."
      );
    require(mVestingClaims[_beneficiary][_period] == false, "Vesting has already been claimed");

    mVestingClaims[_beneficiary][_period] = true;

    mCurrentVested = mCurrentVested.sub(mVestReleaseAmount[_beneficiary]);
    IERC20(mTokenContract).safeTransfer(_beneficiary, mVestReleaseAmount[_beneficiary]);

    emit TokensClaimed(_beneficiary, mVestReleaseAmount[_beneficiary]);
  }

}

 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

pragma solidity ^0.5.17;




 
contract NymToken is ERC20Capped, ERC20Detailed {
    constructor ()
    public
    ERC20Capped(1000000000*10**18)
    ERC20Detailed("Nym Token", "NYMPH", 18)
    {
         
    }

     
    function _transfer(address _sender, address _recipient, uint256 _amount) internal {
        require(_recipient != address(this), "NymToken: transfer to token contract address");
        super._transfer(_sender, _recipient, _amount);
    }

     
    function _mint(address _account, uint256 _amount) internal {
        require(_account != address(this), "NymToken: mint to token contract address");
        super._mint(_account, _amount);
    }

     
    function mintForVesting(TokenVesting _vestingContract) public onlyMinter {
        require(_vestingContract.beneficiariesLocked(), "Beneficiaries are unlocked");
        require(!_vestingContract.tokensLocked(), "Tokens are locked");
        uint256 balance = balanceOf(address (_vestingContract));
        uint256 totalVested = _vestingContract.totalVested();
        uint256 mintAmount = totalVested.sub(balance);
        require(mintAmount > 0, "No vesting tokens to be minted");
        _mint(address(_vestingContract), mintAmount);
    }

     
    function burn(uint256 _amount) public onlyMinter {
        _burn(msg.sender, _amount);
    }
}