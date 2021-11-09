pragma solidity ^0.4.24;

 

interface IERC165 {
     
     
     
     
     
     
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

 

 
contract RateOracle is IERC165 {
    uint256 public constant VERSION = 5;
    bytes4 internal constant RATE_ORACLE_INTERFACE = 0xa265d8e0;

    constructor() internal {}

     
    function symbol() external view returns (string);

     
    function name() external view returns (string);

     
    function decimals() external view returns (uint256);

     
    function token() external view returns (address);

     
    function currency() external view returns (bytes32);
    
     
    function maintainer() external view returns (string);

     
    function url() external view returns (string);

     
    function readSample(bytes _data) external returns (uint256 _tokens, uint256 _equivalent);
}

 

 
contract ERC165 is IERC165 {
    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;
     

     
    mapping(bytes4 => bool) private _supportedInterfaces;

     
    constructor()
        internal
    {
        _registerInterface(_InterfaceId_ERC165);
    }

     
    function supportsInterface(bytes4 interfaceId)
        external
        view
        returns (bool)
    {
        return _supportedInterfaces[interfaceId];
    }

     
    function _registerInterface(bytes4 interfaceId)
        internal
    {
        require(interfaceId != 0xffffffff, "Can&#39;t register 0xffffffff");
        _supportedInterfaces[interfaceId] = true;
    }
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

 

contract Token {
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success);
    function balanceOf(address _owner) public view returns (uint256 balance);
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

 

contract OracleAdapter is RateOracle, ERC165 {
    Oracle public legacyOracle;

    string private isymbol;
    string private iname;
    string private imaintainer;

    uint256 private idecimals;
    bytes32 private icurrency;

    address private itoken;

    constructor(
        Oracle _legacyOracle,
        string _symbol,
        string _name,
        string _maintainer,
        uint256 _decimals,
        bytes32 _currency,
        address _token
    ) public {
        legacyOracle = _legacyOracle;
        isymbol = _symbol;
        iname = _name;
        imaintainer = _maintainer;
        idecimals = _decimals;
        icurrency = _currency;
        itoken = _token;

        _registerInterface(RATE_ORACLE_INTERFACE);
    }

    function symbol() external view returns (string) { return isymbol; }

    function name() external view returns (string) { return iname; }

    function decimals() external view returns (uint256) { return idecimals; }

    function token() external view returns (address) { return itoken; }

    function currency() external view returns (bytes32) { return icurrency; }
    
    function maintainer() external view returns (string) { return imaintainer; }

    function url() external view returns (string) {
        return legacyOracle.url();
    }

    function readSample(bytes _data) external returns (uint256 _tokens, uint256 _equivalent) {
        (_tokens, _equivalent) = legacyOracle.getRate(icurrency, _data);
        _equivalent = 10 ** _equivalent;
    }
}