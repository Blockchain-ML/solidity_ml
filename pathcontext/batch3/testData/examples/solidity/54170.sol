pragma solidity ^0.4.23;

 
library SafeMath {

   
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
     
     
     
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

   
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
     
     
     
    return _a / _b;
  }

   
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

   
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


 
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

contract Pausible is Ownable {
    bool public isPaused = false;

    modifier onlyPaused() {
        require(isPaused);
        _;
    }

    modifier onlyInService() {
        require(!isPaused);
        _;
    }

    function pause() public onlyInService onlyOwner {
        isPaused = true;
    }

    function unpause() public onlyPaused onlyOwner {
        isPaused = false;
    }
}

contract Escrows is Pausible {
    using SafeMath for uint256;

    uint8 constant OWNER_CREATED = 0;
    uint8 constant DEPOSITED = 1;
    uint8 constant OWNER_APPROVED = 2;
    uint8 constant TAKER_APPROVED = 3;
    uint8 constant CANCELLED = 4;
    uint8 constant COMPLETED = 5;
    uint8 constant REFUNDED = 6;
    uint8 constant IN_DISPUTE = 7;

    struct Escrow {
        uint createdAt;
        address owner;
        address taker;
        address arbitrator;
        uint balance;
        uint8 status;
        uint withdrawAmountOwner;
        uint withdrawAmountTaker;
        uint withdrawAmountArbitrator;
        bool ownerApproved;
        bool takerApproved;
        address withdrawRequestSender;
    }
    
    struct Dispute {
        uint ownerAmountDispute;
        uint takerAmountDispute;
        uint arbitratorAmountDisputeOwner;
        uint arbitratorAmountDisputeTaker;
    }

    Escrow[] public escrows;
    Dispute public dispute;
    
    uint public totalEscrowsCount;

    mapping (address => uint) escrowCountByOwner;
    mapping (address => uint) escrowCountByTaker;
    mapping (uint => Dispute) escrowDispute;

     
    event LogEscrow(uint escrowId, address owner, address taker, address arbitrator, uint balance, uint8 status);
    event LogDepositEscrow(uint escrowId, address owner, address taker, address arbitrator, uint balance);
    event LogCompleteEscrow(uint escrowId, address owner, address taker, address arbitrator, uint balance);
    event LogDisputeEscrow(uint escrowId, address owner, address taker, address arbitrator, uint balance);

    function logEscrow(uint _id, Escrow _escrow) internal {

        emit LogEscrow(_id, _escrow.owner, _escrow.taker, _escrow.arbitrator, _escrow.balance, _escrow.status);

        if (_escrow.status == DEPOSITED) {
            emit LogDepositEscrow(_id, _escrow.owner, _escrow.taker, _escrow.arbitrator, _escrow.balance);
        } else if (_escrow.status == COMPLETED) {
            emit LogCompleteEscrow(_id, _escrow.owner, _escrow.taker, _escrow.arbitrator, _escrow.balance);
        } else if (_escrow.status == IN_DISPUTE) {
            emit LogDisputeEscrow(_id, _escrow.owner, _escrow.taker, _escrow.arbitrator, _escrow.balance);
        }
    }

     
    modifier onlyStatus(uint _id, uint _status) {
        require(escrows[_id].status == _status);
        _;
    }

    modifier onlyAuthorized(uint _id) {
        Escrow memory escrow = escrows[_id];
        require(msg.sender == escrow.owner || msg.sender == escrow.taker);
        _;
    }

    modifier onlyTaker(uint _id) {
        Escrow memory escrow = escrows[_id];
        require(msg.sender == escrow.taker);
        _;
    }

    modifier onlyArbitrator(uint _id) {
        Escrow memory escrow = escrows[_id];
        require(msg.sender == escrow.arbitrator);
        _;
    }

    modifier onlyCreator(uint _id) {
        Escrow memory escrow = escrows[_id];
        require(msg.sender == escrow.owner);
        _;
    }

    modifier requireBalance(uint _id) {
        Escrow memory escrow = escrows[_id];
        require(escrow.balance > 0);
        _;
    }

     
    modifier onlyValidAddress(address _address) {
        require(_address != 0x0);
        _;
    }

     
    function _addNewEscrow(
        address _owner,
        address _taker,
        address _arbitrator,
        uint8 _status
        ) internal {
        require(_owner != _taker);
        uint id = escrows.push(Escrow(now, _owner, _taker, _arbitrator, _status, 0, 0, 0, 0, false, false,0x0));
        totalEscrowsCount++;
        escrowCountByOwner[_owner] = escrowCountByOwner[_owner].add(1);
        escrowCountByTaker[_taker] = escrowCountByTaker[_taker].add(1);

        emit LogEscrow(id, _owner, _taker, _arbitrator, 0, _status);
    }
}

