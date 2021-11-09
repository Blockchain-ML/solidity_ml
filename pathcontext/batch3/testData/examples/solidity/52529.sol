pragma solidity ^0.4.24;

 
contract Proxy {
     
    function implementation() public view returns (address);

     
    function () payable public {
        address _impl = implementation();
        require(_impl != address(0), "address invalid");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}

 
contract UpgradeabilityProxy is Proxy {
     
    event Upgraded(address indexed implementation);

     
    bytes32 private constant implementationPosition = keccak256("you are the lucky man.proxy");

     
    constructor() public {}

     
    function implementation() public view returns (address impl) {
        bytes32 position = implementationPosition;
        assembly {
            impl := sload(position)
        }
    }
    
     
    function setImplementation(address newImplementation) internal {
        bytes32 position = implementationPosition;
        assembly {
            sstore(position, newImplementation)
        }
    }

     
    function _upgradeTo(address newImplementation) internal {
        address currentImplementation = implementation();
        require(currentImplementation != newImplementation, "new address is the same");
        setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }
}

 
contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {
     
    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

     
    bytes32 private constant proxyOwnerPosition = keccak256("you are the lucky man.proxy.owner");

     
    constructor() public {
        setUpgradeabilityOwner(msg.sender);
    }

     
    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner(), "owner only");
        _;
    }

     
    function proxyOwner() public view returns (address owner) {
        bytes32 position = proxyOwnerPosition;
        assembly {
            owner := sload(position)
        }
    }

     
    function setUpgradeabilityOwner(address newProxyOwner) internal {
        bytes32 position = proxyOwnerPosition;
        assembly {
            sstore(position, newProxyOwner)
        }
    }

     
    function transferProxyOwnership(address newOwner) public onlyProxyOwner {
        require(newOwner != address(0), "address is invalid");
        emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
        setUpgradeabilityOwner(newOwner);
    }

     
    function upgradeTo(address implementation) public onlyProxyOwner {
        _upgradeTo(implementation);
    }

     
    function upgradeToAndCall(address implementation, bytes data) public payable onlyProxyOwner {
        upgradeTo(implementation);
        require(address(this).call.value(msg.value)(data), "data is invalid");
    }
}

contract BasicToken {
  uint256 internal _totalSupply;
  mapping (address => uint256) internal _balances;

  function totalSupply() public returns (uint256) {
    _totalSupply += 100;
    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }
}

contract StandardToken is BasicToken {
  mapping (address => mapping (address => uint256)) internal _allowances;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
  }
}