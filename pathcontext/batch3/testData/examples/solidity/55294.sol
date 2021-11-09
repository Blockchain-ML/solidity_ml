pragma solidity ^0.4.23;

 

 
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

 

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

contract BulkableToken is Ownable, ERC20Basic {

    struct BulkArray {
        address[] addressList;
        uint[] amountList;
    }

     
    BulkArray bulkAddressList;

     
    function bulkTransfer(address[] _addressList, uint256[] _amountList ) public onlyOwner returns (bool) {
        bulkAddressList.addressList = _addressList;
        bulkAddressList.amountList = _amountList;
        for (uint i = 0; i <= bulkAddressList.addressList.length; i++)
        super.transfer(bulkAddressList.addressList[i], bulkAddressList.amountList[i]);

        return true;
    }
}

 

 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

   
  modifier whenPaused() {
    require(paused);
    _;
  }

   
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

 

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
     
     
     
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
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

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

 

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

 

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


   
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
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

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
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

   
  function increaseApproval(
    address _spender,
    uint _addedValue
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
    uint _subtractedValue
  )
    public
    returns (bool)
  {
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

 

 
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

   
  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

 

 
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

   
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
     
     

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

 

 
contract StandardBurnableToken is BurnableToken, StandardToken {

   
  function burnFrom(address _from, uint256 _value) public {
    require(_value <= allowed[_from][msg.sender]);
     
     
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _burn(_from, _value);
  }
}

 

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract Foundation is MintableToken, StandardBurnableToken, Pausable {

     
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    mapping (address => bool) public lockExemptionList;


    event MintResumed();


    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply_ = initialSupply.mul(10 ** uint256(decimals));
        balances[msg.sender] = totalSupply_;
        name = tokenName;
        symbol = tokenSymbol;

        paused = true;
    }

     
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(paused == false || msg.sender == owner || lockExemptionList[msg.sender] == true);
        _transfer(msg.sender, _to, _value);
    }

     
    function _transfer(address _from, address _to, uint _value) internal {
         
        require(_to != 0x0);
         
        require(balances[_from] >= _value);
         
        require(balances[_to].add(_value) > balances[_to]);
         
        uint previousBalances = balances[_from].add(balances[_to]);
         
        balances[_from] = balances[_from].sub(_value);
         
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
         
        assert(balances[_from].add(balances[_to]) == previousBalances);
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(paused == false || msg.sender == owner);
        return super.transferFrom(_from, _to, _value);
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

     
    function resumeMinting() onlyOwner public returns (bool) {
        mintingFinished = false;
        emit MintResumed();
        return true;
    }


     
    function addExemptionAddress(address addr) public onlyOwner {
        lockExemptionList[addr] = true;
    }

    function removeExemptionAddress(address addr) public onlyOwner {
        lockExemptionList[addr] = false;
    }

    
}

 

contract AitheonToken is Foundation {

    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public Foundation(initialSupply, tokenName, tokenSymbol) {}

    address public ethHoldAddress = 0xf17f52151EbEF6C7334FAD080c5704D77216b732;

    uint256 public saleStart = 0;
    uint256 public saleEnd = 0;
    
    uint ethPrice = 87500;
    uint aicPrice = 245;

    function setEthPrice(uint _value) public onlyOwner {
        ethPrice = _value;
    }

    function setAicPrice(uint _value) public onlyOwner {
        aicPrice = _value;
    }

    function setPrices(uint _eth, uint _aic) public onlyOwner {
        ethPrice = _eth;
        aicPrice = _aic;
    }

    function setSalePeriod(uint256 start, uint256 end) public onlyOwner {
         
        saleStart = start;
        saleEnd = end;
    }

    function() 
        external 
        payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address _user) public payable {
         
         
         
        uint256 amtEth = msg.value;
        if (now >= saleStart && now <= saleEnd) {
            uint256 tokenValue = aicPrice.mul(10 ** (18+2-3)).div(ethPrice);
            uint256 amtTokens = amtEth.div(tokenValue).mul(10 ** uint256(decimals));
            uint256 totalAmt = balances[_user].add(amtTokens);
            if (totalAmt < totalSupply_) {
                _transfer(owner, _user, amtTokens);
                ethHoldAddress.transfer(msg.value);
            }
        }
        else {
            msg.sender.transfer(msg.value);
        }
    }
}