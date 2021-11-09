pragma solidity ^0.4.24;

 
 
 
 

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);

    
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract CryptosToken is ERC20Interface{
    string public name = "Cryptos";
    string public symbol = "CRPT";
    uint public decimals = 0;
    
    uint256 public supply;
    address public founder;
    
    mapping(address => uint) public balances;
    
    mapping(address => mapping(address => uint)) allowed;
    
     
    
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);


    constructor() public{
        supply = 300000;
        founder = msg.sender;
        balances[founder] = supply;
    }
    
    
    function allowance(address tokenOwner, address spender) view public returns(uint){
        return allowed[tokenOwner][spender];
    }
    
    
     
    function approve(address spender, uint tokens) public returns(bool){
        require(balances[msg.sender] >= tokens);
        require(tokens > 0);
        
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
     
    function transferFrom(address from, address to, uint tokens) public returns(bool){
        require(allowed[from][to] >= tokens);
        require(balances[from] >= tokens);
        
        balances[from] -= tokens;
        balances[to] += tokens;
        
        
        allowed[from][to] -= tokens;
        
        return true;
    }
    
    function totalSupply() public view returns (uint){
        return supply;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint balance){
         return balances[tokenOwner];
     }
     
     
    function transfer(address to, uint tokens) public returns (bool success){
         require(balances[msg.sender] >= tokens && tokens > 0);
         
         balances[to] += tokens;
         balances[msg.sender] -= tokens;
         emit Transfer(msg.sender, to, tokens);
         return true;
     }
}


contract CryptosICO is CryptosToken{
    address public admin;
    address public deposit;
    
     
    uint tokenPrice = 1000000000000000;
    
     
    uint public hardCap = 300000000000000000000;
    
    uint public raisedAmount;
    
    uint public saleStart = now;
    uint public saleEnd = now + 604800;
    uint public coinTradeStart = saleEnd + 604800; 
    
    uint public maxInvestment = 5000000000000000000;
    uint public minInvestment = 10000000000000000;
    
    enum State { beforeStart, running, afterEnd, halted}
    State public icoState;
    
    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }
    
    event Invest(address investor, uint value, uint tokens);
    
    constructor(address _deposit) public{
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.beforeStart;
    }
    
      
    function halt() public onlyAdmin{
        icoState = State.halted;
    }
    
     
    function unhalt() public onlyAdmin{
        icoState = State.running;
    }
    
    
     
    function changeDepositAddress(address newDeposit) public onlyAdmin{
        deposit = newDeposit;
    }
    
    
     
    function getCurrentState() public view returns(State){
        if(icoState == State.halted){
            return State.halted;
        }else if(block.timestamp < saleStart){
            return State.beforeStart;
        }else if(block.timestamp >= saleStart && block.timestamp <= saleEnd){
            return State.running;
        }else{
            return State.afterEnd;
        }
    }
    
        
    function invest() payable public returns(bool){
         
        icoState = getCurrentState();
        require(icoState == State.running);
        
        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        
        uint tokens = msg.value / tokenPrice;
        
         
        require(raisedAmount + msg.value <= hardCap);
        
        raisedAmount += msg.value;
        
         
        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        
        deposit.transfer(msg.value); 
        
         
        emit Invest(msg.sender, msg.value, tokens);
        
        return true;
        

    }
    
    function burn() public returns(bool){
        icoState = getCurrentState();
        require(icoState == State.afterEnd);
        balances[founder] = 0;
        
        
    }
    
    

    
    function () payable public{
        invest();
    }  
    
    
    function transfer(address to, uint value) public returns(bool){
        require(block.timestamp > coinTradeStart);
        super.transfer(to, value);
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns(bool){
        require(block.timestamp > coinTradeStart);
        super.transferFrom(_from, _to, _value);
    }
   
   bool public mintingFinished = false;
   event Mint(address indexed to, uint256 amount);
   event MintFinished();
  

modifier canMint() {
    require(!mintingFinished);
    _;
  }


  function mint(address _to, uint256 _amount) onlyAdmin canMint returns (bool) {
   supply = safeAdd(supply, _amount);
    balances[_to] = safeAdd(balances[_to], _amount);
    Mint(_to, _amount);
    return true;
  }

function safeAdd(uint a, uint b) internal returns (uint) {
  if (a + b < a) { throw; }
  return a + b;
}
 
 
  function finishMinting() onlyAdmin returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  
  

}