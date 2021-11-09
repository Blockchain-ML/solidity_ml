pragma solidity ^0.4.24;

 

 
library SafeMath {

   
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
     
     
     
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

   
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
     
     
     
    return _a / _b;
  }

   
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

   
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

 

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


 
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

 

contract AdvisorWallet {  
	using SafeMath for uint256;

	struct Advisor {		
		uint256 tokenAmount;    
		uint withdrawStage;		
	}

  ERC20 public tokenContract;
	uint256 public totalToken;
	address public creator;
	bool public allocateTokenDone = false;

	mapping(address => Advisor) public advisors;

  uint public firstUnlockDate;
  uint public secondUnlockDate;  

  event WithdrewTokens(address _tokenContract, address _to, uint256 _amount);  

	modifier onlyCreator() {
		require(msg.sender == creator);
		_;
	}

  constructor(address _tokenAddress) public {
    require(_tokenAddress != address(0));

    creator = _tokenAddress;
    tokenContract = ERC20(_tokenAddress);

    firstUnlockDate = now + (6 * 30 days);  
    secondUnlockDate = now + (12 * 30 days);  
  }
  
  function() payable public { 
    revert();
  }

	function setAllocateTokenDone() external onlyCreator {
		require(!allocateTokenDone);
		allocateTokenDone = true;
	}

	function addAdvisor(address _memberAddress, uint256 _tokenAmount) external onlyCreator {		
		require(!allocateTokenDone);
		advisors[_memberAddress] = Advisor(_tokenAmount, 0);
    totalToken = totalToken.add(_tokenAmount);
	}
	
   
  function withdrawTokens() external {		
    require(now > firstUnlockDate);
		Advisor storage advisor = advisors[msg.sender];
		require(advisor.tokenAmount > 0);

    uint256 amount = 0;
    if(now > secondUnlockDate) {
       
      amount = advisor.tokenAmount;
    } else if(now > firstUnlockDate && advisor.withdrawStage == 0){
       
      amount = advisor.tokenAmount * 50 / 100;
    }

    if(amount > 0) {
			advisor.tokenAmount = advisor.tokenAmount.sub(amount);      
			advisor.withdrawStage = advisor.withdrawStage + 1;      
      tokenContract.transfer(msg.sender, amount);
      emit WithdrewTokens(tokenContract, msg.sender, amount);
      return;
    }

    revert();
  }
}