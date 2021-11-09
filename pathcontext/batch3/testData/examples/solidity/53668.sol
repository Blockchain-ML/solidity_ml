contract Ownable {
  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender == owner)
      _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) owner = newOwner;
  }
}

contract Killable is Ownable {

  function kill() public onlyOwner {
    selfdestruct(owner);
  }
}

contract Accessible is Killable {

 	 
    mapping(address => bool) public allowedAccounts;
    uint256 public numberOfAccounts;

    event AccessGranted(address newAccount);
    event AccessRemoved(address removedAccount);

    modifier onlyOwnerOrAllowed() {
        require(msg.sender == owner || allowedAccounts[msg.sender]);
        _;
    }

    modifier onlyAllowedAccount() {
        require(allowedAccounts[msg.sender]);
        _;
    }

     
    function grantAccess(address newAccount) public onlyOwnerOrAllowed {
    	 
        require(newAccount != address(0) && !allowedAccounts[newAccount]);
        allowedAccounts[newAccount] = true;
        numberOfAccounts += 1;

        require(numberOfAccounts != 0);
         
        emit AccessGranted(newAccount);
    }

    function removeAccess(address removeAccount) public onlyOwnerOrAllowed {
    	 
        require(allowedAccounts[removeAccount]);
        require (numberOfAccounts >= 1);
        allowedAccounts[removeAccount] = false;
        numberOfAccounts -= 1;
         
        emit AccessRemoved(removeAccount);
    }
}

interface Token {

	event Transfer(
		address indexed _from,
		address indexed _to,
		uint256 _value,
		uint256 _balance);

    event Approval(
    	address indexed _owner,
    	address indexed _spender,
    	uint256 _value);

     

     
     
     
     
     

	 
	 

	 
	 
	 

	 
	 
	 
	 
	 
	 
	function transfer(address _to, uint256 _value) external constant returns (bool success);

	 
	 
     
     
	 
	 
	function transferFrom(address _from, address _to, uint256 _value) external constant returns (bool success);

	 
	 
     
     
     
    function approve(address _spender, uint256 _value) external constant  returns (bool success);

     
     
     
     
}

contract ERC20Token is Token, Accessible {
	 
	uint256 public totalSupply;

	 
	mapping (address => uint256) public balanceOf;
	
	 
	mapping (address => mapping (address => uint256)) public allowance;

	 
	 
	 

	 
 	 
 	 

 	 
 	 
	function transfer(address _to, uint256 _value) public returns (bool success){
		 
		require (balanceOf[msg.sender] >= _value);
		 
		require (_value > 0);
		 
		require (balanceOf[_to] + _value > balanceOf[_to]);
		
		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;

		require (balanceOf[_to] != 0);

		emit Transfer(msg.sender, _to, _value, balanceOf[msg.sender]);

		return true;
	}

 	 
 	 
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		 
		require (balanceOf[_from] >= _value);
		 
		require (allowance[_from][msg.sender] >= _value);
		 
		require (_value > 0);
		
		balanceOf[_from] -= _value;
		balanceOf[_to] += _value;

		require (balanceOf[_to] != 0);
		allowance[_from][msg.sender] -= _value;

		emit Transfer(_from, _to, _value, balanceOf[msg.sender]);

		return true;
	}

	function approve(address _spender, uint256 _value) public returns (bool success) {
		allowance[msg.sender][_spender] += _value;

		emit Approval(msg.sender, _spender, _value);

		return true;
	}

     
     
     
}

contract EduScienceToken is ERC20Token {

    string public name = "EduScience";
    string public symbol = "ESc";
    string public version = "EduScience Token v1.0"; 

	 
	constructor (uint256 _initialSupply) public {
		 
		 
		totalSupply = _initialSupply;

		 
		 
		balanceOf[msg.sender] = _initialSupply;
	}

	 
	 
	function transfer(address _from, address _to, uint256 _value) public onlyOwnerOrAllowed returns (bool success){
		 
		require (balanceOf[_from] >= _value);
		 
		require (_value > 0);
		 
		require (balanceOf[_to] + _value > balanceOf[_to]);
		
		balanceOf[_from] -= _value;
		balanceOf[_to] += _value;

		require (balanceOf[_to] != 0);

		emit Transfer(_from, _to, _value, balanceOf[_from]);

		return true;
	}
}

