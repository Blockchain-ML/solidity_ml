pragma solidity 0.4.24;

contract Authorized {
    address public owner;
    address public newOwner;
    address public trustedTokensHandler;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        trustedTokensHandler = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier authorizedTokensHandler {
        require(msg.sender == owner || msg.sender == trustedTokensHandler);
        _;
    }

    function transferOwnership(address _newOwner) onlyOwner external {
        require(_newOwner != address(0));
        newOwner = _newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    function setTrustedTokenHandler(address _trustedTokensHandler) onlyOwner external {
        require(_trustedTokensHandler != address(0));
        trustedTokensHandler = _trustedTokensHandler;
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

contract BRIDGE is Authorized {
    using SafeMath for uint256;

    string public constant name = "BRIDGE Token";
    string public constant symbol = "BRIDGE";
    uint8 public constant decimals = 2;
    uint256 public totalSupply = 0;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Burn(address indexed _from, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

     
    function balanceOf(address _owner) external view returns (uint256 balance) {
        return balances[_owner];
    }

     
    function transfer(address _to, uint256 _value) external returns (bool success) {
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

     
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) external returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function allowance(address _owner, address _spender) external view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

     
    function emitTokens(address _target, uint256 _mintedAmount) external authorizedTokensHandler returns (bool success) {
        balances[_target] = balances[_target].add(_mintedAmount);
        totalSupply = totalSupply.add(_mintedAmount);

        emit Transfer(address(0), owner, _mintedAmount);
        emit Transfer(owner, _target, _mintedAmount);
        return true;
    }

     
    function burnTokens(address _from, uint256 _value) external authorizedTokensHandler returns (bool success) {
        require(_from != address(0));

        balances[_from] = balances[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);

        emit Transfer(_from, address(0), _value);
        emit Burn(_from, _value);
        return true;
    }

     
    function moveTokens(address _from, address _to, uint256 _value) external authorizedTokensHandler returns (bool success) {
        require(_from != address(0));
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

	 
    function destruct() external onlyOwner {
        selfdestruct(owner);
    }
}