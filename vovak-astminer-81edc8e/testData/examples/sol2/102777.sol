 

 

pragma solidity ^0.4.24;


interface IACLOracle {
    function canPerform(address who, address where, bytes32 what, uint256[] how) external view returns (bool);
}

 

 

pragma solidity ^0.4.24;


interface IACL {
    function initialize(address permissionsCreator) external;

     
     
    function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);
}

 

 

pragma solidity ^0.4.24;


interface IVaultRecoverable {
    event RecoverToVault(address indexed vault, address indexed token, uint256 amount);

    function transferToVault(address token) external;

    function allowRecoverability(address token) external view returns (bool);
    function getRecoveryVault() external view returns (address);
}

 

 

pragma solidity ^0.4.24;




interface IKernelEvents {
    event SetApp(bytes32 indexed namespace, bytes32 indexed appId, address app);
}


 
contract IKernel is IKernelEvents, IVaultRecoverable {
    function acl() public view returns (IACL);
    function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);

    function setApp(bytes32 namespace, bytes32 appId, address app) public;
    function getApp(bytes32 namespace, bytes32 appId) public view returns (address);
}

 

 

pragma solidity ^0.4.24;



contract IAragonApp {
     
    bytes4 internal constant ARAGON_APP_INTERFACE_ID = bytes4(0x54053e6c);

    function kernel() public view returns (IKernel);
    function appId() public view returns (bytes32);
}

 

 

pragma solidity ^0.4.24;


library UnstructuredStorage {
    function getStorageBool(bytes32 position) internal view returns (bool data) {
        assembly { data := sload(position) }
    }

    function getStorageAddress(bytes32 position) internal view returns (address data) {
        assembly { data := sload(position) }
    }

    function getStorageBytes32(bytes32 position) internal view returns (bytes32 data) {
        assembly { data := sload(position) }
    }

    function getStorageUint256(bytes32 position) internal view returns (uint256 data) {
        assembly { data := sload(position) }
    }

    function setStorageBool(bytes32 position, bool data) internal {
        assembly { sstore(position, data) }
    }

    function setStorageAddress(bytes32 position, address data) internal {
        assembly { sstore(position, data) }
    }

    function setStorageBytes32(bytes32 position, bytes32 data) internal {
        assembly { sstore(position, data) }
    }

    function setStorageUint256(bytes32 position, uint256 data) internal {
        assembly { sstore(position, data) }
    }
}

 

 

pragma solidity ^0.4.24;





contract AppStorage is IAragonApp {
    using UnstructuredStorage for bytes32;

     
    bytes32 internal constant KERNEL_POSITION = 0x4172f0f7d2289153072b0a6ca36959e0cbe2efc3afe50fc81636caa96338137b;
    bytes32 internal constant APP_ID_POSITION = 0xd625496217aa6a3453eecb9c3489dc5a53e6c67b444329ea2b2cbc9ff547639b;

    function kernel() public view returns (IKernel) {
        return IKernel(KERNEL_POSITION.getStorageAddress());
    }

    function appId() public view returns (bytes32) {
        return APP_ID_POSITION.getStorageBytes32();
    }

    function setKernel(IKernel _kernel) internal {
        KERNEL_POSITION.setStorageAddress(address(_kernel));
    }

    function setAppId(bytes32 _appId) internal {
        APP_ID_POSITION.setStorageBytes32(_appId);
    }
}

 

 

pragma solidity ^0.4.24;


contract ACLSyntaxSugar {
    function arr() internal pure returns (uint256[]) {
        return new uint256[](0);
    }

    function arr(bytes32 _a) internal pure returns (uint256[] r) {
        return arr(uint256(_a));
    }

    function arr(bytes32 _a, bytes32 _b) internal pure returns (uint256[] r) {
        return arr(uint256(_a), uint256(_b));
    }

    function arr(address _a) internal pure returns (uint256[] r) {
        return arr(uint256(_a));
    }

    function arr(address _a, address _b) internal pure returns (uint256[] r) {
        return arr(uint256(_a), uint256(_b));
    }

    function arr(address _a, uint256 _b, uint256 _c) internal pure returns (uint256[] r) {
        return arr(uint256(_a), _b, _c);
    }

    function arr(address _a, uint256 _b, uint256 _c, uint256 _d) internal pure returns (uint256[] r) {
        return arr(uint256(_a), _b, _c, _d);
    }

    function arr(address _a, uint256 _b) internal pure returns (uint256[] r) {
        return arr(uint256(_a), uint256(_b));
    }

    function arr(address _a, address _b, uint256 _c, uint256 _d, uint256 _e) internal pure returns (uint256[] r) {
        return arr(uint256(_a), uint256(_b), _c, _d, _e);
    }

    function arr(address _a, address _b, address _c) internal pure returns (uint256[] r) {
        return arr(uint256(_a), uint256(_b), uint256(_c));
    }

    function arr(address _a, address _b, uint256 _c) internal pure returns (uint256[] r) {
        return arr(uint256(_a), uint256(_b), uint256(_c));
    }

    function arr(uint256 _a) internal pure returns (uint256[] r) {
        r = new uint256[](1);
        r[0] = _a;
    }

    function arr(uint256 _a, uint256 _b) internal pure returns (uint256[] r) {
        r = new uint256[](2);
        r[0] = _a;
        r[1] = _b;
    }

    function arr(uint256 _a, uint256 _b, uint256 _c) internal pure returns (uint256[] r) {
        r = new uint256[](3);
        r[0] = _a;
        r[1] = _b;
        r[2] = _c;
    }

    function arr(uint256 _a, uint256 _b, uint256 _c, uint256 _d) internal pure returns (uint256[] r) {
        r = new uint256[](4);
        r[0] = _a;
        r[1] = _b;
        r[2] = _c;
        r[3] = _d;
    }

    function arr(uint256 _a, uint256 _b, uint256 _c, uint256 _d, uint256 _e) internal pure returns (uint256[] r) {
        r = new uint256[](5);
        r[0] = _a;
        r[1] = _b;
        r[2] = _c;
        r[3] = _d;
        r[4] = _e;
    }
}


contract ACLHelpers {
    function decodeParamOp(uint256 _x) internal pure returns (uint8 b) {
        return uint8(_x >> (8 * 30));
    }

    function decodeParamId(uint256 _x) internal pure returns (uint8 b) {
        return uint8(_x >> (8 * 31));
    }

    function decodeParamsList(uint256 _x) internal pure returns (uint32 a, uint32 b, uint32 c) {
        a = uint32(_x);
        b = uint32(_x >> (8 * 4));
        c = uint32(_x >> (8 * 8));
    }
}

 

pragma solidity ^0.4.24;


library Uint256Helpers {
    uint256 private constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";

    function toUint64(uint256 a) internal pure returns (uint64) {
        require(a <= MAX_UINT64, ERROR_NUMBER_TOO_BIG);
        return uint64(a);
    }
}

 

 

pragma solidity ^0.4.24;



contract TimeHelpers {
    using Uint256Helpers for uint256;

     
    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }

     
    function getBlockNumber64() internal view returns (uint64) {
        return getBlockNumber().toUint64();
    }

     
    function getTimestamp() internal view returns (uint256) {
        return block.timestamp;  
    }

     
    function getTimestamp64() internal view returns (uint64) {
        return getTimestamp().toUint64();
    }
}

 

 

pragma solidity ^0.4.24;




contract Initializable is TimeHelpers {
    using UnstructuredStorage for bytes32;

     
    bytes32 internal constant INITIALIZATION_BLOCK_POSITION = 0xebb05b386a8d34882b8711d156f463690983dc47815980fb82aeeff1aa43579e;

    string private constant ERROR_ALREADY_INITIALIZED = "INIT_ALREADY_INITIALIZED";
    string private constant ERROR_NOT_INITIALIZED = "INIT_NOT_INITIALIZED";

    modifier onlyInit {
        require(getInitializationBlock() == 0, ERROR_ALREADY_INITIALIZED);
        _;
    }

    modifier isInitialized {
        require(hasInitialized(), ERROR_NOT_INITIALIZED);
        _;
    }

     
    function getInitializationBlock() public view returns (uint256) {
        return INITIALIZATION_BLOCK_POSITION.getStorageUint256();
    }

     
    function hasInitialized() public view returns (bool) {
        uint256 initializationBlock = getInitializationBlock();
        return initializationBlock != 0 && getBlockNumber() >= initializationBlock;
    }

     
    function initialized() internal onlyInit {
        INITIALIZATION_BLOCK_POSITION.setStorageUint256(getBlockNumber());
    }

     
    function initializedAt(uint256 _blockNumber) internal onlyInit {
        INITIALIZATION_BLOCK_POSITION.setStorageUint256(_blockNumber);
    }
}

 

 

pragma solidity ^0.4.24;



contract Petrifiable is Initializable {
     
    uint256 internal constant PETRIFIED_BLOCK = uint256(-1);

    function isPetrified() public view returns (bool) {
        return getInitializationBlock() == PETRIFIED_BLOCK;
    }

     
    function petrify() internal onlyInit {
        initializedAt(PETRIFIED_BLOCK);
    }
}

 

 

pragma solidity ^0.4.24;



contract Autopetrified is Petrifiable {
    constructor() public {
         
         
        petrify();
    }
}

 

