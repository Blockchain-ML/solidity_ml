pragma solidity ^0.4.17;


 
 
library Helpers {
     
    function addressArrayContains(address[] array, address value) internal pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) {
                return true;
            }
        }
        return false;
    }

     
     
    function uintToString(uint256 inputValue) internal pure returns (string) {
         
        uint256 length = 0;
        uint256 currentValue = inputValue;
        do {
            length++;
            currentValue /= 10;
        } while (currentValue != 0);
         
        bytes memory result = new bytes(length);
         
        uint256 i = length - 1;
        currentValue = inputValue;
        do {
            result[i--] = byte(48 + currentValue % 10);
            currentValue /= 10;
        } while (currentValue != 0);
        return string(result);
    }

     
     
     
     
    function hasEnoughValidSignatures(bytes message, uint8[] vs, bytes32[] rs, bytes32[] ss, address[] allowed_signers, uint256 requiredSignatures) internal pure returns (bool) {
         
        if (vs.length < requiredSignatures) {
            return false;
        }

        var hash = MessageSigning.hashMessage(message);
        var encountered_addresses = new address[](allowed_signers.length);

        for (uint256 i = 0; i < requiredSignatures; i++) {
            var recovered_address = ecrecover(hash, vs[i], rs[i], ss[i]);
             
            if (!addressArrayContains(allowed_signers, recovered_address)) {
                return false;
            }
             
            if (addressArrayContains(encountered_addresses, recovered_address)) {
                return false;
            }
            encountered_addresses[i] = recovered_address;
        }
        return true;
    }

}


 
library HelpersTest {
    function addressArrayContains(address[] array, address value) public pure returns (bool) {
        return Helpers.addressArrayContains(array, value);
    }

    function uintToString(uint256 inputValue) public pure returns (string str) {
        return Helpers.uintToString(inputValue);
    }

    function hasEnoughValidSignatures(bytes message, uint8[] vs, bytes32[] rs, bytes32[] ss, address[] addresses, uint256 requiredSignatures) public pure returns (bool) {
        return Helpers.hasEnoughValidSignatures(message, vs, rs, ss, addresses, requiredSignatures);
    }
}


 
 
library MessageSigning {
    function recoverAddressFromSignedMessage(bytes signature, bytes message) internal pure returns (address) {
        require(signature.length == 65);
        bytes32 r;
        bytes32 s;
        bytes1 v;
         
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := mload(add(signature, 0x60))
        }
        return ecrecover(hashMessage(message), uint8(v), r, s);
    }

    function hashMessage(bytes message) internal pure returns (bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        return keccak256(prefix, Helpers.uintToString(message.length), message);
    }
}


 
library MessageSigningTest {
    function recoverAddressFromSignedMessage(bytes signature, bytes message) public pure returns (address) {
        return MessageSigning.recoverAddressFromSignedMessage(signature, message);
    }
}


library Message {
     
     
     
     
     
     

     
     
     
     
     
     
     
     
     
     

    function getRecipient(bytes message) internal pure returns (address) {
        address recipient;
         
        assembly {
            recipient := mload(add(message, 20))
        }
        return recipient;
    }

    function getValue(bytes message) internal pure returns (uint256) {
        uint256 value;
         
        assembly {
            value := mload(add(message, 52))
        }
        return value;
    }

    function getTransactionHash(bytes message) internal pure returns (bytes32) {
        bytes32 hash;
         
        assembly {
            hash := mload(add(message, 84))
        }
        return hash;
    }

    function getHomeGasPrice(bytes message) internal pure returns (uint256) {
        uint256 gasPrice;
         
        assembly {
            gasPrice := mload(add(message, 116))
        }
        return gasPrice;
    }
}


 
library MessageTest {
    function getRecipient(bytes message) public pure returns (address) {
        return Message.getRecipient(message);
    }

    function getValue(bytes message) public pure returns (uint256) {
        return Message.getValue(message);
    }

    function getTransactionHash(bytes message) public pure returns (bytes32) {
        return Message.getTransactionHash(message);
    }

    function getHomeGasPrice(bytes message) public pure returns (uint256) {
        return Message.getHomeGasPrice(message);
    }
}


contract HomeBridge {
     
     
     
    uint256 public requiredSignatures;

     
     
     
     
     
    uint256 public estimatedGasCostOfWithdraw;

     
     
     
     
     
    uint256 public maxTotalHomeContractBalance;

     
     
     
    uint256 public maxSingleDepositValue;

     
    address[] public authorities;

     
    mapping (bytes32 => bool) withdraws;

     
    event Deposit (address recipient, uint256 value);

     
    event Withdraw (address recipient, uint256 value, bytes32 transactionHash);

     
    function HomeBridge(
        uint256 requiredSignaturesParam,
        address[] authoritiesParam,
        uint256 estimatedGasCostOfWithdrawParam,
        uint256 maxTotalHomeContractBalanceParam,
        uint256 maxSingleDepositValueParam
    ) public
    {
        require(requiredSignaturesParam != 0);
        require(requiredSignaturesParam <= authoritiesParam.length);
        requiredSignatures = requiredSignaturesParam;
        authorities = authoritiesParam;
        estimatedGasCostOfWithdraw = estimatedGasCostOfWithdrawParam;
        maxTotalHomeContractBalance = maxTotalHomeContractBalanceParam;
        maxSingleDepositValue = maxSingleDepositValueParam;
    }

     
    function () public payable {
        require(maxSingleDepositValue == 0 || msg.value <= maxSingleDepositValue);
         
         
        require(maxTotalHomeContractBalance == 0 || this.balance <= maxTotalHomeContractBalance);
        Deposit(msg.sender, msg.value);
    }

     
     
     
     
     

     
     
     
     
     
    function withdraw(uint8[] vs, bytes32[] rs, bytes32[] ss, bytes message) public {
        require(message.length == 116);

         
        require(Helpers.hasEnoughValidSignatures(message, vs, rs, ss, authorities, requiredSignatures));

        address recipient = Message.getRecipient(message);
        uint256 value = Message.getValue(message);
        bytes32 hash = Message.getTransactionHash(message);
        uint256 homeGasPrice = Message.getHomeGasPrice(message);

         
         
         
         
         
         
         
         
        require((recipient == msg.sender) || (tx.gasprice == homeGasPrice));

         
         
        require(!withdraws[hash]);
         
        withdraws[hash] = true;

        uint256 estimatedWeiCostOfWithdraw = estimatedGasCostOfWithdraw * homeGasPrice;

         
        uint256 valueRemainingAfterSubtractingCost = value - estimatedWeiCostOfWithdraw;

         
        recipient.transfer(valueRemainingAfterSubtractingCost);

         
        msg.sender.transfer(estimatedWeiCostOfWithdraw);

        Withdraw(recipient, valueRemainingAfterSubtractingCost, hash);
    }
}


