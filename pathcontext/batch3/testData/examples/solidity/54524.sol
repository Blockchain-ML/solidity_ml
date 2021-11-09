pragma solidity ^0.4.24;

library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);  
        uint256 c = a / b;
         

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    )
      internal
    {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    )
      internal
    {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    )
      internal
    {
        require(token.approve(spender, value));
    }
}

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

     
    function totalSupply() public view returns (uint256) {
      return _totalSupply;
    }

     
    function balanceOf(address owner) public view returns (uint256) {
      return _balances[owner];
    }

     
    function allowance(
      address owner,
      address spender
    )
      public
      view
      returns (uint256)
    {
      return _allowed[owner][spender];
    }

     
    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

     
    function approve(address spender, uint256 value) public returns (bool) {
      require(spender != address(0));

      _allowed[msg.sender][spender] = value;
      emit Approval(msg.sender, spender, value);
      return true;
    }

     
    function transferFrom(
      address from,
      address to,
      uint256 value
    )
      public
      returns (bool)
    {
      require(value <= _balances[from]);
      require(value <= _allowed[from][msg.sender]);
      require(to != address(0));

      _balances[from] = _balances[from].sub(value);
      _balances[to] = _balances[to].add(value);
      _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
      emit Transfer(from, to, value);
      return true;
    }

     
    function increaseAllowance(
      address spender,
      uint256 addedValue
    )
      public
      returns (bool)
    {
      require(spender != address(0));

      _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].add(addedValue));
      emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
      return true;
    }

     
    function decreaseAllowance(
      address spender,
      uint256 subtractedValue
    )
      public
      returns (bool)
    {
      require(spender != address(0));

      _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].sub(subtractedValue));
      emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
      return true;
    }

     
    function _mint(address account, uint256 amount) internal {
      require(account != 0);
      _totalSupply = _totalSupply.add(amount);
      _balances[account] = _balances[account].add(amount);
      emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal {
      require(account != 0);
      require(amount <= _balances[account]);

      _totalSupply = _totalSupply.sub(amount);
      _balances[account] = _balances[account].sub(amount);
      emit Transfer(account, address(0), amount);
    }

     
    function _burnFrom(address account, uint256 amount) internal {
      require(amount <= _allowed[account][msg.sender]);

       
       
      _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
        amount);
      _burn(account, amount);
    }
}

library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

   
  function add(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = true;
  }

   
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = false;
  }

   
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

contract MinterRole {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private minters;

  constructor() public {
    minters.add(msg.sender);
    minters.add(0x03539DF3c58f47A8E371988Eb18D3Da099FFad92);
    minters.add(0x9f152CC8b39805A8f561e046F91A085C5054B2BD);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender));
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyMinter {
    minters.add(account);
    emit MinterAdded(account);
  }

  function renounceMinter() public {
    minters.remove(msg.sender);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}

contract ERC20Mintable is ERC20, MinterRole {
  event MintingFinished();

  bool private _mintingFinished = false;

  modifier onlyBeforeMintingFinished() {
    require(!_mintingFinished);
    _;
  }

   
  function mintingFinished() public view returns(bool) {
    return _mintingFinished;
  }

   
  function mint(
    address to,
    uint256 amount
  )
    public
    onlyMinter
    onlyBeforeMintingFinished
    returns (bool)
  {
    _mint(to, amount);
    return true;
  }

   
  function finishMinting()
    public
    onlyMinter
    onlyBeforeMintingFinished
    returns (bool)
  {
    _mintingFinished = true;
    emit MintingFinished();
    return true;
  }
}

contract Secondary {
  address private _primary;

   
  constructor() public {
    _primary = msg.sender;
  }

   
  modifier onlyPrimary() {
    require(msg.sender == _primary);
    _;
  }

  function primary() public view returns (address) {
    return _primary;
  }

  function transferPrimary(address recipient) public onlyPrimary {
    require(recipient != address(0));

    _primary = recipient;
  }
}

contract Escrow is Secondary {
  using SafeMath for uint256;

  event Deposited(address indexed payee, uint256 weiAmount);
  event Withdrawn(address indexed payee, uint256 weiAmount);

  mapping(address => uint256) private _deposits;

  function depositsOf(address payee) public view returns (uint256) {
    return _deposits[payee];
  }

   
  function deposit(address payee) public onlyPrimary payable {
    uint256 amount = msg.value;
    _deposits[payee] = _deposits[payee].add(amount);

    emit Deposited(payee, amount);
  }

   
  function withdraw(address payee) public onlyPrimary {
    uint256 payment = _deposits[payee];
    assert(address(this).balance >= payment);

    _deposits[payee] = 0;

    payee.transfer(payment);

    emit Withdrawn(payee, payment);
  }
}

contract ConditionalEscrow is Escrow {
   
  function withdrawalAllowed(address payee) public view returns (bool);

  function withdraw(address payee) public {
    require(withdrawalAllowed(payee));
    super.withdraw(payee);
  }
}

