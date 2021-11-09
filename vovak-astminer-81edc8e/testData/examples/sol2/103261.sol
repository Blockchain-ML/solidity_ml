 

pragma solidity ^0.6.0;

 
contract Context {
     
     
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity ^0.6.0;

 
interface IERC777 {
     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function granularity() external view returns (uint256);

     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address owner) external view returns (uint256);

     
    function send(address recipient, uint256 amount, bytes calldata data) external;

     
    function burn(uint256 amount, bytes calldata data) external;

     
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

     
    function authorizeOperator(address operator) external;

     
    function revokeOperator(address operator) external;

     
    function defaultOperators() external view returns (address[] memory);

     
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

     
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

 

pragma solidity ^0.6.0;

 
interface IERC777Recipient {
     
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

 

pragma solidity ^0.6.0;

 
interface IERC777Sender {
     
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
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
}

 

pragma solidity ^0.6.0;

 
interface IERC1820Registry {
     
    function setManager(address account, address newManager) external;

     
    function getManager(address account) external view returns (address);

     
    function setInterfaceImplementer(address account, bytes32 interfaceHash, address implementer) external;

     
    function getInterfaceImplementer(address account, bytes32 interfaceHash) external view returns (address);

     
    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

     
    function updateERC165Cache(address account, bytes4 interfaceId) external;

     
    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

     
    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);

    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}

 

pragma solidity ^0.6.0;









 
contract ERC777 is Context, IERC777, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    IERC1820Registry constant internal _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

     
     

     
    bytes32 constant private _TOKENS_SENDER_INTERFACE_HASH =
        0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

     
    bytes32 constant private _TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

     
    address[] private _defaultOperatorsArray;

     
    mapping(address => bool) private _defaultOperators;

     
    mapping(address => mapping(address => bool)) private _operators;
    mapping(address => mapping(address => bool)) private _revokedDefaultOperators;

     
    mapping (address => mapping (address => uint256)) private _allowances;

     
    constructor(
        string memory name,
        string memory symbol,
        address[] memory defaultOperators
    ) public {
        _name = name;
        _symbol = symbol;

        _defaultOperatorsArray = defaultOperators;
        for (uint256 i = 0; i < _defaultOperatorsArray.length; i++) {
            _defaultOperators[_defaultOperatorsArray[i]] = true;
        }

         
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }

     
    function name() public view override returns (string memory) {
        return _name;
    }

     
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

     
    function decimals() public pure returns (uint8) {
        return 18;
    }

     
    function granularity() public view override returns (uint256) {
        return 1;
    }

     
    function totalSupply() public view override(IERC20, IERC777) returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address tokenHolder) public view override(IERC20, IERC777) returns (uint256) {
        return _balances[tokenHolder];
    }

     
    function send(address recipient, uint256 amount, bytes memory data) public override  {
        _send(_msgSender(), recipient, amount, data, "", true);
    }

     
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");

        address from = _msgSender();

        _callTokensToSend(from, from, recipient, amount, "", "");

        _move(from, from, recipient, amount, "", "");

        _callTokensReceived(from, from, recipient, amount, "", "", false);

        return true;
    }

     
    function burn(uint256 amount, bytes memory data) public override  {
        _burn(_msgSender(), amount, data, "");
    }

     
    function isOperatorFor(
        address operator,
        address tokenHolder
    ) public view override returns (bool) {
        return operator == tokenHolder ||
            (_defaultOperators[operator] && !_revokedDefaultOperators[tokenHolder][operator]) ||
            _operators[tokenHolder][operator];
    }

     
    function authorizeOperator(address operator) public override  {
        require(_msgSender() != operator, "ERC777: authorizing self as operator");

        if (_defaultOperators[operator]) {
            delete _revokedDefaultOperators[_msgSender()][operator];
        } else {
            _operators[_msgSender()][operator] = true;
        }

        emit AuthorizedOperator(operator, _msgSender());
    }

     
    function revokeOperator(address operator) public override  {
        require(operator != _msgSender(), "ERC777: revoking self as operator");

        if (_defaultOperators[operator]) {
            _revokedDefaultOperators[_msgSender()][operator] = true;
        } else {
            delete _operators[_msgSender()][operator];
        }

        emit RevokedOperator(operator, _msgSender());
    }

     
    function defaultOperators() public view override returns (address[] memory) {
        return _defaultOperatorsArray;
    }

     
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    )
    public override
    {
        require(isOperatorFor(_msgSender(), sender), "ERC777: caller is not an operator for holder");
        _send(sender, recipient, amount, data, operatorData, true);
    }

     
    function operatorBurn(address account, uint256 amount, bytes memory data, bytes memory operatorData) public override {
        require(isOperatorFor(_msgSender(), account), "ERC777: caller is not an operator for holder");
        _burn(account, amount, data, operatorData);
    }

     
    function allowance(address holder, address spender) public view override returns (uint256) {
        return _allowances[holder][spender];
    }

     
    function approve(address spender, uint256 value) public override returns (bool) {
        address holder = _msgSender();
        _approve(holder, spender, value);
        return true;
    }

    
    function transferFrom(address holder, address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");
        require(holder != address(0), "ERC777: transfer from the zero address");

        address spender = _msgSender();

        _callTokensToSend(spender, holder, recipient, amount, "", "");

        _move(spender, holder, recipient, amount, "", "");
        _approve(holder, spender, _allowances[holder][spender].sub(amount, "ERC777: transfer amount exceeds allowance"));

        _callTokensReceived(spender, holder, recipient, amount, "", "", false);

        return true;
    }

     
    function _mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
    internal virtual
    {
        require(account != address(0), "ERC777: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, amount);

         
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);

        _callTokensReceived(operator, address(0), account, amount, userData, operatorData, true);

        emit Minted(operator, account, amount, userData, operatorData);
        emit Transfer(address(0), account, amount);
    }

     
    function _send(
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        internal
    {
        require(from != address(0), "ERC777: send from the zero address");
        require(to != address(0), "ERC777: send to the zero address");

        address operator = _msgSender();

        _callTokensToSend(operator, from, to, amount, userData, operatorData);

        _move(operator, from, to, amount, userData, operatorData);

        _callTokensReceived(operator, from, to, amount, userData, operatorData, requireReceptionAck);
    }

     
    function _burn(
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    )
        internal virtual
    {
        require(from != address(0), "ERC777: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), amount);

        _callTokensToSend(operator, from, address(0), amount, data, operatorData);

         
        _balances[from] = _balances[from].sub(amount, "ERC777: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);

        emit Burned(operator, from, amount, data, operatorData);
        emit Transfer(from, address(0), amount);
    }

    function _move(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        private
    {
        _beforeTokenTransfer(operator, from, to, amount);

        _balances[from] = _balances[from].sub(amount, "ERC777: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(amount);

        emit Sent(operator, from, to, amount, userData, operatorData);
        emit Transfer(from, to, amount);
    }

     
    function _approve(address holder, address spender, uint256 value) internal {
        require(holder != address(0), "ERC777: approve from the zero address");
        require(spender != address(0), "ERC777: approve to the zero address");

        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }

     
    function _callTokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        private
    {
        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(from, _TOKENS_SENDER_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
        }
    }

     
    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        private
    {
        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(to, _TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        } else if (requireReceptionAck) {
            require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }
    }

     
    function _beforeTokenTransfer(address operator, address from, address to, uint256 tokenId) internal virtual { }
}

 

pragma solidity ^0.6.0;

 
library Math {
     
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

     
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

     
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

 

pragma solidity 0.6.9;







 
struct AddressLock {
     
    uint256 amount;

     
    uint256 burnedAmount;

     
    uint256 blockNumber;

     
    uint256 lastMintBlockNumber;

     
    address minterAddress;
}

 
contract FluxToken is ERC777, IERC777Recipient {
     
    using SafeMath for uint256;

     
    mapping(address => bool) private mutex;

     
    modifier preventRecursion() {
        if(mutex[_msgSender()] == false) {
            mutex[_msgSender()] = true;
            _;  
            mutex[_msgSender()] = false;
        }
        
         
    }

     
    modifier preventSameBlock(address targetAddress) {
        require(addressLocks[targetAddress].blockNumber != block.number && addressLocks[targetAddress].lastMintBlockNumber != block.number, "You can not lock/unlock/mint in the same block");
        
        _;  
    }

     
    modifier requireLocked(address targetAddress, bool requiredState) {
        if (requiredState) {
            require(addressLocks[targetAddress].amount != 0, "You must have locked-in your DAM tokens");
        }else{
            require(addressLocks[targetAddress].amount == 0, "You must have unlocked your DAM tokens");
        }

        _;  
    }

     
    IERC777 immutable private _token;

    IERC1820Registry private _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
	
     
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata,
        bytes calldata
    ) external override {
        require(amount > 0, "You must receive a positive number of tokens");
        require(_msgSender() == address(_token), "You can only lock-in DAM tokens");

         
        require(operator == address(this) , "Only FLUX contract can send itself DAM tokens");
        require(to == address(this), "Funds must be coming into FLUX token");
        require(from != to, "Why would FLUX contract send tokens to itself?");
    }

     
    uint256 immutable private _startTimeReward;

     
    uint256 immutable private _maxTimeReward;

     
    uint256 immutable private _failsafeTargetBlock;
	 
    constructor(address token, uint256 startTimeReward, uint256 maxTimeReward, uint256 failsafeBlockDuration) public ERC777("FLUX", "FLUX", new address[](0)) {
		require(maxTimeReward > 0, "maxTimeReward must be at least 1 block");  

        _token = IERC777(token);
        _startTimeReward = startTimeReward;
        _maxTimeReward = maxTimeReward;
        _failsafeTargetBlock = block.number.add(failsafeBlockDuration);

        _erc1820.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
    }

     
     uint256 private constant _failsafeMaxAmount = 100 * (10 ** 18);

     
    uint256 private constant _mintPerBlockDivisor = 10 ** 8;

     
    uint256 private constant _ratioMultiplier = 10 ** 10;

     
    uint256 private constant _percentMultiplier = 10000;

     
    uint256 private constant _maxBurnMultiplier = 100000;

     
	uint256 private constant _maxTimeMultiplier = 30000;

	 
	uint256 private constant  _targetBlockMultiplier = 20000;
    
     
    mapping (address => AddressLock) public addressLocks;
    
     
    uint256 public globalLockedAmount;
    
     
    uint256 public globalBurnedAmount;

     
    event Locked(address sender, uint256 blockNumber, address minterAddress, uint256 amount, uint256 burnedAmountIncrease);
    event Unlocked(address sender, uint256 amount, uint256 burnedAmountDecrease);
    event BurnedToAddress(address sender, address targetAddress, uint256 amount);
    event Minted(address sender, uint256 blockNumber, address sourceAddress, address targetAddress, uint256 targetBlock, uint256 amount);
    
     

	 
    function lock(address minterAddress, uint256 amount) 
        preventRecursion 
        preventSameBlock(_msgSender())
        requireLocked(_msgSender(), false)  
    public {
        require(amount > 0, "You must provide a positive amount to lock-in");

         
        if (block.number < _failsafeTargetBlock) {
            require(amount <= _failsafeMaxAmount, "You can only lock-in up to 100 DAM during failsafe.");
        }

        AddressLock storage senderAddressLock = addressLocks[_msgSender()];  

        senderAddressLock.amount = amount;
        senderAddressLock.blockNumber = block.number;
        senderAddressLock.lastMintBlockNumber = block.number;  
        senderAddressLock.minterAddress = minterAddress;
        
        globalLockedAmount = globalLockedAmount.add(amount);
        globalBurnedAmount = globalBurnedAmount.add(senderAddressLock.burnedAmount);

        emit Locked(_msgSender(), block.number, minterAddress, amount, senderAddressLock.burnedAmount);

         
        IERC777(_token).operatorSend(_msgSender(), address(this), amount, "", "");  
    }
    
	 
    function unlock() 
        preventRecursion 
        preventSameBlock(_msgSender())
        requireLocked(_msgSender(), true)   
    public {
        AddressLock storage senderAddressLock = addressLocks[_msgSender()];  

        uint256 amount = senderAddressLock.amount;
        senderAddressLock.amount = 0;

        globalLockedAmount = globalLockedAmount.sub(amount);
        globalBurnedAmount = globalBurnedAmount.sub(senderAddressLock.burnedAmount);

        emit Unlocked(_msgSender(), amount, senderAddressLock.burnedAmount);

         
        IERC777(_token).send(_msgSender(), amount, "");  
    }

	 
    function burnToAddress(address targetAddress, uint256 amount) 
        preventRecursion 
        requireLocked(targetAddress, true)  
    public {
        require(amount > 0, "You must burn > 0 FLUX");

        AddressLock storage targetAddressLock = addressLocks[targetAddress];  
        
        targetAddressLock.burnedAmount = targetAddressLock.burnedAmount.add(amount);

        globalBurnedAmount = globalBurnedAmount.add(amount);
        
        emit BurnedToAddress(_msgSender(), targetAddress, amount);

         
        _burn(_msgSender(), amount, "", "");  
    }

	 
    function mintToAddress(address sourceAddress, address targetAddress, uint256 targetBlock) 
        preventRecursion 
        preventSameBlock(sourceAddress)
        requireLocked(sourceAddress, true)  
    public {
        require(targetBlock <= block.number, "You can only mint up to current block");
        
        AddressLock storage sourceAddressLock = addressLocks[sourceAddress];  
        
        require(sourceAddressLock.lastMintBlockNumber < targetBlock, "You can only mint ahead of last mint block");
        require(sourceAddressLock.minterAddress == _msgSender(), "You must be the delegated minter of the sourceAddress");

        uint256 mintAmount = getMintAmount(sourceAddress, targetBlock);
        require(mintAmount > 0, "You can not mint zero balance");
        
        sourceAddressLock.lastMintBlockNumber = targetBlock;  

        emit Minted(_msgSender(), block.number, sourceAddress, targetAddress, targetBlock, mintAmount);

         
        _mint(targetAddress, mintAmount, "", "");  
    }

     

	 
    function getMintAmount(address targetAddress, uint256 targetBlock) public view returns(uint256) {
        AddressLock storage targetAddressLock = addressLocks[targetAddress];  

         
        if (targetAddressLock.amount == 0) {
            return 0;
        }

        require(targetBlock <= block.number, "You can only calculate up to current block");
        require(targetAddressLock.lastMintBlockNumber <= targetBlock, "You can only specify blocks at or ahead of last mint block");

        uint256 blocksMinted = targetBlock.sub(targetAddressLock.lastMintBlockNumber);

        uint256 amount = targetAddressLock.amount;  
        uint256 blocksMintedByAmount = amount.mul(blocksMinted);

         
        uint256 burnMultiplier = getAddressBurnMultiplier(targetAddress);
        uint256 timeMultipler = getAddressTimeMultiplier(targetAddress);
        uint256 fluxAfterMultiplier = blocksMintedByAmount.mul(burnMultiplier).div(_percentMultiplier).mul(timeMultipler).div(_percentMultiplier);

        uint256 actualFluxMinted = fluxAfterMultiplier.div(_mintPerBlockDivisor);
        return actualFluxMinted;
    }
    
	 
    function getAddressTimeMultiplier(address targetAddress) public view returns(uint256) {
        AddressLock storage targetAddressLock = addressLocks[targetAddress];  

         
        if (targetAddressLock.amount == 0) {
            return _percentMultiplier;
        }
        
         
        uint256 targetBlockNumber = targetAddressLock.blockNumber.add(_startTimeReward);
        if (block.number < targetBlockNumber) {
            return _percentMultiplier;
        }

         
         
        uint256 blockDiff = block.number.sub(targetBlockNumber).mul(_targetBlockMultiplier).div(_maxTimeReward).add(_percentMultiplier); 

        uint256 timeMultiplier = Math.min(_maxTimeMultiplier, blockDiff);  
        return timeMultiplier;
    }

     
    function getAddressBurnMultiplier(address targetAddress) public view returns(uint256) {
        uint256 myRatio = getAddressRatio(targetAddress);
        uint256 globalRatio = getGlobalRatio();
        
         
        if (globalRatio == 0 || myRatio == 0) {
            return _percentMultiplier;
        }

         
        uint256 burnMultiplier = Math.min(_maxBurnMultiplier, myRatio.mul(_percentMultiplier).div(globalRatio).add(_percentMultiplier));  
        return burnMultiplier;
    }

     
    function getAddressRatio(address targetAddress) public view returns(uint256) {
        AddressLock storage targetAddressLock = addressLocks[targetAddress];  

        uint256 addressLockedAmount = targetAddressLock.amount;
        uint256 addressBurnedAmount = targetAddressLock.burnedAmount;

         
        if (addressLockedAmount == 0) {
            return 0;
        }

         
         
        uint256 myRatio = addressBurnedAmount.mul(_ratioMultiplier).div(addressLockedAmount);
        return myRatio;
    }

     
    function getGlobalRatio() public view returns(uint256) {
         
        if (globalLockedAmount == 0) {
            return 0;
        }

         
         
        uint256 globalRatio = globalBurnedAmount.mul(_ratioMultiplier).div(globalLockedAmount);
        return globalRatio;
    }

     
    function getAddressDetails(address targetAddress) public view returns(uint256,uint256,uint256,uint256,uint256,uint256,uint256) {
        uint256 fluxBalance = balanceOf(targetAddress);
        uint256 mintAmount = getMintAmount(targetAddress, block.number);

        uint256 addressTimeMultiplier = getAddressTimeMultiplier(targetAddress);
        uint256 addressBurnMultiplier = getAddressBurnMultiplier(targetAddress);

        return (
            block.number, 
            fluxBalance, 
            mintAmount, 
            addressTimeMultiplier,
            addressBurnMultiplier,
            globalLockedAmount, 
            globalBurnedAmount);
    }
    
     
    function getAddressTokenDetails(address targetAddress) public view returns(uint256,bool,uint256,uint256,uint256) {
        bool isFluxOperator = IERC777(_token).isOperatorFor(address(this), targetAddress);
        uint256 damBalance = IERC777(_token).balanceOf(targetAddress);

        uint256 myRatio = getAddressRatio(targetAddress);
        uint256 globalRatio = getGlobalRatio();

        return (
            block.number, 
            isFluxOperator, 
            damBalance,
            myRatio,
            globalRatio);
    }
}