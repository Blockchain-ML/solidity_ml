pragma solidity ^0.4.24;


interface ERC777TokensRecipient {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes data,
        bytes operatorData
    ) public;
}

interface ERC777TokensSender {
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint amount,
        bytes userData,
        bytes operatorData
    ) public;
}


interface ERC777Token {
    function name() public view returns (string);
    function symbol() public view returns (string);
    function totalSupply() public view returns (uint256);
    function balanceOf(address owner) public view returns (uint256);
    function granularity() public view returns (uint256);

    function defaultOperators() public view returns (address[]);
    function isOperatorFor(address operator, address tokenHolder) public view returns (bool);
    function authorizeOperator(address operator) public;
    function revokeOperator(address operator) public;

    function send(address to, uint256 amount, bytes data) public;
    function operatorSend(address from, address to, uint256 amount, bytes data, bytes operatorData) public;

    function burn(uint256 amount, bytes data) public;
    function operatorBurn(address from, uint256 amount, bytes data, bytes operatorData) public;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );  
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes operatorData);
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

contract ERC820Registry {
    function setInterfaceImplementer(address _addr, bytes32 _interfaceHash, address _implementer) external;
    function getInterfaceImplementer(address _addr, bytes32 _interfaceHash) external view returns (address);
    function setManager(address _addr, address _newManager) external;
    function getManager(address _addr) public view returns(address);
}


  
contract ERC820Client {
    ERC820Registry constant ERC820REGISTRY = ERC820Registry(0x820b586C8C28125366C998641B09DCbE7d4cBF06);

    function setInterfaceImplementation(string _interfaceLabel, address _implementation) internal {
        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));
        ERC820REGISTRY.setInterfaceImplementer(this, interfaceHash, _implementation);
    }

    function interfaceAddr(address addr, string _interfaceLabel) internal view returns(address) {
        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));
        return ERC820REGISTRY.getInterfaceImplementer(addr, interfaceHash);
    }

    function delegateManagement(address _newManager) internal {
        ERC820REGISTRY.setManager(this, _newManager);
    }
}

 
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

     
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


 
library SafeMath {
    
     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        require(b > 0);
        uint256 c = a / b;
         

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


  
contract TxFeeManager is Ownable {
    
    using SafeMath for uint256;
    
     
    bool public publicCanWhitelist = true;        

                  
    uint256 public maxRefundableGasPrice = 10000000000;

     
    uint256 public transferFeePercentTenths = 10;

     
    uint256 public transferFeeFlat = 0;
    
     
    address public feeRecipient;

     
    uint256 public totalFees = 0;
    
     
    uint256 public totalTX = 0; 
    
     
    uint256 public totalTXCount = 0;
    
     
    mapping(address => bool) feeWhitelist_;
    
     
    constructor(address _feeRecipient) public {
        feeRecipient = _feeRecipient;
        feeWhitelist_[address(this)] = true;
    }

     
    modifier refundable() {
        uint256 _startGas = gasleft();
        _;
        if(!applyFeeToAddress(msg.sender)) return;
        uint256 gasPrice = tx.gasprice;
        if (gasPrice > maxRefundableGasPrice) gasPrice = maxRefundableGasPrice;
        uint256 _endGas = gasleft();
        uint256 _gasUsed = _startGas.sub(_endGas).add(31000);
        uint256 weiRefund = _gasUsed.mul(gasPrice);
        if (address(this).balance >= weiRefund) msg.sender.transfer(weiRefund);
    }

     
    function applyFeeToAddress(address _address)
    internal
    view
    returns (bool) {
        return isRegularAddress(_address) && !feeWhitelist_[_address];
    }

     
    function isRegularAddress(address _addr) 
    internal 
    view 
    returns(bool) {
        if (_addr == 0) {
            return false; 
        }
        uint size;
        assembly { size := extcodesize(_addr) }  
        return size == 0;
    }
    
     
    function setFeePercentTenths(uint256 _feePercent) 
    public 
    onlyOwner {
        transferFeePercentTenths = _feePercent;
    }

     
    function setFeeFlat(uint256 _feeFlat) 
    public 
    onlyOwner {
        transferFeeFlat = _feeFlat;
    }

     
    function setFeeRecipient(address _feeRecipient) 
    public 
    onlyOwner {
        feeRecipient = _feeRecipient;
    }

     
    function setMaxRefundableGasPrice(uint256 _newMax) 
    public 
    onlyOwner {
        maxRefundableGasPrice = _newMax;
    }

     
    function exemptFromFees(address _exempt) 
    public 
    onlyOwner {
        feeWhitelist_[_exempt] = true;
    }

     
    function revokeFeeExemption(address _notExempt) 
    public 
    onlyOwner {
        feeWhitelist_[_notExempt] = false;
    }

     
    function setPublicWhitelistAbility(bool _canWhitelist) 
    public 
    onlyOwner {
        publicCanWhitelist = _canWhitelist;
    }

     
    function exemptMeFromFees() 
    public {
        if (publicCanWhitelist) {
            feeWhitelist_[msg.sender] = true;
        }
    }

     
    function _getTransferFeeAmount(address _operator, uint256 _value) 
    internal 
    view
    returns (uint256) {
        if (!applyFeeToAddress(_operator)){
            return 0;
        }
        if (transferFeePercentTenths > 0){
            return (_value.mul(transferFeePercentTenths)).div(1000) + transferFeeFlat;
        }
        return transferFeeFlat; 
    }
}

  
contract ERC777BaseToken is TxFeeManager, ERC777Token, ERC820Client {

    string internal mName;
    string internal mSymbol;
    uint256 internal mGranularity;
    uint256 internal mTotalSupply;

    mapping(address => uint) internal mBalances;

    address[] internal mDefaultOperators;
    mapping(address => bool) internal mIsDefaultOperator;
    mapping(address => mapping(address => bool)) internal mRevokedDefaultOperator;
    mapping(address => mapping(address => bool)) internal mAuthorizedOperators;

     
    constructor(string _name, string _symbol, uint256 _granularity, address[] _defaultOperators, address _feeRecipient) 
    internal TxFeeManager(_feeRecipient) {
        mName = _name;
        mSymbol = _symbol;
        mTotalSupply = 0;
        require(_granularity >= 1, "Granularity must be > 1");
        mGranularity = _granularity;

        mDefaultOperators = _defaultOperators;
        for (uint256 i = 0; i < mDefaultOperators.length; i++) { mIsDefaultOperator[mDefaultOperators[i]] = true; }

        setInterfaceImplementation("ERC777Token", this);
    }

     
     
     
    function name() public view returns (string) { return mName; }

     
    function symbol() public view returns (string) { return mSymbol; }

     
    function granularity() public view returns (uint256) { return mGranularity; }

     
    function totalSupply() public view returns (uint256) { return mTotalSupply; }

     
    function balanceOf(address _tokenHolder) public view returns (uint256) { return mBalances[_tokenHolder]; }

     
    function defaultOperators() public view returns (address[]) { return mDefaultOperators; }

     
    function send(address _to, uint256 _amount, bytes _data) public {
        doSend(msg.sender, msg.sender, _to, _amount, _data, "", true);
    }

     
    function send(address _to, uint256 _amount) public {
        doSend(msg.sender, msg.sender, _to, _amount, "", "", true);
    }

     
    function authorizeOperator(address _operator) public {
        require(_operator != msg.sender, "Cannot authorize yourself as an operator");
        if (mIsDefaultOperator[_operator]) {
            mRevokedDefaultOperator[_operator][msg.sender] = false;
        } else {
            mAuthorizedOperators[_operator][msg.sender] = true;
        }
        emit AuthorizedOperator(_operator, msg.sender);
    }

     
    function revokeOperator(address _operator) public {
        require(_operator != msg.sender, "Cannot revoke yourself as an operator");
        if (mIsDefaultOperator[_operator]) {
            mRevokedDefaultOperator[_operator][msg.sender] = true;
        } else {
            mAuthorizedOperators[_operator][msg.sender] = false;
        }
        emit RevokedOperator(_operator, msg.sender);
    }

     
    function isOperatorFor(address _operator, address _tokenHolder) public view returns (bool) {
        return (_operator == _tokenHolder  
            || mAuthorizedOperators[_operator][_tokenHolder]
            || (mIsDefaultOperator[_operator] && !mRevokedDefaultOperator[_operator][_tokenHolder]));
    }

     
    function operatorSend(address _from, address _to, uint256 _amount, bytes _data, bytes _operatorData) public {
        require(isOperatorFor(msg.sender, _from), "Not an operator");
        doSend(msg.sender, _from, _to, _amount, _data, _operatorData, true);
    }

    function burn(uint256 _amount, bytes _data) public {
        doBurn(msg.sender, msg.sender, _amount, _data, "");
    }

    function operatorBurn(address _tokenHolder, uint256 _amount, bytes _data, bytes _operatorData) public {
        require(isOperatorFor(msg.sender, _tokenHolder), "Not an operator");
        doBurn(msg.sender, _tokenHolder, _amount, _data, _operatorData);
    }

    
     
    function requireMultiple(uint256 _amount) internal view {
        require(_amount % mGranularity == 0, "Amount is not a multiple of granualrity");
    }

     
    function doSend(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _data,
        bytes _operatorData,
        bool _preventLocking
    )
        internal
        refundable
    {
        requireMultiple(_amount);

        callSender(_operator, _from, _to, _amount, _data, _operatorData);

        require(_to != address(0), "Cannot send to 0x0");
        require(mBalances[_from] >= _amount, "Not enough funds");

        uint256 feeAmount = _getTransferFeeAmount(_operator, _amount);       

        mBalances[_from] = mBalances[_from].sub(_amount);
        mBalances[_to] = mBalances[_to].add(_amount.sub(feeAmount));
        mBalances[feeRecipient] = mBalances[feeRecipient].add(feeAmount);

        totalTX = totalTX.add(_amount);
        totalTXCount += 1;

        if(feeAmount > 0){
            totalFees = totalFees.add(feeAmount);
            emit Sent(_operator, _from, feeRecipient, feeAmount, "", "");
        }

        callRecipient(_operator, _from, _to, _amount.sub(feeAmount), _data, _operatorData, _preventLocking);

        emit Sent(_operator, _from, _to, _amount.sub(feeAmount), _data, _operatorData);
    }
    
     
    function doBurn(address _operator, address _tokenHolder, uint256 _amount, bytes _data, bytes _operatorData)
        internal
    {
        callSender(_operator, _tokenHolder, 0x0, _amount, _data, _operatorData);

        requireMultiple(_amount);
        require(balanceOf(_tokenHolder) >= _amount, "Not enough funds");

        mBalances[_tokenHolder] = mBalances[_tokenHolder].sub(_amount);
        mTotalSupply = mTotalSupply.sub(_amount);

        emit Burned(_operator, _tokenHolder, _amount, _data, _operatorData);
    }

     
    function callRecipient(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _data,
        bytes _operatorData,
        bool _preventLocking
    )
        internal
    {
        address recipientImplementation = interfaceAddr(_to, "ERC777TokensRecipient");
        if (recipientImplementation != 0) {
            ERC777TokensRecipient(recipientImplementation).tokensReceived(
                _operator, _from, _to, _amount, _data, _operatorData);
        } else if (_preventLocking) {
            require(isRegularAddress(_to), "Cannot send to contract without ERC777TokensRecipient");
        }
    }

     
    function callSender(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _data,
        bytes _operatorData
    )
        internal
    {
        address senderImplementation = interfaceAddr(_from, "ERC777TokensSender");
        if (senderImplementation == 0) { return; }
        ERC777TokensSender(senderImplementation).tokensToSend(
            _operator, _from, _to, _amount, _data, _operatorData);
    }
}

interface ERC20Token {
    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256);
    function balanceOf(address owner) public view returns (uint256);
    function transfer(address to, uint256 amount) public returns (bool);
    function transferFrom(address from, address to, uint256 amount) public returns (bool);
    function approve(address spender, uint256 amount) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

  
contract ERC777ERC20BaseToken is ERC20Token, ERC777BaseToken {
    bool internal mErc20compatible;

    mapping(address => mapping(address => uint256)) internal mAllowed;

    constructor(
        string _name,
        string _symbol,
        uint256 _granularity,
        address[] _defaultOperators,
        address _feeRecipient
    )
        internal ERC777BaseToken(_name, _symbol, _granularity, _defaultOperators, _feeRecipient)
    {
        mErc20compatible = true;
        setInterfaceImplementation("ERC20Token", this);
    }

     
    modifier erc20 () {
        require(mErc20compatible, "ERC20 is disabled");
        _;
    }

     
    function decimals() public erc20 view returns (uint8) { return uint8(18); }

     
    function transfer(address _to, uint256 _amount) 
    public 
    erc20 
    returns (bool success) {
        doSend(msg.sender, msg.sender, _to, _amount, "", "", false);
        return true;
    }

     
    function transferFrom(address _from, address _to, uint256 _amount) 
    public 
    erc20 
    returns (bool success) {
        require(_amount <= mAllowed[_from][msg.sender], "Not enough funds allowed");

         
        mAllowed[_from][msg.sender] = mAllowed[_from][msg.sender].sub(_amount);
        doSend(msg.sender, _from, _to, _amount, "", "", false);
        return true;
    }

     
    function approve(address _spender, uint256 _amount) public erc20 returns (bool success) {
        mAllowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

     
    function allowance(address _owner, address _spender) public erc20 view returns (uint256 remaining) {
        return mAllowed[_owner][_spender];
    }
    
     
    function doSend(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _data,
        bytes _operatorData,
        bool _preventLocking
    )
        internal
    {
        super.doSend(_operator, _from, _to, _amount, _data, _operatorData, _preventLocking);
        if (mErc20compatible) { emit Transfer(_from, _to, _amount); }
    }

     
    function doBurn(address _operator, address _tokenHolder, uint256 _amount, bytes _data, bytes _operatorData)
        internal
    {
        super.doBurn(_operator, _tokenHolder, _amount, _data, _operatorData);
        if (mErc20compatible) { emit Transfer(_tokenHolder, 0x0, _amount); }
    }
}


 
contract CAN777 is ERC777ERC20BaseToken {

    string internal mURI;

    event ERC20Enabled();
    event ERC20Disabled();

     
    constructor(
        string _name,
        string _symbol,
        string _uri,
        uint256 _granularity,
        address[] _defaultOperators,
        address _feeRecipient,
        uint256 _initialSupply
    )
        public ERC777ERC20BaseToken(_name, _symbol, _granularity, _defaultOperators, _feeRecipient)
    {
        mURI = _uri;
        doMint(msg.sender, _initialSupply, "");
    }


     
    function() public payable { } 

     
    function updateDetails(string _updatedName, string _updatedSymbol, string _updatedURI) 
    public 
    onlyOwner {
        mName = _updatedName;
        mSymbol = _updatedSymbol;
        mURI = _updatedURI;
    }

     
    function URI() 
    public 
    view 
    returns (string) { 
        return mURI; 
    }

     
    function disableERC20() 
    public 
    onlyOwner {
        mErc20compatible = false;
        setInterfaceImplementation("ERC20Token", 0x0);
        emit ERC20Disabled();
    }

     
    function enableERC20() 
    public 
    onlyOwner {
        mErc20compatible = true;
        setInterfaceImplementation("ERC20Token", this);
        emit ERC20Enabled();
    }

     
    function doMint(address _tokenHolder, uint256 _amount, bytes _operatorData) 
    private {
        requireMultiple(_amount);
        mTotalSupply = mTotalSupply.add(_amount);
        mBalances[_tokenHolder] = mBalances[_tokenHolder].add(_amount);

        emit Minted(msg.sender, _tokenHolder, _amount, _operatorData);
        if (mErc20compatible) { 
            emit Transfer(0x0, _tokenHolder, _amount); 
        }
    }
}