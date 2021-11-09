pragma solidity ^0.6.12;

 

 
 
 
 

 
 
 
 

 
 

 


 
contract Owned {

     
    address public owner;

    event OwnerChanged(address indexed _newOwner);

     
    modifier onlyOwner {
        require(msg.sender == owner, "Must be owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

     
    function changeOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Address must not be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
}

 
interface IArgentProxy {
    function implementation() external view returns (address);
}

 
contract ArgentWalletDetector is Owned {
	
	 
	bytes32[] private codes;
	 
	address[] private implementations;
	 
    mapping (bytes32 => Info) public acceptedCodes;
	 
	mapping (address => Info) public acceptedImplementations;

	struct Info {
        bool exists;
        uint128 index;
    }

	 
	event CodeAdded(bytes32 indexed code);
	 
	event ImplementationAdded(address indexed implementation);

	constructor(bytes32[] memory _codes, address[] memory _implementations) public {
		for(uint i = 0; i < _codes.length; i++) {
			addCode(_codes[i]);
		}
		for(uint j = 0; j < _implementations.length; j++) {
			addImplementation(_implementations[j]);
		}
	}

	 
	function addCode(bytes32 _code) public onlyOwner {
        require(_code != bytes32(0), "AWR: empty _code");
        Info storage code = acceptedCodes[_code];
		if(!code.exists) {
			codes.push(_code);
			code.exists = true;
        	code.index = uint128(codes.length - 1);
			emit CodeAdded(_code);
		}
    }
	
	 
	function addImplementation(address _impl) public onlyOwner {
        require(_impl != address(0), "AWR: empty _impl");
        Info storage impl = acceptedImplementations[_impl];
		if(!impl.exists) {
			implementations.push(_impl);
			impl.exists = true;
        	impl.index = uint128(implementations.length - 1);
			emit ImplementationAdded(_impl);
		}
    }

	 
    function addCodeAndImplementationFromWallet(address _argentWallet) external onlyOwner {
        bytes32 codeHash;   
    	assembly { codeHash := extcodehash(_argentWallet) }
        addCode(codeHash);
        address implementation = IArgentProxy(_argentWallet).implementation(); 
        addImplementation(implementation);
    }

	 
	function getImplementations() public view returns (address[] memory) {
		return implementations;
	}

	 
	function getCodes() public view returns (bytes32[] memory) {
		return codes;
	}

	 
	function isArgentWallet(address _wallet) external view returns (bool) {
		bytes32 codeHash;    
    	assembly { codeHash := extcodehash(_wallet) }
		return acceptedCodes[codeHash].exists && acceptedImplementations[IArgentProxy(_wallet).implementation()].exists;
	}
}