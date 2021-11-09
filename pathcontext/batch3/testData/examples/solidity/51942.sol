pragma solidity ^0.4.24;
 

 
 
 
library SafeMath
{
    function mul(uint256 a, uint256 b) internal pure returns (uint256)
    {
        if (a == 0)
        {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256)
    {
         
        uint256 c = a / b;
         
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

 
 
 
contract Owned
{
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public
    {
        owner = msg.sender;
    }

    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner
    {
        newOwner = _newOwner;
    }

    function acceptOwnership() public
    {
        require(msg.sender == newOwner);
        owner = newOwner;
        newOwner = address(0);
        emit OwnershipTransferred(owner, newOwner);
    }
}

 
 
 
contract Stoppable is Owned
{
    bool public stopped;

    modifier canStop
    {
        assert (!stopped);
        _;
    }
    
    function stop() public onlyOwner
    {
        stopped = true;
    }
    
    function start() public onlyOwner
    {
        stopped = false;
    }
}

 
 
 
contract ERC20 is Stoppable
{
    using SafeMath for uint256;
    
    uint256 public totalSupply;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed owner, uint256 value);
    event Burn(address indexed owner, uint256 value);
    
    function transfer(address _to, uint256 _value) public canStop returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        
         
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance)
    {
        return balances[_owner];
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public canStop returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public canStop returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256)
    {
        return allowed[_owner][_spender];
    }
    
    function increaseApproval(address _spender, uint _addedValue) public canStop returns (bool)
    {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
    function decreaseApproval(address _spender, uint _subtractedValue) public canStop returns (bool)
    {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue)
        {
            allowed[msg.sender][_spender] = 0;
        }
        else
        {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

 
 
 
contract TokenSender is Owned, Stoppable, ERC20
{
    string public constant name = "TokenSender";
    string public constant symbol = "TKNSNDR";
    uint8 public constant decimals = 8;
    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));
    
    address public fundsWallet;            
    uint256 public unitsOneEthCanBuy;      
    
    ERC20 public butter;
    
    constructor() public
    {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        
        unitsOneEthCanBuy = 20000; 
        fundsWallet = msg.sender;
        
        
        butter = ERC20(0x0F8667b09984043E0bfDBA4BD2092A6e02Ab4B14);
         
        
         
        
         
    }
    
    function multisend(address _tokenAddr, address[] dests, uint256[] values) public onlyOwner returns (uint256)
    {
        uint256 i = 0;
        while (i < dests.length)
        {
           ERC20(_tokenAddr).transfer(dests[i], values[i]);
           i += 1;
        }
        return(i);
    }
    
    function balanceOfButter(address _owner) public view returns (uint256 balance)
    {
        return butter.balanceOf(_owner);
    }
    
    function balanceOfToken(ERC20 _token, address _owner) public view returns (uint256 balance)
    {
        return _token.balanceOf(_owner);
    }
    
    function mint(uint256 _value) public onlyOwner canStop returns (bool success)
    {
        balances[msg.sender] += _value;
        totalSupply += _value;
        emit Mint(msg.sender, _value);
        return true;
    }
    
    function burn(uint256 _value) public onlyOwner canStop returns (bool success)
    {
        require(balances[msg.sender] >= _value);    
        balances[msg.sender] -= _value;             
        totalSupply -= _value;                       
        emit Burn(msg.sender, _value);
        return true;
    }
    
    function changeWallet(address _owner) public onlyOwner returns (bool success)
    {
        fundsWallet = _owner;
        return true;
    }

    function() public payable
    {
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);
        
        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;
        
        emit Transfer(fundsWallet, msg.sender, amount);
        
         
        fundsWallet.transfer(msg.value);
    }
}