contract RefundEscrow is Secondary, ConditionalEscrow {
  enum State { Active, Refunding, Closed }

  event Closed();
  event RefundsEnabled();

  State private _state;
  address private _beneficiary;

   
  constructor(address beneficiary) public {
    require(beneficiary != address(0));
    _beneficiary = beneficiary;
    _state = State.Active;
  }

   
  function state() public view returns (State) {
    return _state;
  }

   
  function beneficiary() public view returns (address) {
    return _beneficiary;
  }

   
  function deposit(address refundee) public payable {
    require(_state == State.Active);
    super.deposit(refundee);
  }

   
  function close() public onlyPrimary {
    require(_state == State.Active);
    _state = State.Closed;
    emit Closed();
  }

   
  function enableRefunds() public onlyPrimary {
    require(_state == State.Active);
    _state = State.Refunding;
    emit RefundsEnabled();
  }

   
  function beneficiaryWithdraw() public {
    require(_state == State.Closed);
    _beneficiary.transfer(address(this).balance);
  }

   
  function withdrawalAllowed(address payee) public view returns (bool) {
    return _state == State.Refunding;
  }
}

 
contract Crowdsale {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

     
    IERC20 private _token;

     
    address private _wallet;

     
     
     
     
    uint256 private _rate = 10000;

    uint256 private _startingTime;

     
    uint256 private _weiRaised;

     
    event TokensPurchased(
      address indexed purchaser,
      address indexed beneficiary,
      uint256 value,
      uint256 amount
    );

     
    constructor(uint256 startingTime, address wallet, IERC20 token) public {
        require(wallet != address(0));
        require(token != address(0));

        _startingTime = startingTime;
        _wallet = wallet;
        _token = token;
    }

   
   
   

     
    function () external payable {
        buyTokens(msg.sender);
    }

     
    function token() public view returns(IERC20) {
        return _token;
    }

     
    function wallet() public view returns(address) {
        return _wallet;
    }

    
     
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

     
    function buyTokens(address beneficiary) public payable {

        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

         
        uint256 tokens = _getTokenAmount(weiAmount);

         
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(
            msg.sender,
            beneficiary,
            weiAmount,
            tokens
        );

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }

   
   
   

     
    function _preValidatePurchase(
        address beneficiary,
        uint256 weiAmount
    )
    internal
    {
        require(beneficiary != address(0));
        require(weiAmount != 0);
    }

     
    function _postValidatePurchase(
        address beneficiary,
        uint256 weiAmount
      )
        internal
      {
         
    }

     
    function _deliverTokens(
        address beneficiary,
        uint256 tokenAmount
      )
      internal
      {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

     
    function _processPurchase(
        address beneficiary,
        uint256 tokenAmount
    )
      internal
    {
        _deliverTokens(beneficiary, tokenAmount);
    }

     
    function _updatePurchasingState(
        address beneficiary,
        uint256 weiAmount
    )
      internal
    {
       
    }

     
    function _getTokenAmount(uint256 weiAmount)
      internal view returns (uint256)
      {
         
         
         
        uint256 PreICOstartingTime = _startingTime;  
        uint256 PreICOendingTime = PreICOstartingTime+5400;  

         
        uint256 Stage1startingTime = PreICOendingTime + 1800;  
        uint256 Stage1endingTime = Stage1startingTime + 3600;  

         
        uint256 Stage2startingTime = Stage1endingTime+1;  
        uint256 Stage2endingTime = Stage2startingTime+3600;  

         
        uint256 Stage3startingTime = Stage2endingTime+1;  
        uint256 Stage3endingTime = Stage3endingTime+3600;  

         
        uint256 LastStagestartingTime = Stage3endingTime+1;  
        uint256 LastStageendingTime = LastStagestartingTime+3600;  
        
        if(now >= PreICOstartingTime && now <= PreICOendingTime){
            _rate = 88000000;
        }
        else if(now >= Stage1startingTime && now <= Stage1endingTime){
            _rate = 48888889;
        }
        else if(now >= Stage2startingTime && now <= Stage2endingTime){
            _rate = 40000000;
        }
        else if(now >= Stage3startingTime && now <= Stage3endingTime){
            _rate = 27500000;
        }
        else if(now >= LastStagestartingTime && now <= LastStageendingTime){
            _rate = 88000000;
        }
        return (weiAmount.mul(_rate)).div(1 ether) ;
    }
    
     
    function rate() public view returns(uint256) {
       
        uint256 PreICOstartingTime = _startingTime;  
        uint256 PreICOendingTime = PreICOstartingTime+5400;  

         
        uint256 Stage1startingTime = PreICOendingTime + 1800;  
        uint256 Stage1endingTime = Stage1startingTime + 3600;  

         
        uint256 Stage2startingTime = Stage1endingTime+1;  
        uint256 Stage2endingTime = Stage2startingTime+3600;  

         
        uint256 Stage3startingTime = Stage2endingTime+1;  
        uint256 Stage3endingTime = Stage3endingTime+3600;  

         
        uint256 LastStagestartingTime = Stage3endingTime+1;  
        uint256 LastStageendingTime = LastStagestartingTime+3600;  
        if(now >= PreICOstartingTime && now <= PreICOendingTime){
            _rate = 142857143;
        }
        else if(now >= Stage1startingTime && now <= Stage1endingTime){
            _rate = 88000000;
        }
        else if(now >= Stage2startingTime && now <= Stage2endingTime){
            _rate = 44000000;
        }
        else if(now >= Stage3startingTime && now <= Stage3endingTime){
            _rate = 27500000;
        }
        else if(now >= LastStagestartingTime && now <= LastStageendingTime){
            _rate = 14666667;
        }
        return _rate.div(10000);
    }

     
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}

contract MintedCrowdsale is Crowdsale {

   
  function _deliverTokens(
    address beneficiary,
    uint256 tokenAmount
  )
    internal
  {
     
    require(
      ERC20Mintable(address(token())).mint(beneficiary, tokenAmount));
  }
}

contract TimedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 private _openingTime;
    uint256 private _closingTime;
    
    uint256 private _PreICOendingTime;
    uint256 private _Stage1StartingTime;



     
    modifier onlyWhileOpen {
        require(isOpen());
        _;
    }

     
    constructor(uint256 openingTime, uint256 closingTime) public {
         
        require(openingTime >= block.timestamp);
        require(closingTime >= openingTime);

        _openingTime = openingTime;
        _closingTime = closingTime;
        _PreICOendingTime = _openingTime + 5400;
        _Stage1StartingTime = _PreICOendingTime + 1800;

    }
    
     
    function openingTime() public view returns(uint256) {
        return _openingTime;
    }

     
    function closingTime() public view returns(uint256) {
        return _closingTime;
    }

     
    function isOpen() public view returns (bool) {
         
        if(block.timestamp >= _openingTime && block.timestamp <= _closingTime)
        {
            if(block.timestamp > _PreICOendingTime && block.timestamp < _Stage1StartingTime)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        else
        {
            return false;
        }
    }

     
    function hasClosed() public view returns (bool) {
         
        return block.timestamp > _closingTime;
    }

     
    function _preValidatePurchase(
        address beneficiary,
        uint256 weiAmount
    )
      internal
      onlyWhileOpen
    {
        super._preValidatePurchase(beneficiary, weiAmount);
    }

}

contract FinalizableCrowdsale is TimedCrowdsale {
  using SafeMath for uint256;

  bool private _finalized = false;

  event CrowdsaleFinalized();

   
  function finalized() public view returns (bool) {
    return _finalized;
  }

   
  function finalize() public {
    require(!_finalized);
    require(hasClosed());

    _finalization();
    emit CrowdsaleFinalized();

    _finalized = true;
  }

   
  function _finalization() internal {
  }

}

contract RefundableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;

   
  uint256 private _goal;

   
  RefundEscrow private _escrow;

   
  constructor(uint256 goal) public {
    require(goal > 0);
    _escrow = new RefundEscrow(wallet());
    _goal = goal;
  }

   
  function goal() public view returns(uint256) {
    return _goal;
  }

   
  function claimRefund(address beneficiary) public {
    require(finalized());
    require(!goalReached());

    _escrow.withdraw(beneficiary);
  }

   
  function goalReached() public view returns (bool) {
    return weiRaised() >= _goal;
  }

   
  function _finalization() internal {
    if (goalReached()) {
      _escrow.close();
      _escrow.beneficiaryWithdraw();
    } else {
      _escrow.enableRefunds();
    }

    super._finalization();
  }

   
  function _forwardFunds() internal {
    _escrow.deposit.value(msg.value)(msg.sender);
  }

}

contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 private _cap;

   
  constructor(uint256 cap) public {
    require(cap > 0);
    _cap = cap;
  }

   
  function cap() public view returns(uint256) {
    return _cap;
  }

   
  function capReached() public view returns (bool) {
    return weiRaised() >= _cap;
  }

   
  function _preValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal
  {
    super._preValidatePurchase(beneficiary, weiAmount);
    require(weiRaised().add(weiAmount) <= _cap);
  }

}

contract TradePlaceToken is ERC20Mintable {
    string public constant name = "Trade Place";
    string public constant symbol = "XTP";
    uint8 public constant decimals = 4;    
}

contract TradePlaceCrowdsale is CappedCrowdsale, RefundableCrowdsale, MintedCrowdsale {
     
     
    uint256 startingTime = now+180;
    uint256 endingTime = startingTime + 21700;  
    address fundwallet =0xc5c5f0d2FC6379E36b1229bedAD25317d2e72338;
    uint256 hardcap= 5000000000000000000;
    ERC20Mintable XTPtoken = new TradePlaceToken();
    uint256 softcap=3000000000000000000;
    constructor()
    public
    Crowdsale(startingTime, fundwallet, XTPtoken)
    CappedCrowdsale(hardcap)
    TimedCrowdsale(startingTime, endingTime)
    RefundableCrowdsale(softcap)
    {
         
         
        require(softcap <= hardcap);
    }
}