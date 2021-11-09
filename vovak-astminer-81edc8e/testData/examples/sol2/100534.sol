 

 


 

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

 

pragma solidity 0.5.16;

 




 
contract PaymentHandler {
	using SafeERC20 for IERC20;

	 
	bool public initialized = false;

	 
	PaymentMaster public master;

	 
	function initialize(PaymentMaster _master) public {
		require(initialized == false, 'Contract is already initialized');
		initialized = true;
		master = _master;
	}

	 
	function getMasterAddress() public view returns (address) {
		return address(master);
	}

	 
	function() external payable {
		 
		address payable ownerAddress = address(uint160(master.owner()));

		 
		Address.sendValue(ownerAddress, msg.value);

		 
		master.firePaymentReceivedEvent(address(this), msg.sender, msg.value);
	}

	 
	function sweepTokens(IERC20 token) public {
		 
		address ownerAddress = master.owner();

		 
		uint balance = token.balanceOf(address(this));

		 
		token.safeTransfer(ownerAddress, balance);
	}

}

 

pragma solidity 0.5.16;

contract Proxy {
     
     
    constructor(address contractLogic) public {
         
        assembly {  
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, contractLogic)
        }
    }

    function() external payable {
        assembly {  
            let contractLogic := sload(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7)
            let ptr := mload(0x40)
            calldatacopy(ptr, 0x0, calldatasize)
            let success := delegatecall(gas, contractLogic, ptr, calldatasize, 0, 0)
            let retSz := returndatasize
            returndatacopy(ptr, 0, retSz)
            switch success
            case 0 {
                revert(ptr, retSz)
            }
            default {
                return(ptr, retSz)
            }
        }
    }
}

 

pragma solidity 0.5.16;






 
contract PaymentMaster is Ownable {
	using SafeERC20 for IERC20;

	 
	address public handlerLogicAddress ;

	 
  address[] public handlerList;

	 
	mapping(address => bool) public handlerMap;

	 
	event HandlerCreated(address indexed _addr);
	event EthPaymentReceived(address indexed _to, address indexed _from, uint256 _amount);

	 
	constructor() public {
		deployHandlerLogic();
	}

	 
	function deployHandlerLogic() internal {
		 
		PaymentHandler createdHandler = new PaymentHandler();

		 
		createdHandler.initialize(this);

		 
		handlerLogicAddress = address(createdHandler);
	}

	 
	function deployNewHandler() public {
		 
		Proxy createdProxy = new Proxy(handlerLogicAddress);

		 
		PaymentHandler proxyHandler = PaymentHandler(address(createdProxy));

		 
		proxyHandler.initialize(this);

		 
		handlerList.push(address(createdProxy));
		handlerMap[address(createdProxy)] = true;

		 
		emit HandlerCreated(address(createdProxy));
	}

	 
	function getHandlerListLength() public view returns (uint) {
		return handlerList.length;
	}

	 
	function firePaymentReceivedEvent(address to, address from, uint256 amount) public {
		 
		require(handlerMap[msg.sender], "Only payment handlers are allowed to trigger payment events.");

		 
		emit EthPaymentReceived(to, from, amount);
	}

	 
	function multiHandlerSweep(address[] memory handlers, IERC20 tokenContract) public {
		for (uint i = 0; i < handlers.length; i++) {

			 
			require(handlerMap[handlers[i]], "Only payment handlers are valid sweep targets.");

			 
			PaymentHandler(address(uint160(handlers[i]))).sweepTokens(tokenContract);
		}
	}

	 
	function sweepTokens(IERC20 token) public {
		 
		uint balance = token.balanceOf(address(this));

		 
		token.safeTransfer(this.owner(), balance);
	}
}


 

 

 
 
 
 
 
 

 
 

 
 
 
 
 
 
 