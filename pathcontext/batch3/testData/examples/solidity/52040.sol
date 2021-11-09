pragma solidity ^0.4.21;

contract Ownable {
 
address public owner;

 
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

constructor() public {
owner = msg.sender;
}

 
modifier onlyOwner() {
require(msg.sender == owner);
_;
}

 
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}

contract NestEgg is Ownable {
 
string public userData;

 
address public lastDonator;

 
uint public price = 1;

 
bool public isPayed;

event Withdraw(address _from, address _to, uint256 _amount);

constructor() public {
    isPayed = false;
}

 
modifier onlyPayed(){
require(isPayed == true);
_;
}

 
function () external payable {
 
setValue();
}

 
function getCurrentAddress() public view returns (address){
return this;
}

 
function getCurrentBalance() public view returns (uint256){
return address(this).balance;
}

 
function setPrice(uint _price) external onlyOwner {
price = _price;
}

 
function setValue() internal {
lastDonator = msg.sender;
setSubscribe();
}

 
function setSubscribe() internal {
isPayed = true;
}

 
function setData(string _userData) public onlyOwner onlyPayed returns (bool){
userData = _userData;
return true;
}

 
function getData() public view returns(string){
return userData;
}

 
function ownerKill() public onlyOwner {
selfdestruct(owner);
}

 
function withdraw(address _to, uint256 _amount ) external onlyOwner {
require(address(this).balance >= _amount);
_to.transfer(_amount * 1 ether);
}

}