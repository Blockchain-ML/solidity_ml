pragma solidity ^0.4.24;

 
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

     
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

     
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

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
        _transfer(msg.sender, to, value);
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
        require(value <= _allowed[from][msg.sender]);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
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

     
    function _transfer(address from, address to, uint256 value) internal {
        require(value <= _balances[from]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

     
    function _mint(address account, uint256 value) internal {
        require(account != 0);
        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

     
    function _burn(address account, uint256 value) internal {
        require(account != 0);
        require(value <= _balances[account]);

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

     
    function _burnFrom(address account, uint256 value) internal {
        require(value <= _allowed[account][msg.sender]);

         
         
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
            value);
        _burn(account, value);
    }
}


contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private minters;

    constructor() internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        minters.remove(account);
        emit MinterRemoved(account);
    }
}

 
contract ERC20Mintable is ERC20, MinterRole {
     
    function mint(
        address to,
        uint256 value
    )
    public
    onlyMinter
    returns (bool)
    {
        _mint(to, value);
        return true;
    }
}
 
contract ERC20Capped is ERC20Mintable {

    uint256 private _cap;

    constructor(uint256 cap)
    public
    {
        require(cap > 0);
        _cap = cap;
    }

     
    function cap() public view returns(uint256) {
        return _cap;
    }

    function _mint(address account, uint256 value) internal {
        require(totalSupply().add(value) <= _cap);
        super._mint(account, value);
    }
}
 
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string name, string symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

     
    function name() public view returns(string) {
        return _name;
    }

     
    function symbol() public view returns(string) {
        return _symbol;
    }

     
    function decimals() public view returns(uint8) {
        return _decimals;
    }
}
 
contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

     
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns(address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

     
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract FSTToken is ERC20Capped,ERC20Detailed {

    constructor(string name, string symbol, uint8 decimals,uint256 cap)
    public
    ERC20Capped(cap)
    ERC20Detailed(name,symbol,decimals)
    {

    }

}
contract FSTTokenHolder is Ownable{

    using SafeMath for uint256;

    address public tokenAddress;

    uint256 public totalUnLockTokens;

    address public agentAddress;

    uint256 public globalLockPeriod;

    uint256 public unlockNum=8;
    mapping (address => HolderSchedule) public holderList;

    event ReleaseTokens(address indexed who,uint256 value);

    struct HolderSchedule {
        uint256 startAt;
        uint256 lockAmount;
        uint256 lockPeriod;
        uint256 releasedAmount;
        uint256 lastUnlocktime;
        bool isReleased;
    }

    constructor(address _tokenAddress ,uint256 _globalLockPeriod) public{
        tokenAddress=_tokenAddress;
        globalLockPeriod=_globalLockPeriod;
    }
    modifier onlyAgent() {
        require(agentAddress==msg.sender);
        _;
    }
    function setAgent(address _adr) public onlyOwner{
        require(_adr!=address(0));
        agentAddress=_adr;
    }
    function setHolder(address _adr,uint256 _lockAmount) public onlyAgent {
        HolderSchedule storage holderSchedule = holderList[_adr];
        require(_lockAmount > 0);
        ERC20 token = ERC20(tokenAddress);
        require(token.balanceOf(this) >= totalUnLockTokens.add(_lockAmount));
        holderSchedule.startAt = block.timestamp;
        holderSchedule.lastUnlocktime=holderSchedule.startAt;
        holderSchedule.lockPeriod = globalLockPeriod.add(holderSchedule.startAt);
        holderSchedule.lockAmount=_lockAmount;
        holderSchedule.isReleased = false;
        holderSchedule.releasedAmount=0;
    }


    function releaseMyTokens() public{
        releaseTokens(msg.sender);
    }

    function releaseTokens(address _adr) public{
        require(_adr!=address(0));
        uint256 unlockAmount=lockStrategy(_adr);
        require(unlockAmount>0);
         
        HolderSchedule storage holderSchedule = holderList[_adr];
        require(holderSchedule.lockAmount>=unlockAmount);
        holderSchedule.lockAmount=holderSchedule.lockAmount.sub(unlockAmount);
        holderSchedule.releasedAmount=holderSchedule.releasedAmount.add(unlockAmount);
        holderSchedule.lastUnlocktime=block.timestamp;
        ERC20 token = ERC20(tokenAddress);
        token.transfer(_adr,unlockAmount);
         
        emit ReleaseTokens(_adr,unlockAmount);
    }
    function lockStrategy(address _adr) private view returns(uint256){
        HolderSchedule memory holderSchedule = holderList[_adr];
        uint256 interval=block.timestamp.sub(holderSchedule.lastUnlocktime);
        uint256 timeNode=globalLockPeriod.div(unlockNum);
        require(interval>=timeNode);
        uint256 mulNum=interval.div(timeNode);
        uint totalAmount=holderSchedule.lockAmount.add(holderSchedule.releasedAmount);
        uint singleAmount=totalAmount.div(unlockNum);
        uint256 unlockAmount=singleAmount.mul(mulNum);
        if(unlockAmount>holderSchedule.lockAmount){
            unlockAmount=holderSchedule.lockAmount;
        }
        return unlockAmount;
    }
    function destory(address _adrs) public onlyOwner returns(bool){
        require(_adrs!=address(0));
        selfdestruct(_adrs);
        return true;
    }
}
contract FSTTokenIssue is Ownable{

    using SafeMath for uint256;

    address public tokenAddress;
    address public fSTTokenHolderAddress;

    uint256 public price;

    mapping (address => bool ) public OWhitelist;
     
    Team[10] public TWhitelist;

    uint256 public OMaxAmount;
    uint256 public OSoldAmount;

    FSTToken private fSTToken;
    FSTTokenHolder private fSTTokenHolder;
    event Buy(address indexed who,uint256 value);

    struct Team{
        address teamAccount;
        uint256 bonusAmount;
    }
    constructor(
        address _tokenAddress,
        uint256 _price,
        uint256 _OMaxAmount,
        address _fSTTokenHolderAddress
    )public {
        tokenAddress=_tokenAddress;
        price=_price;
        OMaxAmount=_OMaxAmount;
        fSTTokenHolderAddress=_fSTTokenHolderAddress;
        fSTToken=FSTToken(tokenAddress);
        fSTTokenHolder=FSTTokenHolder(fSTTokenHolderAddress);
    }

    function setOWhitelist(address[] _accountAddress) public onlyOwner{
        require(_accountAddress.length > 0);
        uint256 _accountAddressCount = _accountAddress.length;
        for (uint256 j=0; j<_accountAddressCount; j++) {
            require(_accountAddress[j] != 0);
            OWhitelist[_accountAddress[j]] = true;
        }
    }
    function removeOWhitelist(address _accountAddress)public onlyOwner{
        require(OWhitelist[_accountAddress]);
        OWhitelist[_accountAddress]=false;
    }

    function setTWhitelist(address[] _tWhitelistAccount,uint256[] _tWhitelistAmount) public onlyOwner{
        require(_tWhitelistAccount.length ==_tWhitelistAmount.length);
        uint256 _tWhitelistCount = _tWhitelistAccount.length;
        for (uint256 i=0; i<_tWhitelistCount; i++) {
            require(_tWhitelistAccount[i] != address(0));
            require(_tWhitelistAmount[i] >0);
            TWhitelist[i].teamAccount=_tWhitelistAccount[i];
            TWhitelist[i].bonusAmount=_tWhitelistAmount[i];
        }
    }

    function removeTWhitelist(address _accountAddress) public onlyOwner{
        require(_accountAddress!=address(0));
        uint256 teamCount = TWhitelist.length;
        for (uint256 i=0; i<teamCount; i++) {
            if(TWhitelist[i].teamAccount==_accountAddress){
                TWhitelist[i].bonusAmount=0;
                break;
            }
        }
    }

    function  provideTeamHolderToken() public onlyOwner{
        require(TWhitelist.length>0);
        uint256 teamCount = TWhitelist.length;
        for (uint256 i=0; i<teamCount; i++) {
            if(TWhitelist[i].bonusAmount > 0){
                accessToken(fSTTokenHolderAddress,TWhitelist[i].bonusAmount);
                fSTTokenHolder.setHolder(TWhitelist[i].teamAccount,TWhitelist[i].bonusAmount);
            }
        }
    }
    function() payable public {
        _invest(msg.sender);
    }
    function buy() public payable {
        _invest(msg.sender);
    }

    function _invest(address _adr) internal {
        require(_adr != address(0));
        require(OWhitelist[_adr]);
        require(price>0);
        uint256 weiAmount = msg.value;
        uint256 tokenAmount=weiAmount.div(price);
        require(tokenAmount>0);
        require(OSoldAmount.add(tokenAmount)<=OMaxAmount);

        OSoldAmount=OSoldAmount.add(tokenAmount);
        accessToken(fSTTokenHolderAddress,tokenAmount);
        fSTTokenHolder.setHolder(_adr,tokenAmount);
        emit Buy(_adr,tokenAmount);
    }
    function accessToken(address rec,uint256 value)private {
        fSTToken.mint(rec,value);
    }

    function destory(address _adrs) public onlyOwner returns(bool){
        require(_adrs!=address(0));
        selfdestruct(_adrs);
        return true;
    }
}