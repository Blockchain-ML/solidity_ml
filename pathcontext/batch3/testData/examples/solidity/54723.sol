pragma solidity ^0.4.13;

library ECRecovery {

   
  function recover(bytes32 hash, bytes sig)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

     
    if (sig.length != 65) {
      return (address(0));
    }

     
     
     
     
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

     
    if (v < 27) {
      v += 27;
    }

     
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
       
      return ecrecover(hash, v, r, s);
    }
  }

   
  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
     
     
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
    );
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

contract Margin {
    using SafeMath for uint256;

    address public tokenAddress;
    mapping(address => uint256) marginBalances;
    event DepositWithToken(address indexed from, uint256 amount);
    event WithdrawMargin(address indexed from, uint256 amount);

     
    function marginBalanceOf(address _investor) public view returns (uint256) {
        return marginBalances[_investor];
    }

     
    function depositWithToken(
        bytes _signature,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce,
        uint256 _validUntil
    )
        public
        returns (bool)
    {
        require(block.number <= _validUntil);
        BCNTToken tokenContract = BCNTToken(tokenAddress);

        bytes32 hashedTx = ECRecovery.toEthSignedMessageHash(
          tokenContract.transferPreSignedHashing(tokenAddress, address(this), _value, _fee, _nonce, _validUntil)
        );
        address from = ECRecovery.recover(hashedTx, _signature);

        uint256 prevBalance = tokenContract.balanceOf(address(this));
        require(tokenContract.transferPreSigned(_signature, address(this), _value, _fee, _nonce, _validUntil));
        require(tokenContract.transfer(msg.sender, _fee));
        uint256 curBalance = tokenContract.balanceOf(address(this));
        require(curBalance == prevBalance + _value);

        marginBalances[from] = marginBalances[from].add(_value);

        emit DepositWithToken(from, _value);
        return true;
    }

     
    function withdrawMargin(
        uint256 _value
    )
        public
        returns (bool)
    {
        BCNTToken tokenContract = BCNTToken(tokenAddress);

        marginBalances[msg.sender] = marginBalances[msg.sender].sub(_value);
        require(tokenContract.transfer(msg.sender, _value));

        emit WithdrawMargin(msg.sender, _value);
        return true;
    }
}

contract MarginWithPresignedWithdraw is Margin{
    using SafeMath for uint256;

    event WithdrawMarginPreSigned(address indexed from, address indexed delegate, uint256 amount, uint256 fee);

     
    function withdrawMarginPreSigned(
        bytes _signature,
        address _from,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce,
        uint256 _validUntil
    )
        public
        returns (bool)
    {
        require(block.number <= _validUntil);

        bytes32 hashedTx = ECRecovery.toEthSignedMessageHash(withdrawMarginPreSignedHashing(
            address(this),
            _from,
            _value,
            _fee,
            _nonce,
            _validUntil
        ));
        address from = ECRecovery.recover(hashedTx, _signature);
        require(_from == from);

        BCNTToken tokenContract = BCNTToken(tokenAddress);

        marginBalances[_from] = marginBalances[_from].sub(_value).sub(_fee);
        require(tokenContract.transfer(_from, _value));
        require(tokenContract.transfer(msg.sender, _fee));

        emit WithdrawMargin(_from, _value);
        emit WithdrawMarginPreSigned(_from, msg.sender, _value, _fee);
        return true;
    }

     
    function withdrawMarginPreSignedHashing(
        address _investContract,
        address _from,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce,
        uint256 _validUntil
    )
        public
        pure
        returns (bytes32)
    {
         
        return keccak256(
            abi.encodePacked(
                bytes4(0xffffffff),
                _investContract,
                _from,
                _value,
                _fee,
                _nonce,
                _validUntil
            )
        );
    }
}

