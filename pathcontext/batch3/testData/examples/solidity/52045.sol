pragma solidity ^0.4.23;

  

 
library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint a, uint b) internal pure returns (uint) {
    uint c = a / b;
    return c;
  }
  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }
  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }
  function max256(uint a, uint b) internal pure returns (uint) {
    return a >= b ? a : b;
  }
  function min256(uint a, uint b) internal pure returns (uint) {
    return a < b ? a : b;
  }
}


 
contract ERC20Basic {
  function balanceOf(address who) public constant returns (uint);
  function transfer(address to, uint value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint value);
}

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint);
  function transferFrom(address from, address to, uint value) public returns (bool);
  function approve(address spender, uint value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint value);
}

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint;

  mapping(address => uint) balances;

   
  modifier onlyPayloadSize(uint size) {
   require(msg.data.length >= size + 4);
   _;
  }

   
  function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public constant returns (uint balance) {
    return balances[_owner];
  }
  
}

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint)) internal allowed;

   
  function transferFrom(address _from, address _to, uint _value) public returns (bool) {
    require(_to != address(0) && _value <= balances[_from] && _value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public constant returns (uint remaining) {
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

contract Deprecated is Ownable {

    bool private _deprecated;

    modifier deprecated {
        assert(!_deprecated);
        _;
    }
    function setDeprecated(bool _status) public onlyOwner {
        _deprecated = _status;
    }
    function isDeprecated() public view returns (bool) {
        return _deprecated;
    }
}

contract FlexFaucet is Deprecated {
    using SafeMath for uint;
    
    string public name;
    string public version;

    event Deposit(address indexed sender, uint256 value);
    
    event TokenSent(address receiver, uint amout);
    
    event FaucetOn(bool status);
    event FaucetOff(bool status);

    uint private constant atto = 1000000000000000000;
    uint private constant hour = 1 hours;
    
    uint private maxDrip = 30 * atto;
    
    bool public faucetStatus;
    mapping(address => uint256) status;

    modifier faucetOn {
        require(faucetStatus);
        _;
    }
    modifier faucetOff {
        require(!faucetStatus);
        _;
    }

    constructor(string _name, string _version) public {
        version = _version;
        name = _name;
        
        faucetStatus = true;
        emit FaucetOn(faucetStatus);
    }

    function() public payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }
    
    function transfer(
        address _erc, address _to, uint _value
        ) public onlyOwner faucetOn
        returns (bool) {
        uint oldERCBalance = ERC20(_erc).balanceOf(_to);
        if (!StandardToken(_erc).transfer(_to, _value)) {
            if (ERC20(_erc).balanceOf(_to) <= oldERCBalance ||
            ERC20(_erc).balanceOf(_to) != oldERCBalance.add(_value)) {
                revert();
            }
        }
        return true;
    }
    function turnFaucetOn()
        public onlyOwner faucetOff
        returns(bool) {
        faucetStatus = true;
        emit FaucetOn(faucetStatus);
        return true;
    }
    function turnFaucetOff()
        public onlyOwner faucetOn()
        returns(bool) {
        faucetStatus = false;
        emit FaucetOff(faucetStatus);
        return true;
    }

    function dripToken(
        address _erc, uint amount
        ) public faucetOn
        returns(bool) {
        require(
            canDrip(msg.sender) && amount >= atto && amount <= maxDrip
            && StandardToken(_erc).balanceOf(address(this)) >= amount
        );
        
        uint oldERCBalance = ERC20(_erc).balanceOf(msg.sender);
        if (!StandardToken(_erc).transfer(msg.sender, amount)) {
            if (ERC20(_erc).balanceOf(msg.sender) <= oldERCBalance ||
            ERC20(_erc).balanceOf(msg.sender) != oldERCBalance.add(amount)) {
                revert();
            }
        }
        
        updateStatus(msg.sender, ((amount / atto) * hour));

        emit TokenSent(msg.sender, amount);
        return true;
    }

    function canDrip(
        address _address
        ) public view
        returns (bool) {
        return (status[_address] == 0)  ? true :
            (block.timestamp >= status[_address])
                ? true : false;
    }

    function waitTime(
        address _address
        ) public view
        returns (uint) {
        return status[_address] > 0 ? status[_address].sub(block.timestamp) : 0;
    }

    function updateStatus(
        address _address, uint256 _timelock
        ) internal
        returns (bool) {
        status[_address] = block.timestamp.add(_timelock);
        return true;
    }

}