 
 
 

pragma solidity 0.4.24;

 
 
 
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


 
 
 
 
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

 
 
 
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public 
    onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

 
 
 
contract Lock is Owned{
    
     
    bool public isGlobalLocked;
     
    mapping( address => bool) public isAddressLockedMap;

    event AddressLocked(address lockedAddress);
    event AddressUnlocked(address unlockedaddress);
    event GlobalLocked();
    event GlobalUnlocked();

     
    modifier checkGlobalLocked {
        require(!isGlobalLocked);
        _;
    }

     
    modifier checkAddressLocked {
        require(!isAddressLockedMap[msg.sender]);
        _;
    }

    function lockGlobalToken() public
    onlyOwner
    returns (bool)
    {
        isGlobalLocked = true;
        return isGlobalLocked;
        emit GlobalLocked();
    }

    function unlockGlobalToken() public
    onlyOwner
    returns (bool)
    {
        isGlobalLocked = false;
        return isGlobalLocked;
        emit GlobalUnlocked();
    }

    function lockAddressToken(address target) public
    onlyOwner
    returns (bool)
    {
        isAddressLockedMap[target] = true;
        emit AddressLocked(target);
        return isAddressLockedMap[target];
    }

    function unlockAddressToken(address target) public
    onlyOwner
    returns (bool)
    {
        isAddressLockedMap[target] = false;
        emit AddressUnlocked(target);
        return isAddressLockedMap[target];
    }
    
}

contract Reward is Owned{
    struct RewardHistory{
        string caller;
        string callee;
        uint256 tokenAmount;
    }
    
    mapping(address => RewardHistory[]) public rewardHistoryMap;
    address[] public routerArray;
    
    function addRouter(address target) public
    onlyOwner
    returns (bool){
        routerArray.push(target);
        return true;
    }
    
    uint randNonce = 0;

    function getRandomRouter() public
    returns (address){
        uint random = uint(keccak256(now, msg.sender, randNonce)) % routerArray.length;
        randNonce++;
        return routerArray[random];
    }
}

 
 
 
 
contract RasolTest03 is ERC20Interface, Owned, SafeMath, Lock, Reward {
    string public symbol;
    string public  name;
    uint8 public decimals = 18;
     
    uint256 public totalSupply;

    mapping(address => uint) balances;
    mapping(address => uint) balances2;

    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) rewardHistoryLengthArray;
    
    event Burn();



     
     
     
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        symbol = tokenSymbol;
        name = tokenName;
        totalSupply = initialSupply;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }


     
     
     
    function totalSupply() public constant returns (uint) {
        return totalSupply;
    }


     
     
     
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


     
     
     
     
     
    function transfer(address to, uint tokens) public  
    checkGlobalLocked
    checkAddressLocked
    returns (bool success){
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, uint tokens) public 
    checkGlobalLocked
    returns (bool success) {
         
        require(!isAddressLockedMap[from]);
        
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


     
     
     
     
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

     
     
     
    function () public payable {
    }
    
     
     
     
    function burn(uint256 tokens) public
    onlyOwner
    returns (bool)
    {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        totalSupply = safeSub(totalSupply, tokens);
        emit Burn();
        
        return true;
    }
    
     
     
     
    function callAndReward(string caller, string callee, uint256 amount) public
    returns (address rewardedRouter){
        address targetRouter = getRandomRouter();
        balances[msg.sender] = safeSub(balances[msg.sender], amount);
        balances[targetRouter] = safeAdd(balances[targetRouter], amount);
        rewardHistoryMap[targetRouter].push(RewardHistory(caller, callee, amount));
        rewardHistoryLengthArray[targetRouter] = safeAdd(rewardHistoryLengthArray[targetRouter], 1);
        emit Transfer(msg.sender, targetRouter, amount);
        
        return targetRouter;
    }
    
     
     
     
     
        
     
     
     
     
    
    function rewardHistoryLengthOf(address target) public constant returns(uint256){
        return rewardHistoryMap[target].length;
    }
    
    function rewardHistoryMapOf(address target, uint256 index) public constant returns(string caller, string callee, uint256 amount){
        return (rewardHistoryMap[target][index].caller, rewardHistoryMap[target][index].callee, rewardHistoryMap[target][index].tokenAmount);
    }
    
    function getAllRouter() public constant returns(address[]){
        return routerArray;
    }
    
     
        
     
    
    function getRewardHistory(address target) public constant returns (bytes32[] caller, bytes32[] callee, uint256[] amount){
        bytes32[] memory callerData = new bytes32[](10);
        bytes32[] memory calleeData = new bytes32[](10);
        uint[] memory amountData = new uint[](10);
        
        uint j = 0;
        for(uint i = rewardHistoryMap[target].length - 1 ; i >= 0 ; i--){
            callerData[j] = stringToBytes32(rewardHistoryMap[target][i].caller);
            calleeData[j] = stringToBytes32(rewardHistoryMap[target][i].callee);
            amountData[j] = rewardHistoryMap[target][i].tokenAmount;
            j++;
            if(i==0 || j>9){
                break;
            }
        }
        
        return (callerData, calleeData, amountData);
    }
    
    function stringToBytes32(string memory source) returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(source, 32))
        }
    }

}