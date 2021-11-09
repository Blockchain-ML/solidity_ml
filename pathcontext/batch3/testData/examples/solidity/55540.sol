pragma solidity ^0.4.24;

 

contract Token {
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success);
    function balanceOf(address _owner) public view returns (uint256 balance);
}

 

contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Ownable() public {
        owner = msg.sender; 
    }

     
    function transferTo(address _to) public onlyOwner returns (bool) {
        require(_to != address(0));
        owner = _to;
        return true;
    } 
}

 

 
contract Oracle is Ownable {
    uint256 public constant VERSION = 4;

    event NewSymbol(bytes32 _currency);

    mapping(bytes32 => bool) public supported;
    bytes32[] public currencies;

     
    function url() public view returns (string);

     
    function getRate(bytes32 symbol, bytes data) public returns (uint256 rate, uint256 decimals);

     
    function addCurrency(string ticker) public onlyOwner returns (bool) {
        bytes32 currency = encodeCurrency(ticker);
        NewSymbol(currency);
        supported[currency] = true;
        currencies.push(currency);
        return true;
    }

     
    function encodeCurrency(string currency) public pure returns (bytes32 o) {
        require(bytes(currency).length <= 32);
        assembly {
            o := mload(add(currency, 32))
        }
    }
    
     
    function decodeCurrency(bytes32 b) public pure returns (string o) {
        uint256 ns = 256;
        while (true) { if (ns == 0 || (b<<ns-8) != 0) break; ns -= 8; }
        assembly {
            ns := div(ns, 8)
            o := mload(0x40)
            mstore(0x40, add(o, and(add(add(ns, 0x20), 0x1f), not(0x1f))))
            mstore(o, ns)
            mstore(add(o, 32), b)
        }
    }
    
}

 

contract Engine {
    uint256 public VERSION;
    string public VERSION_NAME;

    enum Status { initial, lent, paid, destroyed }
    struct Approbation {
        bool approved;
        bytes data;
        bytes32 checksum;
    }

    function getTotalLoans() public view returns (uint256);
    function getOracle(uint index) public view returns (Oracle);
    function getBorrower(uint index) public view returns (address);
    function getCosigner(uint index) public view returns (address);
    function ownerOf(uint256) public view returns (address owner);
    function getCreator(uint index) public view returns (address);
    function getAmount(uint index) public view returns (uint256);
    function getPaid(uint index) public view returns (uint256);
    function getDueTime(uint index) public view returns (uint256);
    function getApprobation(uint index, address _address) public view returns (bool);
    function getStatus(uint index) public view returns (Status);
    function isApproved(uint index) public view returns (bool);
    function getPendingAmount(uint index) public returns (uint256);
    function getCurrency(uint index) public view returns (bytes32);
    function cosign(uint index, uint256 cost) external returns (bool);
    function approveLoan(uint index) public returns (bool);
    function transfer(address to, uint256 index) public returns (bool);
    function takeOwnership(uint256 index) public returns (bool);
    function withdrawal(uint index, address to, uint256 amount) public returns (bool);
}

 

 
contract Cosigner {
    uint256 public constant VERSION = 2;

     
    function url() public view returns (string);

     
    function cost(address engine, uint256 index, bytes data, bytes oracleData) public view returns (uint256);

     
    function requestCosign(Engine engine, uint256 index, bytes data, bytes oracleData) public returns (bool);

     
    function claim(address engine, uint256 index, bytes oracleData) public returns (bool);
}

 

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x + y;
        require((z >= x) && (z >= y), "Add overflow");
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256) {
        require(x >= y, "Sub underflow");
        uint256 z = x - y;
        return z;
    }

    function mult(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x * y;
        require((x == 0)||(z/x == y), "Mult overflow");
        return z;
    }
}

 

