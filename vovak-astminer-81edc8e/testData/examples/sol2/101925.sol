 
 

pragma solidity ^0.6.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);
    
    function decimals() external view returns (uint8);

     
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

 

pragma solidity ^0.6.6;

 
 
 
 
 

contract StabilizeTreasuryFurnace is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
     
    address public stbzAddress;  
    address public operatorAddress;  
    IERC20 private _stabilizeT;  
    address[] private activeTokens;  
    address[] public furnaceList;  

     
    event TreasuryBurn(address indexed user, uint256 amount);

    constructor(
        address _stbz,
        address _operator
    ) public {
        stbzAddress = _stbz;
        operatorAddress = _operator;
        _stabilizeT = IERC20(stbzAddress);
        initialTokens();
        initialFurnaces();
    }
    
     
    function initialTokens() internal {
         
         
        
         
        activeTokens.push(address(0x6B175474E89094C44Da98b954EedeAC495271d0F));  
        activeTokens.push(address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));  
        activeTokens.push(address(0xdAC17F958D2ee523a2206206994597C13D831ec7));  
        activeTokens.push(address(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51));  
    }
    
    function initialFurnaces() internal {
         
         
         
        
         
         
    }

    
     
    function circulatingSupply() public view returns (uint256) {
        if(_stabilizeT.totalSupply() == 0){
            return 0;
        }else{
             
            uint256 total = _stabilizeT.totalSupply().sub(_stabilizeT.balanceOf(operatorAddress)).sub(_stabilizeT.balanceOf(address(this)));
             
            if(furnaceList.length > 0){
                for(uint256 i = 0; i < furnaceList.length; i++){
                    total = total.sub(_stabilizeT.balanceOf(furnaceList[i]));
                }
            }
            return total;
        }
    }
    
    function totalTokens() external view returns (uint256) {
        return activeTokens.length;
    }
    
    function getTokenAddress(uint256 _pos) external view returns (address) {
        return activeTokens[_pos];
    }
    
    function getTokenBalance(uint256 _pos) external view returns (uint256) {
        IERC20 token = IERC20(activeTokens[_pos]);
        return token.balanceOf(address(this));
    }

    function claim(uint256 amount) external {
        require(amount > 0, "Cannot claim with 0 amount");
        require(activeTokens.length > 0, "There are no redeemable tokens in the treasury");
        uint256 supply = circulatingSupply();  
        require(supply > 0, "There are no circulating tokens");
        _stabilizeT.safeTransferFrom(_msgSender(), address(this), amount);
        
         
        uint256 i = 0;
        uint256 transferAmount = 0;
        for(i = 0; i < activeTokens.length; i++){
            IERC20 token = IERC20(activeTokens[i]);
            transferAmount = amount.mul(token.balanceOf(address(this))).div(supply);
            if(transferAmount > 0){
                token.safeTransfer(_msgSender(), transferAmount);
            }
        }
        
        emit TreasuryBurn(_msgSender(), amount);
    }
    
     
    
     
     
    
    uint256 private _timelockStart;  
    uint256 private _timelockType;  
    uint256 constant _timelockDuration = 86400;  
    
     
    address private _timelock_address;
    
    modifier timelockConditionsMet(uint256 _type) {
        require(_timelockType == _type, "Timelock not acquired for this function");
        _timelockType = 0;  
        if(_stabilizeT.balanceOf(address(this)) > 0){
             
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
     
   
     
     
    function startAddNewToken(address _address) external onlyGovernance {
         
        require(_address != stbzAddress, "Cannot add token that is the same as the burnt tokens");
        _timelockStart = now;
        _timelockType = 2;
        _timelock_address = _address;
    }
    
    function finishAddNewToken() public onlyGovernance timelockConditionsMet(2) {
         
        activeTokens.push(_timelock_address);
    }
     
    
     
     
    function startRemoveToken(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 3;
        _timelock_address = _address;
    }
    
    function finishRemoveToken() external onlyGovernance timelockConditionsMet(3) {
        uint256 length = activeTokens.length;
        for(uint256 i = 0; i < length; i++){
            if(activeTokens[i] == _timelock_address){
                 
                for(uint256 i2 = i; i2 < length-1; i2++){
                    activeTokens[i2] = activeTokens[i2 + 1];  
                }
                activeTokens.pop();  
                break;
            }
        }
    }
     
    
     
     
    function startAddNewFurnace(address _address) external onlyGovernance {
         
        require(_address != stbzAddress, "Cannot add STBZ address as a furnace");
        _timelockStart = now;
        _timelockType = 4;
        _timelock_address = _address;
    }
    
    function finishAddNewFurnace() public onlyGovernance timelockConditionsMet(4) {
         
        furnaceList.push(_timelock_address);
    }
     
}