 

 


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

 


pragma solidity ^0.6.0;

 
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

 

pragma solidity 0.6.10;


interface RegistryClone {
    function syncAttributeValue(
        address _who,
        bytes32 _attribute,
        uint256 _value
    ) external;
}

contract Registry {
    struct AttributeData {
        uint256 value;
        bytes32 notes;
        address adminAddr;
        uint256 timestamp;
    }

     
    address public owner;
    address public pendingOwner;
    bool initialized;

     
     
     
     
     
     
    mapping(address => mapping(bytes32 => AttributeData)) attributes;
     
     
    bytes32 constant WRITE_PERMISSION = keccak256("canWriteTo-");
    mapping(bytes32 => RegistryClone[]) subscribers;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SetAttribute(address indexed who, bytes32 attribute, uint256 value, bytes32 notes, address indexed adminAddr);
    event SetManager(address indexed oldManager, address indexed newManager);
    event StartSubscription(bytes32 indexed attribute, RegistryClone indexed subscriber);
    event StopSubscription(bytes32 indexed attribute, RegistryClone indexed subscriber);

     
     
     
    function confirmWrite(bytes32 _attribute, address _admin) internal view returns (bool) {
        return (_admin == owner || hasAttribute(_admin, keccak256(abi.encodePacked(WRITE_PERMISSION ^ _attribute))));
    }

     
    function setAttribute(
        address _who,
        bytes32 _attribute,
        uint256 _value,
        bytes32 _notes
    ) public {
        require(confirmWrite(_attribute, msg.sender));
        attributes[_who][_attribute] = AttributeData(_value, _notes, msg.sender, block.timestamp);
        emit SetAttribute(_who, _attribute, _value, _notes, msg.sender);

        RegistryClone[] storage targets = subscribers[_attribute];
        uint256 index = targets.length;
        while (index-- > 0) {
            targets[index].syncAttributeValue(_who, _attribute, _value);
        }
    }

    function subscribe(bytes32 _attribute, RegistryClone _syncer) external onlyOwner {
        subscribers[_attribute].push(_syncer);
        emit StartSubscription(_attribute, _syncer);
    }

    function unsubscribe(bytes32 _attribute, uint256 _index) external onlyOwner {
        uint256 length = subscribers[_attribute].length;
        require(_index < length);
        emit StopSubscription(_attribute, subscribers[_attribute][_index]);
        subscribers[_attribute][_index] = subscribers[_attribute][length - 1];
        subscribers[_attribute].pop();
    }

    function subscriberCount(bytes32 _attribute) public view returns (uint256) {
        return subscribers[_attribute].length;
    }

    function setAttributeValue(
        address _who,
        bytes32 _attribute,
        uint256 _value
    ) public {
        require(confirmWrite(_attribute, msg.sender));
        attributes[_who][_attribute] = AttributeData(_value, "", msg.sender, block.timestamp);
        emit SetAttribute(_who, _attribute, _value, "", msg.sender);
        RegistryClone[] storage targets = subscribers[_attribute];
        uint256 index = targets.length;
        while (index-- > 0) {
            targets[index].syncAttributeValue(_who, _attribute, _value);
        }
    }

     
    function hasAttribute(address _who, bytes32 _attribute) public view returns (bool) {
        return attributes[_who][_attribute].value != 0;
    }

     
    function getAttribute(address _who, bytes32 _attribute)
        public
        view
        returns (
            uint256,
            bytes32,
            address,
            uint256
        )
    {
        AttributeData memory data = attributes[_who][_attribute];
        return (data.value, data.notes, data.adminAddr, data.timestamp);
    }

    function getAttributeValue(address _who, bytes32 _attribute) public view returns (uint256) {
        return attributes[_who][_attribute].value;
    }

    function getAttributeAdminAddr(address _who, bytes32 _attribute) public view returns (address) {
        return attributes[_who][_attribute].adminAddr;
    }

    function getAttributeTimestamp(address _who, bytes32 _attribute) public view returns (uint256) {
        return attributes[_who][_attribute].timestamp;
    }

    function syncAttribute(
        bytes32 _attribute,
        uint256 _startIndex,
        address[] calldata _addresses
    ) external {
        RegistryClone[] storage targets = subscribers[_attribute];
        uint256 index = targets.length;
        while (index-- > _startIndex) {
            RegistryClone target = targets[index];
            for (uint256 i = _addresses.length; i-- > 0; ) {
                address who = _addresses[i];
                target.syncAttributeValue(who, _attribute, attributes[who][_attribute].value);
            }
        }
    }

    function reclaimEther(address payable _to) external onlyOwner {
        _to.transfer(address(this).balance);
    }

    function reclaimToken(IERC20 token, address _to) external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(_to, balance);
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }

     
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner);
        _;
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        pendingOwner = newOwner;
    }

     
    function claimOwnership() public onlyPendingOwner {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}

 

