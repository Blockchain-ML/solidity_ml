pragma solidity ^0.4.23;

 

 
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

     
    function balanceOf(address _owner) public view returns (uint256 balance) {
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

 


pragma solidity ^0.4.23;




 
contract TransferableToken is StandardToken,Ownable {

     

    event Transferable();
    event UnTransferable();

    bool public transferable = false;
    mapping (address => bool) public whitelisted;

     
    
    constructor() 
        StandardToken() 
        Ownable()
        public 
    {
        whitelisted[msg.sender] = true;
    }

     

     
    modifier whenNotTransferable() {
        require(!transferable);
        _;
    }

     
    modifier whenTransferable() {
        require(transferable);
        _;
    }

     
    modifier canTransfert() {
        if(!transferable){
            require (whitelisted[msg.sender]);
        } 
        _;
   }
   
     

     
    function allowTransfert() onlyOwner whenNotTransferable public {
        transferable = true;
        emit Transferable();
    }

     
    function restrictTransfert() onlyOwner whenTransferable public {
        transferable = false;
        emit UnTransferable();
    }

     
    function whitelist(address _address) onlyOwner public {
        require(_address != 0x0);
        whitelisted[_address] = true;
    }

     
    function restrict(address _address) onlyOwner public {
        require(_address != 0x0);
        whitelisted[_address] = false;
    }


     

    function transfer(address _to, uint256 _value) public canTransfert returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public canTransfert returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

   
    function approve(address _spender, uint256 _value) public canTransfert returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public canTransfert returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public canTransfert returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

 


pragma solidity ^0.4.23;




contract TCLRToken is TransferableToken {
 

    string public symbol = "TCLR";
    string public name = "TCLR";
    uint256 public decimals = 18;
  

    uint256 constant internal DECIMAL_CASES    = (10 ** 18);
    uint256 constant public   ICO             =  48369987 * DECIMAL_CASES;  
    uint256 constant public   TEAM             =   7773748 * DECIMAL_CASES;  
    uint256 constant public   ADVISORS         =   4318748 * DECIMAL_CASES;  
    uint256 constant public   COMPANY         =   7773748 * DECIMAL_CASES;  
    uint256 constant public   BONUS  =   16411245 * DECIMAL_CASES;          
    uint256 constant public   BOUNTY           =    1727500 * DECIMAL_CASES;  

    address public ico_address     = 0x7C53f81cd5718162CC3903a10dbeE391A0E9d90E;     
    address public team_address     = 0x46B5cE5140FaB20567df484322A77fB3334Fb393;    
    address public advisors_address = 0x26B5cFAd1703f08d7AF2034f7B6465b58ead795E;    
    address public company_address = 0x242aed53b9C369B7Ef67D03Fe72248c3e054d873;    
    address public bonus_address = 0xE95F8397533c35B1E53309FeB93eAB6F757B8594;       
    address public bounty_address   = 0x69277dA93c2263e24e069D98d1040c7A7f7C8093;   
    bool public initialDistributionDone = false;

     
    function reset(address _icoAddrss, address _teamAddrss, address _advisorsAddrss, address _companyAddrss, address _bonusAddrss, address _bountyAddrss) public onlyOwner{
        require(!initialDistributionDone);
        
        ico_address = _icoAddrss;
        team_address = _teamAddrss;
        advisors_address = _advisorsAddrss;
        company_address = _companyAddrss;
        bonus_address = _bonusAddrss;
        bounty_address = _bountyAddrss;
        
    }

     
    function distribute() public onlyOwner {
         
        require(!initialDistributionDone);
        require(ico_address != 0x0 && team_address != 0x0 && advisors_address != 0x0 && company_address != 0x0 && bonus_address != 0x0  && bounty_address != 0x0);      

         
        totalSupply_ = ICO.add(TEAM).add(ADVISORS).add(COMPANY).add(BONUS).add(BOUNTY);

         
        balances[owner] = totalSupply_;
        emit Transfer(0x0, owner, totalSupply_);
        
        transfer(ico_address, ICO);
        transfer(team_address, TEAM);
        transfer(advisors_address, ADVISORS);
        transfer(company_address, COMPANY);
        transfer(bonus_address, BONUS);
        transfer(bounty_address, BOUNTY);
        
        initialDistributionDone = true;
        whitelist(ico_address);  
        whitelist(bounty_address);  
    }

     
    function setName(string _name) onlyOwner public {
        name = _name;
    }

}