pragma solidity ^0.4.24;

library SafeMath {

   
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
     
     
     
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

   
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0);  
    uint256 c = _a / _b;
     

    return c;
  }

   
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

   
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

   
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

   
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

   
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value)
    public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract Pozess is ERC20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) internal balances;

  mapping (address => mapping (address => uint256)) private allowed;
  
  mapping (address => uint) private frozen;  

  uint256 internal totalSupply_;
  
  event FrozenStatus(address _target,uint _timeStamp);
  
  event Burn(address indexed burner, uint256 value);
  
  string public name = "Pozess"; 
  string public symbol = "PZS"; 
  uint8 public decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 200000000 * 10**18;

  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
  

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

   
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));
    require(frozen[msg.sender] >= now);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));
    require(frozen[msg.sender] >= now);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function _mint(address _account, uint256 _amount) public onlyOwner {
    require(_account != 0);
    totalSupply_ = totalSupply_.add(_amount);
    balances[_account] = balances[_account].add(_amount);
    emit Transfer(address(0), _account, _amount);
  }

   
  function _burn(address _account, uint256 _amount) public onlyOwner {
    require(_account != 0);
    require(_amount <= balances[_account]);

    totalSupply_ = totalSupply_.sub(_amount);
    balances[_account] = balances[_account].sub(_amount);
    emit Transfer(_account, address(0), _amount);
  }
  
   
  function setFrozen(address _target, uint _timeStamp) public onlyOwner {
    frozen[_target]=_timeStamp;
    emit FrozenStatus(_target,_timeStamp);
  }


}