pragma solidity 0.6.10;


 
contract ProxyStorage {
    bool initalized;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(uint144 => uint256) attributes;  

    address owner_;
    address pendingOwner_;

     
}

 

pragma solidity 0.6.10;

 
library ValSafeMath {
    function add(
        uint256 a,
        uint256 b,
        string memory overflowMessage
    ) internal pure returns (uint256 result) {
        result = a + b;
        require(result >= a, overflowMessage);
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory underflowMessage
    ) internal pure returns (uint256 result) {
        require(b <= a, underflowMessage);
        result = a - b;
    }

    function mul(
        uint256 a,
        uint256 b,
        string memory overflowMessage
    ) internal pure returns (uint256 result) {
        if (a == 0) {
            return 0;
        }
        result = a * b;
        require(result / a == b, overflowMessage);
    }

    function div(
        uint256 a,
        uint256 b,
        string memory divideByZeroMessage
    ) internal pure returns (uint256 result) {
        require(b > 0, divideByZeroMessage);
        result = a / b;
    }
}

 

pragma solidity 0.6.10;



 
 
contract ModularBasicToken is ProxyStorage {
    using ValSafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function _addBalance(address _who, uint256 _value) internal returns (uint256 priorBalance) {
        priorBalance = balanceOf[_who];
        balanceOf[_who] = priorBalance.add(_value, "balance overflow");
    }

    function _subBalance(address _who, uint256 _value) internal returns (uint256 result) {
        result = balanceOf[_who].sub(_value, "insufficient balance");
        balanceOf[_who] = result;
    }

    function _setBalance(address _who, uint256 _value) internal {
        balanceOf[_who] = _value;
    }
}

 
contract ModularStandardToken is ModularBasicToken {
    using ValSafeMath for uint256;
    uint256 constant INFINITE_ALLOWANCE = 0xfe00000000000000000000000000000000000000000000000000000000000000;

    event Approval(address indexed owner, address indexed spender, uint256 value);

     
    function approve(address _spender, uint256 _value) public returns (bool) {
        _approveAllArgs(_spender, _value, msg.sender);
        return true;
    }

    function _approveAllArgs(
        address _spender,
        uint256 _value,
        address _tokenHolder
    ) internal {
        _setAllowance(_tokenHolder, _spender, _value);
        emit Approval(_tokenHolder, _spender, _value);
    }

     
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        _increaseApprovalAllArgs(_spender, _addedValue, msg.sender);
        return true;
    }

    function _increaseApprovalAllArgs(
        address _spender,
        uint256 _addedValue,
        address _tokenHolder
    ) internal {
        _addAllowance(_tokenHolder, _spender, _addedValue);
        emit Approval(_tokenHolder, _spender, allowance[_tokenHolder][_spender]);
    }

     
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        _decreaseApprovalAllArgs(_spender, _subtractedValue, msg.sender);
        return true;
    }

    function _decreaseApprovalAllArgs(
        address _spender,
        uint256 _subtractedValue,
        address _tokenHolder
    ) internal {
        uint256 oldValue = allowance[_tokenHolder][_spender];
        uint256 newValue;
        if (_subtractedValue > oldValue) {
            newValue = 0;
        } else {
            newValue = oldValue - _subtractedValue;
        }
        _setAllowance(_tokenHolder, _spender, newValue);
        emit Approval(_tokenHolder, _spender, newValue);
    }

    function _addAllowance(
        address _who,
        address _spender,
        uint256 _value
    ) internal {
        allowance[_who][_spender] = allowance[_who][_spender].add(_value, "allowance overflow");
    }

    function _subAllowance(
        address _who,
        address _spender,
        uint256 _value
    ) internal returns (uint256 newAllowance) {
        newAllowance = allowance[_who][_spender].sub(_value, "insufficient allowance");
        if (newAllowance < INFINITE_ALLOWANCE) {
            allowance[_who][_spender] = newAllowance;
        }
    }

    function _setAllowance(
        address _who,
        address _spender,
        uint256 _value
    ) internal {
        allowance[_who][_spender] = _value;
    }
}

 

