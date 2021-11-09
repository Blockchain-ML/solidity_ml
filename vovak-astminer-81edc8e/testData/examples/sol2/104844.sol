 
pragma solidity =0.6.11;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
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

 
interface IMerkleDistributor {
     
    function token() external view returns (address);
     
    function merkleRoot() external view returns (bytes32);
     
    function funder() external view returns (address);
     
    function fundingAmount() external view returns (uint256);
     
    function isFunded() external view returns (bool);
     
    function isClaimed(uint256 index) external view returns (bool);
     
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external;
     
    function fund() external;

     
    event Claimed(uint256 index, address account, uint256 amount);

     
    event Funded(address account, uint256 amount);
}

contract MerkleDistributor is IMerkleDistributor {
    address public immutable override token;
    bytes32 public immutable override merkleRoot;
    address public immutable override funder;
    uint256 public immutable override fundingAmount;
    bool public override isFunded;

     
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(address token_, bytes32 merkleRoot_, address funder_, uint256 fundingAmount_) public {
        token = token_;
        merkleRoot = merkleRoot_;
        funder = funder_;
        fundingAmount = fundingAmount_;
        isFunded = false;
    }

    function isClaimed(uint256 index) public view override returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external override {
        require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

         
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

         
        _setClaimed(index);
        require(IERC20(token).transfer(account, amount), 'MerkleDistributor: Transfer failed.');

        emit Claimed(index, account, amount);
    }

    function fund() external override {
        require(!isFunded, 'MerkleDistributor: Distributor has already been funded.');

        isFunded = true;

        require(IERC20(token).transferFrom(funder, address(this), fundingAmount), 'MerkleDistributor: Funding failed.');

        emit Funded(funder, fundingAmount);
    }
}