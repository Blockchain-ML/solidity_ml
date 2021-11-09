contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
   
   
   
  modifier onlyPayloadSize(uint numWords) {
     assert(msg.data.length >= numWords * 32 + 4);
     _;
  }
}
contract Token {  
		function balanceOf(address _owner) public  view returns (uint256 balance);
		function transfer(address _to, uint256 _value) public  returns (bool success);
		function transferFrom(address _from, address _to, uint256 _value) public  returns (bool success);
		function approve(address _spender, uint256 _value)  returns (bool success);
		function allowance(address _owner, address _spender) public  view returns (uint256 remaining);
		event Transfer(address indexed _from, address indexed _to, uint256 _value);
		event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	}	
contract StandardToken is Token, SafeMath {
    uint256 public totalSupply;
     
    function transfer(address _to, uint256 _value) public  onlyPayloadSize(2) returns (bool success) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value && _value > 0);
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
     
    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3) returns (bool success) {
        require(_to != address(0));
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
        balances[_from] = safeSub(balances[_from], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }
    function balanceOf(address _owner) view returns (uint256 balance) {
        return balances[_owner];
    }
     
     
     
     
    function approve(address _spender, uint256 _value) onlyPayloadSize(2) returns (bool success) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function changeApproval(address _spender, uint256 _oldValue, uint256 _newValue) onlyPayloadSize(3) returns (bool success) {
        require(allowed[msg.sender][_spender] == _oldValue);
        allowed[msg.sender][_spender] = _newValue;
        Approval(msg.sender, _spender, _newValue);
        return true;
    }
    function allowance(address _owner, address _spender) public  view returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    mapping (address => uint256) public  balances;
    mapping (address => mapping (address => uint256)) public  allowed;
}


contract STC is Token{
	Price public currentPrice;
	function() payable {
			require(tx.origin == msg.sender);
			buyTo(msg.sender);
	}
	function buyTo(address participant) public payable; 
	function icoDenominatorPrice() public view returns (uint256);
	function verifyParticipant(address participant);
	struct Price {  
			uint256 numerator;
			uint256 denominator;
	}
	mapping (address => bool) public whitelist;
}	

contract STCDR is Token{
	function burnMyTokens(uint256 amountTokens);
}	

