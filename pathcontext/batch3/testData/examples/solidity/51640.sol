pragma solidity ^0.4.24;

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

contract ERC820Registry {
    function getManager(address addr) public view returns(address);
    function setManager(address addr, address newManager) public;
    function getInterfaceImplementer(address addr, bytes32 iHash) public constant returns (address);
    function setInterfaceImplementer(address addr, bytes32 iHash, address implementer) public;
}

contract ERC820Implementer {
    ERC820Registry erc820Registry = ERC820Registry(0x991a1bcb077599290d7305493c9A630c20f8b798);

    function setInterfaceImplementation(string ifaceLabel, address impl) internal {
        bytes32 ifaceHash = keccak256(abi.encodePacked(ifaceLabel));
        erc820Registry.setInterfaceImplementer(this, ifaceHash, impl);
    }

    function interfaceAddr(address addr, string ifaceLabel) internal constant returns(address) {
        bytes32 ifaceHash = keccak256(abi.encodePacked(ifaceLabel));
        return erc820Registry.getInterfaceImplementer(addr, ifaceHash);
    }

    function delegateManagement(address newManager) internal {
        erc820Registry.setManager(this, newManager);
    }
}

contract ERC20Token {
    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256);
    function balanceOf(address owner) public view returns (uint256);
    function transfer(address to, uint256 amount) public returns (bool);
    function transferFrom(address from, address to, uint256 amount) public returns (bool);
    function approve(address spender, uint256 amount) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);

     
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

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

contract ERC777Token {
    function name() public view returns (string);
    function symbol() public view returns (string);
    function totalSupply() public view returns (uint256);
    function granularity() public view returns (uint256);
    function balanceOf(address owner) public view returns (uint256);

    function send(address to, uint256 amount, bytes userData) public;

    function authorizeOperator(address operator) public;
    function revokeOperator(address operator) public;
    function isOperatorFor(address operator, address tokenHolder) public view returns (bool);
    function operatorSend(address from, address to, uint256 amount, bytes userData, bytes operatorData) public;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes userData,
        bytes operatorData
    );  
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes operatorData);
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes userData, bytes operatorData);
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

contract ERC777TokensSender {
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint amount,
        bytes userData,
        bytes operatorData
    ) public;
}

contract ERC777TokensRecipient {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint amount,
        bytes userData,
        bytes operatorData
    ) public;
}

contract TokenRecoverable is Ownable {
    using SafeERC20 for ERC20Basic;

    function recoverTokens(ERC20Basic token, address to, uint256 amount) public onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount);
        token.safeTransfer(to, amount);
    }
}

