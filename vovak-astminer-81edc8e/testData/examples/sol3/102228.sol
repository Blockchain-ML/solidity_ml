 

pragma solidity >=0.4.24 <0.7.0;


 
contract Initializable {

   
  bool private initialized;

   
  bool private initializing;

   
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

   
  function isConstructor() private view returns (bool) {
     
     
     
     
     
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

   
  uint256[50] private ______gap;
}

 

pragma solidity ^0.5.0;


 
contract ReentrancyGuardEmber is Initializable {
     
    uint256 private _guardCounter;

    function initialize() public initializer {
         
         
        _guardCounter = 1;
    }

     
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }

    uint256[50] private ______gap;
}

 

pragma solidity ^0.5.2;

 

library OpenZeppelinUpgradesECDSA {
     
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
         
        if (signature.length != 65) {
            return (address(0));
        }

         
        bytes32 r;
        bytes32 s;
        uint8 v;

         
         
         
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

         
         
         
         
         
         
         
         
         
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

         
        return ecrecover(hash, v, r, s);
    }

     
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
         
         
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

 

pragma solidity ^0.5.0;


 
contract Context is Initializable {
     
     
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

 
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

     
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

     
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

     
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

 

pragma solidity ^0.5.0;




 
contract WhitelistAdminRole is Initializable, Context {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    function initialize(address sender) public initializer {
        if (!isWhitelistAdmin(sender)) {
            _addWhitelistAdmin(sender);
        }
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(_msgSender()), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(_msgSender());
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }

    uint256[50] private ______gap;
}

 

pragma solidity ^0.5.0;






 

 
contract WhitelistedRoleEmber is Initializable, Context, WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(_msgSender()), "WhitelistedRole: caller does not have the Whitelisted role");
        _;
    }

    function initialize(address sender) public initializer {
        WhitelistAdminRole.initialize(sender);
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        _addWhitelisted(account);
    }

    function addSignedWhitelisted(address account, bytes memory signature) public {
        address signer = getWhitelistedRoleActionSigner('addSignedWhitelisted', account, signature);
        require(signer != address(0), "Invalid signature");
        require(isWhitelistAdmin(signer), "signer is not an admin");
        _addWhitelisted(account);
    }

    function addSignedWhitelistAdmin(address account, bytes memory signature) public {
        address signer = getWhitelistedRoleActionSigner('addSignedWhitelistAdmin', account, signature);
        require(signer != address(0), "Invalid signature");
        require(isWhitelistAdmin(signer), "signer is not an admin");
        _addWhitelistAdmin(account);
    }

    function getWhitelistedRoleActionSigner(string memory action, address account, bytes memory _signature) private view returns (address) {
      bytes32 msgHash = OpenZeppelinUpgradesECDSA.toEthSignedMessageHash(
      keccak256(
          abi.encodePacked(
            action,
            account,
            address(this)
          )
        )
      );
      return OpenZeppelinUpgradesECDSA.recover(msgHash, _signature);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(_msgSender());
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }

    uint256[50] private ______gap;
}

 

pragma solidity ^0.5.0;

 
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
         
         
         
         
         
         
        _notEntered = true;
    }

     
    modifier nonReentrant() {
         
        require(_notEntered, "ReentrancyGuard: reentrant call");

         
        _notEntered = false;

        _;

         
         
        _notEntered = true;
    }
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

 

 

pragma solidity 0.5.7;



library CommonMath {
    using SafeMath for uint256;

    uint256 public constant SCALE_FACTOR = 10 ** 18;
    uint256 public constant MAX_UINT_256 = 2 ** 256 - 1;

     
    function scaleFactor()
        internal
        pure
        returns (uint256)
    {
        return SCALE_FACTOR;
    }

     
    function maxUInt256()
        internal
        pure
        returns (uint256)
    {
        return MAX_UINT_256;
    }

     
    function scale(
        uint256 a
    )
        internal
        pure
        returns (uint256)
    {
        return a.mul(SCALE_FACTOR);
    }

     
    function deScale(
        uint256 a
    )
        internal
        pure
        returns (uint256)
    {
        return a.div(SCALE_FACTOR);
    }

     
    function safePower(
        uint256 a,
        uint256 pow
    )
        internal
        pure
        returns (uint256)
    {
        require(a > 0);

        uint256 result = 1;
        for (uint256 i = 0; i < pow; i++){
            uint256 previousResult = result;

             
            result = previousResult.mul(a);
        }

        return result;
    }

     
    function divCeil(uint256 a, uint256 b)
        internal
        pure
        returns(uint256)
    {
        return a.mod(b) > 0 ? a.div(b).add(1) : a.div(b);
    }

     
    function getPartialAmount(
        uint256 _principal,
        uint256 _numerator,
        uint256 _denominator
    )
        internal
        pure
        returns (uint256)
    {
         
        uint256 remainder = mulmod(_principal, _numerator, _denominator);

         
        if (remainder == 0) {
            return _principal.mul(_numerator).div(_denominator);
        }

         
        uint256 errPercentageTimes1000000 = remainder.mul(1000000).div(_numerator.mul(_principal));

         
        require(
            errPercentageTimes1000000 < 1000,
            "CommonMath.getPartialAmount: Rounding error exceeds bounds"
        );

        return _principal.mul(_numerator).div(_denominator);
    }
    
     
    function ceilLog10(
        uint256 _value
    )
        internal
        pure 
        returns (uint256)
    {
         
        require (
            _value > 0,
            "CommonMath.ceilLog10: Value must be greater than zero."
        );

         
        if (_value == 1) return 0;

         
        uint256 x = _value - 1;

        uint256 result = 0;

        if (x >= 10 ** 64) {
            x /= 10 ** 64;
            result += 64;
        }
        if (x >= 10 ** 32) {
            x /= 10 ** 32;
            result += 32;
        }
        if (x >= 10 ** 16) {
            x /= 10 ** 16;
            result += 16;
        }
        if (x >= 10 ** 8) {
            x /= 10 ** 8;
            result += 8;
        }
        if (x >= 10 ** 4) {
            x /= 10 ** 4;
            result += 4;
        }
        if (x >= 100) {
            x /= 100;
            result += 2;
        }
        if (x >= 10) {
            result += 1;
        }

        return result + 1;
    }
}

 

 
 

pragma solidity 0.5.7;


