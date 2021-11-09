pragma solidity ^0.4.24;

contract SmartSignDev002 {
     
    bool private deprecated;
    address private owner;
    struct signRegister{
        uint256 index;
        string dataHash;
        string csv;
        uint256 timestamp;
    }
    signRegister [] public tableRegisters;
    mapping(string => signRegister) private mappingSignRegister;
    string [] private hashIndex;
    constructor(){
        owner = msg.sender;
        deprecated = false;
    }
     
     
    modifier isOwner(address _sender){
        require(msg.sender == _sender,
        "sender not authorized"
            );
            _;
    }
    modifier isDeprecated(){
        require(deprecated == false,
        "contract deprecated");
        _;
    }
     
     
    function isRepeated(string dataHash) public constant returns(bool){
        if(hashIndex.length == 0) return false;
        return(keccak256(abi.encodePacked(hashIndex[mappingSignRegister[dataHash].index])) == keccak256(abi.encodePacked(dataHash)));
    }
     
     
    function setNewRegister(string _dataHash, string _csv, uint256 _timestamp)  
        isOwner(msg.sender) 
        isDeprecated() 
        public returns(string, string, uint256){
            
        if(isRepeated(_dataHash)) return ("Repeated", _csv, 0);
        
        signRegister memory newSignRegister;
        newSignRegister.dataHash = _dataHash;
        newSignRegister.csv = _csv;
        newSignRegister.timestamp = _timestamp;
        newSignRegister.index = hashIndex.push(_dataHash) - 1;
        
        tableRegisters.push(newSignRegister);
       return(_dataHash, _csv, _timestamp);
    }
     
     
    function getRegister(string dataHash, string csv) 
        isOwner(msg.sender)
        isDeprecated()
        public returns(string, string, uint256){
            if(!isRepeated(dataHash)) return ("Not found", "0", 0);
            return (
                mappingSignRegister[dataHash].dataHash,
                mappingSignRegister[dataHash].csv,
                mappingSignRegister[dataHash].timestamp);
        }
     
    
    function deprecate() 
        isOwner(msg.sender)
        public 
        returns(string){
            deprecated == true;
            return "Contract deprecated";
        }
    
}