pragma solidity ^0.4.24;

library ECDSA {
     
    function recover(bytes32 hash, bytes signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

         
        if (signature.length != 65) {
            return (address(0));
        }

         
         
         
         
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

         
        if (v < 27) {
            v += 27;
        }

         
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
             
            return ecrecover(hash, v, r, s);
        }
    }
}

 
 
 
contract TeamWallet {
    using ECDSA for bytes32;

     
    event TeamCreated(address[] owners, address contractAddress, string id);
    event Approval(address indexed sender, uint indexed transactionId);
    event Rejection(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId, uint trackingId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner, string name);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint oldRequired, uint newRequired);

     
    uint constant public MAX_OWNER_COUNT = 50;

     
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public approvals;
    mapping (uint => mapping (address => bool)) public rejections;
    mapping (address => bool) public isOwner;
    address[] public owners;
    uint public required;
    uint public transactionCount;
    string public id;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bytes reasonHash;
        bool executed;
    }

     
    modifier onlyWallet() {
        require(msg.sender == address(this), "Sender is not wallet");
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner], "Owner existed");
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner], "Owner does not existed");
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].destination != 0, "Transaction was not existed");
        _;
    }

    modifier approved(uint transactionId, address owner) {
        require(approvals[transactionId][owner], "Transaction was not approved");
        _;
    }

    modifier notApproved(uint transactionId, address owner) {
        require(!approvals[transactionId][owner], "Transaction was approved");
        _;
    }

    modifier notRejected(uint transactionId, address owner) {
        require(!rejections[transactionId][owner], "Transaction was rejected");
        _;
    }

    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed, "Transaction was executed");
        _;
    }

    modifier notNull(address _address) {
        require(_address != 0, "Null address");
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        require(ownerCount <= MAX_OWNER_COUNT && _required <= ownerCount && _required != 0 && ownerCount != 0, "Invalid required");
        _;
    }

     
    function()
        public
        payable
    {
        if (msg.value > 0)
            emit Deposit(msg.sender, msg.value);
    }

     
     
     
     
    constructor(address[] _owners, uint _required, string _id)
        public
        validRequirement(_owners.length, _required)
    {
        for (uint i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != 0, "Invalid owner");
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
        id = _id;
        emit TeamCreated(owners, this, id);
    }

     
     
    function addOwner(address owner, string name)
        public
        onlyWallet
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner, name);
    }

     
     
    function removeOwner(address owner)
        public
        onlyWallet
        ownerExists(owner)
    {
        isOwner[owner] = false;
        for (uint i = 0; i < owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

     
     
    function changeRequirement(uint _required)
        public
        onlyWallet
        validRequirement(owners.length, _required)
    {
        uint oldRequired = required;
        required = _required;
        emit RequirementChange(oldRequired, _required);
    }

     
     
     
     
     
     
    function _submitTransaction(address destination, uint value, bytes data, bytes reasonHash, address owner, uint trackingId)
        internal
        returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data, reasonHash, trackingId);
        _approveTransaction(transactionId, owner);
    }

     
     
     
     
     
     
    function submitTransaction(address destination, uint value, bytes data, bytes reasonHash, bytes signature, uint trackingId)
        public
        returns (uint transactionId)
    {
        bytes32 opHash = keccak256(abi.encodePacked(destination, value, data, reasonHash));
        address opSigner = opHash.recover(signature);
        
        transactionId = _submitTransaction(destination, value, data, reasonHash, opSigner, trackingId);
    }

     
     
    function _approveTransaction(uint transactionId, address owner)
        internal
        ownerExists(owner)
        transactionExists(transactionId)
        notApproved(transactionId, owner)
        notRejected(transactionId, owner)
    {
        approvals[transactionId][owner] = true;
        emit Approval(owner, transactionId);
        _executeTransaction(transactionId, owner);
    }

     
     
    function approveTransaction(uint transactionId, bytes signature)
        public
    {
        bytes32 opHash = keccak256(abi.encodePacked(transactionId));
        address opSigner = opHash.recover(signature);
        
        _approveTransaction(transactionId, opSigner);
    }

     
     
    function _rejectTransaction(uint transactionId, address owner)
        internal
        ownerExists(owner)
        notApproved(transactionId, owner)
        notExecuted(transactionId)
    {
        rejections[transactionId][owner] = true;
        emit Rejection(owner, transactionId);
    }

     
     
    function rejectTransaction(uint transactionId, bytes signature)
        public
    {
        bytes32 opHash = keccak256(abi.encodePacked(transactionId));
        address opSigner = opHash.recover(signature);
        
        _rejectTransaction(transactionId, opSigner);
    }

     
     
    function _executeTransaction(uint transactionId, address owner)
        internal
        ownerExists(owner)
        approved(transactionId, owner)
        notExecuted(transactionId)
    {
        if (isApproved(transactionId)) {
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

     
     
    function executeTransaction(uint transactionId, bytes signature)
        public
    {
        bytes32 opHash = keccak256(abi.encodePacked(transactionId));
        address opSigner = opHash.recover(signature);
        
        _executeTransaction(transactionId, opSigner);
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

     
     
     
    function isApproved(uint transactionId)
        public
        view
        returns (bool)
    {
        uint count = 0;
        for (uint i = 0; i < owners.length; i++) {
            if (approvals[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

     
     
     
     
     
     
    function addTransaction(address destination, uint value, bytes data, bytes reasonHash, uint trackingId)
        internal
        notNull(destination)
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            reasonHash: reasonHash,
            executed: false
        });
        transactionCount += 1;
        emit Submission(transactionId, trackingId);
    }

     
     
     
     
    function getApprovalCount(uint transactionId)
        public
        view
        returns (uint count)
    {
        for (uint i = 0; i < owners.length; i++)
            if (approvals[transactionId][owners[i]]) count += 1;
    }

     
     
     
    function getRejectionCount(uint transactionId)
        public
        view
        returns (uint count)
    {
        for (uint i = 0; i < owners.length; i++)
            if (rejections[transactionId][owners[i]]) count += 1;
    }

     
     
     
     
    function getTransactionCount(bool pending, bool executed)
        public
        view
        returns (uint count)
    {
        for (uint i = 0; i < transactionCount; i++)
            if (pending && !transactions[i].executed ||
            executed && transactions[i].executed) count += 1;
    }

     
     
    function getOwners()
        public
        view
        returns (address[])
    {
        return owners;
    }

     
     
     
    function getApprovals(uint transactionId)
        public
        view
        returns (address[] _approvals)
    {
        address[] memory approvalsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i = 0; i < owners.length; i++)
            if (approvals[transactionId][owners[i]]) {
                approvalsTemp[count] = owners[i];
                count += 1;
            }
        _approvals = new address[](count);
        for (i = 0; i < count; i++)
            _approvals[i] = approvalsTemp[i];
    }

     
     
     
    function getRejections(uint transactionId)
        public
        view
        returns (address[] _rejections)
    {
        address[] memory rejectionsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i = 0; i < owners.length; i++)
            if (rejections[transactionId][owners[i]]) {
                rejectionsTemp[count] = owners[i];
                count += 1;
            }
        _rejections = new address[](count);
        for (i = 0; i < count; i++)
            _rejections[i] = rejectionsTemp[i];
    }

     
     
     
     
     
     
    function getTransactionIds(uint from, uint to, bool pending, bool executed)
        public
        view
        returns (uint[] _transactionIds)
    {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i = 0; i < transactionCount; i++)
            if (pending && !transactions[i].executed ||
                executed && transactions[i].executed)
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i = from; i < to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
}