contract EduScience is Accessible {

   

  struct User {
    bytes32 name;
  }

   
  struct Data {
     
    string ipfsHash;
     
    address publisher;
     
    bytes32 title;
     
    uint256 popularity;
     
    uint256 time;
  }

  EduScienceToken private tokenContract;

  mapping (address => User) public users;
  
   
   
  mapping (address => mapping (uint256 => Data)) private addressData;
  mapping (address => mapping (uint256 => Data)) private userPurchasedData;
   
  mapping (address => uint256) public addressCount;
  mapping (address => uint256) public userPurchasedCount;
   
  
   
  mapping (bytes32 => Data) private titleData;
   
  bytes32[] private titles;
   
  uint256 public titlesCount;

  uint256 public accessFee = 6;
  uint256 public popularityFee = 2;

   
  event Store(
     address publisher,
     string ipfsHash);

  modifier onlyExistingUser {
     
    require(!(users[msg.sender].name == 0x0));
    _;
  }

  modifier onlyValidName(bytes32 name) {
     
    require(!(name == 0x0));
    _;
  }

  constructor(EduScienceToken _tokenContract) public {
    tokenContract = _tokenContract;
  }

  function publish(string _ipfsHash, bytes32 _title) public onlyValidName(_title) onlyExistingUser {
    require (bytes(_ipfsHash).length < 50);
     
    require (titleData[_title].time == 0);

     
    uint256 n = ++addressCount[msg.sender];
    titlesCount++;

    require (n != 0);
    require (titlesCount != 0);

    addressData[msg.sender][n].ipfsHash = _ipfsHash;
    addressData[msg.sender][n].publisher = msg.sender;
    addressData[msg.sender][n].title = _title;
    addressData[msg.sender][n].popularity = 0;
    addressData[msg.sender][n].time = getTimestamp();

    titleData[_title].ipfsHash = _ipfsHash;
    titleData[_title].publisher = msg.sender;
    titleData[_title].title = _title;
    titleData[_title].popularity = 0;
    titleData[_title].time = getTimestamp();
    titles.push(_title);

    emit Store(msg.sender, _ipfsHash);
  }

   
  function getTitle(uint256 _index) constant public onlyExistingUser returns (bytes32) {
     
    require (titles[_index] != 0x0);
    return titles[_index];
  }

  function getPublisher(bytes32 _title) constant public onlyExistingUser returns (address) {
     
    require (titleData[_title].time != 0);
    return titleData[_title].publisher;
  }

  function getPopularity(bytes32 _title) constant public onlyExistingUser returns (uint256) {
     
    require (titleData[_title].time != 0);
    return titleData[_title].popularity;
  }

  function getPublishTime(bytes32 _title) constant public onlyExistingUser returns (uint256) {
     
    require (titleData[_title].time != 0);
    return titleData[_title].time;
  }

  function purchaseIpfsAfterTitle(bytes32 _title) public onlyExistingUser {
     
    require (titleData[_title].time != 0);
     
    require (titleData[_title].publisher != msg.sender);

     
    for (uint256 i = 0; i < userPurchasedCount[msg.sender]; i++) {
       
      require (userPurchasedData[msg.sender][i].title != _title);
    }

     
    require (tokenContract.transfer(msg.sender, titleData[_title].publisher, accessFee));
    uint256 n = ++userPurchasedCount[msg.sender];
    userPurchasedData[msg.sender][n].ipfsHash = titleData[_title].ipfsHash;
    userPurchasedData[msg.sender][n].publisher = titleData[_title].publisher;
    userPurchasedData[msg.sender][n].title = titleData[_title].title;
    userPurchasedData[msg.sender][n].popularity = titleData[_title].popularity;
    userPurchasedData[msg.sender][n].time = titleData[_title].time;
  }

  function getIpfsAfterTitle(bytes32 _title) public constant onlyExistingUser returns (string) {
     
    require (titleData[_title].time != 0);
     
    for (uint256 i = 1; i <= userPurchasedCount[msg.sender]; i++) {
      if (userPurchasedData[msg.sender][i].title == _title) {
        return userPurchasedData[msg.sender][i].ipfsHash;
      }
    }
     
    for (uint256 j = 1; j <= addressCount[msg.sender]; j++) {
      if (addressData[msg.sender][j].title == _title) {
        return addressData[msg.sender][j].ipfsHash;
      }
    }
     
    return "NA";
  }

  function votePopularity(bytes32 _title) public onlyExistingUser {
     
    require (titleData[_title].time != 0);
     
    require (titleData[_title].publisher != msg.sender);
     
    require (tokenContract.transfer(msg.sender, titleData[_title].publisher, popularityFee));

    ++titleData[_title].popularity;
  }

  function getTitleAddress(uint256 _index) constant public onlyExistingUser returns (bytes32) {
    require (addressData[msg.sender][_index].time != 0);
    return addressData[msg.sender][_index].title;
  }

  function getPurchaseAddress(uint256 _index) constant public onlyExistingUser returns (bytes32) {
    require (userPurchasedData[msg.sender][_index].time != 0);
    return userPurchasedData[msg.sender][_index].title;
  }

  function getTimestamp() internal view returns (uint256) {
    return now;
  }

  function getBlockNumber() internal view returns (uint256) {
    return block.number;
  }

  function login() public constant onlyExistingUser returns (bytes32) {
    return (users[msg.sender].name);
  }

   
   
  function user(bytes32 name) public constant onlyValidName(name) returns (bytes32) {
     if (users[msg.sender].name == 0x0) {
        return "null";
     }
     return users[msg.sender].name;
  }

  function signup(bytes32 name) public payable onlyValidName(name) returns (bytes32) {
     
     
     
     
    if (users[msg.sender].name == 0x0) {
        users[msg.sender].name = name;
        return (users[msg.sender].name);
    }

    return (users[msg.sender].name);
  }

  function update(bytes32 name) public payable onlyValidName(name) onlyExistingUser returns (bytes32) {
     
    if (users[msg.sender].name != 0x0) {
        users[msg.sender].name = name;
        return (users[msg.sender].name);
    }
  }

   

   

   
   
   

   
   
   
   

   
   
   

   
}