 

 


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


 
 


 
contract Accrual {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public accrualToken;

    uint256 public accruedIndex = 0;  
    uint256 public accruedBalance = 0;  

    mapping(address => uint256) public supplyIndex;

    constructor(
        address _accrualToken
    )
        public
    {
        accrualToken = IERC20(_accrualToken);
    }

    function getUserBalance(
        address owner
    )
        public
        view
        returns (uint256);

    function getTotalBalance()
        public
        view
        returns (uint256);

    function updateFees()
        public
    {
        if (getTotalBalance() == 0) {
            return;
        }

        uint256 contractBalance = accrualToken.balanceOf(address(this));

        if (contractBalance == 0) {
            return;
        }

         
        uint256 difference = contractBalance.sub(accruedBalance);

        if (difference == 0) {
            return;
        }

         
        uint256 ratio = difference.mul(1e18).div(getTotalBalance());

        if (ratio == 0) {
            return;
        }

         
        accruedIndex = accruedIndex.add(ratio);

         
        accruedBalance = contractBalance;
    }

    function claimFees()
        public
    {
        claimFor(msg.sender);
    }

    function claimFor(
        address recipient
    )
        public
    {
        updateFees();

        uint256 userBalance = getUserBalance(recipient);

        if (userBalance == 0) {
            supplyIndex[recipient] = accruedIndex;
            return;
        }

         
        uint256 existingIndex = supplyIndex[recipient];

         
        supplyIndex[recipient] = accruedIndex;

         
         
        uint256 delta = accruedIndex.sub(existingIndex);

        require(
            delta > 0,
            "TokenAccrual: no tokens available to claim"
        );

         
        uint256 share = userBalance.mul(delta).div(1e18);

         
        accrualToken.safeTransfer(recipient, share);

         
        accruedBalance = accrualToken.balanceOf(address(this));
    }

}

 


contract AddressAccrual is Ownable, Accrual {

    uint256 public _supply = 0;

    mapping(address => uint256) public balances;

    constructor(
        address _claimableToken
    )
        public
        Accrual(_claimableToken)
    {}

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _supply;
    }

    function balanceOf(
        address account
    )
        public
        view
        returns (uint256)
    {
        return balances[account];
    }

    function getTotalBalance()
        public
        view
        returns (uint256)
    {
        return totalSupply();
    }

    function getUserBalance(
        address owner
    )
        public
        view
        returns (uint256)
    {
        return balanceOf(owner);
    }

    function increaseShare(
        address to,
        uint256 value
    )
        public
        onlyOwner
    {
        require(to != address(0), "Cannot add zero address");

        balances[to] = balances[to].add(value);
        _supply = _supply.add(value);
    }

    function decreaseShare(
        address from,
        uint256 value
    )
        public
        onlyOwner
    {
        require(from != address(0), "Cannot remove zero address");

        balances[from] = balances[from].sub(value);
        _supply = _supply.sub(value);
    }

}