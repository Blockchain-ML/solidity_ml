pragma solidity ^0.4.24;

 
contract MarketplaceProxy {
    function calculatePlatformCommission(uint256 weiAmount) public view returns (uint256);
    function payPlatformIncomingTransactionCommission(address clientAddress) public payable;
    function payPlatformOutgoingTransactionCommission() public payable;
    function isUserBlockedByContract(address contractAddress) public view returns (bool);
}
 

 
 
contract Fund {

     
    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);
    event MemberAdded(address indexed member);
    event MemberBlocked(address indexed member);
    event MemberUnblocked(address indexed member);
    event FeeAmountChanged(uint256 feeAmount);
    event NextMemberPaymentAdded(address indexed member, uint256 expectingAmount, uint256 platformCommission);
    event NextMemberPaymentUpdated(address indexed member, uint256 expectingAmount, uint256 platformCommission);
    event IncomingPayment(address indexed sender, uint value);
    event Claim(address indexed to, uint value);

     
    uint constant public MAX_OWNER_COUNT = 50;

     
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    mapping (address => Member) public members;
    mapping (address => NextMemberPayment) public nextMemberPayments;
    address[] public owners;
    address public creator;
    uint public required;
    uint public transactionCount;
    uint256 public feeAmount;    
    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }
    struct Member {
        bool exists;
        bool blocked; 
    }
    struct NextMemberPayment {
        bool exists;
        uint256 expectingValue;        
        uint256 platformCommission;    
    }

     
    MarketplaceProxy public mp;
    event PlatformIncomingTransactionCommission(uint256 amount, address clientAddress);
    event PlatformOutgoingTransactionCommission(uint256 amount);
    event Blocked();
     

     
    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].destination != 0);
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed);
        _;
    }

    modifier notNull(address _address) {
        require(_address != 0);
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        require(ownerCount <= MAX_OWNER_COUNT
            && _required <= ownerCount
            && _required != 0
            && ownerCount != 0);
        _;
    }

     
    modifier onlyCreator() {
        require(msg.sender == creator);
        _;
    }

     
    modifier memberExists(address member) {
        require(members[member].exists);
        _;
    }

     
    modifier memberDoesNotExist(address member) {
        require(!members[member].exists);
        _;
    }

     
    modifier nextMemberPaymentExists(address member) {
        require(nextMemberPayments[member].exists);
        _;
    }

     
    modifier nextMemberPaymentDoesNotExist(address member) {
        require(!nextMemberPayments[member].exists);
        _;
    }

     
    function() 
        public 
        memberExists(msg.sender)
        nextMemberPaymentExists(msg.sender)
        payable 
    {
        handleIncomingPayment(msg.sender);
    }

     
    function fromPaymentGateway(address member) 
        public 
        memberExists(member)
        nextMemberPaymentExists(member)
        payable 
    {
        handleIncomingPayment(member);
    }

     
    function handleIncomingPayment(address member) 
        private 
    {
        NextMemberPayment storage nextMemberPayment = nextMemberPayments[member];

        require(nextMemberPayment.expectingValue == msg.value);

         
         
        if (mp.isUserBlockedByContract(address(this))) {
            mp.payPlatformIncomingTransactionCommission.value(msg.value)(member);
            emit Blocked();
        } else {
            mp.payPlatformIncomingTransactionCommission.value(nextMemberPayment.platformCommission)(member);
            emit PlatformIncomingTransactionCommission(nextMemberPayment.platformCommission, member);
        }
         

        emit IncomingPayment(member, msg.value);
    }

     
    function addEth() 
        public 
        onlyCreator
        payable 
    {

    }

     
     
    constructor()
        public
    {
        required = 1;            
        creator = msg.sender;
        
         
         
        mp = MarketplaceProxy(0x7b71342582610452641989D599a684501922Cb57);
         

    }

     
     
    function addOwner(address owner)
        public
        onlyCreator
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

     
     
    function removeOwner(address owner)
        public
        onlyCreator
        ownerExists(owner)
    {
        isOwner[owner] = false;
        for (uint i=0; i<owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

     
     
     
    function replaceOwner(address owner, address newOwner)
        public
        onlyCreator
        ownerExists(owner)
        ownerDoesNotExist(newOwner)
    {
        for (uint i=0; i<owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

     
     
    function changeRequirement(uint _required)
        public
        onlyCreator
        validRequirement(owners.length, _required)
    {
        required = _required;
        emit RequirementChange(_required);
    }

     
     
     
     
     
    function initTransaction(address destination, uint value, bytes data)
        public
        onlyCreator
        returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data);
    }

     
     
    function confirmTransaction(uint transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

     
     
    function revokeConfirmation(uint transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

     
     
    function executeTransaction(uint transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            if (external_call(txn.destination, txn.value, txn.data.length, txn.data))
                emit Execution(transactionId);
            else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

     
     
    function external_call(address destination, uint value, uint dataLength, bytes data) private returns (bool) {
        bool result;
        assembly {
            let x := mload(0x40)    
            let d := add(data, 32)  
            result := call(
                sub(gas, 34710),    
                                    
                                    
                destination,
                value,
                d,
                dataLength,         
                x,
                0                   
            )
        }
        return result;
    }

     
     
     
    function isConfirmed(uint transactionId)
        public
        view
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

     
    function blockMember(address member) 
        public
        onlyCreator
        memberExists(member)
    {
        members[member].blocked = true;
        emit MemberBlocked(member);
    }

     
    function unblockMember(address member) 
        public
        onlyCreator
        memberExists(member)
    {
        members[member].blocked = false;
        emit MemberUnblocked(member);
    }

     
    function isMemberBlocked(address member) 
        public 
        view 
        memberExists(member)
        returns (bool) 
    {
        return members[member].blocked;
    }

     
    function addMember(address member) 
        public
        onlyCreator
        notNull(member)
        memberDoesNotExist(member)
    {
        members[member] = Member(
            true,    
            false    
        );
        emit MemberAdded(member);
    }

     
    function setFeeAmount(uint256 _feeAmount) 
        public
        onlyCreator
    {
        feeAmount = _feeAmount;
        emit FeeAmountChanged(_feeAmount);
    }

     
    function addNextMemberPayment(address member, uint256 expectingValue, uint256 platformCommission) 
        public 
        onlyCreator 
        memberExists(member)
        nextMemberPaymentDoesNotExist(member)
    {
        nextMemberPayments[member] = NextMemberPayment(
            true,
            expectingValue,
            platformCommission
        );
        emit NextMemberPaymentAdded(member, expectingValue, platformCommission);
    }

     
    function updateNextMemberPayment(address member, uint256 _expectingValue, uint256 _platformCommission) 
        public 
        onlyCreator 
        memberExists(member)
        nextMemberPaymentExists(member)
    {
        nextMemberPayments[member].expectingValue = _expectingValue;
        nextMemberPayments[member].platformCommission = _platformCommission;
        emit NextMemberPaymentUpdated(member, _expectingValue, _platformCommission);
    }

     
    function claim(address to, uint256 amount) 
        public 
        onlyCreator
        memberExists(to)
    {
         
         
        uint256 commission = mp.calculatePlatformCommission(amount);
        require(address(this).balance > (amount + commission));

         
        mp.payPlatformOutgoingTransactionCommission.value(commission)();
        emit PlatformOutgoingTransactionCommission(commission);
         

        to.transfer(amount);

        emit Claim(to, amount);
    }

     
     
     
     
     
     
    function addTransaction(address destination, uint value, bytes data)
        internal
        notNull(destination)
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }

     
     
     
     
    function getConfirmationCount(uint transactionId)
        public
        view
        returns (uint count)
    {
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

     
     
     
     
    function getTransactionCount(bool pending, bool executed)
        public
        view
        returns (uint count)
    {
        for (uint i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
                count += 1;
    }

     
     
    function getOwners()
        public
        view
        returns (address[])
    {
        return owners;
    }

     
     
     
    function getConfirmations(uint transactionId)
        public
        view
        returns (address[] _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

     
     
     
     
     
     
    function getTransactionIds(uint from, uint to, bool pending, bool executed)
        public
        view
        returns (uint[] _transactionIds)
    {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i=from; i<to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
}