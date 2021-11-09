pragma solidity ^0.4.24;

contract FechHpbBallotAddr {
    
    address public contractAddr=0;
    
    string public funStr="0xc90189e4";
    
     
    uint public round = 0;
    
     
    address public owner;
    
     
    mapping (address => address) public adminMap;
    
    
    modifier onlyOwner{
        require(msg.sender == owner);
         
         
        _;
    }
	
    function transferOwnership(address newOwner) onlyOwner  public{
        owner = newOwner;
    }
   
    
    modifier onlyAdmin{
        require(adminMap[msg.sender] != 0);
        _;
    }
   
     
    function addAdmin(address addr) onlyOwner public{
        adminMap[addr] = addr;
    }
   
    
    function deleteAdmin(address addr) onlyOwner public{
        require(adminMap[addr] != 0);
        adminMap[addr]=0;
    }
   
    event SetContractAddr(address indexed from,address indexed _contractAddr);
    
    event SetFunStr(address indexed from,string indexed _funStr);
    
    event SetRound(uint indexed _round);
    
    constructor() public{
       owner = msg.sender;
        
	   adminMap[owner]=owner;
    }
    
    function setContractAddr(
        address _contractAddr
    ) onlyAdmin public{
        contractAddr=_contractAddr;
        emit SetContractAddr(msg.sender,_contractAddr);
    }
    
     
    function setRound(
        uint _round
    ) onlyAdmin public{
        round=_round;
        emit SetRound(_round);
    }
   
    
    function getRound(
    ) public constant returns(
        uint _round
    ){
        return round;
    }
     
    function getContractAddr(
    ) public constant returns(
        address _contractAddr
    ){
        return contractAddr;
    }
    
    function setFunStr(
        string _funStr
    ) onlyAdmin public{
        funStr=_funStr;
        emit SetFunStr(msg.sender,_funStr);
    }
    
     
    function getFunStr(
    ) public constant returns(
        string _funStr
    ){
        return funStr;
    }
}