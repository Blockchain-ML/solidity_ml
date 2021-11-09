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