pragma solidity ^0.4.24;

library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
     
     
     
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;
   
  constructor() public {
    owner = msg.sender;
  }
   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

}

contract Trazair is Ownable{

using SafeMath for uint256;

   
   
   
event Transfer(address indexed from, address indexed to, uint256 value);  

 mapping(address => uint256) balances;

 string public name = "Trazair";
 uint256 totalSupply_;
 uint256 public RATE = 1 ether;
 string public symbol = "TRZA";                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
 uint8 public decimals = 2;
 uint public INITIAL_SUPPLY = 50000000000;
 uint public totalSold_ = 0;

 constructor() public {
   totalSupply_ = INITIAL_SUPPLY;
   balances[msg.sender] = INITIAL_SUPPLY;
 }

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }


  function buy(address _address, uint256 quantity) public payable returns (bool) {
    uint256 _amount = msg.value;
    require(_amount > 0);
     

     
     

    totalSupply_ = totalSupply_.sub(quantity);
    balances[owner] = balances[owner].sub(quantity);
    balances[_address] = balances[_address].add(quantity);
    totalSold_ = totalSold_.add(quantity);
    return true;
  }

   
  function transfer(address _to, uint256 _value) public payable returns (bool) {
    require(_to != address(0));
    require(_value <= balances[owner]);
    balances[owner] = balances[owner].sub(_value);
    balances[_to] = balances[_to].add(_value);
    totalSold_ = totalSold_.add(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  function balanceEth(address _owner) public view returns (uint256) {
    return _owner.balance;
   }

  function change_rate(uint256 value) onlyOwner public{
    RATE = value*(1*10**18);
  }
}