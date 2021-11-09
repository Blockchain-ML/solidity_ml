pragma solidity ^0.4.24;
 
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
 
contract ERC20 {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract TOTToken is ERC20, Pausable {

  using SafeMath for uint256;

  string public name = "Trecento";       
  string public symbol = "TOT";            
  uint256 public decimals = 18;             




  uint256 private totalSupply_;
  bool public mintingFinished = false;

  uint256 public cap = 20000000 * 10 ** decimals;  

  mapping(address => uint256) private balances;

  mapping (address => mapping (address => uint256)) private allowed;



  event Burn(address indexed burner, uint256 value);
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  modifier canMint() {
    require(!mintingFinished);
    _;
  }



   
  function setName(string _name)  public onlyOwner {
    name = _name;
  }

   
  function setSymbol(string _symbol)  public onlyOwner {
    symbol = _symbol;
  }


   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

   
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool success) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function mint(address _to, uint256 _amount)  public onlyOwner canMint returns (bool) {
    require(_amount > 0);
    require(totalSupply_.add(_amount) <= cap);
    require(_to != address(0));
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

   
function finishMinting()  public onlyOwner canMint returns (bool) {
  mintingFinished = true;
  emit MintFinished();
  return true;
}




   
  function burn(uint256 _value) public whenNotPaused {
    require(_value <= balances[msg.sender]);
     
     

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(burner, _value);
    emit Transfer(burner, address(0), _value);
  }


}
contract Distribute is Ownable{

  using SafeMath for uint256;
   
  uint256 public constant SHARE_PURCHASERS = 75;
  uint256 public constant SHARE_FOUNDATION = 5;
  uint256 public constant SHARE_TEAM = 15;
  uint256 public constant SHARE_BOUNTY = 5;
  TOTToken public token;

   
  address public foundationAddress;
  address public teamAddress;
  address public bountyAddress;

   
  uint256 public releasedTokens;
  uint256 public tokensTorelease;
  uint256 public startVesting;
  uint256 public period1;
	uint256 public period2;
	uint256 public period3;
  uint256 public period4;
  bool public distributed_round1 = false;
  bool public distributed_round2 = false;
  bool public distributed_round3 = false;
  bool public distributed_round4 = false;

  constructor(address _token, address _foundationAddress, address _teamAddress, address _bountyAddress) public {
    require(_token != address(0) && _foundationAddress != address(0) && _teamAddress != address(0) && _bountyAddress != address(0));
    token = TOTToken(_token);
    foundationAddress = _foundationAddress;
    teamAddress = _teamAddress;
    bountyAddress = _bountyAddress;
  }

  function updateWallets(address _foundation, address _team, address _bounty) public onlyOwner {
    require(!token.mintingFinished());
    require(_foundation != address(0) && _team != address(0) && _bounty != address(0));
    foundationAddress = _foundation;
    teamAddress = _team;
    bountyAddress = _bounty;
  }

   
  function finishMinting() public onlyOwner returns (bool) {

     
    uint256 total = token.totalSupply().mul(100).div(SHARE_PURCHASERS);  

    uint256 foundationTokens = total.mul(SHARE_FOUNDATION).div(100);
    uint256 teamTokens = total.mul(SHARE_TEAM).div(100);
    uint256 bountyTokens = total.mul(SHARE_BOUNTY).div(100);
    require (token.balanceOf(foundationAddress) == 0 && token.balanceOf(address(this)) == 0 && token.balanceOf(bountyAddress) == 0);
    token.mint(foundationAddress, foundationTokens);
    token.mint(address(this), teamTokens);
    token.mint(bountyAddress, bountyTokens);
    tokensTorelease = teamTokens.mul(25).div(100);
    token.finishMinting();

    startVesting = now;
    period1 = startVesting.add(24 weeks);
    period2 = startVesting.add(48 weeks);
    period3 = startVesting.add(72 weeks);
    period4 = startVesting.add(96 weeks);
    return true;
  }

   
  function batchMint(address[] _data,uint256[] _amount) public onlyOwner {
    for (uint i = 0; i < _data.length; i++) {
       token.mint(_data[i],_amount[i]);
    }
  }

  function pauseToken() public onlyOwner {
    token.pause();
  }

  function unpauseToken() public onlyOwner {
    token.unpause();
  }

    function TeamtokenRelease1 ()public onlyOwner {
       require(token.mintingFinished() && !distributed_round1);
    	 require (now >= period1);
       token.transfer(teamAddress,tokensTorelease);
    	 releasedTokens=tokensTorelease;
    	 distributed_round1=true;
    	}

    function TeamtokenRelease2 ()public onlyOwner {
       require(distributed_round1 && !distributed_round2);
    	 require (now >= period2);
    	 token.transfer(teamAddress,tokensTorelease);
    	 releasedTokens=releasedTokens.add(tokensTorelease);
    	 distributed_round2=true;
     }

   function TeamtokenRelease3 ()public onlyOwner {
       require(distributed_round2 && !distributed_round3);
    	 require (now >= period3);
    	 token.transfer(teamAddress,tokensTorelease);
    	 releasedTokens = releasedTokens.add(tokensTorelease);
    	 distributed_round3 = true;
     }

     function TeamtokenRelease4 ()public onlyOwner {
      require(distributed_round3 && !distributed_round4);
      require (now >= period4);
      uint256 balance = token.balanceOf(this);
      token.transfer(teamAddress,balance);
      releasedTokens = releasedTokens.add(balance);
      distributed_round4=true;
    }



}