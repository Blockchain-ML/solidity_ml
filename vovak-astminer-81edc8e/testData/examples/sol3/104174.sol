pragma solidity ^0.5.0;

contract TestaExchange {
    
    ERC20Token testa = ERC20Token(0x1da65B1868e2d36d06d7A44DBD2Be98e49E1f7f9);
    ERC20Token jTesta = ERC20Token(0xEc7B95ba343224A9ED1EEe230912055DcD7081CA);
    
    function stake(uint _value) public {
        testa.transferFrom(msg.sender, address(this), _value);
        jTesta.transfer(msg.sender, _value);
    }
    
    function unstake(uint _value) public {
        jTesta.transferFrom(msg.sender, address(this), _value);
        testa.transfer(msg.sender, _value);
    }
    
    function getStakedBalance() public view returns (uint) {
        return testa.balanceOf(address(this));
    }
    
    function balanceOf(address _owner) public view returns (uint) {
        return jTesta.balanceOf(_owner);
    }

}

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

 
contract Ownable {
  address public owner;


   
  constructor() public {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
      require(msg.sender == owner);
    _;
  }


   
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

 
contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) public view returns (uint);
  function transfer(address to, uint value) public;
  event Transfer(address indexed from, address indexed to, uint value);
}


 
contract BasicToken is ERC20Basic {
  using SafeMath for uint;

  mapping(address => uint) balances;

   
  function transfer(address _to, uint _value) public {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
  }

   
  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }

}


 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint);
  function transferFrom(address from, address to, uint value) public;
  function approve(address spender, uint value) public;
  event Approval(address indexed owner, address indexed spender, uint value);
}


 
contract StandardToken is BasicToken, ERC20 {

  mapping (address => mapping (address => uint)) allowed;


   
  function transferFrom(address _from, address _to, uint _value) public {
    uint256 _allowance = allowed[_from][msg.sender];

     
     

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
  }

   
  function approve(address _spender, uint _value) public {

     
     
     
     
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) revert("approve revert");

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
  }

   
  function allowance(address _owner, address _spender) public view returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}

 

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint value);
  event MintFinished();

  bool public mintingFinished = false;
  uint public totalSupply = 0;


  modifier canMint() {
    if(mintingFinished) revert();
    _;
  }

   
  function mint(address _to, uint _amount) public onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    return true;
  }

   
  function finishMinting() public onlyOwner returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}


 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    if (paused) revert("it's paused");
    _;
  }

   
  modifier whenPaused {
    if (!paused) revert("it's not paused");
    _;
  }

   
  function pause() public onlyOwner whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

   
  function unpause() public onlyOwner whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}


 

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint _value) public whenNotPaused {
    super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) public whenNotPaused {
    super.transferFrom(_from, _to, _value);
  }
}

 
contract ERC20Token is PausableToken, MintableToken {
  using SafeMath for uint256;

  string public name;
  string public symbol;
  uint public decimals;

  constructor(string memory _name, string memory _symbol, uint _decimals) public  {
      name = _name;
      symbol = _symbol;
      decimals = _decimals;
  }
}

contract TestaToken is ERC20Token("Testa", "TESTA", 18) {
    
    constructor() public {
        mint(owner, 7777777 * 10 ** decimals);
    }
    
}

contract JTestaToken is ERC20Token("jTesta", "jTESTA", 18) {
    
    constructor() public {
        mint(owner, 7777777 * 10 ** decimals);
    }
    
}