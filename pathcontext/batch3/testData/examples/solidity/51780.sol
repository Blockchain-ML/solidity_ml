 

pragma solidity ^0.5.0;

 
contract ZOSLibOwnable {
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

 
library ZOSLibAddress {
     
    function isContract(address account) internal view returns (bool) {
        uint256 size;
         
         
         
         
         
         
         
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

 
contract Proxy {
     
    function () payable external {
        _fallback();
    }

     
    function _implementation() internal view returns (address);

     
    function _delegate(address implementation) internal {
        assembly {
         
         
         
            calldatacopy(0, 0, calldatasize)

         
         
            let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

         
            returndatacopy(0, 0, returndatasize)

            switch result
             
            case 0 { revert(0, returndatasize) }
            default { return(0, returndatasize) }
        }
    }

     
    function _willFallback() internal {
    }

     
    function _fallback() internal {
        _willFallback();
        _delegate(_implementation());
    }
}

 
contract BaseUpgradeabilityProxy is Proxy {
     
    event Upgraded(address indexed implementation);

     
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;

     
    function _implementation() internal view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

     
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

     
    function _setImplementation(address newImplementation) internal {
        require(ZOSLibAddress.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}

 
contract UpgradeabilityProxy is BaseUpgradeabilityProxy {
     
    constructor(address _logic, bytes memory _data) public payable {
        assert(IMPLEMENTATION_SLOT == keccak256("org.zeppelinos.proxy.implementation"));
        _setImplementation(_logic);
        if(_data.length > 0) {
            (bool success,) = _logic.delegatecall(_data);
            require(success);
        }
    }
}

 
contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {
     
    event AdminChanged(address previousAdmin, address newAdmin);

     
    bytes32 internal constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

     
    modifier ifAdmin() {
        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

     
    function admin() external ifAdmin returns (address) {
        return _admin();
    }

     
    function implementation() external ifAdmin returns (address) {
        return _implementation();
    }

     
    function changeAdmin(address newAdmin) external ifAdmin {
        require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

     
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeTo(newImplementation);
    }

     
    function upgradeToAndCall(address newImplementation, bytes calldata data) payable external ifAdmin {
        _upgradeTo(newImplementation);
        (bool success,) = newImplementation.delegatecall(data);
        require(success);
    }

     
    function _admin() internal view returns (address adm) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

     
    function _setAdmin(address newAdmin) internal {
        bytes32 slot = ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

     
    function _willFallback() internal {
        require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
        super._willFallback();
    }
}

 
contract AdminUpgradeabilityProxy is BaseAdminUpgradeabilityProxy, UpgradeabilityProxy {
     
    constructor(address _logic, address _admin, bytes memory _data) UpgradeabilityProxy(_logic, _data) public payable {
        assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));
        _setAdmin(_admin);
    }
}

 
contract ProxyAdmin is ZOSLibOwnable {

     
    function getProxyImplementation(AdminUpgradeabilityProxy proxy) public view returns (address) {
         
         
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

     
    function getProxyAdmin(AdminUpgradeabilityProxy proxy) public view returns (address) {
         
         
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

     
    function changeProxyAdmin(AdminUpgradeabilityProxy proxy, address newAdmin) public onlyOwner {
        proxy.changeAdmin(newAdmin);
    }

     
    function upgrade(AdminUpgradeabilityProxy proxy, address implementation) public onlyOwner {
        proxy.upgradeTo(implementation);
    }

     
    function upgradeAndCall(AdminUpgradeabilityProxy proxy, address implementation, bytes memory data) payable public onlyOwner {
        proxy.upgradeToAndCall.value(msg.value)(implementation, data);
    }
}