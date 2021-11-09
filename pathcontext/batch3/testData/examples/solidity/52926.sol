library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

     
    function add(Role storage role, address account) internal {
        require(account != address(0), "the 0x0 address cannot hold roles");
        require(!has(role, account), "this account already has already been given this role");

        role.bearer[account] = true;
    }

     
    function remove(Role storage role, address account) internal {
        require(account != address(0), "the 0x0 address cannot hold roles");
        require(has(role, account), "this account doesn&#39;t have this role to remove");

        role.bearer[account] = false;
    }

     
    function has(Role storage role, address account)
      internal
      view
      returns (bool)
    {
        require(account != address(0), "the 0x0 address cannot hold roles");
        return role.bearer[account];
    }
}

library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "c divided by a must equal b, otherwise a * b has overflowed");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "cannot divide by zero");  
        uint256 c = a / b;
         

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "b must be less than or equal to a, otherwise c could overflow");
        uint256 c = a - b;

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "c must be greter than or equal to a, otherwise a + b has overflown");

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "cannot divide by zero");
        return a % b;
    }
}
contract FundkeeperRole {
    using Roles for Roles.Role;

    address public fundkeeper;

    event FundkeeperTransferred(
      address indexed previousKeeper,
      address indexed newKeeper
    );

    Roles.Role private fundkeepers;

    constructor() internal {
        _addFundkeeper(msg.sender);
    }

    modifier onlyFundkeeper() {
        require(isFundkeeper(msg.sender), "msg.sender does not have the fundkeeper role");
        _;
    }

    function isFundkeeper(address account) public view returns (bool) {
        return fundkeepers.has(account);
    }

    function transferFundkeeper(address newFundkeeper) public onlyFundkeeper {
        _transferFundkeeper(newFundkeeper);
    }

     
    function _transferFundkeeper(address newFundkeeper) internal {
        _addFundkeeper(newFundkeeper);
        _removeFundkeeper(msg.sender);
        emit FundkeeperTransferred(msg.sender, newFundkeeper);
    }

    function renounceFundkeeper() public {
        _removeFundkeeper(msg.sender);
    }

    function _addFundkeeper(address account) internal {
        require(account != address(0), "fundkeeper role cannot be held by 0x0");
        fundkeepers.add(account);
        fundkeeper = account;
        emit FundkeeperTransferred(address(0), account);
    }

    function _removeFundkeeper(address account) internal {
        fundkeepers.remove(account);
        emit FundkeeperTransferred(account, address(0));
    }
}
contract IERC20 is FundkeeperRole{ 
    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function allowance(address owner, address spender) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

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
interface ICrowdsale {

   

  function getInterval(uint256 blockNumber) external view returns (uint256);
  
  function getERC20() external view returns (address);
  
  function getDistributedTotal() external view returns (uint256);
    
  function currentStage() external view returns (uint256);

    

    

  function initialize(
      uint256 ETHPrice,
      uint256 reserveFloor,
      uint256 reserveStart, 
      uint256 reserveCeiling,
      uint256 crowdsaleAllocation
    ) external returns (bool); 

   

   
   
  function participate(uint256 limit) external payable returns (bool);

   
  function claim(uint256 interval) external;

   
  function claimAll() external returns (bool);

   
   
  function setRebase(uint256 newETHPrice) external returns (bool);

   
  function revealCap(uint256 cap, uint256 secret) external returns (bool); 

   
   
  function collect() external returns (bool);
  
   
   
  function addToWhitelist(address[] _participant_addresses) external;
  
   
  function removeFromWhitelist(address[] _participant_addresses) external;

    
   

    
   
  function recoverTokens(IERC20 token) external returns (bool);

  event Participated (uint256 interval, address account, uint256 amount);
  event Claimed (uint256 interval, address account, uint256 amount);
  event Collected (address collector, uint256 amount);
  event Rebased(uint256 newETHPrice, uint256 newETHReservePrice, uint256 newETHReserveAmount);
  event TokensRecovered(IERC20 token, uint256 recovered);
}
contract ManagerRole {
    using Roles for Roles.Role;

    event ManagerAdded(address indexed account);
    event ManagerRemoved(address indexed account);

    Roles.Role private managers;

    constructor() internal {
        _addManager(msg.sender);
    }

    modifier onlyManager() {
        require(isManager(msg.sender), "msg.sender does not have the manager role");
        _;
    }

    function isManager(address account) public view returns (bool) {
        return managers.has(account);
    }

    function addManager(address account) public onlyManager {
        _addManager(account);
    }

    function renounceManager() public {
        _removeManager(msg.sender);
    }

    function _addManager(address account) internal {
        managers.add(account);
        emit ManagerAdded(account);
    }

    function _removeManager(address account) internal {
        managers.remove(account);
        emit ManagerRemoved(account);
    }
}
contract RecoverRole {
    using Roles for Roles.Role;

    event RecovererAdded(address indexed account);
    event RecovererRemoved(address indexed account);

    Roles.Role private recoverers;

    constructor() internal {
        _addRecoverer(msg.sender);
    }

    modifier onlyRecoverer() {
        require(isRecoverer(msg.sender), "msg.sender does not have the recoverer role");
        _;
    }

    function isRecoverer(address account) public view returns (bool) {
        return recoverers.has(account);
    }

    function addRecoverer(address account) public onlyRecoverer {
        _addRecoverer(account);
    }

    function renounceRecoverer() public {
        _removeRecoverer(msg.sender);
    }

    function _addRecoverer(address account) internal {
        recoverers.add(account);
        emit RecovererAdded(account);
    }

    function _removeRecoverer(address account) internal {
        recoverers.remove(account);
        emit RecovererRemoved(account);
    }
}
contract WhitelisterRole {
    using Roles for Roles.Role;

    event WhitelisterAdded(address indexed account);
    event WhitelisterRemoved(address indexed account);

    Roles.Role private _whitelisters;

    constructor () internal {
        _addWhitelister(msg.sender);
    }

    modifier onlyWhitelister() {
        require(isWhitelister(msg.sender));
        _;
    }

    function isWhitelister(address account) public view returns (bool) {
        return _whitelisters.has(account);
    }

    function addWhitelister(address account) public onlyWhitelister {
        _addWhitelister(account);
    }

    function renounceWhitelister() public {
        _removeWhitelister(msg.sender);
    }

    function _addWhitelister(address account) internal {
        _whitelisters.add(account);
        emit WhitelisterAdded(account);
    }

    function _removeWhitelister(address account) internal {
        _whitelisters.remove(account);
        emit WhitelisterRemoved(account);
    }
}
contract TBNCrowdSale is ICrowdsale, ManagerRole, RecoverRole, FundkeeperRole, WhitelisterRole {
    using SafeMath for uint256;
    
     
    struct Interval {
        uint256 reservePrice;   
        uint256 ETHReserveAmount;    
    }

    mapping (uint256 => Interval) public intervals;

    IERC20 private _erc20;                           
    
    uint256 private _guaranteedIntervals;            
    uint256 private _numberOfIntervals;              
    bytes32 private _hiddenCap;                      

                                                     
    uint256 private _ETHPrice;                       
    uint256 private _reserveFloor;                   
    uint256 private _reserveCeiling;                 
    uint256 private _reserveStep;                    

    uint256 private _crowdsaleAllocation;            
    uint256 private _distributedTotal;               
    uint256 private _totalContributions;             

    uint256 private WEI_FACTOR = 10**18;             

    uint256 private _rebaseNewPrice;                 
    uint256 private _rebased;                        
    
    uint256 private _lastAdjustedInterval;           

    bool private _recoverySafety;                            

    uint256 public startBlock;                       
    uint256 public endBlock;                         
    uint256 public endInterval;                      
    uint256 public INTERVAL_BLOCKS = 80;           

    uint256 public tokensPerInterval;                
    
    mapping (uint256 => uint256) public intervalTotals;  

    mapping (uint256 => mapping (address => uint256)) public participationAmount;
    mapping (uint256 => mapping (address => bool)) public claimed;
    mapping (address => bool) public whitelist;
    
    Stages public stages;

     
    enum Stages {
        CrowdsaleDeployed,
        Crowdsale,
        CrowdsaleEnded
    }

     
    modifier atStage(Stages _stage) {
        require(stages == _stage, "functionality not allowed at current stage");
        _;
    }

    modifier onlyWhitelisted(address _participant) {
        require(whitelist[_participant] == true, "account is not white listed");
        _;
    }

     
     
    modifier update() {
        uint256 interval = getInterval(block.number);
        if(endInterval == 0) {
            if (block.number > endBlock) {  
                interval = _numberOfIntervals.add(1);
                if (uint(stages) < 2) {
                    stages = Stages.CrowdsaleEnded;
                    endInterval = _numberOfIntervals.add(1);
                }
            }
        } else {
            interval = endInterval;
        }

        if(_lastAdjustedInterval != interval){  
            for (uint i = _lastAdjustedInterval.add(1); i <= interval; i++) {  
                _adjustReserve(i);  
                _addDistribution(i);  
            }
            if(endInterval != 0 && _recoverySafety != true) {  
                _recoverySafety = true;
            }
            _lastAdjustedInterval = interval;
        }

         
        if( interval > 1 && _rebased == interval.sub(1)){  
            _rebase(_rebaseNewPrice);
            _;
        } else {
            _;
        }
    }

     
    constructor(
        IERC20 token,
        uint256 numberOfIntervals,
        uint256 guaranteedIntervals,
        bytes32 hiddenCap    
    ) public {
        require(address(token) != 0x0, "token address cannot be 0x0");
        require(guaranteedIntervals > 0, "guaranteedIntervals must be larger than zero");
        require(numberOfIntervals > guaranteedIntervals, "numberOfIntervals must be larger than guaranteedIntervals");

        _erc20 = token;
        _numberOfIntervals = numberOfIntervals;
        _guaranteedIntervals = guaranteedIntervals;
        _hiddenCap = hiddenCap;

        stages = Stages.CrowdsaleDeployed;
    }

     
    function () external payable {
        participate(0);
    }

     
    function recoverTokens(IERC20 token) 
        external 
        onlyRecoverer 
        returns (bool) 
    {
        uint256 recover;
        if (token == _erc20){
            require(uint(stages) >= 2, "if recovering TBN, must have progressed to CrowdsaleEnded");
            require(_recoverySafety, "update() needs to run at least once since the sale has ended");
            recover = token.balanceOf(address(this)).sub(_distributedTotal);
        } else {
            recover = token.balanceOf(address(this));
        }

        token.transfer(msg.sender, recover);
        emit TokensRecovered(token, recover);
        return true;
    }

    


     
    function getInterval(uint256 blockNumber) public view returns (uint256) {
        return _intervalFor(blockNumber);
    }

     
    function getERC20() public view returns (address) {
        return address(_erc20);
    }

     
    function getDistributedTotal() public view returns (uint256) {
        return _distributedTotal;
    }

    function currentStage() public view returns(uint256) {
        return uint256(stages);
    }

     
    function participate(uint256 guarantee) 
        public 
        payable 
        atStage(Stages.Crowdsale) 
        update()
        onlyWhitelisted(msg.sender) 
        returns (bool) 
    {
        uint256 interval = getInterval(block.number);
        require(interval <= _numberOfIntervals, "interval of current block number must be less than or equal to the number of intervals");
        require(msg.value >= .01 ether, "minimum participation amount is .01 ETH");

        participationAmount[interval][msg.sender] = participationAmount[interval][msg.sender].add(msg.value);
        intervalTotals[interval] = intervalTotals[interval].add(msg.value);
        _totalContributions = _totalContributions.add(msg.value);

        if (guarantee != 0) {
            uint256 TBNperETH;
            if(intervalTotals[interval] >= intervals[interval].ETHReserveAmount) {
                TBNperETH = (tokensPerInterval.mul(WEI_FACTOR)).div(intervalTotals[interval]);  
            } else {
                TBNperETH = (WEI_FACTOR.mul(WEI_FACTOR)).div(intervals[interval].reservePrice);  
            }
            require(TBNperETH >= guarantee, "the number TBN per ETH is less than your expected guaranteed number of TBN");
        }

        emit Participated(interval, msg.sender, msg.value);

        return true;
    }


     
    function claim(uint256 interval) 
        public 
        update()
    {
        require(uint(stages) >= 1, "must be in the Crowdsale or later stage to claim");
        require(getInterval(block.number) > interval, "the given interval must be less than the current interval");
        
        if (claimed[interval][msg.sender] || intervalTotals[interval] == 0) {
            return;
        }

        uint256 intervalClaim;
        uint256 contributorProportion = participationAmount[interval][msg.sender].mul(WEI_FACTOR).div(intervalTotals[interval]);
        uint256 reserveMultiplier;
        if (intervalTotals[interval] >= intervals[interval].ETHReserveAmount){
            reserveMultiplier = WEI_FACTOR;
        } else {
            reserveMultiplier = intervalTotals[interval].mul(WEI_FACTOR).div(intervals[interval].ETHReserveAmount);
        }

        intervalClaim = tokensPerInterval.mul(contributorProportion).mul(reserveMultiplier).div(10**36);
        _distributedTotal = _distributedTotal.sub(intervalClaim);
        claimed[interval][msg.sender] = true;
        _erc20.transfer(msg.sender, intervalClaim);

        emit Claimed(interval, msg.sender, intervalClaim);
    }

     
    function claimAll() 
        public
        returns (bool) 
    {
        for (uint i = 0; i < getInterval(block.number); i++) {
            claim(i);
        }
        return true;
    }

      
     
    function addToWhitelist(address[] _participant_addresses) external onlyWhitelister {
        for (uint32 i = 0; i < _participant_addresses.length; i++) {
            if(_participant_addresses[i] != address(0) && whitelist[_participant_addresses[i]] == false){
                whitelist[_participant_addresses[i]] = true;
            }
        }
    }

     
     
    function removeFromWhitelist(address[] _participant_addresses) external onlyWhitelister {
        for (uint32 i = 0; i < _participant_addresses.length; i++) {
            if(_participant_addresses[i] != address(0) && whitelist[_participant_addresses[i]] == true){
                whitelist[_participant_addresses[i]] = false;
            }
        }
    }

     
    function initialize(
        uint256 ETHPrice,
        uint256 reserveFloor,
        uint256 reserveStart, 
        uint256 reserveCeiling,
        uint256 crowdsaleAllocation
    ) 
        external 
        onlyManager 
        atStage(Stages.CrowdsaleDeployed) 
        returns (bool) 
    {
        require(ETHPrice > reserveCeiling, "ETH basis price must be greater than the reserve ceiling"); 
        require(reserveFloor > 0, "the reserve floor must be greater than 0");
        require(reserveCeiling > reserveFloor.add(_numberOfIntervals), "the reserve ceiling must be _numberOfIntervals WEI greater than the reserve floor");
        require(reserveStart >= reserveFloor, "the reserve start price must be greater than the reserve floor");
        require(reserveStart <= reserveCeiling, "the reserve start price must be less than the reserve ceiling");
        require(crowdsaleAllocation > 0, "crowdsale allocation must be assigned a number greater than 0");
        
        address fundkeeper = _erc20.fundkeeper();
        require(_erc20.allowance(address(fundkeeper), address(this)) == crowdsaleAllocation, "crowdsale allocation must be equal to the amount of tokens approved for this contract");

         
        _ETHPrice = ETHPrice;
        _rebaseNewPrice = ETHPrice;
        _crowdsaleAllocation = crowdsaleAllocation;
        _reserveFloor = reserveFloor;
        _reserveCeiling = reserveCeiling;
        _reserveStep = (_reserveCeiling.sub(_reserveFloor)).div(_numberOfIntervals);
        startBlock = block.number;
        
        tokensPerInterval = crowdsaleAllocation.div(_numberOfIntervals);

         
        uint256 interval = getInterval(block.number);
        intervals[interval].reservePrice = (reserveStart.mul(WEI_FACTOR)).div(_ETHPrice);
        intervals[interval].ETHReserveAmount = tokensPerInterval.mul(intervals[interval].reservePrice).div(WEI_FACTOR);

         
        _erc20.transferFrom(fundkeeper, address(this), crowdsaleAllocation);

         
        endBlock = startBlock.add(INTERVAL_BLOCKS.mul(_numberOfIntervals));
       
        stages = Stages.Crowdsale;

        return true;
    }

     
    function setRebase(uint256 newETHPrice) 
        external 
        onlyManager 
        atStage(Stages.Crowdsale) 
        returns (bool) 
    {
        require(newETHPrice > _reserveCeiling, "ETH price cannot be set smaller than the reserve ceiling");
        uint256 interval = getInterval(block.number);
        require(block.number <= endBlock, "cannot rebase after the crowdsale period is over");
        require(interval > 0, "cannot rebase in the initial interval");
        _rebaseNewPrice = newETHPrice;
        _rebased = interval;
        return true;
    }

     
    function revealCap(uint256 cap, uint256 secret) 
        external 
        onlyManager 
        atStage(Stages.Crowdsale) 
        returns (bool) 
    {
        require(block.number >= startBlock.add(INTERVAL_BLOCKS.mul(_guaranteedIntervals)), "cannot reveal hidden cap until after the guaranteed period");
        uint256 interval = getInterval(block.number);
        bytes32 hashed = keccak256(abi.encode(cap, secret));
        if (hashed == _hiddenCap) {
            require(cap <= _totalContributions, "revealed cap must be under the total contribution");
            stages = Stages.CrowdsaleEnded;
            endInterval = interval;
            return true;
        }
        return false;
    }

     
    function collect() 
        external 
        onlyFundkeeper 
        returns (bool) 
    {
        msg.sender.transfer(address(this).balance);
        emit Collected(msg.sender, address(this).balance);
    }

     
    function _rebase(uint256 newETHPrice) 
        internal 
        atStage(Stages.Crowdsale) 
    {
        uint256 interval = getInterval(block.number);
        
         
        uint256 oldPrice = (intervals[interval].reservePrice.mul(_ETHPrice)).div(WEI_FACTOR);
        
         
        _ETHPrice = newETHPrice;

         
        intervals[interval].reservePrice = (oldPrice.mul(WEI_FACTOR)).div(_ETHPrice);
         
        intervals[interval].ETHReserveAmount = tokensPerInterval.mul(intervals[interval].reservePrice).div(WEI_FACTOR);

         
        _rebaseNewPrice = 0;
         
        _rebased = 0;

        emit Rebased(
            _ETHPrice,
            intervals[interval].reservePrice,
            intervals[interval].ETHReserveAmount
        );
    } 

     
    function _intervalFor(uint256 blockNumber) 
        internal 
        view 
        returns (uint256) 
    {
        uint256 interval;
        if(blockNumber <= startBlock) {
            interval = 0;
        }else if(blockNumber <= endBlock) {
            interval = blockNumber.sub(startBlock).div(INTERVAL_BLOCKS);
        } else {
            interval = ((endBlock.sub(startBlock)).div(INTERVAL_BLOCKS)).add(1);
        }

        return interval;
    }

     
    function _adjustReserve(uint256 interval) internal {
        require(interval > 0, "cannot adjust the intial interval reserve");
         
        uint256 lastReserveAmount = intervals[interval.sub(1)].ETHReserveAmount;  
        uint256 lastUSDPrice = (intervals[interval.sub(1)].reservePrice.mul(_ETHPrice)).div(WEI_FACTOR);  

        uint256 ratio;  
        uint256 multiplier;  

        uint256 newUSDPrice;

         
        if (intervalTotals[interval.sub(1)] > lastReserveAmount) {  
            ratio = (lastReserveAmount.mul(WEI_FACTOR)).div(intervalTotals[interval.sub(1)]);
            if(ratio <= 33*10**16){  
                multiplier = 3;
            } else if (ratio <= 66*10**16){  
                multiplier = 2;
            } else {  
                multiplier = 1;
            }

            newUSDPrice = lastUSDPrice.add(_reserveStep.mul(multiplier));  
            
            if (newUSDPrice >= _reserveCeiling) {  
                intervals[interval].reservePrice = (_reserveCeiling.mul(WEI_FACTOR)).div(_ETHPrice);  
            } else {  
                intervals[interval].reservePrice = (newUSDPrice.mul(WEI_FACTOR)).div(_ETHPrice);  
            }

        } else if (intervalTotals[interval.sub(1)] < lastReserveAmount) {  
            ratio = (intervalTotals[interval.sub(1)].mul(WEI_FACTOR)).div(lastReserveAmount);
            if(ratio <= 33*10**16){  
                multiplier = 3;
            } else if (ratio <= 66*10**16){  
                multiplier = 2;
            } else {  
                multiplier = 1;
            }

            newUSDPrice = lastUSDPrice.sub(_reserveStep.mul(multiplier));  
            
            if (newUSDPrice <= _reserveFloor) {  
                intervals[interval].reservePrice = (_reserveFloor.mul(WEI_FACTOR)).div(_ETHPrice);  
            } else {  
                intervals[interval].reservePrice = (newUSDPrice.mul(WEI_FACTOR)).div(_ETHPrice);  
            }
        } else {  
            intervals[interval].reservePrice = intervals[interval.sub(1)].reservePrice;  
        }
         
        intervals[interval].ETHReserveAmount = tokensPerInterval.mul(intervals[interval].reservePrice).div(WEI_FACTOR);
                            
    }

     
    function _addDistribution(uint256 interval) internal {
        uint256 reserveMultiplier;

        if (intervalTotals[interval.sub(1)] >= intervals[interval.sub(1)].ETHReserveAmount){
            reserveMultiplier = WEI_FACTOR;
        } else {
            reserveMultiplier = intervalTotals[interval.sub(1)].mul(WEI_FACTOR).div(intervals[interval.sub(1)].ETHReserveAmount);
        }
        uint256 intervalDistribution = (tokensPerInterval.mul(reserveMultiplier)).div(WEI_FACTOR);

        _distributedTotal = _distributedTotal.add(intervalDistribution);
    }
}