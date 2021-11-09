pragma solidity ^0.4.24;

contract RentAFlat {
	address public owner;
	uint public flatId;
	uint public ownerBalanceOf;
	uint public balanceToDistribute;

	RentStatus currentRentStatus;
	address currentTenantAddress;
	uint currentRentStartTime;
	uint currentRentRequiredEndTime;
	uint rentValue;

	enum RentStatus {
		Available,
		Rented,
		 
		Unavailable
	}

	event RentFlatDaily(address _currentTenantAddress, uint _rentValue, uint _rentalStart, uint _rentalEnd);
	event EndRentFlatDaily(address _currentTenantAddress, uint _rentalEnd, bool _endedInTime);

	constructor(uint _flatId, uint _rentValue) public {
		require(_flatId > 0);

		owner  			  = msg.sender;
		flatId 			  = _flatId;
		rentValue   	  = _rentValue;
		currentRentStatus = RentStatus.Available;
	}

	function rentFlatDaily(uint _daysToRent) public payable {
		 
		require (currentRentStatus == RentStatus.Available && currentRentStatus != RentStatus.Unavailable);

		 
		 
		require (msg.value == rentValue * _daysToRent);

		 
		currentTenantAddress = msg.sender;

		 
		currentRentStatus = RentStatus.Rented;

		 
		currentRentStartTime = now;

		 
		currentRentRequiredEndTime = now + (_daysToRent * 1 days);

		 
		balanceToDistribute = msg.value;

		emit RentFlatDaily(currentTenantAddress, msg.value, currentRentStartTime, currentRentRequiredEndTime);
	}

	function activateFlat(address _tenant, uint _flatId) public view returns(bool) {
		 
		require(_tenant == currentTenantAddress && _flatId == flatId);

		return true;
	}

	function endRentFlatDaily() public {
		 
		 
		require ((msg.sender == owner && now > currentRentRequiredEndTime) || (msg.sender == currentTenantAddress));

		 
		require(currentRentStatus == RentStatus.Rented);

		 
		bool endedInTime = now <= currentRentRequiredEndTime;

		emit EndRentFlatDaily(currentTenantAddress, now, endedInTime);

		 
		currentTenantAddress = address(0);

		 
		currentRentStatus = RentStatus.Available;

		 
		currentRentStartTime  	   = 0;
		currentRentRequiredEndTime = 0;

		 
		setOwnerEarnings();
	}

	function setUnavailableFlat() public returns(bool) {
		 
		require(owner == msg.sender);

		 
		require(currentRentStatus == RentStatus.Available);

		currentRentStatus = RentStatus.Unavailable;

		return true;
	}

	function setAvailableFlat() public returns(bool) {
		 
		require(owner == msg.sender);

		 
		require(currentRentStatus == RentStatus.Unavailable);

		currentRentStatus = RentStatus.Available;

		return true;
	}	

	function setOwnerEarnings() internal {
		uint ownerEarnings  = balanceToDistribute;
		balanceToDistribute = 0;
		ownerBalanceOf      = ownerEarnings;
	}

	function withdraw() public {
		 
		require(owner == msg.sender);

		uint balanceToWithdraw = ownerBalanceOf;
		require(balanceToWithdraw > 0);

		ownerBalanceOf = 0;
		msg.sender.transfer(balanceToWithdraw);
	}
}