contract Invest is MarginWithPresignedWithdraw{
    using SafeMath for uint256;

    address public bincentive;
    mapping(address => mapping(bytes32 => address)) traderProfile;
    mapping(bytes => bool) internal registerSignatures;
    mapping(bytes => bool) internal transferSignatures;
    mapping(bytes => bool) internal followTraderSignatures;
    event RegisterTradeProfile(address indexed trader, address indexed profileAddr);
    event CloseTradeProfile(address indexed trader, address indexed profileAddr);
    event FollowTrader(address indexed follower, address indexed trader, uint256 marginAmount);
    event ClearTrade(address indexed follower, address indexed trader, uint256 investedAmount, int256 profitAmount, string causeToClear);

     
     
    struct LocalVariableGrouping {
        bytes32 hashedTx;
        address from;
        BCNTToken tokenContract;
        TradeProfile profile;
    }

     
    function profileOf(address _trader, bytes32 _strategyID) public view returns (address) {
        return traderProfile[_trader][_strategyID];
    }

     
    function registerTradeProfile(
        bytes _registerSignature,
        bytes32 _strategyID,
        uint256 _registerFee,
        uint256 _periodLength,
        uint256 _maxMarginDeposit,
        uint256 _minMarginDeposit,
        uint256 _rewardPercentage,
        uint256 _nonce,
        bytes _transferSignature,
        uint256 _validUntil
    )
        public
        returns (bool)
    {
        require(msg.sender == bincentive);
        require(registerSignatures[_registerSignature] == false);
        require(transferSignatures[_transferSignature] == false);

        LocalVariableGrouping memory localVariables;

        localVariables.hashedTx = ECRecovery.toEthSignedMessageHash(registerPreSignedHashing(
            address(this),
            _strategyID,
            _registerFee,
            _periodLength,
            _maxMarginDeposit,
            _minMarginDeposit,
            _rewardPercentage,
            _nonce
        ));
        localVariables.from = ECRecovery.recover(localVariables.hashedTx, _registerSignature);
        require(traderProfile[localVariables.from][_strategyID] == address(0));

        if(_registerFee > 0) {
            localVariables.tokenContract = BCNTToken(tokenAddress);
        
            localVariables.hashedTx = ECRecovery.toEthSignedMessageHash(
                localVariables.tokenContract.transferPreSignedHashing(tokenAddress, address(this), _registerFee, 0, _nonce, _validUntil)
            );
            require(ECRecovery.recover(localVariables.hashedTx, _transferSignature) == localVariables.from);

            require(localVariables.tokenContract.transferPreSigned(_transferSignature, address(this), _registerFee, 0, _nonce, _validUntil));
        }

        localVariables.profile = new TradeProfile(localVariables.from, _periodLength, _maxMarginDeposit, _minMarginDeposit, _rewardPercentage);
        traderProfile[localVariables.from][_strategyID] = localVariables.profile;
        registerSignatures[_registerSignature] = true;
        transferSignatures[_transferSignature] = true;

        emit RegisterTradeProfile(localVariables.from, localVariables.profile);
        return true;
    }

     
    function registerPreSignedHashing(
        address _investContract,
        bytes32 _strategyID,
        uint256 _registerFee,
        uint256 _periodLength,
        uint256 _maxMarginDeposit,
        uint256 _minMarginDeposit,
        uint256 _rewardPercentage,
        uint256 _nonce
    )
        public
        pure
        returns (bytes32)
    {
         
        return keccak256(
            abi.encodePacked(
                bytes4(0xffffffff),
                _investContract,
                _strategyID,
                _registerFee,
                _periodLength,
                _maxMarginDeposit,
                _minMarginDeposit,
                _rewardPercentage,
                _nonce
            )
        );
    }

     
    function followTrader(
        bytes _signature,
        address _trader,
        bytes32 _strategyID,
        uint256 _marginAmount,
        address _oracle,
        uint256 _validUntil
    )
        public
        returns (bool)
    {
        require(block.number <= _validUntil);
        require(followTraderSignatures[_signature] == false);

        require(traderProfile[_trader][_strategyID] != address(0));
        TradeProfile profile = TradeProfile(traderProfile[_trader][_strategyID]);

        bytes32 hashedTx = ECRecovery.toEthSignedMessageHash(followTraderPreSignedHashing(
            address(this),
            _trader,
            _strategyID,
            _marginAmount,
            _oracle,
            _validUntil
        ));
        address from = ECRecovery.recover(hashedTx, _signature);

        marginBalances[from] = marginBalances[from].sub(_marginAmount);
        require(profile.follow(from, _marginAmount, _oracle));

        followTraderSignatures[_signature] = true;

        emit FollowTrader(from, _trader, _marginAmount);
        return true;
    }

     
    function followTraderPreSignedHashing(
        address _investContract,
        address _trader,
        bytes32 _strategyID,
        uint256 _marginAmount,
        address _oracle,
        uint256 _validUntil
    )
        public
        pure
        returns (bytes32)
    {
         
        return keccak256(
            abi.encodePacked(
                bytes4(0xffffffff),
                _investContract,
                _trader,
                _strategyID,
                _marginAmount,
                _oracle,
                _validUntil
            )
        );
    }

     
    function clearTrade(
        bytes _signature,
        address _trader,
        bytes32 _strategyID,
        address _follower,
        uint256 _investedAmount,
        int256 _profitAmount,
        string _causeToClear
    )
        public
        returns (bool)
    {
        require(traderProfile[_trader][_strategyID] != address(0));
        TradeProfile profile = TradeProfile(traderProfile[_trader][_strategyID]);

        if(msg.sender != bincentive) {
            require(profile.startTimeOf(_follower) + profile.periodLength() <= now);
        }

        bytes32 hashedTx = ECRecovery.toEthSignedMessageHash(clearTradePreSignedHashing(
            address(this),
            _trader,
            _strategyID,
            _follower,
            _investedAmount,
            _profitAmount,
            _causeToClear
        ));
        address from = ECRecovery.recover(hashedTx, _signature);

        uint256 amountToTrader;
        uint256 amountToFollower;
        (amountToTrader, amountToFollower) = profile.clear(_follower, from, _profitAmount);
        marginBalances[_trader] = marginBalances[_trader].add(amountToTrader);
        marginBalances[_follower] = marginBalances[_follower].add(amountToFollower);

        emit ClearTrade(_follower, _trader, _investedAmount, _profitAmount, _causeToClear);
        return true;
    }


     
    function clearTradePreSignedHashing(
        address _investContract,
        address _trader,
        bytes32 _strategyID,
        address _follower,
        uint256 _investedAmount,
        int256 _profitAmount,
        string _causeToClear
    )
        public
        pure
        returns (bytes32)
    {
         
        return keccak256(
            abi.encodePacked(
                bytes4(0xffffffff),
                _investContract,
                _trader,
                _strategyID,
                _follower,
                _investedAmount,
                _profitAmount,
                _causeToClear
            )
        );
    }

     
    function closeTradeProfile(bytes _signature, bytes32 _strategyID) public returns (bool) {
        require(msg.sender == bincentive);

        bytes32 hashedTx = ECRecovery.toEthSignedMessageHash(closePreSignedHashing(
            address(this),
            _strategyID
        ));
        address from = ECRecovery.recover(hashedTx, _signature);
        require(traderProfile[from][_strategyID] != address(0));

        TradeProfile profile = TradeProfile(traderProfile[from][_strategyID]);
        require(profile.close());

        emit CloseTradeProfile(from, profile);
        return true;
    }

     
    function closePreSignedHashing(
        address _investContract,
        bytes32 _strategyID
    )
        public
        pure
        returns (bytes32)
    {
         
        return keccak256(
            abi.encodePacked(bytes4(0xffffffff), _investContract, _strategyID)
        );
    }

    constructor(address _tokenAddress) public {
        bincentive = msg.sender;
        tokenAddress = _tokenAddress;
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

contract StandardToken is ERC20, BasicToken {
    using SafeMath for uint256;

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
        uint256 _addedValue
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
        uint256 _subtractedValue
    )
        public
        returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
        allowed[msg.sender][_spender] = 0;
        } else {
        allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract DepositFromPrivateToken is StandardToken {
   using SafeMath for uint256;

   PrivateToken public privateToken;

   modifier onlyPrivateToken() {
     require(msg.sender == address(privateToken));
     _;
   }

    

   function deposit(address _depositor, uint256 _value) public onlyPrivateToken returns(bool){
     require(_value != 0);
     balances[_depositor] = balances[_depositor].add(_value);
     emit Transfer(privateToken, _depositor, _value);
     return true;
   }
 }

contract BCNTToken is DepositFromPrivateToken{
    using SafeMath for uint256;

    string public constant name = "Bincentive Token";  
    string public constant symbol = "BCNT";  
    uint8 public constant decimals = 18;  
    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));
    mapping(bytes => bool) internal signatures;
    event TransferPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);

     
    function transferPreSigned(
        bytes _signature,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce,
        uint256 _validUntil
    )
        public
        returns (bool)
    {
        require(_to != address(0));
        require(signatures[_signature] == false);
        require(block.number <= _validUntil);

        bytes32 hashedTx = ECRecovery.toEthSignedMessageHash(
          transferPreSignedHashing(address(this), _to, _value, _fee, _nonce, _validUntil)
        );

        address from = ECRecovery.recover(hashedTx, _signature);

        balances[from] = balances[from].sub(_value).sub(_fee);
        balances[_to] = balances[_to].add(_value);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        signatures[_signature] = true;

        emit Transfer(from, _to, _value);
        emit Transfer(from, msg.sender, _fee);
        emit TransferPreSigned(from, _to, msg.sender, _value, _fee);
        return true;
    }

     
    function transferPreSignedHashing(
        address _token,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce,
        uint256 _validUntil
    )
        public
        pure
        returns (bytes32)
    {
         
        return keccak256(
            abi.encodePacked(
                bytes4(0x0a0fb66b),
                _token,
                _to,
                _value,
                _fee,
                _nonce,
                _validUntil
            )
        );
    }

     
    constructor(address _admin) public {
        totalSupply_ = INITIAL_SUPPLY;
        privateToken = new PrivateToken(
          _admin, "Bincentive Private Token", "BCNP", decimals, INITIAL_SUPPLY
       );
    }
}

