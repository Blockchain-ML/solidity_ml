 
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

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        uint256 size;
         
        assembly { size := extcodesize(account) }
        return size > 0;
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

 
contract TokenVesting is Ownable {
     
     
     
     
     

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokensReleased(address holder, address token, uint256 amount);

     
    IERC20 public _token;

    bool private _revocable;

    uint256 private _totalReleased = 0;

    mapping (address => uint256) private _balances;

    mapping (address => uint256) private _released;

    mapping (address =>  bool[]) private _vested;

    bool[] private _baseVested;

    uint256[] private _schedule;
    
    uint256 private _amountPerSchedule;

     
    constructor (IERC20 token, uint256[] memory schedule, uint256 amountPerSchedule, bool revocable) public {

        require(schedule.length <= 255);
        
        bool[] memory baseVested = new bool[](schedule.length);  
        
        _token = token;

        _schedule = schedule;
        
        _amountPerSchedule = amountPerSchedule;
        
        _baseVested = baseVested;

        _revocable = revocable;
    }

     
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

     
    function revocable() public view returns (bool) {
        return _revocable;
    }

     
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

     
    function released(address holder) public view returns (uint256) {
        return _released[holder];
    }

     
    function vested(address holder, uint idx) public view returns (bool) {
        return _vested[holder][idx];
    }

     
    function setBalance(address holder, uint256 amount) public onlyOwner {
        require(holder != address(0), "ERC20: setting to the zero address");

        _balances[holder] = amount;

        _vested[holder] = _baseVested;
    }

     
    function revoke(uint256 amount) public onlyOwner {
        require(_revocable, "TokenVesting: cannot revoke");

        _token.safeTransfer(owner(), amount);
    }

     
    function vestedAmount(uint256 ts, address holder) public view returns (uint256) {
        int8 unreleasedIdx = _releasableIdx(ts, holder);
        if (unreleasedIdx >= 0) {
            return _amountPerSchedule;
        } else {
            return 0;
        }

    }

     
    function release() public {
        int8 unreleasedIdx = _releasableIdx(block.timestamp, _msgSender());

        require(unreleasedIdx >= 0, "TokenVesting: no tokens are due");

        uint256 unreleasedAmount = _amountPerSchedule;

        _token.safeTransfer(_msgSender(), unreleasedAmount);

        _vested[_msgSender()][uint(unreleasedIdx)] = true;
        _released[_msgSender()] = _released[_msgSender()].add(unreleasedAmount);
        _totalReleased = _totalReleased.add(unreleasedAmount);

        emit TokensReleased(_msgSender(), address(_token), unreleasedAmount);
    }

     
    function _releasableIdx(uint256 ts, address holder) private view returns (int8) {
        if (_vested[holder].length == 0) {
            return -1;
        }

        for (uint8 i = 0; i < _schedule.length; i++) {
            if (ts > _schedule[i] && _vested[holder][i] == false) {
                return int8(i);
            }
        }

        return -1;
    }
}