contract ERC721Base {
    using SafeMath for uint256;

    uint256 private _count;

    mapping(uint256 => address) private _holderOf;
    mapping(address => uint256[]) private _assetsOf;
    mapping(address => mapping(address => bool)) private _operators;
    mapping(uint256 => address) private _approval;
    mapping(uint256 => uint256) private _indexOfAsset;

    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;
    bytes4 private constant ERC721_RECEIVED_LEGACY = 0xf0b9e5ba;

    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

     
     
     

     
    function totalSupply() external view returns (uint256) {
        return _totalSupply();
    }
    function _totalSupply() internal view returns (uint256) {
        return _count;
    }

     
     
     

     
    function ownerOf(uint256 assetId) external view returns (address) {
        return _ownerOf(assetId);
    }
    function _ownerOf(uint256 assetId) internal view returns (address) {
        return _holderOf[assetId];
    }

     
     
     
     
    function balanceOf(address owner) external view returns (uint256) {
        return _balanceOf(owner);
    }
    function _balanceOf(address owner) internal view returns (uint256) {
        return _assetsOf[owner].length;
    }

     
     
     

     
    function isApprovedForAll(address operator, address assetHolder)
        external view returns (bool)
    {
        return _isApprovedForAll(operator, assetHolder);
    }
    function _isApprovedForAll(address operator, address assetHolder)
        internal view returns (bool)
    {
        return _operators[assetHolder][operator];
    }

     
    function getApprovedAddress(uint256 assetId) external view returns (address) {
        return _getApprovedAddress(assetId);
    }
    function _getApprovedAddress(uint256 assetId) internal view returns (address) {
        return _approval[assetId];
    }

     
    function isAuthorized(address operator, uint256 assetId) external view returns (bool) {
        return _isAuthorized(operator, assetId);
    }
    function _isAuthorized(address operator, uint256 assetId) internal view returns (bool)
    {
        require(operator != 0);
        address owner = _ownerOf(assetId);
        if (operator == owner) {
            return true;
        }
        return _isApprovedForAll(operator, owner) || _getApprovedAddress(assetId) == operator;
    }

     
     
     

     
    function setApprovalForAll(address operator, bool authorized) external {
        return _setApprovalForAll(operator, authorized);
    }
    function _setApprovalForAll(address operator, bool authorized) internal {
        if (authorized) {
            require(!_isApprovedForAll(operator, msg.sender));
            _addAuthorization(operator, msg.sender);
        } else {
            require(_isApprovedForAll(operator, msg.sender));
            _clearAuthorization(operator, msg.sender);
        }
        emit ApprovalForAll(operator, msg.sender, authorized);
    }

     
    function approve(address operator, uint256 assetId) external {
        address holder = _ownerOf(assetId);
        require(msg.sender == holder || _isApprovedForAll(msg.sender, holder));
        require(operator != holder);
        if (_getApprovedAddress(assetId) != operator) {
            _approval[assetId] = operator;
            emit Approval(holder, operator, assetId);
        }
    }

    function _addAuthorization(address operator, address holder) private {
        _operators[holder][operator] = true;
    }

    function _clearAuthorization(address operator, address holder) private {
        _operators[holder][operator] = false;
    }

     
     
     

    function _addAssetTo(address to, uint256 assetId) internal {
        _holderOf[assetId] = to;

        uint256 length = _balanceOf(to);

        _assetsOf[to].push(assetId);

        _indexOfAsset[assetId] = length;

        _count = _count.add(1);
    }

    function _removeAssetFrom(address from, uint256 assetId) internal {
        uint256 assetIndex = _indexOfAsset[assetId];
        uint256 lastAssetIndex = _balanceOf(from).sub(1);
        uint256 lastAssetId = _assetsOf[from][lastAssetIndex];

        _holderOf[assetId] = 0;

         
        _assetsOf[from][assetIndex] = lastAssetId;

         
        _assetsOf[from][lastAssetIndex] = 0;
        _assetsOf[from].length--;

         
        if (_assetsOf[from].length == 0) {
            delete _assetsOf[from];
        }

         
        _indexOfAsset[assetId] = 0;
        _indexOfAsset[lastAssetId] = assetIndex;

        _count = _count.sub(1);
    }

    function _clearApproval(address holder, uint256 assetId) internal {
        if (_ownerOf(assetId) == holder && _approval[assetId] != 0) {
            _approval[assetId] = 0;
            emit Approval(holder, 0, assetId);
        }
    }

     
     
     

    function _generate(uint256 assetId, address beneficiary) internal {
        require(_holderOf[assetId] == 0, "Asset already exists");

        _addAssetTo(beneficiary, assetId);

        emit Transfer(0x0, beneficiary, assetId);
    }

    function _destroy(uint256 assetId) internal {
        address holder = _holderOf[assetId];
        require(holder != 0);

        _removeAssetFrom(holder, assetId);

        emit Transfer(holder, 0x0, assetId);
    }

     
     
     

    modifier onlyHolder(uint256 assetId) {
        require(_ownerOf(assetId) == msg.sender);
        _;
    }

    modifier onlyAuthorized(uint256 assetId) {
        require(_isAuthorized(msg.sender, assetId));
        _;
    }

    modifier isCurrentOwner(address from, uint256 assetId) {
        require(_ownerOf(assetId) == from);
        _;
    }

     
    function safeTransferFrom(address from, address to, uint256 assetId) external {
        return _doTransferFrom(from, to, assetId, "", true);
    }

     
    function safeTransferFrom(address from, address to, uint256 assetId, bytes userData) external {
        return _doTransferFrom(from, to, assetId, userData, true);
    }

     
    function transferFrom(address from, address to, uint256 assetId) external {
        return _doTransferFrom(from, to, assetId, "", false);
    }

    function _doTransferFrom(
        address from,
        address to,
        uint256 assetId,
        bytes userData,
        bool doCheck
    )
        onlyAuthorized(assetId)
        internal
    {
        _moveToken(from, to, assetId, userData, doCheck);
    }

    function _moveToken(
        address from,
        address to,
        uint256 assetId,
        bytes userData,
        bool doCheck
    )
        internal
        isCurrentOwner(from, assetId)
    {
        address holder = _holderOf[assetId];
        _removeAssetFrom(holder, assetId);
        _clearApproval(holder, assetId);
        _addAssetTo(to, assetId);

        if (doCheck && _isContract(to)) {
             
            uint256 success;
            bytes32 result;
             
             
            (success, result) = _noThrowCall(
                to,
                abi.encodeWithSelector(
                    ERC721_RECEIVED,
                    msg.sender,
                    holder,
                    assetId,
                    userData
                )
            );

            if (success != 1 || result != ERC721_RECEIVED) {
                 
                 
                (success, result) = _noThrowCall(
                    to,
                    abi.encodeWithSelector(
                        ERC721_RECEIVED_LEGACY,
                        holder,
                        assetId,
                        userData
                    )
                );

                require(success == 1 && result == ERC721_RECEIVED_LEGACY);
            }
        }

        emit Transfer(holder, to, assetId);
    }

     

     
    function supportsInterface(bytes4 _interfaceID) external view returns (bool) {

        if (_interfaceID == 0xffffffff) {
            return false;
        }
        return _interfaceID == 0x01ffc9a7 || _interfaceID == 0x80ac58cd;
    }

     
     
     

    function _isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function _noThrowCall(
        address _contract,
        bytes _data
    ) internal returns (uint256 success, bytes32 result) {
        assembly {
            let x := mload(0x40)

            success := call(
                            gas,                   
                            _contract,             
                            0,                     
                            add(0x20, _data),      
                            mload(_data),          
                            x,                     
                            0x20                   
                        )

            result := mload(x)
        }
    }
}

 

