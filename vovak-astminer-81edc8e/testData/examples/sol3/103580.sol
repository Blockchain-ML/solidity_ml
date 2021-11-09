pragma solidity 0.6.4;

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

contract MiningReward is Initializable {
    using SafeMath for uint256;

    using SafeERC20 for IERC20;

    bool internal _notEntered;

     
    address public rewardToken;

     
    address public admin;

     
    address public proposedAdmin;

     
    uint256 public datetime;

     
     
    struct Balance {
        uint256 amount;
    }

     
    address public coinAdmin;

     
    address public proposedCoinAdmin;

     
    mapping(address => Balance) public userBalance;

     
     
     
    event ProposeAdmin(address admin, address proposedAdmin);

     
     
     
    event ClaimAdmin(address oldAdmin, address newAdmin);

     
     
    event WithdrawRewardWithAmount(uint256 amount);

     
     
    event WithdrawReward(uint256 amount);

     
     
     
    event WithdrawRewardToAddress(address addr, uint256 amount);

     
     
     
    event WithdrawRewardToAddressWithAmount(address addr, uint256 amount);

     
     
     
    event ClaimReward(address addr, uint256 amount);

     
     
     
    event SetRewardToken(address oldToken, address newToken);

     
     
     
     
    event BatchSet(address[] accounts, uint256[] amounts, uint256 datetime);

     
     
     
    event Set(address account, uint256 amount);

     
     
     
    function initialize(address _admin, address _coinAdmin, address _rewardToken)
        public
        initializer
    {
        admin = _admin;
        coinAdmin = _coinAdmin;
        rewardToken = _rewardToken;
        _notEntered = true;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Admin required");
        _;
    }

    modifier onlyCoinAdmin {
        require(msg.sender == coinAdmin, "CoinAdmin required");
        _;
    }

    modifier nonReentrant() {
        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true;
    }

     
     
    function setRewardToken(address _rewardToken) public onlyCoinAdmin {
        address oldToken = rewardToken;
        rewardToken = _rewardToken;

        emit SetRewardToken(oldToken, rewardToken);
    }

     
     
    function proposeAdmin(address _proposedAdmin) public onlyAdmin {
        require(_proposedAdmin != address(0));
        proposedAdmin = _proposedAdmin;

        emit ProposeAdmin(admin, _proposedAdmin);
    }

     
    function claimAdmin() public {
        require(msg.sender == proposedAdmin, "ProposedAdmin required");
        address oldAdmin = admin;
        admin = proposedAdmin;
        proposedAdmin = address(0);

        emit ClaimAdmin(oldAdmin, admin);
    }

     
     
    function proposeCoinAdmin(address _proposedCoinAdmin) public onlyCoinAdmin {
        require(_proposedCoinAdmin != address(0));
        proposedCoinAdmin = _proposedCoinAdmin;

         
    }

     
    function claimCoinAdmin() public {
        require(msg.sender == proposedCoinAdmin, "proposedCoinAdmin required");
         
        coinAdmin = proposedCoinAdmin;
        proposedCoinAdmin = address(0);

         
    }

     
     
    function withdrawRewardWithAmount(uint256 amount) public onlyCoinAdmin {
        require(
            IERC20(rewardToken).balanceOf(address(this)) > 0,
            "No reward left"
        );
        require(amount > 0, "Invalid amount");
        IERC20(rewardToken).safeTransfer(admin, amount);

        emit WithdrawRewardWithAmount(amount);
    }

     
    function withdrawReward() public onlyCoinAdmin {
        require(
            IERC20(rewardToken).balanceOf(address(this)) > 0,
            "No reward left"
        );
        uint256 balance = checkRewardBalance();
        IERC20(rewardToken).safeTransfer(admin, balance);

        emit WithdrawReward(balance);
    }

     
     
    function withdrawRewardToAddress(address addr) public onlyCoinAdmin {
        require(
            IERC20(rewardToken).balanceOf(address(this)) > 0,
            "No reward left"
        );
        uint256 balance = checkRewardBalance();
        IERC20(rewardToken).safeTransfer(addr, balance);

        emit WithdrawRewardToAddress(addr, balance);
    }

     
     
     
    function withdrawRewardToAddressWithAmount(address addr, uint256 amount)
        public
        onlyCoinAdmin
    {
        require(
            IERC20(rewardToken).balanceOf(address(this)) > 0,
            "No reward left"
        );
        IERC20(rewardToken).safeTransfer(addr, amount);

        emit WithdrawRewardToAddressWithAmount(addr, amount);
    }

     
     
     
     
    function batchSet(
        address[] calldata accounts,
        uint256[] calldata amount,
        uint256 _datetime
    ) external onlyAdmin {
        require(_datetime > datetime, "Invalid time");
        uint256 userCount = accounts.length;
        require(userCount == amount.length, "Invalid input");
        for (uint256 i = 0; i < userCount; ++i) {
            userBalance[accounts[i]].amount = userBalance[accounts[i]]
                .amount
                .add(amount[i]);
        }
        datetime = _datetime;

        emit BatchSet(accounts, amount, _datetime);
    }

     
     
     
    function set(address account, uint256 amount) external onlyAdmin {
        userBalance[account].amount = amount;

        emit Set(account, amount);
    }

     
    function claimReward() public nonReentrant {
        uint256 claimAmount = userBalance[msg.sender].amount;
        require(claimAmount > 0, "No reward");
        require(
            checkRewardBalance() >= claimAmount,
            "Insufficient rewardToken"
        );
        userBalance[msg.sender].amount = 0;
        IERC20(rewardToken).safeTransfer(msg.sender, claimAmount);

        emit ClaimReward(msg.sender, claimAmount);
    }

     
    function checkBalance(address account) public view returns (uint256) {
        return userBalance[account].amount;
    }

     
    function checkRewardBalance() public view returns (uint256) {
        return IERC20(rewardToken).balanceOf(address(this));
    }
}