pragma solidity ^0.4.24;


library ConversionHelpers {
    string private constant ERROR_IMPROPER_LENGTH = "CONVERSION_IMPROPER_LENGTH";

    function dangerouslyCastUintArrayToBytes(uint256[] memory _input) internal pure returns (bytes memory output) {
         
         
         
        uint256 byteLength = _input.length * 32;
        assembly {
            output := _input
            mstore(output, byteLength)
        }
    }

    function dangerouslyCastBytesToUintArray(bytes memory _input) internal pure returns (uint256[] memory output) {
         
         
         
        uint256 intsLength = _input.length / 32;
        require(_input.length == intsLength * 32, ERROR_IMPROPER_LENGTH);

        assembly {
            output := _input
            mstore(output, intsLength)
        }
    }
}

 

 

pragma solidity ^0.4.24;



contract ReentrancyGuard {
    using UnstructuredStorage for bytes32;

     
    bytes32 private constant REENTRANCY_MUTEX_POSITION = 0xe855346402235fdd185c890e68d2c4ecad599b88587635ee285bce2fda58dacb;

    string private constant ERROR_REENTRANT = "REENTRANCY_REENTRANT_CALL";

    modifier nonReentrant() {
         
        require(!REENTRANCY_MUTEX_POSITION.getStorageBool(), ERROR_REENTRANT);

         
        REENTRANCY_MUTEX_POSITION.setStorageBool(true);

         
        _;

         
        REENTRANCY_MUTEX_POSITION.setStorageBool(false);
    }
}

 

 

pragma solidity ^0.4.24;


 
contract ERC20 {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function allowance(address _owner, address _spender)
        public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value)
        public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value)
        public returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

 

 

pragma solidity ^0.4.24;


 
 
contract EtherTokenConstant {
    address internal constant ETH = address(0);
}

 

 

pragma solidity ^0.4.24;


contract IsContract {
     
    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }
}

 

 
 

pragma solidity ^0.4.24;



