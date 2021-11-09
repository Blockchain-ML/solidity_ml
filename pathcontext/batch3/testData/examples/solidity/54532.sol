pragma solidity ^0.4.24;

contract Token {

	function transfer( address _to, uint256 _value ) public returns ( bool success );

	function transferFrom( address _from, address _to, uint256 _value ) public returns ( bool success );

	event Transfer( address indexed _from, address indexed _to, uint256 _value );

}

library SafeMath {

	 
	function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
		require(_b <= _a);
		uint256 c = _a - _b;

		return c;
	}

	 
	function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
		uint256 c = _a + _b;
		require(c >= _a);

		return c;
	}
}

 
contract Ownable {

	address public _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	 
	constructor() public {
		_owner = msg.sender;
	}

	 
	function transferOwnership(address newOwner) onlyOwner() public {
		require(newOwner != _owner);
		_transferOwnership(newOwner);
	}

	 
	function _transferOwnership(address newOwner) internal {
		require(newOwner != address(0));
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}

	 
	modifier onlyOwner() {
		require(msg.sender == _owner, "Error: msg.sender is not owner");
		_;
	}
}

contract 	Admins is Ownable {

	mapping(address => bool) internal _moderators;

	 
	constructor() public {
		_moderators[msg.sender] = true;
	}

	function	changeStatusModerator(
		address user,
		bool status
	)
		public
		notNullAddress(user)
		onlyOwner()
	{
		_moderators[user] = status;
	}

	 
	modifier onlyModerator() {
		require(_moderators[msg.sender] == true, "Error: msg.sender is not moderator");
		_;
	}

	 
	modifier notNullAddress(address user) {
		require(user != address(0x0));
		_;
	}

	 
	function 	getStatusModerator(address user) public view returns (bool) {
		return 	(_moderators[user]);
	}
}

contract EscrowToken is Admins {

	address public _token = 0x04e3bb06DC39f2edCB073DAD327fCc13ed40d280;

	using SafeMath for uint;

	mapping(address => uint) public _balanceOf;
	mapping(address => uint) public _freezeBalanceOf;

	address public _liquidatePool;

	event Deposit(address user, uint amountDeposit, uint balanceNow);

	event FreezeDeposit(address user, uint amountDeposit, uint balanceOfUser, uint freezeBalanceOf);

	event FreezeWithdraw(address user, uint amountWithdraw, bool status, uint balanceOfUser, uint freezeBalanceOfUser);

	event Withdraw(address user, uint amountWithdraw, uint balanceNow);

	constructor() public {
		_liquidatePool = msg.sender;
	}

	function 	depositToken(uint amount) notZero(amount) public {
		_balanceOf[msg.sender] = _balanceOf[msg.sender].add(amount);
		if (Token(_token).transferFrom(msg.sender, this, amount) == false) {
			revert();
		}
		emit Deposit(msg.sender, amount , _balanceOf[msg.sender]);
	}


	function 	withdrawTokenForUser(uint amount) notZero(amount) public {
		_balanceOf[msg.sender] = _balanceOf[msg.sender].sub(amount);
		if (Token(_token).transfer(msg.sender, amount) == false) {
			revert();
		}
		emit Withdraw(msg.sender, amount, _balanceOf[msg.sender]);
	}

	function 	freezeDeposit(uint amount) notZero(amount) public {
		require(_balanceOf[msg.sender] >= amount);

		_balanceOf[msg.sender] = _balanceOf[msg.sender].sub(amount);
		_freezeBalanceOf[msg.sender] = _freezeBalanceOf[msg.sender].add(amount);
		_balanceOf[_liquidatePool] = _balanceOf[_liquidatePool].add(amount);
		emit FreezeDeposit(msg.sender, amount, _balanceOf[msg.sender], _freezeBalanceOf[msg.sender]);
	}

	function 	freezeWithdraw(
		address user,
		uint amount,
		bool status
	)
		notNullAddress(user)
		notZero(amount)
		onlyModerator()
		public
	{
		if (status == true) {  
			_balanceOf[user] = _balanceOf[user].add(amount);
			_balanceOf[_liquidatePool] = _balanceOf[_liquidatePool].sub(amount);
		}
		_freezeBalanceOf[user] = _freezeBalanceOf[user].sub(amount);
		emit FreezeWithdraw(user, amount, status, _balanceOf[user], _freezeBalanceOf[user]);
	}

	function 	withdrawLiquidatePool(uint amount) notZero(amount) onlyOwner() public {
		_balanceOf[_liquidatePool] = _balanceOf[_liquidatePool].sub(amount);
		if (Token(_token).transfer(msg.sender, amount) == false) {
			revert();
		}
	}

	function 	depositLiquidateThePool(uint amount) notZero(amount) public {
		_balanceOf[_liquidatePool] = _balanceOf[_liquidatePool].add(amount);
		if (Token(_token).transferFrom(msg.sender, this, amount) == false) {
			revert();
		}
	}

	modifier 	notZero(uint amount) {
		require(amount != 0);
		_;
	}
}