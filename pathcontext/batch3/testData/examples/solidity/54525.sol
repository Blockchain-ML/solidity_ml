pragma solidity 0.4.25;

interface ERC20CompatibleToken {
    function transfer (address to, uint tokens) external returns (bool success);
    function transferFrom (address from, address to, uint tokens) external returns (bool success);
}

contract RecurringBillingContractFactory {

    event NewRecurringBillingContractCreated(address token, address recurringBillingContract);

    function newRecurringBillingContract (address tokenAddress) public returns (address recurringBillingContractAddress) {
        TokenRecurringBilling rb = new TokenRecurringBilling(tokenAddress);
        emit NewRecurringBillingContractCreated(tokenAddress, rb);
        return rb;
    }

}

 
contract TokenRecurringBilling {

    event BillingAllowed(uint256 indexed billingId, address customer, uint256 merchantId, uint256 timestamp, uint256 period, uint256 value);
    event BillingCharged(uint256 indexed billingId, uint256 timestamp, uint256 nextChargeTimestamp);
    event BillingCanceled(uint256 indexed billingId);
    event MerchantRegistered(uint256 indexed merchantId, address merchantAccount, address beneficiaryAddress);
    event MerchantAccountChanged(uint256 indexed merchantId, address merchantAccount);
    event MerchantBeneficiaryAddressChanged(uint256 indexed merchantId, address beneficiaryAddress);
    event MerchantChargingAccountAllowed(uint256 indexed merchantId, address chargingAccount, bool allowed);

    struct BillingRecord {
        address customer;  
        uint256 metadata;  
                           
                           
                           
                           
    }

    struct Merchant {
        address merchant;     
        address beneficiary;  
    }

    uint256 lastRecurringBillingId;  
    uint256 lastMerchantId;          
    ERC20CompatibleToken token;      

    mapping(uint256 => BillingRecord) public billingRegistry;                            
    mapping(uint256 => Merchant) public merchantRegistry;                                
    mapping(uint256 => mapping(address => bool)) public merchantChargingAccountAllowed;  

     
    modifier isMerchant (uint256 merchantId) {
        require(merchantRegistry[merchantId].merchant == msg.sender, "Sender is not a merchant");
        _;
    }

     
    modifier isCustomer (uint256 billingId) {
        require(billingRegistry[billingId].customer == msg.sender, "Sender is not a customer");
        _;
    }

     
    modifier tokenOnly () {
        require(msg.sender == address(token), "Sender is not a token");
        _;
    }

     

     
    constructor (address tokenAddress) public {
        token = ERC20CompatibleToken(tokenAddress);
    }

     

     
    function allowRecurringBilling (uint256 billingId, uint256 merchantId, uint256 value, uint256 period) public {
        allowRecurringBillingInternal(msg.sender, merchantId, billingId, value, period);
    }

     
    function registerNewMerchant (address beneficiary, address chargingAccount) public returns (uint256 merchantId) {

        merchantId = ++lastMerchantId;
        Merchant storage record = merchantRegistry[merchantId];
        record.merchant = msg.sender;
        record.beneficiary = beneficiary;
        emit MerchantRegistered(merchantId, msg.sender, beneficiary);

        changeMerchantChargingAccount(merchantId, chargingAccount, true);

    }

     

     
    function cancelRecurringBilling (uint256 billingId) public isCustomer(billingId) {
        cancelRecurringBillingInternal(billingId);
    }

     
    function charge (uint256 billingId) public {

        BillingRecord storage billingRecord = billingRegistry[billingId];
        (uint256 value, uint256 lastChargeAt, uint256 merchantId, uint256 period) = decodeBillingMetadata(billingRecord.metadata);

        require(merchantChargingAccountAllowed[merchantId][msg.sender], "Sender is not allowed to charge");
        require(merchantId != 0, "Billing does not exist");
        require(lastChargeAt + period <= now, "Charged too early");

        if (now > lastChargeAt + period * 2) {  
            cancelRecurringBillingInternal(billingId);
            return;
        }

        require(token.transferFrom(billingRecord.customer, address(this), value), "Unable to charge customer");
        require(token.transfer(merchantRegistry[merchantId].beneficiary, value), "Unable to withdraw tokens");

        billingRecord.metadata = encodeBillingMetadata(value, lastChargeAt + period, merchantId, period);

        emit BillingCharged(billingId, now, lastChargeAt + period * 2);

    }

     
    function receiveApproval (address sender, uint, address, bytes data) external tokenOnly {

         
        require(data.length == 64, "Invalid data length");

        (uint256 value,  , uint256 merchantId, uint256 period) = decodeBillingMetadata(bytesToUint256(data, 0));
        uint256 billingId = bytesToUint256(data, 32);

        if (billingRegistry[billingId].customer == 0x0) {  
            allowRecurringBillingInternal(sender, merchantId, billingId, value, period);
        } else if (billingRegistry[billingId].customer == sender) {  
            cancelRecurringBillingInternal(billingId);
        } else {
            revert("Given billingId exists and sender is not a customer");
        }

    }

     
    function changeMerchantAccount (uint256 merchantId, address newMerchantAccount) public isMerchant(merchantId) {
        merchantRegistry[merchantId].merchant = newMerchantAccount;
        emit MerchantAccountChanged(merchantId, newMerchantAccount);
    }

     
    function changeMerchantBeneficiaryAddress (uint256 merchantId, address newBeneficiaryAddress) public isMerchant(merchantId) {
        merchantRegistry[merchantId].beneficiary = newBeneficiaryAddress;
        emit MerchantBeneficiaryAddressChanged(merchantId, newBeneficiaryAddress);
    }

     
    function changeMerchantChargingAccount (uint256 merchantId, address account, bool allowed) public isMerchant(merchantId) {
        merchantChargingAccountAllowed[merchantId][account] = allowed;
        emit MerchantChargingAccountAllowed(merchantId, account, allowed);
    }

     

     
    function encodeBillingMetadata (
        uint256 value,
        uint256 lastChargeAt,
        uint256 merchantId,
        uint256 period
    ) public pure returns (uint256 result) {

        require(
            value < 2 ** 144
            && lastChargeAt < 2 ** 48
            && merchantId < 2 ** 32
            && period < 2 ** 32,
            "Invalid input sizes to encode"
        );

        result = value;
        result |= lastChargeAt << (144);
        result |= merchantId << (144 + 48);
        result |= period << (144 + 48 + 32);

        return result;

    }

     
    function decodeBillingMetadata (uint256 encodedData) public pure returns (
        uint256 value,
        uint256 lastChargeAt,
        uint256 merchantId,
        uint256 period
    ) {
        value = uint144(encodedData);
        lastChargeAt = uint48(encodedData >> (144));
        merchantId = uint32(encodedData >> (144 + 48));
        period = uint32(encodedData >> (144 + 48 + 32));
    }

     

     
    function allowRecurringBillingInternal (
        address customer,
        uint256 merchantId,
        uint256 billingId,
        uint256 value,
        uint256 period
    ) internal {

        require(merchantId <= lastMerchantId && merchantId != 0, "Invalid merchant specified");
        require(period < now, "Invalid period specified");

        BillingRecord storage newRecurringBilling = billingRegistry[billingId];
        newRecurringBilling.metadata = encodeBillingMetadata(value, now - period, merchantId, period);
        newRecurringBilling.customer = customer;

        emit BillingAllowed(billingId, customer, merchantId, now, period, value);

    }

     
    function cancelRecurringBillingInternal (uint256 billingId) internal {
        delete billingRegistry[billingId];
        emit BillingCanceled(billingId);
    }

     
    function bytesToUint256(bytes memory input, uint offset) internal pure returns (uint256 output) {
        assembly { output := mload(add(add(input, 32), offset)) }
    }

}

 