pragma solidity 0.6.10;


abstract contract RegistrySubscriber is ProxyStorage {
     
    bytes32 constant PASSED_KYCAML = "hasPassedKYC/AML";
    bytes32 constant IS_DEPOSIT_ADDRESS = "isDepositAddress";
    bytes32 constant BLACKLISTED = 0x6973426c61636b6c697374656400000000000000000000000000000000000000;
    bytes32 constant REGISTERED_CONTRACT = 0x697352656769737465726564436f6e7472616374000000000000000000000000;

     
    uint256 constant ACCOUNT_BLACKLISTED = 0xff00000000000000000000000000000000000000000000000000000000000000;
    uint256 constant ACCOUNT_BLACKLISTED_INV = 0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 constant ACCOUNT_KYC = 0x00ff000000000000000000000000000000000000000000000000000000000000;
    uint256 constant ACCOUNT_KYC_INV = 0xff00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 constant ACCOUNT_ADDRESS = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;
    uint256 constant ACCOUNT_ADDRESS_INV = 0xffffffffffffffffffffffff0000000000000000000000000000000000000000;
    uint256 constant ACCOUNT_HOOK = 0x0000ff0000000000000000000000000000000000000000000000000000000000;
    uint256 constant ACCOUNT_HOOK_INV = 0xffff00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    function registry() public virtual view returns (Registry);

    modifier onlyRegistry {
        require(msg.sender == address(registry()));
        _;
    }

     
    function syncAttributeValue(
        address _who,
        bytes32 _attribute,
        uint256 _value
    ) public onlyRegistry {
        uint144 who = uint144(uint160(_who) >> 20);
        uint256 prior = attributes[who];
        if (prior == 0) {
            prior = uint256(_who);
        }
        if (_attribute == IS_DEPOSIT_ADDRESS) {
            attributes[who] = (prior & ACCOUNT_ADDRESS_INV) | uint256(address(_value));
        } else if (_attribute == BLACKLISTED) {
            if (_value != 0) {
                attributes[who] = prior | ACCOUNT_BLACKLISTED;
            } else {
                attributes[who] = prior & ACCOUNT_BLACKLISTED_INV;
            }
        } else if (_attribute == PASSED_KYCAML) {
            if (_value != 0) {
                attributes[who] = prior | ACCOUNT_KYC;
            } else {
                attributes[who] = prior & ACCOUNT_KYC_INV;
            }
        } else if (_attribute == REGISTERED_CONTRACT) {
            if (_value != 0) {
                attributes[who] = prior | ACCOUNT_HOOK;
            } else {
                attributes[who] = prior & ACCOUNT_HOOK_INV;
            }
        }
    }
}

 

pragma solidity 0.6.10;

interface TrueCoinReceiver {
    function tokenFallback(address from, uint256 value) external;
}

 

pragma solidity 0.6.10;




