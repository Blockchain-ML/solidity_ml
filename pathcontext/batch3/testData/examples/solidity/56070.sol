pragma solidity ^0.4.23;

 

 
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

 

contract Stateable is Ownable {
    enum State{Unknown, Preparing, Starting, Pausing, Finished}
    State state;

    event OnStateChange(string _state);

    constructor() public {
        state = State.Unknown;
    }

    modifier prepared() {
        require(getState() == State.Preparing);
        _;
    }

    modifier started() {
        require(getState() == State.Starting);
        _;
    }

    modifier paused() {
        require(getState() == State.Pausing);
        _;
    }

    modifier finished() {
        require(getState() == State.Finished);
        _;
    }

    function setState(State _state) internal {
        state = _state;
        emit OnStateChange(getKeyByValue(state));
    }

    function getState() public view returns (State) {
        return state;
    }

    function getKeyByValue(State _state) public pure returns (string) {
        if (State.Unknown == _state) return "Unknown";
        if (State.Preparing == _state) return "Preparing";
        if (State.Starting == _state) return "Starting";
        if (State.Pausing == _state) return "Pausing";
        if (State.Finished == _state) return "Finished";
        return "";
    }
}

 

contract ExtendsOwnable {

    mapping(address => bool) owners;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipExtended(address indexed host, address indexed guest);

    modifier onlyOwner() {
        require(owners[msg.sender]);
        _;
    }

    constructor() public {
        owners[msg.sender] = true;
    }

    function addOwner(address guest) public onlyOwner {
        require(guest != address(0));
        owners[guest] = true;
        emit OwnershipExtended(msg.sender, guest);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owners[newOwner] = true;
        delete owners[msg.sender];
        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

 

 
contract Product is ExtendsOwnable {
    string public name;
    uint256 public maxcap;
    uint256 public exceed;
    uint256 public minimum;
    uint256 public rate;
    uint256 public lockup;

    constructor (
        string _name,
        uint256 _maxcap,
        uint256 _exceed,
        uint256 _minimum,
        uint256 _rate,
        uint256 _lockup
    ) public {
        name = _name;
        maxcap = _maxcap;
        exceed = _exceed;
        minimum = _minimum;
        rate = _rate;
        lockup = _lockup;
    }

    function setName(string _name) external onlyOwner {
        name = _name;
    }

    function setMaxcap(uint256 _maxcap) external onlyOwner {
        maxcap = _maxcap;
    }

    function setExceed(uint256 _exceed) external onlyOwner {
        exceed = _exceed;
    }

    function setMinimum(uint256 _minimum) external onlyOwner {
        minimum = _minimum;
    }

    function setRate(uint256 _rate) external onlyOwner {
        rate = _rate;
    }

    function setLockup(uint256 _lockup) external onlyOwner {
        lockup = _lockup;
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

 

library BlockTimeMs {
    using SafeMath for uint256;

    function getMs(uint s) internal pure returns(uint ms) {
        return s.mul(1000);
    }
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

 

contract TokenDistributor is ExtendsOwnable {

    using SafeMath for uint256;
    using BlockTimeMs for uint256;
    using SafeERC20 for ERC20;

    struct Purchased {
        address buyer;
        address product;
        uint256 id;
        uint256 amount;
        uint256 etherAmount;
        bool release;
        bool refund;
    }

    ERC20 token;
    Purchased[] private purchasedList;
    uint256 private index;
    uint256 public criterionTime;

    modifier validAddress(address _account) {
        require(_account != address(0));
        require(_account != address(this));
        _;
    }

    event Receipt(
        address buyer,
        address product,
        uint256 id,
        uint256 amount,
        uint256 etherAmount,
        bool release,
        bool refund
    );

    event ReleaseByCount(
        address product,
        uint256 request,
        uint256 succeed,
        uint256 remainder
    );

    event BuyerAddressTransfer(uint256 _id, address _from, address _to, uint256 _etherAmount);

    event WithdrawToken(address to, uint256 amount);

    constructor(address _token) public {
        token = ERC20(_token);
        index = 0;
        criterionTime = 0;

         
        purchasedList.push(Purchased(0, 0, 0, 0, 0, true, true));
    }

    function addPurchased(address _buyer, address _product, uint256 _amount, uint256 _etherAmount)
        external
        onlyOwner
        validAddress(_buyer)
        validAddress(_product)
        returns(uint256)
    {
        index = index.add(1);
        purchasedList.push(Purchased(_buyer, _product, index, _amount, _etherAmount, false, false));
        return index;

        emit Receipt(_buyer, _product, index, _amount, _etherAmount, false, false);
    }

    function getTokenAddress() external view returns(address) {
        return address(token);
    }

    function getAmount(uint256 _index) external view returns(uint256) {
        if (_index == 0) {
            return 0;
        }

        if (purchasedList[_index].release || purchasedList[_index].refund) {
            return 0;
        } else {
            return purchasedList[_index].amount;
        }
    }

    function getEtherAmount(uint256 _index) external view returns(uint256) {
        if (_index == 0) {
            return 0;
        }

        if (purchasedList[_index].release || purchasedList[_index].refund) {
            return 0;
        } else {
            return purchasedList[_index].etherAmount;
        }
    }

    function getAllReceipt()
        external
        view
        onlyOwner
        returns(address[], address[], uint256[], uint256[], uint256[], bool[], bool[])
    {
        address[] memory product = new address[](purchasedList.length.sub(1));
        address[] memory buyer = new address[](purchasedList.length.sub(1));
        uint256[] memory id = new uint256[](purchasedList.length.sub(1));
        uint256[] memory amount = new uint256[](purchasedList.length.sub(1));
        uint256[] memory etherAmount = new uint256[](purchasedList.length.sub(1));
        bool[] memory release = new bool[](purchasedList.length.sub(1));
        bool[] memory refund = new bool[](purchasedList.length.sub(1));

        uint256 receiptIndex = 0;
        for(uint i=1; i < purchasedList.length; i++) {
            product[receiptIndex] = purchasedList[i].product;
            buyer[receiptIndex] = purchasedList[i].buyer;
            id[receiptIndex] = purchasedList[i].id;
            amount[receiptIndex] = purchasedList[i].amount;
            etherAmount[receiptIndex] = purchasedList[i].etherAmount;
            release[receiptIndex] = purchasedList[i].release;
            refund[receiptIndex] = purchasedList[i].refund;

            receiptIndex = receiptIndex.add(1);
        }
        return (product, buyer, id, amount, etherAmount, release, refund);

    }

    function getBuyerReceipt(address _buyer)
        external
        view
        validAddress(_buyer)
        returns(address[], uint256[], uint256[], uint256[], bool[], bool[])
    {
        uint256 count = 0;
        for(uint i=1; i < purchasedList.length; i++) {
            if (purchasedList[i].buyer == _buyer) {
                count = count.add(1);
            }
        }

        address[] memory product = new address[](count);
        uint256[] memory id = new uint256[](count);
        uint256[] memory amount = new uint256[](count);
        uint256[] memory etherAmount = new uint256[](count);
        bool[] memory release = new bool[](count);
        bool[] memory refund = new bool[](count);

        if (count == 0) {
            return (product, id, amount, etherAmount, release, refund);
        }

        count = 0;
        for(i = 1; i < purchasedList.length; i++) {
            if (purchasedList[i].buyer == _buyer) {
                product[count] = purchasedList[i].product;
                id[count] = purchasedList[i].id;
                amount[count] = purchasedList[i].amount;
                etherAmount[count] = purchasedList[i].etherAmount;
                release[count] = purchasedList[i].release;
                refund[count] = purchasedList[i].refund;

                count = count.add(1);
            }
        }
        return (product, id, amount, etherAmount, release, refund);
    }

    function setCriterionTime(uint256 _criterionTime) external onlyOwner {
        require(_criterionTime > 0);

        criterionTime = _criterionTime;
    }

    function releaseByCount(address _product, uint256 _count)
        external
        onlyOwner
    {
        require(criterionTime != 0);

        uint256 succeed = 0;
        uint256 remainder = 0;

        for(uint i=1; i < purchasedList.length; i++) {
            if (isLive(i) && (purchasedList[i].product == _product)) {
                if (succeed < _count) {
                    Product product = Product(purchasedList[i].product);
                    uint256 oneDay = uint256(1 days).getMs();
                    require(block.timestamp.getMs() >= criterionTime.add(product.lockup().mul(oneDay)));
                    require(token.balanceOf(address(this)) >= purchasedList[i].amount);

                    purchasedList[i].release = true;
                    token.safeTransfer(purchasedList[i].buyer, purchasedList[i].amount);

                    succeed = succeed.add(1);

                    emit Receipt(
                        purchasedList[i].buyer,
                        purchasedList[i].product,
                        purchasedList[i].id,
                        purchasedList[i].amount,
                        purchasedList[i].etherAmount,
                        purchasedList[i].release,
                        purchasedList[i].refund);
                } else {
                    remainder = remainder.add(1);
                }
            }
        }

        emit ReleaseByCount(_product, _count, succeed, remainder);
    }

    function release(uint256 _index) external onlyOwner {
        require(_index != 0);
        require(criterionTime != 0);
        require(isLive(_index));

        Product product = Product(purchasedList[_index].product);
        uint256 oneDay = uint256(1 days).getMs();
        require(block.timestamp.getMs() >= criterionTime.add(product.lockup().mul(oneDay)));
        require(token.balanceOf(address(this)) >= purchasedList[_index].amount);

        purchasedList[_index].release = true;
        token.safeTransfer(purchasedList[_index].buyer, purchasedList[_index].amount);

        emit Receipt(
            purchasedList[_index].buyer,
            purchasedList[_index].product,
            purchasedList[_index].id,
            purchasedList[_index].amount,
            purchasedList[_index].etherAmount,
            purchasedList[_index].release,
            purchasedList[_index].refund);
    }

    function refund(uint _index, address _product, address _buyer)
        external
        onlyOwner
        returns (bool, uint256)
    {
        if (isLive(_index)
            && purchasedList[_index].product == _product
            && purchasedList[_index].buyer == _buyer)
        {

            purchasedList[_index].refund = true;

            emit Receipt(
                purchasedList[_index].buyer,
                purchasedList[_index].product,
                purchasedList[_index].id,
                purchasedList[_index].amount,
                purchasedList[_index].etherAmount,
                purchasedList[_index].release,
                purchasedList[_index].refund);

            return (true, purchasedList[_index].etherAmount);
        } else {
            return (false, 0);
        }
    }

    function buyerAddressTransfer(uint256 _index, address _from, address _to)
        external
        onlyOwner
        returns (bool, uint256)
    {
        require(isLive(_index));

        if (purchasedList[_index].buyer == _from) {
            purchasedList[_index].buyer = _to;
            emit BuyerAddressTransfer(_index, _from, _to, purchasedList[_index].etherAmount);
            return (true, purchasedList[_index].etherAmount);
        } else {
            return (false, 0);
        }
    }

    function withdrawToken(address _Owner) external onlyOwner {
        token.safeTransfer(_Owner, token.balanceOf(address(this)));
        emit WithdrawToken(_Owner, token.balanceOf(address(this)));
    }

    function isLive(uint256 _index) private view returns(bool){
        if (!purchasedList[_index].release
            && !purchasedList[_index].refund
            && purchasedList[_index].product != address(0)) {
            return true;
        } else {
            return false;
        }
    }
}

 

 
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

   
  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

   
  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

   
  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

   
  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
  }
}

 

 
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address addr, string roleName);
  event RoleRemoved(address addr, string roleName);

   
  function checkRole(address addr, string roleName)
    view
    public
  {
    roles[roleName].check(addr);
  }

   
  function hasRole(address addr, string roleName)
    view
    public
    returns (bool)
  {
    return roles[roleName].has(addr);
  }

   
  function addRole(address addr, string roleName)
    internal
  {
    roles[roleName].add(addr);
    emit RoleAdded(addr, roleName);
  }

   
  function removeRole(address addr, string roleName)
    internal
  {
    roles[roleName].remove(addr);
    emit RoleRemoved(addr, roleName);
  }

   
  modifier onlyRole(string roleName)
  {
    checkRole(msg.sender, roleName);
    _;
  }

   
   
   
   
   
   
   
   
   

   

   
   
}

 

 
contract Whitelist is Ownable, RBAC {
  event WhitelistedAddressAdded(address addr);
  event WhitelistedAddressRemoved(address addr);

  string public constant ROLE_WHITELISTED = "whitelist";

   
  modifier onlyWhitelisted() {
    checkRole(msg.sender, ROLE_WHITELISTED);
    _;
  }

   
  function addAddressToWhitelist(address addr)
    onlyOwner
    public
  {
    addRole(addr, ROLE_WHITELISTED);
    emit WhitelistedAddressAdded(addr);
  }

   
  function whitelist(address addr)
    public
    view
    returns (bool)
  {
    return hasRole(addr, ROLE_WHITELISTED);
  }

   
  function addAddressesToWhitelist(address[] addrs)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < addrs.length; i++) {
      addAddressToWhitelist(addrs[i]);
    }
  }

   
  function removeAddressFromWhitelist(address addr)
    onlyOwner
    public
  {
    removeRole(addr, ROLE_WHITELISTED);
    emit WhitelistedAddressRemoved(addr);
  }

   
  function removeAddressesFromWhitelist(address[] addrs)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < addrs.length; i++) {
      removeAddressFromWhitelist(addrs[i]);
    }
  }

}

 

 
library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

 

