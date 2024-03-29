pragma solidity ^0.4.25;


contract Prosperity {
	
	 
    function transfer(address _toAddress, uint256 _amountOfTokens) public returns(bool);
	
	 
	function myTokens() public view returns(uint256);
	
	  
    function myDividends(bool _includeReferralBonus) public view returns(uint256);
	
	 
    function buy(address _referredBy) public payable returns(uint256);
	
	 
    function withdraw() public;
	
	 
	function reinvest() public;
	
	 
	function() payable external;
}


 
contract Lending {
	using SafeMath for *;
	
	     
     
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
	
	
	 	
	modifier onlyTokenContract {
        require(msg.sender == address(tokenContract_));
        _;
    }
	
	 
     
     
     
     
     
     
     
     
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrator_ == _customerAddress);
        _;
    }
	
	
	 
     
    mapping(address => Dealer) internal dealers_; 	 
    uint256 internal totalDeposit_ = 0;
	
	 
	Prosperity public tokenContract_;
	
	 
    address internal administrator_;
	
	 
	struct Dealer {
		uint256 deposit;		 
		uint256 profit;			 
		uint256 time;			 
	}
	
	
	 
	function reinvestEther()
		internal
	{
		uint256 _balance = address(this).balance;
		if (_balance >= 1e17) {		 
			 
			address(tokenContract_).transfer(_balance);
		}
		
		uint256 _dividends = myDividends(true);
		if (_dividends >= 1e17) {	 
			tokenContract_.reinvest();
		}
	}
	
	function myDividends(bool _includeReferralBonus)
		internal
		view
		returns(uint256)
	{
		return tokenContract_.myDividends(_includeReferralBonus);
	}
    
	
	 
    constructor() public {
		administrator_ = 0x6bca7e1EC8595B2f0F4D7Ff578F1D25643004825;
    }
	
	function() payable external {
		 
		 
	}
	
	 
    function tokenFallback(address _from, uint256 _value, bytes _data)
		onlyTokenContract()
		external
		returns (bool)
	{
         
		Dealer storage _dealer = dealers_[_from];
		
		 
		_dealer.profit = myProfit(_from);	 
		_dealer.time = now;					 
        
		 
		_dealer.deposit = _dealer.deposit.add(_value);
		totalDeposit_ = totalDeposit_.add(_value);
		
		return true;
		
		 
		_data;
	}
	
	 
	function reinvestProfit() public {
		address _customerAddress = msg.sender;
		Dealer storage _dealer = dealers_[_customerAddress];
		
		uint256 _profits = myProfit(_customerAddress);
		
		 
		_dealer.deposit = _dealer.deposit.add(_profits);	 
		_dealer.profit = 0;									 
		_dealer.time = now;									 
		
		 
		reinvestEther();
		
		 
		totalDeposit_ = totalDeposit_.add(_profits);
	}
	
	 
	function withdrawProfit() public {
		address _customerAddress = msg.sender;
		Dealer storage _dealer = dealers_[_customerAddress];
		
		uint256 _profits = myProfit(_customerAddress);
		
		 
		_dealer.profit = 0;		 
		_dealer.time = now;		 
		
		 
		reinvestEther();
		
		 
		tokenContract_.transfer(_customerAddress, _profits);
	}
	
	function withdrawCapital() public {
		address _customerAddress = msg.sender;
		Dealer storage _dealer = dealers_[_customerAddress];
		
		uint256 _deposit = _dealer.deposit;
		uint256 _taxedDeposit = _deposit.mul(75).div(100);
		uint256 _profits = myProfit(_customerAddress);
		
		 
		_dealer.deposit = 0;
		_dealer.profit = _profits;
		
		 
		 
		 
		totalDeposit_ = totalDeposit_.sub(_deposit);
		
		 
		tokenContract_.transfer(_customerAddress, _taxedDeposit);
	}
	
	
	 	
     
    function totalDeposit()
        public
        view
        returns(uint256)
    {
        return totalDeposit_;
    }
	
	 
    function totalSupply()
        public
        view
        returns(uint256)
    {
        return tokenContract_.myTokens();
    }
	
	function surplus()
		public
		view
		returns(int256)
	{
		uint256 _tokens = totalSupply();
		
		 
		if (totalDeposit_ > 0) {
			 
			 
			return int256((1000).mul(_tokens).div(totalDeposit_) - 1000);
		} else {
			return 1000;	 
		}
	}
	
	 
    function myDeposit()
        public
        view
        returns(uint256)
    {
		address _customerAddress = msg.sender;
        Dealer storage _dealer = dealers_[_customerAddress];
        return _dealer.deposit;
    }
	
	 
	function myProfit(address _customerAddress)
		public
		view
		returns(uint256)
	{
		Dealer storage _dealer = dealers_[_customerAddress];
		uint256 _oldProfits = _dealer.profit;
		uint256 _newProfits = 0;
		
		if (
			 
			_dealer.time == 0 ||
			
			 
			_dealer.deposit == 0
		)
		{
			_newProfits = 0;
		} else {
			 
			uint256 _timeLending = now - _dealer.time;
			
			_newProfits = _timeLending	 
				.mul(_dealer.deposit)	 
				.mul(1337)				 
				.div(100000)			 
				.div(86400);			 
		}
		
		 
		return _newProfits + _oldProfits;
	}
	
	 
	function setTokenContract(address _tokenContract)
		onlyAdministrator()
		public
	{
		tokenContract_ = Prosperity(_tokenContract);
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