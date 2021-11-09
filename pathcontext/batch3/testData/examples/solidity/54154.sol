pragma solidity ^ 0.4.25;

 

 

contract ContractReceiver {
	function tokenFallback(address _from, uint _value, bytes _data)public pure {
		 
		_from;
		_value;
		_data;
	}
}

 
library SafeMath {

	 
	function mul(uint256 a, uint256 b)internal pure returns(uint256 c) {
		 
		 
		 
		if (a == 0) {
			return 0;
		}

		c = a * b;
		assert(c / a == b);
		return c;
	}

	 
	function div(uint256 a, uint256 b)internal pure returns(uint256) {
		 
		 
		 
		return a / b;
	}

	 
	function sub(uint256 a, uint256 b)internal pure returns(uint256) {
		assert(b <= a);
		return a - b;
	}

	 
	function add(uint256 a, uint256 b)internal pure returns(uint256 c) {
		c = a + b;
		assert(c >= a);
		return c;
	}
}

 
contract Ownable {
	address public owner;

	event OwnershipRenounced(address indexed previousOwner);
	event OwnershipTransferred(address indexed previousOwner, address indexed _newOwner);

	 
	constructor()public {
		owner = msg.sender;
	}

	 
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	 
	function transferOwnership(address _newOwner)public onlyOwner {
		require(_newOwner != address(0));
		emit OwnershipTransferred(owner, _newOwner);
		owner = _newOwner;
	}

	 
	function renounceOwnership()public onlyOwner {
		emit OwnershipRenounced(owner);
		owner = address(0);
	}
}