abstract contract ValTokenWithHook is ModularStandardToken, RegistrySubscriber {
    event Burn(address indexed from, uint256 indexed amount);
    event Mint(address indexed to, uint256 indexed amount);

    function _resolveRecipient(address _to) internal view returns (address to, bool hook) {
        uint256 flags = (attributes[uint144(uint160(_to) >> 20)]);
        if (flags == 0) {
            to = _to;
             
            hook = false;
        } else {
            to = address(flags);
            hook = (flags & ACCOUNT_HOOK) != 0;
        }
    }

    modifier resolveSender(address _from) {
        uint256 flags = (attributes[uint144(uint160(_from) >> 20)]);
        address from = address(flags);
        if (from != address(0)) {
            require(from == _from, "account collision");
        }
        _;
    }

    function _transferFromAllArgs(
        address _from,
        address _to,
        uint256 _value,
        address _spender
    ) internal virtual {
        _subAllowance(_from, _spender, _value);
        _transferAllArgs(_from, _to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool) {
        _transferFromAllArgs(_from, _to, _value, msg.sender);
        return true;
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        _transferAllArgs(msg.sender, _to, _value);
        return true;
    }

    function _transferAllArgs(
        address _from,
        address _to,
        uint256 _value
    ) internal virtual resolveSender(_from) {
        _subBalance(_from, _value);
        emit Transfer(_from, _to, _value);
        bool hasHook;
        address to;
        (to, hasHook) = _resolveRecipient(_to);
        _addBalance(to, _value);
        if (_to != to) {
            emit Transfer(_to, to, _value);
        }
        if (hasHook) {
            TrueCoinReceiver(to).tokenFallback(_from, _value);
        }
    }

    function _burn(address _from, uint256 _value) internal virtual returns (uint256 resultBalance_, uint256 resultSupply_) {
        emit Transfer(_from, address(0), _value);
        emit Burn(_from, _value);
        resultBalance_ = _subBalance(_from, _value);
        resultSupply_ = totalSupply.sub(_value, "removing more stake than in supply");
        totalSupply = resultSupply_;
    }

    function _mint(address _to, uint256 _value) internal virtual {
        emit Transfer(address(0), _to, _value);
        emit Mint(_to, _value);
        (address to, bool hook) = _resolveRecipient(_to);
        if (_to != to) {
            emit Transfer(_to, to, _value);
        }
        _addBalance(to, _value);
        totalSupply = totalSupply.add(_value, "totalSupply overflow");
        if (hook) {
            TrueCoinReceiver(to).tokenFallback(address(0x0), _value);
        }
    }
}

 

pragma solidity 0.6.10;


 
contract ClaimableContract is ProxyStorage {
    function owner() public view returns (address) {
        return owner_;
    }

    function pendingOwner() public view returns (address) {
        return pendingOwner_;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() public {
        owner_ = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner_, "only owner");
        _;
    }

     
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner_);
        _;
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        pendingOwner_ = newOwner;
    }

     
    function claimOwnership() public onlyPendingOwner {
        address _pendingOwner = pendingOwner_;
        emit OwnershipTransferred(owner_, _pendingOwner);
        owner_ = _pendingOwner;
        pendingOwner_ = address(0);
    }
}

 

