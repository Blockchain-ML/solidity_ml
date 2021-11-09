 

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

 

pragma solidity ^0.5.12;

interface IDefiProtocol {
     
    function handleDeposit(address token, uint256 amount) external;

    function handleDeposit(address[] calldata tokens, uint256[] calldata amounts) external;

     
    function withdraw(address beneficiary, address token, uint256 amount) external;

     
    function withdraw(address beneficiary, uint256[] calldata amounts) external;

     
    function claimRewards() external returns(address[] memory tokens, uint256[] memory amounts);

     
    function withdrawReward(address token, address user, uint256 amount) external;

     
    function balanceOf(address token) external returns(uint256);

     
    function balanceOfAll() external returns(uint256[] memory); 

     
    function normalizedBalance() external returns(uint256);

    function supportedTokens() external view returns(address[] memory);

    function supportedTokensCount() external view returns(uint256);

    function supportedRewardTokens() external view returns(address[] memory);

    function isSupportedRewardToken(address token) external view returns(bool);

     
    function canSwapToToken(address token) external view returns(bool);

}

 

pragma solidity ^0.5.12;

 
 
contract ICErc20 { 


     

    function transfer(address dst, uint amount) external returns (bool);
    function transferFrom(address src, address dst, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function balanceOfUnderlying(address owner) external returns (uint256);
    function exchangeRateCurrent() external returns (uint256);
    function exchangeRateStored() external view returns (uint256);
    function accrueInterest() external returns (uint256);

      

    function mint(uint mintAmount) external returns (uint256);
    function redeem(uint redeemTokens) external returns (uint256);
    function redeemUnderlying(uint redeemAmount) external returns (uint256);

}

 

pragma solidity ^0.5.16;

interface IComptroller {
    function claimComp(address holder) external;
    function claimComp(address[] calldata holders, address[] calldata cTokens, bool borrowers, bool suppliers) external;
    function getCompAddress() external view returns (address);
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

 

pragma solidity ^0.5.12;




 
contract Base is Initializable, Context, Ownable {
    address constant  ZERO_ADDRESS = address(0);

    function initialize() public initializer {
        Ownable.initialize(_msgSender());
    }

}

 

pragma solidity ^0.5.12;

 
contract ModuleNames {
     
    string internal constant MODULE_ACCESS            = "access";
    string internal constant MODULE_SAVINGS           = "savings";
    string internal constant MODULE_INVESTING         = "investing";
    string internal constant MODULE_STAKING           = "staking";
    string internal constant MODULE_DCA               = "dca";

     
    string internal constant CONTRACT_RAY             = "ray";
}

 

pragma solidity ^0.5.12;



 
contract Module is Base, ModuleNames {
    event PoolAddressChanged(address newPool);
    address public pool;

    function initialize(address _pool) public initializer {
        Base.initialize();
        setPool(_pool);
    }

    function setPool(address _pool) public onlyOwner {
        require(_pool != ZERO_ADDRESS, "Module: pool address can't be zero");
        pool = _pool;
        emit PoolAddressChanged(_pool);        
    }

    function getModuleAddress(string memory module) public view returns(address){
        require(pool != ZERO_ADDRESS, "Module: no pool");
        (bool success, bytes memory result) = pool.staticcall(abi.encodeWithSignature("get(string)", module));
        
         
        if (!success) assembly {
            revert(add(result, 32), result)
        }

        address moduleAddress = abi.decode(result, (address));
         
         
        require(moduleAddress != ZERO_ADDRESS, "Module: requested module not found");
        return moduleAddress;
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

 

pragma solidity ^0.5.12;




contract DefiOperatorRole is Initializable, Context {
    using Roles for Roles.Role;

    event DefiOperatorAdded(address indexed account);
    event DefiOperatorRemoved(address indexed account);

    Roles.Role private _operators;

    function initialize(address sender) public initializer {
        if (!isDefiOperator(sender)) {
            _addDefiOperator(sender);
        }
    }

    modifier onlyDefiOperator() {
        require(isDefiOperator(_msgSender()), "DefiOperatorRole: caller does not have the DefiOperator role");
        _;
    }

    function addDefiOperator(address account) public onlyDefiOperator {
        _addDefiOperator(account);
    }

    function renounceDefiOperator() public {
        _removeDefiOperator(_msgSender());
    }

    function isDefiOperator(address account) public view returns (bool) {
        return _operators.has(account);
    }

    function _addDefiOperator(address account) internal {
        _operators.add(account);
        emit DefiOperatorAdded(account);
    }

    function _removeDefiOperator(address account) internal {
        _operators.remove(account);
        emit DefiOperatorRemoved(account);
    }

}

 

pragma solidity ^0.5.12;










contract ProtocolBase is Module, DefiOperatorRole, IDefiProtocol {
    uint256 constant MAX_UINT256 = uint256(-1);

    event RewardTokenClaimed(address indexed token, uint256 amount);

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(address=>uint256) public rewardBalances;     

    function initialize(address _pool) public initializer {
        Module.initialize(_pool);
        DefiOperatorRole.initialize(_msgSender());
    }

    function upgrade(address rtkn, uint256 newStoredBalance) public onlyOwner {
        require(rewardBalances[rtkn] == 0, "No upgrade required");
        uint256 balance = IERC20(rtkn).balanceOf(address(this));
        require(newStoredBalance <= balance, "Can not store more than available");
        rewardBalances[rtkn] = newStoredBalance;
    }

    function supportedRewardTokens() public view returns(address[] memory);

    function isSupportedRewardToken(address token) public view returns(bool);

    function cliamRewardsFromProtocol() internal;

    function claimRewards() public onlyDefiOperator returns(address[] memory tokens, uint256[] memory amounts){
        cliamRewardsFromProtocol();

         
        address[] memory rewardTokens = supportedRewardTokens();
        uint256[] memory rewardAmounts = new uint256[](rewardTokens.length);
        uint256 receivedRewardTokensCount;
        for(uint256 i = 0; i < rewardTokens.length; i++) {
            address rtkn = rewardTokens[i];
            uint256 newBalance = IERC20(rtkn).balanceOf(address(this));
            if(newBalance > rewardBalances[rtkn]) {
                receivedRewardTokensCount++;
                rewardAmounts[i] = newBalance.sub(rewardBalances[rtkn]);
                rewardBalances[rtkn] = newBalance;
            }
        }

         
        tokens = new address[](receivedRewardTokensCount);
        amounts = new uint256[](receivedRewardTokensCount);
        if(receivedRewardTokensCount > 0) {
            uint256 j;
            for(uint256 i = 0; i < rewardTokens.length; i++) {
                if(rewardAmounts[i] > 0) {
                    tokens[j] = rewardTokens[i];
                    amounts[j] = rewardAmounts[i];
                    j++;
                }
            }
        }
    }

    function withdrawReward(address token, address user, uint256 amount) public onlyDefiOperator {
        require(isSupportedRewardToken(token), "ProtocolBase: not reward token");
        rewardBalances[token] = rewardBalances[token].sub(amount);
        IERC20(token).safeTransfer(user, amount);
    }
}

 

pragma solidity ^0.5.12;











 
contract CompoundProtocol is ProtocolBase {
    uint256 constant MAX_UINT256 = uint256(-1);

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public baseToken;
    uint8 public decimals;
    ICErc20 public cToken;
    IComptroller public comptroller;
    IERC20 public compToken;

    function initialize(address _pool, address _token, address _cToken, address _comptroller) public initializer {
        ProtocolBase.initialize(_pool);
        baseToken = IERC20(_token);
        cToken = ICErc20(_cToken);
        decimals = ERC20Detailed(_token).decimals();
        baseToken.safeApprove(_cToken, MAX_UINT256);
        comptroller = IComptroller(_comptroller);
        compToken = IERC20(comptroller.getCompAddress());
    }

     
     
     
     

    function handleDeposit(address token, uint256 amount) public onlyDefiOperator {
        require(token == address(baseToken), "CompoundProtocol: token not supported");
        cToken.mint(amount);
    }

    function handleDeposit(address[] memory tokens, uint256[] memory amounts) public onlyDefiOperator {
        require(tokens.length == 1 && amounts.length == 1, "CompoundProtocol: wrong count of tokens or amounts");
        handleDeposit(tokens[0], amounts[0]);
    }

    function withdraw(address beneficiary, address token, uint256 amount) public onlyDefiOperator {
        require(token == address(baseToken), "CompoundProtocol: token not supported");

        cToken.redeemUnderlying(amount);
        baseToken.safeTransfer(beneficiary, amount);
    }

    function withdraw(address beneficiary, uint256[] memory amounts) public onlyDefiOperator {
        require(amounts.length == 1, "CompoundProtocol: wrong amounts array length");

        cToken.redeemUnderlying(amounts[0]);
        baseToken.safeTransfer(beneficiary, amounts[0]);
    }

    function balanceOf(address token) public returns(uint256) {
        if (token != address(baseToken)) return 0;
        return cToken.balanceOfUnderlying(address(this));
    }
    
    function balanceOfAll() public returns(uint256[] memory) {
        uint256[] memory balances = new uint256[](1);
        balances[0] = balanceOf(address(baseToken));
        return balances;
    }

    function normalizedBalance() public returns(uint256) {
        return normalizeAmount(address(baseToken), balanceOf(address(baseToken)));
    }

    function canSwapToToken(address token) public view returns(bool) {
        return (token == address(baseToken));
    }    

    function supportedTokens() public view returns(address[] memory){
        address[] memory tokens = new address[](1);
        tokens[0] = address(baseToken);
        return tokens;
    }

    function supportedTokensCount() public view returns(uint256) {
        return 1;
    }

    function supportedRewardTokens() public view returns(address[] memory) {
        address[] memory rtokens = new address[](1);
        rtokens[0] = address(compToken);
        return rtokens;
    }

    function isSupportedRewardToken(address token) public view returns(bool) {
        return(token == address(compToken));
    }

    function cliamRewardsFromProtocol() internal {
        address[] memory holders = new address[](1);
        holders[0] = address(this);
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(cToken);
        comptroller.claimComp(holders, cTokens, false, true);
    }

    function normalizeAmount(address, uint256 amount) internal view returns(uint256) {
        if (decimals == 18) {
            return amount;
        } else if (decimals > 18) {
            return amount.div(10**(uint256(decimals)-18));
        } else if (decimals < 18) {
            return amount.mul(10**(18-uint256(decimals)));
        }
    }

    function denormalizeAmount(address, uint256 amount) internal view returns(uint256) {
        if (decimals == 18) {
            return amount;
        } else if (decimals > 18) {
            return amount.mul(10**(uint256(decimals)-18));
        } else if (decimals < 18) {
            return amount.div(10**(18-uint256(decimals)));
        }
    }

}

 

pragma solidity ^0.5.12;


contract CompoundProtocol_DAI is CompoundProtocol {
    function initialize(address _pool, address _token, address _cToken, address _comptroller) public initializer {
        CompoundProtocol.initialize(
            _pool, 
            _token,
            _cToken,
            _comptroller
        );
    }    
}