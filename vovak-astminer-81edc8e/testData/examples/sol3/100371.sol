 

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

 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = _msgSender();
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

 

pragma solidity ^0.5.5;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
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

interface IDmmEther {

     
    function wethToken() external view returns (address);

     
    function mintViaEther() external payable returns (uint);

     
    function redeemToWETH(uint amount) external returns (uint);

}

 

pragma solidity ^0.5.0;

interface InterestRateInterface {

     
    function getInterestRate(uint dmmTokenId, uint totalSupply, uint activeSupply) external view returns (uint);

}

 

pragma solidity ^0.5.0;


 
contract Blacklistable is Ownable {

    string public constant BLACKLISTED = "BLACKLISTED";

    mapping(address => bool) internal blacklisted;

    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);
    event BlacklisterChanged(address indexed newBlacklister);

     
    modifier onlyBlacklister() {
        require(msg.sender == owner(), "MUST_BE_BLACKLISTER");
        _;
    }

     
    modifier notBlacklisted(address account) {
        require(blacklisted[account] == false, BLACKLISTED);
        _;
    }

     
    function checkNotBlacklisted(address account) public view {
        require(!blacklisted[account], BLACKLISTED);
    }

     
    function isBlacklisted(address account) public view returns (bool) {
        return blacklisted[account];
    }

     
    function blacklist(address account) public onlyBlacklister {
        blacklisted[account] = true;
        emit Blacklisted(account);
    }

     
    function unBlacklist(address account) public onlyBlacklister {
        blacklisted[account] = false;
        emit UnBlacklisted(account);
    }

}

 

pragma solidity ^0.5.0;



interface IDmmController {

    event TotalSupplyIncreased(uint oldTotalSupply, uint newTotalSupply);
    event TotalSupplyDecreased(uint oldTotalSupply, uint newTotalSupply);

    event AdminDeposit(address indexed sender, uint amount);
    event AdminWithdraw(address indexed receiver, uint amount);

    function blacklistable() external view returns (Blacklistable);

     
    function addMarket(
        address underlyingToken,
        string calldata symbol,
        string calldata name,
        uint8 decimals,
        uint minMintAmount,
        uint minRedeemAmount,
        uint totalSupply
    ) external;

     
    function addMarketFromExistingDmmToken(
        address dmmToken,
        address underlyingToken
    ) external;

     
    function transferOwnershipToNewController(
        address newController
    ) external;

     
    function enableMarket(uint dmmTokenId) external;

     
    function disableMarket(uint dmmTokenId) external;

     
    function setInterestRateInterface(address newInterestRateInterface) external;

     
    function setOffChainAssetValuator(address newOffChainAssetValuator) external;

     
    function setOffChainCurrencyValuator(address newOffChainCurrencyValuator) external;

     
    function setUnderlyingTokenValuator(address newUnderlyingTokenValuator) external;

     
    function setMinCollateralization(uint newMinCollateralization) external;

     
    function setMinReserveRatio(uint newMinReserveRatio) external;

     
    function increaseTotalSupply(uint dmmTokenId, uint amount) external;

     
    function decreaseTotalSupply(uint dmmTokenId, uint amount) external;

     
    function adminWithdrawFunds(uint dmmTokenId, uint underlyingAmount) external;

     
    function adminDepositFunds(uint dmmTokenId, uint underlyingAmount) external;

     
    function getTotalCollateralization() external view returns (uint);

     
    function getActiveCollateralization() external view returns (uint);

     
    function getInterestRateByUnderlyingTokenAddress(address underlyingToken) external view returns (uint);

     
    function getInterestRateByDmmTokenId(uint dmmTokenId) external view returns (uint);

     
    function getInterestRateByDmmTokenAddress(address dmmToken) external view returns (uint);

     
    function getExchangeRateByUnderlying(address underlyingToken) external view returns (uint);

     
    function getExchangeRate(address dmmToken) external view returns (uint);

     
    function getDmmTokenForUnderlying(address underlyingToken) external view returns (address);

     
    function getUnderlyingTokenForDmm(address dmmToken) external view returns (address);

     
    function isMarketEnabledByDmmTokenId(uint dmmTokenId) external view returns (bool);

     
    function isMarketEnabledByDmmTokenAddress(address dmmToken) external view returns (bool);

     
    function getTokenIdFromDmmTokenAddress(address dmmTokenAddress) external view returns (uint);

}

 

pragma solidity ^0.5.0;


 
interface IDmmToken {

     

    event Mint(address indexed minter, address indexed recipient, uint amount);
    event Redeem(address indexed redeemer, address indexed recipient, uint amount);
    event FeeTransfer(address indexed owner, address indexed recipient, uint amount);

    event TotalSupplyIncreased(uint oldTotalSupply, uint newTotalSupply);
    event TotalSupplyDecreased(uint oldTotalSupply, uint newTotalSupply);

