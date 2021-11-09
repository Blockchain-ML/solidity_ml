pragma solidity ^0.4.24;

 
 
 
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

 
 
contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

 
contract Evoai {
    function recevedTokenFromEvabot(address _user, uint256 _amount) public;
    function recevedEthFromEvabot(address _user, uint256 _amount) public;
}

 
contract ESes {
  
  using SafeMath for uint256;
  address public admin;  
  address public tokenEVOT;  
  address public wallet_contract;  
  address public fee_contract;  
  uint256 public readyTime;
  uint32 public cycleOpened;
  uint256 public eth_value_amount;
  uint256 public max_whitelists;
  uint256 public limit_token;
  uint256 public cycleResetTime;
  uint256 public dailyProfitSumForAllUsers;
  
  mapping (address => uint256) public activeToken;  
  mapping (address => uint256) public pendingToken;  
  mapping (address => bool) public isAutoInvest;  
  mapping (address => uint256) public myEthBalance;  
  mapping (address => uint256) public dailyEthProfit;
  mapping (address => uint256) public totalInvested;
  mapping (address => uint256) public totalProfit;
  
  address[] public whitelists;  
  address[] private pendingUserlists;  
  address[] private activeUserlists;  
   
  event Deposit(uint256 types, address user, uint256 amount);  
  event Withdraw(uint256 types, address user, uint256 amount);  
  event Transfered(uint256 types, address _from, uint256 amount, address _to); 
  
   
  constructor() public {
    admin = msg.sender;
    cycleOpened = 0;
    max_whitelists = 69;
    limit_token = 1000 ether;
    cycleResetTime = 1 days;
    dailyProfitSumForAllUsers = 0;
  }

  modifier onlyAdmin {
    require(msg.sender == admin);
    _;
  }
  
   
  function setTokenAddress(address _token) onlyAdmin() public {
      tokenEVOT = _token;
  }
  
   
  function setInvestTokenLimit(uint256 _limit) onlyAdmin() public {
    limit_token = _limit;    
  }
  
   
  function setMaxWhitelists(uint256 _max) onlyAdmin() public {
      max_whitelists = _max;
  }

   
  function setCycleResetTime(uint256 _time) onlyAdmin() public {
        cycleResetTime = _time;
  }

   
  function setWalletContractAddress(address _wallet) onlyAdmin() public {
    wallet_contract = _wallet;
  }

  function setFeeContractAddress(address _wallet) onlyAdmin() public {
    fee_contract = _wallet;    
  }
  
   
  function changeAdmin(address admin_) onlyAdmin() public {
    admin = admin_;
  }
  
   
  function _find(address value) private view returns(uint) {
      uint i = 0;
      while (whitelists[i] != value) {
          i++;
      }
      return i;
  }
    
  function _removeByValue(address value) private {
      uint i = _find(value);
      _removeByIndex(i);
  }
    
  function _removeByIndex(uint i) private {
      while (i<whitelists.length-1) {
          whitelists[i] = whitelists[i+1];
          i++;
      }
      whitelists.length--;
  }
  
   
  function _pfind(address value) private view returns(uint) {
      uint i = 0;
      while (pendingUserlists[i] != value) {
          i++;
      }
      return i;
  }
    
  function _premoveByValue(address value) private {
      uint i = _pfind(value);
      _premoveByIndex(i);
  }
    
  function _premoveByIndex(uint i) private {
      while (i<pendingUserlists.length-1) {
          pendingUserlists[i] = pendingUserlists[i+1];
          i++;
      }
      pendingUserlists.length--;
  }
  
   
  function addWhitelist(address _user) onlyAdmin() public {
    require(whitelists.length <= max_whitelists);
    isAutoInvest[_user] = false;
    whitelists.push(_user);
  }
  
   
  function removeWhitelist(address _user) onlyAdmin() public {
     
    _removeByValue(_user);
  }
  
   
  function getWhitelists() public constant returns(address[]) {
      return whitelists;
  }
  
  
   
  function receiveToken(address _user, uint256 _amount) public {
    require(tokenEVOT == msg.sender);
    require(pendingToken[_user].add(activeToken[_user]) <= limit_token);
    pendingToken[_user] = pendingToken[_user].add(_amount); 
  }
  
   
  function getInvestedTokenBalance(address _user) public view returns(uint256) {
    return pendingToken[_user].add(activeToken[_user]);
  }

   
  function setAutoInvest() public {
      if(isAutoInvest[msg.sender] == true) {
          isAutoInvest[msg.sender] = false;
      } else {
          isAutoInvest[msg.sender] = true;
      }
  }
  
   
  function getAutoInvestStatus(address _user) public view returns(bool) {
      return isAutoInvest[_user];
  }
  
   
  function setEthValueAmount(uint256 _amount) onlyAdmin() public {
      eth_value_amount = _amount;
  }
  
   
  function getEthValueAmount() public view returns(uint256) {
      return eth_value_amount;
  }
  
   
  function startCycle() onlyAdmin() public {
      require(cycleOpened == 0);
      readyTime = now + cycleResetTime;
      cycleOpened = 1;
       
      for(uint256 i = 0; i < pendingUserlists.length; i++) {
          activeToken[pendingUserlists[i]] = pendingToken[pendingUserlists[i]];
          totalInvested[pendingUserlists[i]] = totalInvested[pendingUserlists[i]].add(pendingToken[pendingUserlists[i]]);
          pendingToken[pendingUserlists[i]] = 0;
          activeUserlists.push(pendingUserlists[i]);  
      }
      pendingUserlists.length = 0;
  }
  
   
  function stopCycle() onlyAdmin() public {
      require(now >= readyTime);
      cycleOpened = 0;
      
      for(uint256 i = 0; i < activeUserlists.length; i++) {
           
          if(isAutoInvest[activeUserlists[i]]) {
            pendingToken[activeUserlists[i]] = pendingToken[activeUserlists[i]].add(activeToken[activeUserlists[i]]);
            pendingUserlists.push(activeUserlists[i]);
          } else {
            if (!ERC20(tokenEVOT).transfer(wallet_contract, activeToken[activeUserlists[i]])) revert();
            Evoai(wallet_contract).recevedTokenFromEvabot(activeUserlists[i], activeToken[activeUserlists[i]]);
          }
      }
  }
  
   
  function getProfit(address _user) public view returns(uint256) {
      uint256 cycle_activetoken = 0;
      for (uint256 j = 0; j < activeUserlists.length; j++) {
        cycle_activetoken = cycle_activetoken.add(activeToken[activeUserlists[j]]);
      }
      if(cycle_activetoken == 0) revert();
      return (activeToken[_user]).mul(10**18).div(cycle_activetoken);
  }
  
   
  function deposit() payable public {
     fee_contract.transfer(10**17); 
     emit Deposit(0, msg.sender, msg.value);
  }
  
   
  function() payable public {
      
  }
  
   
  function distributeEth(address[] _addrs, uint256[] _vals) onlyAdmin() public {
    for(uint i = 0; i < _addrs.length; ++i){
      myEthBalance[_addrs[i]] = myEthBalance[_addrs[i]].add(_vals[i]);
      totalProfit[_addrs[i]] = totalProfit[_addrs[i]].add(_vals[i]);
      activeToken[_addrs[i]] = 0;
    }
    activeUserlists.length = 0;
    startCycle();
  }
  
   
  function transferETH(uint256 amount) public {
    require(myEthBalance[msg.sender] >= amount);
    myEthBalance[msg.sender] = myEthBalance[msg.sender].sub(amount);
    wallet_contract.transfer(amount);
    Evoai(wallet_contract).recevedEthFromEvabot(msg.sender, amount);
    emit Transfered(0, msg.sender, amount, msg.sender);
  }

   
  function transferToken(uint256 amount) public {
    if (tokenEVOT==0) revert();
    require(pendingToken[msg.sender] >= amount);
    pendingToken[msg.sender] = pendingToken[msg.sender].sub(amount);
    if (!ERC20(tokenEVOT).transfer(wallet_contract, amount)) revert();
    if(pendingToken[msg.sender] == 0)
        _premoveByValue(msg.sender);
    
    Evoai(wallet_contract).recevedTokenFromEvabot(msg.sender, amount);
    
    emit Transfered(1, msg.sender, amount, msg.sender);
  }
  
   
  function increasePendingTokenBalance(address _user, uint256 _amount) public {
      require(msg.sender == wallet_contract);
      pendingToken[_user] = pendingToken[_user].add(_amount);
      uint j = 0;
      for (uint i=0; i<pendingUserlists.length; i++) {
        if(pendingUserlists[i] == _user) {
          j++;
        }
      }
      if (j == 0) 
        pendingUserlists.push(_user);
  }

   
  function getTotalProfit(address _user) public view returns(uint256) {
    return totalProfit[_user];
  } 
    
   
  function withdrawAll() onlyAdmin() public {
    msg.sender.transfer(address(this).balance);
  }

   
  function getDailyEthProfit(address _user) public view returns(uint256) {
      return dailyEthProfit[_user];
  }
  
   
  function getTotalInvested(address _user) public view returns(uint256) {
      return totalInvested[_user];
  }
  
   
  function getEvotTokenAddress() public constant returns (address) {
    return tokenEVOT;    
  }
  
   
  function balanceOfPendingToken(address user) public constant returns (uint256) {
    return pendingToken[user];
  }
  
   
  function balanceOfActiveToken(address user) public constant returns (uint256) {
    return activeToken[user];
  }
    
   
  function balanceOfETH(address user) public constant returns (uint256) {
    return myEthBalance[user];
  }

   
  function getDailyProfitSumForAllUsers() public constant returns (uint256) {
    return dailyProfitSumForAllUsers;
  }

   
  function getReadyTime() public constant returns (uint256) {
      if(now >= readyTime) {
        return 0;
      } else {
        return readyTime.sub(now);
      }
  }
  
   
  function withdrawAllTokens(uint256 amount) onlyAdmin() public {
      if (!ERC20(tokenEVOT).transfer(msg.sender, amount)) revert();
  }
  
   
  function getPendingUserlists() public view returns (address[]) {
      return pendingUserlists;
  }
  
   
  function getPendingUserCount() public constant returns (uint256) {
    return pendingUserlists.length;
  }
  
   
  function getActiveUserCount() public constant returns (uint256) {
    return activeUserlists.length;
  }
  
   
  function getActiveUserLists() public view returns (address[]) {
      return activeUserlists;
  }
  
   
  function setTotalInvestedToken(address _user, uint256 _amount) onlyAdmin() public {
      totalInvested[_user] = _amount;
  }
  
   
  function setBalanceOfETH(address user, uint256 _amount) onlyAdmin() public {
     myEthBalance[user] = _amount;
  }
  
  
  function setBalanceOfPendingToken(address user, uint256 _amount) onlyAdmin() public {
    pendingToken[user] = _amount;
  }
  
   
  function setBalanceOfActiveToken(address user, uint256 _amount) onlyAdmin() public {
     activeToken[user] = _amount;
  } 
  
   
  function setAutoInvestByAdmin(address _user, bool _status) onlyAdmin() public {
    isAutoInvest[_user] = _status;
  }
  
   
  function setTotalProfit(address _user, uint256 _amount) onlyAdmin() public {
    totalProfit[_user] = _amount;
  }
  
   
  function forceStopCycle() onlyAdmin() public {
    readyTime = now;
    cycleOpened = 0;
  }
  
   
  function setForceReadyTime(uint256 _time) onlyAdmin() public {
    readyTime = _time;
  }
  
  
 function emptyPendingUserList() onlyAdmin() public {
   pendingUserlists.length = 0;
 }
 
  
 function emptyActiveUserList() onlyAdmin() public {
   activeUserlists.length = 0;
 }
 
  
 function addPendingUserListArr(address _user) onlyAdmin() public {
    uint j = 0;
    for (uint i=0; i<pendingUserlists.length; i++) {
      if(pendingUserlists[i] == _user) {
        j++;
      }
    }
    if (j == 0) 
     pendingUserlists.push(_user);
 }
 
  
 function addActiveUserListArr(address _user) onlyAdmin() public {
    uint j = 0;
    for (uint i=0; i<activeUserlists.length; i++) {
      if(activeUserlists[i] == _user) {
        j++;
      }
    }
    if (j == 0) 
     activeUserlists.push(_user);
 }
}