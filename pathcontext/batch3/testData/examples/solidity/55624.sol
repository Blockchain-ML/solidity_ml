pragma solidity ^0.4.25;

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

  function transferOwnershipOfContract(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

 

contract EthPub is Ownable{
    mapping(bytes32 => mapping(address => bool)) public ownerships;  
    mapping(bytes32 => Content) public contents;  

     
    mapping(address => bytes32[]) private authorContents;
    mapping(address => mapping(bytes32 => uint256)) private authorContentIndex;  

     
    mapping(address => bytes32[]) private userContents;
    mapping(address => mapping(bytes32 => uint256)) private userContentIndex;  

   struct Content {
       address author;
       uint256 totalSupply;
       uint256 price;
       string contentPath;
   }

    modifier onlyAuthor(bytes32 _contentHash) {
      require(contents[_contentHash].author == msg.sender);
      _;
    }

    constructor() public {}

     
    function publish (bytes32 _contentHash, string _contentPath, uint256 _price) public {
        require(contents[_contentHash].author == 0);  
        contents[_contentHash].author = msg.sender;
        contents[_contentHash].totalSupply = 0;
        contents[_contentHash].price = _price * 1 ether / 1000;
        contents[_contentHash].contentPath = _contentPath;
        authorContents[msg.sender].push(_contentHash);
    }
    
     
    function purchase(bytes32 _contentHash) public payable {
        require(msg.value >= contents[_contentHash].price);
        require(!ownerships[_contentHash][msg.sender]);  
        ownerships[_contentHash][msg.sender] = true;  
        userContents[msg.sender].push(_contentHash);
        userContentIndex[msg.sender][_contentHash] = userContents[msg.sender].length - 1;
        contents[_contentHash].totalSupply += 1;  
    }    

     
    function issue(address _to, bytes32 _contentHash) public onlyAuthor(_contentHash) {
        require(!ownerships[_contentHash][_to]);  
        ownerships[_contentHash][_to] = true;  
        userContents[_to].push(_contentHash);
        userContentIndex[_to][_contentHash] = userContents[_to].length - 1;
        contents[_contentHash].totalSupply += 1;  
    }

     
    function transfer(address _to, bytes32 _contentHash) public {
        require(ownerships[_contentHash][msg.sender]);
        ownerships[_contentHash][msg.sender] = false;  
        userContents[msg.sender][userContentIndex[msg.sender][_contentHash]] = 0x0;  
        userContentIndex[msg.sender][_contentHash] = 0;  
        
        require(!ownerships[_contentHash][_to]);
        ownerships[_contentHash][_to] = true;  
        userContents[_to].push(_contentHash);  
        userContentIndex[_to][_contentHash] = userContents[_to].length - 1;  
    }
    
     
    function getNumPublications() public view returns (uint256 numContents) {
        return authorContents[msg.sender].length;
    }
    
     
    function getNumContents() public view returns (uint256 numContents) {
        return userContents[msg.sender].length;
    }
    
     
    function authorContentByIndex(uint256 _index) public view returns (bytes32 contentHash) {
        return authorContents[msg.sender][_index];
    }
    
     
    function userContentByIndex(uint256 _index) public view returns (bytes32 contentHash) {
        return userContents[msg.sender][_index];
    }

     
    function transferAuthorship(address _to, bytes32 _contentHash) public onlyAuthor(_contentHash) {
        contents[_contentHash].author = _to;
        authorContents[msg.sender][authorContentIndex[msg.sender][_contentHash]] = 0x0;
        authorContentIndex[msg.sender][_contentHash] = 0;
        authorContents[_to].push(_contentHash);
        authorContentIndex[_to][_contentHash] = authorContents[_to].length - 1;
    }

    function destruct() public onlyOwner {
        selfdestruct(owner);
    }
}