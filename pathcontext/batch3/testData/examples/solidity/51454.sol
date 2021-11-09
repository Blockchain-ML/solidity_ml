pragma solidity ^0.4.24;

 
 
 
 
 
 
 



 
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


 
contract Ownable {
    address public owner;
    constructor() public{
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

     

}


 
contract Pausable is Ownable {

    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused {
        require(!paused);
        _;
    }
    modifier whenPaused {
        require(paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused returns (bool) {
        paused = true;
        emit Pause();
        return true;
    }
    function unpause() public onlyOwner whenPaused returns (bool) {
        paused = false;
        emit Unpause();
        return true;
    }

}


 
contract Dealershipable is Ownable {

    mapping(address => bool) public dealership;

    event Trust(address dealer);
    event Distrust(address dealer);

     
    modifier onlyDealers() {
        require(dealership[msg.sender]);
        _;
    }

    function trust(address _newDealer) public onlyOwner {
        require(_newDealer != address(0));
        require(!dealership[_newDealer]);
        dealership[_newDealer] = true;
        emit Trust(_newDealer);
    }

    function disTrust(address _dealer) public onlyOwner {
        require(dealership[_dealer]);
        dealership[_dealer] = false;
        emit Distrust(_dealer);
    }

}





 
contract ERC20 {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function totalSupply() public view returns (uint256);
    function balanceOf(address _owner) public view returns (uint256);

     
    function transfer(address _to, uint256 _value) public returns (bool);
     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
     
    function approve(address _spender, uint256 _value) public returns (bool);
     
    function allowance(address _owner, address _spender) public view returns (uint256);

}


 
contract ERC20Token is ERC20 {

    using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    uint256 public totalToken;

    function totalSupply() public view returns (uint256){
        return totalToken;
    }
    function balanceOf(address _owner) public view returns (uint256){
        return balances[_owner];
    }
    function transfer(address _to, uint256 _value) public returns (bool){
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
        require(balances[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public returns (bool){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) public view returns (uint256){
        return allowed[_owner][_spender];
    }
}


 
contract LVECoinDemo is ERC20Token, Pausable, Dealershipable {

     
    string public  constant name                = "LVECoinDemo";
     
    string public  constant symbol              = "LVEDemo";
     
    uint256 public constant decimals            = 18;
     
    uint256 public initialToken                 = 2000000000 * (10 ** decimals);


    event Mint(address indexed dealer, address indexed to, uint256 value);
    event Burn(address indexed _burner, uint256 _value);
    event Lock(address indexed locker, uint256 value, uint releaseTime);
    event UnLock(address indexed unlocker, uint256 value);
    


     
    mapping(address => uint256) public releaseTimes;
     
    mapping(address => bool) public lockAddresses;
     
    struct LockStatus{
        uint256 releaseTime;
        address lockAddr;
        bool isLock;
    }
    LockStatus[] public lockStatus;

     
     
     
    uint256 public privatePlacingToken  = initialToken * 400 / 1000;
     
    uint256 public foundingTeamToken    = initialToken * 200 / 1000;
     
     
    uint256 public crowdsaleToken        = initialToken * 400 / 1000;


     
     
     
    address public  privatePlacingAddr  = 0x9089612b984A1eC4B34EefF78B9Df5fC955130CF;
     
    address public  foundingTeamAddr    = 0x708ce7c6d547Cbd4C7fD889619c50e9d55471ED7;
     
     
    address public  crowdsaleAddr       = 0xC1903bA9032F5C163Fe0881Ed360c499F226975b;



    constructor() public{
         
        totalToken = initialToken;
         
        balances[msg.sender] = totalToken;

         
         
         
        balances[foundingTeamAddr] = foundingTeamToken;
         
        lockAddresses[foundingTeamAddr] = true;
         
        releaseTimes[foundingTeamAddr] = 1531728000;  

        LockStatus memory lockPerson;
        lockPerson.releaseTime = 1531728000;
        lockPerson.lockAddr = foundingTeamAddr;
        lockPerson.isLock = true;
        lockStatus.push(lockPerson);

         
        balances[privatePlacingAddr] = privatePlacingToken;

         
         
        balances[crowdsaleAddr] = crowdsaleToken;

        emit Transfer(0x0, foundingTeamAddr, foundingTeamToken);
        emit Transfer(0x0, privatePlacingAddr, privatePlacingToken);
        emit Transfer(0x0, crowdsaleAddr, crowdsaleToken);

    }


     
    modifier transferable(address _addr) {
        require(!lockAddresses[_addr]);
        _;
    }


     
     
     
    function transfer(address _to, uint256 _value) public whenNotPaused transferable(msg.sender) returns (bool) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public transferable(msg.sender) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
    function approve(address _spender, uint256 _value) public whenNotPaused transferable(msg.sender) returns (bool) {
        return super.approve(_spender, _value);
    }



     
     
     
     
    function mintLVE(address _to, uint256 _amount, uint256 _releaseTime) public whenNotPaused onlyDealers returns(bool){

        require(balances[msg.sender] >= _amount);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);

         
        lockAddresses[_to] = true;
         
        releaseTimes[_to] = _releaseTime;

         
        LockStatus memory lockPerson;
        lockPerson.releaseTime = _releaseTime;
        lockPerson.lockAddr = _to;
        lockPerson.isLock = true;
         
        lockStatus.push(lockPerson);

        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

     
    function getUnlockTime(address _addr) public view returns (uint256) {
        return releaseTimes[_addr];
    }


     
    function unlockAddr() public onlyOwner {
         
        uint256 lockStatusLength = lockStatus.length;
        for (uint i = 0; i < lockStatusLength; i++) {
              LockStatus memory lockPerson = lockStatus[i];
              if (now > lockPerson.releaseTime) {
                  lockPerson.isLock = false;
                  lockAddresses[lockPerson.lockAddr] = false;
                  releaseTimes[lockPerson.lockAddr] = 0;
              }
        }
    }

}