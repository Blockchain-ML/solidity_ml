 

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


interface IWeth {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

contract IERC20 {
    string public name;
    uint8 public decimals;
    string public symbol;
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function approve(address _spender, uint256 _value) public returns (bool);
    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract IWethERC20 is IWeth, IERC20 {}

contract Constants {

    uint256 internal constant WEI_PRECISION = 10**18;
    uint256 internal constant WEI_PERCENT_PRECISION = 10**20;

    uint256 internal constant DAYS_IN_A_YEAR = 365;
    uint256 internal constant ONE_MONTH = 2628000;  

    IWethERC20 public constant wethToken = IWethERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant bzrxTokenAddress = 0x56d811088235F11C8920698a204A5010a788f4b3;
    address public constant vbzrxTokenAddress = 0xB72B31907C1C95F3650b64b2469e08EdACeE5e8F;
}

 
library EnumerableBytes32Set {

    struct Bytes32Set {
         
         
        mapping (bytes32 => uint256) index;
        bytes32[] values;
    }

     
    function addAddress(Bytes32Set storage set, address addrvalue)
        internal
        returns (bool)
    {
        bytes32 value;
        assembly {
            value := addrvalue
        }
        return addBytes32(set, value);
    }

     
    function addBytes32(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        if (!contains(set, value)){
            set.index[value] = set.values.push(value);
            return true;
        } else {
            return false;
        }
    }

     
    function removeAddress(Bytes32Set storage set, address addrvalue)
        internal
        returns (bool)
    {
        bytes32 value;
        assembly {
            value := addrvalue
        }
        return removeBytes32(set, value);
    }

     
    function removeBytes32(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        if (contains(set, value)){
            uint256 toDeleteIndex = set.index[value] - 1;
            uint256 lastIndex = set.values.length - 1;

             
            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set.values[lastIndex];

                 
                set.values[toDeleteIndex] = lastValue;
                 
                set.index[lastValue] = toDeleteIndex + 1;  
            }

             
            delete set.index[value];

             
            set.values.pop();

            return true;
        } else {
            return false;
        }
    }

     
    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
        return set.index[value] != 0;
    }

     
    function containsAddress(Bytes32Set storage set, address addrvalue)
        internal
        view
        returns (bool)
    {
        bytes32 value;
        assembly {
            value := addrvalue
        }
        return set.index[value] != 0;
    }

     
    function enumerate(Bytes32Set storage set, uint256 start, uint256 count)
        internal
        view
        returns (bytes32[] memory output)
    {
        uint256 end = start + count;
        require(end >= start, "addition overflow");
        end = set.values.length < end ? set.values.length : end;
        if (end == 0 || start >= end) {
            return output;
        }

        output = new bytes32[](end-start);
        for (uint256 i = start; i < end; i++) {
            output[i-start] = set.values[i];
        }
        return output;
    }

     
    function length(Bytes32Set storage set)
        internal
        view
        returns (uint256)
    {
        return set.values.length;
    }

    
    function get(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
        return set.values[index];
    }

    
    function getAddress(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (address)
    {
        bytes32 value = set.values[index];
        address addrvalue;
        assembly {
            addrvalue := value
        }
        return addrvalue;
    }
}

 
contract ReentrancyGuard {

     
     
    uint256 internal constant REENTRANCY_GUARD_FREE = 1;

     
    uint256 internal constant REENTRANCY_GUARD_LOCKED = 2;

     
    uint256 internal reentrancyLock = REENTRANCY_GUARD_FREE;

     
    modifier nonReentrant() {
        require(reentrancyLock == REENTRANCY_GUARD_FREE, "nonReentrant");
        reentrancyLock = REENTRANCY_GUARD_LOCKED;
        _;
        reentrancyLock = REENTRANCY_GUARD_FREE;
    }
}

 
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
        require(isOwner(), "unauthorized");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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
         
