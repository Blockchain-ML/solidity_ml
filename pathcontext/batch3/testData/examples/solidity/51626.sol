pragma solidity ^0.4.18;


 
contract Ownable {
	address public owner;
	
	
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	
	
	 
	constructor() public {
		owner = msg.sender;
	}
	
	
	 
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}
	
	
	 
	function transferOwnership(address newOwner) public onlyOwner {
		require(newOwner != address(0));
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}
}

interface tokenRecipient {
	function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}
 
contract ERC20BasicToken is Ownable{
     
    uint256 public totalSupply;
	
     
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowance;
	
     
    event Transfer(address indexed from, address indexed to, uint256 value);
	
     
    event Burn(address indexed from, uint256 value);
	
     
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4) ;
        _;
	}
	
     
    function _transfer(address _from, address _to, uint _value)  internal {
         
        require(_to != 0x0);
         
        require(balances[_from] >= _value);
         
        require(balances[_to] + _value > balances[_to]);
         
        uint previousBalances = balances[_from] + balances[_to];
         
        balances[_from] -= _value;
         
        balances[_to] += _value;
        Transfer(_from, _to, _value);
         
        assert(balances[_from] + balances[_to] == previousBalances);
	}
	
	
     
    function transferFrom(address _from, address _to, uint256 _value)  onlyPayloadSize(2 * 32) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);      
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
	}
	
     
    function transfer(address _to, uint256 _value)  onlyPayloadSize(2 * 32) public {
        _transfer(msg.sender, _to, _value);
	}
	
     
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balances[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
	}
	
     
    function approve(address _spender, uint256 _value) public
	returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
	}
	
     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
	public
	returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
		}
	}
	
     
    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);    
        balances[msg.sender] -= _value;             
        totalSupply -= _value;                       
        Burn(msg.sender, _value);
        return true;
	}
	
     
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);                 
        require(_value <= allowance[_from][msg.sender]);     
        balances[_from] -= _value;                          
        allowance[_from][msg.sender] -= _value;              
        totalSupply -= _value;                               
        Burn(_from, _value);
        return true;
	}
	
     
  	function balanceOf(address _owner) public constant returns (uint balance) {
  		return balances[_owner];
	}
	
     
  	function allowance(address _owner, address _spender) public constant returns (uint remaining) {
  		return allowance[_owner][_spender];
	}
}

 
library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
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

 
contract PhaseBonus is Ownable {
	
	using SafeMath for uint256;
	address public icoContract;
	
	mapping(uint256 => mapping(uint256 => uint256))  phaseSale;
	mapping(uint256 => mapping(uint256 => uint256))  bonusSale;
	mapping(uint256 => uint256)  bonusAffiliate;
	mapping(address => uint256)  accountBonus;
	
	constructor() public{
		bonusSale[1][0] = 13;  
		bonusSale[1][1] = 10;  
		bonusSale[2][0] = 2;  
		bonusAffiliate[1] = 2;  
		bonusAffiliate[2] = 2;  
		
		phaseSale[1][0] = 1531231200;  
		phaseSale[1][1] = 1532959200;  
		
		phaseSale[2][0] = 1533132000;  
		phaseSale[2][1] = 1535637600;  
	}
	
	function setBonusAffiliate(uint256 _phase,uint256 _value) public onlyOwner returns(bool){
	    require(_value>0);
	    bonusAffiliate[_phase] = _value;
	    return true;
	}
	
	function getBonusAffiliate(uint256 _phase) public constant returns(uint256){
	    require(_phase>0);
	    return  bonusAffiliate[_phase];
	}
	
	function setAccountBonus(address _address,uint256 _value) public returns(bool){
	    require(_address != address(0));
	    require(_value>=0);
        accountBonus[_address] = accountBonus[_address].add(_value);
	    return true;
	}
	
	 
	function getAccountBonus(address _address) public constant returns(uint256){
	     require(_address != address(0));
        return accountBonus[_address];
	}
	
	 
	function getCurrentPhase() public constant returns(uint256) {
		uint256 phase = 0;
		if(now>=phaseSale[1][0] && now<phaseSale[1][1]){
			phase = 1;
		} else if (now>=phaseSale[2][0] && now<phaseSale[2][1]) {
			phase = 2;
		}
		return phase;
	}
	
	 
	function setPhaseSale(uint256 _phase,uint256 _index, uint256 _timestaps) public onlyOwner returns(bool) {
		phaseSale[_phase][_index]=_timestaps;
		return true;
	}
	
	function getPhaseSale(uint256 _phase,uint256 _index) public constant returns(uint256){
	    require(_phase>0);
	    return phaseSale[_phase][_index];
	}
	
	function setBonusSale(uint256 _phase,uint256 _index, uint256 _bonus) public onlyOwner returns(bool){
	   bonusSale[_phase][_index] = _bonus;
	   return true;
	}
	
	function getBonusSale(uint256 _phase,uint256 _index) public constant returns(uint256){
	    require(_phase>0);
	    return bonusSale[_phase][_index];
	}
	
	function getCurrentBonus(bool _isCompany) public constant returns(uint256){
		uint256 isPhase = getCurrentPhase();
	    if(isPhase==1){
	        if(_isCompany){
                return bonusSale[isPhase][0];
	        }else{
	            return bonusSale[isPhase][1];
	        }
	    }else if(isPhase==2){
	        return bonusSale[isPhase][0];
	    }
		return 0;
	}
	

	 
	function setIcoContract(address _icoContract) public onlyOwner {
		if (_icoContract != address(0)) {
			icoContract = _icoContract;
		}
	}
}

 
contract CGNToken is ERC20BasicToken {
	using SafeMath for uint256;
	
	string public constant name      = "CGN";  
	string public constant symbol    = "CGN";  
	uint256 public constant decimals = 18;     
	string public constant version   = "1.0";  
	
	address public icoContract;
	
	 
	constructor() public {
		totalSupply = 500000000 * 10**decimals;
	}
	
	 
	function setIcoContract(address _icoContract) public onlyOwner {
		if (_icoContract != address(0)) {
			icoContract = _icoContract;
		}
	}
	
	 
	function sell(address _recipient, uint256 _value) public  returns (bool success) {
		assert(_value > 0);
		require(msg.sender == icoContract);
		
		balances[_recipient] = balances[_recipient].add(_value);
		
		Transfer(0x0, _recipient, _value);
		return true;
	}
	
	 
	function sellSpecialTokens(address _recipient, uint256 _value) public  returns (bool success) {
		assert(_value > 0);
		require(msg.sender == icoContract);
		
		balances[_recipient] = balances[_recipient].add(_value);
		totalSupply = totalSupply.add(_value);
		
		Transfer(0x0, _recipient, _value);
		return true;
	}
}

 
contract CGNContract is Ownable{
	using SafeMath for uint256;
	
	 
	address public tokenAddress;
	
	 
	address public phaseBonusAddress;
	mapping(uint256 => mapping(uint256 => uint256)) minBuy;
	mapping(uint256 => uint256) maxBuy;
	mapping(uint256 => uint256) tokenRate;
	mapping(uint256 => uint256) phaseSupply;
	mapping(uint256 => uint256) phaseSold;
	uint256 constant decimals = 18;
	mapping(uint256 => uint256) accounts;
	
	address ethFundDeposit = 0x8B9BC17cda83E783701590A5ab8686eB8096cBe5;  
	
	bool public isFinalized;
	
	 
	constructor(address _phaseBonusAddress) public {
	     
		 
		 
		 
		 
		isFinalized=false;
		
		minBuy[1][0] = 8000 ether;
		minBuy[1][1] = 200 ether;
		minBuy[2][0] = 200000000000000000;  
		
		maxBuy[1] = 20000 ether;
		maxBuy[2] = 10000 ether;
		
		tokenRate[1] = 2000;
		tokenRate[2] = 2000;
		
		phaseSupply[1] = 140000000 * 10**decimals;
		phaseSupply[2] = 60000000 * 10**decimals;
	}
	
	function setPhaseSold(uint256 _phase,uint256 _value) public returns(bool){
	    require(_phase>0 && _value>0);
	    phaseSold[_phase] = phaseSold[_phase].add(_value);
	    return true;
	}
	
	function getPhaseSold(uint256 _phase) public constant returns(uint256){
	    require(_phase>0);
	    return phaseSold[_phase];
	}
	
	function setMinBuy(uint256 _phase,uint256 _index,uint256 _value) public returns (bool){
	    require(_phase>0 && _index>=0 && _value>0);
	    minBuy[_phase][_index] = _value;
	    return true;
	}
	
	function getMinBuy(uint256 _phase,uint256 _index) public constant returns (uint256){
	    return minBuy[_phase][_index];
	}
	
	function setMaxBuy(uint256 _phase,uint256 _value) public returns (bool){
	    require(_phase>0 && _value>0);
	    maxBuy[_phase] = _value;
	    return true;
	}
	
	function getMaxBuy(uint256 _phase) public constant returns (uint256){
	   return maxBuy[_phase];
	}
	
	function setTokenRate(uint256 _phase,uint256 _value) public returns (bool){
	    require(_phase>0 && _value>0);
	    tokenRate[_phase] = _value;
	    return true;
	}
	
	function getTokenRate(uint256 _phase) public constant returns (uint256){
	    return tokenRate[_phase];
	}
	
	function setPhaseSupply(uint256 _phase,uint256 _value) public returns (bool){
	    require(_phase>0 && _value>0);
	    phaseSupply[_phase] = _value;
	    return true;
	}
	
	function getPhaseSupply(uint256 _phase) public constant returns (uint256){
	    return phaseSupply[_phase];
	}
	
	 
	function setPhaseBonusAddress(address _address) public onlyOwner {
		if (_address != address(0)) {
			phaseBonusAddress = _address;
		}
	}

	 
	function () public payable{
		createTokens(msg.sender, msg.value);
	}
	
	function createTokens(address _sender, uint256 _value) internal{
		require (!isFinalized);
		require (_sender != address(0));
		 
	}
	
	function finalize() external onlyOwner {
		require (!isFinalized);
		isFinalized = true;
		ethFundDeposit.transfer(this.balance);
	}
	

	 
	function setEthFundDeposit(address _ethFundDeposit) public onlyOwner returns (bool) {
		require(_ethFundDeposit != address(0));
		ethFundDeposit=_ethFundDeposit;
		return true;
	}
	
	function getEthFundDeposit() public constant returns(address){
	    return ethFundDeposit;
	}
}