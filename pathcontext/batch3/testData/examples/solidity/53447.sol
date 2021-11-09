pragma solidity ^0.4.18;

 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  function Ownable() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
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

 
contract Contactable is Ownable {

  string public contactInformation;

   
  function setContactInformation(string info) onlyOwner public {
    contactInformation = info;
  }
}

 
contract Restricted is Ownable {

     
    event MonethaAddressSet(
        address _address,
        bool _isMonethaAddress
    );

    mapping (address => bool) public isMonethaAddress;

     
    modifier onlyMonetha() {
        require(isMonethaAddress[msg.sender]);
        _;
    }

     
    function setMonethaAddress(address _address, bool _isMonethaAddress) onlyOwner public {
        isMonethaAddress[_address] = _isMonethaAddress;

        emit MonethaAddressSet(_address, _isMonethaAddress);
    }
}
 
contract SafeDestructible is Ownable {
    function destroy() onlyOwner public {
        require(this.balance == 0);
        selfdestruct(owner);
    }
}


 

contract MerchantWallet is Pausable, SafeDestructible, Contactable, Restricted {

    string constant VERSION = "0.4";

     
    address public merchantAccount;

     
    address public merchantFundAddress;

     
    bytes32 public merchantIdHash;

     
    mapping (string=>string) profileMap;

     
    mapping (string=>string) paymentSettingsMap;

     
    mapping (string=>uint32) compositeReputationMap;

     
    uint8 public constant REPUTATION_DECIMALS = 4;

     
    modifier onlyMerchant() {
        require(msg.sender == merchantAccount);
        _;
    }

     
    modifier isEOA(address _fundAddress) {
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_fundAddress)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

     
    modifier onlyMerchantOrMonetha() {
        require(msg.sender == merchantAccount || isMonethaAddress[msg.sender]);
        _;
    }

     
    function MerchantWallet(address _merchantAccount, string _merchantId, address _fundAddress) public isEOA(_fundAddress) {
        require(_merchantAccount != 0x0);
        require(bytes(_merchantId).length > 0);

        merchantAccount = _merchantAccount;
        merchantIdHash = keccak256(_merchantId);

        merchantFundAddress = _fundAddress;
    }

     
    function () external payable {
    }

     
    function profile(string key) external constant returns (string) {
        return profileMap[key];
    }

     
    function paymentSettings(string key) external constant returns (string) {
        return paymentSettingsMap[key];
    }

     
    function compositeReputation(string key) external constant returns (uint32) {
        return compositeReputationMap[key];
    }

     
    function setProfile(
        string profileKey,
        string profileValue,
        string repKey,
        uint32 repValue
    ) external onlyOwner
    {
        profileMap[profileKey] = profileValue;

        if (bytes(repKey).length != 0) {
            compositeReputationMap[repKey] = repValue;
        }
    }

     
    function setPaymentSettings(string key, string value) external onlyOwner {
        paymentSettingsMap[key] = value;
    }

     
    function setCompositeReputation(string key, uint32 value) external onlyMonetha {
        compositeReputationMap[key] = value;
    }

     
    function doWithdrawal(address beneficiary, uint amount) private {
        require(beneficiary != 0x0);
        beneficiary.transfer(amount);
    }

     
    function withdrawTo(address beneficiary, uint amount) public onlyMerchant whenNotPaused {
        doWithdrawal(beneficiary, amount);
    }

     
    function withdraw(uint amount) external onlyMerchant {
        withdrawTo(msg.sender, amount);
    }

     
    function withdrawToExchange(address depositAccount, uint amount) external onlyMerchantOrMonetha whenNotPaused {
        doWithdrawal(depositAccount, amount);
    }

     
    function withdrawAllToExchange(address depositAccount, uint min_amount) external onlyMerchantOrMonetha whenNotPaused {
        require (address(this).balance >= min_amount);
        doWithdrawal(depositAccount, address(this).balance);
    }

     
    function changeMerchantAccount(address newAccount) external onlyMerchant whenNotPaused {
        merchantAccount = newAccount;
    }

     
    function changeFundAddress(address newFundAddress) external onlyMerchant isEOA(newFundAddress) {
        merchantFundAddress = newFundAddress;
    }
}