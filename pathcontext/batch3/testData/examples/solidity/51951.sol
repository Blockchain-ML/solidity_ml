 
pragma solidity ^0.4.23;


 
 
 
 
 
 
 
 
 
 
contract WalletAbi {
   
  function revoke(bytes32 _operation) external;

   
  function changeOwner(address _from, address _to) external;

  function addOwner(address _owner) external;

  function removeOwner(address _owner) external;

  function changeRequirement(uint _newRequired) external;

   
  function setDailyLimit(uint _newLimit) external;

  function execute(address _to, uint _value, bytes _data) external returns (bytes32);

  function hasConfirmed(bytes32 _operation, address _owner) external view returns (bool);

  function isOwner(address _addr) public view returns (bool);

  function confirm(bytes32 _h) public returns (bool);
}



 
contract SoftDestruct {
   
  address public targetUser;

   
  bool private destroyed = false;

  constructor(address _targetUser) public {
    assert(_targetUser != address(0));
    targetUser = _targetUser;
  }

   
  function() public payable onlyAlive {}

   
  function kill() public onlyTarget onlyAlive {
    destroyed = true;
    if (address(this).balance == 0) {
      return;
    }
    targetUser.transfer(address(this).balance);
  }

  function isTarget() internal view returns (bool) {
    return targetUser == msg.sender;
  }

  function isDestroyed() internal view returns (bool) {
    return destroyed;
  }

   
   
  modifier onlyAlive() {
    require(!destroyed);
    _;
  }

   
  modifier onlyTarget() {
    require(isTarget());
    _;
  }
}



 
 
 
 
 
 
 
 
 
 
contract WalletEvents {
   

   
   
  event Confirmation(address owner, bytes32 operation);
  event Revoke(address owner, bytes32 operation);

   
  event OwnerChanged(address oldOwner, address newOwner);
  event OwnerAdded(address newOwner);
  event OwnerRemoved(address oldOwner);

   
  event RequirementChanged(uint newRequirement);

   
  event Deposit(address _from, uint value);

   
  event SingleTransact(address owner, uint value, address to, bytes data, address created);

   
   
  event MultiTransact(address owner, bytes32 operation, uint value, address to, bytes data, address created);

   
  event ConfirmationNeeded(bytes32 operation, address initiator, uint value, address to, bytes data);
}


contract WalletAbiMembers is WalletAbi {
  uint public m_required = 1;  
  uint public m_numOwners = 1;  
  uint public m_dailyLimit = 0;  
  uint public m_spentToday = 0;  

   
  function m_lastDay() public view returns (uint) {
    return block.timestamp;
  }
}


contract WalletAbiFunctions is WalletAbi, SoftDestruct {
   
  function revoke(bytes32) external onlyTarget {}

   
  function changeOwner(address _from, address _to) external onlyTarget {
    require(_from == targetUser);
    targetUser = _to;
  }

  function addOwner(address) external onlyTarget {
    revert();
  }

  function removeOwner(address) external onlyTarget {
    revert();
  }

  function changeRequirement(uint) external onlyTarget {
    revert();
  }

   
  function setDailyLimit(uint) external onlyTarget {
    revert();
  }

  function hasConfirmed(bytes32, address) external view returns (bool) {
    return true;
  }

  function confirm(bytes32) public onlyTarget returns (bool) {
    return true;
  }

  function isOwner(address _address) public view returns (bool) {
    return targetUser == _address;
  }

   
  function getOwner(uint ownerIndex) public view returns (address) {
    if (ownerIndex > 0) {
      return 0;
    }
    return targetUser;
  }
}



 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



contract Checkable {
  address private serviceAccount;
   
  bool private triggered = false;

   
  event Triggered(uint balance);
   
  event Checked(bool isAccident);

  constructor() public {
    serviceAccount = msg.sender;
  }

   
  function changeServiceAccount(address _account) public onlyService {
    require(_account != 0);
    serviceAccount = _account;
  }

   
  function isServiceAccount() public view returns (bool) {
    return msg.sender == serviceAccount;
  }

   
  function check() public payable onlyService notTriggered {
    if (internalCheck()) {
      emit Triggered(address(this).balance);
      triggered = true;
      internalAction();
    }
  }

   
  function internalCheck() internal returns (bool);

   
  function internalAction() internal;

  modifier onlyService {
    require(msg.sender == serviceAccount);
    _;
  }

  modifier notTriggered {
    require(!triggered);
    _;
  }
}



 
contract ERC223Receiver {
   
  function tokenFallback(address _from, uint _value, bytes _data) public;
}


contract ERC223Basic is ERC20Basic {
  function transfer(address to, uint value, bytes data) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint indexed value, bytes data);
}


 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


 
