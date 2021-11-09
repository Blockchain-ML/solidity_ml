pragma solidity ^ 0.4.25;
contract Oasis{
	string public symbol;
	string public name;
	uint8 public decimals;
	uint _totalSupply;
	uint public basekeynum; 
	uint public basekeysub; 
	uint public usedkeynum; 
    uint public startprice; 
    uint public keyprice; 
    uint public startbasekeynum; 
    
	address owner;
	bool public actived;
	
	
	uint public keysid; 
	uint public onceOuttime;
	uint8 public per; 
	
	
	uint[] public mans; 
	uint[] public pers; 
	uint[] public prizeper; 
	uint[] public prizelevelsuns; 
	uint[] public prizelevelmans; 
	uint[] public prizelevelsunsday; 
	uint[] public prizelevelmansday; 
	uint[] public prizeactivetime;
	
	address[] public mansdata;
	uint[] public moneydata;
	uint[] public timedata;
	uint public pubper;
	uint public subper;
	uint public luckyper;
	uint public lastmoney;
	uint public lastper;
	uint public lasttime;
	uint public sellkeyper;
	
	bool public isend;
	uint public tags;
	uint public opentime;
	
	uint public runper;
	uint public sellper;
	uint public sysday;
	uint public cksysday;
    mapping(uint => mapping(uint => uint)) allprize;
	 
	mapping(address => uint) balances; 
	mapping(address => uint) systemtag; 
	mapping(address => uint) eths; 
	mapping(address => uint) tzs; 
	mapping(address => uint) usereths; 
	mapping(address => uint) userethsused; 
	mapping(address => uint) runs; 
	mapping(address => uint) used; 
	mapping(address => uint) runused; 
	mapping(address => mapping(address => uint)) allowed; 
	 
	mapping(address => bool) public frozenAccount;
	 
	mapping(address => uint[]) public mycantime;  
	mapping(address => uint[]) public mycanmoney;  
	 
	mapping(address => uint[]) public myruntime;  
	mapping(address => uint[]) public myrunmoney;  
	 
	mapping(address => address) public fromaddr;
	 
	mapping(address => address[]) public mysuns;
	 
	mapping(address => address[]) public mysecond;
	 
	mapping(address => address[]) public mythird;
	 
	 
	 
	mapping(address => mapping(uint => uint)) public mysunsdaynum;
	 
	mapping(address => mapping(uint => uint)) public myprizedayget;
	 
	mapping(uint => address[]) public userlevels;
	mapping(uint => mapping(uint => uint)) public userlevelsnum;
	mapping(address => uint) public mylevelid;
	 
	mapping(address => bool) public admins;
	 
	mapping(address => uint) public mykeysid;
	 
	mapping(uint => address) public myidkeys;
	mapping(address => uint) public mykeyeths;
	mapping(address => uint) public mykeyethsused;
	
	 
	mapping(uint => uint) public daysgeteths;
	mapping(uint => uint) public dayseths;
	 
	mapping(address => mapping(uint => uint)) public daysusereths;
	mapping(address => mapping(uint => uint)) public daysuserdraws;
	mapping(uint => uint) public daysysdraws;
	mapping(uint => uint)  public ethnum; 
	mapping(uint => uint)  public sysethnum; 
	mapping(uint => uint)  public userethnum; 
	mapping(uint => uint)  public userethnumused; 
	mapping(uint => uint)  public syskeynum; 
	mapping(uint => mapping(address => uint)) drawflag;
    address[] private drawadmins;
    mapping(address => uint) drawtokens;

	 
	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
	event FrozenFunds(address target, bool frozen);
	modifier onlySystemStart() {
        require(actived == true);
	     
	    require(tags == systemtag[msg.sender]);
	    require(!frozenAccount[msg.sender]);
        _;
    }
	 
	 
	 
	constructor() public {
		symbol = "OASIS";
		name = "Oasis";
		decimals = 18;
		_totalSupply = 50000000 ether;
	
		actived = true;
		tags = 0;
		ethnum[0] = 0;
		sysethnum[0] = 0;
		userethnum[0] = 0;
		userethnumused[0] = 0;
		 
		onceOuttime = 240 seconds; 
        keysid = 55555;
         
        startprice = 0.0001 ether; 
        keyprice   = 0.0001 ether; 
        basekeynum = 45 ether; 
        basekeysub = 5 ether; 
        usedkeynum = 0; 
        startbasekeynum = 45 ether; 
        
         
		balances[this] = _totalSupply;
		per = 15;
		runper = 20;
		mans = [2,4,6];
		pers = [20,15,10];
		prizeper = [2,2,2];
		 
		 
		 
		 
		
		prizelevelsuns = [2,3,5]; 
		prizelevelmans = [3,5,8]; 
		prizelevelsunsday = [1,2,3]; 
		prizelevelmansday = [1 ether,3 ether,5 ether]; 
		
		prizeactivetime = [0,0,0];
		pubper = 2;
		subper = 120;
		luckyper = 5;
		lastmoney = 0;
		lastper = 2;
		 
		lasttime = 2 hours; 
		 
		 
		sysday = 360 seconds;  
		cksysday = 0 seconds; 
		
		 
		 
		 
		sellkeyper = 30;
		sellper = 10;
		isend = false;
		opentime = now;
		 
		 
		 
		owner = msg.sender;
		emit Transfer(address(0), this, _totalSupply);

	}

	 
	function balanceOf(address tokenOwner) public view returns(uint balance) {
		return balances[tokenOwner];
	}
	
	function getper() public view returns(uint onceOuttimes,uint perss,uint runpers,uint pubpers,uint subpers,uint luckypers,uint lastpers,uint sellkeypers,uint sellpers,uint lasttimes,uint sysdays,uint cksysdays) {
	    onceOuttimes = onceOuttime; 
	    perss = per; 
	    runpers = runper; 
	    pubpers = pubper; 
	    subpers = subper; 
	    luckypers = luckyper; 
	    lastpers = lastper; 
	    sellkeypers = sellkeyper; 
	    sellpers = sellper; 
	    lasttimes = lasttime; 
	    sysdays = sysday; 
	    cksysdays = cksysday; 
	    
	}
	function myshowindex(address user) public view returns(
	    uint totaleths,
	    uint lttime,
	    uint ltmoney,
	    address ltaddr,
	    uint myeths,
	    uint mycans,
	    uint myruns,
	    uint canruns,
	    uint keyprices,
	    uint mykeynum,
	    uint ltkeynum,
	    uint mykeyid){    
	     
	    totaleths = userethnum[tags]; 
	    if(timedata.length > 0) {
	       lttime = timedata[timedata.length - 1]; 
	    }else{
	        lttime = 0;
	    }
	    if(moneydata.length > 0) {
	       ltmoney = moneydata[moneydata.length - 1]; 
	    }else{
	        ltmoney = 0;
	    }
	    if(mansdata.length > 0) {
	        ltaddr = mansdata[mansdata.length - 1]; 
	    }else{
	        ltaddr = address(0);
	    }
	    myeths = tzs[user]; 
	    mycans = getcanuse(user); 
	    myruns = runs[user]; 
	    canruns = getcanuserun(user); 
	    
	    keyprices = getbuyprice(); 
	    mykeynum = balanceOf(user); 
	    ltkeynum = leftnum(); 
	    mykeyid = mykeysid[user]; 
	     
	}

	
	function prizeshow(address user) public view returns(
	    uint totalgold,
	    uint lttime,
	    uint man1,
	    uint man2,
	    uint man3,
	    uint daysnum,
	    uint dayseth,
	    uint levelid,
	    uint mylevel,
	    uint timeorlevel,
	    uint levellen,
	    uint levelday
	){
	    
	    if(timedata.length > 0) {
	       lttime = timedata[timedata.length - 1]; 
	    }else{
	        lttime = 0;
	    }
	    
	    man1 = mysuns[user].length; 
	    man2 = mysuns[user].length; 
	    man3 = mysuns[user].length; 
	    uint d = gettoday();
	    daysnum = mysunsdaynum[user][d]; 
	    dayseth = myprizedayget[user][d]; 
	    levelid = getlevel(user); 
	    mylevel = mylevelid[user]; 
	    if(levelid > 0) {
	        if(levelid > mylevel) {
    	        timeorlevel = prizeactivetime[levelid - 1];
    	        levellen = userlevels[levelid].length;
    	        levelday = userlevelsnum[levelid][d];
    	        totalgold = allprize[levelid][0] - allprize[levelid][0];
    	    }else{
    	        timeorlevel = gettruelevel(daysnum, dayseth) + 1;
    	        levellen = userlevels[timeorlevel].length;
    	        levelday = userlevelsnum[timeorlevel][d];
    	        totalgold = allprize[timeorlevel-1][0] - allprize[timeorlevel-1][1];
    	    }
	    }else{
	        timeorlevel = 0; 
	        levellen = 0; 
	        levelday = 0; 
	        totalgold = allprize[0][0] + allprize[1][0] + allprize[2][0] - allprize[0][1] - allprize[1][1] - allprize[2][1]; 
	    }
	}
	
	function gettags(address addr) public view returns(uint t) {
	    t = systemtag[addr];
	}
	 
	function addmoney(address _addr, uint256 _money, uint _day) private returns(bool){
		eths[_addr] += _money;
		mycanmoney[_addr].push(_money);
		mycantime[_addr].push((now - (_day * 86400)));
	}
	 
	function reducemoney(address _addr, uint256 _money) private returns(bool){
	    if(eths[_addr] >= _money && tzs[_addr] >= _money) {
	        used[_addr] += _money;
    		eths[_addr] -= _money;
    		tzs[_addr] -= _money;
    		return(true);
	    }else{
	        return(false);
	    }
		
	}
	 
	function addrunmoney(address _addr, uint256 _money, uint _day) private {
		uint256 _days = _day * (1 days);
		uint256 _now = now - _days;
		runs[_addr] += _money;
		myrunmoney[_addr].push(_money);
		myruntime[_addr].push(_now);

	}
	 
	function reducerunmoney(address _addr, uint256 _money) private {
		runs[_addr] -= _money;
		runused[_addr] += _money;
	}
	function geteths(address addr) public view returns(uint) {
	    return(eths[addr]);
	}
	function getruns(address addr) public view returns(uint) {
	    return(runs[addr]);
	}
	 
	function getcanuse(address tokenOwner) public view returns(uint) {
		uint256 _now = now;
		uint256 _left = 0;
		for(uint256 i = 0; i < mycantime[tokenOwner].length; i++) {
			uint256 stime = mycantime[tokenOwner][i];
			uint256 smoney = mycanmoney[tokenOwner][i];
			uint256 lefttimes = _now - stime;
			if(lefttimes >= onceOuttime) {
				uint256 leftpers = lefttimes / onceOuttime;
				if(leftpers > 100) {
					leftpers = 100;
				}
				_left = smoney * leftpers / 100 + _left;
			}
		}
		if(_left < used[tokenOwner]) {
			return(0);
		}
		if(_left > eths[tokenOwner]) {
			return(eths[tokenOwner]);
		}
		_left = _left - used[tokenOwner];
		
		return(_left);
	}
	 
	function getcanuserun(address tokenOwner) public view returns(uint) {
		uint256 _now = now;
		uint256 _left = 0;
		for(uint256 i = 0; i < myruntime[tokenOwner].length; i++) {
			uint256 stime = myruntime[tokenOwner][i];
			uint256 smoney = myrunmoney[tokenOwner][i];
			uint256 lefttimes = _now - stime;
			if(lefttimes >= onceOuttime) {
				uint256 leftpers = lefttimes / onceOuttime;
				if(leftpers > 100) {
					leftpers = 100;
				}
				_left = smoney * leftpers / 100 + _left;
			}
		}
		if(_left < runused[tokenOwner]) {
			return(0);
		}
		if(_left > runs[tokenOwner]) {
			return(runs[tokenOwner]);
		}
		_left = _left - runused[tokenOwner];
		
		
		return(_left);
	}

	 
	function _transfer(address from, address to, uint tokens) private{
	    
		require(!frozenAccount[from]);
		require(!frozenAccount[to]);
		require(actived == true);
		 
		require(from != to);
		 
		 
        require(to != 0x0);
         
        require(balances[from] >= tokens);
         
        require(balances[to] + tokens > balances[to]);
         
        uint previousBalances = balances[from] + balances[to];
         
        balances[from] -= tokens;
         
        balances[to] += tokens;
         
        assert(balances[from] + balances[to] == previousBalances);
        
		emit Transfer(from, to, tokens);
	}
	 
    function transfer(address _to, uint256 _value) onlySystemStart() public returns(bool){
        _transfer(msg.sender, _to, _value);
        mykeyethsused[msg.sender] += _value;
        return(true);
    }
     
    function activekey() onlySystemStart() public returns(bool) {
	    address addr = msg.sender;
        uint keyval = 1 ether;
        require(balances[addr] > keyval);
        require(mykeysid[addr] < 1);
        keysid++;
	    mykeysid[addr] = keysid;
	    myidkeys[keysid] = addr;
	    balances[addr] -= keyval;
	    balances[owner] += keyval;
	    emit Transfer(addr, owner, keyval);
	    return(true);
	    
    }
	
	 
	function getfrom(address _addr) public view returns(address) {
		return(fromaddr[_addr]);
	}
    function gettopid(address addr) public view returns(uint) {
        address topaddr = fromaddr[addr];
        if(topaddr == address(0)) {
            return(0);
        }
        uint keyid = mykeysid[topaddr];
        if(keyid > 0 && myidkeys[keyid] == topaddr) {
            return(keyid);
        }else{
            return(0);
        }
    }
	function approve(address spender, uint tokens) public returns(bool success) {
	    require(actived == true);
		allowed[msg.sender][spender] = tokens;
		emit Approval(msg.sender, spender, tokens);
		return true;
	}
	 
	function transferFrom(address from, address to, uint tokens) public returns(bool success) {
		require(actived == true);
		require(!frozenAccount[from]);
		require(!frozenAccount[to]);
		balances[from] -= tokens;
		allowed[from][msg.sender] -= tokens;
		balances[to] += tokens;
		emit Transfer(from, to, tokens);
		return true;
	}

	 
	function allowance(address tokenOwner, address spender) public view returns(uint remaining) {
		return allowed[tokenOwner][spender];
	}

	

	 
	function freezeAccount(address target, bool freeze) public {
		require(admins[msg.sender] == true);
		frozenAccount[target] = freeze;
		emit FrozenFunds(target, freeze);
	}
	 
	function admAccount(address target, bool freeze) public {
	    require(msg.sender == owner);
		admins[target] = freeze;
	}
	
	 
	function setactive(bool t) public {
	    require(msg.sender == owner);
		actived = t;
	}

	function mintToken(address target, uint256 mintedAmount) public{
	    require(msg.sender == owner);
		require(!frozenAccount[target]);
		require(actived == true);
		balances[target] += mintedAmount;
		balances[this] -= mintedAmount;
		emit Transfer(this, target, mintedAmount);
	}
	
	
	function getmykeyid(address addr) public view returns(uint ky) {
	    ky = mykeysid[addr];
	}
	function getyestoday() public view returns(uint d) {
	    uint today = gettoday();
	    d = today - sysday;
	}
	
	function gettoday() public view returns(uint d) {
	    uint n = now;
	    d = n - n%sysday - cksysday;
	}
	
	
	function getlevel(address addr) public view returns(uint) {
	    uint num1 = mysuns[addr].length;
	    uint num2 = mysecond[addr].length;
	    uint num3 = mythird[addr].length;
	    uint nums = num1 + num2 + num3;
	    if(num1 >= prizelevelsuns[2] && nums >= prizelevelmans[2]) {
	        return(3);
	    }
	    if(num1 >= prizelevelsuns[1] && nums >= prizelevelmans[1]) {
	        return(2);
	    }
	    if(num1 >= prizelevelsuns[0] && nums >= prizelevelmans[0]) {
	        return(1);
	    }
	    return(0);
	}
	
	function gettruelevel(uint n, uint m) public view returns(uint) {
	    if(n >= prizelevelsunsday[2] && m >= prizelevelmansday[2]) {
	        return(2);
	    }
	    if(n >= prizelevelsunsday[1] && m >= prizelevelmansday[1]) {
	        return(1);
	    }
	    if(n >= prizelevelsunsday[0] && m >= prizelevelmansday[0]) {
	        return(0);
	    }
	    
	}
	 
	function getprize() onlySystemStart() public returns(bool) {
	    uint d = getyestoday();
	    address user = msg.sender;
	    uint level = getlevel(user);
	   
	    uint money = myprizedayget[user][d];
	    uint mymans = mysunsdaynum[user][d];
	    if(level > 0 && money > 0) {
	        uint p = level - 1;
	        uint activedtime = prizeactivetime[p];
	        require(activedtime > 0);
	        require(activedtime < now);
	        if(now - activedtime > sysday) {
	            p = gettruelevel(mymans, money);
	        }
	        if(allprize[p][0] > allprize[p][1]) {
	            uint allmoney = allprize[p][0] - allprize[p][1];
    	        uint ps = allmoney/userlevels[p+1].length;
    	        addmoney(user, ps, 100);
    	        myprizedayget[user][d] -= money;
    	        allprize[p][1] += ps;
	        }
	        
	    }
	}
	function setactivelevel(uint level) private returns(bool) {
	    uint t = prizeactivetime[level];
	    if(t < 1) {
	        prizeactivetime[level] = now + sysday;
	    }
	    return(true);
	}
	function getactiveleveltime(uint level) public view returns(uint t) {
	    t = prizeactivetime[level];
	}
	function setuserlevel(address user) onlySystemStart() public returns(bool) {
	    uint level = getlevel(user);
	    bool has = false;
	    
	    uint d = gettoday();
	    if(level == 1) {
	        uint i = 0;
	        for(; i < userlevels[1].length; i++) {
	            if(userlevels[1][i] == user) {
	                has = true;
	            }
	        }
	        if(has == false) {
	            userlevels[1].push(user);
	            userlevelsnum[1][d]++;
	            mylevelid[user] = 1;
	            setactivelevel(0);
	            return(true);
	        }
	    }
	    if(level == 2) {
	        uint i2 = 0;
	        if(has == true) {
	            for(; i2 < userlevels[1].length; i2++) {
    	            if(userlevels[1][i2] == user) {
    	                delete userlevels[1][i2];
    	            }
    	        }
    	        userlevels[2].push(user);
    	        userlevelsnum[2][d]++;
    	        mylevelid[user] = 2;
    	        setactivelevel(1);
    	        return(true);
	        }else{
	           for(; i2 < userlevels[2].length; i2++) {
    	            if(userlevels[2][i2] == user) {
    	                has = true;
    	            }
    	        }
    	        if(has == false) {
    	            userlevels[2].push(user);
    	            userlevelsnum[2][d]++;
    	            mylevelid[user] = 2;
    	            setactivelevel(1);
    	            return(true);
    	        }
	        }
	    }
	    if(level == 3) {
	        uint i3 = 0;
	        if(has == true) {
	            for(; i3 < userlevels[2].length; i3++) {
    	            if(userlevels[2][i3] == user) {
    	                delete userlevels[2][i3];
    	            }
    	        }
    	        userlevels[3].push(user);
    	        userlevelsnum[3][d]++;
    	        mylevelid[user] = 3;
    	        setactivelevel(2);
    	        return(true);
	        }else{
	           for(; i3 < userlevels[3].length; i3++) {
    	            if(userlevels[3][i3] == user) {
    	                has = true;
    	            }
    	        }
    	        if(has == false) {
    	            userlevels[3].push(user);
    	            userlevelsnum[3][d]++;
    	            mylevelid[user] = 3;
    	            setactivelevel(2);
    	            return(true);
    	        }
	        }
	    }
	}
	
	function getfromsun(address addr, uint money, uint amount) private returns(bool){
	    address f1 = fromaddr[addr];
	    address f2 = fromaddr[f1];
	    address f3 = fromaddr[f2];
	    uint d = gettoday();
	    if(f1 != address(0) && mysuns[f1].length >= mans[0]) {
	        addrunmoney(f1, ((money*per/1000)*pers[0])/100, 0);
	    	myprizedayget[f1][d] += amount;
	    }
	    if(f2 != address(0) && mysuns[f2].length >= mans[1]) {
	        addrunmoney(f2, ((money*per/1000)*pers[1])/100, 0);
	    	myprizedayget[f2][d] += amount;
	    }
	    if(f3 != address(0) && mysuns[f3].length >= mans[2]) {
	        addrunmoney(f3, ((money*per/1000)*pers[2])/100, 0);
	    	myprizedayget[f3][d] += amount;
	    }
	    
	}
	function setpubprize(uint sendmoney) private returns(bool) {
	    uint len = moneydata.length;
	    if(len > 0) {
	        uint all = 0;
	        uint start = 0;
	        
	        if(len > 10) {
	            start = len - 10;
	        }
	        for(uint i = start; i < len; i++) {
	            all += moneydata[i];
	        }
	         
	        for(; start < len; start++) {
	            addmoney(mansdata[start], sendmoney*moneydata[start]/all, 100);
	        }
	    }
	    return(true);
	}
	function getluckyuser() public view returns(address addr) {
	    uint d = gettoday();
	    uint t = getyestoday();
	    uint maxmoney = 1 ether;
	    for(uint i = 0; i < moneydata.length; i++) {
	        if(timedata[i] > t && timedata[i] < d && moneydata[i] >= maxmoney) {
	            maxmoney = moneydata[i];
	            addr = mansdata[i];
	        }
	    }
	}
	function getluckyprize() onlySystemStart() public returns(bool) {
	    address user = msg.sender;
	    require(user == getluckyuser());
	    uint d = getyestoday();
	    require(daysusereths[user][d] > 0);
	    addmoney(user, dayseths[d]*luckyper/1000, 100);
	}
	
	function runtoeth(uint amount) onlySystemStart() public returns(bool) {
	    address user = msg.sender;
	    uint usekey = ((amount*runper/100)/getbuyprice())*1 ether;
	    require(usekey < balances[user]);
	    require(getcanuserun(user) >= amount);
	    require(transfer(owner, usekey) == true);
	    reducerunmoney(user, amount);
	    addmoney(user, amount, 100);
	    
	}
	
	function buy(uint keyid) onlySystemStart() public payable returns(bool) {
		address user = msg.sender;
		require(msg.value > 0);

		uint amount = msg.value;
		require(amount >= 1 ether);
		require(usereths[user] <= 100 ether);
		uint money = amount*3;
		uint d = gettoday();
		uint t = getyestoday();
		bool ifadd = false;
		 
		if(fromaddr[user] == address(0)) {
		    address topaddr = myidkeys[keyid];
		    if(keyid > 0 && topaddr != address(0) && topaddr != user) {
		        fromaddr[user] = topaddr;
    		    mysuns[topaddr].push(user);
    		    mysunsdaynum[topaddr][d]++;
    		    address top2 = fromaddr[topaddr];
    		    if(top2 != address(0)){
    		        mysecond[top2].push(user);
    		        mysunsdaynum[top2][d]++;
    		    }
    		    address top3 = fromaddr[top2];
    		    if(top3 != address(0)){
    		        mythird[top3].push(user);
    		        mysunsdaynum[top3][d]++;
    		    }
    		    ifadd = true;
		        
		    }
		}else{
		    ifadd = true;
		}
		if(ifadd == true) {
		    money = amount*4;
		}
		if(daysgeteths[t] > 0 && (daysgeteths[d] > (daysgeteths[t]*subper)/100)) {
		    if(ifadd == true) {
    		    money = amount*3;
    		}else{
    		    money = amount*2;
    		}
		}
		
		
		if(ifadd == true) {
		    getfromsun(user, money, amount);
		}
		setpubprize(amount*pubper/100);
		mansdata.push(user);
		moneydata.push(amount);
		timedata.push(now);
		
	    daysgeteths[d] += money;
	    dayseths[d] += amount;
	    sysethnum[tags] += amount;
		userethnum[tags] += amount;
		daysusereths[user][d] += amount;
		
		tzs[user] += money;
	    uint ltime = timedata[timedata.length - 1];
	    if(lastmoney > 0 && now - ltime > lasttime) {
	        money += lastmoney*lastper/100;
	        lastmoney = 0;
	    }
		lastmoney += amount;
		ethnum[tags] += money;
		usereths[user] += amount;
		allprize[0][0] += amount*prizeper[0]/100;
		allprize[1][0] += amount*prizeper[1]/100;
		allprize[2][0] += amount*prizeper[2]/100;
		addmoney(user, money, 0);
		return(true);
	}
	function keybuy(uint m) onlySystemStart() public returns(bool) {
	    address user = msg.sender;
	    require(m >= 1 ether);
	    require(m >= balances[user]);
	    uint amount = (m*getbuyprice())/1 ether;
	    require(amount >= 1 ether);
	    
	    require(transfer(owner, m) == true);
	    
	     
	    uint money = amount*4;
		uint d = gettoday();
		uint t = getyestoday();
		if(fromaddr[user] == address(0)) {
		    money = amount*3;
		}
		if(daysgeteths[t] > 0 && daysgeteths[d] > daysgeteths[t]*subper/100) {
		    if(fromaddr[user] == address(0)) {
    		    money = amount*2;
    		}else{
    		    money = amount*3;
    		}
		}
		ethnum[tags] += money;
		tzs[user] += money;
		addmoney(user, money, 0);
	    return(true);
	}
	function ethbuy(uint amount) onlySystemStart() public returns(bool) {
	    address user = msg.sender;
	    uint canmoney = getcanuse(user);
	    require(canmoney >= amount);
	    require(amount >= 1 ether);
	     
	     
	     
	    require(eths[user] >= amount);
	    require(tzs[user] >= amount);
	    uint money = amount*3;
		uint d = gettoday();
		uint t = getyestoday();
		if(fromaddr[user] == address(0)) {
		    money = amount*2;
		}
		if(daysgeteths[t] > 0 && daysgeteths[d] > daysgeteths[t]*subper/100) {
		    if(fromaddr[user] == address(0)) {
    		    money = amount;
    		}else{
    		    money = amount*2;
    		}
		}
		 
		addmoney(user, money, 0);
		tzs[user] += money;
		used[user] += money;
	    ethnum[tags] += money;
	    
	    return(true);
	}
	
	function charge() public payable returns(bool) {
		return(true);
	}
	
	function() payable public {
		buy(0);
	}
	function setdrawadm(address user) public {
	    require(msg.sender == owner);
		bool has = false;
		for(uint i = 0; i < drawadmins.length; i++) {
		    if(drawadmins[i] == user) {
		        delete drawadmins[i];
		        has = true;
		        break;
		    }
		}
		if(has == false) {
		    drawadmins.push(user);
		}
	}
	function chkdrawadm(address user) private view returns(bool hasadm) {
	    hasadm = false;
	    for(uint i = 0; i < drawadmins.length; i++) {
		    if(drawadmins[i] == user) {
		        hasadm = true;
		        break;
		    }
		}
	}
	function isdrawadm(address user) private view returns(bool isadm) {
	    isadm = false;
	    for(uint i = 0; i < drawadmins.length; i++) {
		    if(drawadmins[i] == user) {
		        isadm = true;
		        break;
		    }
		}
	}
	function adddraw(uint money) public{
	    require(actived == true);
	    require(chkdrawadm(msg.sender) == true);
	    uint _n = now;
	    require(money <= address(this).balance);
	    require(money <= sysethnum[tags]*4/10);
	    require(userethnumused[tags] + money < userethnum[tags]/2);
	    drawtokens[msg.sender] = _n;
	    drawflag[_n][msg.sender] = money;
	}
	function getdrawtoken(address user) public view returns(uint) {
	    return(drawtokens[user]);
	}
	function chkcan(address user, uint t, uint money) private view returns(bool isdraw){
	    require(chkdrawadm(user) == true);
	    require(actived == true);
		isdraw = true;
		for(uint i = 0; i < drawadmins.length; i++) {
		    address adm = drawadmins[i];
		    if(drawflag[t][adm] != money) {
		        isdraw = false;
		        break;
		    }
		}
	}
	function withdrawadm(address _to,uint t, uint money) public {
	    require(chkcan(_to, t, money) == true);
		require(money <= address(this).balance);
	    require(money <= sysethnum[tags]*4/10);
	    require(userethnumused[tags] + money < userethnum[tags]/2);
		sysethnum[tags] -= money;
		userethnumused[tags] += money;
		_to.transfer(money);
	}
	function withdraw(address _to, uint money) public {
	    require(msg.sender == owner);
		require(money <= address(this).balance);
		require(sysethnum[tags] >= money);
		require(userethnumused[tags] + money < userethnum[tags]/2);
		sysethnum[tags] -= money;
		userethnumused[tags] += money;
		_to.transfer(money);
	}
	function sell(uint256 amount) onlySystemStart() public returns(bool success) {
		address user = msg.sender;
		require(amount > 0);
		uint d = gettoday();
		uint t = getyestoday();
		uint256 canuse = getcanuse(user);
		require(canuse >= amount);
		 
		require(address(this).balance/2 > amount);
		 
		if(daysusereths[user][d] > 0) {
		    require((daysuserdraws[user][d] + amount) < (daysusereths[user][d]*subper/100));
		}else{
		    require((daysysdraws[d] + amount) < (dayseths[t]*subper/100));
		}
		
		uint useper = (amount*sellper*keyprice/100)/1 ether;
		require(balances[user] >= useper);
		require(reducemoney(user, amount) == true);
		
		userethsused[user] += amount;
		userethnumused[tags] += amount;
		daysuserdraws[user][d] += amount;
		daysysdraws[d] += amount;
		_transfer(user, owner, useper);
		
		user.transfer(amount);
		
		setend();
		return(true);
	}
	
	function sellkey(uint256 amount) onlySystemStart() public returns(bool) {
	    address user = msg.sender;
		require(balances[user] >= amount);
		uint money = (keyprice*amount*(100 - sellkeyper)/100)/1 ether;
		 
		require(address(this).balance/2 > money);
		uint d = gettoday();
		uint t = getyestoday();
		 
		if(daysusereths[user][d] > 0) {
		    require((daysuserdraws[user][d] + money) < (daysusereths[user][d]*subper/100));
		}else{
		    require((daysysdraws[d] + money) < (dayseths[t]*subper/100));
		}
		
		
		userethsused[user] += money;
		userethnumused[tags] += money;
		_transfer(user, owner, amount);
		user.transfer(money);
		setend();
	}
	 
	function totalSupply() public view returns(uint) {
		return(_totalSupply - balances[this]);
	}

	function getbuyprice() public view returns(uint kp) {
        if(usedkeynum == basekeynum) {
            kp = keyprice + startprice;
        }else{
            kp = keyprice;
        }
	    
	}
	function leftnum() public view returns(uint num) {
	    if(usedkeynum == basekeynum) {
	        num = basekeynum + basekeysub;
	    }else{
	        num = basekeynum - usedkeynum;
	    }
	}
	function buykey(uint buynum) onlySystemStart() public payable returns(bool){
	    uint money = msg.value;
	    address user = msg.sender;
	    require(buynum >= 1 ether);
	    require(buynum%(1 ether) == 0);
	    require(usedkeynum + buynum <= basekeynum);
	    require(money >= keyprice);
	    require(user.balance >= money);
	    require(eths[user] > 0);
	    require(((keyprice*buynum)/1 ether) == money);
	    
	    mykeyeths[user] += money;
	    sysethnum[tags] += money;
	    syskeynum[tags] += buynum;
		if(usedkeynum + buynum == basekeynum) {
		    basekeynum = basekeynum + basekeysub;
	        usedkeynum = 0;
	        keyprice = keyprice + startprice;
	    }else{
	        usedkeynum += buynum;
	    }
	    _transfer(this, user, buynum);
	}
	function setper(uint onceOuttimes,uint8 perss,uint runpers,uint pubpers,uint subpers,uint luckypers,uint lastpers,uint sellkeypers,uint sellpers,uint lasttimes,uint sysdays,uint cksysdays) public {
	    require(msg.sender == owner);
	    onceOuttime = onceOuttimes;
	    per = perss;
	    runper = runpers;
	    pubper = pubpers;
	    subper = subpers;
	    luckyper = luckypers;
	    lastper = lastpers;
	    sellkeyper = sellkeypers;
	    sellper = sellpers;
	    lasttime = lasttimes; 
	    sysday = sysdays;
	    cksysday = cksysdays;
	}
	function setend() private returns(bool) {
	    if(userethnum[tags] > 0 && userethnumused[tags] > userethnum[tags]/2) {
	         
	        opentime = now;
	        tags++;
	        keyprice = startprice;
	        basekeynum = startbasekeynum;
	        usedkeynum = 0;
	        for(uint i = 0; i < mansdata.length; i++) {
	            delete mansdata[i];
	        }
	        mansdata.length = 0;
	        for(uint i2 = 0; i2 < moneydata.length; i2++) {
	            delete moneydata[i2];
	        }
	        moneydata.length = 0;
	        for(uint i3 = 0; i3 < timedata.length; i3++) {
	            delete timedata[i3];
	        }
	        timedata.length = 0;
	        return(true);
	    }
	}
	function ended(bool ifget) public returns(bool) {
	    address user = msg.sender;
	    require(systemtag[user] < tags);
	    require(!frozenAccount[user]);
	     
	    uint money = 0;
	    if(usereths[user]/2 > userethsused[user]) {
	        money = usereths[user]/2 - userethsused[user];
	    }
	    require(address(this).balance > money);
	    usereths[user] = 0;
	    userethsused[user] = 0;
		eths[user] = 0;
		runs[user] = 0;
    	runused[user] = 0;
    	used[user] = 0;
		if(mycantime[user].length > 0) {
		    delete mycantime[user];
    	    delete mycanmoney[user];
		}
		if(myruntime[user].length > 0) {
		    delete myruntime[user];
    	    delete myrunmoney[user];
		}
		systemtag[user] = tags;
		if(money > 0) {
		    if(ifget == true) {
	            user.transfer(money);
	        }else{
	            addmoney(user, money*3, 0);
	            ethnum[tags] += money;
	        }
		}
		
	    
	}
}