pragma solidity ^0.4.24;

 

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

   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
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
    emit Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}


contract ERC20Basic {
  function totalSupply() public view returns (uint256);
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

contract CrowdsaleToken is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

 constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

contract Standard is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }


  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }


  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }


  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }


  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


 

contract FRST is Ownable, Pausable, Standard, CrowdsaleToken {
    using SafeMath for uint256;

    string name = "FTEST";
    string symbol = "FT";
    uint8 decimals = 18;

     
    bool crowdsaleConcluded = false;

     
    uint256 public startTime;
    uint256 public endTime;

     
    uint256 minimum_invest = 100000000000000;

     
    uint256 customBonus = 20;

     
    address public wallet;

     
    uint256 public rate;

     
    uint256 public weiRaised;
    uint256 public tokensSold;
    
     
    address STRATEGIC_PARTNERS_WALLET = 0x641AD78BAca220C5BD28b51Ce8e0F495e85Fe689;
    address BOUNTY_PROGRAM_WALLET = 0xa803c226c8281550454523191375695928DcFE92;
    address FOUNDING_TEAM_WALLET = 0xE73168deb6831502FFC1F437e4835A3eA12D69b7;
    address ADVISORY_BOARD_WALLET = 0x9107715F75700d2D1E2a7862A5E264aaA60766FA;
    address PRE_SALE_WALLET = 0x6dBC5fBB69D43442a5BeC07E18037896b1E2EF6d;
    

     
    bool tokensAllocated = false;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    constructor(uint256 _rate) 
        CrowdsaleToken(name, symbol, decimals) public {
    
        totalSupply_ = 4000000000E18;
        
         
        balances[this] = totalSupply_;

        startTime = 1531781636;
        endTime = 1731781636;
        
        require(endTime >= startTime);
        require(_rate > 0);

        rate = _rate;
        wallet = msg.sender;
    }

     
    function () external whenNotPaused payable {
        buyTokens(msg.sender);
    }

    function envokeTokenAllocation() public onlyOwner {
        require(!tokensAllocated);
        this.transfer(STRATEGIC_PARTNERS_WALLET, 320000000E18);  
        this.transfer(BOUNTY_PROGRAM_WALLET, 80000000E18);  
        this.transfer(FOUNDING_TEAM_WALLET, 800000000E18);  
        this.transfer(ADVISORY_BOARD_WALLET, 200000000E18);  
        this.transfer(PRE_SALE_WALLET, 400000000E18);  
        tokensAllocated = true;
    }

     
    function buyTokens(address _beneficiary) public whenNotPaused payable returns (uint256) {
        require(!hasEnded());

         
        require(minimum_invest <= msg.value);

        address beneficiary = _beneficiary;

        require(beneficiary != address(0));
        require(validPurchase());

        uint256 weiAmount = msg.value;

         
        uint256 tokens = getTokenAmount(weiAmount);

         
        bool isLess = false;
        if (!hasEnoughTokensLeft(weiAmount)) {
            isLess = true;

            uint256 percentOfValue = tokensLeft().mul(100).div(tokens);
            require(percentOfValue <= 100);

            tokens = tokens.mul(percentOfValue).div(100);
            weiAmount = weiAmount.mul(percentOfValue).div(100);

             
            beneficiary.transfer(msg.value.sub(weiAmount));
        }

         
        weiRaised = weiRaised.add(weiAmount);
        tokensSold = tokensSold.add(tokens);

         
        this.transfer(beneficiary, tokens);

        forwardFunds(weiAmount);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
        return (tokens);
    }

     

    function setCustomBonus(uint256 _customBonus) onlyOwner public {
      require(_customBonus >= 0);
      customBonus = _customBonus;
    }

    function setMinInvestment(uint256 _investment) onlyOwner public {
      require(_investment > 0);
      minimum_invest = _investment;
    }

    function changeEndTime(uint256 _endTime) onlyOwner public {
        require(_endTime > startTime);
        endTime = _endTime;
    }

    function changeStartTime(uint256 _startTime) onlyOwner public {
        require(endTime > _startTime);
        startTime = _startTime;
    }

    function setWallet(address _wallet) onlyOwner public {
        require(_wallet != address(0));
        wallet = _wallet;
    }

     

    function endSale() onlyOwner public {
       
      crowdsaleConcluded = true;
    }

     

    function evacuateTokens(address _wallet) onlyOwner public {
      require(_wallet != address(0));
      this.transfer(_wallet, this.balanceOf(this));
    }

     

     
    function hasEnded() public view returns (bool) {
        return now > endTime || this.balanceOf(this) == 0 || crowdsaleConcluded;
    }

    function getBaseAmount(uint256 _weiAmount) public view returns (uint256) {
        return _weiAmount.mul(rate);
    }

    function getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        uint256 tokens = getBaseAmount(_weiAmount);
        uint256 percentage = customBonus;
        if (percentage > 0) {
            tokens = tokens.add(tokens.mul(percentage).div(100));
        }

        assert(tokens > 0);
        return (tokens);
    }

     
    function forwardFunds(uint256 _amount) internal {
        wallet.transfer(_amount);
    }

     
    function validPurchase() internal view returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    function tokensLeft() public view returns (uint256) {
        return this.balanceOf(this);
    }

    function hasEnoughTokensLeft(uint256 _weiAmount) public payable returns (bool) {
        return tokensLeft().sub(_weiAmount) >= getBaseAmount(_weiAmount);
    }
}