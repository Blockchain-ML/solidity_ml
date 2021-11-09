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

 

contract TeamWallet {  
	using SafeMath for uint256;

	struct Member {		
    uint256 tokenAmount;
		uint256 tokenRemain;
		uint withdrawStage;
		bool approvedWithdrawal;
		address lastRejecter;
  	bool canBurn;
	}

  ERC20 public tokenContract;
	uint256 public totalToken;
	address public creator;
	bool public allocateTokenDone = false;

	mapping(address => Member) public members;

  uint public firstUnlockDate;
  uint public secondUnlockDate;
  uint public thirdUnlockDate;

  address public approver1;
  address public approver2;

  event WithdrewTokens(address _tokenContract, address _to, uint256 _amount);
  event ApprovedWithdrawal(address _approver, address _member, uint _withdrawStage);
  event RejectedWithdrawal(address _rejecter, address _member, uint _withdrawStage);

	modifier onlyCreator() {
		require(msg.sender == creator);
		_;
	}

  modifier onlyApprover() {
    require(msg.sender == approver1 || msg.sender == approver2);
    _;
  }

  constructor(
    address _tokenAddress,
    address _approver1, 
    address _approver2
  ) public {
    require(_tokenAddress != address(0));
    require(_approver1 != address(0));
    require(_approver2 != address(0));

    creator = _tokenAddress;		
    tokenContract = ERC20(_tokenAddress);
    
    firstUnlockDate = now + (12 * 30 days);  
    secondUnlockDate = now + (24 * 30 days);  
    thirdUnlockDate = now + (36 * 30 days);  

    approver1 = _approver1;
    approver2 = _approver2;
  }
  
  function() payable public { 
    revert();
  }

	function setAllocateTokenDone() external onlyCreator {
		require(!allocateTokenDone);
		allocateTokenDone = true;
	}

	function addMember(address _memberAddress, uint256 _tokenAmount) external onlyCreator {		
		require(!allocateTokenDone);
		members[_memberAddress] = Member(_tokenAmount, _tokenAmount, 0, false, address(0), false);
    totalToken = totalToken.add(_tokenAmount);
	}
	
   
  function withdrawTokens() external {		
    require(now > firstUnlockDate);
		Member storage member = members[msg.sender];
		require(member.tokenRemain > 0 && member.approvedWithdrawal);

    uint256 amount = 0;
    if(now > thirdUnlockDate) {
       
      amount = member.tokenRemain;      
    } else if(now > secondUnlockDate && member.withdrawStage == 1) {
       
      amount = member.tokenAmount * 30 / 100;
    } else if(now > firstUnlockDate && member.withdrawStage == 0){
       
      amount = member.tokenAmount * 20 / 100;
    }

    if(amount > 0) {
			member.tokenRemain = member.tokenRemain.sub(amount);      
			member.withdrawStage = member.withdrawStage + 1;
      member.approvedWithdrawal = false;
      tokenContract.transfer(msg.sender, amount);
      emit WithdrewTokens(tokenContract, msg.sender, amount);
      return;
    }

    revert();
  }

  function approveWithdrawal(address _memberAddress) external onlyApprover {
    Member storage member = members[_memberAddress];
		require(member.tokenRemain > 0 && !member.approvedWithdrawal && !member.canBurn);

    member.approvedWithdrawal = true;
    emit ApprovedWithdrawal(msg.sender, _memberAddress, member.withdrawStage);
  }

  function rejectWithdrawal(address _memberAddress) external onlyApprover {
		Member storage member = members[_memberAddress];
		require(member.tokenRemain > 0 && !member.canBurn && member.lastRejecter != msg.sender);  

     
    if(member.lastRejecter != address(0)) {
      member.canBurn = true;
			member.approvedWithdrawal = false;
		}

    member.lastRejecter = msg.sender;
    emit RejectedWithdrawal(msg.sender, _memberAddress, member.withdrawStage);
  }

	function canBurn(address _memberAddress) external view returns(bool) {
		Member memory member = members[_memberAddress];
		if(member.tokenRemain > 0) return member.canBurn;
		return false;
	}

	function getMemberTokenRemain(address _memberAddress) external view returns(uint256) {
		Member memory member = members[_memberAddress];
		if(member.tokenRemain > 0) return member.tokenRemain;
		return 0;
	}	

	function burnMemberToken(address _memberAddress) external onlyCreator() {
		Member storage member = members[_memberAddress];
		require(member.tokenRemain > 0 && member.canBurn);
		member.tokenRemain = 0;
	}	
}