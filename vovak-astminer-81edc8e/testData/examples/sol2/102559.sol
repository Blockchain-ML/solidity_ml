 

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

 

pragma solidity 0.5.2;




 
contract Wrapper is Ownable {
  using SafeMath for uint256;

  function transferWithFee(address _token, address _recipient, uint256 _amount, address _feeRecipient, uint256 _feeAmount) public {
    uint256 totalAmount = _amount.add(_feeAmount);
    require(IERC20(_token).transferFrom(msg.sender, address(this), totalAmount), "transferWithFee/in");
    require(IERC20(_token).transfer(_feeRecipient, _feeAmount), "transferWithFee/fee");
    require(IERC20(_token).transfer(_recipient, _amount), "transferWithFee/transfer");
  }

  function transferAndCallWithFee(address _token, address _recipient, uint256 _amount, address _feeRecipient, uint256 _feeAmount, bytes memory _data) public {
    uint256 totalAmount = _amount.add(_feeAmount);
    require(IERC20(_token).transferFrom(msg.sender, address(this), totalAmount), "transferWithFee/in");
    require(IERC20(_token).transfer(_feeRecipient, _feeAmount), "transferWithFee/fee");
    require(IERC20(_token).approve(_recipient, _amount), "transferWithFee/approve");
    (bool success,) = _recipient.call(_data);
    require (success, "transferWithFee/call");
  }

  function approveContractAndCallAnotherContract(address _token, uint256 _amount, address _contractToApprove, address _contractToCall, bytes memory _data) public {
    require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "approveContractAndCallAnotherContract/in");
    require(IERC20(_token).approve(_contractToApprove, _amount), "approveContractAndCallAnotherContract/approve");
    (bool success,) = _contractToCall.call.value(0)(_data);
    require (success, "approveContractAndCallAnotherContract/call");
  }
}