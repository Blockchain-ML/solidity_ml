pragma solidity 0.4.21;

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


contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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


 
 
contract Basket is StandardToken {
  using SafeMath for uint;

   
  string                  public name;
  string                  public symbol;
  uint                    public decimals;
  address[]               public tokens;
  uint[]                  public weights;

  address                 public arranger;
  address                 public arrangerFeeRecipient;
  uint                    public arrangerFee;

   
   
  mapping(address => mapping(address => uint)) public outstandingBalance;

   
  IBasketRegistry         public basketRegistry;

   
  modifier onlyArranger {
    require(msg.sender == arranger);                 
    _;
  }

   
  event LogDepositAndBundle(address indexed holder, uint indexed quantity);
  event LogDebundleAndWithdraw(address indexed holder, uint indexed quantity);
  event LogPartialDebundle(address indexed holder, uint indexed quantity);
  event LogWithdraw(address indexed holder, address indexed token, uint indexed quantity);
  event LogArrangerFeeRecipientChange(address indexed oldRecipient, address indexed newRecipient);
  event LogArrangerFeeChange(uint indexed oldFee, uint indexed newFee);

   
   
   
   
   
   
   
   
   
  function Basket(
    string    _name,
    string    _symbol,
    address[] _tokens,
    uint[]    _weights,
    address   _basketRegistryAddress,
    address   _arranger,
    address   _arrangerFeeRecipient,
    uint      _arrangerFee                          
  ) public {
     
    require(_tokens.length > 0 && _tokens.length == _weights.length);

    name = _name;
    symbol = _symbol;
    tokens = _tokens;
    weights = _weights;

    basketRegistry = IBasketRegistry(_basketRegistryAddress);

    arranger = _arranger;
    arrangerFeeRecipient = _arrangerFeeRecipient;
    arrangerFee = _arrangerFee;

    decimals = 18;
  }

   
   
   
  function depositAndBundle(uint _quantity) public payable returns (bool success) {
    for (uint i = 0; i < tokens.length; i++) {
      address t = tokens[i];
      uint w = weights[i];
      assert(ERC20(t).transferFrom(msg.sender, this, w.mul(_quantity).div(10 ** decimals)));
    }

     
     
    if (arrangerFee > 0) {
       
      require(msg.value >= arrangerFee.mul(_quantity).div(10 ** decimals));
      arrangerFeeRecipient.transfer(msg.value);
    } else {
       
      require(msg.value == 0);
    }

    balances[msg.sender] = balances[msg.sender].add(_quantity);
    totalSupply_ = totalSupply_.add(_quantity);

    basketRegistry.incrementBasketsMinted(_quantity, msg.sender);
    emit LogDepositAndBundle(msg.sender, _quantity);
    return true;
  }

   
   
   
  function debundleAndWithdraw(uint _quantity) public returns (bool success) {
    assert(debundle(_quantity, msg.sender, msg.sender));
    emit LogDebundleAndWithdraw(msg.sender, _quantity);
    return true;
  }

   
   
   
   
   
  function debundle(
    uint      _quantity,
    address   _sender,
    address   _recipient
  ) internal returns (bool success) {
    require(balances[_sender] >= _quantity);       
     
    balances[_sender] = balances[_sender].sub(_quantity);
    totalSupply_ = totalSupply_.sub(_quantity);

     
    for (uint i = 0; i < tokens.length; i++) {
      address t = tokens[i];
      uint w = weights[i];
      ERC20(t).transfer(_recipient, w.mul(_quantity).div(10 ** decimals));
    }

    basketRegistry.incrementBasketsBurned(_quantity, _sender);
    return true;
  }

   
   
   
  function burn(uint _quantity) public returns (bool success) {
    balances[msg.sender] = balances[msg.sender].sub(_quantity);
    totalSupply_ = totalSupply_.sub(_quantity);

     
    for (uint i = 0; i < tokens.length; i++) {
      address t = tokens[i];
      uint w = weights[i];
      outstandingBalance[msg.sender][t] = outstandingBalance[msg.sender][t].add(w.mul(_quantity).div(10 ** decimals));
    }

    basketRegistry.incrementBasketsBurned(_quantity, msg.sender);
    return true;
  }

   
   
   
  function withdraw(address _token) public returns (bool success) {
    uint bal = outstandingBalance[msg.sender][_token];
    require(bal > 0);
    outstandingBalance[msg.sender][_token] = 0;
    assert(ERC20(_token).transfer(msg.sender, bal));

    emit LogWithdraw(msg.sender, _token, bal);
    return true;
  }

   
   
   
  function changeArrangerFeeRecipient(address _newRecipient) public onlyArranger returns (bool success) {
     
    require(_newRecipient != address(0) && _newRecipient != arrangerFeeRecipient);
    address oldRecipient = arrangerFeeRecipient;
    arrangerFeeRecipient = _newRecipient;

    emit LogArrangerFeeRecipientChange(oldRecipient, arrangerFeeRecipient);
    return true;
  }

   
   
   
  function changeArrangerFee(uint _newFee) public onlyArranger returns (bool success) {
    uint oldFee = arrangerFee;
    arrangerFee = _newFee;

    emit LogArrangerFeeChange(oldFee, arrangerFee);
    return true;
  }

   
   
  function () public payable { revert(); }
}