library SafeERC20 {
     
     
    bytes4 private constant TRANSFER_SELECTOR = 0xa9059cbb;

    string private constant ERROR_TOKEN_BALANCE_REVERTED = "SAFE_ERC_20_BALANCE_REVERTED";
    string private constant ERROR_TOKEN_ALLOWANCE_REVERTED = "SAFE_ERC_20_ALLOWANCE_REVERTED";

    function invokeAndCheckSuccess(address _addr, bytes memory _calldata)
        private
        returns (bool)
    {
        bool ret;
        assembly {
            let ptr := mload(0x40)     

            let success := call(
                gas,                   
                _addr,                 
                0,                     
                add(_calldata, 0x20),  
                mload(_calldata),      
                ptr,                   
                0x20                   
            )

            if gt(success, 0) {
                 
                switch returndatasize

                 
                case 0 {
                    ret := 1
                }

                 
                case 0x20 {
                     
                     
                    ret := eq(mload(ptr), 1)
                }

                 
                default { }
            }
        }
        return ret;
    }

    function staticInvoke(address _addr, bytes memory _calldata)
        private
        view
        returns (bool, uint256)
    {
        bool success;
        uint256 ret;
        assembly {
            let ptr := mload(0x40)     

            success := staticcall(
                gas,                   
                _addr,                 
                add(_calldata, 0x20),  
                mload(_calldata),      
                ptr,                   
                0x20                   
            )

            if gt(success, 0) {
                ret := mload(ptr)
            }
        }
        return (success, ret);
    }

     
    function safeTransfer(ERC20 _token, address _to, uint256 _amount) internal returns (bool) {
        bytes memory transferCallData = abi.encodeWithSelector(
            TRANSFER_SELECTOR,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(_token, transferCallData);
    }

     
    function safeTransferFrom(ERC20 _token, address _from, address _to, uint256 _amount) internal returns (bool) {
        bytes memory transferFromCallData = abi.encodeWithSelector(
            _token.transferFrom.selector,
            _from,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(_token, transferFromCallData);
    }

     
    function safeApprove(ERC20 _token, address _spender, uint256 _amount) internal returns (bool) {
        bytes memory approveCallData = abi.encodeWithSelector(
            _token.approve.selector,
            _spender,
            _amount
        );
        return invokeAndCheckSuccess(_token, approveCallData);
    }

     
    function staticBalanceOf(ERC20 _token, address _owner) internal view returns (uint256) {
        bytes memory balanceOfCallData = abi.encodeWithSelector(
            _token.balanceOf.selector,
            _owner
        );

        (bool success, uint256 tokenBalance) = staticInvoke(_token, balanceOfCallData);
        require(success, ERROR_TOKEN_BALANCE_REVERTED);

        return tokenBalance;
    }

     
    function staticAllowance(ERC20 _token, address _owner, address _spender) internal view returns (uint256) {
        bytes memory allowanceCallData = abi.encodeWithSelector(
            _token.allowance.selector,
            _owner,
            _spender
        );

        (bool success, uint256 allowance) = staticInvoke(_token, allowanceCallData);
        require(success, ERROR_TOKEN_ALLOWANCE_REVERTED);

        return allowance;
    }

     
    function staticTotalSupply(ERC20 _token) internal view returns (uint256) {
        bytes memory totalSupplyCallData = abi.encodeWithSelector(_token.totalSupply.selector);

        (bool success, uint256 totalSupply) = staticInvoke(_token, totalSupplyCallData);
        require(success, ERROR_TOKEN_ALLOWANCE_REVERTED);

        return totalSupply;
    }
}

 

 

pragma solidity ^0.4.24;







contract VaultRecoverable is IVaultRecoverable, EtherTokenConstant, IsContract {
    using SafeERC20 for ERC20;

    string private constant ERROR_DISALLOWED = "RECOVER_DISALLOWED";
    string private constant ERROR_VAULT_NOT_CONTRACT = "RECOVER_VAULT_NOT_CONTRACT";
    string private constant ERROR_TOKEN_TRANSFER_FAILED = "RECOVER_TOKEN_TRANSFER_FAILED";

     
    function transferToVault(address _token) external {
        require(allowRecoverability(_token), ERROR_DISALLOWED);
        address vault = getRecoveryVault();
        require(isContract(vault), ERROR_VAULT_NOT_CONTRACT);

        uint256 balance;
        if (_token == ETH) {
            balance = address(this).balance;
            vault.transfer(balance);
        } else {
            ERC20 token = ERC20(_token);
            balance = token.staticBalanceOf(this);
            require(token.safeTransfer(vault, balance), ERROR_TOKEN_TRANSFER_FAILED);
        }

        emit RecoverToVault(vault, _token, balance);
    }

     
    function allowRecoverability(address token) public view returns (bool) {
        return true;
    }

     
    function getRecoveryVault() public view returns (address);
}

 

 

pragma solidity ^0.4.24;


interface IEVMScriptExecutor {
    function execScript(bytes script, bytes input, address[] blacklist) external returns (bytes);
    function executorType() external pure returns (bytes32);
}

 

 

pragma solidity ^0.4.24;



contract EVMScriptRegistryConstants {
     
    bytes32 internal constant EVMSCRIPT_REGISTRY_APP_ID = 0xddbcfd564f642ab5627cf68b9b7d374fb4f8a36e941a75d89c87998cef03bd61;
}


interface IEVMScriptRegistry {
    function addScriptExecutor(IEVMScriptExecutor executor) external returns (uint id);
    function disableScriptExecutor(uint256 executorId) external;

     
     
    function getScriptExecutor(bytes script) public view returns (IEVMScriptExecutor);
}

 

 

pragma solidity ^0.4.24;


contract KernelAppIds {
     
    bytes32 internal constant KERNEL_CORE_APP_ID = 0x3b4bf6bf3ad5000ecf0f989d5befde585c6860fea3e574a4fab4c49d1c177d9c;
    bytes32 internal constant KERNEL_DEFAULT_ACL_APP_ID = 0xe3262375f45a6e2026b7e7b18c2b807434f2508fe1a2a3dfb493c7df8f4aad6a;
    bytes32 internal constant KERNEL_DEFAULT_VAULT_APP_ID = 0x7e852e0fcfce6551c13800f1e7476f982525c2b5277ba14b24339c68416336d1;
}


contract KernelNamespaceConstants {
     
    bytes32 internal constant KERNEL_CORE_NAMESPACE = 0xc681a85306374a5ab27f0bbc385296a54bcd314a1948b6cf61c4ea1bc44bb9f8;
    bytes32 internal constant KERNEL_APP_BASES_NAMESPACE = 0xf1f3eb40f5bc1ad1344716ced8b8a0431d840b5783aea1fd01786bc26f35ac0f;
    bytes32 internal constant KERNEL_APP_ADDR_NAMESPACE = 0xd6f028ca0e8edb4a8c9757ca4fdccab25fa1e0317da1188108f7d2dee14902fb;
}

 

 

pragma solidity ^0.4.24;







contract EVMScriptRunner is AppStorage, Initializable, EVMScriptRegistryConstants, KernelNamespaceConstants {
    string private constant ERROR_EXECUTOR_UNAVAILABLE = "EVMRUN_EXECUTOR_UNAVAILABLE";
    string private constant ERROR_PROTECTED_STATE_MODIFIED = "EVMRUN_PROTECTED_STATE_MODIFIED";

     

    event ScriptResult(address indexed executor, bytes script, bytes input, bytes returnData);

    function getEVMScriptExecutor(bytes _script) public view returns (IEVMScriptExecutor) {
        return IEVMScriptExecutor(getEVMScriptRegistry().getScriptExecutor(_script));
    }

    function getEVMScriptRegistry() public view returns (IEVMScriptRegistry) {
        address registryAddr = kernel().getApp(KERNEL_APP_ADDR_NAMESPACE, EVMSCRIPT_REGISTRY_APP_ID);
        return IEVMScriptRegistry(registryAddr);
    }

    function runScript(bytes _script, bytes _input, address[] _blacklist)
        internal
        isInitialized
        protectState
        returns (bytes)
    {
        IEVMScriptExecutor executor = getEVMScriptExecutor(_script);
        require(address(executor) != address(0), ERROR_EXECUTOR_UNAVAILABLE);

        bytes4 sig = executor.execScript.selector;
        bytes memory data = abi.encodeWithSelector(sig, _script, _input, _blacklist);

        bytes memory output;
        assembly {
            let success := delegatecall(
                gas,                 
                executor,            
                add(data, 0x20),     
                mload(data),         
                0,                   
                0                    
            )

            output := mload(0x40)  

            switch success
            case 0 {
                 
                returndatacopy(output, 0, returndatasize)
                revert(output, returndatasize)
            }
            default {
                switch gt(returndatasize, 0x3f)
                case 0 {
                     
                     
                     
                     
                    mstore(output, 0x08c379a000000000000000000000000000000000000000000000000000000000)          
                    mstore(add(output, 0x04), 0x0000000000000000000000000000000000000000000000000000000000000020)  
                    mstore(add(output, 0x24), 0x000000000000000000000000000000000000000000000000000000000000001e)  
                    mstore(add(output, 0x44), 0x45564d52554e5f4558454355544f525f494e56414c49445f52455455524e0000)  

                    revert(output, 100)  
                }
                default {
                     
                     
                     
                     
                     
                     
                     
                     
                     
                    let copysize := sub(returndatasize, 0x20)
                    returndatacopy(output, 0x20, copysize)

                    mstore(0x40, add(output, copysize))  
                }
            }
        }

        emit ScriptResult(address(executor), _script, _input, output);

        return output;
    }

    modifier protectState {
        address preKernel = address(kernel());
        bytes32 preAppId = appId();
        _;  
        require(address(kernel()) == preKernel, ERROR_PROTECTED_STATE_MODIFIED);
        require(appId() == preAppId, ERROR_PROTECTED_STATE_MODIFIED);
    }
}

 

 

pragma solidity ^0.4.24;


contract ERC165 {
     
    bytes4 internal constant ERC165_INTERFACE_ID = bytes4(0x01ffc9a7);

     
    function supportsInterface(bytes4 _interfaceId) public pure returns (bool) {
        return _interfaceId == ERC165_INTERFACE_ID;
    }
}

 

 

pragma solidity ^0.4.24;










 
 
 
 
 
contract AragonApp is ERC165, AppStorage, Autopetrified, VaultRecoverable, ReentrancyGuard, EVMScriptRunner, ACLSyntaxSugar {
    string private constant ERROR_AUTH_FAILED = "APP_AUTH_FAILED";

    modifier auth(bytes32 _role) {
        require(canPerform(msg.sender, _role, new uint256[](0)), ERROR_AUTH_FAILED);
        _;
    }

    modifier authP(bytes32 _role, uint256[] _params) {
        require(canPerform(msg.sender, _role, _params), ERROR_AUTH_FAILED);
        _;
    }

     
    function canPerform(address _sender, bytes32 _role, uint256[] _params) public view returns (bool) {
        if (!hasInitialized()) {
            return false;
        }

        IKernel linkedKernel = kernel();
        if (address(linkedKernel) == address(0)) {
            return false;
        }

        return linkedKernel.hasPermission(
            _sender,
            address(this),
            _role,
            ConversionHelpers.dangerouslyCastUintArrayToBytes(_params)
        );
    }

     
    function getRecoveryVault() public view returns (address) {
         
        return kernel().getRecoveryVault();  
    }

     
    function supportsInterface(bytes4 _interfaceId) public pure returns (bool) {
        return super.supportsInterface(_interfaceId) || _interfaceId == ARAGON_APP_INTERFACE_ID;
    }
}

 

 

pragma solidity ^0.4.24;



contract IAgreement {

    event ActionSubmitted(uint256 indexed actionId, address indexed disputable);
    event ActionClosed(uint256 indexed actionId);
    event ActionChallenged(uint256 indexed actionId, uint256 indexed challengeId);
    event ActionSettled(uint256 indexed actionId, uint256 indexed challengeId);
    event ActionDisputed(uint256 indexed actionId, uint256 indexed challengeId);
    event ActionAccepted(uint256 indexed actionId, uint256 indexed challengeId);
    event ActionVoided(uint256 indexed actionId, uint256 indexed challengeId);
    event ActionRejected(uint256 indexed actionId, uint256 indexed challengeId);

    enum ChallengeState {
        Waiting,
        Settled,
        Disputed,
        Rejected,
        Accepted,
        Voided
    }

    function newAction(uint256 _disputableActionId, bytes _context, address _submitter) external returns (uint256);

    function closeAction(uint256 _actionId) external;

    function challengeAction(uint256 _actionId, uint256 _settlementOffer, bool _finishedSubmittingEvidence, bytes _context) external;

    function settleAction(uint256 _actionId) external;

    function disputeAction(uint256 _actionId, bool _finishedSubmittingEvidence) external;
}

 

 

pragma solidity ^0.4.24;





contract IDisputable is ERC165 {
     
     
    bytes4 internal constant DISPUTABLE_INTERFACE_ID = bytes4(0xf3d3bb51);

    event AgreementSet(IAgreement indexed agreement);

    function setAgreement(IAgreement _agreement) external;

    function onDisputableActionChallenged(uint256 _disputableActionId, uint256 _challengeId, address _challenger) external;

    function onDisputableActionAllowed(uint256 _disputableActionId) external;

    function onDisputableActionRejected(uint256 _disputableActionId) external;

    function onDisputableActionVoided(uint256 _disputableActionId) external;

    function getAgreement() external view returns (IAgreement);

    function canChallenge(uint256 _disputableActionId) external view returns (bool);

    function canClose(uint256 _disputableActionId) external view returns (bool);
}

 

 
 
 

pragma solidity ^0.4.24;


 
library SafeMath64 {
    string private constant ERROR_ADD_OVERFLOW = "MATH64_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH64_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH64_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH64_DIV_ZERO";

     
    function mul(uint64 _a, uint64 _b) internal pure returns (uint64) {
        uint256 c = uint256(_a) * uint256(_b);
        require(c < 0x010000000000000000, ERROR_MUL_OVERFLOW);  

        return uint64(c);
    }

     
    function div(uint64 _a, uint64 _b) internal pure returns (uint64) {
        require(_b > 0, ERROR_DIV_ZERO);  
        uint64 c = _a / _b;
         

        return c;
    }

     
    function sub(uint64 _a, uint64 _b) internal pure returns (uint64) {
        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint64 c = _a - _b;

        return c;
    }

     
    function add(uint64 _a, uint64 _b) internal pure returns (uint64) {
        uint64 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

     
    function mod(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}

 

 

pragma solidity ^0.4.24;







contract DisputableAragonApp is IDisputable, AragonApp {
     
    string internal constant ERROR_SENDER_NOT_AGREEMENT = "DISPUTABLE_SENDER_NOT_AGREEMENT";
    string internal constant ERROR_AGREEMENT_STATE_INVALID = "DISPUTABLE_AGREEMENT_STATE_INVAL";

     
     
     
    bytes32 public constant CHALLENGE_ROLE = 0xef025787d7cd1a96d9014b8dc7b44899b8c1350859fb9e1e05f5a546dd65158d;

     
    bytes32 public constant SET_AGREEMENT_ROLE = 0x8dad640ab1b088990c972676ada708447affc660890ec9fc9a5483241c49f036;

     
    bytes32 internal constant AGREEMENT_POSITION = 0x6dbe80ccdeafbf5f3fff5738b224414f85e9370da36f61bf21c65159df7409e9;

    modifier onlyAgreement() {
        require(address(_getAgreement()) == msg.sender, ERROR_SENDER_NOT_AGREEMENT);
        _;
    }

     
    function onDisputableActionChallenged(uint256 _disputableActionId, uint256 _challengeId, address _challenger) external onlyAgreement {
        _onDisputableActionChallenged(_disputableActionId, _challengeId, _challenger);
    }

     
    function onDisputableActionAllowed(uint256 _disputableActionId) external onlyAgreement {
        _onDisputableActionAllowed(_disputableActionId);
    }

     
    function onDisputableActionRejected(uint256 _disputableActionId) external onlyAgreement {
        _onDisputableActionRejected(_disputableActionId);
    }

     
    function onDisputableActionVoided(uint256 _disputableActionId) external onlyAgreement {
        _onDisputableActionVoided(_disputableActionId);
    }

     
    function setAgreement(IAgreement _agreement) external auth(SET_AGREEMENT_ROLE) {
        IAgreement agreement = _getAgreement();
        require(agreement == IAgreement(0) && _agreement != IAgreement(0), ERROR_AGREEMENT_STATE_INVALID);

        AGREEMENT_POSITION.setStorageAddress(address(_agreement));
        emit AgreementSet(_agreement);
    }

     
    function getAgreement() external view returns (IAgreement) {
        return _getAgreement();
    }

     
    function supportsInterface(bytes4 _interfaceId) public pure returns (bool) {
        return super.supportsInterface(_interfaceId) || _interfaceId == DISPUTABLE_INTERFACE_ID;
    }

     
    function _onDisputableActionChallenged(uint256 _disputableActionId, uint256 _challengeId, address _challenger) internal;

     
    function _onDisputableActionRejected(uint256 _disputableActionId) internal;

     
    function _onDisputableActionAllowed(uint256 _disputableActionId) internal;

     
    function _onDisputableActionVoided(uint256 _disputableActionId) internal;

     
    function _registerDisputableAction(uint256 _disputableActionId, bytes _context, address _submitter) internal returns (uint256) {
        IAgreement agreement = _ensureAgreement();
        return agreement.newAction(_disputableActionId, _context, _submitter);
    }

     
    function _closeDisputableAction(uint256 _actionId) internal {
        IAgreement agreement = _ensureAgreement();
        agreement.closeAction(_actionId);
    }

     
    function _getAgreement() internal view returns (IAgreement) {
        return IAgreement(AGREEMENT_POSITION.getStorageAddress());
    }

     
    function _ensureAgreement() internal view returns (IAgreement) {
        IAgreement agreement = _getAgreement();
        require(agreement != IAgreement(0), ERROR_AGREEMENT_STATE_INVALID);
        return agreement;
    }
}

 

 
 

pragma solidity ^0.4.24;


 
library SafeMath {
    string private constant ERROR_ADD_OVERFLOW = "MATH_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH_DIV_ZERO";

     
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
         
         
         
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b, ERROR_MUL_OVERFLOW);

        return c;
    }

     
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0, ERROR_DIV_ZERO);  
        uint256 c = _a / _b;
         

        return c;
    }

     
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint256 c = _a - _b;

        return c;
    }

     
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}

 

