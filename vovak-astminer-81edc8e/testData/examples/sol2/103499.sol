 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
pragma solidity ^0.6.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
 
 
contract LN2tBTC {

	 
	 
	 
	 

	 
	 
	 
	 
	 
	 
	struct Operator {
		 
		string publicUrl;
		 
		 
		 
		 
		 
		 
		 
		uint tBTCBalance;
		 
		 
		 
		 
		uint lnBalance;
		 
		 
		bool exists;
		 
		 
		uint linearFee;
		 
		uint constantFee;
		 
	}

	 
	 
	 
	uint constant linearFeeDenominator = 10**8;
	 
	uint constant tBTCDenominator = 10**10;

	 
	 
	mapping (address => Operator) public operators;
	 
	address[] public operatorList;
	 
	IERC20 tBTContract = IERC20(0x8dAEBADE922dF735c38C80C7eBD708Af50815fAa);

	 
	 
	 
	function operatorRegister(uint tBTCBalance, uint lnBalance, uint linearFee, uint constantFee, string memory publicUrl) public {
		require(operators[msg.sender].exists==false, "Operator has already been registered before");
		operators[msg.sender] = Operator(publicUrl, tBTCBalance, lnBalance, true, linearFee, constantFee);
		if(tBTCBalance > 0){
			tBTContract.transferFrom(msg.sender, address(this), tBTCBalance);
		}
		operatorList.push(msg.sender);
	}

	 
	 
	function getOperatorListLength() view public returns(uint length){
		return operatorList.length;
	}

	 
	function operatorWithdrawTBTC(uint amount) public returns(bool){
		Operator storage op = operators[msg.sender];
		require(op.tBTCBalance >= amount);
		op.tBTCBalance -= amount;
		tBTContract.transfer(msg.sender, amount);
		return true;
	}

	 
	 
	function operatorDepositTBTC(uint amount) public returns(bool){
		Operator storage op = operators[msg.sender];
		require(op.exists == true);  
		op.tBTCBalance += amount;
		tBTContract.transferFrom(msg.sender, address(this), amount);
		return true;
	}

	 
	function operatorSetFees(uint newLinearFee, uint newConstantFee) public {
		operators[msg.sender].linearFee = newLinearFee;
		operators[msg.sender].constantFee = newConstantFee;
	}

	 
	 
	function operatorSetLNBalance(uint newLNBalance) public {
		operators[msg.sender].lnBalance = newLNBalance;
	}

	 
	function operatorSetPublicUrl(string memory newUrl) public {
		operators[msg.sender].publicUrl = newUrl;
	}

	 
	 
	 
	 
	 
	 
	 
	 
	 
	 

	 
	 
	uint public timeoutPeriod = 1 hours;

	struct TBTC2LNSwap {
		 
		address provider;
		 
		 
		uint tBTCAmount;
		 
		 
		 
		uint timeoutTimestamp;
	}

	 
	 
	 
	 
	mapping (address => mapping (bytes32 => TBTC2LNSwap)) public tbtcSwaps;

	 
	event TBTC2LNSwapCreated(bytes32 paymentHash, uint amount, address userAddress, address providerAddress, uint lockTime, string invoice);

	 
	 
	 
	 
	 
	 
	function createTBTC2LNSwap(bytes32 paymentHash, uint amount, address providerAddress, uint lockTime, string memory invoice) public {
		require(tbtcSwaps[msg.sender][paymentHash].timeoutTimestamp == 0, "Swap already exists");
		tbtcSwaps[msg.sender][paymentHash] = TBTC2LNSwap(providerAddress, amount, now + lockTime);
		tBTContract.transferFrom(msg.sender, address(this), amount);
		emit TBTC2LNSwapCreated(paymentHash, amount, msg.sender, providerAddress, lockTime, invoice);
	}

	 
	 
	 
	 
	function revertTBTC2LNSwap(bytes32 paymentHash) public {
		TBTC2LNSwap storage swap = tbtcSwaps[msg.sender][paymentHash];
		require(swap.timeoutTimestamp != 0, "Swap doesn't exist");
		require(swap.tBTCAmount > 0, "Swap has already been finalized");
		require(swap.timeoutTimestamp < now, "Swap hasn't timed out yet");
		uint tBTCAmount = swap.tBTCAmount;
		swap.tBTCAmount = 0;
		tBTContract.transfer(msg.sender, tBTCAmount);
	}

	 
	 
	 
	function operatorClaimPayment(address userAddress, bytes32 paymentHash, bytes memory preimage) public {
		TBTC2LNSwap storage swap = tbtcSwaps[userAddress][paymentHash];
		require(swap.provider == msg.sender, "Swap doesn't use this provider or doesn't exist at all");
		require(swap.tBTCAmount > 0, "Swap has already been finalized");
		require(sha256(preimage) == paymentHash, "Preimage doesn't match the payment hash");
		Operator storage operator = operators[msg.sender];
		operator.tBTCBalance += swap.tBTCAmount;
		swap.tBTCAmount = 0;
		 
		 
		 
		 
		operator.lnBalance -= removeFees(swap.tBTCAmount/tBTCDenominator, operator.linearFee, operator.constantFee); 
	}

	 
	 
	function removeFees(uint amount, uint linearFee, uint constantFee) pure public returns (uint amountWithoutFees){
		return ((amount - constantFee)*linearFeeDenominator)/(linearFeeDenominator+linearFee);
	}

	 
	 
	 

	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	uint public securityDepositAmount = 1 ether;

	struct LN2TBTCSwap {
		 
		address provider;
		 
		 
		 
		uint tBTCAmount;
		 
		 
		 
		uint startTimestamp;
		 
		 
		uint tBTCLockTimestamp;
	}

	 
	mapping (address => mapping (bytes32 => LN2TBTCSwap)) public lnSwaps;

	 
	event LN2TBTCSwapCreated(address userAddress, bytes32 paymentHash, address providerAddress, uint tBTCAmount);
	 
	event LN2TBTCOperatorLockedTBTC(address userAddress, bytes32 paymentHash);
	 
	event LN2TBTCPreimageRevealed(address userAddress, bytes32 paymentHash, address providerAddress, bytes preimage);

	 
	 
	 
	function createLN2TBTCSwap(bytes32 paymentHash, address providerAddress, uint tBTCAmount) payable public {
		require(lnSwaps[msg.sender][paymentHash].startTimestamp == 0, "Swap already exists");
		require(msg.value == securityDepositAmount, "ETH security deposit provided isn't the right amount (should be 1 ETH)");
		require(tBTCAmount > 0, "The amount requested cannot be zero (why swap something for nothing?)");
		lnSwaps[msg.sender][paymentHash] = LN2TBTCSwap(providerAddress, tBTCAmount, now, 0);
		emit LN2TBTCSwapCreated(msg.sender, paymentHash, providerAddress, tBTCAmount);
	}

	 
	 
	function revertLN2TBTCSwap(bytes32 paymentHash) public {
		LN2TBTCSwap storage swap = lnSwaps[msg.sender][paymentHash];
		require(swap.tBTCAmount > 0, "Swap doesn't exist or has already been finalized");
		require((swap.startTimestamp + timeoutPeriod) < now, "Swap hasn't timed out yet");
		require(swap.tBTCLockTimestamp == 0, "Operator has locked the tBTC tokens before the timeout");
		swap.tBTCAmount = 0;
		msg.sender.transfer(securityDepositAmount);  
	}

	 
	function operatorLockTBTCForLN2TBTCSwap(address userAddress, bytes32 paymentHash) public {
		LN2TBTCSwap storage swap = lnSwaps[userAddress][paymentHash];
		require(swap.provider == msg.sender, "Swap doesn't use this provider or doesn't exist at all");
		require(swap.tBTCAmount > 0, "Swap has already been finalized");
		require(swap.tBTCLockTimestamp == 0, "tBTC tokens have already been locked before for this swap");
		Operator storage op = operators[msg.sender];
		require(op.tBTCBalance >= swap.tBTCAmount, "Operator doesn't have enough funds to conduct the swap");
		op.tBTCBalance -= swap.tBTCAmount;
		swap.tBTCLockTimestamp = now;
		emit LN2TBTCOperatorLockedTBTC(userAddress, paymentHash);
	}

	 
	 
	 
	 
	function operatorRevertLN2TBTCSwap(address userAddress, bytes32 paymentHash) public {
		LN2TBTCSwap storage swap = lnSwaps[userAddress][paymentHash];
		require(swap.provider == msg.sender, "Swap doesn't use this provider or doesn't exist at all");
		require(swap.tBTCAmount > 0, "Swap has already been finalized");
		require(swap.tBTCLockTimestamp != 0, "tBTC tokens have not been locked for this swap");
		require((swap.tBTCLockTimestamp + timeoutPeriod) < now, "Swap hasn't timed out yet");
		operators[msg.sender].tBTCBalance += swap.tBTCAmount;
		swap.tBTCAmount = 0;
		msg.sender.transfer(securityDepositAmount);  
	}

	 
	function claimTBTCPayment(bytes32 paymentHash, bytes memory preimage) public {
		LN2TBTCSwap storage swap = lnSwaps[msg.sender][paymentHash];
		require(swap.tBTCAmount > 0, "Swap doesn't exist or has already been finalized");
		require(swap.tBTCLockTimestamp != 0, "tBTC tokens have not been locked for this swap");
		require(sha256(preimage) == paymentHash, "Preimage doesn't match the payment hash");
		uint tBTCAmount = swap.tBTCAmount;
		swap.tBTCAmount = 0;
		tBTContract.transfer(msg.sender, tBTCAmount);
		msg.sender.transfer(securityDepositAmount);  
		Operator storage op = operators[swap.provider];
		 
		 
		op.lnBalance += addFees(tBTCAmount/tBTCDenominator, op.linearFee, op.constantFee);  
		emit LN2TBTCPreimageRevealed(msg.sender, paymentHash, swap.provider, preimage);
	}

	 
	 
	function addFees(uint amount, uint linearFee, uint constantFee) pure public returns (uint amountWithFees){
		return (amount * (linearFeeDenominator + linearFee))/linearFeeDenominator + constantFee;
	}
}