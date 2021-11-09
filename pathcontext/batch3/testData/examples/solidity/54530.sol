pragma solidity ^0.4.7;

 
contract FootballMatches {
    
     
    struct FootballMatch {

		 
	    mapping (address => mapping (uint => uint)) bets;
	    
	    uint    totalAmount;
	    uint    claimedAmount;
	    uint[3] pools;			 
	    uint    startTime;
	    
	    uint winner;			 
	    bool isWinnerSet;
	    bool ownerHasClaimed;   
    }    

	     
    uint constant private FEE_PERCENTAGE = 2;
    
     
    address         private owner;
    FootballMatch[] private matches;
    
     
    event Bet(
        address indexed from, 
        uint    indexed matchId,
        uint            team, 
        uint    indexed value
    );
    
    event Claim(
        address indexed from, 
        uint    indexed matchId, 
        uint            value
    );    
    
     
    
     
	modifier ownerOnly() {
	    require(msg.sender == owner);
	    _;
	}
	
	 
	modifier winnerSet(uint matchId) {
		require(matches[matchId].isWinnerSet == true);
		_;
	}	
	
	 
	modifier matchValid(uint matchId) {
		require(matchId >= 0 && matchId < matches.length);
		_;
	}
	
	 
	modifier teamValid(uint team) {
		require(team == 0 || team == 1 || team == 2);
		_;
	}	
	
	 
	modifier afterStartTime(uint matchId) {
	    require(now >= matches[matchId].startTime);
	    _;
	}	
	
	 
	modifier beforeStartTime(uint matchId) {
	    require(now < matches[matchId].startTime);
	    _;
	}	
    
	     
    constructor() public {
        
        owner = msg.sender;
        
        uint startTime1 = 1540313700;
        uint startTime2 = 1540321200;
        uint startTime3 = 1540400100;
        uint startTime4 = 1540407600;
        
        newFootballMatch(startTime1);  
        newFootballMatch(startTime1);  
        newFootballMatch(startTime2);  
        newFootballMatch(startTime2);  
        newFootballMatch(startTime2);  
        newFootballMatch(startTime2);  
        newFootballMatch(startTime2);  
        newFootballMatch(startTime2);  
        
        newFootballMatch(startTime3);  
        newFootballMatch(startTime3);  
        newFootballMatch(startTime4);  
        newFootballMatch(startTime4);  
        newFootballMatch(startTime4);  
        newFootballMatch(startTime4);  
        newFootballMatch(startTime4);  
        newFootballMatch(startTime4);  
    }
    
     
    function newFootballMatch(uint startTime) private ownerOnly {

		uint matchId = matches.length;
		matches.length += 1;
		
		matches[matchId].startTime = startTime;        
    }    
    
	 
	function calculateFee(uint value) private pure returns (uint) {
	    return SafeMath.div(SafeMath.mul(value, FEE_PERCENTAGE), 100);
	}
	
	 
	function getOwnerPayout(uint matchId) private 
		winnerSet(matchId) ownerOnly returns (uint) {
	
		if (matches[matchId].ownerHasClaimed) {
			return 0;
		}
		
		uint payout = 0;
		if (matches[matchId].pools[matches[matchId].winner] != 0) {
			 
			payout = calculateFee(matches[matchId].totalAmount);
		} else {
			 
			payout = matches[matchId].totalAmount;
		}
		
		matches[matchId].ownerHasClaimed = true;
		return payout;
	}
	
	 
	function getNormalPayout(uint matchId) private 
		winnerSet(matchId) returns (uint) {
	
		uint bet = matches[matchId].bets[msg.sender][matches[matchId].winner];
		if (bet == 0) {
			return 0;
		}
    
        uint fee        = calculateFee(matches[matchId].totalAmount);
        uint taxedTotal = SafeMath.sub(matches[matchId].totalAmount, fee);
        uint total      = matches[matchId].pools[matches[matchId].winner];
        
        uint payout = SafeMath.div(SafeMath.mul(taxedTotal, bet), total);
        
        matches[matchId].bets[msg.sender][matches[matchId].winner] = 0;
        return payout;
	}
	
	 
	function getTotalAmount(uint matchId) public 
		matchValid(matchId) view returns (uint) {
		    
        return matches[matchId].totalAmount;
    }
    
	 
	function getClaimedAmount(uint matchId) public 
		matchValid(matchId) ownerOnly view returns (uint) {
		    
        return matches[matchId].claimedAmount;
    }     
    
     
    function setWinner(uint matchId, uint team) external 
    	matchValid(matchId) teamValid(team) afterStartTime(matchId) ownerOnly {
    	    
        matches[matchId].winner      = team;
        matches[matchId].isWinnerSet = true;
    }    
    
	 
    function bet(uint matchId, uint team) external payable 
    	matchValid(matchId) teamValid(team) beforeStartTime(matchId) {
    	    
        require(msg.value > 0);
        
        matches[matchId].totalAmount = 
        	SafeMath.add(matches[matchId].totalAmount, msg.value);
        matches[matchId].pools[team] = 
        	SafeMath.add(matches[matchId].pools[team], msg.value);
        matches[matchId].bets[msg.sender][team] = 
        	SafeMath.add(matches[matchId].bets[msg.sender][team], msg.value);
        
        emit Bet(msg.sender, matchId, team, msg.value);
    }
    
     
    function claim(uint matchId) external 
    	matchValid(matchId) winnerSet(matchId) {
    
    	uint payout = 0;
    	
    	if (msg.sender == owner) {
    		payout = getOwnerPayout(matchId); 
    	}
    	
    	 
    	payout = SafeMath.add(payout, getNormalPayout(matchId));
    	require(payout > 0);
    	
    	matches[matchId].claimedAmount = 
    		SafeMath.add(matches[matchId].claimedAmount, payout);
        msg.sender.transfer(payout);
        
        emit Claim(msg.sender, matchId, payout);
    }     

     
	 
}

 

 
library SafeMath {
     
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c){
         
         
         
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256){
         
         
         
        return a / b;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256){
        assert(b <= a);
        return a - b;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256 c){
        c = a + b;
        assert(c >= a);
        return c;
    }
}