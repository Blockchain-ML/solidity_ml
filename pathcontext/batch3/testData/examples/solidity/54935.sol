pragma solidity ^0.4.22;


 
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


 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  constructor() public {
    owner = msg.sender;
    emit OwnershipTransferred(address(0), owner);
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


contract TransferFilter is Ownable {
  bool public isTransferable;
  mapping( address => bool ) public mapAddressPass;
  mapping( address => bool ) public mapAddressBlock;

  event LogFilterPass(address indexed target, bool status);
  event LogFilterBlock(address indexed target, bool status);

   
  modifier checkTokenTransfer(address source) {
      if (isTransferable == true) {
          require(mapAddressBlock[source] == false);
      }
      else {
          require(mapAddressPass[source] == true);
      }
      _;
  }

  constructor() public {
      isTransferable = false;
  }

  function setTransferable(bool status) public onlyOwner {
      isTransferable = status;
  }

  function isInPassFilter(address user) public view returns (bool) {
    return mapAddressPass[user];
  }

  function isInBlockFilter(address user) public view returns (bool) {
    return mapAddressBlock[user];
  }

  function addressToPass(address target, bool status)
  public
  onlyOwner
  {
      bool old = mapAddressPass[target];
      if (old != status) {
        if (status == true) {
          mapAddressPass[target] = true;
          emit LogFilterPass(target, true);
        }
        else {
          delete mapAddressPass[target];
          emit LogFilterPass(target, false);
        }
      }
  }

  function addressToBlock(address target, bool status)
  public
  onlyOwner
  {
      bool old = mapAddressBlock[target];
      if (old != status) {
        if (status == true) {
          mapAddressBlock[target] = true;
          emit LogFilterBlock(target, true);
        }
        else {
          delete mapAddressBlock[target];
          emit LogFilterBlock(target, false);
        }
      }
  }
}

 
contract ERC20 {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
contract StandardToken is ERC20, TransferFilter {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  mapping (address => mapping (address => uint256)) internal allowed;

  modifier onlyPayloadSize(uint size) {
    require(msg.data.length >= size + 4);
    _;
  }

   
  function transfer(address _to, uint256 _value)
  onlyPayloadSize(2 * 32)
  checkTokenTransfer(msg.sender)
  public returns (bool) {
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

   
  function transferFrom(address _from, address _to, uint256 _value)
  onlyPayloadSize(3 * 32)
  checkTokenTransfer(_from)
  public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value)
  onlyPayloadSize(2 * 32)
  checkTokenTransfer(msg.sender)
  public returns (bool) {
     
     
     
     
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
}

contract BurnableToken is StandardToken {
  event Burn(address indexed from, uint256 value);

  function burn(address _from, uint256 _amount) public onlyOwner {
    require(_amount <= balances[_from]);
    totalSupply = totalSupply.sub(_amount);
    balances[_from] = balances[_from].sub(_amount);
    emit Transfer(_from, address(0), _amount);
    emit Burn(_from, _amount);
  }
}

 

contract MintableToken is BurnableToken {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;
  address public minter;

  constructor() public {
    minter = msg.sender;
  }

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasPermission() {
    require(msg.sender == owner || msg.sender == minter);
    _;
  }

  function () public payable {
    require(false);
  }

  function changeMinter(address newMinter) public onlyOwner {
    require(newMinter != address(0));
    minter = newMinter;
  }

   
  function mint(address _to, uint256 _amount) canMint hasPermission public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

   
  function finishMinting() canMint onlyOwner public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}


contract Whitelist is Ownable {
  mapping(address => bool) userInWhitelist;
  bool isWhitelistPassOnly;

  event WhitelistChanged(address indexed user, bool isAdded, bool isRemoved);

  constructor() public {
    isWhitelistPassOnly = false;
  }

  modifier filterWhitelist(address user) {
    if (isWhitelistPassOnly == true) {
      require(userInWhitelist[user] == true);
    }
    _;
  }

  function isWhitelistOnlyStatus() public view returns (bool) {
    return isWhitelistPassOnly;
  }

  function changeWhitelistOnly(bool isPass) public onlyOwner {
    isWhitelistPassOnly = isPass;
  }

  function isInWhitelist(address user) public view returns (bool) {
    return userInWhitelist[user];
  }

  function addWhitelist(address newUser) public onlyOwner {
    require(newUser != address(0));
    if (userInWhitelist[newUser] == false) {
      userInWhitelist[newUser] = true;
      emit WhitelistChanged(newUser, true, false);
    }
  }

  function removeWhitelist(address oldUser) public onlyOwner {
    if (userInWhitelist[oldUser] == true) {
      delete userInWhitelist[oldUser];
      emit WhitelistChanged(oldUser, false, true);
    }
  }
}


contract Crowdsale is Whitelist {
  using SafeMath for uint256;

  bool public isStop = false;
  bool public isSoldOut = false;
  uint256 public timeBegin = 0;

   
  MintableToken public token;

   
  uint256 public rate;

   
  uint256 public minBuyEthAmount = 0.01 ether;
  uint256 public maxBuyEthAmount = 30 ether;


  event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);

  constructor(address _token) public {
    require(_token != address(0));

    token = MintableToken(_token);
  }

  modifier filterNotStop() {
    require(isStop == false);
    _;
  }

   
  function () external payable {
    buyTokens(msg.sender);
  }

 
  function buyTokens(address beneficiary) public payable
    filterNotStop
    filterWhitelist(beneficiary)
  {
    require(msg.value >= minBuyEthAmount);
    require(msg.value <= maxBuyEthAmount);
    require(rate > 0);
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

     
    uint256 tokens = getTokenAmount(weiAmount);
    uint256 remains = token.balanceOf(address(this));
    uint256 transferTokens = tokens;
    if(tokens > remains) {
        transferTokens = remains;
    }

     
    token.transfer(beneficiary, transferTokens);
    emit TokenPurchase(beneficiary, weiAmount, transferTokens);

     
    if(tokens >= remains) {
        uint256 ethCost = transferTokens.div(rate);
        uint256 toReturn = msg.value.sub(ethCost);
        if(toReturn > 0) {
            msg.sender.transfer(toReturn);
        }
        isStop = true;
        isSoldOut = true;
    }
  }


  function reclaimToken(address takeWallet) public onlyOwner {
    uint256 remains = token.balanceOf(address(this));
    if (remains > 0) {
      token.transfer(takeWallet, remains);
    }
    timeBegin = 0;
    isStop = true;
  }

  function takeAllEther(address takeWallet) public onlyOwner {
      require(takeWallet != address(0));
      takeWallet.transfer(address(this).balance);
  }

  function setStopStatus(bool wantStop) onlyOwner public {
    isStop = wantStop;
  }

  function setTimeBegin(uint256 newTimestamp) public onlyOwner {
    timeBegin = newTimestamp;
  }

  function setBuyRate(uint256 newRate) onlyOwner public returns (bool) {
    require(newRate > 0);
    rate = newRate;
    return true;
  }

  function setBuyMaxLimit(uint256 maxBuyEther) onlyOwner public returns (bool) {
    require(maxBuyEther > 0);
    maxBuyEthAmount = maxBuyEther;
    return true;
  }

  function setBuyMinLimit(uint256 minBuyEther) onlyOwner public returns (bool) {
    require(minBuyEther > 0);
    minBuyEthAmount = minBuyEther;
    return true;
  }


   
  function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
       
      if (weiAmount > maxBuyEthAmount) {
          return maxBuyEthAmount.mul(rate);
      } else {
          return weiAmount.mul(rate);
      }
  }

   
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = false;
    if (timeBegin > 0 && timeBegin < now) {
      withinPeriod = true;
    }
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }
}


contract SimpleCrowdsale is Crowdsale {
  constructor(address _token) public
    Crowdsale(_token)
  {
  }
}