library AddressArrayUtils {

     
    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {
        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (0, false);
    }

     
    function contains(address[] memory A, address a) internal pure returns (bool) {
        bool isIn;
        (, isIn) = indexOf(A, a);
        return isIn;
    }

     
    function extend(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        uint256 aLength = A.length;
        uint256 bLength = B.length;
        address[] memory newAddresses = new address[](aLength + bLength);
        for (uint256 i = 0; i < aLength; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = 0; j < bLength; j++) {
            newAddresses[aLength + j] = B[j];
        }
        return newAddresses;
    }

     
    function append(address[] memory A, address a) internal pure returns (address[] memory) {
        address[] memory newAddresses = new address[](A.length + 1);
        for (uint256 i = 0; i < A.length; i++) {
            newAddresses[i] = A[i];
        }
        newAddresses[A.length] = a;
        return newAddresses;
    }

     
    function intersect(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        uint256 length = A.length;
        bool[] memory includeMap = new bool[](length);
        uint256 newLength = 0;
        for (uint256 i = 0; i < length; i++) {
            if (contains(B, A[i])) {
                includeMap[i] = true;
                newLength++;
            }
        }
        address[] memory newAddresses = new address[](newLength);
        uint256 j = 0;
        for (uint256 k = 0; k < length; k++) {
            if (includeMap[k]) {
                newAddresses[j] = A[k];
                j++;
            }
        }
        return newAddresses;
    }

     
    function union(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        address[] memory leftDifference = difference(A, B);
        address[] memory rightDifference = difference(B, A);
        address[] memory intersection = intersect(A, B);
        return extend(leftDifference, extend(intersection, rightDifference));
    }

     
    function difference(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        uint256 length = A.length;
        bool[] memory includeMap = new bool[](length);
        uint256 count = 0;
         
        for (uint256 i = 0; i < length; i++) {
            address e = A[i];
            if (!contains(B, e)) {
                includeMap[i] = true;
                count++;
            }
        }
        address[] memory newAddresses = new address[](count);
        uint256 j = 0;
        for (uint256 k = 0; k < length; k++) {
            if (includeMap[k]) {
                newAddresses[j] = A[k];
                j++;
            }
        }
        return newAddresses;
    }

     
    function pop(address[] memory A, uint256 index)
        internal
        pure
        returns (address[] memory, address)
    {
        uint256 length = A.length;
        address[] memory newAddresses = new address[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newAddresses[j - 1] = A[j];
        }
        return (newAddresses, A[index]);
    }

     
    function remove(address[] memory A, address a)
        internal
        pure
        returns (address[] memory)
    {
        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert();
        } else {
            (address[] memory _A,) = pop(A, index);
            return _A;
        }
    }

     
    function hasDuplicate(address[] memory A) internal pure returns (bool) {
        if (A.length == 0) { 
            return false;
        }
        for (uint256 i = 0; i < A.length - 1; i++) {
            for (uint256 j = i + 1; j < A.length; j++) {
                if (A[i] == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }

     
    function isEqual(address[] memory A, address[] memory B) internal pure returns (bool) {
        if (A.length != B.length) {
            return false;
        }
        for (uint256 i = 0; i < A.length; i++) {
            if (A[i] != B[i]) {
                return false;
            }
        }
        return true;
    }
}

 

 

pragma solidity 0.5.7;


 
interface ICore {
     
    function transferProxy()
        external
        view
        returns (address);

     
    function vault()
        external
        view
        returns (address);

     
    function exchangeIds(
        uint8 _exchangeId
    )
        external
        view
        returns (address);

     
    function validSets(address)
        external
        view
        returns (bool);

     
    function validModules(address)
        external
        view
        returns (bool);

     
    function validPriceLibraries(
        address _priceLibrary
    )
        external
        view
        returns (bool);

     
    function issue(
        address _set,
        uint256 _quantity
    )
        external;

     
    function issueTo(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;

     
    function issueInVault(
        address _set,
        uint256 _quantity
    )
        external;

     
    function redeem(
        address _set,
        uint256 _quantity
    )
        external;

     
    function redeemTo(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;

     
    function redeemInVault(
        address _set,
        uint256 _quantity
    )
        external;

     
    function redeemAndWithdrawTo(
        address _set,
        address _to,
        uint256 _quantity,
        uint256 _toExclude
    )
        external;

     
    function batchDeposit(
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;

     
    function batchWithdraw(
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;

     
    function deposit(
        address _token,
        uint256 _quantity
    )
        external;

     
    function withdraw(
        address _token,
        uint256 _quantity
    )
        external;

     
    function internalTransfer(
        address _token,
        address _to,
        uint256 _quantity
    )
        external;

     
    function createSet(
        address _factory,
        address[] calldata _components,
        uint256[] calldata _units,
        uint256 _naturalUnit,
        bytes32 _name,
        bytes32 _symbol,
        bytes calldata _callData
    )
        external
        returns (address);

     
    function depositModule(
        address _from,
        address _to,
        address _token,
        uint256 _quantity
    )
        external;

     
    function withdrawModule(
        address _from,
        address _to,
        address _token,
        uint256 _quantity
    )
        external;

     
    function batchDepositModule(
        address _from,
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;

     
    function batchWithdrawModule(
        address _from,
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;

     
    function issueModule(
        address _owner,
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;

     
    function redeemModule(
        address _burnAddress,
        address _incrementAddress,
        address _set,
        uint256 _quantity
    )
        external;

     
    function batchIncrementTokenOwnerModule(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;

     
    function batchDecrementTokenOwnerModule(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;

     
    function batchTransferBalanceModule(
        address[] calldata _tokens,
        address _from,
        address _to,
        uint256[] calldata _quantities
    )
        external;

     
    function transferModule(
        address _token,
        uint256 _quantity,
        address _from,
        address _to
    )
        external;

     
    function batchTransferModule(
        address[] calldata _tokens,
        uint256[] calldata _quantities,
        address _from,
        address _to
    )
        external;
}

 

 

pragma solidity 0.5.7;

 
interface ISetToken {

     

     
    function naturalUnit()
        external
        view
        returns (uint256);

     
    function getComponents()
        external
        view
        returns (address[] memory);

     
    function getUnits()
        external
        view
        returns (uint256[] memory);

     
    function tokenIsComponent(
        address _tokenAddress
    )
        external
        view
        returns (bool);

     
    function mint(
        address _issuer,
        uint256 _quantity
    )
        external;

     
    function burn(
        address _from,
        uint256 _quantity
    )
        external;

     
    function transfer(
        address to,
        uint256 value
    )
        external;
}

 

 

pragma solidity 0.5.7;

 
interface IVault {

     
    function withdrawTo(
        address _token,
        address _to,
        uint256 _quantity
    )
        external;

     
    function incrementTokenOwner(
        address _token,
        address _owner,
        uint256 _quantity
    )
        external;

     
    function decrementTokenOwner(
        address _token,
        address _owner,
        uint256 _quantity
    )
        external;

     

    function transferBalance(
        address _token,
        address _from,
        address _to,
        uint256 _quantity
    )
        external;


     
    function batchWithdrawTo(
        address[] calldata _tokens,
        address _to,
        uint256[] calldata _quantities
    )
        external;

     
    function batchIncrementTokenOwner(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;

     
    function batchDecrementTokenOwner(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;

    
    function batchTransferBalance(
        address[] calldata _tokens,
        address _from,
        address _to,
        uint256[] calldata _quantities
    )
        external;

     
    function getOwnerBalance(
        address _token,
        address _owner
    )
        external
        view
        returns (uint256);
}

 

 

pragma solidity 0.5.7;







 
library ExchangeIssuanceLibrary {
    using SafeMath for uint256;
    using AddressArrayUtils for address[];

     

    struct ExchangeIssuanceParams {
        address setAddress;
        uint256 quantity;
        uint8[] sendTokenExchangeIds;
        address[] sendTokens;
        uint256[] sendTokenAmounts;
        address[] receiveTokens;
        uint256[] receiveTokenAmounts;
    }

     
    function validateQuantity(
        address _set,
        uint256 _quantity
    )
        internal
        view
    {
         
        require(
            _quantity > 0,
            "ExchangeIssuanceLibrary.validateQuantity: Quantity must be positive"
        );

         
        require(
            _quantity.mod(ISetToken(_set).naturalUnit()) == 0,
            "ExchangeIssuanceLibrary.validateQuantity: Quantity must be multiple of natural unit"
        );
    }

     
    function validateReceiveTokens(
        address[] memory _receiveTokens,
        uint256[] memory _receiveTokenAmounts
    )
        internal
        view
    {
        uint256 receiveTokensCount = _receiveTokens.length;

         
        require(
            receiveTokensCount > 0,
            "ExchangeIssuanceLibrary.validateReceiveTokens: Receive tokens must not be empty"
        );

         
        require(
            !_receiveTokens.hasDuplicate(),
            "ExchangeIssuanceLibrary.validateReceiveTokens: Receive tokens must not have duplicates"
        );

         
        require(
            receiveTokensCount == _receiveTokenAmounts.length,
            "ExchangeIssuanceLibrary.validateReceiveTokens: Receive tokens and amounts must be equal length"
        );

        for (uint256 i = 0; i < receiveTokensCount; i++) {
             
            require(
                _receiveTokenAmounts[i] > 0,
                "ExchangeIssuanceLibrary.validateReceiveTokens: Component amounts must be positive"
            );
        }
    }

     
    function validatePostExchangeReceiveTokenBalances(
        address _vault,
        address[] memory _receiveTokens,
        uint256[] memory _requiredBalances,
        address _userToCheck
    )
        internal
        view
    {
         
        IVault vault = IVault(_vault);

         
        for (uint256 i = 0; i < _receiveTokens.length; i++) {
            uint256 currentBal = vault.getOwnerBalance(
                _receiveTokens[i],
                _userToCheck
            );

            require(
                currentBal >= _requiredBalances[i],
                "ExchangeIssuanceLibrary.validatePostExchangeReceiveTokenBalances: Insufficient receive token acquired"
            );
        }
    }

     
    function validateSendTokenParams(
        address _core,
        uint8[] memory _sendTokenExchangeIds,
        address[] memory _sendTokens,
        uint256[] memory _sendTokenAmounts
    )
        internal
        view
    {
        require(
            _sendTokens.length > 0,
            "ExchangeIssuanceLibrary.validateSendTokenParams: Send token inputs must not be empty"
        );

        require(
            _sendTokenExchangeIds.length == _sendTokens.length && 
            _sendTokens.length == _sendTokenAmounts.length,
            "ExchangeIssuanceLibrary.validateSendTokenParams: Send token inputs must be of the same length"
        );

        ICore core = ICore(_core);

        for (uint256 i = 0; i < _sendTokenExchangeIds.length; i++) {
             
            require(
                core.exchangeIds(_sendTokenExchangeIds[i]) != address(0),
                "ExchangeIssuanceLibrary.validateSendTokenParams: Must be valid exchange"
            );

             
            require(
                _sendTokenAmounts[i] > 0,
                "ExchangeIssuanceLibrary.validateSendTokenParams: Send amounts must be positive"
            );
        }
    }
}

 

 

pragma solidity 0.5.7;


 
interface IERC20 {
    function balanceOf(
        address _owner
    )
        external
        view
        returns (uint256);

    function allowance(
        address _owner,
        address _spender
    )
        external
        view
        returns (uint256);

    function transfer(
        address _to,
        uint256 _quantity
    )
        external;

    function transferFrom(
        address _from,
        address _to,
        uint256 _quantity
    )
        external;

    function approve(
        address _spender,
        uint256 _quantity
    )
        external
        returns (bool);

    function totalSupply()
        external
        returns (uint256);
}

 

 

pragma solidity 0.5.7;




 
library ERC20Wrapper {

     

     
    function balanceOf(
        address _token,
        address _owner
    )
        external
        view
        returns (uint256)
    {
        return IERC20(_token).balanceOf(_owner);
    }

     
    function allowance(
        address _token,
        address _owner,
        address _spender
    )
        internal
        view
        returns (uint256)
    {
        return IERC20(_token).allowance(_owner, _spender);
    }

     
    function transfer(
        address _token,
        address _to,
        uint256 _quantity
    )
        external
    {
        IERC20(_token).transfer(_to, _quantity);

         
        require(
            checkSuccess(),
            "ERC20Wrapper.transfer: Bad return value"
        );
    }

     
    function transferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _quantity
    )
        external
    {
        IERC20(_token).transferFrom(_from, _to, _quantity);

         
        require(
            checkSuccess(),
            "ERC20Wrapper.transferFrom: Bad return value"
        );
    }

     
    function approve(
        address _token,
        address _spender,
        uint256 _quantity
    )
        internal
    {
        IERC20(_token).approve(_spender, _quantity);

         
        require(
            checkSuccess(),
            "ERC20Wrapper.approve: Bad return value"
        );
    }

     
    function ensureAllowance(
        address _token,
        address _owner,
        address _spender,
        uint256 _quantity
    )
        internal
    {
        uint256 currentAllowance = allowance(_token, _owner, _spender);
        if (currentAllowance < _quantity) {
            approve(
                _token,
                _spender,
                CommonMath.maxUInt256()
            );
        }
    }

     

     
    function checkSuccess(
    )
        private
        pure
        returns (bool)
    {
         
        uint256 returnValue = 0;

        assembly {
             
            switch returndatasize

             
            case 0x0 {
                returnValue := 1
            }

             
            case 0x20 {
                 
                returndatacopy(0x0, 0x0, 0x20)

                 
                returnValue := mload(0x0)
            }

             
            default { }
        }

         
        return returnValue == 1;
    }
}

 

 

pragma solidity 0.5.7;


 
interface IExchangeIssuanceModule {

    function exchangeIssue(
        ExchangeIssuanceLibrary.ExchangeIssuanceParams calldata _exchangeIssuanceParams,
        bytes calldata _orderData
    )
        external;


    function exchangeRedeem(
        ExchangeIssuanceLibrary.ExchangeIssuanceParams calldata _exchangeIssuanceParams,
        bytes calldata _orderData
    )
        external;
}

 

 

pragma solidity 0.5.7;


 
library RebalancingLibrary {

     

    enum State { Default, Proposal, Rebalance, Drawdown }

     

    struct AuctionPriceParameters {
        uint256 auctionStartTime;
        uint256 auctionTimeToPivot;
        uint256 auctionStartPrice;
        uint256 auctionPivotPrice;
    }

    struct BiddingParameters {
        uint256 minimumBid;
        uint256 remainingCurrentSets;
        uint256[] combinedCurrentUnits;
        uint256[] combinedNextSetUnits;
        address[] combinedTokenArray;
    }
}

 

 

pragma solidity 0.5.7;


 

interface IRebalancingSetToken {

     
    function auctionLibrary()
        external
        view
        returns (address);

     
    function totalSupply()
        external
        view
        returns (uint256);

     
    function proposalStartTime()
        external
        view
        returns (uint256);

     
    function lastRebalanceTimestamp()
        external
        view
        returns (uint256);

     
    function rebalanceInterval()
        external
        view
        returns (uint256);

     
    function rebalanceState()
        external
        view
        returns (RebalancingLibrary.State);

     
    function startingCurrentSetAmount()
        external
        view
        returns (uint256);

     
    function balanceOf(
        address owner
    )
        external
        view
        returns (uint256);

     
    function propose(
        address _nextSet,
        address _auctionLibrary,
        uint256 _auctionTimeToPivot,
        uint256 _auctionStartPrice,
        uint256 _auctionPivotPrice
    )
        external;

     
    function naturalUnit()
        external
        view
        returns (uint256);

     
    function currentSet()
        external
        view
        returns (address);

     
    function nextSet()
        external
        view
        returns (address);

     
    function unitShares()
        external
        view
        returns (uint256);

     
    function burn(
        address _from,
        uint256 _quantity
    )
        external;

     
    function placeBid(
        uint256 _quantity
    )
        external
        returns (address[] memory, uint256[] memory, uint256[] memory);

     
    function getCombinedTokenArrayLength()
        external
        view
        returns (uint256);

     
    function getCombinedTokenArray()
        external
        view
        returns (address[] memory);

     
    function getFailedAuctionWithdrawComponents()
        external
        view
        returns (address[] memory);

     
    function getAuctionPriceParameters()
        external
        view
        returns (uint256[] memory);

     
    function getBiddingParameters()
        external
        view
        returns (uint256[] memory);

     
    function getBidPrice(
        uint256 _quantity
    )
        external
        view
        returns (uint256[] memory, uint256[] memory);

}

 

 

pragma solidity 0.5.7;

 
interface ITransferProxy {

     

     
    function transfer(
        address _token,
        uint256 _quantity,
        address _from,
        address _to
    )
        external;

     
    function batchTransfer(
        address[] calldata _tokens,
        uint256[] calldata _quantities,
        address _from,
        address _to
    )
        external;
}

 

 

pragma solidity 0.5.7;


 
interface IWETH {
    function deposit()
        external
        payable;

    function withdraw(
        uint256 wad
    )
        external;
}

 

 

pragma solidity 0.5.7;





 
contract ModuleCoreStateV2 {

     

     
    ICore public coreInstance;

     
    IVault public vaultInstance;

     
    ITransferProxy public transferProxyInstance;

     

     
    constructor(
        ICore _core,
        IVault _vault,
        ITransferProxy _transferProxy
    )
        public
    {
         
        coreInstance = _core;

         
        vaultInstance = _vault;

         
        transferProxyInstance = _transferProxy;
    }
}

 

 

pragma solidity 0.5.7;







 
contract TokenFlush is 
    ModuleCoreStateV2
{
    using SafeMath for uint256;
    using AddressArrayUtils for address[];

     

     
    function returnExcessBaseSetFromContract(
        address _baseSetAddress,
        address _returnAddress,
        bool _keepChangeInVault
    )
        internal
    {
        uint256 baseSetQuantity = ERC20Wrapper.balanceOf(_baseSetAddress, address(this));
        
        if (baseSetQuantity > 0) { 
            if (_keepChangeInVault) {
                 
                ERC20Wrapper.ensureAllowance(
                    _baseSetAddress,
                    address(this),
                    address(transferProxyInstance),
                    baseSetQuantity
                );

                 
                coreInstance.depositModule(
                    address(this),
                    _returnAddress,
                    _baseSetAddress,
                    baseSetQuantity
                );
            } else {
                 
                ERC20Wrapper.transfer(
                    _baseSetAddress,
                    _returnAddress,
                    baseSetQuantity
                );
            }
        }
    }

     
    function returnExcessBaseSetInVault(
        address _baseSetAddress,
        address _returnAddress,
        bool _keepChangeInVault
    )
        internal
    {
         
        uint256 baseSetQuantityInVault = vaultInstance.getOwnerBalance(
            _baseSetAddress,
            address(this)
        );
        
        if (baseSetQuantityInVault > 0) { 
            if (_keepChangeInVault) {
                 
                coreInstance.internalTransfer(
                    _baseSetAddress,
                    _returnAddress,
                    baseSetQuantityInVault
                );
            } else {
                 
                coreInstance.withdrawModule(
                    address(this),
                    _returnAddress,
                    _baseSetAddress,
                    baseSetQuantityInVault
                );
            }
        }
    } 

     
    function returnExcessComponentsFromContract(
        ISetToken _baseSetToken,
        address _returnAddress
    )
        internal
    {
         
        address[] memory baseSetComponents = _baseSetToken.getComponents();
        for (uint256 i = 0; i < baseSetComponents.length; i++) {
            uint256 withdrawQuantity = ERC20Wrapper.balanceOf(baseSetComponents[i], address(this));
            if (withdrawQuantity > 0) {
                ERC20Wrapper.transfer(
                    baseSetComponents[i],
                    _returnAddress,
                    withdrawQuantity
                );
            }
        }         
    }

     
    function returnExcessComponentsFromVault(
        ISetToken _baseSetToken,
        address _returnAddress
    )
        internal
    {
         
        address[] memory baseSetComponents = _baseSetToken.getComponents();
        for (uint256 i = 0; i < baseSetComponents.length; i++) {
            uint256 vaultQuantity = vaultInstance.getOwnerBalance(baseSetComponents[i], address(this));
            if (vaultQuantity > 0) {
                coreInstance.withdrawModule(
                    address(this),
                    _returnAddress,
                    baseSetComponents[i],
                    vaultQuantity
                );
            }
        }
    }   
}

 

 

pragma solidity 0.5.7;
pragma experimental "ABIEncoderV2";
















 
contract RebalancingSetExchangeIssuanceModule is
    ModuleCoreStateV2,
    TokenFlush,
    ReentrancyGuard
{
    using SafeMath for uint256;

     

     
    IExchangeIssuanceModule public exchangeIssuanceModuleInstance;

     
    IWETH public wethInstance;

     

    event LogPayableExchangeIssue(
        address indexed rebalancingSetAddress,
        address indexed callerAddress,
        address paymentTokenAddress,
        uint256 rebalancingSetQuantity,
        uint256 paymentTokenReturned
    );

    event LogPayableExchangeRedeem(
        address indexed rebalancingSetAddress,
        address indexed callerAddress,
        address outputTokenAddress,
        uint256 rebalancingSetQuantity,
        uint256 outputTokenQuantity
    );

     

     
    constructor(
        ICore _core,
        ITransferProxy _transferProxy,
        IExchangeIssuanceModule _exchangeIssuanceModule,
        IWETH _wrappedEther,
        IVault _vault
    )
        public
        ModuleCoreStateV2(
            _core,
            _vault,
            _transferProxy
        )
    {
         
        exchangeIssuanceModuleInstance = _exchangeIssuanceModule;

         
        wethInstance = _wrappedEther;

         
        ERC20Wrapper.approve(
            address(_wrappedEther),
            address(_transferProxy),
            CommonMath.maxUInt256()
        );
    }

     
    function ()
        external
        payable
    {
        require(
            msg.sender == address(wethInstance),
            "RebalancingSetExchangeIssuanceModule.fallback: Cannot receive ETH directly unless unwrapping WETH"
        );
    }

     

     
    function issueRebalancingSetWithEther(
        address _rebalancingSetAddress,
        uint256 _rebalancingSetQuantity,
        ExchangeIssuanceLibrary.ExchangeIssuanceParams memory _exchangeIssuanceParams,
        bytes memory _orderData,
        bool _keepChangeInVault
    )
        public
        payable
        nonReentrant
    {
         
        wethInstance.deposit.value(msg.value)();

         
        issueRebalancingSetInternal(
            _rebalancingSetAddress,
            _rebalancingSetQuantity,
            address(wethInstance),
            msg.value,
            _exchangeIssuanceParams,
            _orderData,
            _keepChangeInVault
        );

         
        uint256 leftoverWeth = ERC20Wrapper.balanceOf(address(wethInstance), address(this));
        if (leftoverWeth > 0) {
             
            wethInstance.withdraw(leftoverWeth);

             
            msg.sender.transfer(leftoverWeth);
        }

        emit LogPayableExchangeIssue(
            _rebalancingSetAddress,
            msg.sender,
            address(wethInstance),
            _rebalancingSetQuantity,
            leftoverWeth
        );
    }

     
    function issueRebalancingSetWithERC20(
        address _rebalancingSetAddress,
        uint256 _rebalancingSetQuantity,
        address _paymentTokenAddress,
        uint256 _paymentTokenQuantity,
        ExchangeIssuanceLibrary.ExchangeIssuanceParams memory _exchangeIssuanceParams,
        bytes memory _orderData,
        bool _keepChangeInVault
    )
        public
        nonReentrant
    {
         
        coreInstance.transferModule(
            _paymentTokenAddress,
            _paymentTokenQuantity,
            msg.sender,
            address(this)
        );

         
        issueRebalancingSetInternal(
            _rebalancingSetAddress,
            _rebalancingSetQuantity,
            _paymentTokenAddress,
            _paymentTokenQuantity,
            _exchangeIssuanceParams,
            _orderData,
            _keepChangeInVault
        );

         
        uint256 leftoverPaymentTokenQuantity = ERC20Wrapper.balanceOf(_paymentTokenAddress, address(this));
        if (leftoverPaymentTokenQuantity > 0) {
            ERC20Wrapper.transfer(
                _paymentTokenAddress,
                msg.sender,
                leftoverPaymentTokenQuantity
            );
        }

        emit LogPayableExchangeIssue(
            _rebalancingSetAddress,
            msg.sender,
            _paymentTokenAddress,
            _rebalancingSetQuantity,
            leftoverPaymentTokenQuantity
        );
    }

     
    function redeemRebalancingSetIntoEther(
        address _rebalancingSetAddress,
        uint256 _rebalancingSetQuantity,
        ExchangeIssuanceLibrary.ExchangeIssuanceParams memory _exchangeIssuanceParams,
        bytes memory _orderData,
        bool _keepChangeInVault
    )
        public
        nonReentrant
    {
         
         
        redeemRebalancingSetIntoComponentsInternal(
            _rebalancingSetAddress,
            _rebalancingSetQuantity,
            address(wethInstance),
            _exchangeIssuanceParams,
            _orderData
        );

         
         
         
        uint256 wethQuantityInVault = vaultInstance.getOwnerBalance(address(wethInstance), address(this));
        if (wethQuantityInVault > 0) {
            coreInstance.withdrawModule(
                address(this),
                address(this),
                address(wethInstance),
                wethQuantityInVault
            );
        }

         
        uint256 wethBalance = ERC20Wrapper.balanceOf(address(wethInstance), address(this));
        if (wethBalance > 0) {
            wethInstance.withdraw(wethBalance);
            msg.sender.transfer(wethBalance);
        }

        address baseSetAddress = _exchangeIssuanceParams.setAddress;

         
        returnExcessBaseSetFromContract(
            baseSetAddress,
            msg.sender,
            _keepChangeInVault
        );

         
        returnExcessComponentsFromContract(ISetToken(baseSetAddress), msg.sender);

        emit LogPayableExchangeRedeem(
            _rebalancingSetAddress,
            msg.sender,
            address(wethInstance),
            _rebalancingSetQuantity,
            wethBalance
        );
    }

     
    function redeemRebalancingSetIntoERC20(
        address _rebalancingSetAddress,
        uint256 _rebalancingSetQuantity,
        address _outputTokenAddress,
        ExchangeIssuanceLibrary.ExchangeIssuanceParams memory _exchangeIssuanceParams,
        bytes memory _orderData,
        bool _keepChangeInVault
    )
        public
        nonReentrant
    {
         
         
        redeemRebalancingSetIntoComponentsInternal(
            _rebalancingSetAddress,
            _rebalancingSetQuantity,
            _outputTokenAddress,
            _exchangeIssuanceParams,
            _orderData
        );

         
         
        uint256 outputTokenInVault = vaultInstance.getOwnerBalance(_outputTokenAddress, address(this));
        if (outputTokenInVault > 0) {
            coreInstance.withdrawModule(
                address(this),
                address(this),
                _outputTokenAddress,
                outputTokenInVault
            );
        }

         
        uint256 outputTokenBalance = ERC20Wrapper.balanceOf(_outputTokenAddress, address(this));
        ERC20Wrapper.transfer(
            _outputTokenAddress,
            msg.sender,
            outputTokenBalance
        );

        address baseSetAddress = _exchangeIssuanceParams.setAddress;

         
        returnExcessBaseSetFromContract(
            baseSetAddress,
            msg.sender,
            _keepChangeInVault
        );

         
        returnExcessComponentsFromContract(ISetToken(baseSetAddress), msg.sender);

        emit LogPayableExchangeRedeem(
            _rebalancingSetAddress,
            msg.sender,
            _outputTokenAddress,
            _rebalancingSetQuantity,
            outputTokenBalance
        );
    }


     

     
    function validateExchangeIssuanceInputs(
        address _transactTokenAddress,
        IRebalancingSetToken _rebalancingSetAddress,
        uint256 _rebalancingSetQuantity,
        address _baseSetAddress,
        address[] memory _transactTokenArray
    )
        private
        view
    {
         
        require(
            coreInstance.validSets(address(_rebalancingSetAddress)),
            "RebalancingSetExchangeIssuance.validateExchangeIssuanceInputs: Invalid or disabled SetToken address"
        );

        require(
            _rebalancingSetQuantity > 0,
            "RebalancingSetExchangeIssuance.validateExchangeIssuanceInputs: Quantity must be > 0"
        );

         
        require(
            _rebalancingSetQuantity.mod(_rebalancingSetAddress.naturalUnit()) == 0,
            "RebalancingSetExchangeIssuance.validateExchangeIssuanceInputs: Quantity must be multiple of natural unit"
        );

         
         
         
         
        for (uint256 i = 0; i < _transactTokenArray.length; i++) {
             
            require(
                _transactTokenAddress == _transactTokenArray[i],
                "RebalancingSetExchangeIssuance.validateExchangeIssuanceInputs: Send/Receive token must match transact token"
            );
        }

         
        address baseSet = _rebalancingSetAddress.currentSet();
        require(
            baseSet == _baseSetAddress,
            "RebalancingSetExchangeIssuance.validateExchangeIssuanceInputs: Base Set addresses must match"
        );
    }

     
    function issueRebalancingSetInternal(
        address _rebalancingSetAddress,
        uint256 _rebalancingSetQuantity,
        address _paymentTokenAddress,
        uint256 _paymentTokenQuantity,
        ExchangeIssuanceLibrary.ExchangeIssuanceParams memory _exchangeIssuanceParams,
        bytes memory _orderData,
        bool _keepChangeInVault
    )
        private
    {
        address baseSetAddress = _exchangeIssuanceParams.setAddress;
        uint256 baseSetIssueQuantity = _exchangeIssuanceParams.quantity;

         
        validateExchangeIssuanceInputs(
            _paymentTokenAddress,
            IRebalancingSetToken(_rebalancingSetAddress),
            _rebalancingSetQuantity,
            baseSetAddress,
            _exchangeIssuanceParams.sendTokens
        );

         
         
         
        ERC20Wrapper.ensureAllowance(
            _paymentTokenAddress,
            address(this),
            address(transferProxyInstance),
            _paymentTokenQuantity
        );

         
        exchangeIssuanceModuleInstance.exchangeIssue(
            _exchangeIssuanceParams,
            _orderData
        );

         
        ERC20Wrapper.ensureAllowance(
            baseSetAddress,
            address(this),
            address(transferProxyInstance),
            baseSetIssueQuantity
        );

         
        coreInstance.issueTo(
            msg.sender,
            _rebalancingSetAddress,
            _rebalancingSetQuantity
        );

         
         
         
        returnExcessBaseSetFromContract(
            baseSetAddress,
            msg.sender,
            _keepChangeInVault
        );

         
        returnExcessComponentsFromVault(ISetToken(baseSetAddress), msg.sender);
    }

     
    function redeemRebalancingSetIntoComponentsInternal(
        address _rebalancingSetAddress,
        uint256 _rebalancingSetQuantity,
        address _receiveTokenAddress,
        ExchangeIssuanceLibrary.ExchangeIssuanceParams memory _exchangeIssuanceParams,
        bytes memory _orderData
    )
        private
    {
         
        validateExchangeIssuanceInputs(
            _receiveTokenAddress,
            IRebalancingSetToken(_rebalancingSetAddress),
            _rebalancingSetQuantity,
            _exchangeIssuanceParams.setAddress,
            _exchangeIssuanceParams.receiveTokens
        );

         
        coreInstance.redeemModule(
            msg.sender,
            address(this),
            _rebalancingSetAddress,
            _rebalancingSetQuantity
        );

        address baseSetAddress = _exchangeIssuanceParams.setAddress;
        uint256 baseSetVaultQuantity = vaultInstance.getOwnerBalance(baseSetAddress, address(this));

         
        coreInstance.withdrawModule(
            address(this),
            address(this),
            baseSetAddress,
            baseSetVaultQuantity
        );

         
         
         
        exchangeIssuanceModuleInstance.exchangeRedeem(
            _exchangeIssuanceParams,
            _orderData
        );
    }
}

 

 

pragma solidity 0.5.7;





 
contract ModuleCoreState {

     

     
    address public core;

     
    address public vault;

     
    ICore public coreInstance;

     
    IVault public vaultInstance;

     

     
    constructor(
        address _core,
        address _vault
    )
        public
    {
         
        core = _core;

         
        coreInstance = ICore(_core);

         
        vault = _vault;

         
        vaultInstance = IVault(_vault);
    }
}

 

 

pragma solidity 0.5.7;








 
contract RebalancingSetIssuance is 
    ModuleCoreState
{
    using SafeMath for uint256;
    using AddressArrayUtils for address[];

     

     
    function validateWETHIsAComponentOfSet(
        address _setAddress,
        address _wrappedEtherAddress
    )
        internal
        view
    {
        require(
            ISetToken(_setAddress).tokenIsComponent(_wrappedEtherAddress),
            "RebalancingSetIssuance.validateWETHIsAComponentOfSet: Components must contain weth"
        );
    }

        
    function validateRebalancingSetIssuance(
        address _rebalancingSetAddress,
        uint256 _rebalancingSetQuantity
    ) 
        internal
        view
    {
         
        require(
            coreInstance.validSets(_rebalancingSetAddress),
            "RebalancingSetIssuance.validateRebalancingIssuance: Invalid or disabled SetToken address"
        );
        
         
        require(
            _rebalancingSetQuantity.mod(ISetToken(_rebalancingSetAddress).naturalUnit()) == 0,
            "RebalancingSetIssuance.validateRebalancingIssuance: Quantity must be multiple of natural unit"
        );
    }

         
    function getBaseSetIssuanceRequiredQuantity(
        address _rebalancingSetAddress,
        uint256 _rebalancingSetQuantity
    )
        internal
        view
        returns (uint256)
    {
        IRebalancingSetToken rebalancingSet = IRebalancingSetToken(_rebalancingSetAddress);

        uint256 unitShares = rebalancingSet.unitShares();
        uint256 naturalUnit = rebalancingSet.naturalUnit();

        uint256 requiredBaseSetQuantity = _rebalancingSetQuantity.div(naturalUnit).mul(unitShares);

        address baseSet = rebalancingSet.currentSet();
        uint256 baseSetNaturalUnit = ISetToken(baseSet).naturalUnit();

         
         
        uint256 roundDownQuantity = requiredBaseSetQuantity.mod(baseSetNaturalUnit);
        if (roundDownQuantity > 0) {
            requiredBaseSetQuantity = requiredBaseSetQuantity.sub(roundDownQuantity).add(baseSetNaturalUnit);
        }

        return requiredBaseSetQuantity;
    }


     
    function getBaseSetRedeemQuantity(
        address _baseSetAddress
    )
        internal
        view
        returns (uint256)
    {
         
        uint256 baseSetNaturalUnit = ISetToken(_baseSetAddress).naturalUnit();
        uint256 baseSetBalance = vaultInstance.getOwnerBalance(
            _baseSetAddress,
            address(this)
        );

         
        return baseSetBalance.sub(baseSetBalance.mod(baseSetNaturalUnit));
    }

     
    function returnExcessBaseSet(
        address _baseSetAddress,
        address _transferProxyAddress,
        bool _keepChangeInVault
    )
        internal
    {
        returnExcessBaseSetFromContract(_baseSetAddress, _transferProxyAddress, _keepChangeInVault);

        returnExcessBaseSetInVault(_baseSetAddress, _keepChangeInVault);
    }   

     
    function returnExcessBaseSetFromContract(
        address _baseSetAddress,
        address _transferProxyAddress,
        bool _keepChangeInVault
    )
        internal
    {
        uint256 baseSetQuantity = ERC20Wrapper.balanceOf(_baseSetAddress, address(this));
        
        if (baseSetQuantity == 0) { 
            return; 
        } else if (_keepChangeInVault) {
             
            ERC20Wrapper.ensureAllowance(
                _baseSetAddress,
                address(this),
                _transferProxyAddress,
                baseSetQuantity
            );

             
            coreInstance.depositModule(
                address(this),
                msg.sender,
                _baseSetAddress,
                baseSetQuantity
            );
        } else {
             
            ERC20Wrapper.transfer(
                _baseSetAddress,
                msg.sender,
                baseSetQuantity
            );
        }
    }

     
    function returnExcessBaseSetInVault(
        address _baseSetAddress,
        bool _keepChangeInVault
    )
        internal
    {
         
        uint256 baseSetQuantityInVault = vaultInstance.getOwnerBalance(
            _baseSetAddress,
            address(this)
        );
        
        if (baseSetQuantityInVault == 0) { 
            return; 
        } else if (_keepChangeInVault) {
             
            coreInstance.internalTransfer(
                _baseSetAddress,
                msg.sender,
                baseSetQuantityInVault
            );
        } else {
             
            coreInstance.withdrawModule(
                address(this),
                msg.sender,
                _baseSetAddress,
                baseSetQuantityInVault
            );
        }
    }   
}

 

 

pragma solidity 0.5.7;










 
contract RebalancingSetIssuanceModule is
    ModuleCoreState,
    RebalancingSetIssuance,
    ReentrancyGuard
{
    using SafeMath for uint256;

     
    address public transferProxy;

     
    IWETH public weth;

     

    event LogRebalancingSetIssue(
        address indexed rebalancingSetAddress,
        address indexed callerAddress,
        uint256 rebalancingSetQuantity
    );

    event LogRebalancingSetRedeem(
        address indexed rebalancingSetAddress,
        address indexed callerAddress,
        uint256 rebalancingSetQuantity
    );

     

     
    constructor(
        address _core,
        address _vault,
        address _transferProxy,
        IWETH _weth
    )
        public
        ModuleCoreState(
            _core,
            _vault
        )
    {
         
        weth = _weth;

         
        transferProxy = _transferProxy;
    }

     
    function ()
        external
        payable
    {
        require(
            msg.sender == address(weth),
            "RebalancingSetIssuanceModule.fallback: Cannot receive ETH directly unless unwrapping WETH"
        );
    }

     

     
    function issueRebalancingSet(
        address _rebalancingSetAddress,
        uint256 _rebalancingSetQuantity,
        bool _keepChangeInVault
    )
        external
        nonReentrant
    {
         
        (
            address baseSetAddress,
            uint256 requiredBaseSetQuantity
        ) = getBaseSetAddressAndQuantity(_rebalancingSetAddress, _rebalancingSetQuantity);

         
        coreInstance.issueModule(
            msg.sender,
            address(this),
            baseSetAddress,
            requiredBaseSetQuantity
        );

         
        ERC20Wrapper.ensureAllowance(
            baseSetAddress,
            address(this),
            transferProxy,
            requiredBaseSetQuantity
        );

         
        issueRebalancingSetAndReturnExcessBase(
            _rebalancingSetAddress,
            baseSetAddress,
            _rebalancingSetQuantity,
            _keepChangeInVault
        );
    }

     
    function issueRebalancingSetWrappingEther(
        address _rebalancingSetAddress,
        uint256 _rebalancingSetQuantity,
        bool _keepChangeInVault
    )
        external
        payable
        nonReentrant
    {
         
        (
            address baseSetAddress,
            uint256 requiredBaseSetQuantity
        ) = getBaseSetAddressAndQuantity(_rebalancingSetAddress, _rebalancingSetQuantity);

         
        validateWETHIsAComponentOfSet(baseSetAddress, address(weth));

         
         
        depositComponentsAndHandleEth(
            baseSetAddress,
            requiredBaseSetQuantity
        );

         
        coreInstance.issueInVault(
            baseSetAddress,
            requiredBaseSetQuantity
        );

         

         
        issueRebalancingSetAndReturnExcessBase(
            _rebalancingSetAddress,
            baseSetAddress,
            _rebalancingSetQuantity,
            _keepChangeInVault
        );

         
         
        uint256 leftoverEth = address(this).balance;
        if (leftoverEth > 0) {
            msg.sender.transfer(leftoverEth);
        }
    }

     
    function redeemRebalancingSet(
        address _rebalancingSetAddress,
        uint256 _rebalancingSetQuantity,
        bool _keepChangeInVault
    )
        external
        nonReentrant
    {
         
        validateRebalancingSetIssuance(_rebalancingSetAddress, _rebalancingSetQuantity);

         
        coreInstance.redeemModule(
            msg.sender,
            address(this),
            _rebalancingSetAddress,
            _rebalancingSetQuantity
        );

         
        address baseSetAddress = IRebalancingSetToken(_rebalancingSetAddress).currentSet();
        uint256 baseSetRedeemQuantity = getBaseSetRedeemQuantity(baseSetAddress);

         
        coreInstance.withdraw(
            baseSetAddress,
            baseSetRedeemQuantity
        );

         
         
        coreInstance.redeemAndWithdrawTo(
            baseSetAddress,
            msg.sender,
            baseSetRedeemQuantity,
            0
        );

         
        returnExcessBaseSet(baseSetAddress, transferProxy, _keepChangeInVault);

         
        emit LogRebalancingSetRedeem(
            _rebalancingSetAddress,
            msg.sender,
            _rebalancingSetQuantity
        );
    }

     
    function redeemRebalancingSetUnwrappingEther(
        address _rebalancingSetAddress,
        uint256 _rebalancingSetQuantity,
        bool _keepChangeInVault
    )
        external
        nonReentrant
    {
         
        validateRebalancingSetIssuance(_rebalancingSetAddress, _rebalancingSetQuantity);

        address baseSetAddress = IRebalancingSetToken(_rebalancingSetAddress).currentSet();

        validateWETHIsAComponentOfSet(baseSetAddress, address(weth));

         
        coreInstance.redeemModule(
            msg.sender,
            address(this),
            _rebalancingSetAddress,
            _rebalancingSetQuantity
        );

         
        uint256 baseSetRedeemQuantity = getBaseSetRedeemQuantity(baseSetAddress);

         
        coreInstance.withdraw(
            baseSetAddress,
            baseSetRedeemQuantity
        );

         
        coreInstance.redeem(
            baseSetAddress,
            baseSetRedeemQuantity
        );

         
        withdrawComponentsToSenderWithEther(baseSetAddress);

         
        returnExcessBaseSet(baseSetAddress, transferProxy, _keepChangeInVault);

         
        emit LogRebalancingSetRedeem(
            _rebalancingSetAddress,
            msg.sender,
            _rebalancingSetQuantity
        );
    }

     

     
    function getBaseSetAddressAndQuantity(
        address _rebalancingSetAddress,
        uint256 _rebalancingSetQuantity
    )
        internal
        view
        returns (address, uint256)
    {
         
        validateRebalancingSetIssuance(_rebalancingSetAddress, _rebalancingSetQuantity);

        address baseSetAddress = IRebalancingSetToken(_rebalancingSetAddress).currentSet();

         
        uint256 requiredBaseSetQuantity = getBaseSetIssuanceRequiredQuantity(
            _rebalancingSetAddress,
            _rebalancingSetQuantity
        );

        return (baseSetAddress, requiredBaseSetQuantity);        
    }

     
    function issueRebalancingSetAndReturnExcessBase(
        address _rebalancingSetAddress,
        address _baseSetAddress,
        uint256 _rebalancingSetQuantity,
        bool _keepChangeInVault
    )
        internal
    {
         
        coreInstance.issueTo(
            msg.sender,
            _rebalancingSetAddress,
            _rebalancingSetQuantity
        );

         
        returnExcessBaseSet(_baseSetAddress, transferProxy, _keepChangeInVault);

         
        emit LogRebalancingSetIssue(
            _rebalancingSetAddress,
            msg.sender,
            _rebalancingSetQuantity
        );       
    }

     
    function depositComponentsAndHandleEth(
        address _baseSetAddress,
        uint256 _baseSetQuantity
    )
        private
    {
        ISetToken baseSet = ISetToken(_baseSetAddress);

        address[] memory baseSetComponents = baseSet.getComponents();
        uint256[] memory baseSetUnits = baseSet.getUnits();
        uint256 baseSetNaturalUnit = baseSet.naturalUnit();

        
        for (uint256 i = 0; i < baseSetComponents.length; i++) {
            address currentComponent = baseSetComponents[i];
            uint256 currentUnit = baseSetUnits[i];

             
            uint256 currentComponentQuantity = _baseSetQuantity.div(baseSetNaturalUnit).mul(currentUnit);

             
            if (currentComponent == address(weth)) {
                 
                require(
                    msg.value >= currentComponentQuantity,
                    "RebalancingSetIssuanceModule.depositComponentsAndHandleEth: Not enough ether included for base SetToken"
                );

                 
                weth.deposit.value(currentComponentQuantity)();

                 
                ERC20Wrapper.ensureAllowance(
                    address(weth),
                    address(this),
                    transferProxy,
                    currentComponentQuantity
                );
            } else {
                 
                coreInstance.depositModule(
                    msg.sender,
                    address(this),
                    currentComponent,
                    currentComponentQuantity
                );                
            }
        }
    }

     
    function withdrawComponentsToSenderWithEther(
        address _baseSetAddress
    )
        private
    {
        address[] memory baseSetComponents = ISetToken(_baseSetAddress).getComponents();

         
        for (uint256 i = 0; i < baseSetComponents.length; i++) {
            address currentComponent = baseSetComponents[i];
            uint256 currentComponentQuantity = vaultInstance.getOwnerBalance(
                currentComponent,
                address(this)
            );

             
            if (currentComponent == address(weth)) {
                 
                coreInstance.withdrawModule(
                    address(this),
                    address(this),
                    address(weth),
                    currentComponentQuantity
                );

                 
                weth.withdraw(currentComponentQuantity);

                 
                msg.sender.transfer(currentComponentQuantity);
            } else {
                 
                coreInstance.withdrawModule(
                    address(this),
                    msg.sender,
                    currentComponent,
                    currentComponentQuantity
                );
            }
        }
    }
}

 

 

pragma solidity 0.5.7;

 
interface IAddressToAddressWhiteList {

     

     
    function whitelist(
        address _key
    )
        external
        view
        returns (address);

     
    function areValidAddresses(
        address[] calldata _keys
    )
        external
        view
        returns (bool);

     
    function getValues(
        address[] calldata _key
    )
        external
        view
        returns (address[] memory);

     
    function getValue(
        address _key
    )
        external
        view
        returns (address);

     
    function validAddresses()
        external
        view
        returns (address[] memory);
}

 

 
pragma solidity ^0.5.0;












contract SmartWalletProd is Initializable, ReentrancyGuardEmber, WhitelistedRoleEmber {
    using SafeMath for uint256;

    address constant public transfersProxy = 0x882d80D3a191859d64477eb78Cca46599307ec1C;
    address payable constant public rebalancingSetExchangeIssuanceModule = 0xd4240987D6F92B06c8B5068B1E4006A97c47392b;
    address payable constant public rebalancingSetIssuanceModule = 0xDA6786379FF88729264d31d472FA917f5E561443;
    address payable constant public cTokenaddressToAddressWhiteList = 0x5BA020a8835ed40936941562bdF42D66F65fc00f;

     
    mapping(uint256 => bool) issueRebalancingSetUsedNonces;
    mapping(uint256 => bool) redeemRebalancingSetUsedNonces;

    event IssueRebalancingSetFromERC20Token(uint256 quantity);
    event IssueRebalancingSetFromComponents(uint256 quantity);
    event IssueBaseSetFromComponents(uint256 quantity, uint256 roundedQuantity);
    event RedeemedRebalancingSetIntoERC20(address erc20, uint256 quantity);
    event MissingComponentForIssueRebalancingSetFromAllComponents(address componentMissing);

    function initialize(address _owner) public initializer {
      WhitelistedRoleEmber.initialize(_owner);
      ReentrancyGuardEmber.initialize();
    }

    function() external payable { }

    function withdrawAllAdmin(address [] calldata _tokenAddresses)
      external
      nonReentrant
      onlyWhitelistAdmin
    {
      for (uint i=0; i<_tokenAddresses.length; i++) {
          uint256 tokenBalance = ERC20Wrapper.balanceOf(_tokenAddresses[i], address(this));
          ERC20Wrapper.transfer(
              _tokenAddresses[i],
              msg.sender,
              tokenBalance
          );
      }
    }

    function getIssueRebalancingSetSigner(address _rebalancingSetAddress, address _paymentTokenAddress, uint256 _nonce, bytes memory _signature) private view returns (address) {
      bytes32 msgHash = OpenZeppelinUpgradesECDSA.toEthSignedMessageHash(
      keccak256(
          abi.encodePacked(
            _rebalancingSetAddress,
            _paymentTokenAddress,
            _nonce,
            address(this)
          )
        )
      );
      return OpenZeppelinUpgradesECDSA.recover(msgHash, _signature);
    }

     
    function issueRebalancingSetFromERC20(
       address _rebalancingSetAddress,
       uint256 _rebalancingSetQuantity,
       address _paymentTokenAddress,
       uint256 _paymentTokenQuantity,
       ExchangeIssuanceLibrary.ExchangeIssuanceParams memory _exchangeIssuanceParams,
       bytes memory _orderData,
       uint256 _nonce,
       bytes memory _signature
    )
      public
      nonReentrant
    {
      require(!issueRebalancingSetUsedNonces[_nonce], "Replay attack detected.");
      issueRebalancingSetUsedNonces[_nonce] = true;
      address signer = getIssueRebalancingSetSigner(_rebalancingSetAddress, _paymentTokenAddress, _nonce, _signature);
      require(signer != address(0), "Invalid signature");
      require(isWhitelistAdmin(signer), "signer is not an admin");

      uint256 paymentTokenBalance = ERC20Wrapper.balanceOf(_paymentTokenAddress, address(this));
      require(paymentTokenBalance > 0, "Zero payment token balance");

       
      ERC20Wrapper.approve(_paymentTokenAddress, transfersProxy, uint256(-1));

       
      ISetToken baseSet = ISetToken(IRebalancingSetToken(_rebalancingSetAddress).currentSet());
      if (baseSet.getComponents().length == 1 &&
          (_paymentTokenAddress == baseSet.getComponents()[0]
          || _paymentTokenAddress == IAddressToAddressWhiteList(cTokenaddressToAddressWhiteList).whitelist(baseSet.getComponents()[0])
      )) {
             
            RebalancingSetIssuanceModule(rebalancingSetIssuanceModule).issueRebalancingSet(
              _rebalancingSetAddress, _rebalancingSetQuantity, true);
      } else {
        RebalancingSetExchangeIssuanceModule(rebalancingSetExchangeIssuanceModule).issueRebalancingSetWithERC20(
          _rebalancingSetAddress,
          _rebalancingSetQuantity,
          _paymentTokenAddress,
          _paymentTokenQuantity,
          _exchangeIssuanceParams,
          _orderData,
          true
        );
      }

      uint256 rebalancingTokenSetBalance = ERC20Wrapper.balanceOf(_rebalancingSetAddress, address(this));

      emit IssueRebalancingSetFromERC20Token(rebalancingTokenSetBalance);

      issueRebalancingSetFromRemainingComponents(_rebalancingSetAddress);
    }

    function issueRebalancingSetFromRemainingComponents(address _rebalancingSetAddress) private {
      IRebalancingSetToken rebalancingSet = IRebalancingSetToken(_rebalancingSetAddress);
      address baseSetAddress = rebalancingSet.currentSet();
      ISetToken baseSet = ISetToken(baseSetAddress);

       
      uint256 minPossibleBaseSetQuantity = 2**256 - 1;
      bool missingComponents = false;
      for (uint256 i = 0; i < baseSet.getComponents().length; i++) {
        uint256 componentBalance = ERC20Wrapper.balanceOf(baseSet.getComponents()[i], address(this));
        if (componentBalance == 0) {
           
          emit MissingComponentForIssueRebalancingSetFromAllComponents(baseSet.getComponents()[i]);
          missingComponents = true;
          break;
        }

        ERC20Wrapper.approve(baseSet.getComponents()[i], transfersProxy, uint256(-1));

        uint256 possibleBaseSetQuantity = baseSet.naturalUnit().div(baseSet.getUnits()[i]).mul(componentBalance);
        if(possibleBaseSetQuantity < minPossibleBaseSetQuantity) {
          minPossibleBaseSetQuantity = possibleBaseSetQuantity;
        }
      }

      if (!missingComponents) {
         
        uint256 rationalBaseSetQuantity = minPossibleBaseSetQuantity.div(baseSet.naturalUnit());
        uint256 roundedBaseSetQuantity = rationalBaseSetQuantity.mul(baseSet.naturalUnit());

        emit IssueBaseSetFromComponents(minPossibleBaseSetQuantity, roundedBaseSetQuantity);
        uint256 rebalancingSetUnitShares = rebalancingSet.unitShares();
        uint256 rebalancingSetNaturalUnits = rebalancingSet.naturalUnit();
        uint256 impliedRebalancingSetQuantityFromBaseSet = roundedBaseSetQuantity
          .mul(rebalancingSetNaturalUnits)
          .div(rebalancingSetUnitShares);

        uint256 rationalRebalancingSetQuantity = impliedRebalancingSetQuantityFromBaseSet.div(rebalancingSet.naturalUnit());
        uint256 roundedRebalancingSetQuantity = rationalRebalancingSetQuantity.mul(rebalancingSet.naturalUnit());

        RebalancingSetIssuanceModule(rebalancingSetIssuanceModule).issueRebalancingSet(
          _rebalancingSetAddress, roundedRebalancingSetQuantity, true);

         
        uint256 rebalancingTokenSetBalance = ERC20Wrapper.balanceOf(_rebalancingSetAddress, address(this));

        emit IssueRebalancingSetFromComponents(rebalancingTokenSetBalance);

      }
    }

    function getRedeemRebalancingSetSigner(address _rebalancingSetAddress, address _outputTokenAddress, address _to, uint256 _nonce, bytes memory _signature) private view returns (address) {
      bytes32 msgHash = OpenZeppelinUpgradesECDSA.toEthSignedMessageHash(
      keccak256(
          abi.encodePacked(
            _rebalancingSetAddress,
            _outputTokenAddress,
            _to,
            _nonce,
            address(this)
          )
        )
      );
      return OpenZeppelinUpgradesECDSA.recover(msgHash, _signature);
    }

    function redeemRebalancingSetIntoERC20(
      address _rebalancingSetAddress,
      uint256 _rebalancingSetQuantity,
      address _outputTokenAddress,
      ExchangeIssuanceLibrary.ExchangeIssuanceParams memory _exchangeIssuanceParams,
      bytes memory _orderData,
      address _to,
      uint256 _nonce,
      bytes memory _signature
    )
        public
        nonReentrant
    {

      require(!redeemRebalancingSetUsedNonces[_nonce], "Replay attack detected.");
      redeemRebalancingSetUsedNonces[_nonce] = true;
      address signer = getRedeemRebalancingSetSigner(_rebalancingSetAddress, _outputTokenAddress, _to, _nonce, _signature);
      require(signer != address(0), "Invalid signature");
      require(isWhitelistAdmin(signer), "signer is not an admin");

       
      ISetToken baseSet = ISetToken(IRebalancingSetToken(_rebalancingSetAddress).currentSet());
      if (baseSet.getComponents().length == 1 &&
          (_outputTokenAddress == baseSet.getComponents()[0]
          ||
          _outputTokenAddress == IAddressToAddressWhiteList(cTokenaddressToAddressWhiteList).whitelist(baseSet.getComponents()[0])
      )) {
         
        RebalancingSetIssuanceModule(rebalancingSetIssuanceModule).redeemRebalancingSet(
          _rebalancingSetAddress, _rebalancingSetQuantity, false);
      } else {
        RebalancingSetExchangeIssuanceModule(rebalancingSetExchangeIssuanceModule).redeemRebalancingSetIntoERC20(
          _rebalancingSetAddress,
          _rebalancingSetQuantity,
          _outputTokenAddress,
          _exchangeIssuanceParams,
          _orderData,
          false
        );
      }

       
      uint256 outputTokenBalance = ERC20Wrapper.balanceOf(_outputTokenAddress, address(this));

      ERC20Wrapper.transfer(
          _outputTokenAddress,
          _to,
          outputTokenBalance
      );

      emit RedeemedRebalancingSetIntoERC20(_outputTokenAddress, outputTokenBalance);
    }

}