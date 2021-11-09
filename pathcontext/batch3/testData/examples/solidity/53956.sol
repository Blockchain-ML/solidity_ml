pragma solidity ^0.4.25;

contract DroneWars {
    
     
    
    
     
    
    
     
    uint256 internal ACTIVATION_TIME = 1543054333;   
    
    uint256 internal hiveCost_ = 0.075 ether;
    uint256 internal droneCost_ = 0.01 ether;
    
    uint8 internal amountHives_ = 8;
    uint8 internal dronesPerDay_ = 20;
	bool internal commanderAlive_ = true;
	bool internal conquested_ = true;
    
    
     
    address internal administrator_;
    address internal fundAddress_;
    uint256 internal pot_;
    mapping (address => uint256) internal vaults_;
    
    address internal commander_;
    address[] internal hives_;
    address[] internal drones_;
    
    uint256 internal DEATH_TIME;
    uint256 internal dronePopulation_;
    
    
     
    constructor() 
        public 
    {
        commander_ = address(this);
        administrator_ = 0x28436C7453EbA01c6EcbC8a9cAa975f0ADE6Fff1;
        fundAddress_ = 0x1E2F082CB8fd71890777CA55Bd0Ce1299975B25f;
    }
	
	function startNewRound() 
		public 
	{
		 
		require(!commanderAlive_);
		
		 
		_payout();
		
		 
		_resetGame();
	}
	
	 
	function withdrawVault() 
		public 
	{
		address _player = msg.sender;
		uint256 _balance = vaults_[_player];
		
		 
		require(_balance > 0);
		
		 
		vaults_[_player] = 0;
		
		 
		_player.transfer(_balance);
	}
	
	function createCarrierFromVault()
		public 
	{
		address _player = msg.sender;
		
		 
		require(vaults_[_player] >= hiveCost_);
		vaults_[_player] = vaults_[_player] - hiveCost_;
		
		_createHiveInternal(_player);
	}
	
	function createDroneFromVault()
		public 
	{
		address _player = msg.sender;
		
		 
		require(vaults_[_player] >= droneCost_);
		vaults_[_player] = vaults_[_player] - droneCost_;
		
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
    
    function commander()
        public
        view
        returns(address)
    {
        return commander_;
    }
    
    function commanderAlive() 
        public
        view
        returns(bool)
    {
        return commanderAlive_;
    }
    
    function getPot()
        public
        view
        returns(uint256)
    {
        return pot_;
    }
	
	function balanceOf(address _player)
		public
		view
		returns(uint256)
	{
		return vaults_[_player];
	}
    
    
     
	function _createDroneInternal(address _player) 
		internal 
	{
	    require(hives_.length == amountHives_);    	 
		require(commanderAlive_);					 
	    
	     
	     
	    if (now > DEATH_TIME) {
	        if (drones_.length - dronePopulation_ >= dronesPerDay_) {
	            dronePopulation_ = drones_.length;		 
	            DEATH_TIME = DEATH_TIME + 24 hours;		 
	        } else {
	            commanderAlive_ = false;
	            conquested_ = false;
	            return;
	        }
	    }
	    
		 
        drones_.push(_player);
        
		 
		_figthCommander(_player);
	}
	
	function _createHiveInternal(address _player) 
		internal 
	{
	    require(now >= ACTIVATION_TIME);                                 
	    require(hives_.length < amountHives_);                           
         
        
		 
        hives_.push(_player);
        
         
        if (hives_.length == amountHives_) {
            DEATH_TIME = now + 24 hours;
        }
	}
    
    function _figthCommander(address _player)
        internal
    {
        uint256 _drones = drones_.length;
        
         
        uint256 _drone = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, _player, _drones))) % 289;
        
		 
		if (_drone == 42) {
			commanderAlive_ = false;
		}
    }
    
     
    function _payout()
        internal
    {
         
        uint256 _hivesIncome = 8 * hiveCost_;
        uint256 _dronesIncome = drones_.length * droneCost_;
        pot_ = pot_ + _hivesIncome + _dronesIncome;  
        uint256 _fee = pot_ / 10;        
        pot_ = pot_ - _fee;              
        
         
        uint256 _toCommander = (_hivesIncome * 7) / 10 +   	 
                               (_dronesIncome * 3) / 100;  	 
        uint256 _toHives = (_dronesIncome * 415) / 1000;     
        uint256 _toHive = _toHives / 8;						 
        uint256 _toDrones = pot_ - _toHives - _toCommander;   
        uint256 _toDrone;
        
         
        if (conquested_) {
             
            for (uint8 i = 0; i < 8; i++) {
                address _ownerHive = hives_[i];
                vaults_[_ownerHive] = vaults_[_ownerHive] + _toHive;
                pot_ = pot_ - _toHive;
            }
            
             
            uint256 _squadSize;
            if (drones_.length >= 4) { _squadSize = 4; }				 
    		else                     { _squadSize = drones_.length; }	 
    		_toDrone = _toDrones / _squadSize;
            
             
            for (uint256 j = (drones_.length - _squadSize); j < drones_.length; j++) {
                address _ownerDrone = drones_[j];
                vaults_[_ownerDrone] = vaults_[_ownerDrone] + _toDrone;
                pot_ = pot_ - _toDrone;
            }
        }
        
         
        if (commander_ != address(this)) {
            vaults_[commander_] = vaults_[commander_] + _toCommander;
            pot_ = pot_ - _toCommander;
        }
        
         
        fundAddress_.transfer(_fee);
    }
	
	 
	function _resetGame() 
		internal 
	{
		address _winner = drones_[drones_.length - 1];
		
		commander_ = _winner;
		hives_.length = 0;
		drones_.length = 0;
		dronePopulation_ = 0;
		
		commanderAlive_ = true;
		conquested_ = true;
		
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
    
    
     
}