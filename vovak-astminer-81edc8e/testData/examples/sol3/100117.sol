 

 



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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

     
    function decimals() public view returns (uint8) {
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

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

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

     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

 

pragma solidity ^0.6.0;

interface StakingInterface {
     
    event WhitelistToken(address indexed tokenAddress);

     
    event DiscardToken(address indexed tokenAddress);

     
    event StakeEvent(
        address indexed staker,
        address indexed tokenAddress,
        uint256 tokenBalance
    );

     
     
    event Redeem(
        address indexed staker,
        address indexed tokenAddress,
        uint256 tokenWithdrawal
    );

     
    event TakeEarnings(address indexed tokenAddress, uint256 indexed amount);

     
     
     
     
     
    function balanceOf(address staker, address tokenAddress) external view returns (uint256);

     
     
     
    function whitelistToken(address tokenAddress) external;

     
     
     
    function removeToken(address tokenAddress) external;

     
     
     
     
     
    function stake(address tokenAddress, uint256 amount) external;

     
     
     
     
     
    function redeem(address staker, address tokenAddress, uint256 amount) external;

     
     
     
     
    function takeEarnings(address tokenAddress, uint256 amount) external;
}

 

pragma solidity ^0.6.0;

contract ComptrollerErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        COMPTROLLER_MISMATCH,
        INSUFFICIENT_SHORTFALL,
        INSUFFICIENT_LIQUIDITY,
        INVALID_CLOSE_FACTOR,
        INVALID_COLLATERAL_FACTOR,
        INVALID_LIQUIDATION_INCENTIVE,
        MARKET_NOT_ENTERED,
        MARKET_NOT_LISTED,
        MARKET_ALREADY_LISTED,
        MATH_ERROR,
        NONZERO_BORROW_BALANCE,
        PRICE_ERROR,
        REJECTION,
        SNAPSHOT_ERROR,
        TOO_MANY_ASSETS,
        TOO_MUCH_REPAY
    }

    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
        EXIT_MARKET_BALANCE_OWED,
        EXIT_MARKET_REJECTION,
        SET_CLOSE_FACTOR_OWNER_CHECK,
        SET_CLOSE_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_NO_EXISTS,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_WITHOUT_PRICE,
        SET_IMPLEMENTATION_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_VALIDATION,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_PENDING_IMPLEMENTATION_OWNER_CHECK,
        SET_PRICE_ORACLE_OWNER_CHECK,
        SUPPORT_MARKET_EXISTS,
        SUPPORT_MARKET_OWNER_CHECK,
        ZUNUSED
    }

     
    event Failure(uint256 error, uint256 info, uint256 detail);

     
    function fail(Error err, FailureInfo info) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), 0);

        return uint256(err);
    }

     
    function failOpaque(Error err, FailureInfo info, uint256 opaqueError) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), opaqueError);

        return uint256(err);
    }
}

