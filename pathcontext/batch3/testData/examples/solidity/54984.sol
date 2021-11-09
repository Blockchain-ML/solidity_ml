pragma solidity ^0.4.24;

 

 
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
    require(msg.sender == owner);
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
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

 

 
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

 

contract Authorizable is Ownable {
    address public trustee;

    constructor() public {
        trustee = 0x0;
    }

    modifier onlyAuthorized() {
        require(msg.sender == trustee || msg.sender == owner);
        _;
    }

    function setTrustee(address _newTrustee) public onlyOwner {
        trustee = _newTrustee;
    }
}


contract BitmarkHotWallet is Authorizable, Pausable {
    bytes4 internal constant Interface_Transfer = 0xa9059cbb;
     
    bytes4 internal constant Interface_TakeOwnership = 0xb2e6ceeb;
     
    bytes4 internal constant Interface_TransferFrom = 0x23b872dd;
     
    bytes4 internal constant Interface_ERC721SafeTransferFrom = 0x42842e0e;
     

     
    mapping(address => mapping(uint256 => address)) internal ownedAssets;

    event ERC20TokenWithdraw(address indexed tokenContract, uint256 indexed amount, address indexed to);
    event ERC721TokenDeposit(address indexed tokenContract, uint256 indexed tokenId, address indexed to);
    event ERC721TokenWithdraw(address indexed tokenContract, uint256 indexed tokenId, address indexed to);

     
    function bytesToAddress(bytes data) internal pure returns (address result) {
        require(data.length == 20, "incorrect length of address");
        assembly {
            result := div(mload(add(data, 0x20)), 0x1000000000000000000000000)
        }
    }

     
    function withdrawERC20(address tokenContract, uint256 amount, address to) public onlyAuthorized {
        require(tokenContract.call(Interface_Transfer, to, amount));
        emit ERC20TokenWithdraw(tokenContract, amount, to);
    }

     
    function depositERC721(address tokenContract, uint256 tokenId, address to) public {
        require(tokenContract.call(Interface_TransferFrom, msg.sender, address(this), tokenId) ||
            tokenContract.call(Interface_TakeOwnership, tokenId));
        ownedAssets[tokenContract][tokenId] = to;
        emit ERC721TokenDeposit(tokenContract, tokenId, to);
    }

     
     
    function withdrawERC721(address tokenContract, uint256 tokenId, address from, address to) public onlyAuthorized {
        require(from != 0x0 && ownedAssets[tokenContract][tokenId] == from);
        ownedAssets[tokenContract][tokenId] = 0x0;
        require(tokenContract.call(Interface_Transfer, to, tokenId));
        emit ERC721TokenWithdraw(tokenContract, tokenId, to);
    }

     
     
    function safeWithdrawERC721(address tokenContract, uint256 tokenId, address from, address to) public onlyAuthorized {
        require(from != 0x0 && ownedAssets[tokenContract][tokenId] == from);
        ownedAssets[tokenContract][tokenId] = 0x0;
        require(tokenContract.call(Interface_ERC721SafeTransferFrom, address(this), to, tokenId));
        emit ERC721TokenWithdraw(tokenContract, tokenId, to);
    }

     
    function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes data
    )
        public whenNotPaused
        returns(bytes4)
    {
         
        address to = bytesToAddress(data);
        require(to != address(0));
        ownedAssets[msg.sender][tokenId] = to;
        emit ERC721TokenDeposit(msg.sender, tokenId, to);
        return this.onERC721Received.selector;
    }
}