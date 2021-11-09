pragma solidity ^0.4.22;

library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns(uint256 c) {
         
         
         
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
         
         
         
        return a / b;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

     
    function add(uint256 a, uint256 b) internal pure returns(uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

 
contract Ownable {
    
    address public owner;
  
     
    constructor() public {
        owner = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

     
    modifier whenNotPaused() {
        require(!paused, "Contract Paused. Events/Transaction Paused until Further Notice");
        _;
    }

     
    modifier whenPaused() {
        require(paused, "Contract Functionality Resumed");
        _;
    }

     
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

     
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract ERC20Interface {
    
    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}
contract Staking is Pausable, ERC20Interface {
    using SafeMath for uint;
    
    uint BIGNUMBER = 10**18;
    uint DECIMAL = 10**3;
    
    

    struct stakingInfo {
        uint amount;
        uint age;
        address userAddress;
        uint time;
    }
     
    mapping (address => uint256) balances;
    mapping (address => bool) public allowedTokens;
    mapping (address => mapping(address => stakingInfo)) public StakeMap;
    mapping (address => mapping(address => uint)) public userCummRewardPerStake;  
    mapping (address => uint) public tokenCummRewardPerStake;  
    mapping (address => uint) public tokenTotalStaked;  
    mapping (address => mapping (address => uint256)) internal allowed;
        
    event claimed(uint amount);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    address public StakeTokenAddr;
    
    modifier isValidToken(address _tokenAddr){
        require(allowedTokens[_tokenAddr]);
        _;
    }
    
    constructor() public{
        StakeTokenAddr= 0x53981b4004fe67fb3d0da666d635fddadeed5cf8;
    }
    ERC20Interface t = ERC20Interface(StakeTokenAddr);
    function addToken( address _tokenAddr) onlyOwner external {
        allowedTokens[_tokenAddr] = true;
    }
    
     
    function removeToken( address _tokenAddr) onlyOwner external {
        allowedTokens[_tokenAddr] = false;
    }
    function stake(uint _amount, address _tokenAddr, uint256 _age ) isValidToken(_tokenAddr) external returns (bool){
        require(_amount != 0);
         
        if(_amount < 10000)
            throw;
        if(getBalance(msg.sender)<10000)
            throw;
            
        StakeMap[_tokenAddr][msg.sender].amount = _amount;
        StakeMap[_tokenAddr][msg.sender].age = _age;
        StakeMap[_tokenAddr][msg.sender].userAddress = msg.sender;
        StakeMap[_tokenAddr][msg.sender].time = now;
        
        t.transferFrom(msg.sender, _tokenAddr, _amount);
         
         
         
         
         
         
         
         
        return true;
    }
     
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

     
    function balanceOf(address _owner) public view whenNotPaused returns (uint256) {
        return balances[_owner];
    }

    function getBalance(address tokenAddress) public view whenNotPaused returns (uint){
        uint bal = balanceOf(tokenAddress);
        return bal;
    }

     
    function transferFrom( address _from, address _to, uint256 _value ) public whenNotPaused returns (bool) {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function allowance(address _owner, address _spender) public view whenNotPaused returns (uint256) {
        return allowed[_owner][_spender];
    }

     
    function increaseApproval( address _spender, uint256 _addedValue ) public whenNotPaused returns (bool) {
        allowed[msg.sender][_spender] = ( allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

     
    function decreaseApproval( address _spender, uint256 _subtractedValue ) public whenNotPaused returns (bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }



    function stakingBonus(uint256 ETH_profit, uint256 userToken, uint256 totalToken) returns (uint256){
        return (ETH_profit * (userToken/totalToken));
    }
    function claim(address _tokenAddr, address _receiver) isValidToken(_tokenAddr)  public returns (uint) {
        uint stakedAmount = StakeMap[_tokenAddr][msg.sender].amount;
         
        uint amountOwedPerToken = tokenCummRewardPerStake[_tokenAddr].sub(userCummRewardPerStake[_tokenAddr][msg.sender]);
        uint claimableAmount = stakedAmount.mul(amountOwedPerToken);  
        claimableAmount = claimableAmount.mul(DECIMAL);  
        claimableAmount = claimableAmount.div(BIGNUMBER);  
        userCummRewardPerStake[_tokenAddr][msg.sender]=tokenCummRewardPerStake[_tokenAddr];
         
         
         
         
         
        emit claimed(claimableAmount);
        return claimableAmount;

    }
     
}