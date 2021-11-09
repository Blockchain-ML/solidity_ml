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

    uint8 public decimals = 18;
    uint256 public hardCap;
    mapping(address => uint256) public balances;

    event Mint(address indexed to, uint256 amount);

    modifier canMint() {
        require(totalSupply < hardCap);
        _;
    }

     
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

        uint amount = _amount; 
        require(amount + totalSupply < hardCap);
        require(amount > 0);
        totalSupply = totalSupply.add(amount);
        balances[_to] = balances[_to].add(amount);
        emit Mint(_to, amount);
        emit Transfer(0x0, _to, amount);
        return true;
    }
}

contract BBB is MintableToken, ERC223ReceivingContract{
    string public name = "GTC_TEST_CONTRACT_0001";
    string public symbol  = "BBB";


    constructor() public {
        hardCap = 20000000000000000 * 10 ** uint256(decimals);
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

    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
         
            length := extcodesize(_addr)
        }
        return (length > 0);
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public{
        transfer(_from,_value,_data);
    }

     
     
     
     
     

}