pragma solidity ^0.4.24;

 
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
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

 
contract Ownable {
    
  address public owner;
  address public newOwner;
  address public authorizedCaller;
  
  event OwnershipTransferred(address indexed _from, address indexed _to);
  
   
  constructor() public {
    owner = msg.sender;
    authorizedCaller = msg.sender;
  }
  
   
  modifier onlyAdmins() {
    require(msg.sender == authorizedCaller || msg.sender == owner);
    _;
  }


   
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  
   
  function modifyAuthorizedCaller(address _address) external onlyOwner {
      authorizedCaller = _address;
  }

   
  function transferOwnership(address _newOwner) external onlyOwner {
    newOwner = _newOwner;
  }

}

 
contract ERC20Basic {
    uint internal _totalSupply;
    function totalSupply() public constant returns (uint);
    function balanceOf(address who) public constant returns (uint);
    function transfer(address to, uint value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
}

 
contract ERC20 {
    function allowance(address owner, address spender) public constant returns (uint);
    function transferFrom(address from, address to, uint value) public returns (bool);
    function approve(address spender, uint value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint value);
}

 
contract BasicToken is Ownable, ERC20Basic {
    using SafeMath for uint;

    mapping(address => uint) internal balances;

     
    uint public feePercentage = 0;
    uint public maximumFee = 100 * (10**18);
    
    function transferWithFee(address _from, address _to, uint _value) internal returns (bool) {
        
        uint fee = (_value.mul(feePercentage)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        
        uint sendAmount = _value.sub(fee);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        emit Transfer(_from, _to, sendAmount);
        if (fee > 0) {
            balances[owner] = balances[owner].add(fee);
            emit Transfer(_from, owner, fee);
        }
        return true;
    }

     
    function transfer(address _to, uint _value) public returns (bool) {
        return transferWithFee(msg.sender, _to, _value);
    }

     
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

}

 
contract StandardToken is BasicToken, ERC20 {

    mapping (address => mapping (address => uint)) internal allowed;

    uint public constant MAX_UINT = 2**256 - 1;

     
    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        uint _allowance = allowed[_from][msg.sender];
        if (_allowance < MAX_UINT) {
            allowed[_from][msg.sender] = _allowance.sub(_value);
        }
        transferWithFee(_from, _to, _value);
    }

     
    function approve(address _spender, uint _value) public returns (bool)  {

         
         
         
         
        require(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }


    
   function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
   }

    
   function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
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

   
  function pause() onlyAdmins whenNotPaused public {
    paused = true;
    emit Pause();
  }

   
  function unpause() onlyAdmins whenPaused public {
    paused = false;
    emit Unpause();
  }
}

contract BlackList is Ownable, StandardToken {

    mapping (address => bool) private isBlackListed;

     
    function getBlackListStatus(address _account) external constant returns (bool) {
        return isBlackListed[_account];
    }
    
     
    modifier isNotBlackListed(address _address) {
        require(!isBlackListed[_address]);
        _;
    }

    function addBlackList (address _badAddress) external onlyAdmins {
        isBlackListed[_badAddress] = true;
        emit AddedBlackList(_badAddress);
    }

    function removeBlackList (address _clearedUser) external onlyAdmins {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }


     
    function destroyBlackFunds (address _blackListedUser) external onlyAdmins {
        require(isBlackListed[_blackListedUser]);
        uint dirtyFunds = balanceOf(_blackListedUser);
        balances[_blackListedUser] = 0;
        balances[owner] = balances[owner].add(dirtyFunds);
        emit TransferredBlackFunds(_blackListedUser, dirtyFunds);
    }

    event TransferredBlackFunds(address _blackListedUser, uint _balance);

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);

}


 
contract UpgradeAgent {
  uint public originalSupply;
   
  function isUpgradeAgent() public pure returns (bool) {
    return true;
  }
  function upgradeFrom(address _from, uint256 _value) public;
}


 
contract UpgradeableToken is StandardToken {

  using SafeMath for uint;
  
   
  address public upgradeMaster;

   
  UpgradeAgent public upgradeAgent;

   
  uint256 public totalUpgraded;

   
  enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

   
  event Upgrade(address indexed _from, address indexed _to, uint256 _value);

   
  event UpgradeAgentSet(address agent);

   
  constructor() public {
    upgradeMaster = msg.sender;
  }

   
  function upgrade(uint256 value) public {
    UpgradeState state = getUpgradeState();
    require((state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading));

     
    require (value != 0);

    balances[msg.sender] = balances[msg.sender].sub(value);

     
    _totalSupply = _totalSupply.sub(value);
    totalUpgraded = totalUpgraded.add(value);

     
    upgradeAgent.upgradeFrom(msg.sender, value);
    emit Upgrade(msg.sender, upgradeAgent, value);
  }

   
  function setUpgradeAgent(address agent) external {
    require(canUpgrade());

    require(agent != 0x0);
     
    require(msg.sender == upgradeMaster);
     
    require(getUpgradeState() != UpgradeState.Upgrading);

    upgradeAgent = UpgradeAgent(agent);

     
    require(upgradeAgent.isUpgradeAgent());
     
    require(upgradeAgent.originalSupply() == _totalSupply);

    emit UpgradeAgentSet(upgradeAgent);
  }

   
  function getUpgradeState() public constant returns(UpgradeState) {
    if(!canUpgrade()) return UpgradeState.NotAllowed;
    else if(address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
    else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
    else return UpgradeState.Upgrading;
  }

   
  function setUpgradeMaster(address master) public {
    require(master != 0x0);
    require(msg.sender == upgradeMaster);
    upgradeMaster = master;
  }

   
  function canUpgrade() public pure returns(bool) {
     return true;
  }

}



contract ConsentiumCoin is Pausable, BlackList, UpgradeableToken {

    string public name;
    string public symbol;
    uint public decimals;
    
    constructor() public {
        name = "Consentium Coin";
        symbol = "CSM";
        decimals = 18;
        _totalSupply = 240000000 * (10**decimals);
        balances[owner] = _totalSupply;
    }

     
    function transfer(address _to, uint _value) whenNotPaused isNotBlackListed(msg.sender) isNotBlackListed(_to) public returns (bool) {
        return super.transfer(_to, _value);
    }

     
    function transferFrom(address _from, address _to, uint _value) whenNotPaused isNotBlackListed(_to) isNotBlackListed(msg.sender) isNotBlackListed(_from) public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function setParams(uint newFeePercentage, uint newMaxFee) external onlyOwner {
        feePercentage = newFeePercentage;
        maximumFee = newMaxFee;
        emit Params(feePercentage, maximumFee);
    }
    
     
    function burn(uint _value) external onlyOwner {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
         
         
        balances[msg.sender] = balances[msg.sender].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
    }

     
    function setTokenInformation(string _name, string _symbol) onlyOwner external {
      name = _name;
      symbol = _symbol;
      emit UpdatedTokenInformation(name, symbol);
    }
    
    function acceptOwnership() external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner =  newOwner;
        upgradeMaster = newOwner;
    }

     
    event Params(uint feeBasisPoints, uint maxFee);

     
     event UpdatedTokenInformation(string newName, string newSymbol);
     
      
     event Burn(address owner, uint value);
}