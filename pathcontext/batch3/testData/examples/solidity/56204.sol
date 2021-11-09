pragma solidity 0.4.24;

 
 
 
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint tokens, address token, bytes data) public;
}

 
 
 
 
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


 
 
 
 
contract MyBitToken is ERC20Interface{
    using SafeMath for uint; 

     
     
     
    uint internal supply;
    mapping (address => uint) internal balances;
    mapping (address => mapping (address => uint)) internal allowed;

     
     
     
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  


     
     
     
    constructor(uint _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol) 
    public {
        balances[msg.sender] = _initialAmount;                
        supply = _initialAmount;                         
        name = _tokenName;                                    
        decimals = _decimalUnits;                             
        symbol = _tokenSymbol;                                
        emit Transfer(address(0), msg.sender, _initialAmount);     
    }

     
     
     
     
    function transfer(address _to, uint _amount) 
    public 
    returns (bool success) {
        require(_to != address(0));          
        require(_to != address(this));
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

     
     
     
     
    function transferFrom(address _from, address _to, uint _amount) 
    public 
    returns (bool success) {
        require(_to != address(0)); 
        require(_to != address(this)); 
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

     
     
     
     
    function approve(address _spender, uint _amount) 
    public 
    returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

     
     
     
     
    function approveAndCall(address _spender, uint _amount, bytes _data) 
    public 
    returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _amount, this, _data);
        return true;
    }

     
     
     
     
    function burn(uint _amount) 
    public 
    returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        supply = supply.sub(_amount);
        emit LogBurn(msg.sender, _amount);
        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }

     
     
     
     
    function burnFrom(address _from, uint _amount) 
    public 
    returns (bool success) {
        balances[_from] = balances[_from].sub(_amount);                          
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);              
        supply = supply.sub(_amount);                               
        emit LogBurn(_from, _amount);
        emit Transfer(_from, address(0), _amount);
        return true;
    }

     
     
     
    function totalSupply()
    public 
    view 
    returns (uint tokenSupply) { 
        return supply; 
    }

     
     
     
    function balanceOf(address _tokenHolder) 
    public 
    view 
    returns (uint balance) {
        return balances[_tokenHolder];
    }

     
     
     
    function allowance(address _tokenHolder, address _spender) 
    public 
    view 
    returns (uint remaining) {
        return allowed[_tokenHolder][_spender];
    }

     
     
     
     
    function () 
    public 
    payable {
        revert();
    }

     
     
     
    event LogBurn(address indexed _burner, uint indexed _amountBurned); 
}


 
 
 
 
 
contract Database {

     
     
     
    mapping(bytes32 => uint) public uintStorage;
    mapping(bytes32 => string) public stringStorage;
    mapping(bytes32 => address) public addressStorage;
    mapping(bytes32 => bytes) public bytesStorage;
    mapping(bytes32 => bytes32) public bytes32Storage;
    mapping(bytes32 => bool) public boolStorage;
    mapping(bytes32 => int) public intStorage;



     
     
     
     
    constructor(address _ownerOne, address _ownerTwo, address _ownerThree)
    public {
        boolStorage[keccak256(abi.encodePacked("owner", _ownerOne))] = true;
        boolStorage[keccak256(abi.encodePacked("owner", _ownerTwo))] = true;
        boolStorage[keccak256(abi.encodePacked("owner", _ownerThree))] = true;
        emit LogInitialized(_ownerOne, _ownerTwo, _ownerThree);
    }


     
     
     
     
     
    function setContractManager(address _contractManager)
    external {
        require(_contractManager != address(0));
        require(boolStorage[keccak256(abi.encodePacked("owner", msg.sender))]);
         
        addressStorage[keccak256(abi.encodePacked("contract", "ContractManager"))] = _contractManager;
        boolStorage[keccak256(abi.encodePacked("contract", _contractManager))] = true;
        emit LogContractManager(_contractManager, msg.sender); 
    }

     
     
     

    function setAddress(bytes32 _key, address _value)
    onlyMyBitContract
    external {
        addressStorage[_key] = _value;
    }

    function setUint(bytes32 _key, uint _value)
    onlyMyBitContract
    external {
        uintStorage[_key] = _value;
    }

    function setString(bytes32 _key, string _value)
    onlyMyBitContract
    external {
        stringStorage[_key] = _value;
    }

    function setBytes(bytes32 _key, bytes _value)
    onlyMyBitContract
    external {
        bytesStorage[_key] = _value;
    }

    function setBytes32(bytes32 _key, bytes32 _value)
    onlyMyBitContract
    external {
        bytes32Storage[_key] = _value;
    }

    function setBool(bytes32 _key, bool _value)
    onlyMyBitContract
    external {
        boolStorage[_key] = _value;
    }

    function setInt(bytes32 _key, int _value)
    onlyMyBitContract
    external {
        intStorage[_key] = _value;
    }


     
     
     

    function deleteAddress(bytes32 _key)
    onlyMyBitContract
    external {
        delete addressStorage[_key];
    }

    function deleteUint(bytes32 _key)
    onlyMyBitContract
    external {
        delete uintStorage[_key];
    }

    function deleteString(bytes32 _key)
    onlyMyBitContract
    external {
        delete stringStorage[_key];
    }

    function deleteBytes(bytes32 _key)
    onlyMyBitContract
    external {
        delete bytesStorage[_key];
    }

    function deleteBytes32(bytes32 _key)
    onlyMyBitContract
    external {
        delete bytes32Storage[_key];
    }

    function deleteBool(bytes32 _key)
    onlyMyBitContract
    external {
        delete boolStorage[_key];
    }

    function deleteInt(bytes32 _key)
    onlyMyBitContract
    external {
        delete intStorage[_key];
    }



     
     
     
    modifier onlyMyBitContract() {
        require(boolStorage[keccak256(abi.encodePacked("contract", msg.sender))]);
        _;
    }

     
     
     
    event LogInitialized(address indexed _ownerOne, address indexed _ownerTwo, address indexed _ownerThree);
    event LogContractManager(address indexed _contractManager, address indexed _initiator); 
}


 

   
   
   
library SafeMath {

   
   
   
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

   
   
   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
   
   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
   
   
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

   
   
   
  function getFractionalAmount(uint256 _amount, uint256 _percentage)
  internal
  pure
  returns (uint256) {
    return div(mul(_amount, _percentage), 100);
  }

   
   
   
   
  function bytesToUint(bytes b) internal pure returns (uint256) {
      uint256 number;
      for(uint i=0; i < b.length; i++){
          number = number + uint(b[i]) * (2**(8 * (b.length - (i+1))));
      }
      return number;
  }

}

 
 
