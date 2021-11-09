pragma solidity ^0.4.16;
contract Token{
    uint256 public totalSupply;
 
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
 
    function approve(address _spender, uint256 _value) public returns (bool success);
 
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);    
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
 
contract TokenDemo is Token {    
	string public name="Mytoken";                    
    uint8 public decimals=3;                
    string public symbol="MTT";                
	uint256  startTime; 
	address simu; 
	address team; 
    function TokenDemo(uint256 _initialAmount,address sq,address sm,address yy,address group) public {
        totalSupply = _initialAmount * 10 ** uint256(decimals);          
        
	   balances[sq]=totalSupply/10*3; 
	   simu=sm;
	   balances[simu]=totalSupply/10*3; 
	   balances[yy]=totalSupply/10*2; 
	   team=group;
	   balances[team]=totalSupply/10*2; 
	   startTime=now;
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
		
			if(msg.sender==team){
			uint256 timeTemp=(now-startTime)/60/60; 
		if(timeTemp<1){ 
			return false;
		}
		if(timeTemp<2&&timeTemp>=1&&(balances[msg.sender]-_value)<(totalSupply/25*4)){
			return false; 
		}
		if(timeTemp<3&&timeTemp>=2&&(balances[msg.sender]-_value)<(totalSupply/25*3)){
			return false; 
		}
		if(timeTemp<4&&timeTemp>=3&&(balances[msg.sender]-_value)<(totalSupply/25*2)){
			return false; 
		}
		if(timeTemp<5&&timeTemp>=4&&(balances[msg.sender]-_value)<(totalSupply/25)){
			return false; 
		}
		record(_to,_value); 
		}
		
		if(msg.sender==simu){ 
			record(_to,_value);
		}
		if(time[msg.sender]>0){ 
			judge(_value,msg.sender); 
		}
		
             
     
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_to != 0x0);
        balances[msg.sender] -= _value; 
        balances[_to] += _value; 
        Transfer(msg.sender, _to, _value); 
        return true;
    }
 
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
	
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value); 
        balances[_to] += _value; 
        balances[_from] -= _value;  
        allowed[_from][msg.sender] -= _value; 
        Transfer(_from, _to, _value); 
        return true;
    }
	function record(address iniadr,uint256 account)private{
		time[iniadr]=now; 
		init[iniadr]=account; 
	}
	function judge(uint256 value,address addr)private constant returns (bool power){ 
		
			uint256 timeTemp=(now-time[addr])/60/60; 
		if(timeTemp<1&&(balances[addr]-value<init[addr]/5*4)){ 
			return false;
		}
		if(timeTemp<2&&timeTemp>=1&&(balances[addr]-value<init[addr]/5*3)){
			return false; 
		}
		if(timeTemp<3&&timeTemp>=2&&(balances[addr]-value<init[addr]/5*2)){
			return false; 
		}
		if(timeTemp<4&&timeTemp>=3&&(balances[addr]-value<init[addr]/5)){
			return false; 
		}
		return true;
	}
    function balanceOf(address _owner) public constant returns (uint256 balance) {
            return balances[_owner];
    }
 
    function approve(address _spender, uint256 _value) public returns (bool success){ 
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);       
		return true;
    }
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
            return allowed[_owner][_spender]; 
			}
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
	mapping (address => uint256) time; 
	mapping (address => uint256) init; 
}