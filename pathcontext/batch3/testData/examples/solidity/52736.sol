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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    function Ownable() public {
        owner = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

 
contract ERC223 {
    uint public totalSupply;

     
    function balanceOf(address who) public view returns (uint);
    function totalSupply() public view returns (uint256 _supply);
    function transfer(address to, uint value) public returns (bool ok);
    function transfer(address to, uint value, bytes data) public returns (bool ok);
    function transfer(address to, uint value, bytes data, string customFallback) public returns (bool ok);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);

     
    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
    function decimals() public view returns (uint8 _decimals);

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

 
 contract ContractReceiver {

    struct TKN {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }

    function tokenFallback(address _from, uint _value, bytes _data) public pure {
        TKN memory tkn;
        tkn.sender = _from;
        tkn.value = _value;
        tkn.data = _data;
        uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
        tkn.sig = bytes4(u);
        
         
    }
}

 
contract ShiitakeCoin is ERC223, Ownable {
    using SafeMath for uint256;

    string  public name = "ShiitakeCoin";
    string  public symbol = "SHTKC";
    bool    public mintingFinished = false;
    uint8   public decimals = 8;
    uint256 public totalInitialSupply = 20e6 * 1e8;
    uint256 public totalSupply;
    uint256 public maxTotalSupply = 10e7 * 1e8;
    uint256 public distributeAmount = 0;
    uint256 public chainStartTime;  
    uint256 public chainStartBlockNumber;  
    uint256 public stakeStartTime;  
    uint256 public stakeMinAge = 3;  
    uint256 public stakeMaxAge = 90;  
    uint256 public overStakeAge = 180;  
    uint256 public maxMintProofOfStake = 5**7;  
    address[] public coinHaving;
    
    struct transferInStruct{
      uint128 amount;
      uint64 time;
    }

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public unlockUnixTime;
    mapping(address => bool) public frozenAccount;
    mapping(address => mapping (address => uint256)) public allowance;
    mapping(address => transferInStruct[]) transferIns;
    
    event FrozenFunds(address indexed target, bool frozen);
    event LockedFunds(address indexed target, uint256 locked);
    event Burn(address indexed from, uint256 amount);
    event MintFinished();
    event Mint(address indexed _address, uint _reward);

     
    constructor () public {
        chainStartTime = now;
        stakeStartTime = now;
        chainStartBlockNumber = block.number;

        balanceOf[msg.sender] = totalInitialSupply;
        totalSupply = totalInitialSupply;
    }

    function name() public view returns (string _name) {
        return name;
    }

    function symbol() public view returns (string _symbol) {
        return symbol;
    }

    function decimals() public view returns (uint8 _decimals) {
        return decimals;
    }

    function totalSupply() public view returns (uint256 _totalSupply) {
        return totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOf[_owner];
    }

     
    function arrayIndexOf(address[] _addresses, address _address) pure public returns(uint) {
    for (uint i = 0; i < _addresses.length; i++) {
        if (_addresses[i] == _address)
            return i;      
    }
    return 9999999999;
    }

     
    function freezeAccounts(address[] targets, bool isFrozen) onlyOwner public {
        require(targets.length > 0);

        for (uint i = 0; i < targets.length; i++) {
            require(targets[i] != 0x0);
            frozenAccount[targets[i]] = isFrozen;
            FrozenFunds(targets[i], isFrozen);
        }
    }

     
    function lockupAccounts(address[] targets, uint[] unixTimes) onlyOwner public {
        require(targets.length > 0
                && targets.length == unixTimes.length);
                
        for(uint i = 0; i < targets.length; i++){
            require(unlockUnixTime[targets[i]] < unixTimes[i]);
            unlockUnixTime[targets[i]] = unixTimes[i];
            LockedFunds(targets[i], unixTimes[i]);
        }
    }

     
    function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
        require(_value > 0
                && frozenAccount[msg.sender] == false 
                && frozenAccount[_to] == false
                && now > unlockUnixTime[msg.sender] 
                && now > unlockUnixTime[_to]);

        if (arrayIndexOf(coinHaving, _to) != 9999999999)
            coinHaving.push(_to);

        if (isContract(_to)) {
            require(balanceOf[msg.sender] >= _value);
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
            balanceOf[_to] = balanceOf[_to].add(_value);
            assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
            Transfer(msg.sender, _to, _value, _data);
            Transfer(msg.sender, _to, _value);

            if(transferIns[msg.sender].length > 0)
                delete transferIns[msg.sender];
            uint64 _now = uint64(now);
            transferIns[msg.sender].push(transferInStruct(uint128(balanceOf[msg.sender]),_now));
            transferIns[_to].push(transferInStruct(uint128(_value),_now));
            return true;
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

    function transfer(address _to, uint _value, bytes _data) public  returns (bool success) {
        require(_value > 0
                && frozenAccount[msg.sender] == false 
                && frozenAccount[_to] == false
                && now > unlockUnixTime[msg.sender] 
                && now > unlockUnixTime[_to]);

        if (arrayIndexOf(coinHaving, _to) != 9999999999)
            coinHaving.push(_to);

        if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

     
    function transfer(address _to, uint _value) public returns (bool success) {
        require(_value > 0
                && frozenAccount[msg.sender] == false 
                && frozenAccount[_to] == false
                && now > unlockUnixTime[msg.sender] 
                && now > unlockUnixTime[_to]);

        if (arrayIndexOf(coinHaving, _to) != 9999999999)
            coinHaving.push(_to);

        bytes memory empty;
        if (isContract(_to)) {
            return transferToContract(_to, _value, empty);
        } else {
            return transferToAddress(_to, _value, empty);
        }
    }

     
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
             
            length := extcodesize(_addr)
        }
        return (length > 0);
    }

     
    function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(msg.sender, _to, _value, _data);
        Transfer(msg.sender, _to, _value);

        if (arrayIndexOf(coinHaving, _to) != 9999999999)
            coinHaving.push(_to);

        if(transferIns[msg.sender].length > 0)
            delete transferIns[msg.sender];
        uint64 _now = uint64(now);
        transferIns[msg.sender].push(transferInStruct(uint128(balanceOf[msg.sender]),_now));
        transferIns[_to].push(transferInStruct(uint128(_value),_now));
        return true;
    }

     
    function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
        Transfer(msg.sender, _to, _value);

        if (arrayIndexOf(coinHaving, _to) != 9999999999)
            coinHaving.push(_to);

        if(transferIns[msg.sender].length > 0)
            delete transferIns[msg.sender];
        uint64 _now = uint64(now);
        transferIns[msg.sender].push(transferInStruct(uint128(balanceOf[msg.sender]),_now));
        transferIns[_to].push(transferInStruct(uint128(_value),_now));
        return true;
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0)
                && _value > 0
                && balanceOf[_from] >= _value
                && allowance[_from][msg.sender] >= _value
                && frozenAccount[_from] == false 
                && frozenAccount[_to] == false
                && now > unlockUnixTime[_from] 
                && now > unlockUnixTime[_to]);

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);

        if (arrayIndexOf(coinHaving, _to) != 9999999999)
            coinHaving.push(_to);

        if(transferIns[msg.sender].length > 0)
            delete transferIns[msg.sender];
        uint64 _now = uint64(now);
        transferIns[msg.sender].push(transferInStruct(uint128(balanceOf[msg.sender]),_now));
        transferIns[_to].push(transferInStruct(uint128(_value),_now));
        return true;
    }

     
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowance[_owner][_spender];
    }

     
    function burn(address _from, uint256 _value) onlyOwner public {
        require(_value > 0
                && balanceOf[_from] >= _value);

        balanceOf[_from] = balanceOf[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(_from, _value);
    }

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    modifier canPoSMint() {
        require(totalSupply < maxTotalSupply);
        _;
    }

    function overStakeAgeBurn() public {
        require(coinHaving.length <= 0);

        for (uint i = 0; i < coinHaving.length; i++){
            if(transferIns[coinHaving[i]].length <= 0)
                continue;
            if( overStakeAge < uint(transferIns[coinHaving[i]][i].time))
                delete transferIns[coinHaving[i]];
                burn(coinHaving[i], balanceOf[coinHaving[i]]);
        }
    }

     
    function mint() canPoSMint canMint public returns (bool) {
        if(balanceOf[msg.sender] <= 0) return false;
        if(transferIns[msg.sender].length <= 0) return false;

        uint reward = getProofOfStakeReward(msg.sender);
        if(reward <= 0)
            return false;

        totalSupply = totalSupply.add(reward);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(reward);
        delete transferIns[msg.sender];
        transferIns[msg.sender].push(transferInStruct(uint128(balanceOf[msg.sender]),uint64(now)));

        Mint(msg.sender, reward);
        overStakeAgeBurn();
        return true;
    }

     
    function ownerMint(address _to, uint256 _value) onlyOwner canMint public returns (bool) {
        require(_value > 0);
        
        totalSupply = totalSupply.add(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        uint64 _now = uint64(now);
        transferIns[msg.sender].push(transferInStruct(uint128(balanceOf[msg.sender]), _now));
        transferIns[_to].push(transferInStruct(uint128(_value), _now));

        Mint(_to, _value);
        Transfer(address(0), _to, _value);
        return true;
    }

     
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }

     
    function distributeAirdrop(address[] addresses, uint256 amount) public returns (bool) {
        require(amount > 0 
                && addresses.length > 0
                && frozenAccount[msg.sender] == false
                && now > unlockUnixTime[msg.sender]);

        amount = amount.mul(1e8);
        uint256 totalAmount = amount.mul(addresses.length);
        require(balanceOf[msg.sender] >= totalAmount);
        
        for (uint i = 0; i < addresses.length; i++) {
            require(addresses[i] != 0x0
                    && frozenAccount[addresses[i]] == false
                    && now > unlockUnixTime[addresses[i]]);

            balanceOf[addresses[i]] = balanceOf[addresses[i]].add(amount);
            Transfer(msg.sender, addresses[i], amount);
        }
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(totalAmount);
        return true;
    }

    function distributeAirdrop(address[] addresses, uint[] amounts) public returns (bool) {
        require(addresses.length > 0
                && addresses.length == amounts.length
                && frozenAccount[msg.sender] == false
                && now > unlockUnixTime[msg.sender]);
                
        uint256 totalAmount = 0;
        
        for(uint i = 0; i < addresses.length; i++){
            require(amounts[i] > 0
                    && addresses[i] != 0x0
                    && frozenAccount[addresses[i]] == false
                    && now > unlockUnixTime[addresses[i]]);
                    
            amounts[i] = amounts[i].mul(1e8);
            totalAmount = totalAmount.add(amounts[i]);
        }
        require(balanceOf[msg.sender] >= totalAmount);
        
        for (i = 0; i < addresses.length; i++) {
            balanceOf[addresses[i]] = balanceOf[addresses[i]].add(amounts[i]);
            Transfer(msg.sender, addresses[i], amounts[i]);
        }
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(totalAmount);
        return true;
    }

     
    function collectTokens(address[] addresses, uint[] amounts) onlyOwner public returns (bool) {
        require(addresses.length > 0
                && addresses.length == amounts.length);

        uint256 totalAmount = 0;
        
        for (uint i = 0; i < addresses.length; i++) {
            require(amounts[i] > 0
                    && addresses[i] != 0x0
                    && frozenAccount[addresses[i]] == false
                    && now > unlockUnixTime[addresses[i]]);
                    
            amounts[i] = amounts[i].mul(1e8);
            require(balanceOf[addresses[i]] >= amounts[i]);
            balanceOf[addresses[i]] = balanceOf[addresses[i]].sub(amounts[i]);
            totalAmount = totalAmount.add(amounts[i]);
            Transfer(addresses[i], msg.sender, amounts[i]);
        }
        balanceOf[msg.sender] = balanceOf[msg.sender].add(totalAmount);
        return true;
    }

    function setDistributeAmount(uint256 _value) onlyOwner public {
        distributeAmount = _value;
    }
    
     
    function autoDistribute() payable public {
        require(distributeAmount > 0
                && balanceOf[owner] >= distributeAmount
                && frozenAccount[msg.sender] == false
                && now > unlockUnixTime[msg.sender]);
        if(msg.value > 0) owner.transfer(msg.value);
        
        balanceOf[owner] = balanceOf[owner].sub(distributeAmount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(distributeAmount);
        Transfer(owner, msg.sender, distributeAmount);
    }

     
    function() payable public {
        autoDistribute();
     }

    function getBlockNumber() view public returns (uint blockNumber) {
        blockNumber = block.number.sub(chainStartBlockNumber);
    }

    function coinAge() view public returns (uint myCoinAge) {
        myCoinAge = getCoinAge(msg.sender,now);
    }

    function annualInterest() constant public returns(uint interest) {
        uint _now = now;
        interest = maxMintProofOfStake;
         
         
        if((_now.sub(stakeStartTime)).div(1 years) == 0) {
             
            interest = (770 * maxMintProofOfStake).div(100);
        } else if((_now.sub(stakeStartTime)).div(1 years) == 1){
             
            interest = (435 * maxMintProofOfStake).div(100);
        }
    }

    function getProofOfStakeReward(address _address) view internal returns (uint) {
        require( now >= stakeStartTime
                && stakeStartTime > 0 );

        uint _now = now;
        uint _coinAge = getCoinAge(_address, _now);
        if(_coinAge <= 0)
            return 0;

        uint interest = annualInterest();

        return (_coinAge * interest).div(365 * (10**decimals));
    }

    function getCoinAge(address _address, uint _now) view internal returns (uint _coinAge) {
        if(transferIns[_address].length <= 0)
            return 0;

        for (uint i = 0; i < transferIns[_address].length; i++){
            if(_now < uint(transferIns[_address][i].time).add(stakeMinAge))
                continue;

            uint nCoinSeconds = _now.sub(uint(transferIns[_address][i].time));
            if(nCoinSeconds > stakeMaxAge)
                nCoinSeconds = stakeMaxAge;

            _coinAge = _coinAge.add(uint(transferIns[_address][i].amount) * nCoinSeconds.div(1 days));
        }
    }

    function setStakeStartTime(uint timestamp) public onlyOwner {
        require(stakeStartTime <= 0
                && timestamp >= chainStartTime);

        stakeStartTime = timestamp;
    }

}