contract ERC223Interface {
	uint public _totalSupply;
	function balanceOf(address who)public view returns(uint);

	function totalSupply()public view returns(uint256) {
		return _totalSupply;
	}

	event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

 
contract AumonetERC223 is ERC223Interface {
	using SafeMath for uint256;

	 
	address public owner;
	mapping(address => uint256)public balances;
	mapping(address => mapping(address => uint256))public allowed;

	constructor()public {
		owner = msg.sender;
	}

	 
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed from, address indexed to, uint256 value);

	 
	event Transfer(address indexed from, address indexed to, uint value, bytes data);

	 
	function balanceOf(address _address)public view returns(uint256 balance) {
		return balances[_address];
	}

	 
	function transfer(address _to, uint _value)public returns(bool success) {
		bytes memory empty;
		if (isContract(_to)) {
			return transferToContract(_to, _value, empty);
		} else {
			return transferToAddress(_to, _value, empty);
		}
	}

	 
	function transferFrom(address _from, address _to, uint256 _value)public returns(bool success) {
		if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0 && balances[_to].add(_value) > balances[_to]) {
			balances[_from] = balances[_from].sub(_value);
			allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
			balances[_to] = balances[_to].add(_value);
			emit Transfer(_from, _to, _value);
			return true;
		} else {
			return false;
		}
	}

	 
	function approve(address _spender, uint256 _allowance)public returns(bool success) {
		allowed[msg.sender][_spender] = _allowance;
		emit Approval(msg.sender, _spender, _allowance);
		return true;
	}

	 
	function allowance(address _owner, address _spender)public view returns(uint256 remaining) {
		return allowed[_owner][_spender];
	}

	 
	function transfer(address _to, uint _value, bytes _data, string _custom_fallback)public returns(bool success) {
		if (isContract(_to)) {
			return transferToContractWithCustomFallback(_to, _value, _data, _custom_fallback);
		} else {
			return transferToAddress(_to, _value, _data);
		}
	}

	 
	function transfer(address _to, uint _value, bytes _data)public returns(bool) {
		if (isContract(_to)) {
			return transferToContract(_to, _value, _data);
		} else {
			return transferToAddress(_to, _value, _data);
		}
	}

	 
	function isContract(address _addr)private view returns(bool is_contract) {
		uint length;
		assembly {
			 
			length := extcodesize(_addr)
		}
		return (length > 0);
	}

	 
	function transferToAddress(address _to, uint _value, bytes _data)private returns(bool success) {
		require(balances[msg.sender] >= _value);
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
		emit Transfer(msg.sender, _to, _value, _data);
		return true;
	}

	 
	function transferToContract(address _to, uint _value, bytes _data)private returns(bool success) {
		require(balances[msg.sender] >= _value);
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		ContractReceiver receiver = ContractReceiver(_to);
		receiver.tokenFallback(msg.sender, _value, _data);
		emit Transfer(msg.sender, _to, _value);
		emit Transfer(msg.sender, _to, _value, _data);
		return true;
	}

	 
	function transferToContractWithCustomFallback(address _to, uint _value, bytes _data, string _custom_fallback)private returns(bool success) {
		require(balances[msg.sender] >= _value);
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
		emit Transfer(msg.sender, _to, _value, _data);
		return true;
	}

	 
	function ()public {
		revert();
	}
}

 
contract Pausable is Ownable {
	using SafeMath for uint256;

	event Pause();
	event Unpause();

	bool public paused = false;

	uint _pauseStartTime = 0;
	uint _pauseTime = 0;

	 
	modifier whenNotPaused() {
		require(!paused);
		_;
	}

	 
	modifier whenPaused() {
		require(paused);
		_;
	}

	 
	function pauseTime()public view returns(uint256) {
		return _pauseTime;
	}

	 
	function pause()onlyOwner whenNotPaused public {
		_pauseStartTime = block.timestamp;
		paused = true;
		emit Pause();
	}

	 
	function unpause()onlyOwner whenPaused public {
		_pauseTime = _pauseTime.add(block.timestamp.sub(_pauseStartTime));

		paused = false;
		emit Unpause();
	}
}

 
contract PausableToken is AumonetERC223, Pausable {

	function transfer(address _to, uint256 _value)public whenNotPaused returns(bool) {
		return super.transfer(_to, _value);
	}

	function transfer(address _to, uint _value, bytes _data, string _custom_fallback)public whenNotPaused returns(bool) {
		return super.transfer(_to, _value, _data, _custom_fallback);
	}

	function transfer(address _to, uint256 _value, bytes _data)public whenNotPaused returns(bool) {
		return super.transfer(_to, _value, _data);
	}

	function transferFrom(address _from, address _to, uint256 _value)public whenNotPaused returns(bool) {
		return super.transferFrom(_from, _to, _value);
	}

	function approve(address _spender, uint256 _value)public whenNotPaused returns(bool) {
		return super.approve(_spender, _value);
	}

	function increaseApproval(address _spender, uint _addedValue)public whenNotPaused returns(bool success) {
		allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}

	function decreaseApproval(address _spender, uint _subtractedValue)public whenNotPaused returns(bool success) {
		uint256 oldValue = allowed[msg.sender][_spender];
		if (_subtractedValue > oldValue) {
			allowed[msg.sender][_spender] = 0;
		} else {
			allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
		}
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}
}

 
contract OwnableToken is PausableToken {

	event Burn(address indexed burner, uint256 value);

	 
	function transferAnyERC20Token(address _tokenAddress, uint256 _amount)onlyOwner public returns(bool success) {
		return AumonetERC223(_tokenAddress).transfer(owner, _amount);
	}

	 
	function burn(uint256 _value)public {
		_burn(msg.sender, _value);
	}

	function _burn(address _who, uint256 _value)internal {
		require(_value <= balances[_who]);
		 
		 

		balances[_who] = balances[_who].sub(_value);
		_totalSupply = _totalSupply.sub(_value);
		emit Burn(_who, _value);
		emit Transfer(_who, address(0), _value);
	}
}

 
contract AumonetToken is OwnableToken {

	 
	string public _name = "Aumonet";
	string public _symbol = "AUMO";
	uint8 public _decimals = 5;
	uint256 public _creatorSupply;
	uint256 public _icoSupply;
	uint256 public _bonusSupply = 187000 * (10 ** uint256(_decimals));  

	constructor()public {
		 

		_totalSupply = 1100000 * (10 ** uint256(_decimals));

		_creatorSupply = _totalSupply * 25 / 100;  
		_icoSupply = _totalSupply * 58 / 100;  

		 
		 
		balances[msg.sender] = _icoSupply.add(_bonusSupply);
		balances[tx.origin] = _creatorSupply;  

	}

	function name()public view returns(string) {
		return _name;
	}

	function symbol()public view returns(string) {
		return _symbol;
	}

	function decimals()public view returns(uint8) {
		return _decimals;
	}

	function bonusSupply()public view returns(uint256) {
		return _bonusSupply;
	}

	function icoSupply()public view returns(uint256) {
		return _icoSupply;
	}

}

 
contract Crowdsale {
	using SafeMath for uint256;

	 
	AumonetToken public token;

	 
	uint public start;  
	uint public end;  
	uint256 increaseTime;  
	 
	address public wallet;

	 
	 
	uint256 public ethRate;

	 
	uint256 public totalWeiRaised;  

	uint256 public tokensSold;  

	bool public crowdsaleClosed = false;  


	 
	event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

	 
	constructor(address _wallet, uint _startICO, uint _endICO)public {
		require(_wallet != address(0));

		token = new AumonetToken();  
		ethRate = 124;  
		totalWeiRaised = 0;
		tokensSold = 0;
		start = _startICO;  
		end = _endICO;  
		increaseTime = 0;
		wallet = _wallet;
	}

	modifier afterDeadline() {
		increaseTime = token.pauseTime();
		require(block.timestamp > end.add(increaseTime));
		_;
	}

	 
	 
	 

	 
	function ()external payable {
		buyTokens(msg.sender);
	}

	 
	function buyTokens(address _beneficiary)public payable {}

	 
	 
	 

	 
	function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)internal {
		require(_beneficiary != address(0));
		require(_weiAmount != 0);
		increaseTime = token.pauseTime();
		require(!crowdsaleClosed && block.timestamp >= start.add(increaseTime) && block.timestamp <= end.add(increaseTime));
	}

	 
	function _deliverTokens(address _beneficiary, uint256 _tokenAmount)internal {
		token.transfer(_beneficiary, _tokenAmount);
	}

	 
	function _getTokenAmount(uint256 _weiAmount)internal view returns(uint256) {
		_weiAmount = _weiAmount.mul(ethRate).div(100);
		return _weiAmount.div(10 ** uint(18 - token.decimals()));  
	}

	 
	function _forwardFunds()internal {
		wallet.transfer(msg.value);
	}

	 
	function hasEnded()public returns(bool) {
		increaseTime = token.pauseTime();
		return now > end.add(increaseTime);
	}
}

 
contract FinalizableCrowdsale is Crowdsale, Ownable {

	bool public isFinalized = false;

    event Finalized();

	constructor()Ownable()public {}

	 
	function withdrawTokens()onlyOwner public returns(bool) {
		require(token.transfer(owner, token.balanceOf(this)));
		return true;
	}

	 
	function finalize()onlyOwner afterDeadline public {
		require(!crowdsaleClosed);

		emit Finalized();
		withdrawTokens();

		crowdsaleClosed = true;
		isFinalized = true;
	}

	 
	function finalization()internal {}
}