contract TokenErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        BAD_INPUT,
        COMPTROLLER_REJECTION,
        COMPTROLLER_CALCULATION_ERROR,
        INTEREST_RATE_MODEL_ERROR,
        INVALID_ACCOUNT_PAIR,
        INVALID_CLOSE_AMOUNT_REQUESTED,
        INVALID_COLLATERAL_FACTOR,
        MATH_ERROR,
        MARKET_NOT_FRESH,
        MARKET_NOT_LISTED,
        TOKEN_INSUFFICIENT_ALLOWANCE,
        TOKEN_INSUFFICIENT_BALANCE,
        TOKEN_INSUFFICIENT_CASH,
        TOKEN_TRANSFER_IN_FAILED,
        TOKEN_TRANSFER_OUT_FAILED
    }

     
    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED,
        ACCRUE_INTEREST_BORROW_RATE_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED,
        ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED,
        BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        BORROW_ACCRUE_INTEREST_FAILED,
        BORROW_CASH_NOT_AVAILABLE,
        BORROW_FRESHNESS_CHECK,
        BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        BORROW_MARKET_NOT_LISTED,
        BORROW_COMPTROLLER_REJECTION,
        LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED,
        LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED,
        LIQUIDATE_COLLATERAL_FRESHNESS_CHECK,
        LIQUIDATE_COMPTROLLER_REJECTION,
        LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED,
        LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX,
        LIQUIDATE_CLOSE_AMOUNT_IS_ZERO,
        LIQUIDATE_FRESHNESS_CHECK,
        LIQUIDATE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_REPAY_BORROW_FRESH_FAILED,
        LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED,
        LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED,
        LIQUIDATE_SEIZE_COMPTROLLER_REJECTION,
        LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_SEIZE_TOO_MUCH,
        MINT_ACCRUE_INTEREST_FAILED,
        MINT_COMPTROLLER_REJECTION,
        MINT_EXCHANGE_CALCULATION_FAILED,
        MINT_EXCHANGE_RATE_READ_FAILED,
        MINT_FRESHNESS_CHECK,
        MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        MINT_TRANSFER_IN_FAILED,
        MINT_TRANSFER_IN_NOT_POSSIBLE,
        REDEEM_ACCRUE_INTEREST_FAILED,
        REDEEM_COMPTROLLER_REJECTION,
        REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED,
        REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED,
        REDEEM_EXCHANGE_RATE_READ_FAILED,
        REDEEM_FRESHNESS_CHECK,
        REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        REDEEM_TRANSFER_OUT_NOT_POSSIBLE,
        REDUCE_RESERVES_ACCRUE_INTEREST_FAILED,
        REDUCE_RESERVES_ADMIN_CHECK,
        REDUCE_RESERVES_CASH_NOT_AVAILABLE,
        REDUCE_RESERVES_FRESH_CHECK,
        REDUCE_RESERVES_VALIDATION,
        REPAY_BEHALF_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_COMPTROLLER_REJECTION,
        REPAY_BORROW_FRESHNESS_CHECK,
        REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COMPTROLLER_OWNER_CHECK,
        SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED,
        SET_INTEREST_RATE_MODEL_FRESH_CHECK,
        SET_INTEREST_RATE_MODEL_OWNER_CHECK,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_ORACLE_MARKET_NOT_LISTED,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED,
        SET_RESERVE_FACTOR_ADMIN_CHECK,
        SET_RESERVE_FACTOR_FRESH_CHECK,
        SET_RESERVE_FACTOR_BOUNDS_CHECK,
        TRANSFER_COMPTROLLER_REJECTION,
        TRANSFER_NOT_ALLOWED,
        TRANSFER_NOT_ENOUGH,
        TRANSFER_TOO_MUCH
    }

     
    event Failure(uint256 error, uint256 info, uint256 detail);

     
    function fail(Error err, FailureInfo info) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), 0);

        return uint256(err);
    }

     
    function failOpaque(Error err, FailureInfo info, uint256 opaqueError) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), opaqueError);

        return uint256(err);
    }
}

 

pragma solidity ^0.6.0;

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

 

pragma solidity ^0.6.0;

library Types {
    struct Token {
        uint256 listPointer;
    }
    struct Stake {
        address TokenAddress;
        uint256 TokenBalance;
    }
}

 

pragma solidity ^0.6.12;








