pragma solidity 0.4.24;

interface IContractAddressLocator {
    function get(bytes32 interfaceName) external view returns (address);
}

 
contract ContractAddressLocator is IContractAddressLocator {
    event Register(bytes32 indexed interfaceName, address indexed contractAddress);

    mapping(bytes32 => address) private _registry;

    constructor(bytes32[] interfaceNames, address[] contractAddresses) public {
        uint256 length = interfaceNames.length;
        require(length == contractAddresses.length);
        for (uint256 i = 0; i < length; i++) {
            _registry[interfaceNames[i]] = contractAddresses[i];
            emit Register(interfaceNames[i], contractAddresses[i]);
        }
    }

    function get(bytes32 interfaceName) external view returns (address) {
        return _registry[interfaceName];
    }
}