contract PrivateToken is StandardToken {
    using SafeMath for uint256;

    string public name;  
    string public symbol;  
    uint8 public decimals;  

    address public admin;
    bool public isPublic;
    uint256 public unLockTime;
    DepositFromPrivateToken originToken;

    event StartPublicSale(uint256 unlockTime);
    event Deposit(address indexed from, uint256 value);
     
    function isDepositAllowed() internal view{
       
      require(isPublic);
      require(msg.sender == admin || block.timestamp > unLockTime);
    }

     
    function deposit(address _depositor) public returns (bool){
      isDepositAllowed();
      uint256 _value;
      _value = balances[_depositor];
      require(_value > 0);
      balances[_depositor] = 0;
      require(originToken.deposit(_depositor, _value));
      emit Deposit(_depositor, _value);

       
      emit Transfer(_depositor, address(0), _value);
    }

     
    function startPublicSale(uint256 _unLockTime) public onlyAdmin {
      require(!isPublic);
      isPublic = true;
      unLockTime = _unLockTime;
      emit StartPublicSale(_unLockTime);
    }

     
    function unLock() public onlyAdmin{
      require(isPublic);
      unLockTime = block.timestamp;
    }

    modifier onlyAdmin() {
      require(msg.sender == admin);
      _;
    }

    constructor(address _admin, string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) public{
      originToken = DepositFromPrivateToken(msg.sender);
      admin = _admin;
      name = _name;
      symbol = _symbol;
      decimals = _decimals;
      totalSupply_ = _totalSupply;
      balances[admin] = _totalSupply;
      emit Transfer(address(0), admin, _totalSupply);
    }
}

