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

  function subsafe(uint256 a, uint256 b) internal pure returns (uint256) {
    if(b <= a){
        return a - b;
    }else{
        return 0;
    }
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
}


contract FDDP_DepositToken_10 {
    
    using SafeMath for uint;
    
    string public constant name = "FDDP - Deposit Token 10%";
    
    string public constant symbol = "DT10";
    
    uint32 public constant decimals = 15;
    
    uint _money = 0;
    uint _tokens = 0;
    uint _sellprice;
    uint contractBalance;
    
     
    address theStocksTokenContract;
    
     
    
    mapping (address => uint) balances;
    
    event FullEventLog(
        bytes32 status,
        uint sellprice,
        uint buyprice, 
        uint time,
        uint tokens,
        uint ethers);
        
    event OperationEvent(
        bytes32 status, 
        uint sellprice, 
        uint time);
    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value);
        
     
    constructor (address _tstc) public {
        uint s = 10**15;
        _sellprice = s.mul(90).div(100);
        theStocksTokenContract = _tstc;
        
         
        
        address _this = this; 
        uint _value = 10**15; 
        
        _tokens += _value;
        balances[_this] += _value;
    }
    function totalSupply () public constant returns (uint256 tokens) {
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
    
     
    function () external payable {
        buy();
    }
    
     
    function buy() public payable {
        uint _value = msg.value.mul(10**15).div(_sellprice.mul(100).div(90));
        
         
        _money = _money.add(msg.value.mul(95).div(100));
        
         
        theStocksTokenContract.call.value(msg.value.mul(25).div(1000)).gas(53000)();  
        
         
        _tokens = _tokens.add(_value);
        
         
        balances[msg.sender] = balances[msg.sender].add(_value);
        
         
        emit FullEventLog("buy", _sellprice, _sellprice.mul(100).div(95), now, _value, msg.value);
        
        _sellprice = _money.mul(10**15).mul(98).div(_tokens).div(100);
        
        emit OperationEvent("buy", _sellprice, now);
        
        address addressContract = this;
        emit Transfer(addressContract, msg.sender, _value);
    }

     
    function sell (uint256 countTokens) public {
         
        require(balances[msg.sender] >= countTokens);
        
        uint _value = countTokens.mul(_sellprice).div(10**15);
        
        _money = _money.sub(_value);
        
        _tokens = _tokens.subsafe(countTokens);
        
        balances[msg.sender] = balances[msg.sender].subsafe(countTokens);
        
        emit FullEventLog("sell", _sellprice, _sellprice.mul(100).div(95), now, countTokens, _value);
        
        if(_tokens > 0) {
            _sellprice = _money.mul(10**15).mul(98).div(_tokens).div(100);
        }
        emit OperationEvent("sell", _sellprice, now);
        msg.sender.transfer(_value);
    }
     
    function getPrice() public constant returns (uint bid, uint ask) {
        bid = _sellprice.mul(100).div(90);
        ask = _sellprice;
    }
}