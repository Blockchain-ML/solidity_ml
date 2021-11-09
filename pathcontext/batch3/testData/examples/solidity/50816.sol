pragma solidity ^0.4.25;

contract DroneWars {
    
     
	event onHiveCreated (
        address indexed player,
		uint256 number,
		uint256 time
    );
	
	event onDroneCreated (
        address indexed player,
		uint256 number,
		uint256 time
    );
	
	event onEnemyDestroyed (
		address indexed player,
		uint256 time
	);
    
    
     
	modifier onlyAdministrator() {
        address _customerAddress = msg.sender;
        require(administrator_ == _customerAddress);
        _;
    }
    
    
     
    uint256 internal ACTIVATION_TIME = 1543054333;   
    
    uint256 internal hiveCost_ = 0.075 ether;
    uint256 internal droneCost_ = 0.01 ether;
	
	uint256 internal hiveXCommanderFee_ = 50;	 
	uint256 internal droneXCommanderFee_ = 15;	 
    uint256 internal droneXHiveFee_ = 415;		 
	
    uint8 internal amountHives_ = 8;
    uint8 internal dronesPerDay_ = 20;			 
	bool internal conquesting_ = true;
	bool internal conquested_ = false;
    
    
     
    address internal administrator_;
    address internal fundTHCAddress_;
	address internal fundP3DAddress_;
    uint256 internal pot_;
    mapping (address => Pilot) internal pilots_;
    
    address internal commander_;
    address[] internal hives_;
    address[] internal drones_;
    
     
    uint256 internal dronePopulation_;
    
    
     
    constructor() 
        public 
    {
        commander_ = address(this);
        administrator_ = 0x3AbFc04246fD8567677c9bcF0Aa923f2Cd132f06;
        fundTHCAddress_ = administrator_;
		fundP3DAddress_ = administrator_;
    }
	
	function startNewRound() 
		public 
	{
		 
		require(!conquesting_);
		
		 
		_payout();
		
		 
		_resetGame();
	}
	
	 
	function withdrawVault() 
		public 
	{
		address _player = msg.sender;
		uint256 _balance = pilots_[_player].vault;
		
		 
		require(_balance > 0);
		
		 
		pilots_[_player].vault = 0;
		
		 
		_player.transfer(_balance);
	}
	
	function createCarrierFromVault()
		public 
	{
		address _player = msg.sender;
		uint256 _vault = pilots_[_player].vault;
		
		 
		require(_vault >= hiveCost_);
		pilots_[_player].vault = _vault - hiveCost_;
		
		_createHiveInternal(_player);
	}
	
	function createDroneFromVault()
		public 
	{
		address _player = msg.sender;
		uint256 _vault = pilots_[_player].vault;
		
		 
		require(_vault >= droneCost_);
		pilots_[_player].vault = _vault - droneCost_;
		
		_createDroneInternal(_player);
	}    
    
	 
    function createCarrier() 
		public 
		payable
	{
        address _player = msg.sender;
        
		require(msg.value == hiveCost_);			 
        
        _createHiveInternal(_player);
    }	
    
    function createDrone()
        public 
		payable
    {
		address _player = msg.sender;
		
		require(msg.value == droneCost_);			 
        
        _createDroneInternal(_player);
    }
    
     
    function openAt()
        public
        view
        returns(uint256)
    {
        return ACTIVATION_TIME;
    }
    
    function amountHives()
        public
        view
        returns(uint256)
    {
        return hives_.length;
    }
    
    function currentSize() 
        public
        view
        returns(uint256) 
    {
        return drones_.length;
    }
	
	function populationIncrease()
		public
		view
		returns(uint256)
	{
		return drones_.length - dronePopulation_;
	}
    
    function commander()
        public
        view
        returns(address)
    {
        return commander_;
    }
    
    function conquesting() 
        public
        view
        returns(bool)
    {
        return conquesting_;
    }
    
    function getPot()
        public
        view
        returns(uint256)
    {
		 
        uint256 _hivesIncome = hives_.length * hiveCost_;		 
        uint256 _dronesIncome = drones_.length * droneCost_;	 
        uint256 _pot = pot_ + _hivesIncome + _dronesIncome; 	 
		uint256 _fee = _pot / 10;       						 
        _pot = _pot - _fee;										 
        return _pot;
    }
	
	function vaultOf(address _player)
		public
		view
		returns(uint256)
	{
		return pilots_[_player].vault;
	}
	
	function lastFlight(address _player)
		public
		view
		returns(uint256)
	{
		return pilots_[_player].lastFlight;
	}
    
    
     
	function _createDroneInternal(address _player) 
		internal 
	{
	    require(hives_.length == amountHives_);    					 
		require(conquesting_);										 
		 
	    
	     
	     
	     
	    
		 
        drones_.push(_player);
		pilots_[_player].lastFlight = now;
		
		emit onDroneCreated(_player, drones_.length, now);
        
		 
		_figthEnemy(_player);
	}
	
	function _createHiveInternal(address _player) 
		internal 
	{
	    require(now >= ACTIVATION_TIME);                                 
	    require(hives_.length < amountHives_);                           
         
        
		 
        hives_.push(_player);
        
         
         
		
		emit onHiveCreated(_player, hives_.length, now);
	}
    
    function _figthEnemy(address _player)
        internal
    {
        uint256 _drones = drones_.length;
        
         
        uint256 _drone = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, _player, _drones))) % 289;
        
		 
		if (_drone == 42) {
			conquesting_ = false;
			conquested_ = true;
			
			emit onEnemyDestroyed(_player, now);
		}
    }
    
     
    function _payout()
        internal
    {
         
        uint256 _hivesIncome = amountHives_ * hiveCost_;
        uint256 _dronesIncome = drones_.length * droneCost_;
        uint256 _pot = pot_ + _hivesIncome + _dronesIncome; 	 
		uint256 _fee = _pot / 10;       						 
        _pot = _pot - _fee;										 
		_hivesIncome = (_hivesIncome * 9) / 10;
        _dronesIncome = (_dronesIncome * 9) / 10;
		
         
        uint256 _toCommander = (_hivesIncome * hiveXCommanderFee_) / 100 +		 
                               (_dronesIncome * droneXCommanderFee_) / 100;  	 
        uint256 _toHives = (_dronesIncome * droneXHiveFee_) / 1000;    			 
        uint256 _toHive = _toHives / 8;											 
        uint256 _toDrones = _pot - _toHives - _toCommander; 					 
        
         
        if (conquested_) {
             
            for (uint8 i = 0; i < 8; i++) {
                address _ownerHive = hives_[i];
                pilots_[_ownerHive].vault = pilots_[_ownerHive].vault + _toHive;
                _pot = _pot - _toHive;
            }
            
             
            uint256 _squadSize;
            if (drones_.length >= 4) { _squadSize = 4; }				 
    		else                     { _squadSize = drones_.length; }	 
            
             
            for (uint256 j = (drones_.length - _squadSize); j < drones_.length; j++) {
                address _ownerDrone = drones_[j];
                pilots_[_ownerDrone].vault = pilots_[_ownerDrone].vault + (_toDrones / _squadSize);
                _pot = _pot - (_toDrones / _squadSize);
            }
        }
        
         
        if (commander_ != address(this)) {
            pilots_[commander_].vault = pilots_[commander_].vault + _toCommander;
            _pot = _pot - _toCommander;
        }
        
         
        fundTHCAddress_.transfer(_fee / 2);		 
		fundP3DAddress_.transfer(_fee / 2);		 
		
		 
		pot_ = _pot;
    }
	
	 
	function _resetGame() 
		internal 
	{
		address _winner = drones_[drones_.length - 1];
		
		commander_ = _winner;
		hives_.length = 0;
		drones_.length = 0;
		dronePopulation_ = 0;
		
		conquesting_ = true;
		conquested_ = false;
		
		ACTIVATION_TIME = now + 5 minutes;
	}
    
     
    function ownsHive(address _player) 
        internal
        view
        returns(bool)
    {
        for (uint8 i = 0; i < amountHives_; i++) {
            if (hives_[i] == _player) {
                return true;
            }
        }
        
        return false;
    }
    
    
     
	struct Pilot {
		uint256 vault;
		uint256 lastFlight;
    }
}