        require(b != 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        return divCeil(a, b, "SafeMath: division by zero");
    }

     
    function divCeil(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
         
        require(b != 0, errorMessage);

        if (a == 0) {
            return 0;
        }
        uint256 c = ((a - 1) / b) + 1;

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min256(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a < _b ? _a : _b;
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

     
    function sendValue(address recipient, uint256 amount) internal {
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

contract LoanStruct {
    struct Loan {
        bytes32 id;                  
        bytes32 loanParamsId;        
        bytes32 pendingTradesId;     
        uint256 principal;           
        uint256 collateral;          
        uint256 startTimestamp;      
        uint256 endTimestamp;        
        uint256 startMargin;         
        uint256 startRate;           
        address borrower;            
        address lender;              
        bool active;                 
    }
}

contract LoanParamsStruct {
    struct LoanParams {
        bytes32 id;                  
        bool active;                 
        address owner;               
        address loanToken;           
        address collateralToken;     
        uint256 minInitialMargin;    
        uint256 maintenanceMargin;   
        uint256 maxLoanTerm;         
    }
}

contract OrderStruct {
    struct Order {
        uint256 lockedAmount;            
        uint256 interestRate;            
        uint256 minLoanTerm;             
        uint256 maxLoanTerm;             
        uint256 createdTimestamp;        
        uint256 expirationTimestamp;     
    }
}

contract LenderInterestStruct {
    struct LenderInterest {
        uint256 principalTotal;      
        uint256 owedPerDay;          
        uint256 owedTotal;           
        uint256 paidTotal;           
        uint256 updatedTimestamp;    
    }
}

contract LoanInterestStruct {
    struct LoanInterest {
        uint256 owedPerDay;          
        uint256 depositTotal;        
        uint256 updatedTimestamp;    
    }
}

contract Objects is
    LoanStruct,
    LoanParamsStruct,
    OrderStruct,
    LenderInterestStruct,
    LoanInterestStruct
{}

contract State is Constants, Objects, ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using EnumerableBytes32Set for EnumerableBytes32Set.Bytes32Set;

    address public priceFeeds;                                                           
    address public swapsImpl;                                                            

    mapping (bytes4 => address) public logicTargets;                                     

    mapping (bytes32 => Loan) public loans;                                              
    mapping (bytes32 => LoanParams) public loanParams;                                   

    mapping (address => mapping (bytes32 => Order)) public lenderOrders;                 
    mapping (address => mapping (bytes32 => Order)) public borrowerOrders;               

    mapping (bytes32 => mapping (address => bool)) public delegatedManagers;             

     
    mapping (address => mapping (address => LenderInterest)) public lenderInterest;      
    mapping (bytes32 => LoanInterest) public loanInterest;                               

     
    EnumerableBytes32Set.Bytes32Set internal logicTargetsSet;                            
    EnumerableBytes32Set.Bytes32Set internal activeLoansSet;                             

    mapping (address => EnumerableBytes32Set.Bytes32Set) internal lenderLoanSets;        
    mapping (address => EnumerableBytes32Set.Bytes32Set) internal borrowerLoanSets;      
    mapping (address => EnumerableBytes32Set.Bytes32Set) internal userLoanParamSets;     

    address public feesController;                                                       

    uint256 public lendingFeePercent = 10 ether;  
    mapping (address => uint256) public lendingFeeTokensHeld;                            
    mapping (address => uint256) public lendingFeeTokensPaid;                            

    uint256 public tradingFeePercent = 0.15 ether;  
    mapping (address => uint256) public tradingFeeTokensHeld;                            
    mapping (address => uint256) public tradingFeeTokensPaid;                            

    uint256 public borrowingFeePercent = 0.09 ether;  
    mapping (address => uint256) public borrowingFeeTokensHeld;                          
    mapping (address => uint256) public borrowingFeeTokensPaid;                          

    uint256 public protocolTokenHeld;                                                    
    uint256 public protocolTokenPaid;                                                    

    uint256 public affiliateFeePercent = 30 ether;  

    mapping (address => uint256) public liquidationIncentivePercent;                     

    mapping (address => address) public loanPoolToUnderlying;                            
    mapping (address => address) public underlyingToLoanPool;                            
    EnumerableBytes32Set.Bytes32Set internal loanPoolsSet;                               

    mapping (address => bool) public supportedTokens;                                    

    uint256 public maxDisagreement = 5 ether;                                            

    uint256 public sourceBufferPercent = 5 ether;                                        

    uint256 public maxSwapSize = 1500 ether;                                             


    function _setTarget(
        bytes4 sig,
        address target)
        internal
    {
        logicTargets[sig] = target;

        if (target != address(0)) {
            logicTargetsSet.addBytes32(bytes32(sig));
        } else {
            logicTargetsSet.removeBytes32(bytes32(sig));
        }
    }
}

contract bZxProtocol is State {

    function()
        external
        payable
    {
        if (gasleft() <= 2300) {
            return;
        }

        address target = logicTargets[msg.sig];
        require(target != address(0), "target not active");

        bytes memory data = msg.data;
        assembly {
            let result := delegatecall(gas, target, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    function replaceContract(
        address target)
        external
        onlyOwner
    {
        (bool success,) = target.delegatecall(abi.encodeWithSignature("initialize(address)", target));
        require(success, "setup failed");
    }

    function setTargets(
        string[] calldata sigsArr,
        address[] calldata targetsArr)
        external
        onlyOwner
    {
        require(sigsArr.length == targetsArr.length, "count mismatch");

        for (uint256 i = 0; i < sigsArr.length; i++) {
            _setTarget(bytes4(keccak256(abi.encodePacked(sigsArr[i]))), targetsArr[i]);
        }
    }

    function getTarget(
        string calldata sig)
        external
        view
        returns (address)
    {
        return logicTargets[bytes4(keccak256(abi.encodePacked(sig)))];
    }
}