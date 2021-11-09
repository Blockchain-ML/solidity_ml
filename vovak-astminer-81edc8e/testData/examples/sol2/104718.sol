 
 

pragma solidity ^0.6.0;

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity ^0.6.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    function decimals() external view returns (uint8);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity ^0.6.0;

 
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

 

pragma solidity ^0.6.2;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
             
            if (returndata.length > 0) {
                 

                 
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

 

pragma solidity ^0.6.0;

 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

     
    function name() public view returns (string memory) {
        return _name;
    }

     
    function symbol() public view returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

}

 

pragma solidity ^0.6.0;

 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function governance() public view returns (address) {
        return _owner;
    }

     
    modifier onlyGovernance() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function transferGovernance(address newOwner) internal virtual onlyGovernance {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 
 
 
 
 

pragma solidity ^0.6.6;

interface LendingPoolAddressesProvider {
    function getLendingPool() external view returns (address);
    function getLendingPoolCore() external view returns (address);
}

interface LendingPool {
    function deposit(address, uint256, uint16) external;
}

interface aTokenContract is IERC20 {
    function redeem(uint256 _amount) external;
}

contract zaToken is ERC20("Stabilize Proxy Aave USDC Token", "za-USDC"), Ownable {
    using SafeERC20 for IERC20;

     
    uint256 constant divisionFactor = 100000;
    
     
    uint256 public initialFee = 1000;  
    uint256 public endFee = 100;  
    uint256 public feeDuration = 604800;  
    
     
     
     
    address public aaveProviderAddress = 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8;
    LendingPoolAddressesProvider aaveProvider;
    IERC20 private _underlyingAsset;  
    aTokenContract private _aToken;  
    address public treasuryAddress;
    
     
    event Wrapped(address indexed user, uint256 amount);
    event Unwrapped(address indexed user, uint256 amount, uint256 fee);
    
     
    struct UserInfo {
        uint256 depositTime;  
    }
    
    mapping(address => UserInfo) private userInfo;

    constructor (IERC20 _asset, aTokenContract _aavetoken, address _treasury) public {
        _underlyingAsset = _asset;
        _aToken = _aavetoken;
        treasuryAddress = _treasury;
        aaveProvider = LendingPoolAddressesProvider(aaveProviderAddress);  
        _setupDecimals(_aToken.decimals());
    }

    function underlyingAsset() public view returns (address) {
        return address(_underlyingAsset);
    }
    
    function totalPrincipalAndInterest() public view returns (uint256) {
        return _aToken.balanceOf(address(this));  
    } 
    
    function pricePerToken() external view returns (uint256) {
        if(totalSupply() == 0){
            return 1e18;  
        }else{
            return uint256(1e18).mul(totalPrincipalAndInterest()).div(totalSupply());
        }
    }
    
     
    function deposit(uint256 amount) public {
        require(amount > 0, "Cannot deposit 0");
        _underlyingAsset.safeTransferFrom(_msgSender(), address(this), amount);  
        
         
        LendingPool lendingPool = LendingPool(aaveProvider.getLendingPool());  
         
        _underlyingAsset.approve(aaveProvider.getLendingPoolCore(), amount);
        
         
        uint256 total = totalPrincipalAndInterest();
         
        uint256 _underlyingBalance = _underlyingAsset.balanceOf(address(this));
        lendingPool.deposit(underlyingAsset(), amount, 0);  
         
        uint256 movedBalance = _underlyingBalance.sub(_underlyingAsset.balanceOf(address(this)));
        require(movedBalance == amount, "Aave failed to properly move the entire amount");
        
         
        uint256 mintAmount = amount;
        if(total > 0){
             
            mintAmount = amount.mul(totalSupply()).div(total);  
        }
        _mint(_msgSender(),mintAmount);  
        userInfo[_msgSender()].depositTime = now;  
        
        emit Wrapped(_msgSender(), amount);
    }
    
    function redeem(uint256 amount) public {
         
        require(amount > 0, "Cannot withdraw 0");
        require(totalSupply() > 0, "No value redeemable");
        uint256 tokenTotal = totalSupply();
         
        _burn(_msgSender(),amount);  

        uint256 withdrawAmount = totalPrincipalAndInterest().mul(amount).div(tokenTotal);
         
        uint256 _underlyingBalance = _underlyingAsset.balanceOf(address(this));  
        _aToken.redeem(withdrawAmount);  
        uint256 movedBalance = _underlyingAsset.balanceOf(address(this)).sub(_underlyingBalance);
        require(movedBalance >= withdrawAmount, "Aave failed to properly move the entire amount");  
        
         
        if(userInfo[_msgSender()].depositTime == 0){
             
            userInfo[_msgSender()].depositTime = now;  
        }
        
        uint256 feeSubtraction = initialFee.sub(endFee).mul(now.sub(userInfo[_msgSender()].depositTime)).div(feeDuration);
        if(feeSubtraction > initialFee.sub(endFee)){
             
            feeSubtraction = initialFee.sub(endFee);
        }
        uint256 fee = initialFee.sub(feeSubtraction);
        fee = withdrawAmount.mul(fee).div(divisionFactor);
        withdrawAmount = withdrawAmount.sub(fee);
        
         
        _underlyingAsset.safeTransfer(_msgSender(), withdrawAmount);
        _underlyingAsset.safeTransfer(treasuryAddress, fee);
        
        emit Unwrapped(_msgSender(), withdrawAmount, fee);
    }
    
     
    
     
    
    uint256 private _timelockStart;  
    uint256 private _timelockType;  
    uint256 constant _timelockDuration = 86400;  
    
     
    uint256[3] private _timelock_data;
    address private _timelock_address;
    
    modifier timelockConditionsMet(uint256 _type) {
        require(_timelockType == _type, "Timelock not acquired for this function");
        _timelockType = 0;  
        if(totalSupply() > 0){
             
            require(now >= _timelockStart + _timelockDuration, "Timelock time not met");
        }
        _;
    }
    
     
     
    function startGovernanceChange(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 1;
        _timelock_address = _address;       
    }
    
    function finishGovernanceChange() external onlyGovernance timelockConditionsMet(1) {
        transferGovernance(_timelock_address);
    }
     
    
     
     
    function startChangeFeeRates(uint256 _initial, uint256 _end, uint256 _duration) external onlyGovernance {
        require(_initial <= 10000,"Fee can never be greater than 10%");
        require(_end <= _initial,"End fee must be less than or equal to initial fee");
        require(_duration > 0, "Cannot be a zero amount");
        _timelockStart = now;
        _timelockType = 2;
        _timelock_data[0] = _initial;
        _timelock_data[1] = _end;
        _timelock_data[2] = _duration;
    }
    
    function finishChangeFeeRates() external onlyGovernance timelockConditionsMet(2) {
        initialFee = _timelock_data[0];
        endFee = _timelock_data[1];
        feeDuration = _timelock_data[2];
    }
     
    
     
     
    function startChangeTreasury(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 3;
        _timelock_address = _address;
    }
    
    function finishChangeTreasury() external onlyGovernance timelockConditionsMet(3) {
        treasuryAddress = _timelock_address;
    }
     

}