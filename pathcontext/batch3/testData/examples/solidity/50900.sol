pragma solidity ^0.4.25;

 


contract Allowance{
    address public owner;
    address ledger;
    uint AllowanceDay = 10000000000000000 wei;
    uint dayCooldown;
    uint _Amount;
    uint64 coolDownTime = 86400 seconds;
    mapping(address => bool) public whitelist;
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

   function deposit(uint256 _Amount) public payable {
        require(msg.value == _Amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
   
  modifier onlyWhitelisted() {
    require(whitelist[msg.sender]);
    _;
  }

  function Ownable() {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

 
   
  function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
    if (!whitelist[addr]) {
      whitelist[addr] = true;
      WhitelistedAddressAdded(addr);
      success = true; 
    }
  }

   
  function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (addAddressToWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

   
  function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
    if (whitelist[addr]) {
      whitelist[addr] = false;
      WhitelistedAddressRemoved(addr);
      success = true;
    }
  }

   
  function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (removeAddressFromWhitelist(addrs[i])) {
        success = true;
      }
    }
  }


    function _triggerCooldown() public onlyOwner{
      dayCooldown = now + coolDownTime;
    }

     
    function withdrawAll() external onlyOwner{
        require(address(this).balance > 0);
        owner.transfer(address(this).balance);
    }

     
     
    function withdrawOwner(uint _Amount) external payable onlyWhitelisted{
          ledger.transfer(_Amount);
    }

     
    function withdraw(uint _Amount) public{
          require(now >= dayCooldown && address(this).balance >= AllowanceDay);
          ledger.transfer(_Amount);

           
          AllowanceDay = _Amount - AllowanceDay;
         
           
          if(AllowanceDay == 0){
            _triggerCooldown();  
          }
  }

     
    function _setAllowance(uint _Allowance) external onlyOwner{ 
          AllowanceDay = _Allowance;
    }

     
    function _changeAddress(address _Address) public onlyOwner{
        removeAddressFromWhitelist(ledger);
        ledger = _Address;
        addAddressToWhitelist(ledger);
  }


     
    function killAllowanceContract() external onlyOwner returns (bool) {
        selfdestruct(owner);
        return true;
    }
}