contract eFinEscrow is Escrows {

    function createNewEscrow(address owner, address taker, address arbitrator) external onlyValidAddress(owner) {
        require(owner != taker);
        _addNewEscrow(owner, taker, arbitrator, OWNER_CREATED);
    }

     
    function deposit(uint _id) external payable onlyAuthorized(_id) onlyStatus(_id, OWNER_CREATED) {
        Escrow storage escrow = escrows[_id];
        escrow.balance += msg.value;
        logEscrow(_id, escrow);
    }
    
    function getEscrowById(uint _id) external view returns(
        uint createdAt,
        address owner,
        address taker,
        address arbitrator,
        uint balance,
        uint8 status,
        uint withdrawAmountOwner,
        uint withdrawAmountTaker,
        uint withdrawAmountArbitrator,
        bool ownerApproved,
        bool takerApproved) {
        Escrow storage escrow = escrows[_id];

        return(
            escrow.createdAt,
            escrow.owner,
            escrow.taker,
            escrow.arbitrator,
            escrow.balance,
            escrow.status,
            escrow.withdrawAmountOwner,
            escrow.withdrawAmountTaker,
            escrow.withdrawAmountArbitrator,
            escrow.ownerApproved,
            escrow.takerApproved
        );
        
    }

     
    function ownerApproves(uint _id) external onlyCreator(_id) requireBalance(_id) {
        escrows[_id].status = OWNER_APPROVED;
        escrows[_id].ownerApproved = true;
        logEscrow(_id, escrows[_id]);
    }

     
    function takerApproves(uint _id) external onlyTaker(_id) requireBalance(_id) {
        escrows[_id].status = TAKER_APPROVED;
        escrows[_id].takerApproved = true;
        logEscrow(_id, escrows[_id]);
    }

     
    function cancel(uint _id) external onlyAuthorized(_id) {
        Escrow storage escrow = escrows[_id];
        require(escrow.status <= DEPOSITED);
        escrow.status = CANCELLED;

        logEscrow(_id, escrow);
    }
    
    function withdrawRequest(uint _id, 
                             uint _ownerAmount, 
                             uint _takerAmount, 
                             uint _arbitratorAmount) external onlyAuthorized(_id){
                                 
        Escrow storage escrow = escrows[_id];
        require(escrow.takerApproved && escrow.ownerApproved);
        escrow.withdrawAmountOwner = _ownerAmount;
        escrow.withdrawAmountTaker = _takerAmount;
        escrow.withdrawAmountArbitrator = _arbitratorAmount;
        escrow.withdrawRequestSender = msg.sender;
    }

     
    function withdraw(uint _id) external requireBalance(_id) {
        Escrow storage escrow = escrows[_id];
        require(escrow.withdrawRequestSender != msg.sender);  
        require(escrow.takerApproved && escrow.ownerApproved);
        escrow.owner.transfer(escrow.withdrawAmountOwner);
        escrow.taker.transfer(escrow.withdrawAmountTaker);
        escrow.arbitrator.transfer(escrow.withdrawAmountArbitrator);
        escrow.balance = 0;
        escrow.status = COMPLETED;
        
        logEscrow(_id, escrow);
    }



    function ownerDispute(uint _id, uint _ownerAmount, uint _arbitratorAmount) external onlyCreator(_id) {
        Escrow storage escrow = escrows[_id];
        uint incomingBalance = _ownerAmount.add(_arbitratorAmount);
        require(incomingBalance == escrow.balance);  
        escrow.status = IN_DISPUTE;
        Dispute storage dispute = escrowDispute[_id];
        dispute.ownerAmountDispute = _ownerAmount;
        dispute.arbitratorAmountDisputeOwner = _arbitratorAmount;
        
        logEscrow(_id, escrow);
    }
    
    function takerDispute(uint _id, uint _takerAmount, uint _arbitratorAmount) external onlyTaker(_id) {
        Escrow storage escrow = escrows[_id];
        uint incomingBalance = _takerAmount.add(_arbitratorAmount);
        require(incomingBalance == escrow.balance);  
        escrow.status = IN_DISPUTE;
        Dispute storage dispute = escrowDispute[_id];
        dispute.takerAmountDispute = _takerAmount;
        dispute.arbitratorAmountDisputeTaker = _arbitratorAmount;

        logEscrow(_id, escrow);
    }
    
    

     
    function arbitrate(uint _id, bool ownerWin) external onlyArbitrator(_id) onlyStatus(_id, IN_DISPUTE) {
        
        Escrow storage escrow = escrows[_id];
        Dispute storage dispute = escrowDispute[_id];
        
        if(ownerWin){
            escrow.owner.transfer(dispute.ownerAmountDispute);
            escrow.arbitrator.transfer(dispute.arbitratorAmountDisputeOwner);
            escrow.balance = 0;
            escrow.status = COMPLETED;
        } else {
            escrow.taker.transfer(dispute.takerAmountDispute);
            escrow.arbitrator.transfer(dispute.arbitratorAmountDisputeTaker);
            escrow.balance = 0;
            escrow.status = COMPLETED;
        }

        logEscrow(_id, escrow);
    }

    function getBalanceByEscrowId(uint _id) external view returns (uint) {
        return escrows[_id].balance;
    }

    function getEscrowsByOwner(address _owner) external view returns (uint[]) {
        uint[] memory result = new uint[](escrowCountByOwner[_owner]);

        uint counter = 0;
        for (uint i = 0; i < escrows.length; i++) {
            if (escrows[i].owner == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function getEscrowsByTaker(address _taker) external view returns (uint[]) {
        uint[] memory result = new uint[](escrowCountByTaker[_taker]);

        uint counter = 0;
        for (uint i = 0; i < escrows.length; i++) {
            if (escrows[i].taker == _taker) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function getBalance() external view onlyOwner returns (uint) {
        return address(this).balance;
    }
}