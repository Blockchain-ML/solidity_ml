pragma solidity ^0.4.24;

library SafeMath {

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}
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
}

contract ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier OnlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function TransferOwnership(address newOwner) public OnlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract SafeCoinDeposit is ownable {

	using SafeMath for uint;

  string public constant symbol = "DEPOSITS";
  string public constant name = "Coin Safe Deposit";
	uint public constant INITIAL_SUPPLY = 4000000000;
	uint256 public totalSupply = 2400000000;
	uint8 public constant decimals = 0;

	uint256 private marketing = 400000000;  
	uint256 private team = 400000000;  
	uint256 private bounties = 200000000;  
	uint256 private advisors = 200000000;  
	uint256 private reserves = 400000000;  
	
	 
	
	address private not_a_referrer_addr = 0x0000000000000000000000000000000000000000;
	uint256 public specialCount = 0;
	uint256 public rate = 145;
	uint256 public dollar_rate = 463384;
    uint256 public div_factor_9 = 1000000000;
    uint256 public div_factor_10 = 10000000000;

	mapping (address => uint256) balances;

	mapping(address => bool) public contractAddress;

	uint256 private constant MAY_15_2018 = 1533895630;  
	uint256 private constant MAY_30_2018 = 1535623630;  
	uint256 private constant JUNE_01_2018 = 1527791400;
	uint256 private constant JUNE_14_2018 = 1529000999;
	uint256 private constant JUNE_15_2018 = 1529001000;
	uint256 private constant JUNE_30_2018 = 1530383399;
	uint256 private constant JULY_01_2018 = 1530383400;
	uint256 private constant JULY_14_2018 = 1531592999;
	uint256 private constant JULY_15_2018 = 1531593000;
	uint256 private constant JULY_30_2018 = 1532975399;

	 

	function balanceEth(address who) public constant returns (uint256 balance) {
		return who.balance;
	}

	function marketingBalance() public constant returns (uint256 balance) {
		return marketing;
	}

	function teamBalance() public constant returns (uint256 balance) {
		return team;
	}

	function bountiesBalance() public constant returns (uint256 balance) {
		return bounties;
	}

	function advisorsBalance() public constant returns (uint256 balance) {
		return advisors;
	}

	function reservesBalance() public constant returns (uint256 balance) {
		return reserves;
	}

	function collect(uint256 amount) OnlyOwner public{
		msg.sender.transfer(amount);
	}

	function balanceOf(address who) public constant returns (uint256) {
			return balances[who];
	}

	function inSpecialSalePeriod() public constant returns (bool) {
		if (inPrivateSalePeriod()) {
			if (specialCount < 2000) {
				return true;
			} else {
				return false;
			}
		}
		else {
			return false;
		}
	}

	function inPrivateSalePeriod() public constant returns (bool) {
			if (now >= MAY_15_2018 && now < MAY_30_2018){
					return true;
			} else {
					return false;
			}
	}

	function inPreSale1Period() public constant returns (bool) {
			if (now >= JUNE_01_2018 && now < JUNE_14_2018) {
					return true;
			} else {
					return false;
			}
	}

	 function inPreSale2Period() public constant returns (bool) {
			if (now >= JUNE_15_2018 && now < JUNE_30_2018) {
					return true;
			} else {
					return false;
			}
	}

	function inPreSale3Period() public constant returns (bool) {
			if (now >= JULY_01_2018 && now < JULY_14_2018) {
					return true;
			} else {
					return false;
			}
	}

	function inMainSalePeriod() public constant returns (bool) {
			if (now >= JULY_15_2018 && now <= JULY_30_2018) {
					return true;
			} else {
					return false;
			}
	}

	function alreadyAvailedOffer(address _address) view public returns (bool) {
			require(_address != owner);
			return contractAddress[_address];
	}

	function getttttttt(uint256 _eth_to_cent) payable public returns (uint256,uint256,uint256){
		require(_eth_to_cent > 0);
		
		uint256 amount_ = msg.value;
		uint256 amount = amount_.div(10**18);
		uint256 eth_to_cent = _eth_to_cent;  
		uint256 contribution = SafeMath.mul((amount.div(10**18)), eth_to_cent);

		uint256 rate_in_dollar = rate;  

		uint256 tokens_ = SafeMath.div(contribution, rate_in_dollar);
		uint256 tokens = tokens_.mul(100);

		return(rate_in_dollar, tokens, contribution);

	}

    function buy_token(address[] addr, uint256 tokens, uint256 ref_toks) payable public returns (bool) {

		uint256 amount = msg.value;
		 
		 
		 
		require(tokens > 0);
		require(amount > 0);

		address to = addr[0];
		address referrer = addr[1];

		if (referrer == not_a_referrer_addr){
			ref_toks = 0;	
		}

		balances[to] = balances[to].add(tokens);
		balances[referrer] = balances[referrer].add(ref_toks);
		uint total_toks = tokens.add(ref_toks);
		totalSupply = totalSupply.sub(total_toks);

		return true;
    }

    function transfer_token(address[] addr, uint256 tokens) OnlyOwner public returns (bool) {
		require(tokens > 0);
    
        address to = addr[0];
        address from = addr[1];
        
        balances[to] = balances[to].add(tokens);
        balances[from] = balances[from].sub(tokens);
       
    }
	 

	 
	 
	 

	 
	 
	 


	 

	 
	 
	 
	 
	 

	 

	 
	 

	 
	 
	 

	 

	 

	 
	 

	 

	 
	 
	 

	 

	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 

	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 

	function transfer_to_reserves(address addr, uint256 _type, uint256 tokens) OnlyOwner public returns (bool) {
		require(tokens > 0);
		require(addr != owner);

		if(_type == 0){
			require(tokens <= marketing);
			balances[addr] = balances[addr].add(tokens);
			marketing = marketing.sub(tokens);
		}

		if(_type == 1){
			require(tokens <= team);
			balances[addr] = balances[addr].add(tokens);
			team = team.sub(tokens);
		}

		if(_type == 2){
			require(tokens <= bounties);
			balances[addr] = balances[addr].add(tokens);
			bounties = bounties.sub(tokens);
		}

		if(_type == 3){
			require(tokens <= advisors);
			balances[addr] = balances[addr].add(tokens);
			advisors = advisors.sub(tokens);
		}

		if(_type == 4){
			require(tokens <= reserves);
			balances[addr] = balances[addr].add(tokens);
			reserves = reserves.sub(tokens);
		}

	}

	function burn(uint256 _value) OnlyOwner public {
    require(_value <= totalSupply);

    totalSupply = totalSupply.sub(_value);
    emit Burn(_value);
  }

	event Transfer(address indexed from, address indexed to, uint256 value);
  event Burn(uint256 value);

}