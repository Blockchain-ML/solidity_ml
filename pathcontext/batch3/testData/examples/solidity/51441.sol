pragma solidity ^0.4.24;
 
 

contract ERC20 {
    function totalSupply() public constant returns (uint supply);
    function balanceOf( address who ) public constant returns (uint value);
    function allowance( address owner, address spender ) public constant returns (uint _allowance);

    function transfer( address to, uint value) public returns (bool ok);
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value ) public returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
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
contract  SwapToken{
    using SafeMath for uint;
    ERC20 public oldToken;
    ERC20 public newToken;
    address public tokenOwner;

    address public owner;
    bool public swap_able;
    event Swap(address sender, uint amount);
    event SwapAble(bool swapable);

    modifier isOwner() {
         
        require (msg.sender == owner);
        _;
    }

     
    modifier isSwap() {
        require (swap_able);
        _;
    }

     
    constructor()
    public
    {
        owner = msg.sender;
        swap_able = false;
    }

     
    function setupToken(address _oldToken, address _newToken, address _tokenOwner)
    public
    isOwner
    {
        require(_oldToken != 0 && _newToken != 0 && _tokenOwner != 0);
        oldToken = ERC20(_oldToken);
        newToken = ERC20(_newToken);
        tokenOwner = _tokenOwner;
    }

     
    function swapAble(bool _swap_able)
    public
    isOwner
    {
        swap_able = _swap_able;
        emit SwapAble(_swap_able);
    }

     
    function withdrawOldToken(address to, uint amount)
    public
    isOwner
    returns (bool success)
    {
        require(oldToken.transfer(to, amount));
        return true;
    }

    function swapAbleToken()
    public
    constant
    returns (uint256)
    {
        return newToken.allowance(tokenOwner, this);
    }

    function swapToken(uint amount)
    public
    isSwap
    returns (bool success)
    {
         
        require(newToken.allowance(tokenOwner, this) >= amount);
         
        require(oldToken.transferFrom(msg.sender, this, amount));
         
        require(newToken.transferFrom(tokenOwner, msg.sender, amount));
        emit Swap(msg.sender, amount);
        return true;
    }

     
    function () public payable {
        revert();
    }
}