contract Stake is StakingInterface, Ownable, TokenErrorReporter {
    using SafeMath for uint256;
    using Roles for Roles.Role;

    Roles.Role operators;

    event WhitelistToken(address indexed tokenAddress);
    event DiscardToken(address indexed tokenAddress);

    event StakeEvent(
        address indexed staker,
        address indexed tokenAddress,
        uint256 tokenBalance
    );
    event Redeem(
        address indexed staker,
        address indexed tokenAddress,
        uint256 tokenWithdrawal
    );

    event TakeEarnings(address indexed tokenAddress, uint256 indexed amount);

    address[] public TokenList;
    mapping(address => Types.Token) public TokenStructs;
    mapping(address => mapping(address => Types.Stake)) public stakes;

    string private constant ERROR_AMOUNT_ZERO = "STAKING_AMOUNT_ZERO";
    string private constant ERROR_AMOUNT_NEGATIVE = "STAKING_AMOUNT_NEGATIVE";
    string private constant ERROR_TOKEN_TRANSFER = "STAKING_TOKEN_TRANSFER_FAILED";
    string private constant ERROR_NOT_ENOUGH_BALANCE = "STAKING_NOT_ENOUGH_BALANCE";
    string private constant ERROR_NOT_ENOUGH_ALLOWANCE = "STAKING_NOT_ENOUGH_ALLOWANCE";
    string private constant ERROR_TOKEN_NOT_WHITELISTED = "STAKING_TOKEN_NOT_WHITELISTED";
    string private constant ERROR_NOT_OWNER = "SEND_IS_NOT_OWNER";
    string private constant ERROR_NO_STAKE = "STAKING_NOT_FOUND";
    string private constant ERROR_TOKEN_EXISTS = "TOKEN_EXISTS";
    string private constant ERROR_TOKEN_NOT_FOUND = "TOKEN_NOT_FOUND";
    string private constant ERROR_LENGTH_NOT_EQUAL = "LENGTH_NOT_EQUAL";
    string private constant ERROR_TRANSFER_FAILED = "TOKEN_TRANSFER_FAILED";

    constructor(address[] memory TokenAddress) public {
        bulkWhitelistToken(TokenAddress);
    }

    modifier onlyOperatorOrOwner() {
        require(operators.has(msg.sender) || owner() == msg.sender, ERROR_NOT_OWNER);
        _;
    }

    modifier onlyStakerOrOwner(address staker) {
        require(msg.sender == staker || operators.has(msg.sender)  || owner() == msg.sender, ERROR_NOT_OWNER);
        _;
    }

    modifier stakeExists(address staker, address tokenAddress) {
        require(stakes[staker][tokenAddress].TokenAddress == tokenAddress, ERROR_NO_STAKE);
        _;
    }

    function addOperator(address _operator) public onlyOwner
    {
        operators.add(_operator);
    }

    function removeOperator(address _operator) public onlyOwner
    {
        operators.remove(_operator);
    }

    function balanceOf(address staker, address tokenAddress) public view override returns (uint256) {
        if(isStake(staker, tokenAddress)) {
            return stakes[staker][tokenAddress].TokenBalance;
        }
        return 0;
    }

    function isToken(address tokenAddress) public view returns (bool) {
        if (TokenList.length == uint256(Error.NO_ERROR)) return false;
        return (TokenList[TokenStructs[tokenAddress].listPointer] == tokenAddress);
    }

    function isStake(address staker, address tokenAddress) public view returns (bool) {
        return stakes[staker][tokenAddress].TokenAddress == tokenAddress;
    }

    function hasStake(address staker, address tokenAddress) public view returns (bool) {
        if(!isStake(staker, tokenAddress)) {
            return false;
        }
        return stakes[staker][tokenAddress].TokenBalance > 0;
    }

    function whitelistToken(address TokenAddress) public override onlyOwner {
        require(!isToken(TokenAddress), ERROR_TOKEN_EXISTS);
        TokenList.push(TokenAddress);
        TokenStructs[TokenAddress].listPointer = TokenList.length.sub(1);
        emit WhitelistToken(TokenAddress);
    }

    function bulkWhitelistToken(address[] memory TokenAddress) public {
        uint256 length = TokenAddress.length;
        if (length > 0) {
            for (uint256 i = 0; i < length; i = i.add(1)) {
                whitelistToken(TokenAddress[i]);
            }
        }
    }

    function removeToken(address TokenAddress) public override onlyOwner {
        require(isToken(TokenAddress), ERROR_TOKEN_NOT_FOUND);
        uint256 rowToDelete = TokenStructs[TokenAddress].listPointer;
            delete TokenList[rowToDelete];
            delete TokenStructs[TokenAddress];
            emit DiscardToken(TokenAddress);
            return;
    }

    function bulkRemoveToken(address[] memory TokenAddress) public {
        uint256 length = TokenAddress.length;
        if (length > 0) {
            for (uint256 i = 0; i < length; i = i.add(1)) {
                removeToken(TokenAddress[i]);
            }
        }
    }

    function stake(address tokenAddress, uint256 amount) public override {
        addStakeForToken(msg.sender, tokenAddress, amount);
    }

    function stakeFor(address staker, address tokenAddress, uint256 amount) public onlyOperatorOrOwner {
        addStakeForToken(staker, tokenAddress, amount);
    }

    function bulkStakeFor(address[] memory staker, address tokenAddress, uint256[] memory amount) public onlyOperatorOrOwner {
        require(staker.length == amount.length, ERROR_LENGTH_NOT_EQUAL);
        uint256 length = staker.length;
        if (length > 0) {
            for (uint256 i = 0; i < length; i = i.add(1)) {
                addStakeForToken(staker[i], tokenAddress, amount[i]);
            }
        }
    }

    function bulkRedeem(address[] memory staker, address tokenAddress, uint256[] memory amount) public onlyOperatorOrOwner {
        require(staker.length == amount.length, ERROR_LENGTH_NOT_EQUAL);
        uint256 length = staker.length;
        if (length > 0) {
            for (uint256 i = 0; i < length; i = i.add(1)) {
                redeem(staker[i], tokenAddress, amount[i]);
            }
        }
    }

    function redeem(address staker, address tokenAddress, uint256 amount) public override onlyOperatorOrOwner {
        require(isToken(tokenAddress), ERROR_TOKEN_NOT_FOUND);
        require(hasStake(staker, tokenAddress), ERROR_NO_STAKE);
        require(amount > 0, ERROR_AMOUNT_ZERO);

         
        Types.Stake memory memStake = stakes[staker][tokenAddress];
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, ERROR_NOT_ENOUGH_BALANCE);

        uint256 tBalance = memStake.TokenBalance;
        require(tBalance >= amount, ERROR_NOT_ENOUGH_BALANCE);
        require(tBalance > 0, ERROR_NOT_ENOUGH_BALANCE);

         
        uint256 remainingAmount = tBalance.sub(amount);
        require(remainingAmount >= 0, ERROR_NOT_ENOUGH_BALANCE);
        _updateStakeForToken(staker, tokenAddress, remainingAmount);

         
        require(token.transfer(staker, amount), ERROR_TOKEN_TRANSFER);
        emit Redeem(staker, tokenAddress, amount);
    }

    function takeEarnings(address tokenAddress, uint256 amount) public override onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, ERROR_NOT_ENOUGH_BALANCE);

        require(IERC20(tokenAddress).transfer(msg.sender, amount));
        emit TakeEarnings(tokenAddress, amount);
    }

    function takeAllEarnings(address tokenAddress) public onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, ERROR_NOT_ENOUGH_BALANCE);

        require(token.transfer(msg.sender, balance));
        emit TakeEarnings(tokenAddress, balance);
    }

    function addStakeForToken(address staker, address TokenAddress, uint256 amount) internal {
        require(isToken(TokenAddress), ERROR_TOKEN_NOT_FOUND);
        require(amount > 0, ERROR_AMOUNT_ZERO);
        IERC20 token = IERC20(TokenAddress);
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, ERROR_NOT_ENOUGH_ALLOWANCE);
        uint256 funds = amount;
        funds = stakes[staker][TokenAddress].TokenBalance.add(amount);
        _updateStakeForToken(staker, TokenAddress, funds);
        require(token.transferFrom(msg.sender, address(this), amount), ERROR_TOKEN_TRANSFER);
        emit StakeEvent(staker, TokenAddress, amount);
    }

    function _updateStakeForToken(address staker, address TokenAddress, uint256 amount) internal {
        require(amount >= 0, ERROR_AMOUNT_NEGATIVE);
        stakes[staker][TokenAddress] = Types.Stake({
            TokenAddress : TokenAddress,
            TokenBalance : amount
            });
    }
}