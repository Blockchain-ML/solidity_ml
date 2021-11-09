pragma solidity ^0.4.23;

 
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

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
     
     
     
    if (a == 0) {
      return 0;
    }

    c = a * b;
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

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
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

   
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}


contract DecentralizedCrowdFunding is Pausable {
    using SafeMath for uint256;

     
    enum State {
        Running,
        DisbursementPending,
        Closed
    }

    State public state = State.Running;

    address public creator;
    address public fundRecipient;
    uint256 public targetFunding = 0;
    string public campaignUrl;

    uint256 public totalRaised = 0;
    uint256 public currentBalance = 0;

    uint256 public fundingStartTime = 0;
    uint256 public fundingEndTime = 0;

    address[] public contributionAddresses;
    mapping(address => uint256) public contributionAmounts;

    uint256 public disbursementAmount = 0;
    uint256 public approvalPercent = 0;
    mapping(address => bool) public approvalDisbursementStatuses;
    uint public consensusPercent = 51;

    uint256 public terminatePercent = 0;
    mapping(address => bool) public terminateStatuses;
    uint public objectionPercent = 51;

    event LogFundingReceived(address addr, uint256 amount, uint256 currentTotal);
    event LogWinnerPaid(address winnerAddress);
    event LogFunderInitialized(address creator, address fundRecipient, uint256 targetFunding, string campaignUrl, uint256 fundingStartTime, uint256 fundingEndTime);

    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

     
    modifier atEndOfLifecycle() {
        if (state != State.Closed && fundingEndTime + 1 days < now) throw;
        _;
    }

    function DecentralizedCrowdFunding(
        address _fundRecipient,
        uint256 _targetFunding,
        string _campaignUrl,
        uint256 _fundingStartTime,
        uint256 _fundingEndTime
        ) public {
        creator = msg.sender;
        fundRecipient = _fundRecipient;
        targetFunding = _targetFunding;
        campaignUrl = _campaignUrl;
        fundingStartTime = _fundingStartTime;
        fundingEndTime = _fundingEndTime;
        currentBalance = 0;
        LogFunderInitialized(creator, fundRecipient, targetFunding, campaignUrl, fundingStartTime, fundingEndTime);
    }

    function() public payable {
        contribute(msg.sender, msg.value);
    }

    function contribute(address _contributor, uint256 _value) returns (bool success) {
        require(state != State.Closed);
        require(totalRaised < targetFunding);
        require(_value > 0);
        require(fundingStartTime == 0 || now >= fundingStartTime);
        require(fundingEndTime == 0 || now <= fundingEndTime);

        uint256 prevAmt = contributionAmounts[_contributor];

        uint256 contributingAmt = _value;
        uint256 refundAmt = 0;

        uint256 checkedTotalRaised = totalRaised.add(contributingAmt);
        if (targetFunding < checkedTotalRaised) {
            contributingAmt = targetFunding.sub(totalRaised);
            refundAmt = _value.sub(contributingAmt);
        }

        contributionAmounts[_contributor] = contributingAmt.add(prevAmt);

         
        if (refundAmt > 0) {
            _contributor.transfer(refundAmt);
        }

        totalRaised = totalRaised.add(contributingAmt);
        currentBalance = currentBalance.add(contributingAmt);
        if (prevAmt == 0) {
            contributionAddresses.push(_contributor);
        }

        return true;
    }

    function setConsensusPercent(uint _value) public isCreator() returns (bool success) {
        require(state == State.Running);  
        require(_value <= 100);
        consensusPercent = _value;
        return true;
    }

    function setObjectionPercent(uint _value) public isCreator() returns (bool success) {
        require(state == State.Running);  
        require(_value > 0 && _value <= 100);
        objectionPercent = _value;
        return true;
    }

    function requestDisbursement(uint256 _value) public returns (bool success) {
        require(state == State.Running);
        require(totalRaised > 0);
        require(_value > 0);
        require(currentBalance >= _value);
        require(msg.sender == creator || msg.sender == fundRecipient);
        disbursementAmount = _value;
        state = State.DisbursementPending;
        approvalPercent = 0;
        terminatePercent = 0;
        for (uint i = 0; i < contributionAddresses.length; i++) {
            approvalDisbursementStatuses[contributionAddresses[i]] = false;
        }
        return true;
    }

    function approveDisbursement() public returns (bool completed) {
        require(state == State.DisbursementPending);
        require(totalRaised > 0);
        require(currentBalance >= disbursementAmount);
        require(approvalDisbursementStatuses[msg.sender] != true);
        uint256 contributedAmt = contributionAmounts[msg.sender];
        require(contributedAmt > 0);
        approvalDisbursementStatuses[msg.sender] = true;
        uint256 totalApprovalAmt = 0;
        for (uint i = 0; i < contributionAddresses.length; i++) {
            if (approvalDisbursementStatuses[contributionAddresses[i]])
                totalApprovalAmt = totalApprovalAmt.add(contributionAmounts[contributionAddresses[i]]);
        }
        approvalPercent = totalApprovalAmt.mul(100).div(totalRaised);
        if (approvalPercent >= consensusPercent) {
            currentBalance = currentBalance.sub(disbursementAmount);
            state = State.Running;
            fundRecipient.transfer(disbursementAmount);
            return true;
        }
        return false;
    }

    function unapproveDisbursement() public returns (bool completed) {
        require(state == State.DisbursementPending);
        require(totalRaised > 0);
        require(approvalDisbursementStatuses[msg.sender]);
        uint256 contributedAmt = contributionAmounts[msg.sender];
        require(contributedAmt > 0);
        approvalDisbursementStatuses[msg.sender] = false;
        uint256 totalApprovalAmt = 0;
        for (uint i = 0; i < contributionAddresses.length; i++) {
            if (approvalDisbursementStatuses[contributionAddresses[i]])
                totalApprovalAmt = totalApprovalAmt.add(contributionAmounts[contributionAddresses[i]]);
        }
        approvalPercent = totalApprovalAmt.mul(100).div(totalRaised);
        return true;
    }

    function terminateFunding() public returns (bool completed) {
        require(state != State.Closed);
        require(totalRaised > 0);
        require(terminateStatuses[msg.sender] != true);
        uint256 contributedAmt = contributionAmounts[msg.sender];
        require(contributedAmt > 0);
        terminateStatuses[msg.sender] = true;
        uint256 totalTerminateAmt = 0;
        uint256 refundAmt = 0;
        uint i = 0;
        for (i = 0; i < contributionAddresses.length; i++) {
            if (terminateStatuses[contributionAddresses[i]])
                totalTerminateAmt = totalTerminateAmt.add(contributionAmounts[contributionAddresses[i]]);
        }
        terminatePercent = totalTerminateAmt.mul(100).div(totalRaised);
        if (terminatePercent >= objectionPercent) {
            uint256 bal = currentBalance;
            for (i = 0; i < contributionAddresses.length; i++) {
                refundAmt = contributionAmounts[contributionAddresses[i]].mul(currentBalance).div(totalRaised);
                bal = bal.sub(refundAmt);
                contributionAddresses[i].transfer(refundAmt);
            }
            currentBalance = bal;
            state = State.Closed;
            return true;
        }
        return false;
    }

    function unterminateFunding() public returns (bool completed) {
        require(state != State.Closed);
        require(totalRaised > 0);
        require(terminateStatuses[msg.sender]);
        uint256 contributedAmt = contributionAmounts[msg.sender];
        require(contributedAmt > 0);
        terminateStatuses[msg.sender] = false;
        uint256 totalTerminateAmt = 0;
        uint i = 0;
        for (i = 0; i < contributionAddresses.length; i++) {
            if (terminateStatuses[contributionAddresses[i]])
                totalTerminateAmt = totalTerminateAmt.add(contributionAmounts[contributionAddresses[i]]);
        }
        terminatePercent = totalTerminateAmt.mul(100).div(totalRaised);
        return true;
    }

    function removeContract() public isCreator() atEndOfLifecycle() {
        selfdestruct(msg.sender);
         
    }
}