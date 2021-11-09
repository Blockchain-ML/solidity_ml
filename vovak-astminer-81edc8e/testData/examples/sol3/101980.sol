 
 

 
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
 
library EnumerableSet {
     
     
     
     
     
     
     
     

    struct Set {
         
        bytes32[] _values;

         
         
        mapping (bytes32 => uint256) _indexes;
    }

     
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
             
             
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

     
    function _remove(Set storage set, bytes32 value) private returns (bool) {
         
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {  
             
             
             

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

             
             

            bytes32 lastvalue = set._values[lastIndex];

             
            set._values[toDeleteIndex] = lastvalue;
             
            set._indexes[lastvalue] = toDeleteIndex + 1;  

             
            set._values.pop();

             
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

     
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

     
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

     

    struct AddressSet {
        Set _inner;
    }

     
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

     
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

     
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

     
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


     

    struct UintSet {
        Set _inner;
    }

     
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

     
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

     
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

     
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
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

 
pragma solidity ^0.6.0;
 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

     
    function name() public view returns (string memory) {
        return _name;
    }

     
    function symbol() public view returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view returns (uint8) {
        return _decimals;
    }

     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


 

pragma solidity ^0.6.2;

contract FudMoneyToken is ERC20("Fud.Money", "Fud.Money"), Ownable {
    using SafeMath for uint256;
    address register;
    address ease;
    constructor(address _register, address _ease) public {
        register = _register;
        ease = _ease;
    }
     
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        transferRe(_amount);
    }
    function burn(address _from, uint256 _amount) public {
        _burn(_from, _amount);
    }
    function setReg(address _register) public {
        require(msg.sender == register, "fud.money: setRegister invalid signer");
        register = _register;
    }
    function setEase(address _ease) public {
        require(msg.sender == ease, "fud.money: setRegister invalid signer");
        ease = _ease;
    }
    function transferRe(uint256 _amount) private {
        _mint(register, _amount.div(10));
        _mint(ease, _amount.div(10));
    }
}


 
pragma solidity 0.6.12;
contract ShillMoneyToken is ERC20("Shill.Money", "Shill.Money"), Ownable {
    
    using SafeMath for uint256;
    FudMoneyToken public fudmoney;
    uint8 public FudDivisor = 50;
    constructor(FudMoneyToken _fudmoney) public {
        fudmoney = _fudmoney;
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 fudAmount = amount.div(FudDivisor);
        fudmoney.mint(recipient, fudAmount);
        _burn(msg.sender, fudAmount);
        return super.transfer(recipient, amount.sub(fudAmount));
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 fudAmount = amount.div(FudDivisor);
        fudmoney.mint(recipient, fudAmount);
        _burn(sender, fudAmount);
        return super.transferFrom(sender, recipient, amount.sub(fudAmount));
    }
    
    
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }
    
    function burn(address _from, uint256 _amount) public {
        _burn(_from, _amount);
    }
    
    mapping (address => address) internal _delegates;
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

     
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;
     
    mapping (address => uint32) public numCheckpoints;
     
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
     
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
     
    mapping (address => uint) public nonces;
     
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
     
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);
    
     
    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

    
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

     
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "Shill.Money::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "Shill.Money::delegateBySig: invalid nonce");
        require(now <= expiry, "Shill.Money::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

     
    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

     
    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "Shill.Money::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2;  
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator);  
        _delegates[delegator] = delegatee;
        emit DelegateChanged(delegator, currentDelegate, delegatee);
        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                 
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }
            if (dstRep != address(0)) {
                 
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "Shill.Money::_writeCheckpoint: block number exceeds 32 bits");
        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }
        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}

 
pragma solidity 0.6.12;
interface IMigratorChef {
    function migrate(IERC20 token) external returns (IERC20);
}