contract LastWill is SoftDestruct, Checkable, ERC223Receiver {
    struct RecipientPercent {
        address recipient;
        uint8 percent;
    }

     
    uint public constant TOKEN_ADDRESSES_LIMIT = 10;

     
    address[] private tokenAddresses;

     
    RecipientPercent[] private percents;

     
     
    event Killed(bool byUser);
     
    event FundsAdded(address indexed from, uint amount);
     
    event FundsSent(address recipient, uint amount, uint percent);
     
    event TokensSent(address token, address recipient, uint amount, uint percent);

     
    constructor(
        address _targetUser,
        address[] _recipients,
        uint[] _percents
    ) public SoftDestruct(_targetUser) {
        require(_recipients.length == _percents.length);
        percents.length = _recipients.length;
         
        uint summaryPercent = 0;
        for (uint i = 0; i < _recipients.length; i++) {
            address recipient = _recipients[i];
            uint percent = _percents[i];

            require(recipient != 0x0);
            summaryPercent += percent;
            percents[i] = RecipientPercent(recipient, uint8(percent));
        }
        require(summaryPercent == 100);
    }

     
     
    function () public payable onlyAlive() notTriggered {
        emit FundsAdded(msg.sender, msg.value);
    }

    function addTokenAddresses(address[] _contracts) external onlyTarget notTriggered {
        require(tokenAddresses.length + _contracts.length <= TOKEN_ADDRESSES_LIMIT);
        for (uint i = 0; i < _contracts.length; i++) {
            _addTokenAddress(_contracts[i]);
        }
    }

    function addTokenAddress(address _contract) public onlyTarget notTriggered {
        require(tokenAddresses.length < TOKEN_ADDRESSES_LIMIT);
        _addTokenAddress(_contract);
    }

    function deleteTokenAddress(address _contract) public onlyTarget {
        require(_contract != address(0));
        require(isTokenAddressAlreadyInList(_contract));
        for (uint i = 0; i < tokenAddresses.length; i++) {
            if (tokenAddresses[i] == _contract) {
                tokenAddresses[i] = tokenAddresses[tokenAddresses.length - 1];
                delete tokenAddresses[tokenAddresses.length - 1];
                tokenAddresses.length--;
                break;
            }
        }
    }

     
    function check() public onlyAlive payable {
        super.check();
    }

     
    function kill() public {
        super.kill();
        emit Killed(true);
    }

     
    function tokenFallback(address, uint, bytes) public {
        require(isTokenAddressAlreadyInList(msg.sender));
    }

    function getTokenAddresses() public view returns (address[]) {
        return tokenAddresses;
    }

     
    function _addTokenAddress(address _contract) internal {
        require(_contract != address(0));
        require(!isTokenAddressAlreadyInList(_contract));
        tokenAddresses.push(_contract);
    }

     
    function calculateAmounts(uint balance) internal view returns (uint[] amounts) {
        uint remainder = balance;
        amounts = new uint[](percents.length);
        for (uint i = 0; i < percents.length; i++) {
            if (i + 1 == percents.length) {
                amounts[i] = remainder;
                break;
            }
            uint amount = balance * percents[i].percent / 100;
            amounts[i] = amount;
            remainder -= amount;
        }
    }

     
    function distributeFunds() internal {
        uint[] memory amounts = calculateAmounts(address(this).balance);

        for (uint i = 0; i < amounts.length; i++) {
            uint amount = amounts[i];
            address recipient = percents[i].recipient;
            uint percent = percents[i].percent;

            if (amount == 0) {
                continue;
            }

            recipient.transfer(amount);
            emit FundsSent(recipient, amount, percent);
        }
    }

    function distributeTokens() internal {
        for (uint i = 0; i < tokenAddresses.length; i++) {
            ERC20Basic token = ERC20Basic(tokenAddresses[i]);
            uint[] memory amounts = calculateAmounts(token.balanceOf(this));

            for (uint j = 0; j < amounts.length; j++) {
                uint amount = amounts[j];
                address recipient = percents[j].recipient;
                uint percent = percents[j].percent;

                if (amount == 0) {
                    continue;
                }

                token.transfer(recipient, amount);
                emit TokensSent(token, recipient, amount, percent);
            }
        }
    }

     
    function internalAction() internal {
        distributeFunds();
        distributeTokens();
    }

    function isTokenAddressAlreadyInList(address _contract) internal view returns (bool) {
        for (uint i = 0; i < tokenAddresses.length; i++) {
            if (tokenAddresses[i] == _contract) return true;
        }
        return false;
    }
}