contract ForeignBridge {
     
     

    uint256 public totalSupply;

    string public name = "ForeignBridge";
     
    string public symbol = "BETH";
     
    uint8 public decimals = 18;

     
    mapping (address => uint256) public balances;

     
    mapping(address => mapping (address => uint256)) allowed;

     
    event Transfer(address indexed from, address indexed to, uint256 tokens);

     
    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }

     
     
     
     
    function transfer(address recipient, uint256 tokens) public returns (bool) {
        require(balances[msg.sender] >= tokens);
         
        require(balances[recipient] + tokens >= balances[recipient]);

        balances[msg.sender] -= tokens;
        balances[recipient] += tokens;
        Transfer(msg.sender, recipient, tokens);
        return true;
    }

     
     
     

     
     
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

     
     
    function approve(address spender, uint256 tokens) public returns (bool) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }

     
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool) {
         
        require(balances[from] >= tokens);
         
        require(allowed[from][msg.sender] >= tokens);
         
        require(balances[to] + tokens >= balances[to]);

        balances[to] += tokens;
        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;

        Transfer(from, to, tokens);
        return true;
    }

     
     
     

    struct SignaturesCollection {
         
        bytes message;
         
        address[] signed;
         
        bytes[] signatures;
    }

     
     
     
    uint256 public requiredSignatures;

    uint256 public estimatedGasCostOfWithdraw;

     
    address[] public authorities;

     
    mapping (bytes32 => address[]) deposits;

     
    mapping (bytes32 => SignaturesCollection) signatures;

     
    event DepositConfirmation(address recipient, uint256 value, bytes32 transactionHash);

     
    event Deposit(address recipient, uint256 value, bytes32 transactionHash);

     
    event Withdraw(address recipient, uint256 value, uint256 homeGasPrice);

    event WithdrawSignatureSubmitted(bytes32 messageHash);

     
    event CollectedSignatures(address authorityResponsibleForRelay, bytes32 messageHash);

    function ForeignBridge(
        uint256 _requiredSignatures,
        address[] _authorities,
        uint256 _estimatedGasCostOfWithdraw
    ) public
    {
        require(_requiredSignatures != 0);
        require(_requiredSignatures <= _authorities.length);
        requiredSignatures = _requiredSignatures;
        authorities = _authorities;
        estimatedGasCostOfWithdraw = _estimatedGasCostOfWithdraw;
    }

     
    modifier onlyAuthority() {
        require(Helpers.addressArrayContains(authorities, msg.sender));
        _;
    }

     
     
     
     
     
    function deposit(address recipient, uint256 value, bytes32 transactionHash) public onlyAuthority() {
         
        var hash = keccak256(recipient, value, transactionHash);

         
        require(!Helpers.addressArrayContains(deposits[hash], msg.sender));

        deposits[hash].push(msg.sender);

         
        if (deposits[hash].length != requiredSignatures) {
            DepositConfirmation(recipient, value, transactionHash);
            return;
        }

        balances[recipient] += value;
         
        totalSupply += value;
         
         
         
        Transfer(0x0, recipient, value);
        Deposit(recipient, value, transactionHash);
    }

     
     
     
     
     
     
     
     
     
    function transferHomeViaRelay(address recipient, uint256 value, uint256 homeGasPrice) public {
        require(balances[msg.sender] >= value);
         
        require(value > 0);

        uint256 estimatedWeiCostOfWithdraw = estimatedGasCostOfWithdraw * homeGasPrice;
        require(value > estimatedWeiCostOfWithdraw);

        balances[msg.sender] -= value;
         
        totalSupply -= value;
         
         
         
        Transfer(msg.sender, 0x0, value);
        Withdraw(recipient, value, homeGasPrice);
    }

     
     
     
     
     
     
     
     
    function submitSignature(bytes signature, bytes message) public onlyAuthority() {
         
        require(msg.sender == MessageSigning.recoverAddressFromSignedMessage(signature, message));

        require(message.length == 116);
        var hash = keccak256(message);

         
        require(!Helpers.addressArrayContains(signatures[hash].signed, msg.sender));
        signatures[hash].message = message;
        signatures[hash].signed.push(msg.sender);
        signatures[hash].signatures.push(signature);

         
        if (signatures[hash].signed.length == requiredSignatures) {
            CollectedSignatures(msg.sender, hash);
        } else {
            WithdrawSignatureSubmitted(hash);
        }
    }

     
    function signature(bytes32 hash, uint256 index) public view returns (bytes) {
        return signatures[hash].signatures[index];
    }

     
    function message(bytes32 hash) public view returns (bytes) {
        return signatures[hash].message;
    }
}