contract Crowdsale is Pozess {
     
    enum IcoStages {preSale, preIco1, preIco2, ico1, ico2, ico3, ico4} 
    IcoStages Stage;
    bool private crowdsaleFinished;
    
    uint private startPreSaleDate;
    uint private endPreSaleDate;
    uint public preSaleGoal;
    uint private preSaleRaised;
    
    uint private startPreIco1Date;
    uint private endPreIco1Date;
    uint public preIco1Goal;
    uint private preIco1Raised;
    
    
    uint private startIco1Date;
    uint private endIco1Date;
    uint public ico1Goal;
    uint private ico1Raised;
    
    uint private startIco2Date;
    uint private endIco2Date;
    uint public ico2Goal;
    uint private ico2Raised;
    
    uint private startIco3Date;
    uint private endIco3Date;
    uint public ico3Goal;
    uint private ico3Raised;
    
    uint private startIco4Date;
    uint private endIco4Date;
    uint public ico4Goal;
    uint private ico4Raised;
    
    uint private softCap;
    uint private hardCap;
    uint private totalCap;
    uint private price;
    uint private reserved;
    
    struct Benefeciary{  
        address wallet;
        uint amount;
    }
    Benefeciary[] private benefeciary;
    uint private ethersRefund;
    
    constructor() public {
        startPreSaleDate = 1540857600;  
        endPreSaleDate = 1548979199;  
        preSaleGoal = 45000000;  
        preSaleRaised = 0;  
        
        startPreIco1Date = 1548979200;  
        endPreIco1Date = 1551398399;  
        preIco1Goal = 15000000;  
        preIco1Raised = 0;  
        
        startIco1Date = 1551398400;  
        endIco1Date = 1553990399;  
        ico1Goal = 15000000;  
        ico1Raised = 0;  
        
        startIco2Date = 1554076800;  
        endIco2Date = 1556668799;  
        ico2Goal = 10000000;  
        ico2Raised = 0;  
        
        startIco3Date = 1556668800;  
        endIco3Date = 1557878399;  
        ico3Goal = 10000000;  
        ico3Raised = 0;  
        
        startIco4Date = 1557878400;  
        endIco4Date = 1559260799;  
        ico4Goal = 5000000;  
        ico4Raised = 0;  
        
        softCap = 25000 * 10**18;  
        hardCap = 200000 * 10**18;  
        totalCap = 0;
        price = 2500000;  
        crowdsaleFinished = false;
        reserved = (2*20000000 + 30000000 + 10000000 + 6000000 + 14000000 + 30000000) * 10**18;
    }
  
    function getCrowdsaleInfo() private returns(uint stage, 
                                               uint tokenAvailable, 
                                               uint bonus){
         
        if(now <= endPreSaleDate && preSaleRaised < preSaleGoal){
            Stage = IcoStages.preSale;
            tokenAvailable = preSaleGoal - preSaleRaised;
            bonus = 30;
        } else if(startPreIco1Date <= now && now <= endPreIco1Date && preIco1Raised < preIco1Goal){
            Stage = IcoStages.preIco1;
            tokenAvailable = preIco1Goal - preIco1Raised;
            bonus = 25;
        } else if(startIco1Date <= now && now <= endIco1Date && ico1Raised < ico1Goal){
            Stage = IcoStages.ico1;
            tokenAvailable = ico1Goal - ico1Raised;
            bonus = 20;
        } else if(startIco2Date <= now && now <= endIco2Date && ico2Raised < ico2Goal){
            Stage = IcoStages.ico2;
            tokenAvailable = ico2Goal - ico2Raised;
            bonus = 15;
        } else if(startIco3Date <= now && now <= endIco3Date && ico3Raised < ico3Goal){
            Stage = IcoStages.ico3;
            tokenAvailable = ico3Goal - ico3Raised;
            bonus = 10;
        } else if(startIco4Date <= now && now <= endIco4Date && ico4Raised < ico4Goal){
            Stage = IcoStages.ico4;
            tokenAvailable = ico4Goal - ico4Raised;
            bonus = 5;
        } else {
             
            revert();
        }
        return (uint(Stage), tokenAvailable, bonus);
    }
    
    function evaluateTokens(uint _value, address _sender) private returns(uint tokens){
        ethersRefund = 0;
        uint bonus;
        uint tokenAvailable;
        uint stage;
        (stage,tokenAvailable,bonus) = getCrowdsaleInfo();
        tokens = _value / price / 10**9; 
        if(bonus != 0){
            tokens = tokens + (tokens * bonus / 100);  
        } 
        if(tokenAvailable < tokens){  
            tokens = tokenAvailable;
            ethersRefund = _value - (tokens * price * 10**9);  
            _sender.transfer(ethersRefund); 
        }
        owner.transfer(_value - ethersRefund);
         
        if(stage == 0){
            preSaleRaised += tokens;
        } else if(stage == 1){
            preIco1Raised += tokens;
        }  else if(stage == 2){
            ico1Raised += tokens;
        } else if(stage == 3){
            ico2Raised += tokens;
        } else if(stage == 4){
            ico3Raised += tokens;
        } else if(stage == 5){
            ico4Raised += tokens;
        }
        addInvestor(_sender, _value);
        return tokens;
    }
    
    function addInvestor(address _sender, uint _value) private {
        Benefeciary memory ben;
        for(uint i = 0; i < benefeciary.length; i++){
            if(benefeciary[i].wallet == _sender){
                benefeciary[i].amount = benefeciary[i].amount + _value - ethersRefund;
            }
        }
        setFrozen(_sender, 1561939199); 
        ben.wallet = msg.sender;
        ben.amount = msg.value - ethersRefund;
        benefeciary.push(ben);
    }
    
    
    function() public payable {
        require(startPreSaleDate <= now && now <= endIco4Date);
        require(msg.value >= 1 ether);
        totalCap += msg.value;
        uint token = evaluateTokens(msg.value, msg.sender);
         
        balances[msg.sender] = balances[msg.sender].add(token * 10**18);
        balances[owner] = balances[owner].sub(token * 10**18);
        emit Transfer(owner, msg.sender, token * 10**18);
    }
    
    function showParticipantWei(address _wallet) public view onlyOwner returns(uint){
        for(uint i = 0; i < benefeciary.length; i++){
            if(benefeciary[i].wallet == _wallet){
                return benefeciary[i].amount; 
            }
        }
        return 0;
    }
    
    modifier icoHasFinished() {
        require(now >= endIco4Date || crowdsaleFinished);
        _;
    }
    
    function burnUnsoldTokens() public onlyOwner icoHasFinished{
        _burn(owner, balanceOf(owner).sub(reserved));
    }
    
    function endIcoByCap() public onlyOwner{
        require(!crowdsaleFinished);
        require(totalCap >= softCap && totalCap <= hardCap);
        crowdsaleFinished = true;
    }
    
    function crowdSaleStage() public view returns(string){
        string memory result;
        if(uint(Stage) == 0){
            result = "Pre Sale";
        } else if(uint(Stage) == 1){
            result = "Pre-ICO phase 1";
        } else if(uint(Stage) == 2){
            result = "ICO phase 1";
        } else if(uint(Stage) == 3){
            result = "ICO phase 2";
        } else if(uint(Stage) == 4){
            result = "ICO phase 3";
        } else if(uint(Stage) == 5){
            result = "ICO phase 4";
        } 
        return result;
    }
    
    function preSaleRaise() public view returns(uint){
        return preSaleRaised;
    }
    
    function preIco1Raise() public view returns(uint){
        return preIco1Raised;
    }
    
    function ico1Raise() public view returns(uint){
        return ico1Raised;
    }
    
    function ico2Raise() public view returns(uint){
        return ico2Raised;
    }
    
    function ico3Raise() public view returns(uint){
        return ico3Raised;
    }
    
    function ico4Raise() public view returns(uint){
        return ico4Raised;
    }
    
     
    function showAllFunds() public onlyOwner view returns(uint){
        return totalCap;
    }
}