contract IBasketRegistry {
   
  function registerBasket(address, address, string, string, address[], uint[]) public returns (uint) {}
  function checkBasketExists (address) public returns (bool) {}
  function getBasketArranger (address) public returns (address) {}

   
  function incrementBasketsMinted (uint, address) public returns (bool) {}
  function incrementBasketsBurned (uint, address) public returns (bool) {}
}

contract BasketRegistry {
  using SafeMath for uint;

   
  address                           public admin;
  mapping(address => bool)          public basketFactoryMap;

  uint                              public basketIndex;            
  address[]                         public basketList;
  mapping(address => BasketStruct)  public basketMap;
  mapping(address => uint)          public basketIndexFromAddress;

  uint                              public arrangerIndex;          
  address[]                         public arrangerList;
  mapping(address => uint)          public arrangerBasketCount;
  mapping(address => uint)          public arrangerIndexFromAddress;

   
  struct BasketStruct {
    address   basketAddress;
    address   arranger;
    string    name;
    string    symbol;
    address[] tokens;
    uint[]    weights;
    uint      totalMinted;
    uint      totalBurned;
  }

   
  modifier onlyBasket {
    require(basketIndexFromAddress[msg.sender] > 0);  
    _;
  }
  modifier onlyBasketFactory {
    require(basketFactoryMap[msg.sender] == true);    
    _;
  }

   
  event LogWhitelistBasketFactory(address basketFactory);
  event LogBasketRegistration(address basketAddress, uint basketIndex);
  event LogIncrementBasketsMinted(address basketAddress, uint quantity, address sender);
  event LogIncrementBasketsBurned(address basketAddress, uint quantity, address sender);

   
  function BasketRegistry() public {
    basketIndex = 1;
    arrangerIndex = 1;
    admin = msg.sender;
  }

   
   
   
  function whitelistBasketFactory(address _basketFactory) public returns (bool success) {
    require(msg.sender == admin);                   
    basketFactoryMap[_basketFactory] = true;
    emit LogWhitelistBasketFactory(_basketFactory);
    return true;
  }

   
   
   
   
   
   
   
   
  function registerBasket(
    address   _basketAddress,
    address   _arranger,
    string    _name,
    string    _symbol,
    address[] _tokens,
    uint[]    _weights
  )
    public
    onlyBasketFactory
    returns (uint index)
  {
    basketMap[_basketAddress] = BasketStruct(
      _basketAddress, _arranger, _name, _symbol, _tokens, _weights, 0, 0
    );
    basketList.push(_basketAddress);
    basketIndexFromAddress[_basketAddress] = basketIndex;

    if (arrangerBasketCount[_arranger] == 0) {
      arrangerList.push(_arranger);
      arrangerIndexFromAddress[_arranger] = arrangerIndex;
      arrangerIndex = arrangerIndex.add(1);
    }
    arrangerBasketCount[_arranger] = arrangerBasketCount[_arranger].add(1);

    emit LogBasketRegistration(_basketAddress, basketIndex);
    basketIndex = basketIndex.add(1);
    return basketIndex.sub(1);
  }

   
   
   
  function checkBasketExists(address _basketAddress) public view returns (bool basketExists) {
    return basketIndexFromAddress[_basketAddress] > 0;
  }

   
   
   
  function getBasketDetails(address _basketAddress)
    public
    view
    returns (
      address   basketAddress,
      address   arranger,
      string    name,
      string    symbol,
      address[] tokens,
      uint[]    weights,
      uint      totalMinted,
      uint      totalBurned
    )
  {
    BasketStruct memory b = basketMap[_basketAddress];
    return (b.basketAddress, b.arranger, b.name, b.symbol, b.tokens, b.weights, b.totalMinted, b.totalBurned);
  }

   
   
   
  function getBasketArranger(address _basketAddress) public view returns (address) {
    return basketMap[_basketAddress].arranger;
  }

   
   
   
   
  function incrementBasketsMinted(uint _quantity, address _sender) public onlyBasket returns (bool) {
    basketMap[msg.sender].totalMinted = basketMap[msg.sender].totalMinted.add(_quantity);
    emit LogIncrementBasketsMinted(msg.sender, _quantity, _sender);
    return true;
  }

   
   
   
   
  function incrementBasketsBurned(uint _quantity, address _sender) public onlyBasket returns (bool) {
    basketMap[msg.sender].totalBurned = basketMap[msg.sender].totalBurned.add(_quantity);
    emit LogIncrementBasketsBurned(msg.sender, _quantity, _sender);
    return true;
  }

   
   
  function () public payable { revert(); }
}


 
contract BasketFactory {
  using SafeMath for uint;

  address                       public admin;
  address                       public basketRegistryAddress;

  address                       public productionFeeRecipient;
  uint                          public productionFee;

   
  IBasketRegistry               public basketRegistry;

   
  modifier onlyAdmin {
    require(msg.sender == admin);                    
    _;
  }

   
  event LogBasketCreated(uint indexed basketIndex, address indexed basketAddress, address indexed arranger);
  event LogProductionFeeRecipientChange(address indexed oldRecipient, address indexed newRecipient);
  event LogProductionFeeChange(uint indexed oldFee, uint indexed newFee);

   
   
  function BasketFactory(
    address   _basketRegistryAddress,
    address   _productionFeeRecipient,
    uint      _productionFee
  ) public {
    admin = msg.sender;

    basketRegistryAddress = _basketRegistryAddress;
    basketRegistry = IBasketRegistry(_basketRegistryAddress);

    productionFeeRecipient = _productionFeeRecipient;
    productionFee = _productionFee;
  }

   
   
   
   
   
   
   
   
  function createBasket(
    string    _name,
    string    _symbol,
    address[] _tokens,
    uint[]    _weights,
    address   _arrangerFeeRecipient,
    uint      _arrangerFee
  )
    public
    payable
    returns (address newBasket)
  {
     
    require(msg.value >= productionFee);            
    productionFeeRecipient.transfer(msg.value);

    Basket b = new Basket(
      _name,
      _symbol,
      _tokens,
      _weights,
      basketRegistryAddress,
      msg.sender,                                   
      _arrangerFeeRecipient,
      _arrangerFee
    );

    emit LogBasketCreated(
      basketRegistry.registerBasket(b, msg.sender, _name, _symbol, _tokens, _weights),
      b,
      msg.sender
    );
    return b;
  }

   
   
   
  function changeProductionFeeRecipient(address _newRecipient) public onlyAdmin returns (bool success) {
    address oldRecipient = productionFeeRecipient;
    productionFeeRecipient = _newRecipient;

    emit LogProductionFeeRecipientChange(oldRecipient, productionFeeRecipient);
    return true;
  }

   
   
   
  function changeProductionFee(uint _newFee) public onlyAdmin returns (bool success) {
    uint oldFee = productionFee;
    productionFee = _newFee;

    emit LogProductionFeeChange(oldFee, productionFee);
    return true;
  }

   
   
  function () public payable { revert(); }
}