pragma solidity 0.6.10;




 
abstract contract TimeLockedToken is ValTokenWithHook, ClaimableContract {
    using SafeMath for uint256;

     
    mapping(address => uint256) distribution;

     
    uint256 constant LOCK_START = 1594716039;
     
    uint256 constant FIRST_EPOCH_DELAY = 30 days;
     
    uint256 constant EPOCH_DURATION = 90 days;
     
    uint256 constant TOTAL_EPOCHS = 8;
     
    address public timeLockRegistry;

    modifier onlyTimeLockRegistry() {
        require(msg.sender == timeLockRegistry, "only TimeLockRegistry");
        _;
    }

     
    function setTimeLockRegistry(address newTimeLockRegistry) external onlyOwner {
        require(newTimeLockRegistry != address(0), "cannot be zero address");
        require(newTimeLockRegistry != timeLockRegistry, "must be new TimeLockRegistry");
        timeLockRegistry = newTimeLockRegistry;
    }

     
    function _transferAllArgs(
        address _from,
        address _to,
        uint256 _value
    ) internal override resolveSender(_from) {
        require(balanceOf[_from] >= _value, "insufficient balance");
        require(unlockedBalance(_from) >= _value, "attempting to transfer locked funds");

        super._transferAllArgs(_from, _to, _value);
    }

     
    function _transferFromAllArgs(
        address _from,
        address _to,
        uint256 _value,
        address _spender
    ) internal override {
        require(balanceOf[_from] >= _value, "insufficient balance");
        require(unlockedBalance(_from) >= _value, "attempting to transfer locked funds");

        super._transferFromAllArgs(_from, _to, _value, _spender);
    }

     
    function registerLockup(address receiver, uint256 amount) external onlyTimeLockRegistry {
        require(balanceOf[msg.sender] >= amount, "insufficient balance");
        require(distribution[receiver] == 0, "distribution already set");

         
        distribution[receiver] = amount;

         
        _transferAllArgs(msg.sender, receiver, amount);
    }

     
    function lockedBalance(address account) public view returns (uint256) {
         
        uint256 epochsLeft = TOTAL_EPOCHS.sub(epochsPassed());
        return distribution[account].mul(epochsLeft).div(TOTAL_EPOCHS);
    }

     
    function unlockedBalance(address account) public view returns (uint256) {
         
        return balanceOf[account].sub(lockedBalance(account));
    }

     
    function epochsPassed() public view returns (uint256) {
         
        if (block.timestamp < LOCK_START) {
            return 0;
        }

         
        uint256 timePassed = block.timestamp.sub(LOCK_START);

         
        if (timePassed < FIRST_EPOCH_DELAY) {
            return 0;
        }

         
        uint256 totalEpochsPassed = timePassed.sub(FIRST_EPOCH_DELAY).div(EPOCH_DURATION);

         
        if (totalEpochsPassed > TOTAL_EPOCHS) {
            return TOTAL_EPOCHS;
        }

        return totalEpochsPassed;
    }

     
    function nextEpoch() public view returns (uint256) {
         
        uint256 passed = epochsPassed();

         
        if (passed == TOTAL_EPOCHS) {
            revert("No remaining epochs. Distribution period completed.");
        }

         
        if (passed == 0) {
            return latestEpoch().add(FIRST_EPOCH_DELAY).add(EPOCH_DURATION);
        }

         
        return latestEpoch().add(EPOCH_DURATION);
    }

     
    function latestEpoch() public view returns (uint256) {
         
        uint256 passed = epochsPassed();

         
        if (passed == 0) {
            return LOCK_START;
        }

         
         
        return LOCK_START.add(FIRST_EPOCH_DELAY).add(passed.mul(EPOCH_DURATION));
    }

     
    function finalEpoch() public pure returns (uint256) {
         
        return LOCK_START.add(FIRST_EPOCH_DELAY).add(EPOCH_DURATION.mul(TOTAL_EPOCHS));
    }

     
    function lockStart() public pure returns (uint256) {
        return LOCK_START;
    }
}

 

pragma solidity 0.6.10;




 
contract TrustToken is TimeLockedToken {
    using SafeMath for uint256;
    Registry registry_;
    uint256 constant MAX_SUPPLY = 145000000000000000;

     
    function initialize(Registry _registry) public {
        require(!initalized, "already initalized");
        registry_ = _registry;
        owner_ = msg.sender;
        initalized = true;
    }

    function registry() public override view returns (Registry) {
        return registry_;
    }

     
    function mint(address _to, uint256 _amount) external onlyOwner {
        if (totalSupply.add(_amount) <= MAX_SUPPLY) {
            _mint(_to, _amount);
        } else {
            revert("Max supply exceeded");
        }
    }

    function decimals() public pure returns (uint8) {
        return 8;
    }

    function rounding() public pure returns (uint8) {
        return 8;
    }

    function name() public pure returns (string memory) {
        return "TrustToken";
    }

    function symbol() public pure returns (string memory) {
        return "TRU";
    }
}