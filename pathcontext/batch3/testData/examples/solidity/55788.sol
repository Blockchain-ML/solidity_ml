pragma solidity ^0.4.15;
 
contract Utils {
     
    function Utils() {
    }

     
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

     
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

     

     
    function safeAdd(uint256 _x, uint256 _y) internal returns (uint256) {
        uint256 z = _x + _y;
        assert(z >= _x);
        return z;
    }

     
    function safeSub(uint256 _x, uint256 _y) internal returns (uint256) {
        assert(_x >= _y);
        return _x - _y;
    }

     
    function safeMul(uint256 _x, uint256 _y) internal returns (uint256) {
        uint256 z = _x * _y;
        assert(_x == 0 || z / _x == _y);
        return z;
    }
}

 
contract IERC20Token {
     
    function name() public constant returns (string) { name; }
    function symbol() public constant returns (string) { symbol; }
    function decimals() public constant returns (uint8) { decimals; }
    function totalSupply() public constant returns (uint256) { totalSupply; }
    function balanceOf(address _owner) public constant returns (uint256 balance) { _owner; balance; }
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { _owner; _spender; remaining; }

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}


 
contract ERC20Token is IERC20Token, Utils {
    string public standard = "Token 0.1";
    string public name = "";
    string public symbol = "";
    uint8 public decimals = 0;
    uint256 public totalSupply = 0;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

     
    function ERC20Token(string _name, string _symbol, uint8 _decimals) {
        require(bytes(_name).length > 0 && bytes(_symbol).length > 0);  

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

     
    function transfer(address _to, uint256 _value)
        public
        validAddress(_to)
        returns (bool success)
    {
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

     
    function transferFrom(address _from, address _to, uint256 _value)
        public
        validAddress(_from)
        validAddress(_to)
        returns (bool success)
    {
        allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender], _value);
        balanceOf[_from] = safeSub(balanceOf[_from], _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        Transfer(_from, _to, _value);
        return true;
    }
    
    
    

     
    function approve(address _spender, uint256 _value)
        public
        validAddress(_spender)
        returns (bool success)
    {
         
        require(_value == 0 || allowance[msg.sender][_spender] == 0);

        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
}

 
contract IOwned {
     
    function owner() public constant returns (address) { owner; }

    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
}

 
contract Owned is IOwned {
    address public owner;
    address public newOwner;

    event OwnerUpdate(address _prevOwner, address _newOwner);

     
    function Owned() {
        owner = msg.sender;
    }

     
    modifier ownerOnly {
        assert(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

     
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
}

 
contract ITokenHolder is IOwned {
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
}


contract TokenHolder is ITokenHolder, Owned, Utils {
     
    function TokenHolder() {
    }

     
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_to)
        notThis(_to)
    {
        assert(_token.transfer(_to, _amount));
    }
}


contract TCLRToken is ERC20Token, TokenHolder {

 

    uint256 constant public TCLR_UNIT = 10 ** 18;
    uint256 public totalSupply = 86374977 * TCLR_UNIT;

     
    uint256 constant public maxIcoSupply = 48369987 * TCLR_UNIT;            
    uint256 constant public Company = 7773748 * TCLR_UNIT;      
    uint256 constant public Bonus = 16411245 * TCLR_UNIT;   
    uint256 constant public Bounty = 1727500 * TCLR_UNIT;   
    uint256 constant public advisorsAllocation = 4318748 * TCLR_UNIT;           
    uint256 constant public TCLRinTeamAllocation = 7773748 * TCLR_UNIT;     

    
   address public constant ICOSTAKE = 0x41dB8E8b09B8826761CED4f3bd32f9Bb1e8aA679;
   address public constant COMPANY_STAKE_1 = 0x2BD3d9862207c35e74EF839E8Ca7fF8B8fc1FE78;
    address public constant COMPANY_STAKE_2 = 0xB91d08bC1799a527130f800801634b0313cF7626;
    address public constant COMPANY_STAKE_3 = 0xc6aBc0B26D669fDA2E1ca64A68E0D367c842E33f;
    address public constant COMPANY_STAKE_4 = 0xd190772fB02b390e8269e66415955748C71f4F6d;
    address public constant COMPANY_STAKE_5 = 0xcb2f741629E866f0eE81c042B46D6a71eb965909;
    address public constant ADVISOR_1 = 0x6Ff9efC0d0EF6d18D0e040AaBA6e31f55a6f24c6;
    address public constant ADVISOR_2 = 0x7C53f81cd5718162CC3903a10dbeE391A0E9d90E;
    address public constant ADVISOR_3 = 0x46B5cE5140FaB20567df484322A77fB3334Fb393;
    address public constant ADVISOR_4 = 0x26B5cFAd1703f08d7AF2034f7B6465b58ead795E;
    address public constant ADVISOR_5 = 0x242aed53b9C369B7Ef67D03Fe72248c3e054d873;
    address public constant TEAM_1 = 0xE95F8397533c35B1E53309FeB93eAB6F757B8594;
    address public constant TEAM_2 = 0x69277dA93c2263e24e069D98d1040c7A7f7C8093;
    address public constant TEAM_3 = 0xb8B7697b7C92462Bcd3B363b538306611bA70352;
    address public constant TEAM_4 = 0x6C0F2Baa798EAa50395201e068Bba91Fe3b8aEaB;
    address public constant TEAM_5 = 0xbbA201F8244A4B2644eaD291b2a79872930eEc15;
    address public constant BONUS_1 = 0x3F8d61be3DBaE3411f8F25E878978d09eB7dDD23;
    address public constant BONUS_2 = 0x317C5ad69e680c5026DaF828B1d4f11bFE40f8A6;
    address public constant BONUS_3 = 0x5637a78212F3d39335dd2f88c385326DfaF65DCb;
    address public constant BONUS_4 = 0xFD43f785438E74cF4185Ae34BD45134fEc1b8f02;
    address public constant BONUS_5 = 0x41086A910A366e7369D342D3bAd45faa548694C7;
    address public constant BOUNTY_1 = 0x9439f285372042B2F77161036f9Efd7De4a96bFE;
    address public constant BOUNTY_2 = 0xC792E94Ff022ef52fFb9619A5bD379879467Ad66;
    address public constant BOUNTY_3 = 0x11c3D3aAd343dC9ed5e51F6c9ebc9F3E8b55d703;
    address public constant BOUNTY_4 = 0x3Bf6992ed3D301eE289b6340A56Ad9e9b49e7066;
    address public constant BOUNTY_5 = 0x9d5e152A570E06Bc91f89ebae21B4261251f60B3;




    
    
     
uint256 constant public COMPANY_1 = 50000 * TCLR_UNIT;  
uint256 constant public COMPANY_2 = 60000 * TCLR_UNIT;  
uint256 constant public COMPANY_3 = 70000 * TCLR_UNIT;  
uint256 constant public COMPANY_4 = 80000 * TCLR_UNIT;  
uint256 constant public COMPANY_5 = 90000 * TCLR_UNIT;  

 
uint256 constant public ADVISOR1 = 1000 * TCLR_UNIT;  
uint256 constant public ADVISOR2 = 2000 * TCLR_UNIT;  
uint256 constant public ADVISOR3 = 3000 * TCLR_UNIT;  
uint256 constant public ADVISOR4 = 4000 * TCLR_UNIT;  
uint256 constant public ADVISOR5 = 135000 * TCLR_UNIT;  


 
uint256 constant public TEAM1 = 5000 * TCLR_UNIT;  
uint256 constant public TEAM2 = 7000 * TCLR_UNIT;  
uint256 constant public TEAM3 = 12000 * TCLR_UNIT;  
uint256 constant public TEAM4 = 14000 * TCLR_UNIT;  
uint256 constant public TEAM5 = 25000 * TCLR_UNIT;  


 
uint256 constant public BONUS1 = 15000 * TCLR_UNIT;  
uint256 constant public BONUS2 = 20000 * TCLR_UNIT;  
uint256 constant public BONUS3 = 30000 * TCLR_UNIT;  
uint256 constant public BONUS4 = 40000 * TCLR_UNIT;  
uint256 constant public BONUS5 = 45000 * TCLR_UNIT;  

 
uint256 constant public BOUNTY1 = 10500 * TCLR_UNIT;  
uint256 constant public BOUNTY2 = 20600 * TCLR_UNIT;  
uint256 constant public BOUNTY3 = 40300 * TCLR_UNIT;  
uint256 constant public BOUNTY4 = 20900 * TCLR_UNIT;  
uint256 constant public BOUNTY5 = 21895 * TCLR_UNIT;  




    
    




     

uint256 public totalAllocatedToCompany = 0;      
uint256 public totalAllocatedToAdvisor = 0;         
uint256 public totalAllocatedToTEAM = 0;      
uint256 public totalAllocatedToBONUS = 0;         
uint256 public totalAllocatedToBOUNTY = 0;       





uint256 public totalAllocated = 0;              
    uint256 constant public endTime = now;                                      

    bool internal isReleasedToPublic = false;  
    
    bool public isReleasedToadv = false;
    bool public isReleasedToteam = false;
 

     
    

    

     

    
    function TCLRToken()
    ERC20Token("TCLR", "TCLR", 18)
     {
        
                       
        balanceOf[ICOSTAKE] = maxIcoSupply;  
        balanceOf[COMPANY_STAKE_1] = COMPANY_1;  
         balanceOf[COMPANY_STAKE_2] = COMPANY_2;  
          balanceOf[COMPANY_STAKE_3] = COMPANY_3;  
           balanceOf[COMPANY_STAKE_4] = COMPANY_4;  
            balanceOf[COMPANY_STAKE_5] = COMPANY_5;  
            totalAllocatedToCompany = safeAdd(totalAllocatedToCompany, COMPANY_1);
totalAllocatedToCompany = safeAdd(totalAllocatedToCompany, COMPANY_2);
totalAllocatedToCompany = safeAdd(totalAllocatedToCompany, COMPANY_3);
totalAllocatedToCompany = safeAdd(totalAllocatedToCompany, COMPANY_4);
totalAllocatedToCompany = safeAdd(totalAllocatedToCompany, COMPANY_5);

        balanceOf[BONUS_1] = BONUS1;        
        balanceOf[BONUS_2] = BONUS2;        
        balanceOf[BONUS_3] = BONUS3;        
        balanceOf[BONUS_4] = BONUS4;        
        balanceOf[BONUS_5] = BONUS5;        
        totalAllocatedToBONUS = safeAdd(totalAllocatedToBONUS, BONUS1);
totalAllocatedToBONUS = safeAdd(totalAllocatedToBONUS, BONUS2);
totalAllocatedToBONUS = safeAdd(totalAllocatedToBONUS, BONUS3);
totalAllocatedToBONUS = safeAdd(totalAllocatedToBONUS, BONUS4);
totalAllocatedToBONUS = safeAdd(totalAllocatedToBONUS, BONUS5);

        balanceOf[BOUNTY_1] = BOUNTY1;        
        balanceOf[BOUNTY_2] = BOUNTY2;        
        balanceOf[BOUNTY_3] = BOUNTY3;        
        balanceOf[BOUNTY_4] = BOUNTY4;        
        balanceOf[BOUNTY_5] = BOUNTY5;        

totalAllocatedToBOUNTY = safeAdd(totalAllocatedToBOUNTY, BOUNTY1);
totalAllocatedToBOUNTY = safeAdd(totalAllocatedToBOUNTY, BOUNTY2);
totalAllocatedToBOUNTY = safeAdd(totalAllocatedToBOUNTY, BOUNTY3);
totalAllocatedToBOUNTY = safeAdd(totalAllocatedToBOUNTY, BOUNTY4);
totalAllocatedToBOUNTY = safeAdd(totalAllocatedToBOUNTY, BOUNTY5);


        allocateAdvisorTokens() ;
        allocateTCLRinTeamTokens();
        

totalAllocated += maxIcoSupply+ totalAllocatedToCompany+ totalAllocatedToBONUS + totalAllocatedToBOUNTY;   
    }

 

     
     
    
    
    
      
         

   
   
    modifier canTransfer() {
        require( isTransferAllowedteam()==true );
        _;
    }
    
   modifier canTransferadv() {
        require( isTransferAllowedadv()==true );
        _;
    }
    
    
    function transfer(address _to, uint256 _value) canTransfer canTransferadv public returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) canTransfer canTransferadv public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
    
    

    
    
 

    
    function allocateTCLRinTeamTokens() public returns(bool success) {
        require(totalAllocatedToTEAM < TCLRinTeamAllocation);

        balanceOf[TEAM_1] = safeAdd(balanceOf[TEAM_1], TEAM1);        
        balanceOf[TEAM_2] = safeAdd(balanceOf[TEAM_2], TEAM2);        
        balanceOf[TEAM_3] = safeAdd(balanceOf[TEAM_3], TEAM3);         
        balanceOf[TEAM_4] = safeAdd(balanceOf[TEAM_4], TEAM4);         
        balanceOf[TEAM_5] = safeAdd(balanceOf[TEAM_5], TEAM5);        
        
       
       totalAllocatedToTEAM = safeAdd(totalAllocatedToTEAM, TEAM1);
totalAllocatedToTEAM = safeAdd(totalAllocatedToTEAM, TEAM2);
totalAllocatedToTEAM = safeAdd(totalAllocatedToTEAM, TEAM3);
totalAllocatedToTEAM = safeAdd(totalAllocatedToTEAM, TEAM4);
totalAllocatedToTEAM = safeAdd(totalAllocatedToTEAM, TEAM5);

totalAllocated +=  totalAllocatedToTEAM; 


 


                   
            return true;
        
        
    }

    
    function allocateAdvisorTokens() public returns(bool success) {
        require(totalAllocatedToAdvisor < advisorsAllocation);

        balanceOf[ADVISOR_1] = safeAdd(balanceOf[ADVISOR_1], ADVISOR1); 
        balanceOf[ADVISOR_2] = safeAdd(balanceOf[ADVISOR_2], ADVISOR2); 
        balanceOf[ADVISOR_3] = safeAdd(balanceOf[ADVISOR_3], ADVISOR3); 
        balanceOf[ADVISOR_4] = safeAdd(balanceOf[ADVISOR_4], ADVISOR4); 
        balanceOf[ADVISOR_5] = safeAdd(balanceOf[ADVISOR_5], ADVISOR5); 
        
       
       totalAllocatedToAdvisor = safeAdd(totalAllocatedToAdvisor, ADVISOR1);
totalAllocatedToAdvisor = safeAdd(totalAllocatedToAdvisor, ADVISOR2);
totalAllocatedToAdvisor = safeAdd(totalAllocatedToAdvisor, ADVISOR3);
totalAllocatedToAdvisor = safeAdd(totalAllocatedToAdvisor, ADVISOR4);
totalAllocatedToAdvisor = safeAdd(totalAllocatedToAdvisor, ADVISOR5);

totalAllocated +=  totalAllocatedToAdvisor; 


        
        return true;
    }



    function releaseAdvisorTokens() ownerOnly {
        
         isReleasedToadv = true;
        
        
    }

     function releaseTCLRinTeamTokens() ownerOnly  {
        
         isReleasedToteam = true;
         
                   
            
        
        
    }


    
    function burnTokens(uint256 _value) ownerOnly returns(bool success) {
        uint256 amountOfTokens = _value;

        balanceOf[msg.sender]=safeSub(balanceOf[msg.sender], amountOfTokens);
        totalSupply=safeSub(totalSupply, amountOfTokens);       
        Transfer(msg.sender, 0x0, amountOfTokens);
        return true;
    }

    

     
    function allowTransfers() ownerOnly {
        isReleasedToPublic = true;
        
    } 

     
    function isTransferAllowedteam() public returns(bool) 
    {
        
        if (isReleasedToteam==true)
        return true;
        
        if(now < endTime + 52 weeks)

{
if(msg.sender==TEAM_1 || msg.sender==TEAM_2 || msg.sender==TEAM_3 || msg.sender==TEAM_4 || msg.sender==TEAM_5) 

return false;


}


return true;
    }
    
  
 function isTransferAllowedadv() public returns(bool) 
    {
        if (isReleasedToadv==true)
        return true;
        
        
       
       
        if(now < endTime + 26 weeks)

{
if(msg.sender==ADVISOR_1 || msg.sender==ADVISOR_2 || msg.sender==ADVISOR_3 || msg.sender==ADVISOR_4 || msg.sender==ADVISOR_5) 

return false;


}

return true;
    }
      
    
    
   
}