interface ERC165 {
     
     
     
     
     
     
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

 

 
contract Model is ERC165 {
     
     
     

     
    event Created(bytes32 indexed _id);

     
    event ChangedStatus(bytes32 indexed _id, uint256 _timestamp, uint256 _status);

     
    event ChangedObligation(bytes32 indexed _id, uint256 _timestamp, uint256 _debt);

     
    event ChangedFrequency(bytes32 indexed _id, uint256 _timestamp, uint256 _frequency);

     
    event ChangedDueTime(bytes32 indexed _id, uint256 _timestamp, uint256 _status);

     
    event ChangedFinalTime(bytes32 indexed _id, uint256 _timestamp, uint64 _dueTime);

     
    event AddedDebt(bytes32 indexed _id, uint256 _amount);

     
    event AddedPaid(bytes32 indexed _id, uint256 _paid);

     
    bytes4 internal debtModelInterface =
    this.isOperator.selector
    ^ this.validate.selector
    ^ this.getStatus.selector
    ^ this.getPaid.selector
    ^ this.getObligation.selector
    ^ this.getClosingObligation.selector
    ^ this.getDueTime.selector
    ^ this.getFinalTime.selector
    ^ this.getFrequency.selector
    ^ this.getEstimateObligation.selector
    ^ this.create.selector
    ^ this.addPaid.selector
    ^ this.addDebt.selector
    ^ this.run.selector;

    uint256 public constant STATUS_ONGOING = 1;
    uint256 public constant STATUS_PAID = 2;
    uint256 public constant STATUS_ERROR = 4;

     
     
     

     
    function isOperator(address operator) external view returns (bool canOperate);

     
    function validate(bytes data) external view returns (bool isValid);

     
     
     

     
    function getStatus(bytes32 id) external view returns (uint256 status);

     
    function getPaid(bytes32 id) external view returns (uint256 paid);

     
    function getObligation(bytes32 id, uint64 timestamp) external view returns (uint256 amount, bool defined);

     
    function getClosingObligation(bytes32 id) external view returns (uint256 amount);

     
    function getDueTime(bytes32 id) external view returns (uint256 timestamp);

     
     
     

     
    function getFrequency(bytes32 id) external view returns (uint256 frequency);

     
    function getFinalTime(bytes32 id) external view returns (uint256 timestamp);

     
    function getEstimateObligation(bytes32 id) external view returns (uint256 amount);

     
     
     

     
    function create(bytes32 id, bytes data) external returns (bool success);

     
    function addPaid(bytes32 id, uint256 amount) external returns (uint256 real);

     
    function addDebt(bytes32 id, uint256 amount) external returns (bool added);

     
     
     

     
    function run(bytes32 id) external returns (bool effect);
}

 

interface IOracle {
    function getRate(bytes32 symbol, bytes data) external returns (uint256 rate, uint256 decimals);
}

contract DebtEngine is ERC721Base {
    event Created(bytes32 indexed _id, uint256 _nonce, bytes _data);
    event Created2(bytes32 indexed _id, uint256 _nonce, bytes _data);
    event Paid(bytes32 indexed _id, address _sender, address _origin, uint256 _requested, uint256 _requestedTokens, uint256 _paid, uint256 _tokens);
    event ReadedOracle(bytes32 indexed _id, uint256 _amount, uint256 _decimals);
    event Withdrawn(bytes32 indexed _id, address _sender, address _to, uint256 _amount);
    event Error(bytes32 indexed _id, address _sender, uint256 _value, uint256 _gasLeft, uint256 _gasLimit, bytes _callData);

    Token public token;

    mapping(bytes32 => Debt) public debts;
    mapping(address => uint256) public nonces;

    struct Debt {
        bool error;
        bytes8 currency;
        uint128 balance;
        Model model;
        address creator;
        address oracle;
    }

    constructor(Token _token) public {
        token = _token;
    }

    function name() external pure returns (string _name) {
        _name = "RCN Debt Record";
    }

    function symbol() external pure returns (string _symbol) {
        _symbol = "RDR";
    }

    function create(
        Model _model,
        address _owner,
        address _oracle,
        bytes8 _currency,
        bytes _data
    ) external returns (bytes32 id) {
        uint256 nonce = nonces[msg.sender]++;
        id = _buildId(msg.sender, nonce, false);

        debts[id] = Debt({
            error: false,
            currency: _currency,
            balance: 0,
            creator: msg.sender,
            model: _model,
            oracle: _oracle
        });

        _generate(uint256(id), _owner);
        require(_model.create(id, _data), "Error creating debt in model");

        emit Created({
            _id: id,
            _nonce: nonce,
            _data: _data
        });
    }

    function create2(
        Model _model,
        address _owner,
        address _oracle,
        bytes8 _currency,
        uint256 _nonce,
        bytes _data
    ) external returns (bytes32 id) {
        id = _buildId(msg.sender, _nonce, true);

        debts[id] = Debt({
            error: false,
            currency: _currency,
            balance: 0,
            creator: msg.sender,
            model: _model,
            oracle: _oracle
        });

        _generate(uint256(id), _owner);
        require(_model.create(id, _data), "Error creating debt in model");

        emit Created2({
            _id: id,
            _nonce: _nonce,
            _data: _data
        });
    }

    function buildId(
        address _creator,
        uint256 _nonce,
        bool _method2
    ) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_creator, _nonce, _method2));
    }

    function _buildId(
        address _creator,
        uint256 _nonce,
        bool _method2
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_creator, _nonce, _method2));
    }

    function pay(
        bytes32 _id,
        uint256 _amount,
        address _origin,
        bytes _oracleData
    ) external returns (uint256 paid, uint256 paidToken) {
        Debt storage debt = debts[_id];
        if (debt.error) delete debt.error;

         
        paid = _safePay(_id, debt.model, _amount);
        require(paid <= _amount, "Paid can&#39;t be more than requested");

        IOracle oracle = IOracle(debt.oracle);
        if (oracle != address(0)) {
             
            (uint256 rate, uint256 decimals) = oracle.getRate(debt.currency, _oracleData);
            emit ReadedOracle(_id, rate, decimals);
            paidToken = toToken(paid, rate, decimals);
        } else {
            paidToken = paid;
        }

         
        require(token.transferFrom(msg.sender, address(this), paidToken), "Error pulling payment tokens");

         
        uint256 newBalance = paidToken.add(debt.balance);
        require(newBalance < 340282366920938463463374607431768211456, "uint128 Overflow");
        debt.balance = uint128(newBalance);

         
        emit Paid({
            _id: _id,
            _sender: msg.sender,
            _origin: _origin,
            _requested: _amount,
            _requestedTokens: 0,
            _paid: paid,
            _tokens: paidToken
        });
    }
    
    function payToken(
        bytes32 id,
        uint256 amount,
        address origin,
        bytes oracleData
    ) external returns (uint256 paid, uint256 paidToken) {
        Debt storage debt = debts[id];
        if (debt.error) delete debt.error;

         
        IOracle oracle = IOracle(debt.oracle);

        uint256 rate;
        uint256 decimals;
        uint256 available;

         
        if (oracle != address(0)) {
            (rate, decimals) = oracle.getRate(debt.currency, oracleData);
            emit ReadedOracle(id, rate, decimals);
            available = fromToken(amount, rate, decimals);
        } else {
            available = amount;
        }

         
        paid = _safePay(id, debt.model, available);
        require(paid <= available, "Paid can&#39;t exceed available");

         
        if (oracle != address(0)) {
            paidToken = toToken(paid, rate, decimals);
            require(paidToken <= amount, "Paid can&#39;t exceed requested");
        } else {
            paidToken = paid;
        }

         
        require(token.transferFrom(msg.sender, address(this), paidToken), "Error pulling tokens");

         
         
        available = paidToken.add(debt.balance);
        require(available < 340282366920938463463374607431768211456, "uint128 Overflow");
        debt.balance = uint128(available);

         
        emit Paid({
            _id: id,
            _sender: msg.sender,
            _origin: origin,
            _requested: 0,
            _requestedTokens: amount,
            _paid: paid,
            _tokens: paidToken
        });
    }

    function _safePay(
        bytes32 _id,
        Model _model,
        uint256 _available
    ) internal returns (uint256) {
        (uint256 success, bytes32 paid) = _safeGasCall(
            _model,
            abi.encodeWithSelector(
                _model.addPaid.selector,
                _id,
                _available
            )
        );

        if (success != 0) {
            return uint256(paid);
        } else {
            emit Error({
                _id: _id,
                _sender: msg.sender,
                _value: msg.value,
                _gasLeft: gasleft(),
                _gasLimit: block.gaslimit,
                _callData: msg.data
            });
            debts[_id].error = true;
        }
    }

     
    function toToken(uint256 _amount, uint256 _rate, uint256 _decimals) internal pure returns (uint256) {
        require(_decimals <= 18, "Decimals limit reached");
        return _rate.mult(_amount).mult((10 ** (18 - _decimals))) / 1000000000000000000;
    }

     
    function fromToken(uint256 _amount, uint256 _rate, uint256 _decimals) internal pure returns (uint256) {
        require(_decimals <= 18, "Decimals limit reached");
        return (_amount.mult(1000000000000000000) / _rate) / 10 ** (18 - _decimals);
    }

    function run(bytes32 _id) external returns (bool) {
        Debt storage debt = debts[_id];
        if (debt.error) delete debt.error;

        (uint256 success, bytes32 result) = _safeGasCall(
            debt.model,
            abi.encodeWithSelector(
                debt.model.run.selector,
                _id
            )
        );

        if (success != 0) {
            return result == bytes32(1);
        } else {
            emit Error({
                _id: _id,
                _sender: msg.sender,
                _value: 0,
                _gasLeft: gasleft(),
                _gasLimit: block.gaslimit,
                _callData: msg.data
            });
            debt.error = true;
        }
    }

    function withdrawal(bytes32 _id, address _to) external returns (uint256 amount) {
        require(_isAuthorized(msg.sender, uint256(_id)), "Sender not authorized");
        Debt storage debt = debts[_id];
        amount = debt.balance;
        debt.balance = 0;
        require(token.transfer(_to, amount), "Error sending tokens");
        emit Withdrawn({
            _id: _id,
            _sender: msg.sender,
            _to: _to,
            _amount: amount
        });
    }

    function withdrawalList(bytes32[] _ids, address _to) external returns (uint256 amount) {
        bytes32 target;
        uint256 balance;
        for (uint256 i = 0; i < _ids.length; i++) {
            target = _ids[i];
            if(_isAuthorized(msg.sender, uint256(target))) {
                balance = debts[target].balance;
                debts[target].balance = 0;
                amount += balance;
                emit Withdrawn({
                    _id: target,
                    _sender: msg.sender,
                    _to: _to,
                    _amount: balance
                });
            }
        }
        require(token.transfer(_to, amount), "Error sending tokens");
    }

    function getStatus(bytes32 _id) external view returns (uint256) {
        Debt storage debt = debts[_id];
        if (debt.error) {
            return 4;
        } else {
            (uint256 success, bytes32 result) = _safeGasStaticCall(
                debt.model,
                abi.encodeWithSelector(
                    debt.model.getStatus.selector,
                    _id
                )
            );
            return success == 1 ? uint256(result) : 4;
        }
    }

    function _safeGasStaticCall(
        address _contract,
        bytes _data
    ) internal view returns (uint256 success, bytes32 result) {
        uint256 _gas = (block.gaslimit * 80) / 100;
        _gas = gasleft() < _gas ? gasleft() : _gas;
        assembly {
            let x := mload(0x40)
            success := staticcall(
                            _gas,                  
                            _contract,             
                            add(0x20, _data),      
                            mload(_data),          
                            x,                     
                            0x20                   
                        )

            result := mload(x)
        }
    }

    function _safeGasCall(
        address _contract,
        bytes _data
    ) internal returns (uint256 success, bytes32 result) {
        uint256 _gas = (block.gaslimit * 80) / 100;
        _gas = gasleft() < _gas ? gasleft() : _gas;
        assembly {
            let x := mload(0x40)
            success := call(
                            _gas,                  
                            _contract,             
                            0,                     
                            add(0x20, _data),      
                            mload(_data),          
                            x,                     
                            0x20                   
                        )

            result := mload(x)
        }
    }
}

 

