pragma solidity ^0.5.0;

 
contract ITickerService {

     
    function checkValidity(string memory _symbol, address _owner, string memory _tokenName) public returns(bool);

     
    function getTickerDetail(string memory _symbol) public view returns(address _issuer, uint256 _timestamp, string memory _tokenName, bool _status);

     
    function checkTickerExists(string memory _symbol) public view returns(bool);
}

 
library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
         
         
         
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        return a / b;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

 
contract Ownable {

    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
      address indexed previousOwner,
      address indexed newOwner
    );


     
    constructor() public {
        owner = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

     
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

     
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

 
library EncoderUtil {

     
    function encode(string memory _str) public pure returns(bytes32) {
        require(bytes(_str).length != 0, "Encode value must not empty");
        return keccak256(abi.encodePacked(_str));
    }

     
    function encode(address _addr) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_addr));
    }
}

 
contract ServiceStorage is Ownable {

     
    mapping(bytes32 => address) public serviceMap;

     
    event LogServiceStorageUpdate(string _key, address _oldValue, address _newValue);

     
    function get(string memory _key) public view returns(address){
        bytes32 key = EncoderUtil.encode(_key);
        require(serviceMap[key] != address(0), "No result");
        return serviceMap[key];
    }

     
    function update(string memory _key, address _value) public onlyOwner {
        bytes32 key = EncoderUtil.encode(_key);
        emit LogServiceStorageUpdate(_key, serviceMap[key], _value);
        serviceMap[key] = _value;
    }

}

 
contract ServiceHelper is Ownable {

    address public servicesStorageAddress;
    address public moduleServiceAddress;
    address public securityTokenServiceAddress;
    address public tickerServiceAddress;
    address public platformTokenAddress;

    ServiceStorage serviceStorage;

    constructor (address _servicesStorageAddress) public {
        require(_servicesStorageAddress != address(0), "Invlid address");
        servicesStorageAddress = _servicesStorageAddress;
        serviceStorage = ServiceStorage(_servicesStorageAddress);
    }

    function loadData() public onlyOwner {
        moduleServiceAddress = serviceStorage.get("moduleService");
        securityTokenServiceAddress = serviceStorage.get("securityTokenService");
        tickerServiceAddress = serviceStorage.get("tickerService");
        platformTokenAddress = serviceStorage.get("platformToken");
    }

}

 
contract Pausable {

    event Pause(uint256 pauseTime);
    event Unpause(uint256 unpauseTime);

    bool public paused = false;


     
    modifier whenNotPaused() {
        require(!paused, "Should not pause");
        _;
    }

     
    modifier whenPaused() {
        require(paused, "Should be pause");
        _;
    }

     
    function pause() public whenNotPaused {
        paused = true;
        emit Pause(now);
    }

     
    function unpause() public whenPaused {
        paused = false;
        emit Unpause(now);
    }
}

 
library StringUtil {

     
    function lower(string memory _base) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for(uint i = 0; i < _baseBytes.length; i++) {
            bytes1 b1 = _baseBytes[i];
            if (b1 >= 0x41 && b1 <= 0x5A) {
                b1 = bytes1(uint8(b1)+32);
            }
            _baseBytes[i] = b1;
        }
        return string(_baseBytes);
    }

     
    function upper(string memory _base) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            bytes1 b1 = _baseBytes[i];
            if (b1 >= 0x61 && b1 <= 0x7A) {
                b1 = bytes1(uint8(b1)-32);
            }
            _baseBytes[i] = b1;
        }
        return string(_baseBytes);
    }

     
    function length(string memory _base) internal pure returns (uint) {
        bytes memory _baseBytes = bytes(_base);
        return _baseBytes.length;
    }

     
    function compare(string memory _str1, string memory _str2) internal pure returns(bool){
        return keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2));
    }

     
     
    function stringToBytes32(string memory _source) internal pure returns (bytes32) {
        return bytesToBytes32(bytes(_source), 0);
    }

     
     
    function bytesToBytes32(bytes memory _b, uint _offset) internal pure returns (bytes32) {
        bytes32 result;

        for (uint i = 0; i < _b.length; i++) {
            result |= bytes32(_b[_offset + i] & 0xFF) >> (i * 8);
        }
        return result;
    }

     
    function bytes32ToString(bytes32 _source) internal pure returns (string memory result) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(_source) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint8 j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

     
     
     
     
     
     
     


}

