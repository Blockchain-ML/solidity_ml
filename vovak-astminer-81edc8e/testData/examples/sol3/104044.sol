 

 

pragma solidity ^0.5.11;

 
library MerkleProof {
     
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                 
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                 
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

         
        return computedHash == root;
    }
}

 

pragma solidity ^0.5.11;


contract IManager {
    event SetController(address controller);
    event ParameterUpdate(string param);

    function setController(address _controller) external;
}

 

pragma solidity ^0.5.11;


 
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
    constructor() public {
        owner = msg.sender;
    }

   
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

 

pragma solidity ^0.5.11;



 
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


     
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

     
    modifier whenPaused() {
        require(paused);
        _;
    }

     
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

     
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

 

pragma solidity ^0.5.11;



contract IController is Pausable {
    event SetContractInfo(bytes32 id, address contractAddress, bytes20 gitCommitHash);

    function setContractInfo(bytes32 _id, address _contractAddress, bytes20 _gitCommitHash) external;
    function updateController(bytes32 _id, address _controller) external;
    function getContract(bytes32 _id) public view returns (address);
}

 

pragma solidity ^0.5.11;




contract Manager is IManager {
     
    IController public controller;

     
    modifier onlyController() {
        require(msg.sender == address(controller), "caller must be Controller");
        _;
    }

     
    modifier onlyControllerOwner() {
        require(msg.sender == controller.owner(), "caller must be Controller owner");
        _;
    }

     
    modifier whenSystemNotPaused() {
        require(!controller.paused(), "system is paused");
        _;
    }

     
    modifier whenSystemPaused() {
        require(controller.paused(), "system is not paused");
        _;
    }

    constructor(address _controller) public {
        controller = IController(_controller);
    }

     
    function setController(address _controller) external onlyController {
        controller = IController(_controller);

        emit SetController(_controller);
    }
}

 

pragma solidity ^0.5.11;




contract MerkleSnapshot is Manager {
    mapping (bytes32 => bytes32) public snapshot;

    constructor(address _controller) public Manager(_controller) {}

    function setSnapshot(bytes32 _id, bytes32 _root) external onlyControllerOwner {
        snapshot[_id] = _root;
    }

    function verify(bytes32 _id, bytes32[] calldata _proof, bytes32 _leaf) external view returns (bool) {
        return MerkleProof.verify(_proof, snapshot[_id], _leaf);
    }
}