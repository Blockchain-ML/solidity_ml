pragma solidity ^0.4.23;

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

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  function Ownable() public {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

   
  modifier whenPaused() {
    require(paused);
    _;
  }

   
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract ColorBayTestToken is PausableToken {
    string public name;
    string public symbol;
    uint256 public decimals = 18;

    function ColorBayTestToken(uint256 initialSupply, string tokenName, string tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }
}



 




interface token {
    function transfer(address receiver, uint amount);
}

contract Crowdsale is Ownable {
    using SafeMath for uint256;
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool public fundingGoalReached = false;
    bool public crowdsaleClosed = false;
    
    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    
    address[] public funder;
    
    modifier afterDeadline() { if (now >= deadline) _; }
    
    function Crowdsale(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint finneyCostOfEachToken,
        address addressOfTokenUsedAsReward) public {
            beneficiary = ifSuccessfulSendTo;
            fundingGoal = fundingGoalInEthers.mul(1 ether);
            deadline = now + durationInMinutes.mul(1 minutes);
            price = finneyCostOfEachToken.mul(1 finney);
            tokenReward = token(addressOfTokenUsedAsReward);
    }
    
    event LogPay(address sender, uint value, uint blance, uint amount, bool isClosed);
    function () public payable {
        require(!crowdsaleClosed);
        funder.push(msg.sender);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(msg.value);
        amountRaised = amountRaised.add(msg.value);
        if(amountRaised >= fundingGoal) {
            crowdsaleClosed = true;
            fundingGoalReached = true;
        }
        emit LogPay(msg.sender, msg.value, balanceOf[msg.sender], amountRaised, crowdsaleClosed);
    }
    
    function getThisBalance() public constant returns (uint) {
        return this.balance;
    }
    
    function getNow() public constant returns (uint, uint) {
        return (now, deadline);
    }
    
    function setDeadline(uint minute) public onlyOwner {
        deadline = minute.mul(1 minutes).add(now);
    }
    
    function safeWithdrawal() public onlyOwner afterDeadline {
        if(amountRaised >= fundingGoal) {
            crowdsaleClosed = true;
            fundingGoalReached = true;
            emit GoalReached(beneficiary, amountRaised);
        } else {
            crowdsaleClosed = false;
            fundingGoalReached = false;
        }
        uint i;
        if(fundingGoalReached) {
            if(amountRaised > fundingGoal && funder.length>0) {
                address returnFunder = funder[funder.length.sub(1)];
                uint overFund = amountRaised.sub(fundingGoal);
                if(returnFunder.send(overFund)) {
                    balanceOf[returnFunder] = balanceOf[returnFunder].sub(overFund);
                    amountRaised = fundingGoal;
                }
            }
            for(i = 0; i < funder.length; i++) {
                tokenReward.transfer(funder[i], balanceOf[funder[i]].mul(1 ether).div(price));
                balanceOf[funder[i]] = 0;
            }
            if (beneficiary.send(amountRaised)) {
                emit FundTransfer(beneficiary, amountRaised, false);
            } else {
                fundingGoalReached = false;
            }
            
        } else {
            for(i = 0; i < funder.length; i++) {
                if (balanceOf[funder[i]] > 0 && funder[i].send(balanceOf[funder[i]])) {
                    amountRaised = 0;
                    balanceOf[funder[i]] = 0;
                    emit FundTransfer(funder[i], balanceOf[funder[i]], false);
                }
            }
        }
    }
    
}