contract ERC20Wallet {
  function tokenBalanceOf(address _token) public view returns (uint) {
    return ERC20(_token).balanceOf(this);
  }

  function tokenTransfer(address _token, address _to, uint _value) public returns (bool) {
    return ERC20(_token).transfer(_to, _value);
  }

  function tokenTransferFrom(
    address _token,
    address _from,
    address _to,
    uint _value
  )
    public
    returns (bool)
  {
    return ERC20(_token).transferFrom(_from, _to, _value);
  }

  function tokenApprove(address _token, address _spender, uint256 _value) public returns (bool) {
    return ERC20(_token).approve(_spender, _value);
  }

  function tokenAllowance(address _token, address _owner, address _spender) public view returns (uint) {
    return ERC20(_token).allowance(_owner, _spender);
  }
}



library TxUtils {
  struct Transaction {
    address to;
    uint value;
    bytes data;
    uint timestamp;
  }

  function equals(Transaction self, Transaction other) internal pure returns (bool) {
    return (self.to == other.to) && (self.value == other.value) && (self.timestamp == other.timestamp);
  }

  function isNull(Transaction self) internal pure returns (bool) {
     
    return equals(self, Transaction(address(0), 0, "", 0));
  }
}


contract Wallet is WalletEvents, WalletAbiMembers, WalletAbiFunctions {
  function execute(address _to, uint _value, bytes _data) external returns (bytes32);
}


contract LostKeyERC20Wallet is LastWill, ERC20Wallet {
  uint64 public lastOwnerActivity;
  uint64 public noActivityPeriod;

  event Withdraw(address _sender, uint amount, address _beneficiary);

  constructor(
    address _targetUser,
    address[] _recipients,
    uint[] _percents,
    uint64 _noActivityPeriod
  )
    public
    LastWill(_targetUser, _recipients, _percents)
  {
    noActivityPeriod = _noActivityPeriod;
    lastOwnerActivity = uint64(block.timestamp);
  }

  function sendFunds(uint _amount, address _receiver, bytes _data) public onlyTarget onlyAlive {
    sendFundsInternal(_amount, _receiver, _data);
  }

  function sendFunds(uint _amount, address _receiver) public onlyTarget onlyAlive {
    sendFundsInternal(_amount, _receiver, "");
  }

  function check() public payable {
     
    require(msg.value == 0);
    super.check();
  }

  function tokenTransfer(address _token, address _to, uint _value) public onlyTarget returns (bool success) {
    updateLastActivity();
    return super.tokenTransfer(_token, _to, _value);
  }

  function tokenTransferFrom(
    address _token,
    address _from,
    address _to,
    uint _value
  )
    public
    onlyTarget
    returns (bool success)
  {
    updateLastActivity();
    return super.tokenTransferFrom(
      _token,
      _from,
      _to,
      _value
    );
  }

  function tokenApprove(address _token, address _spender, uint256 _value) public onlyTarget returns (bool success) {
    updateLastActivity();
    return super.tokenApprove(_token, _spender, _value);
  }

  function internalCheck() internal returns (bool) {
    bool result = block.timestamp > lastOwnerActivity && (block.timestamp - lastOwnerActivity) >= noActivityPeriod;
    emit Checked(result);
    return result;
  }

  function updateLastActivity() internal {
    lastOwnerActivity = uint64(block.timestamp);
  }

  function sendFundsInternal(uint _amount, address _receiver, bytes _data) internal {
    require(address(this).balance >= _amount);
    if (_data.length == 0) {
       
      require(_receiver.send(_amount));
    } else {
       
      require(_receiver.call.value(_amount)(_data));
    }

    emit Withdraw(msg.sender, _amount, _receiver);
    updateLastActivity();
  }
}


