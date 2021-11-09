pragma solidity ^0.5.17;

contract remoteConfiguration
{
    
     
     
    address public manufacturer;
    
     
    struct info {
        address owner;
         
        uint256 configurations0;
        uint256 configurations1;
        uint256 configurations2;
    }
    
     
     
    mapping (uint => info) public idInfo;
    
    uint256 currentConfig;
    uint256 configStartTime;
    uint256 configPeriod;
    bool tempUpdated;
    uint256 lastTempUpdate;

    modifier onlyManufacturer()
    {
        require(
            msg.sender == manufacturer,
            "Only the mamanufacturer can register a new device."
        );
        _;
    }
    
    constructor() public payable 
    {
        manufacturer = msg.sender;
         
         
         
         
    }

    function registerDevice(uint _identifier, uint256 config0, uint256 config1, uint256 config2) public payable onlyManufacturer {
        idInfo[_identifier].owner = msg.sender;
        idInfo[_identifier].configurations0 = config0;  
        idInfo[_identifier].configurations1 = config1;
        idInfo[_identifier].configurations2 = config2;
    }
    
    function transferOwnership(uint _identifier, address buyer) public {
		require(
            msg.sender == idInfo[_identifier].owner,
            "Only the device owner can transfer the ownership."
        );
        idInfo[_identifier].owner = buyer;
        
    }
    
    function upgradeConfiguration(uint _identifier, uint256 requestedConfig, uint256 configTimer) public payable 
    {
        require(
            msg.sender == idInfo[_identifier].owner,
            "Only the device owner can request for configuration upgrade."
        );
        
        if( requestedConfig == 1 ){
            if (msg.value < 10 szabo){ 
                revert(); 
            } else {
                currentConfig = idInfo[_identifier].configurations1;
            }
        } else if( requestedConfig == 2 ){
            if (msg.value < 20 szabo){ 
                revert(); 
            } else {
                currentConfig = idInfo[_identifier].configurations2;
            }
        } else {
            revert();
        }
        configStartTime = block.timestamp;
        configPeriod = configTimer;
    }
    
        
    function queryConfiguration() public view returns (uint256, uint256)
    {
        if (block.timestamp - configStartTime < configPeriod) {
            return (currentConfig, configPeriod);
        } else {
            revert();
        }
    }
    
    function transferContractValue () public payable onlyManufacturer {
        uint256 transferAmount = address(this).balance - 1 finney;
        address(msg.sender).transfer(transferAmount);
    }
}