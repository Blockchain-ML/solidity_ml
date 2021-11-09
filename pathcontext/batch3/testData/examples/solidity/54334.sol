pragma solidity ^0.4.24;

 

 
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

 

 
contract CappedToken is MintableToken {

  uint256 public cap;

  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

   
  function mint(
    address _to,
    uint256 _amount
  )
    onlyOwner
    canMint
    public
    returns (bool)
  {
    require(totalSupply_.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}

 

 
contract SHRToken is CappedToken {
    using SafeMath for uint256;
    string public name = "SHAREEVERYTHING TOKEN";
    string public symbol = "SHR";
    uint256 public decimals = 18;
    uint256 public cap = 200000000 ether;
    address public communityPool;

     
     
    constructor() CappedToken(cap) public {
    }

    function setCommunityPool(address _pool) external onlyOwner {
        require(_pool != address(0));
        communityPool = _pool;
    }
}

 

 
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}

 

contract SHROrder is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Basic;

    SHRToken public token;

    struct Order {
        address provider;
        address consumer;
        string recordId;
        string itemId;
        uint256 priceTotal;
        uint256 startTime;
        uint256 endTime;
        int8 tokenAllocated;  
        uint256 allocatedToFundPool;  
        uint256 allocatedToPayable;  
    }

    uint256 public lastOrderIndex = 0;
    Order[] private Orders;

    constructor(SHRToken _tokenContract) public {
         
        token = _tokenContract;
    }

    function totalOrders() public view returns (uint256) {
        return Orders.length;
    }

     
    function newOrder(address provider, address consumer, string recordId, string itemId, uint256 priceTotal, uint256 startTime, uint256 endTime) public returns (uint256) {
         
        Order memory order = Order(provider, consumer, recordId, itemId, priceTotal, startTime, endTime, 0, 0, 0);
        Orders.push(order);
        lastOrderIndex = Orders.length.sub(1);
        bool transfered = token.transferFrom(consumer, address(this), priceTotal);
        if (transfered){
            fundsReceived(lastOrderIndex);
        }
        return lastOrderIndex;
    }

     
    function fundsReceived(uint orderId) private {
        Order storage o = Orders[orderId];
        o.tokenAllocated = 1;
    }

     
    function cancel(uint256 orderId) public returns (bool) {
        Order storage o = Orders[orderId];
        require(checkOrderAndBalance(o, 1) == true);

        token.transfer(o.consumer, o.priceTotal);
        o.tokenAllocated = -1;

        return true;
    }

     
    function release(uint256 orderId) public returns (uint256) {
        Order storage o = Orders[orderId];
        require(checkOrderAndBalance(o, 1) == true);
        require(token.communityPool() != address(0));

        uint256 amountFund = o.priceTotal.mul(1).div(100);
        token.transfer(token.communityPool(), amountFund);
        o.allocatedToFundPool = amountFund;
        o.tokenAllocated = 2;

        return amountFund;
    }

    function payout(uint256 orderId) public returns (uint256) {
        Order storage o = Orders[orderId];
        uint256 amountPayable = o.priceTotal.sub(o.allocatedToFundPool);
        require(token.balanceOf(address(this)) >= amountPayable);

        token.transfer(o.provider, amountPayable);
        o.allocatedToPayable = amountPayable;
        o.tokenAllocated = 3;

        return amountPayable;
    }

    function checkOrderAndBalance(Order order, int8 tokenAllocationStatus) private view returns (bool) {
        require(order.tokenAllocated == tokenAllocationStatus);
        uint256 availableTokens = token.balanceOf(address(this));
        require (availableTokens >= order.priceTotal);
        return true;
    }

    function getOrderTokenAllocationStatus(uint256 orderId) public view returns (int8) {
        Order memory o = Orders[orderId];
        return o.tokenAllocated;
    }

    function getOrder(uint256 orderId) public view returns (address, address, string, string, uint256, uint256, uint256, int8, uint256, uint256) {
        Order memory o = Orders[orderId];
        return (o.provider, o.consumer, o.recordId, o.itemId, o.priceTotal, o.startTime, o.endTime, o.tokenAllocated, o.allocatedToFundPool, o.allocatedToPayable);
    }

    function getOrderPriceTotal(uint256 orderId) public view returns (uint256) {
        Order memory o = Orders[orderId];
        return o.priceTotal;
    }

    function getOrderAllocatedToFundPool(uint256 orderId) public view returns (uint256) {
        Order memory o = Orders[orderId];
        return o.allocatedToFundPool;
    }
}