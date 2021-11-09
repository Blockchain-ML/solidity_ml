pragma solidity ^0.4.22;

  
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        uint256 c = a / b;
         
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
 
  
contract ERC223 {
  using SafeMath for uint256;
  uint public totalSupply;
  uint public hardCap;
  function balanceOf(address who) public view returns (uint);
  function transfer(address to, uint value) public returns (bool ok);
  function transfer(address to, uint value, bytes data) public returns (bool ok);

   
  event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC223ReceivingContract {

     
     
     
     
    function tokenFallback(address _from, uint256 _value, bytes _data) public;
    
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

contract MintableToken is ERC223, Ownable {

    uint256 public hardCap;
    mapping(address => uint256) public balances;

    event Mint(address indexed to, uint256 amount);

    modifier canMint() {
        require(totalSupply < hardCap);
        _;
    }

     
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        require(_amount < hardCap);
        require(_amount > 0);
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(0x0, _to, _amount);
        return true;
    }
}

contract Token is MintableToken,ERC223ReceivingContract{
    string public name;
    string public symbol;
    uint256 public decimals;
    bool public canChangeHardCap;

    constructor() public {
        name = "XXXxxxXXX";
        symbol = "XXX";
        decimals = 9;
        hardCap = 20000000000000;
        canChangeHardCap = true;
    }
    
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        bytes memory empty;
        require(_to != address(0));
        require(_value <= balanceOf(msg.sender));
        require(_value > 0);
        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);
        if (isContract(_to)){
            ERC223ReceivingContract recieve = ERC223ReceivingContract(_to);
            recieve.tokenFallback(msg.sender, _value,  empty);
           }
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
        require(_to != address(0));
        require(_value <= balanceOf(msg.sender));
        require(_value > 0);
        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);
        if (isContract(_to)){
            ERC223ReceivingContract recieve = ERC223ReceivingContract(_to);
            recieve.tokenFallback(msg.sender, _value,  _data);
           }
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
   function transferFrom(address _from, address _to, uint256 _value) onlyOwner public returns (bool success) {
        require(_value > 0);
        if (balances[msg.sender] >= _value){
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            emit Transfer(msg.sender, _to, _value);
        }else{
            require(_value <= balanceOf(_from));
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            emit Transfer(_from, _to, _value);
        }
        return true;
    }
    
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
             
            length := extcodesize(_addr)
        }
        return (length > 0);
    }
    
     
    function changeHardCap(uint256 amount) onlyOwner public {
        require(canChangeHardCap);
        require(amount >totalSupply);
        hardCap = amount;
    }
    
    function tokenFallback(address _from, uint256 _value, bytes _data) public{
        ERC223 erc223 = ERC223(msg.sender);
        erc223.transfer(_from,_value);
    }
    

    
}