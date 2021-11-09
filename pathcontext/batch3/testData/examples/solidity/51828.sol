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
	uint256 public fundingEndTime;
	function() payable {
			require(tx.origin == msg.sender);
			buyTo(msg.sender);
	}
	function buyTo(address participant) public payable; 
	function icoDenominatorPrice() public view returns (uint256);
	struct Price {  
			uint256 numerator;
			uint256 denominator;
	}
}	
contract STCDR is Token{
	 
}	
contract OwnerControl is SafeMath {
	bool public halted = false;
	address public controlWallet;	
	 
	event AddLiquidity(uint256 ethAmount);
	event RemoveLiquidity(uint256 ethAmount);
	 
	modifier onlyControlWallet {
			require(msg.sender == controlWallet);
			_;
	}
	 
	function addLiquidity() external onlyControlWallet payable {
			require(msg.value > 0);
			AddLiquidity(msg.value);
	}
	 
	function removeLiquidity(uint256 amount) external onlyControlWallet {
			require(amount <= this.balance);
			controlWallet.transfer(amount);
			RemoveLiquidity(amount);
	}
	function changeControlWallet(address newControlWallet) external onlyControlWallet {
			require(newControlWallet != address(0));
			controlWallet = newControlWallet;
	}
	function halt() external onlyControlWallet {
			halted = true;
	}
	function unhalt() external onlyControlWallet {
			halted = false;
	}
}
contract SWAP is OwnerControl {
	string public name = "SWAP STCDR-STC";	
	STC public STCToken;
	STCDR public STCDRToken;
	uint256 public discount = 5;
	uint256 public stcRatio = 40;
	 
	 event TokenSwaped(address indexed _from,  uint256 _stc, uint256 _stcBonus, uint256 _stcdrBurn);
	 
	 
	function SWAP(address _STCToken,address _STCDRToken) public  {
			controlWallet = msg.sender;
			STCToken = STC(_STCToken);
			STCDRToken = STCDR(_STCDRToken);
	}	
	function() payable {
			require(tx.origin == msg.sender);
			buyTo(msg.sender);
	}
	function transferTokensAfterEndTime(address participant, uint256 _tokens ,uint256 _tokenBonus , uint256 _tokensToBurn) private
	{
		require(avalibleSTCTokens() > safeAdd(_tokens,_tokenBonus));
		 
		STCDRToken.transferFrom(participant,this,_tokensToBurn);
		STCDRToken.transfer(controlWallet, _tokensToBurn);
		 
		STCToken.transferFrom(controlWallet,this,safeAdd(_tokens,_tokenBonus));
		STCToken.transfer(participant, _tokens);
		STCToken.transfer(participant, _tokenBonus);
	}
	function addEthBonusToBuy(address participant, uint256 _ethBonus , uint256 _tokensToBurn ) private {
		 
		require(this.balance>=safeAdd(msg.value, _ethBonus));		
		STCDRToken.transferFrom(participant,this,_tokensToBurn);
		STCDRToken.transfer(controlWallet, _tokensToBurn);
		 
		STCToken.buyTo.value(safeAdd(msg.value, _ethBonus))(participant);
	}
	function buyTo(address participant) public payable {
		require(!halted);		
		require(msg.value > 0);
		
		 
		uint256 avalibleTokenSTCDR = STCDRToken.allowance(participant, this);
		require(avalibleTokenSTCDR > 0);
		 
		uint256 _numerator = getLastSTCPrice();
		require(_numerator > 0);
		 
		uint256 _fundingEndTime = STCToken.fundingEndTime();
		 
		uint256 denominator = STCToken.icoDenominatorPrice();	
		require(denominator > 0);	
		 
		uint256 _stcMaxBonus = safeMul(avalibleTokenSTCDR,10000000000) / stcRatio;  
		require(_stcMaxBonus > 0);
		 
		uint256 _stcOrginalBuy = safeMul(msg.value,_numerator) / denominator;  
		require(_stcOrginalBuy > 0);
		
		uint256 _tokensToBurn =0 ;
		uint256 _tokensBonus =0 ;
		if (_stcOrginalBuy >= _stcMaxBonus){
			_tokensToBurn =  avalibleTokenSTCDR;
			_tokensBonus= safeSub(safeMul((_stcMaxBonus / safeSub(100,discount)),100),_stcMaxBonus);  
		} else {
			_tokensToBurn = safeMul(_stcOrginalBuy,stcRatio)/10000000000;	
			_tokensBonus =  safeSub(safeMul((_stcOrginalBuy / safeSub(100,discount)),100),_stcOrginalBuy);   
		} 
		require(_tokensToBurn > 0);
		require(_tokensBonus > 0);
		require(_tokensBonus < _stcOrginalBuy);
		
		if (now < _fundingEndTime) {
			 
			 
			uint256 _ethBonus=safeMul(_tokensBonus, denominator) / _numerator ;
			addEthBonusToBuy(participant,_ethBonus,_tokensToBurn);
		 
		} else {
			 
			transferTokensAfterEndTime(participant,_stcOrginalBuy,_tokensBonus ,_tokensToBurn);
			 
		}

		TokenSwaped(participant,  _stcOrginalBuy , _tokensBonus,_tokensToBurn );
	}	
	function getLastSTCPrice() private view returns (uint256 numerator)
	{
		 
		return STC.Price(2550000, 10000).numerator;
	}

	function getEndTime() view returns (uint256 numerator) {
		return  STCToken.fundingEndTime();
	}
	
	function getTokenToBurn() view returns (uint256 numerator) {
		return  STCDRToken.balanceOf(this);
	}
	function avalibleSTCTokens() view returns (uint256 numerator) {
		uint256 alowedTokenSTC = STCToken.allowance(controlWallet, this);
		uint256 balanceTokenSTC = STCToken.balanceOf(controlWallet);
		if (alowedTokenSTC>balanceTokenSTC) {
			return balanceTokenSTC;	
		} else {
			return alowedTokenSTC;
		}
	}

}