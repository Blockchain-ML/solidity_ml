pragma solidity ^0.4.16;

 
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


contract FDDP_DepositToken_5 {
    
    using SafeMath for uint;
    
	string public constant name = "FDDP - Deposit Token 5%";
	
	string public constant symbol = "DT5";
	
	uint32 public constant decimals = 15;
    
    uint _money = 0;
    uint _tokens = 0;
    uint _sellprice;
    uint contractBalance;
    
     
    address theStocksTokenContract;
    
     
    
    mapping (address => uint) balances;
    
    event OperationEvent(bytes32 status, uint sellprice, uint time);
    event Transfer(address indexed from, address indexed to, uint256 value);
     
    constructor (address _tstc) public {
        uint s = 10**15;
        _sellprice = s.mul(95).div(100);
        theStocksTokenContract = _tstc;
        
         
        address _this = this; 
        uint _value = 10**15; 
        
        _tokens += _value;
        balances[_this] += _value;
    }
    function totalSuply () public constant returns (uint256 tokens) {
        return _tokens;
    }
   
    function getTheStocksTokens () public constant returns (address stAddress) {
        return theStocksTokenContract;
    }
     
    function balanceOf(address addr) public constant returns(uint){
        return balances[addr];
    }
     
    function transfer(address _to, uint256 _value) public returns (bool success) {
        address addressContract = this;
        require(_to == addressContract);
        sell(_value);
        emit Transfer(msg.sender, _to, _value);
        success = true;
    }
     
    function buy() public payable {
        uint _value = msg.value.mul(10**15).div(_sellprice.mul(100).div(95));
        _money += msg.value.mul(975).div(1000);
        
        theStocksTokenContract.call.value(msg.value.mul(25).div(1000)).gas(53000)();  
        
        _tokens += _value;
        balances[msg.sender] += _value;
        _sellprice = _money.mul(10**15).mul(99).div(_tokens).div(100);
        emit OperationEvent("buy", _sellprice, now);
    }
     
    function () external payable {
        buy();
    }
     
    function sell (uint256 countTokens) public {
        require(balances[msg.sender] - countTokens >= 0);
        uint _value = countTokens.mul(_sellprice).div(10**15);
        _money -= _value;
        _tokens -= countTokens;
        balances[msg.sender] -= countTokens;
        if(_tokens > 0) {
            _sellprice = _money.mul(10**15).mul(99).div(_tokens).div(100);
        }
        msg.sender.transfer(_value);
        emit OperationEvent("sell", _sellprice, now);
    }
     
    function getPrice() public constant returns (uint bid, uint ask) {
        bid = _sellprice.mul(100).div(95);
        ask = _sellprice;
    }
}