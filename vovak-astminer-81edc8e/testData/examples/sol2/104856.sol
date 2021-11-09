 

 

pragma solidity 0.6.2;

 
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

 

 

pragma solidity 0.6.2;


 
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

 

 

pragma solidity 0.6.2;

 
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

 

 

pragma solidity 0.6.2;

 
contract ReentrancyGuard {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }
}

 

 
 
 
pragma solidity 0.6.2;




contract FeeDistributor is ReentrancyGuard {
  using SafeMath for uint256;
  address public brainAddress = 0xEA3cB156745a8d281A5fC174186C976F2dD04c2E;

  constructor(address _brain, address _farm, address _art) public {
    brainAddress = _brain;
    farmAddress = _farm;
    artistFundAddress = _art;
  }

   

  address public burnAddress = address(1);
  uint256 public burnRatio = 1250;

  address public devAddress1 = 0x08d19746Ee0c0833FC5EAF98181eB91DAEEb9abB;
  uint256 public devRatio1 = 500;
  
  address public devAddress2 = 0xB03832FE8f62b27F5e278F0eEe65b5Ace875D984;
  uint256 public devRatio2 = 500;

  address public artistFundAddress;
  uint256 public artistFundRatio = 250;

  address public farmAddress;
  uint256 public farmRatio = 7500;

  function pendingFarmAmount() public view returns (uint256) {
    uint256 balance = IERC20(brainAddress).balanceOf(address(this));
    if (balance > 0) {
      uint256 fraction = balance.div(10000);
      if (fraction > 0) {
        return fraction.mul(farmRatio);
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

   
  function processTransfer() public nonReentrant {
    uint256 balance = IERC20(brainAddress).balanceOf(address(this));
    if (balance > 0) {
      uint256 fraction = balance.div(10000);
      if (fraction > 0) {
          
        IERC20(brainAddress).transfer(burnAddress, fraction.mul(burnRatio));
        
        IERC20(brainAddress).transfer(artistFundAddress, fraction.mul(artistFundRatio));
        
        IERC20(brainAddress).transfer(devAddress1, fraction.mul(devRatio1));
        
        IERC20(brainAddress).transfer(devAddress2, fraction.mul(devRatio2));
        
        IERC20(brainAddress).transfer(farmAddress, fraction.mul(farmRatio));
      }
    }
  }
}