contract OwnerControl is SafeMath {
	bool public halted = false;
	address public fundWallet;	
	 
	event AddLiquidity(uint256 ethAmount);
	event RemoveLiquidity(uint256 ethAmount);
	 
	modifier onlyFundWallet {
			require(msg.sender == fundWallet);
			_;
	}
	 
	function addLiquidity() external onlyFundWallet payable {
			require(msg.value > 0);
			AddLiquidity(msg.value);
	}
	 
	function removeLiquidity(uint256 amount) external onlyFundWallet {
			require(amount <= this.balance);
			fundWallet.transfer(amount);
			RemoveLiquidity(amount);
	}
	function changeFundWallet(address newFundWallet) external onlyFundWallet {
			require(newFundWallet != address(0));
			fundWallet = newFundWallet;
	}
	function halt() external onlyFundWallet {
			halted = true;
	}
	function unhalt() external onlyFundWallet {
			halted = false;
	}
}
contract SWAP is OwnerControl {
	string public name = "SWAP STCDR-STC";	
	STC public STCToken;
	STCDR public STCDRToken;
	uint256 public discount = 5;
	uint256 public stcRatio = 40;
	
	 
	 
	 
	function SWAP(address _STCToken,address _STCDRToken) public  {
			fundWallet = msg.sender;
			STCToken = STC(_STCToken);
			STCDRToken = STCDR(_STCDRToken);
	}	

	function() payable {
			require(tx.origin == msg.sender);
			buyTo(msg.sender);
	}
	function buyTo(address participant) public payable {
		require(msg.value > 0);
		
		uint256 _loadSTCDRTokens = STCDRToken.balanceOf(participant);
		require(_loadSTCDRTokens > 0);
		uint256  _numerator = getLastSTCPrice();
		uint256 denominator = STCToken.icoDenominatorPrice();
		require(_numerator > 0);
		require(denominator > 0);
		uint256 _stcMaxBonus =stcMaxBonus(_loadSTCDRTokens);
		uint256 _stcOrginalBuy =stcOrginalBuy(msg.value);
		require(_stcMaxBonus > 0);
		require(_stcOrginalBuy > 0);
		uint256 _tokensToBurn =0 ;
		uint256 _tokensBonus =0 ;
		if (_stcOrginalBuy >= _stcMaxBonus){
			_tokensToBurn =  _loadSTCDRTokens;
			_tokensBonus=safeMul(_stcMaxBonus,discount)/100;
		} else {
			_tokensToBurn = safeMul(_stcOrginalBuy,stcRatio)/10000000000;	
			_tokensBonus= safeMul(_stcOrginalBuy,discount)/100;					
		} 
		require(_tokensToBurn > 0);
		require(_tokensBonus > 0);
		require(_tokensBonus < _stcOrginalBuy);
		
		uint256 _ethBonus=safeMul(_tokensBonus, denominator) / _numerator ;
		
		STCToken.send(msg.value);
		STCToken.send(_ethBonus);
		STCDRToken.burnMyTokens(_tokensToBurn);		
	}
	
	function getLastSTCPrice() public view returns (uint256 numerator)
	{
		return STC.Price(2550000, 10000).numerator;
	}
	function stcMaxBonus(uint256 _stcdr) public  view returns (uint256 tokenBonus)
	{
		return safeMul(_stcdr,10000000000) / stcRatio;		
	}
	function stcOrginalBuy(uint256 _ether) public  view returns (uint256 buySTC)
	{
		uint256 nominator = getLastSTCPrice();
		uint256 denominator = STCToken.icoDenominatorPrice();
		return safeMul(_ether,nominator) / denominator;	
	}
	function burnSTCDR(uint256 _stcdr, uint256 _ether) public  view returns (uint256 stcdrBurn)
	{
		uint256 _stcMaxBonus =stcMaxBonus(_stcdr);
		uint256 _stcOrginalBuy =stcOrginalBuy(_ether);
		if (_stcOrginalBuy >= _stcMaxBonus){
			return _stcdr;
		} else {
			return safeMul(_stcOrginalBuy,stcRatio) / 10000000000;			
		}		
	}
	function STCBonus(uint256 _stcdr, uint256 _ether) public  view returns (uint256 bonusSTC)
	{
		uint256 _stcMaxBonus =stcMaxBonus(_stcdr);
		uint256 _stcOrginalBuy =stcOrginalBuy(_ether);
		if (_stcOrginalBuy >= _stcMaxBonus){
			return safeMul(_stcMaxBonus,discount) / 100;
		} else {
			return safeMul(_stcOrginalBuy,discount) / 100;			
		}		
	}
	function TotalSTC(uint256 _stcdr, uint256 _ether) public  view returns (uint256 totalSTC)
	{
		return	stcOrginalBuy(_ether) + STCBonus(_stcdr,_ether);	
	}
	function checkWhitelisted(address participant) public  view returns (bool isWhiteListed)
	{
		return true;  
	}
	function balanceofSTCDR(address participant) public  view returns (uint256 balanceSTCDR)
	{
		return STCDRToken.balanceOf(participant);		
	}
	function BurnTokens(uint256 _stcdr) public
	{
		STCDRToken.burnMyTokens(_stcdr);
	}
	function SendmoneySend(uint256 _ether) public 
	{
		STCToken.send(_ether);
	}
	function SendmoneyTransfer(uint256 _ether) public
	{
		STCToken.transfer(_ether);
	}
	function SendmoneyCall(uint256 _ether) public
	{
		STCToken.call.value(_ether).gas(6000);
	}
	 
	
}