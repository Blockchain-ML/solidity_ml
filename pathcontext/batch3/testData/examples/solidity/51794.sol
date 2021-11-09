pragma solidity ^0.4.24;

 

 
contract IERC20 {
 
    function totalSupply() public view returns(uint256);

 
    function balanceOf(address _who) public view returns(uint256);

 
    function allowance(address _owner, address _spender) public view returns(uint256);

 
    function transfer(address _to, uint256 _value) public returns(bool);

 
    function approve(address _spender, uint256 _value) public returns(bool);

 
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool);

 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

 

 
library SafeMath {

 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0){
            return a;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    } 
 

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "b must be larger than zero");
        uint256 c = a / b;
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "b must be lower than a");
        uint256 c = a - b;
        return c;
    }
 
    function add(uint256 a, uint256 b) internal pure returns (uint256){
        uint256 c = a + b;
        require(c >= a, "c must be larger than a");
        return c;
    }

 
    function mod(uint256 a, uint256 b) internal pure returns (uint256){
        require(b!=0,"b can not equal to zero");
        return a % b;
    }

}

 

 
contract ERC20 is IERC20 {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 _totalSupply;

 
    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

 
    function balanceOf(address owner) public view returns(uint256){
        return _balances[owner];
    }

 
    function allowance(address owner, address spender) public view returns(uint256){
        return _allowed[owner][spender];
    }

 
    function transfer(address to, uint256 value) public returns(bool){
        require(to != address(0), "Invalid address");        
        require(value <= _balances[msg.sender], "Balance is not enough");

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value); 
        return true;
    }

 
    function approve(address spender,uint256 value) public returns (bool){
        require(spender != address(0), "Invalid address");

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

 
    function transferFrom(address from, address to, uint256 value) public returns(bool){
        require(to != address(0), "Invalid address");
        require(value <= _balances[from],"Not enough balance");
        require(value <= _allowed[from][msg.sender], "Allowed balance is not enough");
        

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return true;
    }

  
    function increaseAllowance(address spender, uint256 addedValue) public returns(bool){
        require(spender != address(0),"Invalid address");

        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

 
    function decreaseAllowed(address spender, uint256 subtractedValue) public returns(bool){
        require(spender != address(0),"Invalid address");

        uint256 oldValue = _allowed[msg.sender][spender];
        if (subtractedValue > oldValue) {
            _allowed[msg.sender][spender] = 0;
        } else {
            _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        }

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

 
    function _mint(address account, uint256 amount) internal {
        require(account != address(0),"Invalid address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

 
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "Invalid address");
        require(amount <= _balances[account], "Amount is incorrect");
        
        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
    }

 
    function _burnFrom(address account, uint256 amount) internal {
        require(amount <= _allowed[account][msg.sender],"Amount is incorrect");
         
         
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
        _burn(account, amount);
    }
    
}

 

 
contract ERC20Burnable is ERC20 {

 
    function burn(uint256 value) public {
        _burn(msg.sender, value);   
    }

 
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }

 
    function _burn(address who, uint256 value) internal {
        super._burn(who, value);
    }

}

 

 
contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 
    constructor() public{
        _owner = msg.sender;
    }

 
    function owner() public view returns(address){
        return _owner;
    }

 
    modifier onlyOwner(){
        require(isOwner(), "msg.sender is not the onwer of this contract");
        _;
    }

 
    function isOwner() public view returns(bool){
        return msg.sender == _owner;
    }

 
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

 
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

 
    function _transferOwnership(address newOwner) internal{
        require(newOwner != address(0), "Address incorrect");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
}

 

contract Pausable {
    event Paused();
    event Unpaused();

    bool private _paused = false;

 
    function paused() public view returns(bool) {
        return _paused;
    }

 
    modifier whenNotPaused(){
        require(!_paused,"Contract is paused");
        _;
    }

 
    modifier whenPaused(){
        require(_paused,"Contract is not paused");
        _;
    }

 
    function pause() public  whenNotPaused {
        _paused = true;
        emit Paused();
    }

 
    function unpause() public  whenPaused {
        _paused = false;
        emit Unpaused();
    }
}

 

 
contract ICOToken is ERC20, ERC20Burnable, Pausable, Ownable {

 
    string private  _name;
    string private  _symbol;
    uint8  private _decimals;

 
    address public _tokenSaleContract;

 
    modifier notTokenAddress(address _to) {
        require(_to != address(this),"Invalid address");
        _;
    }

    modifier isAllowedTransferable(){  
        require(!paused() || msg.sender == owner() || msg.sender == _tokenSaleContract, "Token is not transferable");
        _;
    }

 
    constructor(string name, string symbol, uint8 decimals, address adminAddress, uint256 totalSupply) 
    public
    notTokenAddress(adminAddress)
    {
        require(adminAddress != address(0), "`Invaid address");
        require(decimals > 0, "Invalid decimals");
        require(totalSupply > 0, "Invalid supply amount");
        _name = name;
        _symbol = symbol;
        _decimals = decimals;

        _mint(msg.sender, totalSupply);
        _tokenSaleContract = msg.sender;
        transferOwnership(adminAddress);
    }

 
    function transfer(address to,uint256 value)
    public
    isAllowedTransferable
    notTokenAddress(to)
    returns (bool){
        return super.transfer(to, value);
    }

 
    function approve(address spender,uint256 value) 
    public
    isAllowedTransferable
    notTokenAddress(spender) 
    returns (bool){
        return super.approve(spender, value);
    }

 
    function transferFrom(address from, address to, uint256 value)
    public
    isAllowedTransferable
    notTokenAddress(to)
    returns(bool){
        return super.transferFrom(from, to, value);
    }

 
    function increaseAllowance(address spender, uint256 addedValue) 
    public 
    isAllowedTransferable
    notTokenAddress(spender)
    returns(bool) {
        return super.increaseAllowance(spender, addedValue);
    }

 
    function decreaseAllowed(address spender, uint256 subtractedValue) 
    public
    isAllowedTransferable
    notTokenAddress(spender) 
    returns(bool){
        super.decreaseAllowed(spender,subtractedValue);
    }

 
    function pause() 
    public
    onlyOwner  
    whenNotPaused {
        super.pause();
    }

 
    function unpause() 
    public
    onlyOwner
    whenPaused {
        super.unpause();
    }

     
    function name() public view returns(string){
        return _name;
    }
    
 
    function symbol() public view returns(string){
        return _symbol;
    }

 
    function decimals() public view returns(uint8){
        return _decimals;
    }
}

 

contract ContributorList is Ownable {

    using SafeMath for uint256;

    
    mapping(address => bool) public _whiteListAddresses;
    mapping(address => uint256)  public _contributors;

    uint256 public _minContribution;  
    uint256 public _maxContribution;  
    address public _adminAddress;

    modifier onlyAdmin(){
        require(msg.sender == _adminAddress, "Permision denied");
        _;
    }

    constructor(uint256 minContribution, uint256 maxContribution, address adminAddress) public {
        require(minContribution > 0, "Invalid MinContribution");
        require(maxContribution > 0, "Invalid MaxContribution");
        _minContribution = minContribution;
        _maxContribution = maxContribution;
        _adminAddress = adminAddress;
    }

    event UpdateWhiteList(address user, bool isAllowed, uint256 time );

 
    function updateWhiteList(address user, bool isAllowed) 
    public
    onlyAdmin{
        _whiteListAddresses[user] = isAllowed;
        emit UpdateWhiteList(user,isAllowed, block.timestamp);
    }

 
    function updateWhiteLists(address[] users, bool[] isAlloweds)
    public
    onlyAdmin{
        for (uint i = 0 ; i < users.length ; i++) {
            address _user = users[i];
            bool _allow = isAlloweds[i];
            _whiteListAddresses[_user] = _allow;
            emit UpdateWhiteList(_user, _allow, block.timestamp);
        }
    }

 
    function getEligibleAmount(address contributor, uint256 amount) public view returns(uint256){
        
        if(amount < _minContribution){
            return 0;
        }

        uint256 contributorMaxContribution = _maxContribution;
        uint256 remainingCap = contributorMaxContribution.sub(_contributors[contributor]);

        return (remainingCap > amount) ? amount : remainingCap;
    }

 
    function increaseContribution(address contributor, uint256 amount)
    internal
    returns(uint256)
    {
        if(!_whiteListAddresses[contributor]){
            return 0;
        }
        uint256 result = getEligibleAmount(contributor,amount);
        _contributors[contributor] = _contributors[contributor].add(result);
        return result;
    }


}

 

contract CrowdSale is ContributorList, Pausable {
    using SafeMath for uint256;

    address public _multiSigWallet;
    address public _adminAddress;
    ICOToken public _token;

    uint256 public _openingTime;
    uint256 public _closingTime;
     
     
    uint256 public _tokenExchangeRate;

    uint256 public _raisedWei;



    event TokenBuy(address from, uint256 token, uint256 payedWee);

 
    modifier isValidAdress(address who){
        require(who != address(0),"Invalid address");
        require(who != address(this), "Invalid address");
        _;
    }

 
    modifier onlyWhileOpen {
        require(isOpen(),"Crowdsale is not open");
        _;
    }


    constructor (string name, 
                string  symbol, 
                uint8   decimals, 
                address adminAddress, 
                uint256 totalSupply,
                uint256 permitedTokenSupply,
                uint256 presaleTokenSupply,
                uint256 minContribution,
                uint256 maxContribution,
                address multiSigWallet,
                uint256 openingTime,
                uint256 closingTime,
                uint256 tokenExchangeRate)
        isValidAdress(adminAddress)
        isValidAdress(multiSigWallet)
        ContributorList(minContribution, maxContribution, adminAddress)
    public
    {
        require(openingTime > block.timestamp, "Invalid opening time");
        require(closingTime > openingTime, "Invalid closing time");
        require(tokenExchangeRate > 0, "Invalid token exchange rate");
        require(permitedTokenSupply > 0, "Invalid permited token supplu");
        require(presaleTokenSupply > 0, "Invalid presale token supply");

        _multiSigWallet = multiSigWallet;
        _adminAddress = adminAddress;
        _openingTime = openingTime;
        _closingTime = closingTime;
        _tokenExchangeRate = tokenExchangeRate;

        _token = new ICOToken (name, symbol, decimals, adminAddress, totalSupply);

        _token.transfer(_multiSigWallet, permitedTokenSupply);
        _token.transfer(adminAddress, presaleTokenSupply);
    }


 

    function() public payable{
        buy(msg.sender);
    }

 
    function buy(address beneficiary)
    public
    payable
    whenNotPaused
    onlyWhileOpen
    isValidAdress(beneficiary)
    returns(uint256){

        uint256 weiContributionAllowed = increaseContribution(beneficiary, msg.value);
        require(weiContributionAllowed > 0, "Contribution is maximum");

        uint256 crowdsaleTokenRemaining = _token.balanceOf(address(this));

        uint256 receiveTokens = weiContributionAllowed.mul(_tokenExchangeRate);

        if(receiveTokens > crowdsaleTokenRemaining){
            receiveTokens = crowdsaleTokenRemaining;
            weiContributionAllowed = crowdsaleTokenRemaining.div(_tokenExchangeRate);
        }

        assert(_token.transfer(beneficiary,receiveTokens));

        if(msg.value > weiContributionAllowed) {
            msg.sender.transfer(msg.value.sub(weiContributionAllowed));
        }

        emit TokenBuy(beneficiary, receiveTokens, weiContributionAllowed);
        
        _raisedWei = _raisedWei.add(weiContributionAllowed);

        _multiSigWallet.transfer(weiContributionAllowed);

        return weiContributionAllowed;
    }


 
    function emergencyWithdraw() 
    public 
    onlyAdmin
    returns(bool){
        if(address(this).balance > 0){
            _multiSigWallet.transfer(address(this).balance);
        }
        _token.transfer(_multiSigWallet, _token.balanceOf(this));
        return true;
    }


 
    function multiSigWallet() public view returns(address){
        return _multiSigWallet;
    }    

 
    function openingTime() public view returns(uint256) {
        return _openingTime;
    }

 
    function closingTime() public view returns(uint256) {
        return _closingTime;
    }

 
    function isOpen() public view returns (bool) {
         
        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

 
    function hasClosed() public view returns (bool) {
         
        return block.timestamp > _closingTime;
    }

 
    function tokenExchangeRate() public view returns(uint256){
        return _tokenExchangeRate;
    }

 
    function raisedWei() public view returns(uint256){
        return _raisedWei;
    }

}