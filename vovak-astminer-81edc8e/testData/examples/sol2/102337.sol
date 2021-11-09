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









 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
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


contract DelayedWithdraw is Ownable {
    using SafeMath for uint256;

    uint256 constant delay = 7 days;

    Withdrawal private withdrawal;
    IERC20 ctsi;


    struct Withdrawal {
        address receiver;
        uint256 amount;
        uint256 timestamp;
    }


     
     
    constructor(IERC20 _ctsi) public {
        ctsi = _ctsi;
    }

     
    function getWithdrawalAmount() public view returns (uint256) {
        return withdrawal.amount;
    }

     
    function getWithdrawalReceiver() public view returns (address) {
        return withdrawal.receiver;
    }

     
    function getWithdrawalTimestamp() public view returns (uint256) {
        return withdrawal.timestamp;
    }

     
     
     
    function requestWithdrawal(
        address _receiver,
        uint256 _amount
    )
        public
        onlyOwner()
        returns (bool)
    {
        require(_amount > 0, "withdrawal amount has to be bigger than 0");

        uint256 newAmount = withdrawal.amount.add(_amount);

        require(
            newAmount <= ctsi.balanceOf(address(this)),
            "Not enough tokens in the contract for this Withdrawal request"
        );
        withdrawal.receiver = _receiver;
        withdrawal.amount = newAmount;
        withdrawal.timestamp = block.timestamp;

        emit WithdrawRequested(_receiver, newAmount, block.timestamp);

        return true;
    }

     
    function finalizeWithdraw() public onlyOwner returns (bool) {
        uint256 amount = withdrawal.amount;
        require(
            withdrawal.timestamp.add(delay) <= block.timestamp,
            "Withdrawal is not old enough to be finalized"
        );
        require(amount > 0, "There are no active withdrawal requests");

        withdrawal.amount = 0;
        ctsi.transfer(withdrawal.receiver, amount);

        emit WithdrawFinalized(withdrawal.receiver, amount);
        return true;
    }

     
    function cancelWithdrawal() public onlyOwner returns (bool) {
        require(withdrawal.amount > 0, "There are no active withdrawal requests");

        emit WithdrawCanceled(withdrawal.receiver, withdrawal.amount, block.timestamp);

        withdrawal.amount = 0;

        return true;
    }

     
    event WithdrawRequested(address _receiver, uint256 _amount, uint256 _timestamp);
    event WithdrawCanceled(address _receiver, uint256 _amount, uint256 _timestamp);
    event WithdrawFinalized(address _receiver, uint256 _amount);
}