pragma solidity >=0.4 <=0.7;


interface IStaking {
    function allowManager(address _lockManager, uint256 _allowance, bytes _data) external;
    function allowManagerAndLock(uint256 _amount, address _lockManager, uint256 _allowance, bytes _data) external;
    function unlockAndRemoveManager(address _account, address _lockManager) external;
    function increaseLockAllowance(address _lockManager, uint256 _allowance) external;
    function decreaseLockAllowance(address _account, address _lockManager, uint256 _allowance) external;
    function lock(address _account, address _lockManager, uint256 _amount) external;
    function unlock(address _account, address _lockManager, uint256 _amount) external;
    function setLockManager(address _account, address _newLockManager) external;
    function transfer(address _to, uint256 _amount) external;
    function transferAndUnstake(address _to, uint256 _amount) external;
    function slash(address _account, address _to, uint256 _amount) external;
    function slashAndUnstake(address _account, address _to, uint256 _amount) external;

    function getLock(address _account, address _lockManager) external view returns (uint256 _amount, uint256 _allowance);
    function unlockedBalanceOf(address _account) external view returns (uint256);
    function lockedBalanceOf(address _user) external view returns (uint256);
    function getBalancesOf(address _user) external view returns (uint256 staked, uint256 locked);
    function canUnlock(address _sender, address _account, address _lockManager, uint256 _amount) external view returns (bool);
}

 

pragma solidity >=0.4 <=0.7;



interface IStakingFactory {
    function existsInstance(  address token) external view returns (bool);
    function getInstance(  address token) external view returns (IStaking);
    function getOrCreateInstance(  address token) external returns (IStaking);
}

 

pragma solidity >=0.4 <=0.7;


interface ILockManager {
     
    function canUnlock(address _user, uint256 _amount) external view returns (bool);
}

 

pragma solidity ^0.4.24;



 
interface IArbitrator {
     
    function createDispute(uint256 _possibleRulings, bytes _metadata) external returns (uint256);

     
    function closeEvidencePeriod(uint256 _disputeId) external;

     
    function executeRuling(uint256 _disputeId) external;

     
    function getDisputeFees() external view returns (address recipient, ERC20 feeToken, uint256 feeAmount);

     
    function getSubscriptionFees(address _subscriber) external view returns (address recipient, ERC20 feeToken, uint256 feeAmount);
}

 

pragma solidity ^0.4.24;




 
contract IArbitrable is ERC165 {
    bytes4 internal constant ARBITRABLE_INTERFACE_ID = bytes4(0x88f3ee69);

     
    event Ruled(IArbitrator indexed arbitrator, uint256 indexed disputeId, uint256 ruling);

     
    event EvidenceSubmitted(IArbitrator indexed arbitrator, uint256 indexed disputeId, address indexed submitter, bytes evidence, bool finished);

     
    function submitEvidence(uint256 _disputeId, bytes _evidence, bool _finished) external;

     
    function rule(uint256 _disputeId, uint256 _ruling) external;

     
    function supportsInterface(bytes4 _interfaceId) public pure returns (bool) {
        return super.supportsInterface(_interfaceId) || _interfaceId == ARBITRABLE_INTERFACE_ID;
    }
}

 

pragma solidity ^0.4.24;



 
interface IAragonAppFeesCashier {
     
    event AppFeeSet(bytes32 indexed appId, ERC20 token, uint256 amount);

     
    event AppFeeUnset(bytes32 indexed appId);

     
    event AppFeePaid(address indexed by, bytes32 appId, bytes data);

     
    function setAppFee(bytes32 _appId, ERC20 _token, uint256 _amount) external;

     
    function setAppFees(bytes32[] _appIds, ERC20[] _tokens, uint256[] _amounts) external;

     
    function unsetAppFee(bytes32 _appId) external;

     
    function unsetAppFees(bytes32[] _appIds) external;

     
    function payAppFees(bytes32 _appId, bytes _data) external payable;

     
    function getAppFee(bytes32 _appId) external view returns (ERC20 token, uint256 amount);
}

 

 

pragma solidity 0.4.24;
