contract TradeProfile{
    using SafeMath for uint256;

    address public InvestContractAddress;
    address public owner;
    bool public isActive;
    uint256 public periodLength;
    uint256 public maxMarginDeposit;
    uint256 public minMarginDeposit;
    uint256 public rewardPercentage;
    mapping(address => uint256) investBalances;
    mapping(address => uint256) startTime;
    mapping(address => address) oracle;

     
    function investBalanceOf(address _follower) public view returns (uint256) {
        return investBalances[_follower];
    }

     
    function startTimeOf(address _follower) public view returns (uint256) {
        return startTime[_follower];
    }

     
    function oracleOf(address _follower) public view returns (address) {
        return oracle[_follower];
    }

     
    function follow(address _follower, uint256 _amount, address _oracle) public returns (bool) {
        require(isActive);
        require(msg.sender == InvestContractAddress);

        investBalances[_follower] = investBalances[_follower].add(_amount);
        require(minMarginDeposit <= investBalances[_follower] && investBalances[_follower] <= maxMarginDeposit);

        if(startTime[_follower] == 0) {
            startTime[_follower] = now;
            oracle[_follower] = _oracle;
        }
    
        return true;
    }

     
    function clear(
        address _follower,
        address _oracle,
        int256 _profitAmount
    )
        public
        returns (uint256 amountToTrader, uint256 amountToFollower)
    {
        require(msg.sender == InvestContractAddress);
        require(_oracle == oracle[_follower]);

        uint256 balance = investBalances[_follower];

        delete investBalances[_follower];
        delete startTime[_follower];
        delete oracle[_follower];

        if(_profitAmount <= 0) {
            amountToTrader = 0;
        }
        else {
            amountToTrader = uint256(_profitAmount) * rewardPercentage / 100;
            if(amountToTrader > balance) {
                amountToTrader = balance;
            }
        }
        amountToFollower = balance - amountToTrader;
    }

    function close() public returns (bool) {
        require(isActive);
        require(msg.sender == InvestContractAddress);
        isActive = false;
        return true;
    }

    constructor(address _owner, uint256 _periodLength, uint256 _maxMarginDeposit, uint256 _minMarginDeposit, uint256 _rewardPercentage) public {
        InvestContractAddress = msg.sender;
        owner = _owner;
        periodLength = _periodLength;
        maxMarginDeposit = _maxMarginDeposit;
        minMarginDeposit = _minMarginDeposit;
        rewardPercentage = _rewardPercentage;
        isActive = true;
    }
}