contract IERC20 {

    string public name;
    string public symbol;
    uint8 public decimals;

    event Transfer(
        address indexed _from, 
        address indexed _to, 
        uint256 _value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);
    
    function allowance(address _owner, address _spender) public view returns (uint256);

}

 
contract TickerService is ITickerService, ServiceHelper, Pausable {

    using SafeMath for uint256;
    using StringUtil for string;

     
    uint256 public expiredLimit = 60 * 1 days;
     
    uint256 public registrationFee;    

    struct SymbolDetails {
        address issuer;  
        uint256 timestamp;  
        string tokenName;  
        bool status;  
    }

     
    mapping(string => SymbolDetails) registerSymbols;

     
    event LogRegisterTicker(address indexed _issuer, string _symbol, string _tokenName, uint256 indexed _timestamp );
     
    event LogChangeExpiredLimit(uint256 _oldExpiredLimit, uint256 _newExpiredLimit);
     
    event LogChangeRegistrationFee(uint256 _oldRegistrationFee, uint256 _newRegistrationFee);

     
    constructor(address _servicesStorageAddress, uint256 _registrationFee) public ServiceHelper(_servicesStorageAddress) {
        registrationFee = _registrationFee;
    }

     
    function registerTicker(address _issuer, string memory _symbol, string memory _tokenName) public whenNotPaused {
         
        require(_issuer != address(0), "Invalid address");
         
        require(_symbol.length() > 0 && _symbol.length() <= 10, "Ticker length should always between 0 & 10");
         
        if(registrationFee > 0){
            require((IERC20(platformTokenAddress).transferFrom(msg.sender, address(this), registrationFee)), "Failed transferFrom because of sufficent Allowance is not provided");
        }
         
        string memory symbol = _symbol.upper();

         
        require(expiredCheck(symbol), "Ticker is already reserved");

         
        uint256 timestamp = now;
        
         
        registerSymbols[symbol] = SymbolDetails(_issuer, timestamp, _tokenName, true);

        emit LogRegisterTicker(_issuer, symbol, _tokenName, timestamp);
    }

     
    function checkTickerExists(string memory _symbol) public view returns(bool) {
         
        string memory symbol = _symbol.upper();

        if(registerSymbols[symbol].status != false){
            return true;
        }else{
            return false;
        }
    }


     
    function expiredCheck(string memory _symbol) internal returns(bool) {
         
        if (registerSymbols[_symbol].issuer != address(0)) {
             
            if (now > registerSymbols[_symbol].timestamp.add(expiredLimit) && registerSymbols[_symbol].status == true) {
                 
                registerSymbols[_symbol] = SymbolDetails(address(0), uint256(0), "", false);
                return true;
            }else{
                return false;
            }
        }
        return true;
    }

     
    function checkValidity(string memory _symbol, address _owner, string memory _tokenName) public returns(bool) {
         
        string memory symbol = _symbol.upper();
         
        require(msg.sender == securityTokenServiceAddress, "msg.sender should be SecurityTokenRegistry contract");
         
        require(registerSymbols[symbol].status != true, "Symbol status should not equal to true");
        require(registerSymbols[symbol].issuer == _owner, "Owner of the symbol should matched with the requested issuer address");
        require(registerSymbols[symbol].timestamp.add(expiredLimit) >= now, "Ticker should not be expired");
        registerSymbols[symbol].tokenName = _tokenName;
        registerSymbols[symbol].status = true;
        return true;
    }

     
    function getTickerDetail(string memory _symbol) public view returns(address _issuer, uint256 _timestamp, 
    string memory _tokenName, bool _status) {

         
        string memory symbol = _symbol.upper();


        if(registerSymbols[symbol].status == true || registerSymbols[symbol].timestamp.add(expiredLimit) > now){
            return (
                registerSymbols[symbol].issuer,
                registerSymbols[symbol].timestamp,
                registerSymbols[symbol].tokenName,
                registerSymbols[symbol].status
            );
        }else{
            return (address(0), uint256(0), "", false);
        }
    }

     
    function changeExpiredLimit(uint256 _expired) public onlyOwner {
        require(_expired >= 1 days, "Expiry should greater than or equal to 1 day");
        uint256 oldExpiredLimit = expiredLimit;
        expiredLimit = _expired;
        emit LogChangeExpiredLimit(oldExpiredLimit, _expired);
    }

     
    function changeRegistrationFee(uint256 _registrationFee) public onlyOwner {
        require(registrationFee != _registrationFee, "Should not equal");
        uint256 newRegistrationFee = _registrationFee * 10 ** uint256(18);
        emit LogChangeRegistrationFee(registrationFee, newRegistrationFee);
        registrationFee = newRegistrationFee;
    }
    
}