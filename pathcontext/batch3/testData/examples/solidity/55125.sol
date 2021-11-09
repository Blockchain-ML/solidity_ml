pragma solidity ^0.4.24;

library SafeMath {
  function mul(uint256 a, uint256 b) pure internal  returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) pure internal returns (uint256) {
     
    uint256 c = a / b;
     
    return c;
  }
  function sub(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

 
contract Ownable {
    address public owner;
    address public agent;
    
    
     
    constructor() public {
        owner = msg.sender;
    }
    
    
     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    
     
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

         
    function setAgent(address newAgent) public onlyOwner {
        if (newAgent != address(0)) {
            agent = newAgent;
        }
    }    
    
}

contract Trade is Ownable {
    uint256 public persent = 100;
    address public agent = 0xA0871cEaC72f042d69b996DcefAf1b7b23535fA1;
    uint256 public dealId=0;
    uint256 private commission=1;
    uint256 public endtime; 

	using SafeMath for uint256;
    
    enum DealState { Empty, Created, InProgress, InTrial, Finished }  
    enum Answer { NotDefined, Yes, No }  
	
	mapping (address => uint) balances;  
	
	
	event CreateNew(uint256 indexed id, address indexed _payer, address indexed _seller, address _agent, uint256 _value, uint256 _commision, uint256 _persent, uint256 _endtime);
	event ConfirmPayer(uint256 indexed _dealId, uint256 _persent);
	event ConfirmSeller(uint256 indexed _dealId, uint256 _persent);
	event Pay(uint256 indexed _dealId);
	event FinishDeal(uint256 indexed _dealId);
	event SetRating(uint256 indexed _dealId);
	event IsPay(address indexed _from, uint _value);
	event ErrorAccess(uint256 indexed _dealId);	
	event Error(uint256 indexed _errorNumber);
	
    struct Deal {
        uint256 dealId;
		address payer; 
		address seller;
        address agent;
        
        uint256 value;  
        uint256 commission;  
        uint256 persent;  
        uint256 endtime;
        
        bool payerAns;
        bool sellerAns;

        DealState state;
    }
	
    modifier onlyAgent(uint256 _dealId) {
        require(msg.sender == deals[_dealId].agent);
        _;
    }

     
    mapping (uint256 => Deal) public deals;
    
     
    function createNew(address _payer) public payable returns(bool){
        
        address _seller;
        uint256 _value;
        
        require(msg.value > 0);
        endtime = now + 1 days;  
        dealId == dealId++;
        require(deals[dealId].state == DealState.Empty);
        
        _seller = msg.sender;
        _value = msg.value;
        
        
         
        deals[dealId] = Deal(dealId, _payer, _seller, agent, _value, commission, persent, endtime, false, false, DealState.Created);  
		emit CreateNew(dealId, _payer, _seller, agent, _value, commission, persent, endtime);

         
         
		balances[deals[dealId].payer] = balances[msg.sender].add(msg.value);
         
		emit Pay(dealId);		
        deals[dealId].state = DealState.InProgress;	
        emit Error(0);
        
        return true;
    }
    
         
    
     	
     function getState(uint256 _dealId) public constant returns (DealState) 
    {
        return deals[_dealId].state;
    }  

     
    function confirm(uint256 _dealId, uint256 _persent) public returns(bool){
 
        if (msg.sender == deals[_dealId].payer) 
            {
 
    		if (deals[_dealId].sellerAns == true && deals[_dealId].persent == _persent) 
        		{
        		    deals[_dealId].payerAns = true;
        		    emit ConfirmPayer(_dealId, _persent);
        		    finishDeal(_dealId, _persent);
        		    emit Error(1);
        		}
        	else
            	{
        		    deals[_dealId].persent = _persent;
        			deals[_dealId].payerAns = true;
        		    emit ConfirmPayer(_dealId, _persent);  
            		emit Error(2);   
            	}
            }

 
        else if (msg.sender == deals[_dealId].seller) 
            {
 
    		if (deals[_dealId].payerAns == true && deals[_dealId].persent == _persent) 
        		{
        		    deals[_dealId].sellerAns = true;
                    emit ConfirmSeller(_dealId, _persent);
        		    finishDeal(_dealId, _persent);
        		    emit Error(3);  
        		}
    		else 
        		{
        		    deals[_dealId].persent = _persent;
        			deals[_dealId].sellerAns = true;
        		    emit ConfirmSeller(_dealId, _persent);
        		    emit Error(4);
        		}        
            }
        
        else
            {
 
                ErrorAccess;
                emit Error(5);
            }
       return true;     
    }


          
    function finishDeal(uint256 _dealId, uint256 _persent) public returns(bool) {  
        if (deals[_dealId].payerAns && deals[_dealId].sellerAns) {  
			 
			 
			
			 
			 
			deals[_dealId].commission = balances[deals[_dealId].payer].mul(1).div(100);  
			balances[deals[_dealId].agent] =  balances[deals[_dealId].agent].add(deals[_dealId].commission);  
			balances[deals[_dealId].payer] =  balances[deals[_dealId].payer].sub(deals[_dealId].commission);  
			deals[_dealId].agent.transfer(balances[deals[_dealId].agent]);  
						
			 
			balances[deals[_dealId].seller] =  balances[deals[_dealId].seller].add(deals[_dealId].value.mul(_persent).div(100));  
			balances[deals[_dealId].payer] =  balances[deals[_dealId].payer].sub(deals[_dealId].value.mul(_persent).div(100));  
	
		
		     
            deals[_dealId].seller.transfer(balances[deals[_dealId].seller]);
            deals[_dealId].payer.transfer(balances[deals[_dealId].payer]);
			
            deals[_dealId].state = DealState.Finished;
			emit FinishDeal(_dealId);
			emit Error(6);
        } else {
            require(now >= deals[_dealId].endtime);
            deals[_dealId].state = DealState.InTrial;
            emit Error(7);
        }
        return true;
    }
  	
}