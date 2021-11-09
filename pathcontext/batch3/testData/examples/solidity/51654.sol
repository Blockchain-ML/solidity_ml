pragma solidity ^0.4.24;


 
 
 
 
 
 
 
 


contract IMigrationContract {
    function migrate(address addr, uint256 nas) public returns (bool success);
}

 
contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSubtract(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMult(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address to, uint256 tokens) public returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


 
contract StandardToken is Token, SafeMath {


     
     
     
     
     
    function transfer(address to, uint256 tokens) public returns (bool success) {
        balances[msg.sender] = safeSubtract(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }



     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, uint256 tokens) public returns (bool success) {
        balances[from] = safeSubtract(balances[from], tokens);
        allowed[from][msg.sender] = safeSubtract(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract stake19Token is StandardToken {

     
    string  public constant name = "STAKE19 Token";
    string  public constant symbol = "STAKE19";
    uint256 public constant decimals = 18;
    string  public version = "1.0";

     
    address public ethFundDeposit;           
    address public newContractAddr;          

     
    bool    public isFunding;                    
    bool    public allowRefunds;                 
    uint256 public fundingStartBlock;
    uint256 public fundingStopBlock;

    uint256 public tokenRaised = 0;          
  
    uint256 public ETHRefunded = 0;          
    uint256 public tokenRefunded = 0;      
    uint256 public tokenMigrated = 0;      
    uint256 public tokenExchangeRate = 400;              

     
    event AllocateToken(address indexed _to, uint256 _value);    
    event IssueToken(address indexed _to, uint256 _value);       
    event IncreaseTotalSupply(uint256 _value);
    event DecreaseTotalSupply(uint256 _value);
    event LogRefund(address indexed _to, uint256 _ETHvalue);
    event LogTokenRefundBurn(address indexed _to, uint256 _value);
    event Migrate(address indexed _to, uint256 _value);

    mapping (address => uint256) ETHbalances;


     
    function formatDecimals(uint256 _value) internal pure returns (uint256 ) {
        return _value * 10 ** decimals;
    }

     
    constructor () public
    {
        ethFundDeposit = msg.sender;
        allowRefunds = false;
        isFunding = false;                            
        fundingStartBlock = 0;
        fundingStopBlock = 0;

        totalSupply = formatDecimals(30000000);
    }

    modifier isOwner()  { require(msg.sender == ethFundDeposit); _; }

     
    function setTokenExchangeRate(uint256 _tokenExchangeRate) isOwner external {
        require (_tokenExchangeRate != 0);
        require (_tokenExchangeRate != tokenExchangeRate);

        tokenExchangeRate = _tokenExchangeRate;
    }

     
    function increaseTotalSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        totalSupply = safeAdd(totalSupply, value);
        emit IncreaseTotalSupply(value);
    }

     
    function decreaseTotalSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        require(value + tokenRaised <= totalSupply);
        totalSupply = safeSubtract(totalSupply, value);
        emit DecreaseTotalSupply(value);
    }


     
    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) isOwner external {
        require (!isFunding);
        require (_fundingStartBlock <= _fundingStopBlock);
        require (block.number <= _fundingStartBlock);

        fundingStartBlock = _fundingStartBlock;
        fundingStopBlock = _fundingStopBlock;
        isFunding = true;
    }

     
    function stopFunding() isOwner external {
        require(isFunding);
        isFunding = false;
    }

     
    function allowRefunds(bool _state) isOwner external {
        allowRefunds = _state;
    }

     
    function ETHbalanceOf(address _owner) constant public returns (uint256 ETHbalance) {
        return ETHbalances[_owner];
    }

     
    function setMigrateContract(address _newContractAddr) isOwner external {
        require(_newContractAddr != newContractAddr);
        newContractAddr = _newContractAddr;
    }

     
    function changeOwner(address _newFundDeposit) isOwner() external {
        require (_newFundDeposit != address(0x0));
        ethFundDeposit = _newFundDeposit;
    }

     
    function migrate() external {
        require(!isFunding);
        require(newContractAddr != address(0x0));

        uint256 tokens = balances[msg.sender];
     
          require (tokens > 0);

        balances[msg.sender] = 0;
        tokenMigrated = safeAdd(tokenMigrated, tokens);

        IMigrationContract newContract = IMigrationContract(newContractAddr);
        require (newContract.migrate(msg.sender, tokens));

        emit Migrate(msg.sender, tokens);                
    }

     
    function transferETH() isOwner external {
     
        require (address(this).balance != 0);
    
     
     

          ethFundDeposit.transfer(address(this).balance);
     
    }

     
    function allocateTokenETHConvert (address _addr, uint256 _eth) isOwner external {
     
        require (_eth > 0);
        require (_addr != address(0x0));

     
        uint256 tokens = safeMult(_eth, tokenExchangeRate);
        require (tokens + tokenRaised <= totalSupply);

        tokenRaised = safeAdd(tokenRaised, tokens);
        balances[_addr] += tokens;

        emit Transfer(address(0), _addr, tokens);
        emit AllocateToken(_addr, tokens);   
    }

     
    function allocateNominalToken (address _addr, uint256 tokens) isOwner external {
        require (tokens > 0);
        require (_addr != address(0x0));

        require (tokens + tokenRaised <= totalSupply);

        tokenRaised = safeAdd(tokenRaised, tokens);
        balances[_addr] += tokens;

        emit Transfer(address(0), _addr, tokens);
        emit AllocateToken(_addr, tokens);   
    }


     
    function () payable public{
        require (isFunding);
        require (msg.value != 0);

        require (block.number >= fundingStartBlock);
        require (block.number <= fundingStopBlock);
         
          
         if ( msg.sender != ethFundDeposit ) {

            uint256 tokens = safeMult(msg.value, tokenExchangeRate);
            require (tokens + tokenRaised <= totalSupply);

            tokenRaised = safeAdd(tokenRaised, tokens);

            balances[msg.sender] += tokens;

             
            ETHbalances[msg.sender] += msg.value;

            emit Transfer(address(0), msg.sender, tokens);
            emit IssueToken(msg.sender, tokens);   
        }
    }

    function refund() public returns(bool success) {
        require(allowRefunds);
        uint256 amtRequested = ETHbalances[msg.sender];
        require(amtRequested > 0);
        require(address(this).balance >= amtRequested);


        uint256 tokens = balances[msg.sender];
        require (tokens > 0);

         
        msg.sender.transfer(amtRequested);

        ETHRefunded = safeAdd(ETHRefunded, amtRequested);

         
        ETHbalances[msg.sender] = 0;

        emit LogRefund(msg.sender, amtRequested );                
        
        tokenRefunded = safeAdd(tokenRefunded, tokens);
        
         
        totalSupply = safeSubtract(totalSupply, tokens);

        balances[msg.sender] = 0;

        emit LogTokenRefundBurn(msg.sender, tokens);                

        emit DecreaseTotalSupply(tokens);                

        return true;
    }



}