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
    using SafeMath for uint256;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
     
    
    constructor() public {
        owner = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    }
    

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}




contract ICO is Ownable{
        using SafeMath for uint256;

     
    uint type_of_token;  
    string ico_name;
    string public token_name;
    string public choose_a_symbol;
    uint public decimal;
    uint public rate; 
    uint funding_method;     
    uint public total_supply;
    uint tokens_available_for_sale_hardcap;
    uint minimum_investment;
    address client_wallet;
    uint256 no_of_tokens1;
    uint256 token;
     
    uint end_date_time;  
    mapping (address => uint256) balances;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    mapping (address => mapping (address => uint256)) internal allowed;
    event Approval(address indexed owner, address indexed spender, uint256 value);
 
     
    struct Phase{
        string Name;
        uint StartDateTime;  
        uint MaxCap;
        uint BonusPercent;
        uint MinInvest;
        uint TokenLockupPeriod;
        
        uint phaseRemainingBalance;  
    }
    Phase[] public phases;
    uint no_of_phases=0;

     
    string phase_name;
    uint phase_start_date_time;
    uint max_token_cap;
    uint bonus_percentage;
    uint min_investment_tokens;
    uint token_lockup_period;    
    
    
     
    struct CTD{
        address RecievingWallet;
        uint LockupPeriod;  
        uint no_of_tokens;
        string Name;
        uint Bonus;
        uint TypesOfDistribution;
    }
    CTD[] public ctdArray;
    uint no_of_CTD=0;
    
     
    address recieving_wallet;
    uint lockup;
    uint no_of_tokens;
    string name;
    uint bonus;
    uint types_of_distribution;
    
    constructor() public{
        
         
        type_of_token = 1;  
        ico_name = "EtherExchange";
        token_name = "Ethereum";
        choose_a_symbol = "ETH";
        decimal = 5;
        rate = 8500000000000000;     
        funding_method = 3;     
        total_supply = 5000000;
        tokens_available_for_sale_hardcap = 4000000;
        minimum_investment = 10;
        client_wallet = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
        balances[owner] = total_supply;
    
         
        phase_name = "phase1";
        phase_start_date_time = 1543449600;
        max_token_cap = 100000;
        bonus_percentage = 5;
        min_investment_tokens = 100;
        token_lockup_period = 9693621963;    
    
         
        Phase memory thisPhase = Phase(phase_name, phase_start_date_time, max_token_cap, bonus_percentage, min_investment_tokens, token_lockup_period, max_token_cap);
        phases.push(thisPhase);
        no_of_phases++;
        
         
        phase_name = "phase2";
        phase_start_date_time = 1543407605;
        max_token_cap = 100000;
        min_investment_tokens = 100;
        token_lockup_period = 9693621963;    
    
         
        thisPhase = Phase(phase_name, phase_start_date_time, max_token_cap, bonus_percentage, min_investment_tokens, token_lockup_period, max_token_cap);
        phases.push(thisPhase);
        no_of_phases++;
        
         
        recieving_wallet = 0x583031d1113ad414f02576bd6afabfb302140225;
        lockup = 1543190400;
        no_of_tokens1 = 1000;
        name = "ankush";
        bonus = 5;
        no_of_tokens = no_of_tokens1 + (no_of_tokens1*bonus)/100;
        types_of_distribution = 2;   
        balances[recieving_wallet]= no_of_tokens;
         
        CTD memory thisCTD = CTD(recieving_wallet, lockup, no_of_tokens, name, bonus, types_of_distribution);
        ctdArray.push(thisCTD);
        no_of_CTD++;
        
         
        recieving_wallet = 0xdd870fa1b7c4700f2bd7f44238821c26f7392148;
        lockup = 1543276800;
        no_of_tokens1 = 1200;
        name = "rahul";
        bonus = 5;
        no_of_tokens = no_of_tokens1+ (no_of_tokens1*bonus)/100;
        types_of_distribution = 2;   
        balances[recieving_wallet]= no_of_tokens;
         
        thisCTD = CTD(recieving_wallet, lockup, no_of_tokens, name, bonus, types_of_distribution);
        ctdArray.push(thisCTD);
        no_of_CTD++;
        
        
         
    }

     
    
    function readPhaseData(uint phaseIndex) public view returns(string, uint, uint, uint, uint, uint, uint){
        return (phases[phaseIndex].Name, phases[phaseIndex].StartDateTime, phases[phaseIndex].MaxCap, phases[phaseIndex].BonusPercent, phases[phaseIndex].MinInvest, phases[phaseIndex].TokenLockupPeriod, phases[phaseIndex].MaxCap);
    }
    
    function readCTDdata(uint CTDIndex) public view returns(address, uint, uint, string, uint, uint){
        return (ctdArray[CTDIndex].RecievingWallet, ctdArray[CTDIndex].LockupPeriod, ctdArray[CTDIndex].no_of_tokens, ctdArray[CTDIndex].Name, ctdArray[CTDIndex].Bonus, ctdArray[CTDIndex].TypesOfDistribution);
    }
    
    



      function transfer(address _to, uint _value) public payable {
         
         
        
        uint senderLockup = findLockupIfCTD(msg.sender);     
        
        if(senderLockup<now){    
             
            require(_to != address(0));  
            require(_value <= balances[msg.sender]);     
            
             
            balances[_to] = balances[_to].add(_value);
            balances[msg.sender] = balances[msg.sender].sub(_value);
            emit Transfer(msg.sender, _to, _value);
            
        }
        else{
             
            
        }
    }
    
    
    function findLockupIfCTD(address Address) internal returns(uint){
        for(uint i=0;i<no_of_CTD;i++){
            if(ctdArray[i].RecievingWallet == Address)
                return ctdArray[i].LockupPeriod;
        }
        return 0;
    }



    
     
    
        
  
     function () public payable {
        BuyTokens(msg.sender);
    }

    function BuyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        
        uint256 weiAmount = msg.value;  
         
        uint256 tokens = weiAmount.div(rate);

        require(tokens <= balances[owner]);
        getCurrentPhase();
        tokens = tokens+ (tokens*bonus)/100; 
         
        if(tokens > 0){
            balances[beneficiary] += tokens;
            balances[owner] -= tokens;
            total_supply -= tokens;
        }
    }



    
     
    function getCurrentPhase() public view returns(uint, uint){
        uint currentTimestamp = now;
        uint currentPhase = 0;
        for(uint i=0;i<no_of_phases;i++){
            if(currentTimestamp > phases[i].StartDateTime)
                currentPhase = i;
        }
        uint256 bonus = phases[currentPhase].BonusPercent;
        return (currentPhase,bonus);
    }
    
    function findWhichCTD(address Address) internal returns(uint){
        for(uint i=0;i<no_of_CTD;i++){
            if(ctdArray[i].RecievingWallet == Address)
                return i;
        }
        return 13072018;     
    }
    
    function balanceOf(address Address) public view returns(uint){
        return balances[Address];
    }
    
  

    function total_no_of_CTD() public view returns(uint){
        return no_of_CTD;
    }    
   
    
   
   
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

   
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
   emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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