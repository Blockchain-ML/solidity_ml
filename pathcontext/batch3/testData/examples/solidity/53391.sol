pragma solidity ^0.4.21;
 
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

 
contract Ownable {
    address public owner;
    address public Publisher;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event PublisherTransferred(address indexed Publisher, address indexed newPublisher);

     
    function Ownable() public {
        owner = msg.sender;
        Publisher = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

     

    function OwnerAddress() public view returns(address){
        return owner;
    }

     
    function transferPublisher(address newPublisher) public onlyOwner {
        emit PublisherTransferred(Publisher, newPublisher);
        Publisher = newPublisher;
    }

     

    function PublisherAddress() public view returns(address){
        return Publisher;
    }

}


 
contract YDHTOKEN is Ownable{
    using SafeMath for uint256;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    event Setlockaddress(address indexed target, bool lock);
    event Setlockall(bool lock);

    mapping(address => uint256) balances;
    mapping(address => bool) public lockaddress;    
    mapping (address => mapping (address => uint256)) internal allowed;

    uint256 public totalSupply;
    bool public mintingFinished = false;
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    bool public lockall = true;

    function YDHTOKEN (
        string name_,
        string symbol_,        
        uint256 totalSupply_
    ) public {
        name = name_;
        symbol = symbol_;
        totalSupply = totalSupply_ * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
    }

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    modifier hasMintPermission() {
        require(msg.sender == owner);
        _;
    }

     
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
        require(!lockaddress[msg.sender]);
        if((msg.sender != address(0)) && (msg.sender != PublisherAddress()) && lockall){
            revert();
        } 

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(!lockaddress[msg.sender]);
        if((msg.sender != address(0)) && (msg.sender != PublisherAddress()) && lockall){
            revert();
        } 

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
        require(!lockaddress[msg.sender]);
        if((msg.sender != address(0)) && (msg.sender != PublisherAddress()) && lockall){
            revert();
        } 

        return allowed[_owner][_spender];
    }

     
    function increaseApproval(
        address _spender,
        uint _addedValue
    )
        public
        returns (bool)
    {
        require(!lockaddress[msg.sender]);
        if((msg.sender != address(0)) && (msg.sender != PublisherAddress()) && lockall){
            revert();
        } 
        
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

     
    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
        public
        returns (bool)
    {
        require(!lockaddress[msg.sender]);
        if((msg.sender != address(0)) && (msg.sender != PublisherAddress()) && lockall){
            revert();
        }

        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

     
    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }

     
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(!lockaddress[msg.sender]);
        if((msg.sender != address(0)) && (msg.sender != PublisherAddress()) && lockall){
            revert();
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

     
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

     
    function burn(address _who, uint256 _value) onlyOwner public {
        _burn(_who, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who]);
         
         

        balances[_who] = balances[_who].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }

     
    function mint(
        address _to,
        uint256 _amount
    )
        hasMintPermission
        canMint
        public
        returns (bool)
    {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

     
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }

     
    function setlockaddress(address target, bool lock) onlyOwner public {
        lockaddress[target] = lock;
        emit Setlockaddress(target, lock);
    }

     
    function setlockall(bool lock) onlyOwner public {
        lockall = lock;
        emit Setlockall(lock);
    }    

}


 
contract Crowdsale is Ownable{
    using SafeMath for uint256;

     
    YDHTOKEN public token;

     
    address public wallet;

     
    mapping(address => bool) public whitelist;

     
    bool public startico = false;

     
     
     
     
    uint256 public rate;

     
    uint256 public weiRaised;

     
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    event ICOStatus(
        bool _startico
    );

     
    function Crowdsale (uint256 _rate, address _wallet, YDHTOKEN _token) public {
        require(_rate > 0);
        require(_wallet != address(0));
        require(_token != address(0));

        rate = _rate;
        wallet = _wallet;
        token = _token;
    }

     
     
     

     
    function () external payable {
        buyTokens(msg.sender);
    }

     
    function buyTokens(address _beneficiary) public payable {

        uint256 weiAmount = msg.value;
        require(startico);
        require(_beneficiary != address(0));
        require(weiAmount != 0);
        require(isWhitelisted(_beneficiary));

         
        uint256 tokens = _getTokenAmount(weiAmount);

         
        weiRaised = weiRaised.add(weiAmount);

        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase(
            msg.sender,
            _beneficiary,
            weiAmount,
            tokens
        );

        _forwardFunds();
    }

     
    function _deliverTokens(
        address _beneficiary,
        uint256 _tokenAmount
    )
        internal
    {
        token.transfer(_beneficiary, _tokenAmount);
    }

     
    function _processPurchase(
        address _beneficiary,
        uint256 _tokenAmount
    )
        internal
    {
        _deliverTokens(_beneficiary, _tokenAmount);
    }


     
    function _getTokenAmount(uint256 _weiAmount)
        internal view returns (uint256)
    {
        return _weiAmount.mul(rate);
    }

     
    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }

     
    function isWhitelisted(address _beneficiary) public view returns(bool){
        bool check;
        check = whitelist[_beneficiary];

        return check;
    }

     
    
    function addToWhitelist(address _beneficiary) external onlyOwner {
        whitelist[_beneficiary] = true;
    }

     
    function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = true;
        }
    }

     
    function removeFromWhitelist(address _beneficiary) external onlyOwner {
        whitelist[_beneficiary] = false;
    }

     
    function startstopICO(bool _startstop) public onlyOwner {        
        startico = _startstop;
    }

     
    function returnTokenToWallet() public onlyOwner {        
        _processPurchase(OwnerAddress(), token.balanceOf(this));        
    }

     
    function deletThisContract() public onlyOwner {        
        selfdestruct(OwnerAddress());
    }

}