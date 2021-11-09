 

pragma solidity ^0.6.12;


 
 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 
 
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

     
    function _beforeTokenTransfer(address operator, address from, address to, uint256 amount) internal virtual { }
}

 
 
contract TokenTimeLock is IERC777Recipient {
    using SafeMath for uint256;
    uint256  private constant THREEMONTH  = 90 days;


     
    IERC777 public token;

     
    address private admin;
     
    mapping(address=>lockInfo) public balanceOf;
     
    uint256 public releaseTime;

     
    struct lockInfo{
        uint256 amount;
        uint256 balance;
        uint256 lastReleaseTime;
    }

    constructor (IERC777 _token,uint256 _releaseTime) public {
         
        require(_releaseTime > block.timestamp, "release time is before current time");

        token = _token;
        releaseTime = _releaseTime;
        admin=msg.sender;

        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24)
        .setInterfaceImplementer(
            address(this),
            0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b, 
            address(this));
    }

     
    function release(address beneficiary) public   {
        require(beneficiary !=address(0),"beneficiary address is empty" );

         
        require(block.timestamp >= releaseTime, "current time is before release time");

        lockInfo storage info = balanceOf[beneficiary];
        require(info.balance>0,"no tokens to release");

        uint256 amount=  info.amount.mul(10).div(100); 
        if(amount>info.balance){
            amount= info.balance;
        }
        require(token.balanceOf(address(this))>=amount,"no tokens to release" );
         
        require(block.timestamp >= info.lastReleaseTime.add(THREEMONTH), "current time is before release time (three month)");

        token.send(beneficiary, amount,"");
        uint256 newBalance = info.balance.sub(amount);
        if(newBalance==0){
            delete balanceOf[beneficiary]; 
            return;
        }
        info.balance=newBalance;
         
        info.lastReleaseTime=block.timestamp;
    }

     
    function lock(address beneficiary,uint256 amount) public{
        require(msg.sender==admin,"msg.sender is not token address");

        require(balanceOf[beneficiary].balance==0,"repeat lock");

         
        balanceOf[beneficiary] = lockInfo({
            balance:amount,
            amount:amount,lastReleaseTime:0 });
    }
     
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) override public {
        operator;from;to;amount;userData;operatorData;
        require(msg.sender==address(token),"received token is not Token target");
    }
}

 
 
contract Token is ERC777 {

    TokenTimeLock public   locker;

    constructor() public ERC777("Business universal services Chain","BUS",new address[](0))   {

        uint256 releaseTime= block.timestamp + 1095 days; 
        locker = new TokenTimeLock(this,releaseTime);

         
         
         
         
         
         
         
         
         
         
         
         
         
         
         

         
        _mint(address(locker),2000*10000*1e18,"","");
        locker.lock(0xd5e7a36DA04C136B3a03beeAAE4E1Da8dC52a192,300*10000*1e18);
        locker.lock(0xaEb3b44732E59e0F9B77316E1Df29be518F486bC,150*10000*1e18);
        locker.lock(0xe9df36cF551bdbfE9CdFbbf2904f56A20D8B8dC1,200*10000*1e18);
        locker.lock(0xB869C2903D3248F40f61773eb9Cf4c2cFf17a5d5,250*10000*1e18);
        locker.lock(0x43401ae3ebcD9c6Ce252e9646373AA90DB588DCA,100*10000*1e18);
        locker.lock(0x3b2Ac663c495A19aE2Fe1272B06e4f9d421Fe041,200*10000*1e18);
        locker.lock(0x4dF5675fA8106296E73Dd7246C0d2fa51049117d,500*10000*1e18);
        locker.lock(0xfea7d3dFA4625E9000D8DbaA0137d385CF699AFb,300*10000*1e18);

          
        _mint(0x1Fa09e46492172ef5E8c99F870cc7a4958d5E41c,3500*10000*1e18,"","");
        _mint(0x4a204002d1AC965EB6A502DDB718834603553D4d,3000*10000*1e18,"","");
        _mint(0x85B51B91c072EA86BbD7290D68c43d8999381C67,1000*10000*1e18,"","");
        _mint(0x85A444ACFc0205c5eE6EaA4005074856bF1C2BF4,500*10000*1e18,"","");
    }
}