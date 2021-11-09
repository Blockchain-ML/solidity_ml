pragma solidity ^0.4.25;


 

 
 
 
 
 

contract Token {

     
    function totalSupply() constant returns (uint256 supply) {}										 

    function balanceOf(address _owner) constant returns (uint256 balance) {}						 

    function transfer(address _to, uint256 _value) returns (bool success) {}						 

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}  	 

    function approve(address _spender, uint256 _value) returns (bool success) {}

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}	 

    
	 
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

contract Tradex is StandardToken { 

   
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    uint256 public exchangeRate;          
    address public icoWallet;            
    uint256 public endBlock;
    uint256 public startBlock;
    

	address public creator;
	
	bool public isFunding;

     
     
    function Tradex() {
        balances[msg.sender] = 1000000000000000000000000000;                
        totalSupply = 1000000000000000000000000000;                         
        name = "Tradex";                                    
        decimals = 18;                                                
        symbol = "dex";                                              
        icoWallet = msg.sender;                                     
		creator = msg.sender;
    }
	
	  
    function updateRate(uint256 rate) external {
        require(msg.sender==creator);
        require(isFunding);
        exchangeRate = rate;
		
	}
	
	
	
	function updateStartTime(uint256 StartTime) external {
        require(msg.sender==creator);
        startBlock = StartTime;
	}    

	
	function updateEndTime(uint256 endTime) external {
        require(msg.sender==creator);
        endBlock = endTime;
	}  		
   
	
	function ChangeicoWallet(address EthWallet) external {
        require(msg.sender==creator);
        icoWallet = EthWallet;
		
	}
	function changeCreator(address _creator) external {
        require(msg.sender==creator);
        creator = _creator;
    }
		

	function openSale() external {
		require(msg.sender==creator);
		isFunding = true;
    }
	
	function closeSale() external {
		require(msg.sender==creator);
		isFunding = false;
    }	
	
	
		
    function() payable {
        require(msg.value >= (1 ether/50));
        require(isFunding);
    	exchangeRate = 200000;                                       
		uint256 amount = msg.value * exchangeRate;
		      
        balances[icoWallet] = balances[icoWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        Transfer(icoWallet, msg.sender, amount);  

         
        icoWallet.transfer(msg.value);                               
    }
	

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

         
         
         
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}