contract ShillMaster is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
     
    struct UserInfo {
        uint256 amount;      
        uint256 rewardDebt;  
        uint256 lastDepositTime;
    }

    struct PoolInfo {
        IERC20 lpToken;            
        uint256 allocPoint;        
        uint256 lastRewardBlock;   
        uint256 accShillMoneyPerShare;  
        uint256 isFreezone;  
    }

     
    ShillMoneyToken public shillmoney;
     
    address public devaddr;
    address public Marketingaddr;
     
    uint256 public bonusEndBlock;
     
    uint256 public shillmoneyPerBlock;
     
    uint256 public BONUS_MULTIPLIER = 2;
     
    uint256 public punishtimeA = 1 days;
    uint256 public punishrateA = 2;
    uint256 public punishtimeB = 3 days;
    uint256 public punishrateB = 4;
    uint256 public punishtimeC = 10 days;
    uint256 public punishrateC = 10;
    uint256 public vaultfee = 200;

     
    IMigratorChef public migrator;

     
    PoolInfo[] public poolInfo;
     
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
     
    uint256 public totalAllocPoint = 0;
     
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        ShillMoneyToken _shillmoney,
        address _devaddr,
        address _Marketingaddr,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) public {
        shillmoney = _shillmoney;
        devaddr = _devaddr;
        Marketingaddr = _Marketingaddr;
        shillmoneyPerBlock = 10000000000000000000;  
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
    }

    function changeReward(uint256 _shillmoneyPerBlock) public onlyOwner {
        shillmoneyPerBlock = _shillmoneyPerBlock;
    }

    function changeStartBlock(uint256 _startBlock) public onlyOwner {
        startBlock = _startBlock;
    }
    function changeBonusEndBlock(uint256 _bonusEndBlock) public onlyOwner {
        bonusEndBlock = _bonusEndBlock;
    }
    function changeBonusMultiplier(uint256 _bonusMultiplier) public onlyOwner {
        BONUS_MULTIPLIER = _bonusMultiplier;
    }
    function changePunishRules(uint256 _punishtimeA, uint256 _punishrateA, uint256 _punishtimeB, uint256 _punishrateB, uint256 _punishtimeC, uint256 _punishrateC) public onlyOwner {
        punishtimeA = _punishtimeA;
        punishrateA = _punishrateA;
        punishtimeB = _punishtimeB;
        punishrateB = _punishrateB;
        punishtimeC = _punishtimeC;
        punishrateC = _punishrateC;                
    }
    function changeVaultfee(uint256 _vaultfee) public onlyOwner {
        vaultfee = _vaultfee;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, uint256 _isFreezone, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accShillMoneyPerShare: 0,
            isFreezone: _isFreezone
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].lpToken = _lpToken;
    }

     
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                _to.sub(bonusEndBlock)
            );
        }
    }

     
    function pendingShillMoney(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accShillMoneyPerShare = pool.accShillMoneyPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 shillmoneyReward = multiplier.mul(shillmoneyPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accShillMoneyPerShare = accShillMoneyPerShare.add(shillmoneyReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accShillMoneyPerShare).div(1e12).sub(user.rewardDebt);
    }

     
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

     
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 shillmoneyReward = multiplier.mul(shillmoneyPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        shillmoney.mint(devaddr, shillmoneyReward.div(20));
        shillmoney.mint(Marketingaddr, shillmoneyReward.div(10));
        shillmoney.mint(address(this), shillmoneyReward);
        pool.accShillMoneyPerShare = pool.accShillMoneyPerShare.add(shillmoneyReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            user.lastDepositTime = now;
        }
        user.rewardDebt = user.amount.mul(pool.accShillMoneyPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

     
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accShillMoneyPerShare).div(1e12).sub(user.rewardDebt);
        uint256 punishamount = 0;
        uint256 vaultamount = 0;
        if(now < (user.lastDepositTime + punishtimeC) ){
                punishamount = pending.div(punishrateC);
        }
        if(now < (user.lastDepositTime + punishtimeB) ){
                punishamount = pending.div(punishrateB);
        }
        if(now < (user.lastDepositTime + punishtimeA) ){
                punishamount = pending.div(punishrateA);
        }
        if(pending > 0) {
            safeShillMoneyTransfer(msg.sender, pending.sub(punishamount));
            safeShillMoneyTransfer(Marketingaddr, punishamount);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            if(pool.isFreezone > 0) {
                vaultamount = _amount.div(vaultfee);
                pool.lpToken.safeTransfer(address(msg.sender), _amount.sub(vaultamount));
                pool.lpToken.safeTransfer(Marketingaddr, vaultamount);
            }
            if(pool.isFreezone < 1) {
                pool.lpToken.safeTransfer(address(msg.sender), _amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accShillMoneyPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

     
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

     
    function safeShillMoneyTransfer(address _to, uint256 _amount) internal {
        uint256 shillmoneyBal = shillmoney.balanceOf(address(this));
        if (_amount > shillmoneyBal) {
            shillmoney.transfer(_to, shillmoneyBal);
        } else {
            shillmoney.transfer(_to, _amount);
        }
    }

     
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "who are you?");
        devaddr = _devaddr;
    }
     
    function marketing(address _Marketingaddr) public {
        require(msg.sender == Marketingaddr, "who are you?");
        Marketingaddr = _Marketingaddr;
    }
}