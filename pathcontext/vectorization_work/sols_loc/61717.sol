pragma solidity ^0.4.13;

contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

contract BTZReceiver is SafeMath {

     
    BTZ223 BTZToken;
    address tokenAddress;
    address owner;
    uint numUsers;

     
    struct UserInfo {
        uint balance;
        uint lastDeposit;
        uint totalDeposits;
    }

    event DepositReceived(uint indexed _who, uint _value, uint _timestamp);
    event Withdrawal(address indexed _withdrawalAddress, uint _value, uint _timestamp);

     
    mapping (uint => UserInfo) userInfo;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address _addr) public onlyOwner {
        owner = _addr;
    }

     
    function updateTokenAddress(address _tokenAddress) public onlyOwner {
        tokenAddress = _tokenAddress;
        BTZToken = BTZ223(_tokenAddress);
    }

     
    function userLookup(uint _uid) public view returns (uint, uint, uint){
        return (userInfo[_uid].balance, userInfo[_uid].lastDeposit, userInfo[_uid].totalDeposits);
    }

     
    function receiveDeposit(uint _id, uint _value) public {
        require(msg.sender == tokenAddress);
        userInfo[_id].balance = safeAdd(userInfo[_id].balance, _value);
        userInfo[_id].lastDeposit = now;
        userInfo[_id].totalDeposits = safeAdd(userInfo[_id].totalDeposits, 1);
        emit DepositReceived(_id, _value, now);
    }

     
    function withdrawTokens(address _withdrawalAddr) public onlyOwner{
        uint tokensToWithdraw = BTZToken.balanceOf(this);
        BTZToken.transfer(_withdrawalAddr, tokensToWithdraw);
        emit Withdrawal(_withdrawalAddr, tokensToWithdraw, now);
    }
}

contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract StandardToken is ERC20, SafeMath {

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) public returns (bool success) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) public returns (bool success) {
    require(_value <= balances[msg.sender]);
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}

contract ERC223 is ERC20 {
  function transfer(address to, uint value, bytes data) returns (bool ok);
  function transferFrom(address from, address to, uint value, bytes data) returns (bool ok);
}

contract Standard223Token is ERC223, StandardToken {
   
  function transfer(address _to, uint _value, bytes _data) returns (bool success) {
     
    if (!super.transfer(_to, _value)) throw;  
    if (isContract(_to)) return contractFallback(msg.sender, _to, _value, _data);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value, bytes _data) returns (bool success) {
    if (!super.transferFrom(_from, _to, _value)) revert();  
    if (isContract(_to)) return contractFallback(_from, _to, _value, _data);
    return true;
  }

  function transfer(address _to, uint _value) returns (bool success) {
    return transfer(_to, _value, new bytes(0));
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    return transferFrom(_from, _to, _value, new bytes(0));
  }

   
  function contractFallback(address _origin, address _to, uint _value, bytes _data) private returns (bool success) {
    ERC223Receiver reciever = ERC223Receiver(_to);
    return reciever.tokenFallback(msg.sender, _origin, _value, _data);
  }

   
  function isContract(address _addr) private returns (bool is_contract) {
     
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }
}

contract BTZ223 is Standard223Token {
  address owner;

   
  string public name = "Bunz Trading Zone";
  string public symbol = "BTZ";
  uint8 public constant decimals = 18;
  uint256 public constant decimalFactor = 10 ** uint256(decimals);
  uint256 public constant totalSupply = 200000000000 * decimalFactor;

   
  bool public prebridge;
  BTZReceiver recieverContract;
  address public recieverContractAddress;

  address _receiverContract = 0x0d136d27ce79289861a819E91772b180bA777712;

   
  constructor() public {
    owner = msg.sender;
    balances[owner] = totalSupply;
    prebridge = true;
    recieverContractAddress = _receiverContract;
    recieverContract = BTZReceiver(_receiverContract);
    Transfer(address(0), owner, totalSupply);
  }

  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }

  function changeOwner(address _addr) public onlyOwner {
      owner = _addr;
  }
    
   
  function toggleDeposit(bool _status) onlyOwner {
      prebridge = _status;
  }

   
  function changeReceiverAddress(address _newAddr) onlyOwner {
      recieverContractAddress = _newAddr;
  }

   
  function deposit(uint _value, uint _id) public {
      require(prebridge &&
              balances[msg.sender] >= _value);
      balances[msg.sender] = safeSub(balances[msg.sender], _value);
      balances[recieverContractAddress] = safeAdd(balances[recieverContractAddress], _value);
      recieverContract.receiveDeposit(_id, _value);
  }
}

contract ERC223Receiver {
  function tokenFallback(address _sender, address _origin, uint _value, bytes _data) returns (bool ok);
}