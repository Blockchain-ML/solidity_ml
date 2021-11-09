pragma solidity ^0.4.18;

 



 
contract ERC20 {
    function totalSupply() public view returns (uint256);
    
    function balanceOf(address _who) public view returns (uint256);
    
    function allowance(address _owner, address _spender) public view returns (uint256);
    
    function transfer(address _to, uint256 _value) public returns (bool);
    
    function approve(address _spender, uint256 _value) public returns (bool);
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    
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
}


 
contract StandardToken is ERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private balances;

  mapping (address => mapping (address => uint256)) public allowed;

  uint256 private totalSupply_;

   
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

   
  function _mint(address _account, uint256 _amount) internal {
    require(_account != address(0));
    totalSupply_ = totalSupply_.add(_amount);
    balances[_account] = balances[_account].add(_amount);
    emit Transfer(address(0), _account, _amount);
  }

   
  function _burn(address _account, uint256 _amount) internal {
    require(_account != address(0));
    require(_amount <= balances[_account]);

    totalSupply_ = totalSupply_.sub(_amount);
    balances[_account] = balances[_account].sub(_amount);
    emit Transfer(_account, address(0), _amount);
  }

   
  function _burnFrom(address _account, uint256 _amount) internal {
    require(_amount <= allowed[_account][msg.sender]);

     
     
    allowed[_account][msg.sender] = allowed[_account][msg.sender].sub(_amount);
    _burn(_account, _amount);
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
    
     
     
     
     
     
    
     
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }
    
     
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

 
contract BurnableToken is StandardToken {

  event Burn(address indexed burner, uint256 value);

   
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

   
  function burnFrom(address _from, uint256 _value) public {
    _burnFrom(_from, _value);
  }

   
  function _burn(address _who, uint256 _value) internal {
    super._burn(_who, _value);
    emit Burn(_who, _value);
  }
}


contract TestnetToken is BurnableToken, Ownable {
    string public constant name = "Thirve";
    
    string public constant symbol = "3VA";
    
    uint32 public constant decimals = 18;
    
    uint private totalCap = 2500000 * 1 ether;
    
    constructor() public {
         
        _mint(msg.sender, totalCap);
    }
}