library QueueUtils {
  using TxUtils for TxUtils.Transaction;

  struct Queue {
    uint length;
    uint head;
    uint tail;
    mapping(uint => Node) list;
  }

  struct Node {
    uint prev;
    uint next;
    TxUtils.Transaction data;  
  }

  function size(Queue storage _self) internal view returns (uint) {
    return _self.length;
  }

  function isEmpty(Queue storage _self) internal view returns (bool) {
    return size(_self) == 0;
  }

  function getTransaction(Queue storage _self, uint _index) internal view returns (TxUtils.Transaction) {
    uint count = 0;
    for (uint i = _self.head; i <= _self.tail; i = _self.list[i].prev) {
      Node memory node = _self.list[i];
      if (count == _index) {
        return node.data;
      }
      count++;
    }
  }

  function push(Queue storage _self, TxUtils.Transaction _tx) internal {
    require(_self.list[_tx.timestamp].data.isNull(), "Cannot push transaction with same timestamp");

    Node memory node;
    if (_self.list[_self.tail].data.isNull()) {
      node = Node(0, 0, _tx);
      _self.head = _tx.timestamp;
    } else {
      _self.list[_self.tail].prev = _tx.timestamp;
      Node storage nextNode = _self.list[_self.tail];
      node = Node(0, nextNode.data.timestamp, _tx);
      nextNode.prev = _tx.timestamp;
    }
    _self.list[_tx.timestamp] = node;
    _self.tail = _tx.timestamp;
    _self.length++;
  }

  function peek(Queue storage _self) internal view returns (TxUtils.Transaction) {
     
    return isEmpty(_self) ? TxUtils.Transaction(0, 0, "", 0) : _self.list[_self.head].data;
  }

  function pop(Queue storage _self) internal returns (TxUtils.Transaction) {
    if (isEmpty(_self)) {
       
      return TxUtils.Transaction(0, 0, "", 0);
    }

    if (size(_self) == 1) {
      _self.tail = 0;
    }

    Node memory current = _self.list[_self.head];
    uint newHead = current.prev;
    delete _self.list[_self.head];
    _self.head = newHead;
    _self.length--;

    return current.data;
  }

  function remove(Queue storage _self, TxUtils.Transaction _tx) internal returns (bool) {
    require(size(_self) > 0, "Queue is empty");

    uint iterator = _self.tail;
    while (iterator != 0) {
      Node memory node = _self.list[iterator];
      if (node.data.equals(_tx)) {
        if (node.prev != 0 && node.next != 0) {
          _self.list[node.prev].next = _self.list[node.next].data.timestamp;
          _self.list[node.next].prev = _self.list[node.next].data.timestamp;
        } else if (node.prev != 0) {
          _self.list[node.prev].next = 0;
          _self.head = node.prev;
        } else if (node.next != 0) {
          _self.list[node.next].prev = 0;
          _self.tail = node.next;
        }

        delete _self.list[iterator];
        _self.length--;
        return true;
      }
      iterator = _self.list[iterator].next;
    }

    return false;
  }
}


contract LostKeyDelayedPaymentWallet is Wallet, LostKeyERC20Wallet {
  using QueueUtils for QueueUtils.Queue;

   
   
  uint public transferThresholdWei;
   
  uint public transferDelaySeconds;
   
  QueueUtils.Queue internal queue;

   
  event Killed(bool byUser);
   
  event FundsAdded(address indexed from, uint amount);
   
  event FundsSent(address recipient, uint amount, uint percent);

   
  constructor(
    address _targetUser,
    address[] _recipients,
    uint[] _percents,
    uint64 _noActivityPeriod,
    uint _transferThresholdWei,
    uint _transferDelaySeconds
  )
    public
    LostKeyERC20Wallet(
      _targetUser,
      _recipients,
      _percents,
      _noActivityPeriod
    )
  {
    transferThresholdWei = _transferThresholdWei;
    transferDelaySeconds = _transferDelaySeconds;
  }

   
  function execute(address _to, uint _value, bytes _data) external returns (bytes32) {
    sendFunds(_to, _value, _data);
    return keccak256(abi.encodePacked(msg.data, block.number));
  }

   
  function sendFunds(address _to, uint _amount, bytes _data) public onlyTarget onlyAlive {
    require(_to != address(0), "Address should not be 0");
    if (_data.length == 0) {
      require(_amount != 0, "Amount should not be 0");
    }

    if (_amount < transferThresholdWei || transferThresholdWei == 0) {
      sendFundsInternal(_amount, _to, _data);
    } else {
      queue.push(TxUtils.Transaction(
          _to,
          _amount,
          _data,
          now + transferDelaySeconds
        ));
    }
  }

   
  function getTransaction(uint _index) public view returns (address to, uint value, bytes data, uint timestamp) {
    TxUtils.Transaction memory t = queue.getTransaction(_index);
    return (t.to, t.value, t.data, t.timestamp);
  }

   
  function reject(
    address _to,
    uint _value,
    bytes _data,
    uint _timestamp
  )
    public
    onlyTarget
  {
    TxUtils.Transaction memory transaction = TxUtils.Transaction(
      _to,
      _value,
      _data,
      _timestamp
    );
    require(queue.remove(transaction), "Transaction not found in queue");
  }

   
  function sendDelayedTransactions() public returns (bool isSent) {
    for (uint i = 0; i < queue.size(); i++) {
      if (queue.peek().timestamp > now) {
        break;
      }
      internalSendTransaction(queue.pop());
      isSent = true;
    }
  }

   
  function queueSize() public view returns (uint size) {
    return queue.size();
  }

   
  function internalSendTransaction(TxUtils.Transaction _tx) internal {
    sendFundsInternal(_tx.value, _tx.to, _tx.data);
  }
}