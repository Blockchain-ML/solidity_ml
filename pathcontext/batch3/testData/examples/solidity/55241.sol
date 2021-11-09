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

     
    event TeamCreated(address[] owners, address contractAddress, uint id);
    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);

     
    uint constant public MAX_OWNER_COUNT = 50;

     
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    uint public required;
    uint public transactionCount;
    uint public id;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bytes reason;
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

    modifier confirmed(uint transactionId, address owner) {
        require(confirmations[transactionId][owner], "Transaction was not confirmed");
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner], "Transaction was confirmed");
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

     
     
     
     
    constructor(address[] _owners, uint _required, uint _id)
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

     
     
    function addOwner(address owner)
        public
        onlyWallet
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

     
     
     
    function replaceOwner(address owner, address newOwner)
        public
        onlyWallet
        ownerExists(owner)
        ownerDoesNotExist(newOwner)
    {
        for (uint i = 0; i < owners.length; i++)
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
        onlyWallet
        validRequirement(owners.length, _required)
    {
        required = _required;
        emit RequirementChange(_required);
    }

     
     
     
     
     
     
    function _submitTransaction(address destination, uint value, bytes data, bytes reason, address owner)
        internal
        returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data, reason);
        _confirmTransaction(transactionId, owner);
    }

     
     
     
     
     
     
    function submitTransaction(address destination, uint value, bytes data, bytes reason, bytes signature)
        public
        returns (uint transactionId)
    {
        bytes32 opHash = keccak256(abi.encodePacked(destination, value, data, reason));
        address opSigner = opHash.recover(signature);
        
        transactionId = _submitTransaction(destination, value, data, reason, opSigner);
    }

     
     
    function _confirmTransaction(uint transactionId, address owner)
        internal
        ownerExists(owner)
        transactionExists(transactionId)
        notConfirmed(transactionId, owner)
    {
        confirmations[transactionId][owner] = true;
        emit Confirmation(owner, transactionId);
        _executeTransaction(transactionId, owner);
    }

     
     
    function confirmTransaction(uint transactionId, bytes signature)
        public
    {
        bytes32 opHash = keccak256(abi.encodePacked(transactionId));
        address opSigner = opHash.recover(signature);
        
        _confirmTransaction(transactionId, opSigner);
    }

     
     
    function _revokeConfirmation(uint transactionId, address owner)
        internal
        ownerExists(owner)
        confirmed(transactionId, owner)
        notExecuted(transactionId)
    {
        confirmations[transactionId][owner] = false;
        emit Revocation(owner, transactionId);
    }

     
     
    function revokeConfirmation(uint transactionId, bytes signature)
        public
    {
        bytes32 opHash = keccak256(abi.encodePacked(transactionId));
        address opSigner = opHash.recover(signature);
        
        _revokeConfirmation(transactionId, opSigner);
    }

     
     
    function _executeTransaction(uint transactionId, address owner)
        internal
        ownerExists(owner)
        confirmed(transactionId, owner)
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

     
     
     
    function isConfirmed(uint transactionId)
        public
        view
        returns (bool)
    {
        uint count = 0;
        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

     
     
     
     
     
     
    function addTransaction(address destination, uint value, bytes data, bytes reason)
        internal
        notNull(destination)
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            reason: reason,
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
        for (uint i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) count += 1;
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

     
     
     
    function getConfirmations(uint transactionId)
        public
        view
        returns (address[] _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++)
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