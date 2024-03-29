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

contract Settings {
     
    uint256 internal decimalPercent = 10000;
     
    uint256 internal percentBigwin = 5000;
    uint256 internal percentShare = 4500;
    uint256 internal percentNextround = 300;
    uint256 internal percentCost = 200;
    
    
     
    uint256 internal percentShareOnetime = 2000;
    
     
    uint256[3] internal scaleBigwin = [6000, 3000, 1000];
    
     
    uint256 internal percentExtendMain = 9000;
    uint256 internal percentExtendUpper = 800;
    uint256 internal percentExtendUpperUpper = 200;
    
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
    
    modifier validValue (uint256 _eth) {
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        require(_eth <= msg.value, "not valid value");
        _;
    }
    
}


contract BleedFomo is Ownable, Settings{
    
    using SafeMath for uint256;
    
    event onKeyLevelUp(uint256 _keyprice);
    
     
    event onDebug(uint256 _val);
    
    
     
    uint256 private keyPriceInit = 0.01 ether;
    uint256 private percentKeyPriceIncrease = 800;
    uint256 private conditionKeyPriceIncrease = 50;
    uint256 private conditionKeyPriceAttenuation = 4;
    uint256 private decimalKey = 8;
    
     
    uint256 private checkOutinterval =  5 hours;  
    uint256 private endTimeSettingInit = 1 days;
    uint256 private endTimeSettingMax = 30 minutes;
    uint256 private endTimeSettingMin = 10 minutes;
    uint256 private endTimeSettingIncrease1 = 1 minutes;
    uint256 private endTimeSettingIncrease2 = 20 minutes;
    uint256 private nextroundInterval = 2 hours;    
    uint256 private timeKeyPriceIncrease = 10 minutes;
    
     
    uint256 private bigwinPot = 0;
    uint256 private sharePot = 0;
    uint256 private sharePot_next = 0;
    uint256 private nextroundPot = 0;
    uint256 private costPot = 0;
    
    
    uint256 private keyPrice = 0;
    
    uint256 private allKeyNum = 0;
    uint256 private allKeyNum_next = 0;

    
     
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
    
    
     
    mapping (address => address) private userextend;
    
     
     
     
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
    
    function getCheckoutTime() public view returns (uint256){
        return checkoutTime;
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
    
    function getExtendAddr(address _useraddr) public view returns(address) {
        return userextend[_useraddr];
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
        uint256 _flagtime = 1537174200;   
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
            costPot = 0;
        }
    }
    
    function extendCost(uint256 _val) payable external {
        if (_val > 0 && _val <= msg.value){
            costPot.add(_val);
             
        }
    }
    
     
    function _newGame(uint256 _starttime) private {
        uint256 i = 0;
        startTime = _starttime;
        _calcCheckoutTime(startTime);
        endTime = startTime + endTimeSettingInit;
        timeKeyLevepUp = _starttime + timeKeyPriceIncrease;
        
        bigwinPot = 0;
        sharePot = 0;
        sharePot_next = 0;
        costPot = 0;
        _setPotValue(nextroundPot, startTime);
        
        keyPrice = keyPriceInit;

        allKeyNum = 0;
        allKeyNum_next = 0;
    
        currentlevelKeycount = 0;
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
        
        for (i=0; i<3; i++){
            bigWinner[i].addr = 0;
            bigWinner[i].timestamp = 0;
        }
    }
    
     
     
    function CheckOut(uint256 _executeCount) public returns (uint256) {
        uint256 _now = now;
        uint256 executeCount = 100;  
        uint256 i=0;
        uint256 j=0;
        uint256 k=0;
        bool overflag = false;
        uint256 tmpv1 = 0;
        uint256 rst = 0;
        
        require(_now >= checkoutTime, "not ready to checkOut");
        
        if(_executeCount > 0 &&  _executeCount < 1000){
            executeCount = _executeCount;
        }

        
         
        _checkoutCost();
        
        
         
        if (sharePotUnTreate == 0 && allKeyNum > 0){
            if (isActivate(_now)){
                sharePotUnTreate = sharePot.mul(percentShareOnetime) / decimalPercent;
            }else{
                sharePotUnTreate = sharePot;
            }
            
            sharenumEveryKey = sharePotUnTreate.mul(decimalPercent) / allKeyNum;
        }
        
        
         
        if ( !isActivate(_now) ){
             
            BigWinner memory tmpBW = BigWinner(0,0);
            for (i=0; i<3; i++){
                for(j=i; j<3; j++){
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
                tmpv1= bigwinPot.mul(scaleBigwin[i]) / decimalPercent;
                if (tmpv1 > 0){
                    bigWinner[i].addr.transfer(tmpv1);
                }
            }
             
            overflag = true;
        }
        
        
         
        if (sharePotUnTreate > 0){
            for (i=0; i<executeCount; i++){
                
                if (checkoutCurr >= useraddrs.length) {
                    
                     
                    checkoutCurr = 0;
                    allKeyNum = allKeyNum.add(allKeyNum_next);
                    allKeyNum_next = 0;
                    sharePot = sharePot.add(sharePot_next);
                    sharePot_next = 0;
                    sharePotUnTreate = 0;
                    
                    for(k=0; k<useraddrs_nextround.length; k++){
                        address _tmpaddr_next = useraddrs_nextround[k];
                        userkeys[_tmpaddr_next].add(userkeys_nextround[_tmpaddr_next]);
                        userkeys_nextround[_tmpaddr_next] = 0;
                    }
                    useraddrs_nextround.length = 0;
                    
                    _calcCheckoutTime(_now);
                    
                    break;
                }else{
                    
                    address  uaddr = useraddrs[checkoutCurr];
                    tmpv1 = userkeys[uaddr].mul(sharenumEveryKey) / decimalPercent;
                    if (tmpv1 > 0){
                        uaddr.transfer(tmpv1);
                        sharePot = sharePot.sub(tmpv1);
                    }
                    
                    checkoutCurr = checkoutCurr.add(1);
                }
            }
        }
        
        if(checkoutCurr == 0){
            rst = 0;
        }else{
            rst = useraddrs.length.sub(checkoutCurr);
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
    
     
    function _setUserInfo(address _useraddr, uint256 _nkeys, uint256 _now, address _upper, address _upperupper) private {
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
        
        
         
        if (userextend[_useraddr] == 0){
             
            if (_upper == 0){
                userextend[_useraddr] = new Extend(_useraddr, this, 0, 0);
            }else{
                if (_upperupper == 0) {
                    userextend[_useraddr] = new Extend(_useraddr, this, userextend[_upper], 0);
                }else{
                    userextend[_useraddr] = new Extend(_useraddr, this, userextend[_upper],  userextend[_upperupper]);
                }
            }
        }
        
    }
    
    function _setAllKeys(uint256 _nkeys, uint256 _now) private {
        
        currentlevelKeycount = currentlevelKeycount.add(_nkeys / decimalPercent);
        
         
        if (_now < checkoutTime){
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
    
    function joinGame(address _sender, uint256 _val, address _upper, address _upperupper) payable public  validValue(_val){
        
        uint256 nowtime = now;
        
        require(isActivate(nowtime), "error game not open");
        
         
        uint256 nkeys = _val.mul(decimalPercent) / keyPrice;    
        require(nkeys >= 6000, "to litte eth");    
        
         
        _setUserInfo(_sender, nkeys, nowtime, _upper, _upperupper);
        
         
        _setAllKeys(nkeys, nowtime);
        
         
        _updateKeyPrice(nowtime);
        
         
        _setPotValue(_val, nowtime);
        
         
        _setBigWinner(_sender, nkeys, nowtime);
        
    }
    
    
    
     
    function() payable public isHuman() validValue (msg.value){
        joinGame(msg.sender, msg.value, 0, 0);
    }
    
    constructor() public{
        
         
        _newGame(now);

    }
}

contract Extend is Settings{
    
    using SafeMath for uint256;
    
    address private extender = 0;    
    
     
    address private con_main = 0;
    address private con_upper = 0;  
    address private con_upperupper = 0;
    
    constructor(address _extender, address _con_main, address _con_upper, address _con_upperupper) public {
        extender = _extender;
        con_main = _con_main;
        con_upper = _con_upper;
        con_upperupper = _con_upperupper;
    }
    
    function transferExtender(uint256 _val) public validValue(_val) {
        extender.transfer(_val);
    }
    
    function getExtender() public view returns(address) {
        return extender;
    }
    
    function() payable public {
        
        joinGame(msg.sender, msg.value.mul(percentExtendMain) / decimalPercent);
        share(msg.value.mul(percentExtendUpper + percentExtendUpperUpper) / decimalPercent );
    }
    
    
    function share(uint256 _val) payable public validValue(_val) {
         
        if (con_upper == 0){
             
            BleedFomo bf = BleedFomo(con_main);
            con_main.transfer(_val);
            bf.extendCost(_val);
        }else{
            uint256 sharecurrent = _val.mul(percentExtendUpper) / (percentExtendUpper + percentExtendUpperUpper);
            uint256 shareupper = _val.mul(percentExtendUpperUpper) / (percentExtendUpper + percentExtendUpperUpper);
            transferExtender(sharecurrent);
            if (con_upperupper != 0){
                Extend ex = Extend(con_upperupper);
                ex.transferExtender(shareupper);
            }else{
                BleedFomo _bf = BleedFomo(con_main);
                con_main.transfer(shareupper);
                _bf.extendCost(shareupper);
            }
        }
    }
    
    function joinGame(address _sender, uint256 _val) payable public validValue(_val) {
         
        con_main.transfer(_val);
        BleedFomo bf = BleedFomo(con_main);
        
        address upperupper = 0;
        if (con_upper != 0){
            Extend ex = Extend(con_upper);
            upperupper = ex.getExtender();
        }
        
        bf.joinGame(_sender, _val, extender, upperupper);
    }
    
}