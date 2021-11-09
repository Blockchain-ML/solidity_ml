pragma solidity ^0.4.24;

 
 
library SafeMath{
    
    
   
  
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

 

contract Token{
    
    function totalSupply() public view returns (uint256);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


 

contract StandardToken is Token{
  using SafeMath for uint256;

  mapping (address => uint256)  balances;

  mapping (address => mapping (address => uint256)) allowed;
  
  uint256 public totalSupply;


   
  
  function totalSupply() public view returns (uint256) {
    return totalSupply;
  }
  
  
   

  function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
  }

  
  
   
  
  function allowance(address _owner,address _spender)public view returns (uint256){
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
  
  
     

  function transferFrom(address _from,address _to,uint256 _value)public returns (bool){
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

}


 

contract Ownable {
    
    address public owner;
    address public backupOwner;
    
    

    constructor () public {
        owner=msg.sender;
        backupOwner=0xE81A9B080652DF33B9Dc68974aFf3a92cbA24B53;
        
    } 
    
     
   
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyBackupOwner() {
        require(msg.sender == backupOwner);
        _;
    }
    
    function transferOwnership(address newOwner) public onlyBackupOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}

 

contract Authorizable is Ownable {

    mapping(address => bool) public authorized;
    event authorityAdded(address indexed _toAdd);
    event authorityRemoved(address indexed _toRemove);

    modifier onlyAuthorized() {
        require(authorized[msg.sender] || owner == msg.sender);
        _;
    }

    function addAuthorized(address _toAdd) onlyOwner public {
        require(_toAdd != 0);
        authorized[_toAdd] = true;
        emit authorityAdded(_toAdd);
    }

    function removeAuthorized(address _toRemove) onlyOwner public {
        require(_toRemove != 0);
        require(_toRemove != msg.sender);
        authorized[_toRemove] = false;
        emit authorityRemoved(_toRemove);
    }

}


 

contract SilaToken is StandardToken,Authorizable{
    using SafeMath for uint256;
    
     
    string  public constant name = "SilaToken";
    string  public constant symbol = "SILA";
    uint256 public constant decimals = 18;
    string  public version = "1.0";
    bool public emergencyFlag; 
    
     
     
    event Issued(address indexed _to,uint256 _value);
    event Redeemed(address indexed _from,uint256 _amount);
    

    
    constructor () public{
      emergencyFlag = false;                            
      
    }
    
    
    

    function issue(address _to, uint256 _amount) public onlyAuthorized returns (bool) {
      require(emergencyFlag==false);
      require(_to !=address(0));
      totalSupply = totalSupply.add(_amount);
      balances[_to] = balances[_to].add(_amount);                 
      emit Issued(_to, _amount);                     
      return true;
    }
    
    
      
    

    function redeem(address _from,uint256 _amount) public onlyAuthorized returns(bool){
        require(emergencyFlag==false);
        require(_from != address(0));
        require(_amount <= balances[_from]);
        balances[_from] = balances[_from].sub(_amount);   
        totalSupply = totalSupply.sub(_amount);
        emit Redeemed(_from,_amount);
        return true;
            

    }
    
    
     

    function protectedTransfer(address _from,address _to,uint256 _amount) public onlyAuthorized returns(bool){
        require(_amount <= balances[_from]);
        require(_to != address(0));
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
        
    }
    
 
    
     
    
    function emergencyToggle() external onlyOwner{
      emergencyFlag = !emergencyFlag;
    }

    

    
    

    
    
}