contract OrcaToken is TokenRecoverable, ERC20Token, ERC777Token, ERC820Implementer {
    using SafeMath for uint256;

    enum State { Minting, Trading, Burning }

    string private constant name_ = "ORCA Token";
    string private constant symbol_ = "ORCA";

    uint256 private constant granularity_ = 1;
    uint256 private totalSupply_;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => bool)) private authorized;
    mapping(address => mapping(address => uint256)) private allowed;

    State public state = State.Minting;
    bool private erc20compatible = true;
    bool public throwOnIncompatibleContract = true;

    event MintFinished();

     
    constructor() public {
        setInterfaceImplementation("ERC20Token", address(this));
        setInterfaceImplementation("ERC777Token", address(this));
    }

    modifier canMint() {
        require(state == State.Minting, "Not in &#39;Minting&#39; state!");
      _;
    }

    modifier canTrade() {
        require(state == State.Trading || state == State.Burning, "Not in &#39;Trading&#39; or &#39;Burning&#39; state!");
        _;
    }

    modifier canBurn() {
        require(state == State.Burning, "Not in &#39;Burning&#39; state!");
        _;
    }

     
     
     
    function name() public view returns (string) { return name_; }

     
    function symbol() public view returns(string) { return symbol_; }

     
    function granularity() public view returns(uint256) { return granularity_; }

     
    function totalSupply() public view returns(uint256) { return totalSupply_; }

     
     
     
    function balanceOf(address _tokenHolder) public view returns (uint256) { return balances[_tokenHolder]; }

     
     
     
    function send(address _to, uint256 _amount, bytes _userData) public {
        doSend(msg.sender, _to, _amount, _userData, msg.sender, "", true);
    }

     
     
    function authorizeOperator(address _operator) public {
        require(_operator != msg.sender);
        authorized[_operator][msg.sender] = true;
        emit AuthorizedOperator(_operator, msg.sender);
    }

     
     
    function revokeOperator(address _operator) public {
        require(_operator != msg.sender);
        authorized[_operator][msg.sender] = false;
        emit RevokedOperator(_operator, msg.sender);
    }

     
     
     
     
    function isOperatorFor(address _operator, address _tokenHolder) public view returns (bool) {
        return _operator == _tokenHolder || authorized[_operator][_tokenHolder];
    }

     
     
     
     
     
     
    function operatorSend(address _from, address _to, uint256 _amount, bytes _userData, bytes _operatorData) public {
        require(isOperatorFor(msg.sender, _from));
        doSend(_from, _to, _amount, _userData, msg.sender, _operatorData, true);
    }

     
     
     
     
     
     
    function mint(address _tokenHolder, uint256 _amount) public onlyOwner canMint {
        requireMultiple(_amount);
        totalSupply_ = totalSupply_.add(_amount);
        balances[_tokenHolder] = balances[_tokenHolder].add(_amount);

        callRecipient(msg.sender, address(0), _tokenHolder, _amount, "", "", true);

        emit Minted(msg.sender, _tokenHolder, _amount, "");
        if (erc20compatible) { emit Transfer(address(0), _tokenHolder, _amount); }
    }

     
     
     
    function burn(uint256 _amount, bytes _userData, bytes _operatorData) public canBurn {
        requireMultiple(_amount);

        callSender(msg.sender, msg.sender, address(0), _amount, _userData, _operatorData);

        require(balances[msg.sender] >= _amount);

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        totalSupply_ = totalSupply_.sub(_amount);

        emit Burned(msg.sender, msg.sender, _amount, _userData, _operatorData);
        if (erc20compatible) { emit Transfer(msg.sender, address(0), _amount); }
    }

     
     
     
     
     
    modifier erc20 () {
        require(erc20compatible);
        _;
    }

     
     
    function disableERC20() public onlyOwner {
        erc20compatible = false;
        setInterfaceImplementation("ERC20Token", address(0));
    }

     
     
    function enableERC20() public onlyOwner {
        erc20compatible = true;
        setInterfaceImplementation("ERC20Token", address(this));
    }

     
     
    function decimals() public erc20 view returns (uint8) { return uint8(18); }

     
     
     
     
    function transfer(address _to, uint256 _amount) public erc20 returns (bool success) {
        doSend(msg.sender, _to, _amount, "", msg.sender, "", false);
        return true;
    }

     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _amount) public erc20 returns (bool success) {
        require(_amount <= allowed[_from][msg.sender]);

         
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        doSend(_from, _to, _amount, "", msg.sender, "", false);
        return true;
    }

     
     
     
     
     
    function approve(address _spender, uint256 _amount) public erc20 returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

     
     
     
     
     
     
    function allowance(address _owner, address _spender) public erc20 view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

     
    function finishMinting() public onlyOwner canMint returns (bool) {
      state = State.Trading;
      emit MintFinished();
      return true;
    }

    function enableBurn(bool enable) public onlyOwner returns (bool) {
        require(state == State.Trading || state == State.Burning);
        state = (enable ? State.Burning : State.Trading);
    }

    function setThrowOnIncompatibleContract(bool _throwOnIncompatibleContract) public onlyOwner {
        throwOnIncompatibleContract = _throwOnIncompatibleContract;
    }

     
     
     
     
    function requireMultiple(uint256 _amount) internal pure {
        require(_amount.div(granularity_).mul(granularity_) == _amount);
    }

     
     
     
    function isRegularAddress(address _addr) internal view returns (bool) {
        if (_addr == 0) { return false; }
        uint size;
        assembly { size := extcodesize(_addr) }  
        return size == 0;
    }

     
     
     
     
     
     
     
     
     
     
    function doSend(
        address _from,
        address _to,
        uint256 _amount,
        bytes _userData,
        address _operator,
        bytes _operatorData,
        bool _preventLocking
    )
        private
        canTrade
    {
        requireMultiple(_amount);

        callSender(_operator, _from, _to, _amount, _userData, _operatorData);

        require(_to != address(0));           
        require(balances[_from] >= _amount);  

        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);

        callRecipient(_operator, _from, _to, _amount, _userData, _operatorData, _preventLocking);

        emit Sent(_operator, _from, _to, _amount, _userData, _operatorData);
        if (erc20compatible) { emit Transfer(_from, _to, _amount); }
    }

     
     
     
     
     
     
     
     
     
     
     
    function callRecipient(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _userData,
        bytes _operatorData,
        bool _preventLocking
    ) private {
        address recipientImplementation = interfaceAddr(_to, "ERC777TokensRecipient");
        if (recipientImplementation != address(0)) {
            ERC777TokensRecipient(recipientImplementation).tokensReceived(
                _operator, _from, _to, _amount, _userData, _operatorData);
        } else if (throwOnIncompatibleContract && _preventLocking) {
            require(isRegularAddress(_to));
        }
    }

     
     
     
     
     
     
     
     
     
     
    function callSender(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _userData,
        bytes _operatorData
    ) private {
        address senderImplementation = interfaceAddr(_from, "ERC777TokensSender");
        if (senderImplementation != address(0)) {
            ERC777TokensSender(senderImplementation).tokensToSend(
                _operator, _from, _to, _amount, _userData, _operatorData);
        }
    }
}