contract TokenFaucet {
  using SafeMath for uint; 

  MyBitToken public mybToken;
  Database public database; 

  uint public mybTokensInFaucet;
  uint public balanceWEI; 

  uint public basicIncomeMYB = uint(10e21);      
  uint public basicIncomeWEI = 100 finney;     

  bytes32 private accessPass; 

  uint public oneYear = uint(31536000);     


  constructor(address _database, address _mybTokenAddress, bytes32 _accessPass)
  public  {
    database = Database(_database); 
    mybToken = MyBitToken(_mybTokenAddress);
    accessPass = _accessPass; 
  }

   
   
  function receiveApproval(address _from, uint _amount, address _mybToken, bytes _data)
  external {
    require(_mybToken == msg.sender && _mybToken == address(mybToken));
    require(mybToken.transferFrom(_from, this, _amount));
    mybTokensInFaucet = mybTokensInFaucet.add(_amount);
    emit LogMYBDeposited(_from, _amount, _data);
  }

   
  function depositWEI()
  external 
  payable { 
    balanceWEI = balanceWEI.add(msg.value); 
    emit LogEthDeposited(msg.sender, msg.value); 
  }

     
  function withdraw(string _pass)
  external {
    require (keccak256(abi.encodePacked(_pass)) == accessPass); 
    uint expiry = now.add(oneYear);
    uint accessLevel = database.uintStorage(keccak256(abi.encodePacked("userAccess", msg.sender))); 
    if (accessLevel < 1){ 
      database.setUint(keccak256(abi.encodePacked("userAccess", msg.sender)), 1);   
      database.setUint(keccak256(abi.encodePacked("userAccessExpiration", msg.sender)), expiry);
      emit LogNewUser(msg.sender);
    }
    if (mybToken.balanceOf(msg.sender) < basicIncomeMYB) { 
      uint amountMYB = basicIncomeMYB.sub(mybToken.balanceOf(msg.sender)); 
      mybTokensInFaucet = mybTokensInFaucet.sub(amountMYB); 
    }
    if (msg.sender.balance < basicIncomeWEI) { 
      uint amountWEI = basicIncomeWEI.sub(msg.sender.balance); 
      balanceWEI = balanceWEI.sub(amountWEI); 
      msg.sender.transfer(amountWEI);
    }
    emit LogWithdraw(msg.sender, amountMYB, amountWEI);
  }

  function changePass(bytes32 _newPass)
  external 
  anyOwner
  returns (bool) { 
    accessPass = _newPass; 
    return true; 
  }

   
   
   
  modifier basicVerification(uint _newAccessLevel) {
  uint currentLevel = database.uintStorage(keccak256(abi.encodePacked("userAccess", msg.sender)));
  require(currentLevel < _newAccessLevel || database.uintStorage(keccak256(abi.encodePacked("userAccessExpiration", msg.sender))) < now);        
  require (_newAccessLevel < uint(4) && _newAccessLevel > uint(0));       
  _;
}

   
   
   
  modifier anyOwner {
    require(database.boolStorage(keccak256(abi.encodePacked("owner", msg.sender))));
    _;
  }

  event LogWithdraw(address _sender, uint _amountMYB, uint _amountWEI);
  event LogMYBDeposited(address _depositer, uint _amount, bytes _data);
  event LogEthDeposited(address _depositer, uint _amountWEI); 
  event LogEthWithdraw(address _withdrawer, uint _amountWEI); 
  event LogNewUser(address _user); 
}