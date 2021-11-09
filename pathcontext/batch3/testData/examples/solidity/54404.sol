pragma solidity ^0.4.25;


contract Wargame {
    using SafeMath for *;
    
     
    modifier onlyAdministrator() {
        address _customerAddress = msg.sender;
        require(administrator_ == _customerAddress);
        _;
    }
	
	modifier roundRunning() {
	    require(now >= roundStart_);	 
		require(
		    now <= roundEnd_  			 
		    ||
			roundStart_ == roundEnd_ &&	             
			roundStart_ != 0 && roundEnd_ != 0	     
		);
		_;
	}
    
    
     
    event onCardFlip(
        uint8 index,
        address indexed owner,
        uint256 price,
		uint256 timeEnd
    );
    
    
     
     
    uint256 internal baseTenMinutes_ = 10 minutes;
    uint256 internal baseOneMinutes_ = 2 minutes;
    
     
    uint256 internal initialPrice_ = 0.005 ether;
	
	 
	uint256 internal fundFee_ = 3;	 
    
     
    uint256 internal countdown_ = 5 minutes;
    
     
     
     
     
    bool internal contractActivated_ = false;
    
    
     
    address internal administrator_;     
    address internal currentWinner_;     
	address internal fundAddress_;       
	uint256 internal etherToFund_;		 
    
     
    Card[12] internal nations_;          
    
     
    uint256 public roundEnd_;            
    uint256 public roundStart_;          
    
    
     
    function initCards()
		internal 
	{
        for (uint8 i = 0; i < nations_.length; i++) {
            Card storage _nation = nations_[i];
            uint256 _baseTenMinutes = uint256((i/4) + 1) * baseTenMinutes_;
            uint256 _column = (i%4);
            uint256 _baseOneMinutes = _column * baseOneMinutes_;
            
             
            _nation.time = _baseTenMinutes + _baseOneMinutes;
        }
    }
    
     
    function resetCards() 
		internal 
	{
        for (uint8 i = 0; i < nations_.length; i++) {
            Card storage _nation = nations_[i];
            
             
            _nation.price = initialPrice_;   
            _nation.owner = address(this);   
        }
    }
    
     
    function setCard(Card storage _nation, address _buyer)
        internal 
    {
         
        _nation.price = _nation.price * 2;   
        _nation.owner = _buyer;              
    }
	
	function setNewRound() 
		internal 
	{
		 
		resetCards();
		currentWinner_ = address(0x0);
		roundStart_ = now + countdown_;
		roundEnd_   = roundStart_;
		etherToFund_ = 0;
	}
    
     
    function _buyNationInternal(uint8 _index, uint256 _value)
		roundRunning()
        internal
    {		
        Card storage _nation = nations_[_index];
        
        address _buyer = msg.sender;     
        address _owner = _nation.owner;  
        require(_buyer != _owner);       
        
         
         
         
        uint256 _ethToOwner = _value.mul(5).div(8);     	 
		uint256 _ethToFund = _value.mul(fundFee_).div(100);	 
		etherToFund_ = etherToFund_.add(_ethToFund);		 
        
         
         
        if (_nation.price != initialPrice_) {
            _owner.transfer(_ethToOwner);    
        }
        
        setCard(_nation, _buyer);    
        
         
        currentWinner_ = _buyer;             
        roundEnd_ = now + _nation.time;      
        
         
        emit onCardFlip(_index, _buyer, _nation.price, roundEnd_);
    }
	
	function deliveryService(uint256 _balance, uint256 _winnings, uint256 _fund) 
		internal 
	{
		 
		if (_balance > 0) {
			if (currentWinner_ != address(0x0)) {
				currentWinner_.transfer(_winnings);	 
				fundAddress_.transfer(_fund);		 
			}
		}
	}
    
    
     
    constructor() 
        public
    {
        administrator_ = 0x6bca7e1EC8595B2f0F4D7Ff578F1D25643004825;
        fundAddress_ = 0x6bca7e1EC8595B2f0F4D7Ff578F1D25643004825;
        
        initCards();
        resetCards();
    }
    
     
    function() public payable {}
    
     
    function startRound()
        public
    {
		 
        uint256 _balance  = address(this).balance;      		 
		uint256 _fund     = etherToFund_;						 
		uint256 _nextPot  = _balance.sub(_fund).div(4);			 
        uint256 _winnings = _balance.sub(_fund).sub(_nextPot);   
		
		 
		if (now > roundEnd_ && 			 
			roundStart_ != roundEnd_	 
			||
			roundStart_ == 0 && roundEnd_ == 0	 
		){
		     
    		if (contractActivated_) {			
    			 
    			deliveryService(_balance, _winnings, _fund);
    			setNewRound();
    		} else {	 
    			 
    			require(currentWinner_ != address(0x0));
    			deliveryService(_balance, _winnings, _balance.sub(_winnings));
    			
    			 
    			etherToFund_ = 0;    
    			currentWinner_ = address(0x0);
    		}	
		} else {
			 
			revert();
		}
    }
    
     
    function buyNation(uint8 _index)
        public
        payable
    {		
        Card storage _nation = nations_[_index];
        uint256 _value = msg.value;
        
         
        require(_value == _nation.price, "Nation has already been bought");
        
		_buyNationInternal(_index, _value);
    }
    
     
    function overbidNation(uint8 _index)
        public 
        payable
    {		
        Card storage _nation = nations_[_index];
        uint256 _value = msg.value;
        
         
        require(_value >= _nation.price, "Nation has already been bought");
        uint256 _nationValue = _nation.price;  
        
        _buyNationInternal(_index, _nationValue);
        
         
        uint256 _excess = _value.sub(_nationValue);
		
		 
        if (_excess > 0) {
            address _buyer = msg.sender;
            _buyer.transfer(_excess);
        }
    }
    
     
    function getNation(uint8 _index)
        public 
        view 
        returns(uint256, uint256, address)
    {
        Card storage _nation = nations_[_index];
        return (_nation.price, _nation.time, _nation.owner);
    }
	
	function getCurrentWinner()
		public
		view
		returns(address)
	{
		return currentWinner_;
	}
    
     
    function setGameStatus(bool _active) 
        onlyAdministrator()
        public
    {
        contractActivated_ = _active;
    }
    
    
     
    struct Card {
        uint256 price;
        uint256 time;
        address owner;
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