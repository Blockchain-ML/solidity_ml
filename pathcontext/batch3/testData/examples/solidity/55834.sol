pragma solidity ^0.4.24;


 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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


 
contract TokenVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(uint256 amount);
  event Revoked();

   
  address public beneficiary;
  uint256 public start;
  uint256 public listed_exchange;
  uint256 public first_release_rate;
  uint256 public duration;
  uint256 public duration_rate;
  uint256 public next_release_time = 0;
  uint256 public duration_count = 0;
  bool public revocable;


  mapping (address => uint256) public released;
  mapping (address => bool) public revoked;

  constructor(
    address _beneficiary,
    uint256 _start,
    uint256 _listed_exchange,
    uint256 _first_release_rate,
    uint256 _duration,
    uint256 _duration_rate,
    bool _revocable
  )
    public
  {
    require(_beneficiary != address(0));
     
    start = _start;
    beneficiary = _beneficiary;
    revocable = _revocable;
    listed_exchange = _listed_exchange;
    first_release_rate = _first_release_rate;
    duration = _duration * 1 minutes; 
    duration_rate = _duration_rate;
  }

   
  function release(ERC20Basic token) public {
    uint256 unreleased = releasableAmount(token);

    require(unreleased > 0);

    released[token] = released[token].add(unreleased);

    token.safeTransfer(beneficiary, unreleased);

    duration_count = duration_count.add(1);

    emit Released(unreleased);
  }

   
  function revoke(ERC20Basic token) public onlyOwner {
    require(revocable);
    require(!revoked[token]);

    uint256 balance = token.balanceOf(this);

    uint256 unreleased = releasableAmount(token);
    uint256 refund = balance.sub(unreleased);

    revoked[token] = true;

    token.safeTransfer(owner, refund);

    emit Revoked();
  }

   
  function releasableAmount(ERC20Basic token) public view  returns (uint256) {
    return vestedAmount(token).sub(released[token]);
  }

   
  function vestedAmount(ERC20Basic token) public view returns (uint256) {
    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released[token]);
    uint256 _now = now;

    if(duration_count == 0){
       
      require(_now > start);
       
      return (totalBalance.mul(first_release_rate)).div(100);
    }else  {
      uint256 released_token = (totalBalance.mul(first_release_rate)).div(100);
      uint256 ready_release_token = (totalBalance.mul(duration_count.mul(duration_rate))).div(100);
      return  released_token.add(ready_release_token);
    }
  }
}