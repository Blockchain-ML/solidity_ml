pragma solidity ^0.4.25;

contract AccountMngmt {
    address public owner;
    uint public numAccts=0;
     
    struct Admin {address AdminAddr; uint Bal;}
    mapping (uint => Admin) public Accounts;
     
    struct UserStruct {uint AcctId; bool CanWrite;}
    mapping (address => UserStruct) public Users;
    
     
    
    constructor() public {
        owner = msg.sender;
    }
    function giveOwnership(uint _Acct, address _newowner) public {
         
        require(Accounts[_Acct].AdminAddr == msg.sender);
         
        Accounts[_Acct].AdminAddr = _newowner;
    }
    function approveViewer(uint _Acct, address _User) public {
         
        require(Accounts[_Acct].AdminAddr == msg.sender);
         
        Users[_User].AcctId = _Acct;
    }
    function approveWriter(uint _Acct, address _User) public {
         
        require(Accounts[_Acct].AdminAddr == msg.sender);
         
        Users[_User].AcctId = _Acct;
        Users[_User].CanWrite = true;
    }
    function deleteUser(uint _Acct, address _User) public {
         
        require(Accounts[_Acct].AdminAddr == msg.sender);
         
        delete Users[_User];
    }
    function disallowWrite(uint _Acct, address _User) public {
         
        require(Accounts[_Acct].AdminAddr == msg.sender);
         
        Users[_User].CanWrite = false;
    }
    function ownerWithdraw(uint _Amount) public{
        require(msg.sender == owner);
         
        msg.sender.transfer(_Amount);
         
    }
     
    function createAccount() public payable returns(uint){
         
        require(msg.value > 1 ether);  
         
        Accounts[numAccts].AdminAddr = msg.sender;
        Accounts[numAccts].Bal = 1;
         
        if (msg.value > 1 ether){
            msg.sender.transfer(msg.value-1 ether);  
        }
         
        numAccts++;
        return (numAccts-1);
         
    }
    function() payable external{
         
        revert();
    }
    
}