contract Agreement is IArbitrable, ILockManager, IAgreement, IACLOracle, AragonApp {
    using SafeMath for uint256;
    using SafeMath64 for uint64;
    using SafeERC20 for ERC20;

     
    uint256 internal constant DISPUTES_POSSIBLE_OUTCOMES = 2;
     
     
     
     
    uint256 internal constant DISPUTES_RULING_SUBMITTER = 3;
    uint256 internal constant DISPUTES_RULING_CHALLENGER = 4;

     
    string internal constant ERROR_SENDER_NOT_ALLOWED = "AGR_SENDER_NOT_ALLOWED";
    string internal constant ERROR_SIGNER_MUST_SIGN = "AGR_SIGNER_MUST_SIGN";
    string internal constant ERROR_SIGNER_ALREADY_SIGNED = "AGR_SIGNER_ALREADY_SIGNED";
    string internal constant ERROR_INVALID_SIGNING_SETTING = "AGR_INVALID_SIGNING_SETTING";
    string internal constant ERROR_INVALID_SETTLEMENT_OFFER = "AGR_INVALID_SETTLEMENT_OFFER";
    string internal constant ERROR_ACTION_DOES_NOT_EXIST = "AGR_ACTION_DOES_NOT_EXIST";
    string internal constant ERROR_CHALLENGE_DOES_NOT_EXIST = "AGR_CHALLENGE_DOES_NOT_EXIST";
    string internal constant ERROR_TOKEN_DEPOSIT_FAILED = "AGR_TOKEN_DEPOSIT_FAILED";
    string internal constant ERROR_TOKEN_TRANSFER_FAILED = "AGR_TOKEN_TRANSFER_FAILED";
    string internal constant ERROR_TOKEN_APPROVAL_FAILED = "AGR_TOKEN_APPROVAL_FAILED";
    string internal constant ERROR_TOKEN_NOT_CONTRACT = "AGR_TOKEN_NOT_CONTRACT";
    string internal constant ERROR_SETTING_DOES_NOT_EXIST = "AGR_SETTING_DOES_NOT_EXIST";
    string internal constant ERROR_ARBITRATOR_NOT_CONTRACT = "AGR_ARBITRATOR_NOT_CONTRACT";
    string internal constant ERROR_STAKING_FACTORY_NOT_CONTRACT = "AGR_STAKING_FACTORY_NOT_CONTRACT";
    string internal constant ERROR_ACL_ORACLE_SIGNER_MISSING = "AGR_ACL_ORACLE_SIGNER_MISSING";
    string internal constant ERROR_ACL_ORACLE_SIGNER_NOT_ADDRESS = "AGR_ACL_ORACLE_SIGNER_NOT_ADDR";

     
    string internal constant ERROR_SENDER_CANNOT_CHALLENGE_ACTION = "AGR_SENDER_CANT_CHALLENGE_ACTION";
    string internal constant ERROR_DISPUTABLE_NOT_CONTRACT = "AGR_DISPUTABLE_NOT_CONTRACT";
    string internal constant ERROR_DISPUTABLE_NOT_ACTIVE = "AGR_DISPUTABLE_NOT_ACTIVE";
    string internal constant ERROR_DISPUTABLE_ALREADY_ACTIVE = "AGR_DISPUTABLE_ALREADY_ACTIVE";
    string internal constant ERROR_COLLATERAL_REQUIREMENT_DOES_NOT_EXIST = "AGR_COL_REQ_DOES_NOT_EXIST";

     
    string internal constant ERROR_CANNOT_CHALLENGE_ACTION = "AGR_CANNOT_CHALLENGE_ACTION";
    string internal constant ERROR_CANNOT_CLOSE_ACTION = "AGR_CANNOT_CLOSE_ACTION";
    string internal constant ERROR_CANNOT_SETTLE_ACTION = "AGR_CANNOT_SETTLE_ACTION";
    string internal constant ERROR_CANNOT_DISPUTE_ACTION = "AGR_CANNOT_DISPUTE_ACTION";
    string internal constant ERROR_CANNOT_RULE_ACTION = "AGR_CANNOT_RULE_ACTION";
    string internal constant ERROR_CANNOT_SUBMIT_EVIDENCE = "AGR_CANNOT_SUBMIT_EVIDENCE";
    string internal constant ERROR_CANNOT_CLOSE_EVIDENCE_PERIOD = "AGR_CANNOT_CLOSE_EVIDENCE_PERIOD";

     
     
     
    bytes32 public constant CHALLENGE_ROLE = 0xef025787d7cd1a96d9014b8dc7b44899b8c1350859fb9e1e05f5a546dd65158d;

     
    bytes32 public constant CHANGE_AGREEMENT_ROLE = 0x07813bca4905795fa22783885acd0167950db28f2d7a40b70f666f429e19f1d9;

     
    bytes32 public constant MANAGE_DISPUTABLE_ROLE = 0x2309a8cbbd5c3f18649f3b7ac47a0e7b99756c2ac146dda1ffc80d3f80827be6;

    event Signed(address indexed signer, uint256 settingId);
    event SettingChanged(uint256 settingId);
    event AppFeesCashierSynced(IAragonAppFeesCashier newAppFeesCashier);
    event DisputableAppActivated(address indexed disputable);
    event DisputableAppDeactivated(address indexed disputable);
    event CollateralRequirementChanged(address indexed disputable, uint256 collateralRequirementId);

    struct Setting {
        IArbitrator arbitrator;
        IAragonAppFeesCashier aragonAppFeesCashier;  
        string title;
        bytes content;
    }

    struct CollateralRequirement {
        ERC20 token;                         
        uint64 challengeDuration;            
        uint256 actionAmount;                
        uint256 challengeAmount;             
        IStaking staking;                    
    }

    struct DisputableInfo {
        bool activated;                                                      
        uint256 nextCollateralRequirementsId;                                
        mapping (uint256 => CollateralRequirement) collateralRequirements;   
    }

    struct Action {
        DisputableAragonApp disputable;      
        uint256 disputableActionId;          
        uint256 collateralRequirementId;     
        uint256 settingId;                   
        address submitter;                   
        bool closed;                         
        bytes context;                       
        uint256 lastChallengeId;             
    }

    struct ArbitratorFees {
        ERC20 token;                         
        uint256 amount;                      
    }

    struct Challenge {
        uint256 actionId;                         
        address challenger;                       
        uint64 endDate;                           
        bytes context;                            
        uint256 settlementOffer;                  
        ArbitratorFees challengerArbitratorFees;  
        ArbitratorFees submitterArbitratorFees;   
        ChallengeState state;                     
        bool submitterFinishedEvidence;           
        bool challengerFinishedEvidence;          
        uint256 disputeId;                        
        uint256 ruling;                           
    }

    IStakingFactory public stakingFactory;                            

    uint256 private nextSettingId;
    mapping (uint256 => Setting) private settings;                   
    mapping (address => uint256) private lastSettingSignedBy;        
    mapping (address => DisputableInfo) private disputableInfos;     

    uint256 private nextActionId;
    mapping (uint256 => Action) private actions;                     

    uint256 private nextChallengeId;
    mapping (uint256 => Challenge) private challenges;               
    mapping (uint256 => uint256) private challengeByDispute;         

     
    function initialize(
        IArbitrator _arbitrator,
        bool _setAppFeesCashier,
        string _title,
        bytes _content,
        IStakingFactory _stakingFactory
    )
        external
    {
        initialized();
        require(isContract(address(_stakingFactory)), ERROR_STAKING_FACTORY_NOT_CONTRACT);

        stakingFactory = _stakingFactory;

        nextSettingId = 1;    
        nextActionId = 1;     
        nextChallengeId = 1;  
        _newSetting(_arbitrator, _setAppFeesCashier, _title, _content);
    }

     
    function changeSetting(
        IArbitrator _arbitrator,
        bool _setAppFeesCashier,
        string _title,
        bytes _content
    )
        external
        auth(CHANGE_AGREEMENT_ROLE)
    {
        _newSetting(_arbitrator, _setAppFeesCashier, _title, _content);
    }

     
    function syncAppFeesCashier() external {
        Setting storage setting = _getSetting(_getCurrentSettingId());
        IAragonAppFeesCashier newAppFeesCashier = _getArbitratorFeesCashier(setting.arbitrator);
        IAragonAppFeesCashier currentAppFeesCashier = setting.aragonAppFeesCashier;

         
        if (currentAppFeesCashier != IAragonAppFeesCashier(0) && currentAppFeesCashier != newAppFeesCashier) {
            setting.aragonAppFeesCashier = newAppFeesCashier;
            emit AppFeesCashierSynced(newAppFeesCashier);
        }
    }

     
    function activate(
        address _disputableAddress,
        ERC20 _collateralToken,
        uint64 _challengeDuration,
        uint256 _actionAmount,
        uint256 _challengeAmount
    )
        external
        auth(MANAGE_DISPUTABLE_ROLE)
    {
        require(isContract(_disputableAddress), ERROR_DISPUTABLE_NOT_CONTRACT);

        DisputableInfo storage disputableInfo = disputableInfos[_disputableAddress];
        _ensureInactiveDisputable(disputableInfo);

        DisputableAragonApp disputable = DisputableAragonApp(_disputableAddress);
        disputableInfo.activated = true;

         
         
        if (disputable.getAgreement() != IAgreement(this)) {
            disputable.setAgreement(IAgreement(this));
            uint256 nextId = disputableInfo.nextCollateralRequirementsId;
            disputableInfo.nextCollateralRequirementsId = nextId > 0 ? nextId : 1;
        }
        _changeCollateralRequirement(disputable, disputableInfo, _collateralToken, _challengeDuration, _actionAmount, _challengeAmount);

        emit DisputableAppActivated(disputable);
    }

     
    function deactivate(address _disputableAddress) external auth(MANAGE_DISPUTABLE_ROLE) {
        DisputableInfo storage disputableInfo = disputableInfos[_disputableAddress];
        _ensureActiveDisputable(disputableInfo);

        disputableInfo.activated = false;
        emit DisputableAppDeactivated(_disputableAddress);
    }

     
    function changeCollateralRequirement(
        DisputableAragonApp _disputable,
        ERC20 _collateralToken,
        uint64 _challengeDuration,
        uint256 _actionAmount,
        uint256 _challengeAmount
    )
        external
        auth(MANAGE_DISPUTABLE_ROLE)
    {
        DisputableInfo storage disputableInfo = disputableInfos[address(_disputable)];
        _ensureActiveDisputable(disputableInfo);

        _changeCollateralRequirement(_disputable, disputableInfo, _collateralToken, _challengeDuration, _actionAmount, _challengeAmount);
    }

     
    function sign(uint256 _settingId) external {
        uint256 lastSettingIdSigned = lastSettingSignedBy[msg.sender];
        require(lastSettingIdSigned < _settingId, ERROR_SIGNER_ALREADY_SIGNED);
        require(_settingId < nextSettingId, ERROR_INVALID_SIGNING_SETTING);

        lastSettingSignedBy[msg.sender] = _settingId;
        emit Signed(msg.sender, _settingId);
    }

     
    function newAction(uint256 _disputableActionId, bytes _context, address _submitter) external returns (uint256) {
        DisputableInfo storage disputableInfo = disputableInfos[msg.sender];
        _ensureActiveDisputable(disputableInfo);

        uint256 currentSettingId = _getCurrentSettingId();
        uint256 lastSettingIdSigned = lastSettingSignedBy[_submitter];
        require(lastSettingIdSigned >= currentSettingId, ERROR_SIGNER_MUST_SIGN);

         
        uint256 currentCollateralRequirementId = disputableInfo.nextCollateralRequirementsId - 1;
        CollateralRequirement storage requirement = _getCollateralRequirement(disputableInfo, currentCollateralRequirementId);
        _lockBalance(requirement.staking, _submitter, requirement.actionAmount);

         
        Setting storage setting = _getSetting(currentSettingId);
        DisputableAragonApp disputable = DisputableAragonApp(msg.sender);
        _payAppFees(setting, disputable, _submitter, id);

        uint256 id = nextActionId++;
        Action storage action = actions[id];
        action.disputable = disputable;
        action.disputableActionId = _disputableActionId;
        action.collateralRequirementId = currentCollateralRequirementId;
        action.settingId = currentSettingId;
        action.submitter = _submitter;
        action.context = _context;

        emit ActionSubmitted(id, msg.sender);
        return id;
    }

     
    function closeAction(uint256 _actionId) external {
        Action storage action = _getAction(_actionId);
        if (action.closed) {
            return;
        }

        require(_canClose(action), ERROR_CANNOT_CLOSE_ACTION);
        (, CollateralRequirement storage requirement) = _getDisputableInfoFor(action);
        _unlockBalance(requirement.staking, action.submitter, requirement.actionAmount);
        _unsafeCloseAction(_actionId, action);
    }

     
    function challengeAction(uint256 _actionId, uint256 _settlementOffer, bool _finishedEvidence, bytes _context) external {
        Action storage action = _getAction(_actionId);
        require(_canChallenge(action), ERROR_CANNOT_CHALLENGE_ACTION);

        (DisputableAragonApp disputable, CollateralRequirement storage requirement) = _getDisputableInfoFor(action);
        require(_canPerformChallenge(disputable, msg.sender), ERROR_SENDER_CANNOT_CHALLENGE_ACTION);
        require(_settlementOffer <= requirement.actionAmount, ERROR_INVALID_SETTLEMENT_OFFER);

        uint256 challengeId = _createChallenge(_actionId, action, msg.sender, requirement, _settlementOffer, _finishedEvidence, _context);
        action.lastChallengeId = challengeId;
        disputable.onDisputableActionChallenged(action.disputableActionId, challengeId, msg.sender);
        emit ActionChallenged(_actionId, challengeId);
    }

     
    function settleAction(uint256 _actionId) external {
        (Action storage action, Challenge storage challenge, uint256 challengeId) = _getChallengedAction(_actionId);
        address submitter = action.submitter;

        if (msg.sender == submitter) {
            require(_canSettle(challenge), ERROR_CANNOT_SETTLE_ACTION);
        } else {
            require(_canClaimSettlement(challenge), ERROR_CANNOT_SETTLE_ACTION);
        }

        (DisputableAragonApp disputable, CollateralRequirement storage requirement) = _getDisputableInfoFor(action);
        uint256 actionCollateral = requirement.actionAmount;
        uint256 settlementOffer = challenge.settlementOffer;

         
         
         
        uint256 slashedAmount = settlementOffer >= actionCollateral ? actionCollateral : settlementOffer;
        uint256 unlockedAmount = actionCollateral - slashedAmount;

         
        address challenger = challenge.challenger;
        IStaking staking = requirement.staking;
        _unlockBalance(staking, submitter, unlockedAmount);
        _slashBalance(staking, submitter, challenger, slashedAmount);

         
        _transferTo(requirement.token, challenger, requirement.challengeAmount);
        _transferTo(challenge.challengerArbitratorFees.token, challenger, challenge.challengerArbitratorFees.amount);

        challenge.state = ChallengeState.Settled;
        disputable.onDisputableActionRejected(action.disputableActionId);
        emit ActionSettled(_actionId, challengeId);
        _unsafeCloseAction(_actionId, action);
    }

     
    function disputeAction(uint256 _actionId, bool _submitterFinishedEvidence) external {
        (Action storage action, Challenge storage challenge, uint256 challengeId) = _getChallengedAction(_actionId);
        require(_canDispute(challenge), ERROR_CANNOT_DISPUTE_ACTION);

        address submitter = action.submitter;
        require(msg.sender == submitter, ERROR_SENDER_NOT_ALLOWED);

        IArbitrator arbitrator = _getArbitratorFor(action);
        bytes memory metadata = abi.encodePacked(appId(), action.lastChallengeId);
        uint256 disputeId = _createDispute(action, challenge, arbitrator, metadata);
        _submitEvidence(arbitrator, disputeId, submitter, action.context, _submitterFinishedEvidence);
        _submitEvidence(arbitrator, disputeId, challenge.challenger, challenge.context, challenge.challengerFinishedEvidence);

        challenge.state = ChallengeState.Disputed;
        challenge.submitterFinishedEvidence = _submitterFinishedEvidence;
        challenge.disputeId = disputeId;
        challengeByDispute[disputeId] = challengeId;
        emit ActionDisputed(_actionId, challengeId);
    }

     
    function submitEvidence(uint256 _disputeId, bytes _evidence, bool _finished) external {
        (, Action storage action, , Challenge storage challenge) = _getDisputedAction(_disputeId);
        require(_isDisputed(challenge), ERROR_CANNOT_SUBMIT_EVIDENCE);

        IArbitrator arbitrator = _getArbitratorFor(action);
        if (msg.sender == action.submitter) {
             
            bool submitterFinishedEvidence = challenge.submitterFinishedEvidence || _finished;
            _submitEvidence(arbitrator, _disputeId, msg.sender, _evidence, submitterFinishedEvidence);
            challenge.submitterFinishedEvidence = submitterFinishedEvidence;
        } else if (msg.sender == challenge.challenger) {
             
            bool challengerFinishedEvidence = challenge.challengerFinishedEvidence || _finished;
            _submitEvidence(arbitrator, _disputeId, msg.sender, _evidence, challengerFinishedEvidence);
            challenge.challengerFinishedEvidence = challengerFinishedEvidence;
        } else {
            revert(ERROR_SENDER_NOT_ALLOWED);
        }
    }

     
    function closeEvidencePeriod(uint256 _disputeId) external {
        (, Action storage action, , Challenge storage challenge) = _getDisputedAction(_disputeId);
        require(_isDisputed(challenge), ERROR_CANNOT_SUBMIT_EVIDENCE);
        require(challenge.submitterFinishedEvidence && challenge.challengerFinishedEvidence, ERROR_CANNOT_CLOSE_EVIDENCE_PERIOD);

        IArbitrator arbitrator = _getArbitratorFor(action);
        arbitrator.closeEvidencePeriod(_disputeId);
    }

     
    function rule(uint256 _disputeId, uint256 _ruling) external {
        (uint256 actionId, Action storage action, uint256 challengeId, Challenge storage challenge) = _getDisputedAction(_disputeId);
        require(_isDisputed(challenge), ERROR_CANNOT_RULE_ACTION);

        IArbitrator arbitrator = _getArbitratorFor(action);
        require(arbitrator == IArbitrator(msg.sender), ERROR_SENDER_NOT_ALLOWED);

        challenge.ruling = _ruling;
        emit Ruled(arbitrator, _disputeId, _ruling);

        if (_ruling == DISPUTES_RULING_SUBMITTER) {
            _acceptAction(actionId, action, challengeId, challenge);
        } else if (_ruling == DISPUTES_RULING_CHALLENGER) {
            _rejectAction(actionId, action, challengeId, challenge);
        } else {
            _voidAction(actionId, action, challengeId, challenge);
        }
    }

     

     
    function getCurrentSettingId() external view returns (uint256) {
        return _getCurrentSettingId();
    }

     
    function getSetting(uint256 _settingId)
        external
        view
        returns (IArbitrator arbitrator, IAragonAppFeesCashier aragonAppFeesCashier, string title, bytes content)
    {
        Setting storage setting = _getSetting(_settingId);
        arbitrator = setting.arbitrator;
        aragonAppFeesCashier = setting.aragonAppFeesCashier;
        title = setting.title;
        content = setting.content;
    }

     
    function getDisputableInfo(address _disputable) external view returns (bool activated, uint256 currentCollateralRequirementId) {
        DisputableInfo storage disputableInfo = disputableInfos[_disputable];
        activated = disputableInfo.activated;
        uint256 nextId = disputableInfo.nextCollateralRequirementsId;
         
         
        currentCollateralRequirementId = nextId == 0 ? 0 : nextId - 1;
    }

     
    function getCollateralRequirement(address _disputable, uint256 _collateralRequirementId)
        external
        view
        returns (
            ERC20 collateralToken,
            uint64 challengeDuration,
            uint256 actionAmount,
            uint256 challengeAmount
        )
    {
        DisputableInfo storage disputableInfo = disputableInfos[_disputable];
        CollateralRequirement storage collateral = _getCollateralRequirement(disputableInfo, _collateralRequirementId);
        collateralToken = collateral.token;
        actionAmount = collateral.actionAmount;
        challengeAmount = collateral.challengeAmount;
        challengeDuration = collateral.challengeDuration;
    }

     
    function getSigner(address _signer) external view returns (uint256 lastSettingIdSigned, bool mustSign) {
        (lastSettingIdSigned, mustSign) = _getSigner(_signer);
    }

     
    function getAction(uint256 _actionId)
        external
        view
        returns (
            address disputable,
            uint256 disputableActionId,
            uint256 collateralRequirementId,
            uint256 settingId,
            address submitter,
            bool closed,
            bytes context,
            uint256 lastChallengeId,
            bool lastChallengeActive
        )
    {
        Action storage action = _getAction(_actionId);

        disputable = action.disputable;
        disputableActionId = action.disputableActionId;
        collateralRequirementId = action.collateralRequirementId;
        settingId = action.settingId;
        submitter = action.submitter;
        closed = action.closed;
        context = action.context;
        lastChallengeId = action.lastChallengeId;

        if (lastChallengeId > 0) {
            (, Challenge storage challenge, ) = _getChallengedAction(_actionId);
            lastChallengeActive = _isWaitingChallengeAnswer(challenge) || _isDisputed(challenge);
        }
    }

     
    function getChallenge(uint256 _challengeId)
        external
        view
        returns (
            uint256 actionId,
            address challenger,
            uint64 endDate,
            bytes context,
            uint256 settlementOffer,
            ChallengeState state,
            bool submitterFinishedEvidence,
            bool challengerFinishedEvidence,
            uint256 disputeId,
            uint256 ruling
        )
    {
        Challenge storage challenge = _getChallenge(_challengeId);

        actionId = challenge.actionId;
        challenger = challenge.challenger;
        endDate = challenge.endDate;
        context = challenge.context;
        settlementOffer = challenge.settlementOffer;
        state = challenge.state;
        submitterFinishedEvidence = challenge.submitterFinishedEvidence;
        challengerFinishedEvidence = challenge.challengerFinishedEvidence;
        disputeId = challenge.disputeId;
        ruling = challenge.ruling;
    }

     
    function getChallengeArbitratorFees(uint256 _challengeId)
        external
        view
        returns (
            ERC20 submitterArbitratorFeesToken,
            uint256 submitterArbitratorFeesAmount,
            ERC20 challengerArbitratorFeesToken,
            uint256 challengerArbitratorFeesAmount
        )
    {
        Challenge storage challenge = _getChallenge(_challengeId);

        submitterArbitratorFeesToken = challenge.submitterArbitratorFees.token;
        submitterArbitratorFeesAmount = challenge.submitterArbitratorFees.amount;
        challengerArbitratorFeesToken = challenge.challengerArbitratorFees.token;
        challengerArbitratorFeesAmount = challenge.challengerArbitratorFees.amount;
    }

     
    function canChallenge(uint256 _actionId) external view returns (bool) {
        Action storage action = _getAction(_actionId);
        return _canChallenge(action);
    }

     
    function canClose(uint256 _actionId) external view returns (bool) {
        Action storage action = _getAction(_actionId);
        return _canClose(action);
    }

     
    function canSettle(uint256 _actionId) external view returns (bool) {
        (, Challenge storage challenge, ) = _getChallengedAction(_actionId);
        return _canSettle(challenge);
    }

     
    function canClaimSettlement(uint256 _actionId) external view returns (bool) {
        (, Challenge storage challenge, ) = _getChallengedAction(_actionId);
        return _canClaimSettlement(challenge);
    }

     
    function canDispute(uint256 _actionId) external view returns (bool) {
        (, Challenge storage challenge, ) = _getChallengedAction(_actionId);
        return _canDispute(challenge);
    }

     
    function canRuleDispute(uint256 _actionId) external view returns (bool) {
        (, Challenge storage challenge, ) = _getChallengedAction(_actionId);
        return _isDisputed(challenge);
    }

     
    function canPerformChallenge(uint256 _actionId, address _challenger) external view returns (bool) {
        Action storage action = _getAction(_actionId);
        return _canPerformChallenge(action.disputable, _challenger);
    }

     
    function canPerform(address  , address  , bytes32  , uint256[] _how)
        external
        view
        returns (bool)
    {
         
         
        require(_how.length > 0, ERROR_ACL_ORACLE_SIGNER_MISSING);
        require(_how[0] < 2**160, ERROR_ACL_ORACLE_SIGNER_NOT_ADDRESS);

        address signer = address(_how[0]);
        (, bool mustSign) = _getSigner(signer);
        return !mustSign;
    }

     
    function canUnlock(address, uint256) external view returns (bool) {
        return false;
    }

     
    function allowRecoverability(address  ) public view returns (bool) {
        return false;
    }

     

     
    function _newSetting(IArbitrator _arbitrator, bool _setAppFeesCashier, string _title, bytes _content) internal {
        require(isContract(address(_arbitrator)), ERROR_ARBITRATOR_NOT_CONTRACT);

        uint256 id = nextSettingId++;
        Setting storage setting = settings[id];
        setting.title = _title;
        setting.content = _content;
        setting.arbitrator = _arbitrator;

         
         
         
        setting.aragonAppFeesCashier = _setAppFeesCashier ? _getArbitratorFeesCashier(_arbitrator) : IAragonAppFeesCashier(0);
        emit SettingChanged(id);
    }

     
    function _changeCollateralRequirement(
        DisputableAragonApp _disputable,
        DisputableInfo storage _disputableInfo,
        ERC20 _collateralToken,
        uint64 _challengeDuration,
        uint256 _actionAmount,
        uint256 _challengeAmount
    )
        internal
    {
        require(isContract(address(_collateralToken)), ERROR_TOKEN_NOT_CONTRACT);

        IStaking staking = stakingFactory.getOrCreateInstance(_collateralToken);
        uint256 id = _disputableInfo.nextCollateralRequirementsId++;
        CollateralRequirement storage collateralRequirement = _disputableInfo.collateralRequirements[id];
        collateralRequirement.token = _collateralToken;
        collateralRequirement.challengeDuration = _challengeDuration;
        collateralRequirement.actionAmount = _actionAmount;
        collateralRequirement.challengeAmount = _challengeAmount;
        collateralRequirement.staking = staking;

        emit CollateralRequirementChanged(_disputable, id);
    }

     
    function _payAppFees(Setting storage _setting, DisputableAragonApp _disputable, address _submitter, uint256 _actionId) internal {
         
        IAragonAppFeesCashier aragonAppFeesCashier = _setting.aragonAppFeesCashier;
        if (aragonAppFeesCashier == IAragonAppFeesCashier(0)) {
            return;
        }

        bytes32 appId = _disputable.appId();
        (ERC20 token, uint256 amount) = aragonAppFeesCashier.getAppFee(appId);

        if (amount == 0) {
            return;
        }

         
        IStaking staking = stakingFactory.getOrCreateInstance(token);
        _lockBalance(staking, _submitter, amount);
        _slashBalance(staking, _submitter, address(this), amount);
        _approveFor(token, address(aragonAppFeesCashier), amount);

         
        aragonAppFeesCashier.payAppFees(appId, abi.encodePacked(_actionId));
    }

     
    function _unsafeCloseAction(uint256 _actionId, Action storage _action) internal {
        _action.closed = true;
        emit ActionClosed(_actionId);
    }

     
    function _createChallenge(
        uint256 _actionId,
        Action storage _action,
        address _challenger,
        CollateralRequirement storage _requirement,
        uint256 _settlementOffer,
        bool _finishedSubmittingEvidence,
        bytes _context
    )
        internal
        returns (uint256)
    {
         
        uint256 challengeId = nextChallengeId++;
        Challenge storage challenge = challenges[challengeId];
        challenge.actionId = _actionId;
        challenge.challenger = _challenger;
        challenge.endDate = getTimestamp64().add(_requirement.challengeDuration);
        challenge.context = _context;
        challenge.settlementOffer = _settlementOffer;
        challenge.challengerFinishedEvidence = _finishedSubmittingEvidence;

         
        _depositFrom(_requirement.token, _challenger, _requirement.challengeAmount);

         
        IArbitrator arbitrator = _getArbitratorFor(_action);
        (, ERC20 feeToken, uint256 feeAmount) = arbitrator.getDisputeFees();
        challenge.challengerArbitratorFees.token = feeToken;
        challenge.challengerArbitratorFees.amount = feeAmount;
        _depositFrom(feeToken, _challenger, feeAmount);

        return challengeId;
    }

     
    function _createDispute(Action storage _action, Challenge storage _challenge, IArbitrator _arbitrator, bytes memory _metadata)
        internal
        returns (uint256)
    {
         
        (address disputeFeeRecipient, ERC20 feeToken, uint256 feeAmount) = _arbitrator.getDisputeFees();
        _challenge.submitterArbitratorFees.token = feeToken;
        _challenge.submitterArbitratorFees.amount = feeAmount;

        address submitter = _action.submitter;
        _depositFrom(feeToken, submitter, feeAmount);

         
        _approveFor(feeToken, disputeFeeRecipient, feeAmount);
        uint256 disputeId = _arbitrator.createDispute(DISPUTES_POSSIBLE_OUTCOMES, _metadata);

        return disputeId;
    }

     
    function _submitEvidence(IArbitrator _arbitrator, uint256 _disputeId, address _submitter, bytes _evidence, bool _finished) internal {
        if (_evidence.length > 0) {
            emit EvidenceSubmitted(_arbitrator, _disputeId, _submitter, _evidence, _finished);
        }
    }

     
    function _rejectAction(uint256 _actionId, Action storage _action, uint256 _challengeId, Challenge storage _challenge) internal {
        _challenge.state = ChallengeState.Accepted;

        address challenger = _challenge.challenger;
        (DisputableAragonApp disputable, CollateralRequirement storage requirement) = _getDisputableInfoFor(_action);

         
        _slashBalance(requirement.staking, _action.submitter, challenger, requirement.actionAmount);
        _transferTo(requirement.token, challenger, requirement.challengeAmount);
        _transferTo(_challenge.challengerArbitratorFees.token, challenger, _challenge.challengerArbitratorFees.amount);
        disputable.onDisputableActionRejected(_action.disputableActionId);
        emit ActionRejected(_actionId, _challengeId);
        _unsafeCloseAction(_actionId, _action);
    }

     
    function _acceptAction(uint256 _actionId, Action storage _action, uint256 _challengeId, Challenge storage _challenge) internal {
        _challenge.state = ChallengeState.Rejected;

        address submitter = _action.submitter;
        (DisputableAragonApp disputable, CollateralRequirement storage requirement) = _getDisputableInfoFor(_action);

         
        _transferTo(requirement.token, submitter, requirement.challengeAmount);
        _transferTo(_challenge.challengerArbitratorFees.token, submitter, _challenge.challengerArbitratorFees.amount);
        disputable.onDisputableActionAllowed(_action.disputableActionId);
        emit ActionAccepted(_actionId, _challengeId);

         
    }

     
    function _voidAction(uint256 _actionId, Action storage _action, uint256 _challengeId, Challenge storage _challenge) internal {
        _challenge.state = ChallengeState.Voided;

        (DisputableAragonApp disputable, CollateralRequirement storage requirement) = _getDisputableInfoFor(_action);
        address challenger = _challenge.challenger;

         
        _transferTo(requirement.token, challenger, requirement.challengeAmount);
        ERC20 challengerArbitratorFeesToken = _challenge.challengerArbitratorFees.token;
        uint256 challengerArbitratorFeesAmount = _challenge.challengerArbitratorFees.amount;
        uint256 submitterPayBack = challengerArbitratorFeesAmount / 2;
         
        uint256 challengerPayBack = challengerArbitratorFeesAmount - submitterPayBack;
        _transferTo(challengerArbitratorFeesToken, _action.submitter, submitterPayBack);
        _transferTo(challengerArbitratorFeesToken, challenger, challengerPayBack);
        disputable.onDisputableActionVoided(_action.disputableActionId);
        emit ActionVoided(_actionId, _challengeId);

         
    }

     
    function _lockBalance(IStaking _staking, address _user, uint256 _amount) internal {
        if (_amount == 0) {
            return;
        }

        _staking.lock(_user, address(this), _amount);
    }

     
    function _unlockBalance(IStaking _staking, address _user, uint256 _amount) internal {
        if (_amount == 0) {
            return;
        }

        _staking.unlock(_user, address(this), _amount);
    }

     
    function _slashBalance(IStaking _staking, address _user, address _recipient, uint256 _amount) internal {
        if (_amount == 0) {
            return;
        }

        _staking.slashAndUnstake(_user, _recipient, _amount);
    }

     
    function _transferTo(ERC20 _token, address _to, uint256 _amount) internal {
        if (_amount > 0) {
            require(_token.safeTransfer(_to, _amount), ERROR_TOKEN_TRANSFER_FAILED);
        }
    }

     
    function _depositFrom(ERC20 _token, address _from, uint256 _amount) internal {
        if (_amount > 0) {
            require(_token.safeTransferFrom(_from, address(this), _amount), ERROR_TOKEN_DEPOSIT_FAILED);
        }
    }

     
    function _approveFor(ERC20 _token, address _to, uint256 _amount) internal {
        if (_amount > 0) {
             
             
             
            require(_token.safeApprove(_to, 0), ERROR_TOKEN_APPROVAL_FAILED);
            require(_token.safeApprove(_to, _amount), ERROR_TOKEN_APPROVAL_FAILED);
        }
    }

     
    function _getSetting(uint256 _settingId) internal view returns (Setting storage) {
        require(_settingId > 0 && _settingId < nextSettingId, ERROR_SETTING_DOES_NOT_EXIST);
        return settings[_settingId];
    }

     
    function _getCurrentSettingId() internal view returns (uint256) {
         
        return nextSettingId == 0 ? 0 : nextSettingId - 1;
    }

     
    function _getArbitratorFor(Action storage _action) internal view returns (IArbitrator) {
        Setting storage setting = _getSetting(_action.settingId);
        return setting.arbitrator;
    }

     
    function _getArbitratorFeesCashier(IArbitrator _arbitrator) internal view returns (IAragonAppFeesCashier) {
        (address cashier,,) = _arbitrator.getSubscriptionFees(address(this));
        return IAragonAppFeesCashier(cashier);
    }

     
    function _ensureActiveDisputable(DisputableInfo storage _disputableInfo) internal view {
        require(_disputableInfo.activated, ERROR_DISPUTABLE_NOT_ACTIVE);
    }

     
    function _ensureInactiveDisputable(DisputableInfo storage _disputableInfo) internal view {
        require(!_disputableInfo.activated, ERROR_DISPUTABLE_ALREADY_ACTIVE);
    }

     
    function _getDisputableInfoFor(Action storage _action)
        internal
        view
        returns (DisputableAragonApp disputable, CollateralRequirement storage requirement)
    {
        disputable = _action.disputable;
        DisputableInfo storage disputableInfo = disputableInfos[address(disputable)];
        requirement = _getCollateralRequirement(disputableInfo, _action.collateralRequirementId);
    }

     
    function _getCollateralRequirement(DisputableInfo storage _disputableInfo, uint256 _collateralRequirementId)
        internal
        view
        returns (CollateralRequirement storage)
    {
        bool exists = _collateralRequirementId > 0 && _collateralRequirementId < _disputableInfo.nextCollateralRequirementsId;
        require(exists, ERROR_COLLATERAL_REQUIREMENT_DOES_NOT_EXIST);
        return _disputableInfo.collateralRequirements[_collateralRequirementId];
    }

     
    function _getSigner(address _signer) internal view returns (uint256 lastSettingIdSigned, bool mustSign) {
        lastSettingIdSigned = lastSettingSignedBy[_signer];
        mustSign = lastSettingIdSigned < _getCurrentSettingId();
    }

     
    function _getAction(uint256 _actionId) internal view returns (Action storage) {
        require(_actionId > 0 && _actionId < nextActionId, ERROR_ACTION_DOES_NOT_EXIST);
        return actions[_actionId];
    }

     
    function _getChallenge(uint256 _challengeId) internal view returns (Challenge storage) {
        require(_existChallenge(_challengeId), ERROR_CHALLENGE_DOES_NOT_EXIST);
        return challenges[_challengeId];
    }

     
    function _getChallengedAction(uint256 _actionId)
        internal
        view
        returns (Action storage action, Challenge storage challenge, uint256 challengeId)
    {
        action = _getAction(_actionId);
        challengeId = action.lastChallengeId;
        challenge = _getChallenge(challengeId);
    }

     
    function _getDisputedAction(uint256 _disputeId)
        internal
        view
        returns (uint256 actionId, Action storage action, uint256 challengeId, Challenge storage challenge)
    {
        challengeId = challengeByDispute[_disputeId];
        challenge = _getChallenge(challengeId);
        actionId = challenge.actionId;
        action = _getAction(actionId);
    }

     
    function _existChallenge(uint256 _challengeId) internal view returns (bool) {
        return _challengeId > 0 && _challengeId < nextChallengeId;
    }

     
    function _canClose(Action storage _action) internal view returns (bool) {
        if (!_canProceed(_action)) {
            return false;
        }

        DisputableAragonApp disputable = _action.disputable;
         
        return DisputableAragonApp(msg.sender) == disputable || disputable.canClose(_action.disputableActionId);
    }

     
    function _canChallenge(Action storage _action) internal view returns (bool) {
        return _canProceed(_action) && _action.disputable.canChallenge(_action.disputableActionId);
    }

     
    function _canProceed(Action storage _action) internal view returns (bool) {
         
        if (_action.closed) {
            return false;
        }

        uint256 challengeId = _action.lastChallengeId;

         
        if (!_existChallenge(challengeId)) {
            return true;
        }

         
        Challenge storage challenge = challenges[challengeId];
        ChallengeState state = challenge.state;
        return state == ChallengeState.Rejected || state == ChallengeState.Voided;
    }

     
    function _canSettle(Challenge storage _challenge) internal view returns (bool) {
        return _isWaitingChallengeAnswer(_challenge);
    }

     
    function _canClaimSettlement(Challenge storage _challenge) internal view returns (bool) {
        return _isWaitingChallengeAnswer(_challenge) && getTimestamp() >= uint256(_challenge.endDate);
    }

     
    function _canDispute(Challenge storage _challenge) internal view returns (bool) {
        return _isWaitingChallengeAnswer(_challenge) && uint256(_challenge.endDate) > getTimestamp();
    }

     
    function _isWaitingChallengeAnswer(Challenge storage _challenge) internal view returns (bool) {
        return _challenge.state == ChallengeState.Waiting;
    }

     
    function _isDisputed(Challenge storage _challenge) internal view returns (bool) {
        return _challenge.state == ChallengeState.Disputed;
    }

     
    function _canPerformChallenge(DisputableAragonApp _disputable, address _challenger) internal view returns (bool) {
        IKernel currentKernel = kernel();
        if (currentKernel == IKernel(0)) {
            return false;
        }

         
         
        bytes memory params = ConversionHelpers.dangerouslyCastUintArrayToBytes(arr(_challenger));
        return currentKernel.hasPermission(_challenger, address(_disputable), CHALLENGE_ROLE, params);
    }
}