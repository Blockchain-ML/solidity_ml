pragma solidity ^0.4.20;
 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
 
 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
 
   
  function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
 
   
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
 
}
 
 
contract StandardToken is ERC20, BasicToken {
 
  mapping (address => mapping (address => uint256)) allowed;
 
   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    uint256 _allowance = allowed[_from][msg.sender];
 
     
     
 
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
 
   
  function approve(address _spender, uint256 _value) public returns (bool) {
 
     
     
     
     
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
 
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
 
   
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
  
   
}
 
 
 
contract BurnableToken is StandardToken {
 
  function burn(uint _value) public {
    require(_value > 0);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
  }
 
  event Burn(address indexed burner, uint indexed value);
}

contract TBL4Token is BurnableToken {
    
  string public constant name = "TBL4 Test Token";
    
  string public constant symbol = "TBL4";
    
  uint32 public constant decimals = 15;
    
  uint256 public constant INITIAL_SUPPLY = 17.5 * 1 ether;  
   
    
  bool public stopped = false;  
  address public owner;
    
  modifier isRunning() {
    if (stopped) {
        if (msg.sender != owner)
            revert();
      }
    _;
  }

  function TBL4Token() public {
    owner = msg.sender;
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
  
  function start() public {
    require(msg.sender == owner);
    stopped = false;
  }

  function transfer(address _to, uint256 _value) public isRunning returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public isRunning returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public isRunning returns (bool) {
    return super.approve(_spender, _value);
  }

  
  
}

contract TBL4TokenSale {
    
    using SafeMath for uint;
    
    address public multisigOwner;

    address public multisigFunds;
    address public devs;
    address public partners;
     
    
    uint public constant soldPercent = 60;
    uint public constant partnersPercent = 5;
     
    uint public constant devsPercent = 35;

    uint public constant softcap = 2 * 1 ether;  
    uint public constant hardcap = 10 * 1 ether;  
 
    uint public constant startPreSale = 1529020800;  
    uint public constant endPreSale = 1529971140;  

    uint public constant startSale = 1534118400;  
    uint public constant endSale = 1536796740;  

    TBL4Token public token = new TBL4Token();

    bool stopped = false;

    uint256 public receivedEth = 0;
    uint256 public deliveredEth = 0;
    
    uint256 public issuedTokens;
 
    mapping(address => uint) public prebalances;
    mapping(address => uint) public salebalances;
    
    enum State{
       Running,
       Finished,
       DevsTokensIssued
    }
    
    State finalizeState = State.Running;
    
    event ReservedPresale(address indexed to, uint256 value);
    event ReservedSale(address indexed to, uint256 value);
    event Issued(address indexed to, uint256 value);
    event Refunded(address indexed to, uint256 value);

    function TBL4TokenSale() public {
        
        multisigOwner = msg.sender;  

        multisigFunds = 0x893aafe4736d92f8f30b10E25A83F2B10878cDB3;
        devs = 0xa3Fcb8ef8E4b62240eefa0Ce712E16ADE0EC984C;
        partners = 0xa3Fcb8ef8E4b62240eefa0Ce712E16ADE0EC984C;
      
        
      
    }
 
    modifier isAfterPresale() {
    	require(now > endPreSale || (stopped && now > startPreSale));
    	_;
    }

    modifier isAfterSale() {
    	require(now > endSale);
    	_;
    }
	
    modifier isAboveSoftCap() {
        require(receivedEth >= softcap);
        _;
    }

    modifier onlyOwner() {
        require(multisigOwner == msg.sender);
        _;
    }
    
     
    function getbalance() external view returns(uint) {
      return this.balance;
    }

    function() external payable {
      reserveFunds();
    }

   function reserveFunds() public payable {
       
       uint256 _value = msg.value;
       address _addr = msg.sender;
       
       require (!isContract(_addr));
       require(_value >= 0.1 * 1 ether);  
       
       uint256 _totalFundedEth;
       
       if (!stopped && now > startPreSale && now < endPreSale)
       {
           _totalFundedEth = prebalances[_addr].add(_value);
           require(_totalFundedEth < 5 * 1 ether);  
           prebalances[_addr] = _totalFundedEth;
           receivedEth = receivedEth.add(_value);
           ReservedPresale(_addr, _value);
       }
       else if (now > startSale && now < endSale)
       {
           _totalFundedEth = salebalances[_addr].add(_value);
           require(_totalFundedEth < 100 * 1 ether);  
           salebalances[_addr] = _totalFundedEth;
           receivedEth = receivedEth.add(_value);
           ReservedSale(_addr, _value);
       }
       else
       {
           revert();
       }
    }

    function stopPresale() public {
        require(msg.sender == multisigOwner);
        stopped = true;
    }
    
    function isContract(address _addr) constant internal returns(bool) {
	    uint size;
	    if (_addr == 0) return false;
	    assembly {
		    size := extcodesize(_addr)
	    }
	    return size > 0;
    }

    function issueTokens(address _addr, uint256 _valTokens) internal {

        token.transfer(_addr, _valTokens);
        issuedTokens = issuedTokens.add(_valTokens);
        Issued(_addr, _valTokens);
    }

    function deliver(address _addr, uint256 _valEth, uint256 _valTokens) internal {

        uint _newDeliveredEth = deliveredEth.add(_valEth);
        require(_newDeliveredEth < hardcap);
        multisigFunds.transfer(_valEth);
        deliveredEth = _newDeliveredEth;

        issueTokens(_addr, _valTokens);
    }
    
     
    function refund() public {
        require(receivedEth < softcap && now > endSale);
        uint256 _value = prebalances[msg.sender]; 
        _value += salebalances[msg.sender]; 
        if (_value > 0)
        {
            prebalances[msg.sender] = 0;
            salebalances[msg.sender] = 0; 
            msg.sender.transfer(_value);
            Refunded(msg.sender, _value);
        }
    }

    function issueTokensPresale(address _addr, uint _val) public   isAboveSoftCap {

         
        
        require(_val >= 0);
        
        uint256 _fundedEth = prebalances[_addr];
        if (_fundedEth > 0)
        {
            if (_fundedEth > _val)
            {
                 
                uint _refunded = _fundedEth.sub(_val);
                _addr.transfer(_refunded);
                Refunded(_addr, _refunded);
                _fundedEth = _val;
            }

            if (_fundedEth > 0)
            {
                 
                uint256 _issuedTokens = _fundedEth * 120 / 100;  
                deliver(_addr, _fundedEth, _issuedTokens);
            }
            prebalances[_addr] = 0;
        }
    }

    function issueTokensSale(address _addr, uint _val) public   isAboveSoftCap {

         
        
        require(_val >= 0);
        
        uint _fundedEth = salebalances[_addr];
        if (_fundedEth > 0)
        {
            if (_fundedEth > _val)
            {
                 
                uint256 _refunded = _fundedEth.sub(_val);
                _addr.transfer(_refunded);
                Refunded(_addr, _refunded);
                _fundedEth = _val;
            }

            if (_fundedEth > 0)
            {
                 
                uint256 _issuedTokens = _fundedEth;
                deliver(_addr, _fundedEth, _issuedTokens);
            }
            salebalances[_addr] = 0;
        }
    }

    function issueTokensPresale(address[] _addrs) public   isAboveSoftCap {

         
        for (uint i; i < _addrs.length; i++)
        {
            address _addr = _addrs[i];
            uint256 _fundedEth = prebalances[_addr];
            
            uint256 _issuedTokens = _fundedEth * 120 / 100;  
            if (_fundedEth > 0)
            {
                deliver(_addr, _fundedEth, _issuedTokens);
                prebalances[_addr] = 0;
            }            
        }
    }

    function issueTokensSale(address[] _addrs) public   isAboveSoftCap {

         
        for (uint i; i < _addrs.length; i++)
        {
            address _addr = _addrs[i];
            uint256 _fundedEth = salebalances[_addr];
             
            uint256 _issuedTokens = _fundedEth;
            if (_fundedEth > 0)
            {
                deliver(_addr, _fundedEth, _issuedTokens);
                salebalances[_addr] = 0;
            }            
        }
    }
    
    function refundTokensPresale(address[] _addrs) public   {

         
        for (uint i; i < _addrs.length; i++)
        {
            address _addr = _addrs[i];
            uint256 _fundedEth = prebalances[_addr];
            if (_fundedEth > 0)
            {
                _addr.transfer(_fundedEth);
                Refunded(_addr, _fundedEth);
                prebalances[_addr] = 0;
            }
        }
    }

    function refundTokensSale(address[] _addrs) public   {

         
        for (uint i; i < _addrs.length; i++)
        {
            address _addr = _addrs[i];
            uint256 _fundedEth = salebalances[_addr];
            if (_fundedEth > 0)
            {
                _addr.transfer(_fundedEth);
                Refunded(_addr, _fundedEth);
                salebalances[_addr] = 0;
            }
        }
    }

     
    function finalize() public   isAboveSoftCap {

        require(finalizeState == State.Running);  

        finalizeState = State.Finished;
        
        uint256 _soldTokens = issuedTokens;
        
         
        uint256 _partnersTokens = _soldTokens * partnersPercent / soldPercent;
        issueTokens(partners, _partnersTokens);

         
         

         
        uint256 _tokensToBurn = token.INITIAL_SUPPLY().sub(issuedTokens).sub(_soldTokens * devsPercent / soldPercent);
        token.burn(_tokensToBurn);
        token.start();
    }

    function issueDevsTokens() public   isAboveSoftCap {

        require(finalizeState == State.Finished && now > endSale + 2 years);  
        
         
        uint _devsTokens = token.balanceOf(this);
        issueTokens(devs, _devsTokens);
        
        finalizeState == State.DevsTokensIssued;
    }
}