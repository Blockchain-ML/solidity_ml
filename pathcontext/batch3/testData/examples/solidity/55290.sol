pragma solidity ^0.4.24;
 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
 
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
 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  
  struct Dividend {
    uint256 amount;
    uint256 claimed;
    mapping(address => uint256) claimed_balances;
    string message;
  }  
  
   
  Dividend[] public dividends;
  
   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    handle_dividend(msg.sender, _to);
    return true;
  }
  
   
  function handle_dividend(address _from, address _to) internal{
      if(dividends.length > 0){
          Dividend storage dividend = dividends[dividends.length.sub(1)];
          uint256 dividend_claimed_from = dividend.claimed_balances[_from];
          uint256 from_balance = balances[_from];
          uint256 dividend_claimed_to = dividend.claimed_balances[_to];
           
          if(dividend_claimed_from > 0){
               
              if(from_balance <  dividend_claimed_from){
                  uint256 token_claimed_dividend = dividend_claimed_from.sub(from_balance);
                   
                  dividend.claimed_balances[_to] = dividend_claimed_to.add(token_claimed_dividend);
                  dividend.claimed_balances[_from] = dividend_claimed_from.sub(token_claimed_dividend);
              }
          }
          
      }
  }
  
   
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
  
  function update_dividend(address wallet, uint256 dividend_index, uint256 token_paid, uint256 dividend_amount) internal {
      require(dividends.length > dividend_index);
      Dividend storage dividend = dividends[dividend_index];
      dividend.claimed_balances[wallet] = dividend.claimed_balances[wallet].add(token_paid) ;
      dividend.claimed = dividend.claimed.add(dividend_amount) ;
  }
}
 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) allowed;
   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    uint256 _allowance = allowed[_from][msg.sender];
     
     
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
    handle_dividend(_from, _to);
    return true;
  }
   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
   
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
   
  function increaseApproval (address _spender, uint _addedValue) public
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  function decreaseApproval (address _spender, uint _subtractedValue) public
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
  constructor() public{
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

contract IndexprotocolToken is StandardToken, Ownable {
  string public name = "Indexprotocol";
  string public symbol = "ETF100";
  uint256 public decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 20000000 * (10 ** uint256(18));
  
  struct Rate {
    uint256 current_rate;
    string remark;
    uint256 time;
  }
  
  Rate[] public rates;

  event Burn(address indexed owner, uint256 value);
  event DividendAdded(uint256 index, uint256 amount, string message);
  event DividendClaimed(uint256 dividend_index, uint256 eligible_token_count, uint256 amount);

   
  constructor() public{
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

  function burn(uint256 _value) public onlyOwner returns (bool) {
    require(balances[msg.sender] >= _value);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    emit Burn(msg.sender, _value);
    return true;
  }
  
   
  function pay_dividend(string message) payable public onlyOwner{
    uint256 amount = msg.value;
    Dividend memory dividend = Dividend({ amount: amount, claimed: 0, message: message });
    dividends.push(dividend);  
    emit DividendAdded(dividends.length.sub(1), amount, message);
  }
  
   
  function claim_devidend() public {
     
    require(dividends.length > 0);
    uint256 dividend_index = dividends.length.sub(1);
    claim_devidend_for(dividend_index);
  }
  
  
   
  function claim_devidend_for(uint256 dividend_index) internal {
    address sender_wallet = msg.sender;
    uint256 eligible_token_balance = calculate_eligible_token_balance(sender_wallet, dividend_index);
    uint256 dividend_amount = calculate_dividend(eligible_token_balance, dividend_index);
     
    update_dividend(sender_wallet, dividend_index, eligible_token_balance, dividend_amount);
     
    sender_wallet.transfer(dividend_amount);
    emit DividendClaimed(dividend_index, eligible_token_balance, dividend_amount);
  }
  
   
  function calculate_eligible_token_balance(address wallet, uint256 dividend_index) internal view returns(uint256){
     
    require(dividends.length > dividend_index);
    Dividend storage dividend = dividends[dividend_index];
    
    uint256 claimed_token_balance = dividend.claimed_balances[wallet];
    uint256 token_balance = balances[wallet];
     
    require(claimed_token_balance < token_balance);
    return token_balance.sub(claimed_token_balance);
   } 
  
   
  function calculate_dividend(uint256 eligible_token_balance, uint256 dividend_index) internal view returns(uint256){
     
    require(dividends.length > dividend_index);
    Dividend storage dividend = dividends[dividend_index];
    return dividend.amount.mul(eligible_token_balance).div(totalSupply);
  }
  
   
  function check_dividend(address wallet) public constant returns(uint256){
    require(dividends.length > 0);
    uint256 dividend_index = dividends.length.sub(1);
    uint256 eligible_token_balance = calculate_eligible_token_balance(wallet, dividend_index);
    return calculate_dividend(eligible_token_balance, dividend_index);
  }
  
  event WithdrawUnclaimedBalance(uint256 dividend_index, uint256 claimed_amount);
  
   
  function withdraw_unclaimed_balance(uint256 dividend_index) onlyOwner public {
      require(dividends.length > 0);
       
      require(dividends.length.sub(1) > dividend_index);
      Dividend storage dividend = dividends[dividend_index];
      uint256 unclaimed_balance = dividend.amount.sub(dividend.claimed);
      dividend.claimed = dividend.amount;
      owner.transfer(unclaimed_balance);
      emit WithdrawUnclaimedBalance(dividend_index, unclaimed_balance);
  }
  
   
  function update_current_rate(uint256 current_rate, string remark) public onlyOwner{
    Rate memory rate = Rate({current_rate: current_rate, remark: remark, time: now});
    rates.push(rate);
  }
  
}