contract TestnetCrowdSale is Ownable {
    using SafeMath for uint;
    
    TestnetToken public Token;  
    
     
    enum Stage {
        Pouse,
        Init,
        Running,
        Stoped
    }
    
     
    enum Type {
        Presale,
        Ico
    }

    
    Stage public currentStage = Stage.Pouse;  
    Type public currentType = Type.Presale;  
    
     
    uint public constant startPresaleTime = 1535466000;  
    uint public constant endPresaleTime = 1535467800;    
    
    uint public constant startIcoTime = 1535468100;      
    uint public constant endIcoTime = 1535469900;        

     
     
     
    uint public totalCap = 2500000 * 1 ether;
    
    
     
     
     
     
     
    uint public presaleCap = 648000 * 1 ether;
    
     
     
    uint public icoCap = 868000 * 1 ether;
    
     
     
     
    uint public constant advisorsPercentage = 15;
    
     
     
     
    uint public constant bountyPercentage = 5;
    
    
     
     
     
    uint public constant foundersPercentage = 15;
    
    uint public constant salePercantage = 65;
    
     
     
    address public constant advisor = 0x53926a2CC9920CbE05A1Eb9B10dcC14E048c3995;
    
     
     
    address public constant supporter = 0x4Cf06620f06CB9293f8912646214C38C5088aa54;
    
     
     
    address public constant founder = 0xae5A146E7303ec4f17a5eB07319903E6224A7b45;
    
     
     
     
     
    address public constant coldWallet = 0x67d54A616bBF7b72046A710f71a83e25f580eA32;
    
     
     
    uint public constant PRESALE_PRICE = 3000;
    
     
     
    uint public constant ICO_PRICE = 2000;
    
    uint public totalSoldTokens = 0;     
    uint public totalSoldOnPresale = 0;  
    uint public totalSoldOnIco = 0;      
    
    bool public isCoinSentToFounder = false;  
    
     
    uint public weiRaised = 0;
    
    uint public constant softcap =  100 ether;  
    uint public constant hardcap = 400 ether;  
    uint public constant presaleEtherCap = 120 ether;
    
    bool public isHardCapCollected = false;  
    bool public isCrowdsaleInitialized = false;  
    bool public isWithdrawn = false;  
    
     
     
    mapping(address=>uint) public balances; 
    
    event HardcapReached(
        address indexed _where,
        uint256 hardcap,
        uint collected
    );
    
    constructor(TestnetToken _token) public {
        Token = _token;
    }
    
    
     
    modifier isCrowdsaleOff() {
        require(!isCrowdsaleInitialized);
        _;
    }
    
     
    modifier isPresaleFinished() {
        require(now > endPresaleTime);
        _;
    }
    
      
    modifier isIcoFinished() {
        require(now > endIcoTime);
        _;
    }

     
    modifier saleIsOn() {
        if (currentType == Type.Presale)
            require(
                now > startPresaleTime && 
                now < endPresaleTime && 
                address(this).balance <= presaleEtherCap
            );
            
        else if (currentType == Type.Ico)
            require(now > startIcoTime && now < endIcoTime);
        
        _;
    }
    
     
    modifier isUnderHadrCap() {
        require(address(this).balance <= hardcap);
        
        if (address(this).balance == hardcap && !isHardCapCollected) {
            isHardCapCollected = true;
            
            emit HardcapReached(
                address(this), 
                hardcap, 
                address(this).balance
            );
        }
        
        _;
    }
    
     
    modifier isPouse() {
        require(currentStage == Stage.Pouse);
        _;
    }
    
    modifier whenNotPouse() {
        require(currentStage != Stage.Pouse);
        _;
    }
    
    modifier isInit() {
        require(currentStage == Stage.Init);
        _;
    }
    
    modifier isRunning() {
        require(currentStage == Stage.Running);
        _;
    }
    
    modifier whenNotRunning() {
        require(currentStage != Stage.Running);
        _;
    }
    
    modifier isStoped() {
        require(
            currentStage == Stage.Stoped, 
            "isStoped: Before running `safeWithdrawal` function, make sure the you run the `finishCrowdsale` function."
        );
        
        _;
    }
    
     
    modifier isPresale() {
        require(currentType == Type.Presale);
        _;
    }
    
    modifier isIco() {
        require(currentType == Type.Ico);
        _;
    }
    
    modifier whenNotWithdrawn() {
        require(!isWithdrawn);
        _;
    }
    
     
    function getCurrentWeek(uint256 startDate, uint256 currentDate) internal pure returns (uint256) {
        uint256 diff = currentDate.sub( startDate );
        
         
         
        uint256 diffWeeks = diff.div( 1 weeks ); 
        
         
        return diffWeeks.add(1);
    }
    
     
    function getVolumeBonus(uint etherValue) private pure returns (uint) {
             if (etherValue >= 10000 ether) return 55;   
        else if (etherValue >=  5000 ether) return 50;   
        else if (etherValue >=  1000 ether) return 45;   
        else if (etherValue >=   200 ether) return 40;   
        else if (etherValue >=   100 ether) return 35;   
        else if (etherValue >=    50 ether) return 30;   
        else if (etherValue >=    30 ether) return 25;   
        else if (etherValue >=    20 ether) return 20;   
        else if (etherValue >=    10 ether) return 15;   
        else if (etherValue >=     5 ether) return 10;   
        else if (etherValue >=     1 ether) return 5;    
        
        return 0;
    }
    
    
     
    function getWeekBonus(uint fixedTime) private view returns (uint) {
         
        if (currentType == Type.Presale) {
            uint currentWeek = getCurrentWeek(startPresaleTime, fixedTime); 
            
                 if (currentWeek == 1)  return 80;   
            else if (currentWeek == 2)  return 70;   
            else if (currentWeek == 3)  return 60;   
            else if (currentWeek == 4)  return 50;   
            else if (currentWeek == 5)  return 40;   
            else if (currentWeek == 6)  return 30;   
            else if (currentWeek == 7)  return 20;   
            else if (currentWeek == 8)  return 10;   
            else if (currentWeek == 9)  return 1;    
        }
        
         
        return 0;
    }
    
     
    function initialize() public onlyOwner isCrowdsaleOff isPouse isPresale {
        require(
            founder != address(0), 
            "Address of the &#39;Founders&#39; is 0x0, please set the address of the &#39;founder&#39;."
        );
        
        require(
            advisor != address(0), 
            "Address of the &#39;Advisors&#39; is 0x0, please set the address of the &#39;advisors&#39;."
        );
        
        require(
            supporter != address(0), 
            "Address of the &#39;Bounty supporters&#39; is 0x0, please set the address of the &#39;supporter&#39;."
        );
        
        require(
            coldWallet != address(0),
            "&#39;coldWallet&#39; is 0x0, please set the address &#39;coldWallet&#39; to continue."
        );
        
        require(startPresaleTime < endPresaleTime, "startPresaleTime >= endPresaleTime");
        require(endPresaleTime <= startIcoTime, "endPresaleTime > startIcoTime");
        require(startIcoTime < endIcoTime, "startIcoTime >= endIcoTime");
        
        currentStage = Stage.Init;
        isCrowdsaleInitialized = true;
    }
    
     
    function turnOnPresale() public onlyOwner isInit {
        currentStage = Stage.Running;
        currentType = Type.Presale;
    }
    
     
    function turnOnIco() public onlyOwner isPresaleFinished {
        currentStage = Stage.Running;
        currentType = Type.Ico;
    }
    
     
    function pouseCrowdsale() external onlyOwner isRunning whenNotPouse {
        currentStage = Stage.Pouse;
    }
    
     
    function runCrowdsale() external onlyOwner isPouse whenNotRunning {
        currentStage = Stage.Running;
    }
    
     
    function getBonusTokens(uint _fixedTime, uint _etherValue, uint tokensForSale) private view returns (uint) {
        uint bonusPercentage = 0;
        
        if (currentType == Type.Presale)
            bonusPercentage = getWeekBonus(_fixedTime);
            
        else if (currentType == Type.Ico)
            bonusPercentage = getVolumeBonus(_etherValue);
        
        uint totalBonusToken = tokensForSale.mul(bonusPercentage).div(100);
        
        return totalBonusToken;
    }
    
     
    function buyTokens(uint _fixedTime) private {
        uint tokensForSale;
        
         
        if (currentType == Type.Presale)
            tokensForSale = PRESALE_PRICE.mul(msg.value);
        
        else if (currentType == Type.Ico)
            tokensForSale = ICO_PRICE.mul(msg.value);
        
         
        uint bonusTokens = getBonusTokens(_fixedTime, msg.value, tokensForSale);
        
         
        uint totalTokensForSale = tokensForSale.add(bonusTokens);
        
         
        Token.transfer(msg.sender, totalTokensForSale);
        
         
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        weiRaised = weiRaised.add(msg.value);
        
         
        if (currentType == Type.Presale)
            totalSoldOnPresale = totalSoldOnPresale.add(totalTokensForSale);
        
         
        else if (currentType == Type.Ico)
            totalSoldOnIco = totalSoldOnIco.add(totalTokensForSale);
        
         
        totalSoldTokens = totalSoldTokens.add(totalTokensForSale);
    }
    
     
    function safeWithdrawal() public onlyOwner isIcoFinished isStoped {
        require(
            address(this).balance > 0, 
            "safeWithdrawal: Balance is 0."
        );
        
        require(
            address(this).balance >= softcap,
            "safeWithdrawal: You can not withdrow `Ether`, because softcap is not compiled."
        );
        
        coldWallet.transfer(address(this).balance);
        isWithdrawn = true;
    } 
    
     
    function refund() public isIcoFinished whenNotWithdrawn {
        require(
            address(this).balance > 0, 
            "Refund: address(this).balance <= 0"
        );
        
        require(
            address(this).balance < softcap, 
            "Refund: You can not refund your `Ether`, because softcap is compiled."
        );
        
        require(
            balances[msg.sender] > 0, 
            "Refund: You don&#39;t have enough `ETH` to refund."
        );
        
         
        uint balance = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(balance);
        
        weiRaised = weiRaised.sub(balance);
        
    }
    
     
    function finishCrowdsale() public onlyOwner isPresaleFinished isIcoFinished {
         
        currentStage = Stage.Stoped;
        
         
        if (
            totalSoldTokens > 0 && 
            totalSoldTokens == totalSoldOnPresale.add(totalSoldOnIco)
        ) {
            
             
             
            totalSoldTokens = totalSoldTokens.mul(100).div(salePercantage);
            
            
             
            uint tokensForAdvisorss = totalSoldTokens.mul(advisorsPercentage).div(100);
            Token.transfer(advisor, tokensForAdvisorss);
            
             
            uint tokensForSupporters = totalSoldTokens.mul(bountyPercentage).div(100);
            Token.transfer(supporter, tokensForSupporters);
            
             
            uint tokensForFouders = totalSoldTokens.mul(foundersPercentage).div(100);
            Token.transfer(founder, tokensForFouders);
            isCoinSentToFounder = true;
            
             
            Token.burn(Token.balanceOf(address(this)));
            
        }
    }
    
     
    function () external payable saleIsOn isRunning isUnderHadrCap {
        buyTokens(now);
    }
}