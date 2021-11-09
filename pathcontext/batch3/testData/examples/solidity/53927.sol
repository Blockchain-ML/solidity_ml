pragma solidity ^0.4.25;


contract Wargame {
    using SafeMath for *;
    
     
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrator_ == _customerAddress);
        _;
    }
    
    
     
    event onCardFlip(
        uint8 index,
        address indexed owner,
        uint256 price
    );
    
    
     
     
    uint256 internal baseTenMinutes_ = 10 minutes;
    uint256 internal baseOneMinutes_ = 2 minutes;
    
     
    uint256 internal initialPrice_ = 0.005 ether;
    
    
     
     
    address internal administrator_;
    
     
    address internal fundAddress_;
    
     
    Card[12] internal nations_;
    
    
     
    function initCards() internal {
        for (uint8 i = 0; i < nations_.length; i++) {
            Card storage _nation = nations_[i];
            uint256 _baseTenMinutes = uint256((i/4) + 1) * baseTenMinutes_;
            uint256 _column = (i%4);
            uint256 _baseOneMinutes = _column * baseOneMinutes_;
            
             
            
            _nation.time = _baseTenMinutes + _baseOneMinutes;
        }
    }
    
    function resetCards() internal {
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
    
    
     
    constructor() 
        public
    {
        administrator_ = 0x6bca7e1EC8595B2f0F4D7Ff578F1D25643004825;
        fundAddress_ = 0x6bca7e1EC8595B2f0F4D7Ff578F1D25643004825;
        
        initCards();
        resetCards();
    }
    
     
    function buyNation(uint8 _index) 
        public
        payable
    {
        uint256 _value = msg.value;
        
         
        require(_value == nations_[_index].price, "Nation has already been bought");
        
        _buyNationInternal(_index, _value);
    }
    
     
    function overbidNation(uint8 _index)
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
    
    function _buyNationInternal(uint8 _index, uint256 _value)
        internal
    {
        Card storage _nation = nations_[_index];
        
        address _buyer = msg.sender;
        address _owner = _nation.owner;
        
         
         
         
        uint256 _ethToOwner = _value.mul(5).div(8);      
        
         
         
        if (_nation.price != initialPrice_) {
            _owner.transfer(_ethToOwner);    
        }
        
         
        setCard(_nation, _buyer);
        
         
        emit onCardFlip(_index, _buyer, _nation.price);
    }
    
     
    function getNation(uint8 _index)
        public 
        view 
        returns(uint256, uint256, address)
    {
        Card storage _nation = nations_[_index];
        return (_nation.price, _nation.time, _nation.owner);
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