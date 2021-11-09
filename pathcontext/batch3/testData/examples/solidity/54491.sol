pragma solidity ^0.4.25;


contract Wargame {
    using SafeMath for *;
    
     
    modifier onlyAdministrator() {
        address _customerAddress = msg.sender;
        require(administrator_ == _customerAddress);
        _;
    }
    
    modifier gameActivated() {
        require(contractActivated_);
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
    
     
    uint256 internal countdown_ = 5 minutes;
    
     
     
     
     
    bool internal contractActivated_ = false;
    
    
     
    address internal administrator_;     
    address internal fundAddress_;       
    address internal currentWinner_;     
    
     
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
		roundEnd_   = 0;
	}
    
     
    function _buyNationInternal(uint8 _index, uint256 _value)
        internal
    {
		 
		if (now > roundEnd_ && roundEnd_ > 0) {
			revert();				 
		}
		
        Card storage _nation = nations_[_index];
        
        address _buyer = msg.sender;     
        address _owner = _nation.owner;  
        require(_buyer != _owner);       
        
         
         
         
        uint256 _ethToOwner = _value.mul(5).div(8);      
        
         
         
        if (_nation.price != initialPrice_) {
            _owner.transfer(_ethToOwner);    
        }
        
        setCard(_nation, _buyer);    
        
         
        currentWinner_ = _buyer;             
        roundEnd_ = now + _nation.time;      
        
         
        emit onCardFlip(_index, _buyer, _nation.price, roundEnd_);
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
        uint256 _winnings = _balance.mul(69).div(100);   
        uint256 _fund     = _balance.mul(6).div(100);    
		
		 
		if (!contractActivated_) {
			 
			require(currentWinner_ != address(0x0));
			
			if (_balance > 0) {
				currentWinner_.transfer(_winnings);
				_balance = _balance.sub(_winnings);
				fundAddress_.transfer(_balance);
			}
		} else {
			 
			if (now > roundEnd_ && roundEnd_ > 0) {
				currentWinner_.transfer(_winnings);
				fundAddress_.transfer(_fund);
				
				 
				setNewRound();
				return;
			}
			
			 
			if (roundStart_ == 0) {
				setNewRound();
			}
		}
    }
    
     
    function buyNation(uint8 _index)
		gameActivated()
        public
        payable
    {		
        Card storage _nation = nations_[_index];
        uint256 _value = msg.value;
        
         
        require(_value == _nation.price, "Nation has already been bought");
        
        _buyNationInternal(_index, _value);
    }
    
     
    function overbidNation(uint8 _index)
		gameActivated()
        public 
        payable
    {		
        Card storage _nation = nations_[_index];
        uint256 _value = msg.value;
        
         
        require(_value >= _nation.price, "Nation has already been bought");
        _value = _nation.price;  
        
        _buyNationInternal(_index, _value);
        
         
         
         
        uint256 _ethToOwner = _value.mul(5).div(8);      
        uint256 _ethToFund  = _value.mul(6).div(100);    
        uint256 _ethToPot   = _value.mul(63).div(200);   
        
         
        uint256 _overbid = msg.value.sub(_ethToOwner).sub(_ethToFund).sub(_ethToPot);
        if (_overbid > 0) {
            address _buyer = msg.sender;
            _buyer.transfer(_overbid);
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
    
     
    function setGameStatus(bool _status) 
        onlyAdministrator()
        public
    {
        contractActivated_ = _status;
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