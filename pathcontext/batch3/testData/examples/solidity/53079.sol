pragma solidity ^0.4.25;


contract Prosperity {
	 
	function withdraw() public;
	
	  
    function myDividends(bool _includeReferralBonus) public view returns(uint256);
}


contract Fund {
    using SafeMath for *;
    
     
     
     
     
     
     
     
     
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrator_ == _customerAddress);
        _;
    }
    
    
     
    address internal administrator_;
    address internal lending_;
    address internal freeFund_;
    address[] public devs_;
	
	 
	Prosperity public tokenContract_;
    
     
    uint8 internal lendingShare_ = 50;
    uint8 internal freeFundShare_ = 20;
    uint8 internal devsShare_ = 30;
    
    
     
    constructor()
        public 
    {
         
        administrator_ = 0xA1bAeAaC24AeC31FBF0F8895bf8177cDB7Ccc759;
        lending_ = 0xcec1A88Ef22c9c4b91F26D4dC51e5421Cc452B6E;
        freeFund_ = administrator_;
        
         
        devs_.push(0x6bca7e1EC8595B2f0F4D7Ff578F1D25643004825);
        devs_.push(0x6134DD437C51423410BE01aBB8D7CEe427B90481);
        devs_.push(0xd2e67b7678c2AFEe6C3Bf3E698Aa19F1d6fc0746);
    }
	
	function() payable external {
		 
		 
	}
    
     
    function pushEther()
        public
    {
		 
		if (myDividends(true) > 0) {
			tokenContract_.withdraw();
		}
		
		 
        uint256 _balance = getTotalBalance();
        
		 
        if (_balance > 0) {
            uint256 _ethDevs      = _balance.mul(devsShare_).div(100);           
            uint256 _ethFreeFund  = _balance.mul(freeFundShare_).div(100);       
            uint256 _ethLending   = _balance.sub(_ethDevs).sub(_ethFreeFund);    
            
            lending_.transfer(_ethLending);
            freeFund_.transfer(_ethFreeFund);
            
            uint256 _devsCount = devs_.length;
            for (uint8 i = 0; i < _devsCount; i++) {
                uint256 _ethDevPortion = _ethDevs.div(_devsCount);
                address _dev = devs_[i];
                _dev.transfer(_ethDevPortion);
            }
        }
    }
    
     
    function addDev(address _dev)
        onlyAdministrator()
        public
    {
         
        require(!isDev(_dev), "address is already dev");
        
        devs_.push(_dev);
    }
    
     
    function removeDev(address _dev)
        onlyAdministrator()
        public
    {
         
        require(isDev(_dev), "address is not a dev");
        
         
        uint8 index = getDevIndex(_dev);
        
         
        uint256 _devCount = getTotalDevs();
        for (uint8 i = index; i < _devCount - 1; i++) {
            devs_[i] = devs_[i+1];
        }
        delete devs_[devs_.length-1];
        devs_.length--;
    }
    
    
     
    function isDev(address _dealer) 
        public
        view
        returns(bool)
    {
        uint256 _devsCount = devs_.length;
        
        for (uint8 i = 0; i < _devsCount; i++) {
            if (devs_[i] == _dealer) {
                return true;
            }
        }
        
        return false;
    }
    
    
     
    function getTotalBalance() 
        public
        view
        returns(uint256)
    {
        return address(this).balance;
    }
    
    function getTotalDevs()
        public 
        view 
        returns(uint256)
    {
        return devs_.length;
    }
	
	function myDividends(bool _includeReferralBonus)
		public
		view
		returns(uint256)
	{
		return tokenContract_.myDividends(_includeReferralBonus);
	}
    
    
     
     
    function getDevIndex(address _dev)
        internal
        view
        returns(uint8)
    {
        uint256 _devsCount = devs_.length;
        
        for (uint8 i = 0; i < _devsCount; i++) {
            if (devs_[i] == _dev) {
                return i;
            }
        }
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
    require(c / a == b);

    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);  
    uint256 c = a / b;
     

    return c;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

   
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}