contract AumonetICO is FinalizableCrowdsale {
	using SafeMath for uint256;

	uint256 public BONUS_TOKENS = 18700000000;
	 
	uint256 startOfFirstBonus;
	uint256 endOfFirstBonus;
	uint256 startOfSecondBonus;
	uint256 endOfSecondBonus;
	uint256 startOfThirdBonus;
	uint256 endOfThirdBonus;
	uint256 startOfFourthBonus;
	uint256 endOfFourthBonus;
	uint256 startOfFifthBonus;
	uint256 endOfFifthBonus;

	 
	uint256 firstBonus = 30;
	uint256 secondBonus = 25;
	uint256 thirdBonus = 20;
	uint256 fourthBonus = 15;
	uint256 fifthBonus = 10;
	uint256 sixthBonus = 3;

	constructor(address _wallet, uint _startICO, uint _endICO)FinalizableCrowdsale()Crowdsale(_wallet, _startICO, _endICO)public {
		 
		startOfFirstBonus = _startICO;
		endOfFirstBonus = (startOfFirstBonus - 1) + 8 days;
		startOfSecondBonus = (startOfFirstBonus + 1) + 8 days;
		endOfSecondBonus = (startOfSecondBonus - 1) + 8 days;
		startOfThirdBonus = (startOfSecondBonus + 1) + 8 days;
		endOfThirdBonus = (startOfThirdBonus - 1) + 8 days;
		startOfFourthBonus = (startOfThirdBonus + 1) + 8 days;
		endOfFourthBonus = (startOfFourthBonus - 1) + 8 days;
		startOfFifthBonus = (startOfFourthBonus + 1) + 8 days;
		endOfFifthBonus = (startOfFifthBonus - 1) + 8 days;

	}

	event BonusCalculated(uint256 tokenAmount);
	event BonusSent(address indexed from, address indexed to, uint256 boughtTokens, uint256 bonusTokens);

	modifier beforeICO() {
		increaseTime = token.pauseTime();
		require(block.timestamp <= start.add(increaseTime));
		_;
	}

	 
	function setPreICOSoldAmount(uint256 _soldTokens, uint256 _raisedWei)onlyOwner beforeICO public {
		tokensSold = tokensSold.add(_soldTokens);
		totalWeiRaised = totalWeiRaised.add(_raisedWei);
	}

	 
	function getBonusTokens(uint256 _tokenAmount)public returns(uint256) {
		increaseTime = token.pauseTime();
		if (block.timestamp >= startOfFirstBonus.add(increaseTime) && block.timestamp <= endOfFirstBonus.add(increaseTime)) {
			_tokenAmount = _tokenAmount.mul(firstBonus).div(100);
		} else if (block.timestamp >= startOfSecondBonus.add(increaseTime) && block.timestamp <= endOfSecondBonus.add(increaseTime)) {
			_tokenAmount = _tokenAmount.mul(secondBonus).div(100);
		} else if (block.timestamp >= startOfThirdBonus.add(increaseTime) && block.timestamp <= endOfThirdBonus.add(increaseTime)) {
			_tokenAmount = _tokenAmount.mul(thirdBonus).div(100);
		} else if (block.timestamp >= startOfFourthBonus.add(increaseTime) && block.timestamp <= endOfFourthBonus.add(increaseTime)) {
			_tokenAmount = _tokenAmount.mul(fourthBonus).div(100);
		} else if (block.timestamp >= startOfFifthBonus.add(increaseTime) && block.timestamp <= endOfFifthBonus.add(increaseTime)) {
			_tokenAmount = _tokenAmount.mul(fifthBonus).div(100);
		} else
			_tokenAmount = _tokenAmount.mul(sixthBonus).div(100);
		emit BonusCalculated(_tokenAmount);
		return _tokenAmount;
	}

	 
	function buyTokens(address _beneficiary)public payable {
		uint256 weiAmount = msg.value;
		_preValidatePurchase(_beneficiary, weiAmount);

		uint256 tokens = _getTokenAmount(weiAmount);  

		require(token.balanceOf(this) >= tokens);  

		totalWeiRaised = totalWeiRaised.add(weiAmount);  
		tokensSold = tokensSold.add(tokens);  

		_deliverTokens(_beneficiary, tokens);
		emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);
		_processBonus(msg.sender, tokens);

		_forwardFunds();
	}

	 
	function _processBonus(address _beneficiary, uint256 _tokenAmount)internal {
		uint256 bonusTokens = getBonusTokens(_tokenAmount);  
		if (BONUS_TOKENS < bonusTokens) {  
			bonusTokens = BONUS_TOKENS;
		}
		if (bonusTokens > 0) {  
			BONUS_TOKENS = BONUS_TOKENS.sub(bonusTokens);
			token.transfer(_beneficiary, bonusTokens);
			emit BonusSent(address(token), _beneficiary, _tokenAmount, bonusTokens);
			tokensSold = tokensSold.add(bonusTokens);  
		}
	}

	function transferTokenOwnership(address _newOwner)public {
		token.transferOwnership(_newOwner);
	}

	function finalization()internal {
		token.transferOwnership(wallet);
	}

}