contract Sale is Stateable {
    using SafeMath for uint256;
    using Math for uint256;

    address public wallet;
    Whitelist public whiteList;
    Product public product;
    TokenDistributor public tokenDistributor;

    mapping (address => bool) isRegistered;
    mapping (address => uint256) weiRaised;
    mapping (address => mapping (address => uint256)) buyers;

    modifier validAddress(address _account) {
        require(_account != address(0));
        require(_account != address(this));
        _;
    }

    modifier validProductAddress(address _product) {
        require(!isRegistered[_product]);
        _;
    }

    modifier checkStatus() {
        require(getState() == State.Unknown || getState() == State.Preparing || getState() == State.Finished);
        _;
    }

    constructor (
        address _wallet,
        address _whiteList,
        address _tokenDistributor
    ) public {
        require(_wallet != address(0));
        require(_whiteList != address(0));
        require(_tokenDistributor != address(0));

        wallet = _wallet;
        whiteList = Whitelist(_whiteList);
        tokenDistributor = TokenDistributor(_tokenDistributor);
    }

    function registerProduct(address _product)
        external
        onlyOwner
        checkStatus
        validAddress(_product)
        validProductAddress(_product)
    {
        product = Product(_product);

        require(product.maxcap() > product.minimum());

        isRegistered[_product] = true;

        setState(State.Preparing);

        emit ChangeExternalAddress(_product, "Product");
    }

    function setTokenDistributor(address _tokenDistributor)
        external
        onlyOwner
        checkStatus
        validAddress(_tokenDistributor)
    {
        tokenDistributor = TokenDistributor(_tokenDistributor);
        emit ChangeExternalAddress(_tokenDistributor, "TokenDistributor");
    }

    function setWhitelist(address _whitelist)
        external
        onlyOwner
        validAddress(_whitelist)
    {
        whiteList = Whitelist(_whitelist);
        emit ChangeExternalAddress(_whitelist, "Whitelist");
    }

    function setWallet(address _wallet)
        external
        onlyOwner
        validAddress(_wallet)
    {
        wallet = _wallet;
        emit ChangeExternalAddress(_wallet, "Wallet");
    }

    function pause() external onlyOwner {
        require(getState() == State.Starting);

        setState(State.Pausing);
    }

    function start() external onlyOwner {
        require(getState() == State.Preparing || getState() == State.Pausing);

        setState(State.Starting);
    }

    function finish() external onlyOwner {
        setState(State.Finished);
    }

    function () external payable {
        address buyer = msg.sender;
        uint256 amount = msg.value;
        address productAddress = address(product);

        require(getState() == State.Starting);
        require(whiteList.whitelist(buyer));
        require(buyer != address(0));
        require(weiRaised[productAddress] < product.maxcap());
        require(buyers[productAddress][buyer] < product.exceed());
        require(buyers[productAddress][buyer].add(amount) >= product.minimum());

        uint256 purchase;
        uint256 refund;
        (purchase, refund) = getPurchaseDetail(buyers[productAddress][buyer], amount, productAddress);

        if(purchase > 0) {
            wallet.transfer(purchase);
            tokenDistributor.addPurchased(buyer, productAddress, purchase.mul(product.rate()), purchase);
            weiRaised[productAddress] = weiRaised[productAddress].add(purchase);
            buyers[productAddress][buyer] = buyers[productAddress][buyer].add(purchase);
        }

        if(refund > 0) {
            buyer.transfer(refund);
        }

        if(weiRaised[productAddress] >= product.maxcap()) {
            setState(State.Finished);
        }

        emit Purchase(buyer, purchase, refund, purchase.mul(product.rate()));
    }

    function getPurchaseDetail(uint256 _raisedAmount, uint256 _amount, address _product)
        private
        view
        returns (uint256, uint256)
    {
        uint256 d1 = product.maxcap().sub(weiRaised[_product]);
        uint256 d2 = product.exceed().sub(_raisedAmount);
        uint256 possibleAmount = (d1.min256(d2)).min256(_amount);

        return (possibleAmount, _amount.sub(possibleAmount));
    }

    function getProductWeiRaised(address _product)
        external
        view
        validAddress(_product)
        returns (uint256)
    {
        return weiRaised[_product];
    }

    function refund(uint256 _id, address _product, address _buyer)
        external
        payable
        validAddress(_product)
        validAddress(_buyer)
    {
        require(msg.sender == wallet);
        require(_id > 0);

        bool isRefund;
        uint256 refundAmount;
        (isRefund, refundAmount) = tokenDistributor.refund(_id, _product, _buyer);

        require(isRefund && refundAmount > 0);

        _buyer.transfer(refundAmount);

        if(address(product) == _product
            && (getState() == State.Starting || getState() == State.Pausing))
        {
            weiRaised[_product] = weiRaised[_product].sub(refundAmount);
            buyers[_product][_buyer] = buyers[_product][_buyer].sub(refundAmount);
        }
    }

    function buyerAddressTransfer(uint256 _id, address _product, address _from, address _to)
        external
        onlyOwner
        validAddress(_product)
        validAddress(_from)
        validAddress(_to)
    {
        require(_id > 0);
        require(whiteList.whitelist(_from));
        require(whiteList.whitelist(_to));
        require(buyers[_product][_from] > 0);
        require(buyers[_product][_to] == 0);

        bool isChanged;
        uint256 transferAmount;
        (isChanged, transferAmount) = tokenDistributor.buyerAddressTransfer(_id, _from, _to);

        require(isChanged && transferAmount > 0);

        buyers[_product][_from] = buyers[_product][_from].sub(transferAmount);
        buyers[_product][_to] = buyers[_product][_to].add(transferAmount);

        emit BuyerAddressTransfer(_from, _to, transferAmount);
    }

    event Purchase(address indexed _buyer, uint256 _purchased, uint256 _refund, uint256 _tokens);
    event ChangeExternalAddress(address _addr, string _name);
    event BuyerAddressTransfer(address indexed _from, address indexed _to, uint256 _amount);
}