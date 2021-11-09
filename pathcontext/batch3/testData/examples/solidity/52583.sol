pragma solidity ^0.4.23;

 

 
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
     
    uint256 c = a / b;
     
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

 

 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  function Ownable() {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


   
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 

 
contract BethingWorldCup is Ownable {
	using SafeMath for uint256;

	 

	event Bet(address indexed better, uint256 betAmount);

	event PayCommission(uint256 commissionAmount);

	event Payout(address indexed better, uint256 payoutAmount);

     

	 
	uint256 public constant MIN_BET_AMOUNT = 0.01 ether;

	 
	uint256 public constant COMMISSION_RATE = 10;  

	 
	uint256 public BETS_CLOSING_TIME = 1531666800;  

	 
	uint256 public constant TOTAL_TEAMS = 32;

	 
	string[TOTAL_TEAMS] public TEAMS = [
		"Russia",
		"Brazil",
		"Iran",
		"Japan",
		"Mexico",
		"Belgium",
		"South Korea",
		"Saudi Arabia",
		"Germany",
		"England",
		"Spain",
		"Nigeria",
		"Costa Rica",
		"Poland",
		"Egypt",
		"Iceland",
		"Serbia",
		"Portugal",
		"France",
		"Uruguay",
		"Argentina",
		"Colombia",
		"Panama",
		"Senegal",
		"Morocco",
		"Tunisia",
		"Switzerland",
		"Croatia",
		"Sweden",
		"Denmark",
		"Australia",
		"Peru"
	];

     

	 
	address bookie;

	 
	uint256 public totalBets;

	 
	uint256 public totalBetAmount;

	 
	uint256[TOTAL_TEAMS] public teamTotalBetAmount;

	 
	mapping(address => uint256[TOTAL_TEAMS]) public betterBetAmounts;

	 
	uint256 public winningTeam;

	 
	string public winningTeamName;

	 
	uint256 public totalPayoutAmount;

	 

 	 
	modifier whenNotClosed() {
		require(!hasClosed());
		_;
	}

 	 
	modifier isValidTeam(uint256 team) {
		require(team >= 0 && team <= TOTAL_TEAMS);
		_;
	}

 	 
	modifier canPerformPayout() {
		require(hasClosed() && bytes(winningTeamName).length != 0);  
		_;
	}

     

  	 
	constructor() public {
		bookie = owner;
	}

     

  	 
	function bet(uint256 team) public whenNotClosed isValidTeam(team) payable {
		address better = msg.sender;
		uint256 betAmount = msg.value;
		require(betAmount >= MIN_BET_AMOUNT);

		betterBetAmounts[better][team] = betterBetAmounts[better][team].add(betAmount);
		totalBetAmount = totalBetAmount.add(betAmount);
		teamTotalBetAmount[team] = teamTotalBetAmount[team].add(betAmount);
		totalBets++;

		emit Bet(better, betAmount);
	}

  	 
	function claimPayout() public   {
		address better = msg.sender;
		uint256 betterWinningTeamBetAmount = betterBetAmounts[better][winningTeam];
		require(betterWinningTeamBetAmount > 0);

		uint256 winningTeamTotalBetAmount = teamTotalBetAmount[winningTeam];
		uint256 betterPayoutAmount = betterWinningTeamBetAmount.add(betterWinningTeamBetAmount.mul(totalPayoutAmount).div(winningTeamTotalBetAmount));
		better.transfer(betterPayoutAmount);
		emit Payout(better, betterPayoutAmount);
	}

	 
	function setWinningTeam(uint256 team) public {
		winningTeam = team;
		calculateTotalPayoutAmount();
	}

	 

  	 
	function hasClosed() public constant returns (bool) {
		return now > BETS_CLOSING_TIME;
	}

     

     
    function calculateTotalPayoutAmount() private {
		uint256 commissionAmount = totalBetAmount.mul(COMMISSION_RATE).div(100);		
		totalPayoutAmount = totalBetAmount.sub(commissionAmount);

		bookie.transfer(commissionAmount);
		emit PayCommission(commissionAmount);
    }
}