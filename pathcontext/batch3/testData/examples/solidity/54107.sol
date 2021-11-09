pragma solidity ^0.4.23;

 

interface TIIMTokenInterface {
    function transfer(address to, uint amount) external returns (bool);
    function transferBonus(address to, uint amount) external returns (bool);
}

 

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

 

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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

 

contract TIIMToken is TIIMTokenInterface, StandardToken, Ownable {

    using SafeMath for uint;

    event Released(uint amount);
    event Burn(address indexed burner, uint value);

    mapping(address => uint) public bonusBalances;

    uint    public decimals = 18;
    string  public name = "TriipMiles";
    string  public symbol = "TIIM";
    uint    public totalSupply = 500 * 10 ** 6 * TIIM_UNIT;                 

    uint    public constant TIIM_UNIT = 10 ** 18;
    uint    public constant tiimCrowdFundAllocation = 165 * 10 ** 6 * TIIM_UNIT;     
    uint    public constant tiimCommunityReserveAllocation = 125 * 10 ** 6 * TIIM_UNIT;     
    uint    public constant teamAllocation = 50 * 10 ** 6 * TIIM_UNIT;                

    uint    public constant HOLDING_PERIOD = 180 days;
    
    bool    public stopped = false;
    bool    public isReleasedToPublic = false;

    address public tiimPrivateSaleAddress = 0x0;
    address public tiimKyberGoAddress = 0xb1;
    address public tiimCommunityReserve = 0x0;

    address public bonusWallet = 0x3F3;
    uint    public totalAllocated = 0;
    uint    public totalAllocatedForPrivateSale = 0;

    uint    public startTime;
    uint    public endTime;

     
    address public teamAddress = 0x0;
    
    uint    public totalTeamAllocated = 0;
    uint    public teamTranchesReleased = 0;
    uint    public maxTeamTranches = 12;                                     
    uint    public constant RELEASE_PERIOD = 30 days;

    constructor() public {
        balances[tiimCommunityReserve] = tiimCommunityReserveAllocation;
    }

     
    modifier afterHolding() {
        require(endTime > 0);

        uint validTime = endTime + HOLDING_PERIOD;

        require(now > validTime);

        _;
    }

     
    function setTiimPrivateSaleAddress(address _tiimPrivateSaleAddress) onlyOwner public {
        require(tiimPrivateSaleAddress == address(0));
        tiimPrivateSaleAddress = _tiimPrivateSaleAddress;
        balances[_tiimPrivateSaleAddress] = tiimCrowdFundAllocation;
    }

     
    function startPublicIco(address _tiimKyberGoAddress) onlyOwner public {
        require(startTime == 0, "Start time must be not setup yet");
        startTime = now;
        setTiimKyberGoAddress(_tiimKyberGoAddress);
    }

    function setTiimKyberGoAddress(address _tiimKyberGoAddress) internal {
        tiimKyberGoAddress = _tiimKyberGoAddress;
        balances[_tiimKyberGoAddress] = balances[tiimPrivateSaleAddress];
        balances[tiimPrivateSaleAddress] = 0;
    }

     
    function endPublicIco() onlyOwner public {

        require(startTime > 0);
        require(endTime < startTime, "Start time must be setup already");
        require(endTime == 0, "End time must be not setup yet");
        
        endTime = now;
        isReleasedToPublic = true;
         
        burnRemaining(tiimKyberGoAddress);
    }

    function burnRemaining(address _kyberGo) internal {
        uint _value = balances[_kyberGo];
        if(_value > 0) {
            balances[_kyberGo] = 0;

            totalSupply = totalSupply.sub(_value);
            emit Burn(_kyberGo, _value);
            emit Transfer(_kyberGo, address(0), _value);
        }
    }

    function setTeamAddress(address _teamAddress) onlyOwner public {
        teamAddress = _teamAddress;
    }

    
    function transfer(address _to, uint _value) public returns (bool success) {
        if (isReleasedToPublic || msg.sender == tiimPrivateSaleAddress) {
            assert(super.transfer(_to, _value));
            return true;
        }

        if (msg.sender == tiimKyberGoAddress) {
            totalAllocated = totalAllocated.add(_value);
            assert(super.transfer(_to, _value));
            return true;
        }
        revert();
    }

     
    function transferBonus(address _to, uint _value) public returns (bool success) {
        require(msg.sender == tiimPrivateSaleAddress);
        bonusBalances[_to] = bonusBalances[_to].add(_value);
         
        super.transfer(bonusWallet, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        if (isReleasedToPublic || msg.sender == tiimPrivateSaleAddress || msg.sender == tiimKyberGoAddress) {
            assert(super.transferFrom(_from, _to, _value));
            return true;
        }
        revert();
    }

    function approve(address _spender, uint _value) public returns (bool success) {
         
        require(_value == 0 || allowed[msg.sender][_spender] == 0);

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allocateForPrivateSale(uint amount) public {
        require(msg.sender == tiimPrivateSaleAddress);

        totalAllocated = totalAllocated.add(amount);
        totalAllocatedForPrivateSale = totalAllocatedForPrivateSale.add(amount);
    }

     
    function allowTransfers() onlyOwner public {
        isReleasedToPublic = true;
    }

    function bonusBalanceOf(address _owner) public view returns (uint) {
        return bonusBalances[_owner];
    }

     
    function redeem() public afterHolding {

        uint redeemAmount = bonusBalances[msg.sender];
        require(redeemAmount > 0);
        uint bonusWalletBalance = balances[bonusWallet];
        require(bonusWalletBalance >= redeemAmount);
         
        balances[bonusWallet] = balances[bonusWallet].sub(redeemAmount);
        balances[msg.sender] = balances[msg.sender].add(redeemAmount);
        bonusBalances[msg.sender] = 0;
    }

     
    function releaseTeamTokens() onlyOwner public returns (bool) {

        require(endTime > 0);
        require(teamAddress != 0x0);
        require(totalTeamAllocated < teamAllocation);
        require(teamTranchesReleased < maxTeamTranches);

        uint currentTranche = now.sub(endTime).div(RELEASE_PERIOD);

        if (teamTranchesReleased < maxTeamTranches && currentTranche > teamTranchesReleased) {

            uint amount = teamAllocation.div(maxTeamTranches);

            balances[teamAddress] = balances[teamAddress].add(amount);

            totalAllocated = totalAllocated.add(amount);
            totalTeamAllocated = totalTeamAllocated.add(amount);

            teamTranchesReleased++;

            emit Transfer(0x0, teamAddress, amount);
            emit Released(amount);
        }
        return true;
    }

     
     
     
    function () public payable {
        revert();
    }

     

    function nextPeriod() onlyOwner public {
        endTime = endTime.add(RELEASE_PERIOD);
    }

    function endPublicIcoForTesing() onlyOwner public {
        endTime = now.sub(181 days);
    }
}