interface LoanRequester {
    function loanRequested(bytes32[8] requestData, bytes loanData, bool isBorrower, uint256 returnFlag) external returns (uint256);
}

 

contract LoanCreator {
    DebtEngine public debtEngine;
    Token public token;

    bytes32[] public directory;
    mapping(bytes32 => Request) public requests;
    mapping(bytes32 => bool) public canceledSettles;

    constructor(DebtEngine _debtEngine) public {
        debtEngine = _debtEngine;
        token = debtEngine.token();
        require(token != address(0), "Error loading token");
    }
    
    function getDirectory() external view returns (bytes32[]) { return directory; }

    function getBorrower(uint256 id) external view returns (address) { 
        return requests[bytes32(id)].borrower;
    }

    function getCreator(uint256 id) external view returns (address) { return requests[bytes32(id)].creator; }
    function getOracle(uint256 id) external view returns (address) { return requests[bytes32(id)].oracle; }
    function getCosigner(uint256 id) external view returns (address) { return requests[bytes32(id)].cosigner; }
    function getCurrency(uint256 id) external view returns (bytes32) { return requests[bytes32(id)].currency; }
    function getAmount(uint256 id) external view returns (uint256) { return requests[bytes32(id)].amount; }

    function getExpirationRequest(uint256 id) external view returns (uint256) { return requests[bytes32(id)].expiration; }
    function getApproved(uint256 id) external view returns (bool) { return requests[bytes32(id)].approved; }
    function getDueTime(uint256 id) external view returns (uint256) { return Model(requests[bytes32(id)].model).getDueTime(bytes32(id)); }
    function getLoanData(uint256 id) external view returns (bytes) { return requests[bytes32(id)].loanData; }

    function getStatus(uint256 id) external view returns (uint256) {
        Request storage request = requests[bytes32(id)];
        return request.open ? 0 : Model(request.model).getStatus(bytes32(id));
    }

    struct Request {
        bool open;
        bool approved;
        bytes8 currency;
        uint64 position;
        uint64 expiration;
        uint128 amount;
        address cosigner;
        address model;
        address creator;
        address oracle;
        address borrower;
        uint256 nonce;
        bytes loanData;
    }

    function calcFutureDebt(
        address creator,
        uint256 nonce
    ) external view returns (bytes32) {
        return debtEngine.buildId(
            address(this),
            uint256(keccak256(abi.encodePacked(creator, nonce))),
            true
        );
    }

    function requestLoan(
        bytes8 currency,
        uint128 amount,
        address model,
        address oracle,
        address borrower,
        uint256 nonce,
        uint64 expiration,
        bytes loanData
    ) external returns (bytes32 futureDebt) {
        require(borrower != address(0), "The request should have a borrower");
        require(Model(model).validate(loanData), "The loan data is not valid");

        uint256 internalNonce = uint256(keccak256(abi.encodePacked(msg.sender, nonce)));
        futureDebt = debtEngine.buildId(
            address(this),
            internalNonce,
            true
        );

        require(requests[futureDebt].borrower == address(0), "Request already exist");
        bool approved = msg.sender == borrower;
        uint64 pos;
        if (approved) {
            pos = uint64(directory.push(futureDebt) - 1);
        }

        requests[futureDebt] = Request({
            open: true,
            approved: approved,
            position: pos,
            cosigner: address(0),
            currency: currency,
            amount: amount,
            model: model,
            creator: msg.sender,
            oracle: oracle,
            borrower: borrower,
            nonce: internalNonce,
            loanData: loanData,
            expiration: expiration
        });
    }

    function approveRequest(
        bytes32 futureDebt
    ) external returns (bool) {
        Request storage request = requests[futureDebt];
        require(msg.sender == request.borrower, "Only borrower can approve");
        if (!request.approved) {
            request.position = uint64(directory.push(futureDebt) - 1);
            request.approved = true;
        }
        return true;
    }

    function lend(
        bytes32 futureDebt,
        bytes oracleData,
        address cosigner,
        uint256 cosignerLimit,
        bytes cosignerData
    ) public returns (bool) {
        Request storage request = requests[futureDebt];
        require(request.open, "Request is no longer open");
        require(request.approved, "The request is not approved by the borrower");
        require(request.expiration > now, "The request is expired");

        request.open = false;

        require(
            token.transferFrom(
                msg.sender,
                request.borrower,
                currencyToToken(request.oracle, request.currency, request.amount, oracleData)
            ),
            "Error sending tokens to borrower"
        );

         
        require(
            debtEngine.create2(
                Model(request.model),
                msg.sender,
                request.oracle,
                request.currency,
                request.nonce,
                request.loanData
            ) == futureDebt,
            "Error creating the debt"
        );

         
        delete request.loanData;

         
        bytes32 last = directory[directory.length - 1];
        requests[last].position = request.position;
        directory[request.position] = last;
        request.position = 0;
        directory.length--;

         
        if (cosigner != address(0)) {
            uint256 auxNonce = request.nonce;
            request.cosigner = address(uint256(cosigner) + 2);
            request.nonce = cosignerLimit;  
            require(Cosigner(cosigner).requestCosign(Engine(address(this)), uint256(futureDebt), cosignerData, oracleData), "Cosign method returned false");
            require(request.cosigner == cosigner, "Cosigner didn&#39;t callback");
            request.nonce = auxNonce;
        }

        return true;
    }

    function requestSignature(
        bytes32[8] requestData,
        bytes loanData
    ) external view returns (bytes32) {
        return keccak256(abi.encodePacked(this, requestData, loanData));
    }

    function _requestSignature(
        bytes32[8] requestData,
        bytes loanData
    ) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(this, requestData, loanData));
    }

    uint256 public constant R_CURRENCY = 0;
    uint256 public constant R_AMOUNT = 1;
    uint256 public constant R_MODEL = 2;
    uint256 public constant R_ORACLE = 3;
    uint256 public constant R_BORROWER = 4;
    uint256 public constant R_NONCE = 5;
    uint256 public constant R_EXPIRATION = 6;
    uint256 public constant R_CREATOR = 7;

    function settleLend(
        bytes32[8] requestData,
        bytes loanData,
        address cosigner,
        uint256 maxCosignerCost,
        bytes cosignerData,
        bytes oracleData,
        bytes creatorSig,
        bytes borrowerSig
    ) public returns (bytes32 futureDebt) {
        require(uint64(requestData[R_EXPIRATION]) > now, "Loan request is expired");
        require(address(requestData[R_BORROWER]) != address(0), "Borrower can&#39;t be 0x0");
        require(address(requestData[R_CREATOR]) != address(0), "Creator can&#39;t be 0x0");

        uint256 internalNonce = uint256(
            keccak256(
                abi.encodePacked(
                    address(requestData[R_CREATOR]),
                    uint256(requestData[R_NONCE]))
                )
            );
        
        futureDebt = debtEngine.buildId(
            address(this),
            internalNonce,
            true
        );
        
        require(requests[futureDebt].borrower == address(0), "Request already exist");

        validateRequest(requestData, loanData, borrowerSig, creatorSig);

        require(
            token.transferFrom(
                msg.sender,
                address(requestData[R_BORROWER]),
                currencyToToken(requestData, oracleData)
            ),
            "Error sending tokens to borrower"
        );

         
        require(createDebt(requestData, loanData, internalNonce) == futureDebt, "Error creating debt registry");

        requests[futureDebt] = Request({
            open: false,
            approved: true,
            cosigner: cosigner,
            currency: bytes8(requestData[R_CURRENCY]),
            amount: uint128(requestData[R_AMOUNT]),
            model: address(requestData[R_MODEL]),
            creator: address(requestData[R_CREATOR]),
            oracle: address(requestData[R_ORACLE]),
            borrower: address(requestData[R_BORROWER]),
            nonce: cosigner != address(0) ? maxCosignerCost : internalNonce,
            loanData: "",
            position: 0,
            expiration: uint64(requestData[R_EXPIRATION])
        });
        
        Request storage request = requests[futureDebt];

         
        if (cosigner != address(0)) {
            request.cosigner = address(uint256(cosigner) + 2);
            require(Cosigner(cosigner).requestCosign(Engine(address(this)), uint256(futureDebt), cosignerData, oracleData), "Cosign method returned false");
            require(request.cosigner == cosigner, "Cosigner didn&#39;t callback");
            request.nonce = internalNonce;
        }
    }

    function cancel(bytes32 futureDebt) external returns (bool) {
        Request storage request = requests[futureDebt];

        require(
            request.creator == msg.sender || request.borrower == msg.sender,
            "Only borrower or creator can cancel a request"
        );

         
        bytes32 last = directory[directory.length - 1];
        requests[last].position = request.position;
        directory[request.position] = last;
        request.position = 0;
        directory.length--;

        delete request.loanData;
        delete requests[futureDebt];

        return true;
    }

    function settleCancel(
        bytes32[8] requestData,
        bytes loanData
    ) external returns (bool) {
        bytes32 sig = _requestSignature(requestData, loanData);
        require(
            msg.sender == address(requestData[R_BORROWER]) ||
            msg.sender == address(requestData[R_CREATOR]),
            "Only borrower or creator can cancel a settle"
        );
        canceledSettles[sig] = true;
        return true;
    }

    function ecrecovery(bytes32 _hash, bytes _sig) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := and(mload(add(_sig, 65)), 255)
        }

        if (v < 27) {
            v += 27;
        }

        return ecrecover(_hash, v, r, s);
    }

    function validateRequest(
        bytes32[8] requestData,
        bytes loanData,
        bytes borrowerSig,
        bytes creatorSig
    ) internal {
        bytes32 sig = _requestSignature(requestData, loanData);
        require(!canceledSettles[sig], "Settle was canceled");
        
        uint256 expected = uint256(sig) / 2;
        address borrower = address(requestData[R_BORROWER]);
        address creator = address(requestData[R_CREATOR]);

        if (_isContract(borrower)) {
            require(
                LoanRequester(borrower).loanRequested(requestData, loanData, true, uint256(sig)) == expected,
                "Borrower contract rejected the loan"
            );
        } else {
            require(
                borrower == ecrecovery(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", sig)), borrowerSig),
                "Invalid borrower signature"
            );
        }

        if (borrower != creator) {
            if (_isContract(creator)) {
                require(
                    LoanRequester(creator).loanRequested(requestData, loanData, true, uint256(sig)) == expected,
                    "Creator contract rejected the loan"
                );
            } else {
                require(
                    creator == ecrecovery(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", sig)), creatorSig),
                    "Invalid creator signature"
                );
            }
        }
    }

    function createDebt(
        bytes32[8] requestData,
        bytes loanData,
        uint256 internalNonce
    ) internal returns (bytes32) {
        return debtEngine.create2(
            Model(address(requestData[R_MODEL])),
            msg.sender,
            address(requestData[R_ORACLE]),
            bytes8(requestData[R_CURRENCY]),
            internalNonce,
            loanData
        );
    }

    function cosign(uint256 futureDebt, uint256 cost) external returns (bool) {
        Request storage request = requests[bytes32(futureDebt)];
        require(request.position == 0, "Request cosigned is invalid");
        require(request.cosigner != address(0), "Cosigner not valid");
        require(request.expiration > now, "Request is expired");
        require(request.cosigner == address(uint256(msg.sender) + 2), "Cosigner not valid");
        request.cosigner = msg.sender;
        require(request.nonce >= cost || request.nonce == 0, "Cosigner cost exceeded");
        require(token.transferFrom(debtEngine.ownerOf(futureDebt), msg.sender, cost), "Error paying cosigner");
        return true;
    }

    function currencyToToken(
        bytes32[8] requestData,
        bytes oracleData
    ) internal returns (uint256) {
        return currencyToToken(
            address(requestData[R_ORACLE]),
            bytes16(requestData[R_CURRENCY]),
            uint256(requestData[R_AMOUNT]),
            oracleData
        );
    }

    function currencyToToken(
        address oracle,
        bytes16 currency,
        uint256 amount,
        bytes oracleData
    ) internal returns (uint256) {
        if (oracle != 0x0) {
            (uint256 rate, uint256 decimals) = Oracle(oracle).getRate(currency, oracleData);
            return (rate * amount * 10 ** (18 - decimals)) / 10 ** 18;
        } else {
            return amount;
        }
    }

    function _isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}