    event OffChainRequestValidated(address indexed owner, address indexed feeRecipient, uint nonce, uint expiry, uint feeAmount);

     

     
    function controller() external view returns (IDmmController);

     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function decimals() external view returns (uint8);

     
    function minMintAmount() external view returns (uint);

     
    function minRedeemAmount() external view returns (uint);

     
    function activeSupply() external view returns (uint);

     
    function increaseTotalSupply(uint amount) external;

     
    function decreaseTotalSupply(uint amount) external;

     
    function depositUnderlying(uint underlyingAmount) external returns (bool);

     
    function withdrawUnderlying(uint underlyingAmount) external returns (bool);

     
    function exchangeRateLastUpdatedTimestamp() external view returns (uint);

     
    function exchangeRateLastUpdatedBlockNumber() external view returns (uint);

     
    function getCurrentExchangeRate() external view returns (uint);

     
    function nonceOf(address owner) external view returns (uint);

     
    function mint(uint amount) external returns (uint);

     
    function mintFromGaslessRequest(
        address owner,
        address recipient,
        uint nonce,
        uint expiry,
        uint amount,
        uint feeAmount,
        address feeRecipient,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint);

     
    function redeem(uint amount) external returns (uint);

     
    function redeemFromGaslessRequest(
        address owner,
        address recipient,
        uint nonce,
        uint expiry,
        uint amount,
        uint feeAmount,
        address feeRecipient,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint);

     
    function permit(
        address owner,
        address spender,
        uint nonce,
        uint expiry,
        bool allowed,
        uint feeAmount,
        address feeRecipient,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

     
    function transferFromGaslessRequest(
        address owner,
        address recipient,
        uint nonce,
        uint expiry,
        uint amount,
        uint feeAmount,
        address feeRecipient,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}

 

pragma solidity ^0.5.0;






 
contract ReferralTrackerProxy is Ownable {

    using SafeERC20 for IERC20;

    address public weth;

    event ProxyMint(address indexed minter, address indexed receiver, uint amount, uint underlyingAmount);
    event ProxyRedeem(address indexed redeemer, address indexed receiver, uint amount, uint underlyingAmount);

    constructor (address _weth) public {
        weth = _weth;
    }

    function() external {
        revert("NO_DEFAULT");
    }

    function mintViaEther(address mETH) public payable returns (uint) {
        require(
            IDmmEther(mETH).wethToken() == weth,
            "INVALID_TOKEN"
        );
        uint amount = IDmmEther(mETH).mintViaEther.value(msg.value)();
        IERC20(mETH).safeTransfer(msg.sender, amount);
        emit ProxyMint(msg.sender, msg.sender, amount, msg.value);
        return amount;
    }

    function mint(address mToken, uint underlyingAmount) public {
        address underlyingToken = IDmmToken(mToken).controller().getUnderlyingTokenForDmm(mToken);
        IERC20(underlyingToken).safeTransferFrom(_msgSender(), address(this), underlyingAmount);

        _checkApprovalAndIncrementIfNecessary(underlyingToken, mToken);

        uint amountMinted = IDmmToken(mToken).mint(underlyingAmount);
        IERC20(mToken).safeTransfer(_msgSender(), amountMinted);

        emit ProxyMint(_msgSender(), _msgSender(), amountMinted, underlyingAmount);
    }

    function mintFromGaslessRequest(
        address mToken,
        address owner,
        address recipient,
        uint nonce,
        uint expiry,
        uint amount,
        uint feeAmount,
        address feeRecipient,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint) {
        uint dmmAmount = IDmmToken(mToken).mintFromGaslessRequest(
            owner,
            recipient,
            nonce,
            expiry,
            amount,
            feeAmount,
            feeRecipient,
            v,
            r,
            s
        );

        emit ProxyMint(owner, recipient, dmmAmount, amount);
        return dmmAmount;
    }

    function redeem(address mToken, uint amount) public {
        IERC20(mToken).safeTransferFrom(_msgSender(), address(this), amount);

         
        uint underlyingAmountRedeemed = IDmmToken(mToken).redeem(amount);

        address underlyingToken = IDmmToken(mToken).controller().getUnderlyingTokenForDmm(mToken);
        IERC20(underlyingToken).safeTransfer(_msgSender(), underlyingAmountRedeemed);

        emit ProxyRedeem(_msgSender(), _msgSender(), amount, underlyingAmountRedeemed);
    }

    function redeemFromGaslessRequest(
        address mToken,
        address owner,
        address recipient,
        uint nonce,
        uint expiry,
        uint amount,
        uint feeAmount,
        address feeRecipient,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint) {
        uint underlyingAmount = IDmmToken(mToken).redeemFromGaslessRequest(
            owner,
            recipient,
            nonce,
            expiry,
            amount,
            feeAmount,
            feeRecipient,
            v,
            r,
            s
        );

        emit ProxyRedeem(owner, recipient, amount, underlyingAmount);
        return underlyingAmount;
    }

    function _checkApprovalAndIncrementIfNecessary(address token, address mToken) internal {
        uint allowance = IERC20(token).allowance(address(this), mToken);
        if (allowance != uint(- 1)) {
            IERC20(token).safeApprove(mToken, uint(- 1));
        }
    }

}

 

pragma solidity ^0.5.0;



contract ReferralTrackerProxyFactory is Ownable {

    address public weth;
    address[] public proxyContracts;

    event ProxyContractDeployed(address indexed proxyAddress);

    constructor(address _weth) public {
        weth = _weth;
    }

    function getProxyContracts() public view returns (address[] memory) {
        return getProxyContractsWithIndices(0, proxyContracts.length);
    }

     
    function getProxyContractsWithIndices(uint startIndex, uint endIndex) public view returns (address[] memory) {
        require(endIndex >= startIndex, "INVALID_INDICES");
        require(endIndex <= proxyContracts.length, "INVALID_END_INDEX");

        address[] memory retVal = new address[](endIndex - startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            retVal[i - startIndex] = proxyContracts[i];
        }
        return retVal;
    }

    function deployProxy() public onlyOwner returns (address) {
        ReferralTrackerProxy proxy = new ReferralTrackerProxy(weth);

        proxyContracts.push(address(proxy));
        proxy.transferOwnership(owner());

        emit ProxyContractDeployed(address(proxy));

        return address(proxy);
    }

}