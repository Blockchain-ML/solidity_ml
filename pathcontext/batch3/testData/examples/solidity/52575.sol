pragma solidity ^0.4.24;

 
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
  constructor() public {
    owner = msg.sender;
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

}

 
library SafeMath {
    
     
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

     
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

     
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
    
     
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    
     
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }
    
     
    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else 
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}


contract BleedFomo is Ownable{
    
    using SafeMath for uint256;
    
    event onKeyLevelUp(uint256 _keyprice);
    
     
    uint256 private decimalPercent = 10000;
    
     
    uint256 private percentBigwin = 5000;
    uint256 private percentShare = 4500;
    uint256 private percentNextround = 300;
    uint256 private percentCost = 200;
    
    
     
    uint256 private percentShareOnetime = 2000;
    
     
    uint256[3] private scaleBigwin = [6000, 3000, 1000];
    
     
    uint256 private keyPrice = 0.001 ether;
    uint256 private allKeyNum = 0;
    uint256 private allKeyNum_next = 0;
    uint256 private percentKeyPriceIncrease = 800;
    uint256 private conditionKeyPriceIncrease = 50;
    uint256 private conditionKeyPriceAttenuation = 4;
    uint256 private decimalKey = 8;
    
     
     
    
    uint256 private checkOutinterval = 2 hours;
    uint256 private endTimeSettingInit = 1 hours;
    uint256 private endTimeSettingMax = 30 minutes;
    uint256 private endTimeSettingMin = 10 minutes;
    uint256 private endTimeSettingIncrease1 = 1 minutes;
    uint256 private endTimeSettingIncrease2 = 30 minutes;
    uint256 private nextroundInterval = 1 hours;    
    uint256 private timeKeyPriceIncrease = 10 minutes;
    
     
    uint256 private bigwinPot = 0;
    uint256 private sharePot = 0;
    uint256 private sharePot_next = 0;
    uint256 private nextroundPot = 0;
    uint256 private costPot = 0;

    
     
    uint256 private startTime = 0;
    uint256 private lastWinnerTime = 0;
    uint256 private endTime = 0;
    
     
    uint256 private checkoutTime = 0;
    
    
    
    uint256 private currentlevelKeycount = 0;
    uint256 private timeKeyLevepUp = 0;    
    uint256 private sharenumEveryKey = 0;
    
    uint256 private sharePotUnTreate = 0;   
    uint256 private checkoutCurr = 0;
    
    
    
    address private costaddr = 0xF455e968930419C306b5bfD136717DCf22F11883;
    
     
    struct BigWinner{
        address addr;
        uint256 timestamp;
    }
    BigWinner[3] private bigWinner;
    
    
     
    mapping (address => uint256) private userkeys;
    address[] private useraddrs = new address[](0);
   
    
     
    mapping (address => uint256) private userkeys_nextround;
    address[] private useraddrs_nextround = new address[](0);
    
    
     
     
     
    function getGameTime() public view returns(uint256, uint256){
        return (startTime, endTime);
    }
    
    function getPots() public view returns(uint256, uint256, uint256, uint256) {
        return (bigwinPot, sharePot+sharePot_next, nextroundPot, costPot);
    }
    
    function getKeyPrice() public view returns(uint256) {
        return keyPrice;
    }
    
    function getNextKeyTime() public view returns (uint256){
        return timeKeyLevepUp;
    }
    
    function getCurLevelKeyNum() public view returns (uint256){
        return currentlevelKeycount;
    }
    
    function getAllKeyNum() public view returns (uint256){
        return allKeyNum + allKeyNum_next;               
    }
    
    function getBigWinner() public view returns(address, uint256, address, uint256, address, uint256){
         
        return (bigWinner[0].addr, bigWinner[0].timestamp, bigWinner[1].addr, bigWinner[1].timestamp, bigWinner[2].addr, bigWinner[2].timestamp);
    }
    
    function getUserKeys(address _useraddr) public view returns(uint256) {
        return userkeys[_useraddr] + userkeys_nextround[_useraddr];    
    }
     
     
    
    
    
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
    
    modifier validValue (uint256 _eth) {
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        _;
    }
    
    
     
    function _updateKeyPrice(uint256 _nowtime) private returns (uint) {
        if (currentlevelKeycount >= conditionKeyPriceIncrease && _nowtime >= timeKeyLevepUp){
            
             
            keyPrice = keyPrice.mul(decimalPercent + percentKeyPriceIncrease) / decimalPercent;
            
             
            timeKeyLevepUp = _nowtime + timeKeyPriceIncrease;
            
             
            if (conditionKeyPriceIncrease <= conditionKeyPriceAttenuation ){
                conditionKeyPriceIncrease = 1;
            }else{
                conditionKeyPriceIncrease = conditionKeyPriceIncrease - conditionKeyPriceAttenuation;
            }
            
            
            currentlevelKeycount = 0;
            emit onKeyLevelUp(keyPrice);
        }
        return keyPrice;
    }
    
    
    function _calcCheckoutTime(uint256 _now) private {
        uint256 _flagtime = 1536652800;   
        if (checkoutTime == 0) {
            checkoutTime = _flagtime;
        }
        while (_now > checkoutTime) {
            checkoutTime = checkoutTime + checkOutinterval;
        }
    }
    
    function _checkoutCost() private {
        if (costPot > 0){
            costaddr.transfer(costPot);
        }
    }
    
     
    function _newGame(uint256 _starttime) private {
        uint256 i = 0;
        startTime = _starttime;
        _calcCheckoutTime(startTime);
        endTime = startTime + endTimeSettingInit;
        timeKeyLevepUp = _starttime + timeKeyPriceIncrease;
        
        _setPotValue(nextroundPot, startTime);
    
        currentlevelKeycount = 0;
        timeKeyLevepUp = 0;    
        sharenumEveryKey = 0;
        sharePotUnTreate = 0;   
        checkoutCurr = 0;
        
         
        for(i=0; i<useraddrs.length; i++){
            userkeys[useraddrs[i]] = 0;
        }
        useraddrs.length = 0;
        
        for(i=0; i<useraddrs_nextround.length; i++){
            userkeys_nextround[useraddrs_nextround[i]] = 0;
        }
        useraddrs_nextround.length = 0;
    }
    
     
     
    function CheckOut(uint256 _executeCount) public returns (uint256) {
        uint256 _now = now;
        uint256 executeCount = 0;
        uint256 i=0;
        uint256 j=0;
        bool overflag = false;
        uint256 rst = 0;
        
        require(_now >= checkoutTime, "not ready to checkOut");
        
        if(_executeCount == 0){
            executeCount = 100;   
        }

        
         
        _checkoutCost();
        
         
        if (sharePotUnTreate == 0){
            if (isActivate(_now)){
                sharePotUnTreate = sharePot.mul(percentShareOnetime) / decimalPercent;
                sharenumEveryKey = sharePotUnTreate.mul(decimalPercent) / allKeyNum;
            }else{
                sharePotUnTreate = sharePot;
                sharenumEveryKey = sharePotUnTreate.mul(decimalPercent) / allKeyNum;
            }
            
        }
        
         
        if (!isActivate(_now)){
             
            BigWinner memory tmpBW = BigWinner(0,0);
            for (i=0; i<3; i++){
                for(j=i; i<3; j++){
                    if (bigWinner[i].timestamp < bigWinner[j].timestamp){
                        tmpBW.addr = bigWinner[i].addr;
                        tmpBW.timestamp = bigWinner[i].timestamp;
                        bigWinner[i].addr = bigWinner[j].addr;
                        bigWinner[i].timestamp = bigWinner[j].timestamp;
                        bigWinner[j].addr = tmpBW.addr;
                        bigWinner[j].timestamp = tmpBW.timestamp;
                    }
                }
            }
            
             
            for(i=0; i<3; i++){
                bigWinner[i].addr.transfer(bigwinPot.mul(scaleBigwin[i]) / decimalPercent);
            }
            
             
            overflag = true;
        }
        
         
        for (i=0; i<executeCount; i++){
            if (checkoutCurr >= useraddrs.length) {
                 
                checkoutCurr = 0;
                allKeyNum = allKeyNum.add(allKeyNum_next);
                sharePot = sharePot.add(sharePot_next);
                break;
            }else{
                address  uaddr = useraddrs[checkoutCurr];
                uaddr.transfer(userkeys[uaddr] * sharenumEveryKey);
                checkoutCurr++;
            }
        }
        
        if(checkoutCurr == 0){
            rst = 0;
        }else{
            rst = useraddrs.length - checkoutCurr;
        }
        
        
         
        if(overflag){
            _newGame(_now + nextroundInterval);
        }
        
        return rst;
    }
    
    
    
     
    function _setPotValue(uint256 _value, uint256 _now) private {
        if (_now > checkoutTime){
            sharePot_next = sharePot_next.add(_value.mul(percentShare) / decimalPercent);
        }else{
            sharePot = sharePot.add(_value.mul(percentShare) / decimalPercent);
        }
        
        bigwinPot = bigwinPot.add(_value.mul(percentBigwin) /  decimalPercent);
        nextroundPot = nextroundPot.add(_value.mul(percentNextround) /  decimalPercent);
        costPot = costPot.add(_value.mul(percentCost) /  decimalPercent);
    }
    
     
    function _setUserInfo(address _useraddr, uint256 _nkeys, uint256 _now) private {
        if (_now > checkoutTime){
             
            if (userkeys_nextround[_useraddr] == 0) {
                useraddrs_nextround.push(_useraddr);
            }
            userkeys_nextround[_useraddr] = userkeys_nextround[_useraddr].add(_nkeys);
        }else{   
             
            if (userkeys[_useraddr] == 0) {
                useraddrs.push(_useraddr);
            }
            userkeys[_useraddr] = userkeys[_useraddr].add(_nkeys);
        }
    }
    
    function _setAllKeys(uint256 _nkeys, uint256 _now) private {
        
        currentlevelKeycount = currentlevelKeycount.add(_nkeys / decimalPercent);
        
         
        if (_now > checkoutTime){
            allKeyNum = allKeyNum.add(_nkeys);    
        }else{
             
            allKeyNum_next = allKeyNum_next.add(_nkeys);
        }
    }
    
    
    
    function _calcEndTime(uint256 _now) private {
        uint256 timediff = endTime - _now;
        
        if ( timediff >= endTimeSettingMax){
            return;   
        }else if(timediff < endTimeSettingMax && timediff >= endTimeSettingMin){
            endTime = _now + endTimeSettingIncrease1;
        }else if(timediff < endTimeSettingMin ){
            endTime = _now + endTimeSettingIncrease2;
        }
    }
    
     
    function _setBigWinner (address _useraddr, uint256 _nkeys, uint256 _now) private {
        uint256 intKeys = _nkeys / decimalPercent;
        if (intKeys < 1){
            return;   
        }
        
        lastWinnerTime = _now;
        
        if(intKeys >=3){
            for (uint i=0; i<3; i++){
                bigWinner[i].addr = _useraddr;
                bigWinner[i].timestamp = _now;
            }
        }else if(intKeys == 2){  
            uint256 tmpstamp = 0;
            uint256 curr = 99;
            
             
            for (uint n=0; n<3; n++){
               if(bigWinner[n].timestamp >= tmpstamp){
                   tmpstamp = bigWinner[n].timestamp;
                   curr = n;
               }
            }
            
             
            if (curr == 99){   
                bigWinner[0].addr = _useraddr;
                bigWinner[0].timestamp = _now;                
                bigWinner[1].addr = _useraddr;
                bigWinner[2].timestamp = _now;    
            }else{
                for (uint k=0; k<3; k++){
                    if(curr != k){
                        bigWinner[k].addr = _useraddr;
                        bigWinner[k].timestamp = _now;
                    }
                }
            }
            
        }else if(intKeys == 1){
            uint256 tmpstamp2 = 999999999999;
            uint256 curr2 = 99;
            
             
            for (uint j=0; j<3; j++){
               if(bigWinner[j].timestamp < tmpstamp2){
                   tmpstamp2 = bigWinner[j].timestamp;
                   curr2 = j;
               }
            }
            
            if(curr2 == 99){
                bigWinner[0].addr = _useraddr;
                bigWinner[0].timestamp = _now;   
            }else{
                bigWinner[curr2].addr = _useraddr;
                bigWinner[curr2].timestamp = _now;  
            }
        }
        
         
        _calcEndTime(_now);
    }
    
    function isActivate(uint256 _now) public view returns (bool) {
        return (_now > startTime && _now < endTime);
    }
    
     
    function() payable public isHuman() validValue (msg.value){
        
        uint256 nowtime = now;
        
        require(isActivate(nowtime), "error game not open");
        
         
        uint256 nkeys = msg.value.mul(decimalPercent) / keyPrice;    
        require(nkeys >= 6000, "to litte eth");    
        
         
        _setUserInfo(msg.sender, nkeys, nowtime);
        
         
        _setAllKeys(nkeys, nowtime);
        
         
        _updateKeyPrice(nowtime);
        
         
        _setPotValue(msg.value, nowtime);
        
         
        _setBigWinner(msg.sender, nkeys, nowtime);
        
    }
    
    constructor() public{
        
         
        startTime = now;
        _calcCheckoutTime(startTime);
        endTime = startTime + endTimeSettingInit;
        timeKeyLevepUp = startTime + timeKeyPriceIncrease;
        
        for (uint i=0; i<3; i++){
            bigWinner[i].addr = 0;
            bigWinner[i].timestamp = 0;
        }
    }
}