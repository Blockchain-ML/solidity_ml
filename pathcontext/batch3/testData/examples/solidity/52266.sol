pragma solidity ^0.4.24;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


 
 
 
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


 
 
 
 
contract PartiallyBadToken is Owned {

    string public symbol = "PBAD";
    string public  name = "Partially Bad";
    uint8 public constant decimals = 18;
    uint constant _totalSupply = 100000000 * 10**uint(decimals);

    uint public constant DRIP_AMOUNT = 1000 * 10**uint(decimals);

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

     
     
     
    constructor() public {
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }


     
     
     
    function drip() public {
        if (balances[owner] >= DRIP_AMOUNT) {
            balances[owner] = balances[owner] - DRIP_AMOUNT;
            balances[msg.sender] = balances[msg.sender] + DRIP_AMOUNT;
            emit Transfer(owner, msg.sender, DRIP_AMOUNT);
        }
    }


     
     
     
    function totalSupply() public view returns (uint) {
        return _totalSupply - balances[address(0)];
    }


     
     
     
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


     
     
     
     
     
     
     
    function transfer(address to, uint tokens) public {
        if (balances[msg.sender] >= tokens) {
            balances[msg.sender] = balances[msg.sender] - tokens;
            balances[to] = balances[to] + tokens;
            emit Transfer(msg.sender, to, tokens);
        }
    }


     
     
     
     
     
     
     
     
     
     
    function approve(address spender, uint tokens) public {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
    }


     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, uint tokens) public returns (bool) {
        if (balances[from] >= tokens && allowed[from][msg.sender] >= tokens) {
            balances[from] = balances[from] - tokens;
            allowed[from][msg.sender] = allowed[from][msg.sender] - tokens;
            balances[to] = balances[to] + tokens;
            emit Transfer(from, to, tokens);
        }
        return true;
    }


     
     
     
     
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


     
     
     
    function () public payable {
        revert();
    }
}