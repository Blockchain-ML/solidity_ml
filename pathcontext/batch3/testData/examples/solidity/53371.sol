pragma solidity 0.4.18;

 

 
interface ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    function decimals() public view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

 

 
interface KyberNetworkInterface {
    function maxGasPrice() public view returns(uint);
    function getUserCapInWei(address user) public view returns(uint);
    function getUserCapInTokenWei(address user, ERC20 token) public view returns(uint);
    function enabled() public view returns(bool);
    function info(bytes32 id) public view returns(uint);

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public view
        returns (uint expectedRate, uint slippageRate);

    function tradeWithHint(address trader, ERC20 src, uint srcAmount, ERC20 dest, address destAddress,
        uint maxDestAmount, uint minConversionRate, address walletId, bytes hint) public payable returns(uint);
}

 

 
interface KyberNetworkProxyInterface {
    function maxGasPrice() public view returns(uint);
    function getUserCapInWei(address user) public view returns(uint);
    function getUserCapInTokenWei(address user, ERC20 token) public view returns(uint);
    function enabled() public view returns(bool);
    function info(bytes32 id) public view returns(uint);

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public view
        returns (uint expectedRate, uint slippageRate);

    function tradeWithHint(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,
        uint minConversionRate, address walletId, bytes hint) public payable returns(uint);
}

 

 
interface SimpleNetworkInterface {
    function swapTokenToToken(ERC20 src, uint srcAmount, ERC20 dest, uint minConversionRate) public returns(uint);
    function swapEtherToToken(ERC20 token, uint minConversionRate) public payable returns(uint);
    function swapTokenToEther(ERC20 token, uint srcAmount, uint minConversionRate) public returns(uint);
}

 

 
contract Utils {

    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    uint  constant internal PRECISION = (10**18);
    uint  constant internal MAX_QTY   = (10**28);  
    uint  constant internal MAX_RATE  = (PRECISION * 10**6);  
    uint  constant internal MAX_DECIMALS = 18;
    uint  constant internal ETH_DECIMALS = 18;
    mapping(address=>uint) internal decimals;

    function setDecimals(ERC20 token) internal {
        if (token == ETH_TOKEN_ADDRESS) decimals[token] = ETH_DECIMALS;
        else decimals[token] = token.decimals();
    }

    function getDecimals(ERC20 token) internal view returns(uint) {
        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS;  
        uint tokenDecimals = decimals[token];
         
         
         
        if(tokenDecimals == 0) return token.decimals();

        return tokenDecimals;
    }

    function calcDstQty(uint srcQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {
        require(srcQty <= MAX_QTY);
        require(rate <= MAX_RATE);

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(uint dstQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {
        require(dstQty <= MAX_QTY);
        require(rate <= MAX_RATE);
        
         
        uint numerator;
        uint denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator;  
    }
}

 

contract Utils2 is Utils {

     
     
     
    function getBalance(ERC20 token, address user) public view returns(uint) {
        if (token == ETH_TOKEN_ADDRESS)
            return user.balance;
        else
            return token.balanceOf(user);
    }

    function getDecimalsSafe(ERC20 token) internal returns(uint) {

        if (decimals[token] == 0) {
            setDecimals(token);
        }

        return decimals[token];
    }

    function calcDestAmount(ERC20 src, ERC20 dest, uint srcAmount, uint rate) internal view returns(uint) {
        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(ERC20 src, ERC20 dest, uint destAmount, uint rate) internal view returns(uint) {
        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcRateFromQty(uint srcAmount, uint destAmount, uint srcDecimals, uint dstDecimals)
        internal pure returns(uint)
    {
        require(srcAmount <= MAX_QTY);
        require(destAmount <= MAX_QTY);

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return (destAmount * PRECISION / ((10 ** (dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return (destAmount * PRECISION * (10 ** (srcDecimals - dstDecimals)) / srcAmount);
        }
    }
}

 

contract PermissionGroups {

    address public admin;
    address public pendingAdmin;
    mapping(address=>bool) internal operators;
    mapping(address=>bool) internal alerters;
    address[] internal operatorsGroup;
    address[] internal alertersGroup;
    uint constant internal MAX_GROUP_SIZE = 50;

    function PermissionGroups() public {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender]);
        _;
    }

    modifier onlyAlerter() {
        require(alerters[msg.sender]);
        _;
    }

    function getOperators () external view returns(address[]) {
        return operatorsGroup;
    }

    function getAlerters () external view returns(address[]) {
        return alertersGroup;
    }

    event TransferAdminPending(address pendingAdmin);

     
    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0));
        TransferAdminPending(pendingAdmin);
        pendingAdmin = newAdmin;
    }

     
    function transferAdminQuickly(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0));
        TransferAdminPending(newAdmin);
        AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    event AdminClaimed( address newAdmin, address previousAdmin);

     
    function claimAdmin() public {
        require(pendingAdmin == msg.sender);
        AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    event AlerterAdded (address newAlerter, bool isAdd);

    function addAlerter(address newAlerter) public onlyAdmin {
        require(!alerters[newAlerter]);  
        require(alertersGroup.length < MAX_GROUP_SIZE);

        AlerterAdded(newAlerter, true);
        alerters[newAlerter] = true;
        alertersGroup.push(newAlerter);
    }

    function removeAlerter (address alerter) public onlyAdmin {
        require(alerters[alerter]);
        alerters[alerter] = false;

        for (uint i = 0; i < alertersGroup.length; ++i) {
            if (alertersGroup[i] == alerter) {
                alertersGroup[i] = alertersGroup[alertersGroup.length - 1];
                alertersGroup.length--;
                AlerterAdded(alerter, false);
                break;
            }
        }
    }

    event OperatorAdded(address newOperator, bool isAdd);

    function addOperator(address newOperator) public onlyAdmin {
        require(!operators[newOperator]);  
        require(operatorsGroup.length < MAX_GROUP_SIZE);

        OperatorAdded(newOperator, true);
        operators[newOperator] = true;
        operatorsGroup.push(newOperator);
    }

    function removeOperator (address operator) public onlyAdmin {
        require(operators[operator]);
        operators[operator] = false;

        for (uint i = 0; i < operatorsGroup.length; ++i) {
            if (operatorsGroup[i] == operator) {
                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
                operatorsGroup.length -= 1;
                OperatorAdded(operator, false);
                break;
            }
        }
    }
}

 

 
contract Withdrawable is PermissionGroups {

    event TokenWithdraw(ERC20 token, uint amount, address sendTo);

     
    function withdrawToken(ERC20 token, uint amount, address sendTo) external onlyAdmin {
        require(token.transfer(sendTo, amount));
        TokenWithdraw(token, amount, sendTo);
    }

    event EtherWithdraw(uint amount, address sendTo);

     
    function withdrawEther(uint amount, address sendTo) external onlyAdmin {
        sendTo.transfer(amount);
        EtherWithdraw(amount, sendTo);
    }
}

 

 
 
contract KyberNetworkProxy is KyberNetworkProxyInterface, SimpleNetworkInterface, Withdrawable, Utils2 {

    KyberNetworkInterface public kyberNetworkContract;

    function KyberNetworkProxy(address _admin) public {
        require(_admin != address(0));
        admin = _admin;
    }

     
     
     
     
     
     
     
     
     
     
    function trade(
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
    )
        public
        payable
        returns(uint)
    {
        bytes memory hint;

        return tradeWithHint(
            src,
            srcAmount,
            dest,
            destAddress,
            maxDestAmount,
            minConversionRate,
            walletId,
            hint
        );
    }

     
     
     
     
     
     
    function swapTokenToToken(
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        uint minConversionRate
    )
        public
        returns(uint)
    {
        bytes memory hint;

        return tradeWithHint(
            src,
            srcAmount,
            dest,
            msg.sender,
            MAX_QTY,
            minConversionRate,
            0,
            hint
        );
    }

     
     
     
     
    function swapEtherToToken(ERC20 token, uint minConversionRate) public payable returns(uint) {
        bytes memory hint;

        return tradeWithHint(
            ETH_TOKEN_ADDRESS,
            msg.value,
            token,
            msg.sender,
            MAX_QTY,
            minConversionRate,
            0,
            hint
        );
    }

     
     
     
     
     
    function swapTokenToEther(ERC20 token, uint srcAmount, uint minConversionRate) public returns(uint) {
        bytes memory hint;

        return tradeWithHint(
            token,
            srcAmount,
            ETH_TOKEN_ADDRESS,
            msg.sender,
            MAX_QTY,
            minConversionRate,
            0,
            hint
        );
    }

    struct UserBalance {
        uint srcBalance;
        uint destBalance;
    }

    event ExecuteTrade(address indexed trader, ERC20 src, ERC20 dest, uint actualSrcAmount, uint actualDestAmount);

     
     
     
     
     
     
     
     
     
     
     
    function tradeWithHint(
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId,
        bytes hint
    )
        public
        payable
        returns(uint)
    {
        require(src == ETH_TOKEN_ADDRESS || msg.value == 0);
        
        UserBalance memory userBalanceBefore;

        userBalanceBefore.srcBalance = getBalance(src, msg.sender);
        userBalanceBefore.destBalance = getBalance(dest, destAddress);

        if (src == ETH_TOKEN_ADDRESS) {
            userBalanceBefore.srcBalance += msg.value;
        } else {
            require(src.transferFrom(msg.sender, kyberNetworkContract, srcAmount));
        }

        uint reportedDestAmount = kyberNetworkContract.tradeWithHint.value(msg.value)(
            msg.sender,
            src,
            srcAmount,
            dest,
            destAddress,
            maxDestAmount,
            minConversionRate,
            walletId,
            hint
        );

        TradeOutcome memory tradeOutcome = calculateTradeOutcome(
            userBalanceBefore.srcBalance,
            userBalanceBefore.destBalance,
            src,
            dest,
            destAddress
        );

        require(reportedDestAmount == tradeOutcome.userDeltaDestAmount);
        require(tradeOutcome.userDeltaDestAmount <= maxDestAmount);
        require(tradeOutcome.actualRate >= minConversionRate);

        ExecuteTrade(msg.sender, src, dest, tradeOutcome.userDeltaSrcAmount, tradeOutcome.userDeltaDestAmount);
        return tradeOutcome.userDeltaDestAmount;
    }

    event KyberNetworkSet(address newNetworkContract, address oldNetworkContract);

    function setKyberNetworkContract(KyberNetworkInterface _kyberNetworkContract) public onlyAdmin {

        require(_kyberNetworkContract != address(0));

        KyberNetworkSet(_kyberNetworkContract, kyberNetworkContract);

        kyberNetworkContract = _kyberNetworkContract;
    }

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty)
        public view
        returns(uint expectedRate, uint slippageRate)
    {
        return kyberNetworkContract.getExpectedRate(src, dest, srcQty);
    }

    function getUserCapInWei(address user) public view returns(uint) {
        return kyberNetworkContract.getUserCapInWei(user);
    }

    function getUserCapInTokenWei(address user, ERC20 token) public view returns(uint) {
        return kyberNetworkContract.getUserCapInTokenWei(user, token);
    }

    function maxGasPrice() public view returns(uint) {
        return kyberNetworkContract.maxGasPrice();
    }

    function enabled() public view returns(bool) {
        return kyberNetworkContract.enabled();
    }

    function info(bytes32 field) public view returns(uint) {
        return kyberNetworkContract.info(field);
    }

    struct TradeOutcome {
        uint userDeltaSrcAmount;
        uint userDeltaDestAmount;
        uint actualRate;
    }

    function calculateTradeOutcome (uint srcBalanceBefore, uint destBalanceBefore, ERC20 src, ERC20 dest,
        address destAddress)
        internal returns(TradeOutcome outcome)
    {
        uint userSrcBalanceAfter;
        uint userDestBalanceAfter;

        userSrcBalanceAfter = getBalance(src, msg.sender);
        userDestBalanceAfter = getBalance(dest, destAddress);

         
        require(userDestBalanceAfter > destBalanceBefore);
        require(srcBalanceBefore > userSrcBalanceAfter);

        outcome.userDeltaDestAmount = userDestBalanceAfter - destBalanceBefore;
        outcome.userDeltaSrcAmount = srcBalanceBefore - userSrcBalanceAfter;

        outcome.actualRate = calcRateFromQty(
                outcome.userDeltaSrcAmount,
                outcome.userDeltaDestAmount,
                getDecimalsSafe(src),
                getDecimalsSafe(dest)
            );
    }
}

contract Blarity {
  ERC20 constant internal ACCEPT_DAI_ADDRESS = ERC20(0x00ad6d458402f60fd3bd25163575031acdce07538d);
   
   
   
  address public owner;
   
  struct CampaignCreator {
    address addr;
     
    uint amount;
     
    bool isRequested;
  }
   
  uint public startTime;
  uint public endTime;
   
  ERC20 public acceptedToken;
  uint public targetedMoney;
  bool public isReverted = false;

  struct Supplier {
    address addr;
     
    uint amount;
     
    bool isRequested;
    bool isOwnerApproved;
    bool isCreatorApproved;
  }

  struct Donator {
    address addr;
    uint amount;
  }

  CampaignCreator campaignCreator;
  Supplier[] suppliers;
  Donator[] donators;

   
  event EtherWithdraw(uint amount, address sendTo);
   
  function withdrawEther(uint amount, address sendTo) public onlyOwner {
    sendTo.transfer(amount);
    EtherWithdraw(amount, sendTo);
  }

  event TokenWithdraw(ERC20 token, uint amount, address sendTo);
   
  function withdrawToken(ERC20 token, uint amount, address sendTo) public onlyOwner {
    require(token != acceptedToken);
    token.transfer(sendTo, amount);
    TokenWithdraw(token, amount, sendTo);
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyCampaignCreator() {
    require(msg.sender == campaignCreator.addr);
    _;
  }

   
  event TransferOwner(address newOwner);
  function transferOwner(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
    TransferOwner(newOwner);
  }

   
  event TransferCampaignCreator(address newCampCreator);
  function transferCampaignCreator(address newCampCreator) public onlyCampaignCreator {
    require(newCampCreator != address(0));
    campaignCreator = CampaignCreator({
      addr: newCampCreator,
      amount: campaignCreator.amount,
      isRequested: campaignCreator.isRequested
    });
    TransferOwner(newCampCreator);
  }

  function Blarity(
    address _campCreator,
    uint _campAmount,
    uint _endTime,
    uint _targetMoney,
    address[] supplierAddresses,
    uint[] supplierAmounts
  ) public {
    require(_campCreator != address(0));
    require(_targetMoney > 0);
    require(_endTime > now);
    require(supplierAddresses.length == supplierAmounts.length);
    owner = msg.sender;
    campaignCreator = CampaignCreator({addr: _campCreator, amount: _campAmount, isRequested: false});
    endTime = _endTime;
    acceptedToken = ACCEPT_DAI_ADDRESS;
    targetedMoney = _targetMoney;
    isReverted = false;
    for(uint i = 0; i < supplierAddresses.length; i++) {
      require(supplierAddresses[i] != address(0));
      require(supplierAmounts[i] > 0);
      Supplier memory sup = Supplier({
        addr: supplierAddresses[i],
        amount: supplierAmounts[i],
        isRequested: false,
        isOwnerApproved: false,
        isCreatorApproved: false
      });
      suppliers.push(sup);
    }
  }

  event AddNewSupplier(address _address, uint _amount);
  event ReplaceSupplier(address _address, uint _amount);
   
  function addNewSupplier(address _address, uint _amount) public onlyOwner {
    require(now < endTime);  
    require(_address != address(0));
    require(_amount > 0);
    for(uint i = 0; i < suppliers.length; i++) {
      if (suppliers[i].addr == _address) {
        if (suppliers[i].amount == _amount) { return; }
        suppliers[i].amount = _amount;
        suppliers[i].isRequested = false;
        suppliers[i].isCreatorApproved = false;
        suppliers[i].isOwnerApproved = false;
        ReplaceSupplier(_address, _amount);
        return;
      }
    }
    Supplier memory sup = Supplier({
      addr: _address,
      amount: _amount,
      isRequested: false,
      isCreatorApproved: false,
      isOwnerApproved: false
    });
    suppliers.push(sup);
    AddNewSupplier(_address, _amount);
  }

  event RemoveSupplier(address _address);
  function removeSupplier(address _address) public onlyOwner {
    require(now < endTime);  
    require(_address != address(0));
    for(uint i = 0; i < suppliers.length; i++) {
      if (suppliers[i].addr == _address) {
        suppliers[i] = suppliers[suppliers.length - 1];
         
        suppliers.length--;
        RemoveSupplier(_address);
      }
    }
  }

  function updateTargetedMoney(uint _money) public onlyOwner {
    require(now < endTime);  
    targetedMoney = _money;
  }

  function updateEndTime(uint _endTime) public onlyOwner {
    endTime = _endTime;
  }

  function updateIsReverted(bool _isReverted) public onlyOwner {
    isReverted = _isReverted;
  }

  event UpdateIsReverted(bool isReverted);
  function updateIsRevertedEndTimeReached() public onlyOwner {
    require(now >= endTime);
    require(isReverted == false);
    if (ACCEPT_DAI_ADDRESS.balanceOf(address(this)) < targetedMoney) {
      isReverted = true;
      UpdateIsReverted(true);
    }
  }

  event SupplierFundTransferRequested(address addr, uint amount);
  function requestTransferFundToSupplier() public {
    require(now >= endTime);  
    for(uint i = 0; i < suppliers.length; i++) {
      if (suppliers[i].addr == msg.sender) {
        require(suppliers[i].amount > 0);
        require(suppliers[i].isRequested == false);
        require(ACCEPT_DAI_ADDRESS.balanceOf(address(this)) >= suppliers[i].amount);
        suppliers[i].isRequested = true;
        SupplierFundTransferRequested(msg.sender, suppliers[i].amount);
      }
    }
  }

  event ApproveSupplierFundTransferRequested(address addr, uint amount);
  event FundTransferredToSupplier(address supplier, uint amount);
   
  function approveFundTransferToSupplier(address _supplier) public {
    require(now >= endTime);  
    require(msg.sender == owner || msg.sender == campaignCreator.addr);
    for(uint i = 0; i < suppliers.length; i++) {
      if (suppliers[i].addr == _supplier) {
        require(suppliers[i].amount > 0);
        require(ACCEPT_DAI_ADDRESS.balanceOf(address(this)) >= suppliers[i].amount);
        if (msg.sender == owner) {
          suppliers[i].isOwnerApproved = true;
        } else {
          suppliers[i].isCreatorApproved = true;
        }
        if (suppliers[i].isOwnerApproved && suppliers[i].isCreatorApproved) {
           
          if (ACCEPT_DAI_ADDRESS.transferFrom(address(this), _supplier, suppliers[i].amount)) {
            suppliers[i].amount = 0;
            FundTransferredToSupplier(msg.sender, suppliers[i].amount);
          }
        } else {
          ApproveSupplierFundTransferRequested(msg.sender, suppliers[i].amount);
        }
      }
    }
  }

  event CreatorRequestFundTransfer(address _address, uint _amount);
  function creatorRequestFundTransfer() public onlyCampaignCreator {
    require(now >= endTime);  
    require(campaignCreator.amount > 0);
    campaignCreator.isRequested = true;
    CreatorRequestFundTransfer(msg.sender, campaignCreator.amount);
  }

  event FundTransferToCreator(address _from, address _to, uint _amount);
  function approveAndTransferFundToCreator() public onlyOwner {
    require(now >= endTime);  
    require(campaignCreator.amount > 0);
    require(campaignCreator.isRequested);
    if (ACCEPT_DAI_ADDRESS.transferFrom(address(this), campaignCreator.addr, campaignCreator.amount)) {
      campaignCreator.amount = 0;
      FundTransferToCreator(msg.sender, campaignCreator.addr, campaignCreator.amount);
    }
  }
  event Donated(address _address, uint _amount);
  function donateDAI(uint amount) public {
    require(amount > 0);
    require(now < endTime);
    require(ACCEPT_DAI_ADDRESS.balanceOf(msg.sender) >= amount);
    if (ACCEPT_DAI_ADDRESS.transferFrom(msg.sender, address(this), amount)) {
      for(uint i = 0; i < donators.length; i++) {
        if (donators[i].addr == msg.sender) {
          donators[i].amount += amount;
          Donated(msg.sender, amount);
          return;
        }
      }
      donators.push(Donator({addr: msg.sender, amount: amount}));
      Donated(msg.sender, amount);
    }
  }
 
  function donateToken(KyberNetworkProxy network, ERC20 src, uint srcAmount, uint maxDestAmount, uint minConversionRate, address walletId) public {
    require(now < endTime);
    require(src.balanceOf(msg.sender) >= srcAmount);
    network.trade(src, srcAmount, ACCEPT_DAI_ADDRESS, address(this), maxDestAmount, minConversionRate, walletId);
     
     
     
     
     
     
     
     
     
  }

  event Refunded(address _address, uint _amount);
  function requestRefundDonator() public {
    require(isReverted == true);  
    for(uint i = 0; i < donators.length; i++) {
      if (donators[i].addr == msg.sender) {
        require(donators[i].amount > 0);
        uint amount = donators[i].amount;
        if (ACCEPT_DAI_ADDRESS.transfer(msg.sender, amount)) {
          donators[i].amount = 0;
          Refunded(msg.sender, amount);
          return;
        }
      }
    }
  }

  function getCampaignCreator() public view returns (address _address, uint _amount) {
    return (campaignCreator.addr, campaignCreator.amount);
  }

  function getNumberSuppliers() public view returns (uint numberSuppliers) {
    numberSuppliers = suppliers.length;
    return numberSuppliers;
  }

  function getSuppliers()
  public view returns (address[] memory addresses, uint[] memory amounts, bool[] isRequested, bool[] isOwnerApproved, bool[] isCreatorApproved) {
    addresses = new address[](suppliers.length);
    amounts = new uint[](suppliers.length);
    isRequested = new bool[](suppliers.length);
    isOwnerApproved = new bool[](suppliers.length);
    isCreatorApproved = new bool[](suppliers.length);
    for(uint i = 0; i < suppliers.length; i++) {
      addresses[i] = suppliers[i].addr;
      amounts[i] = suppliers[i].amount;
      isRequested[i] = suppliers[i].isRequested;
      isOwnerApproved[i] = suppliers[i].isOwnerApproved;
      isCreatorApproved[i] = suppliers[i].isCreatorApproved;
    }
    return (addresses, amounts, isRequested, isOwnerApproved, isCreatorApproved);
  }

  function getSupplier(address _addr)
  public view returns (address _address, uint amount, bool isRequested, bool isOwnerApproved, bool isCreatorApproved) {
    for(uint i = 0; i < suppliers.length; i++) {
      if (suppliers[i].addr == _addr) {
        return (_addr, suppliers[i].amount, suppliers[i].isRequested, suppliers[i].isOwnerApproved, suppliers[i].isCreatorApproved);
      }
    }
  }

  function getNumberDonators() public view returns (uint numberDonators) {
    numberDonators = donators.length;
    return numberDonators;
  }

  function getDonators() public view returns (address[] addresses, uint[] amounts) {
    addresses = new address[](donators.length);
    amounts = new uint[](donators.length);
    for(uint i = 0; i < donators.length; i++) {
      addresses[i] = donators[i].addr;
      amounts[i] = donators[i].amount;
    }
    return (addresses, amounts);
  }

  function getDonator(address _addr) public view returns (address _address, uint _amount) {
    for(uint i = 0; i < donators.length; i++) {
      if (donators[i].addr == _addr) {
        return (_addr, donators[i].amount);
      }
    }
  }

  function getDAIBalance() public view returns (uint balance) {
    return ACCEPT_DAI_ADDRESS.balanceOf(address(this));
  }
}