pragma solidity ^0.4.24;

 

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}    

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns(bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

contract airdrop is owned{
    
 
    address public tokenAddress = 0xd58cb0c288358D139550fB39a6938Ec05C562f5a;
    
    mapping (address => uint) public readyTime;
    uint public amount = 100*100;
    uint public cooldown = 300;

 
    function set_amount(uint new_amount)onlyOwner{
        amount = new_amount*100;
    }
    
    function set_address(address new_address)onlyOwner{
        tokenAddress = new_address;
    }
    
    function set_cooldown(uint new_cooldown)onlyOwner{
        cooldown = new_cooldown;
    }
    
    function withdraw(uint _amount)onlyOwner{
        require(ERC20Basic(tokenAddress).transfer(owner, _amount*100));
    }
    
 
    function (){
        get_token();
    }
    
    function get_token(){
        require(readyTime[msg.sender] < now);
        readyTime[msg.sender] = now + cooldown;
        require(ERC20Basic(tokenAddress).transfer(msg.sender, amount));
    }
    function view_readyTime() view public returns(uint _readyTime){
        return readyTime[msg.sender];
    }
    
}