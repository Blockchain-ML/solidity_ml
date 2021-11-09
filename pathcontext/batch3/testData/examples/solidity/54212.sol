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
	uint[] public prizelevelmoneyday; 
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
	
	 
	uint public tags;
	uint public opentime;
	
	uint public runper;
	uint public sellper;
	uint public sysday;
	uint public cksysday;
	uint public nulldayeth;
    mapping(uint => mapping(uint => uint)) allprize;
	 
	mapping(address => uint) balances; 
	
	mapping(address => mapping(address => uint)) allowed; 
	 
	mapping(address => bool) public frozenAccount;
	 
	struct usercan{
	    uint eths;
	    uint used;
	    uint len;
	    uint[] times;
	    uint[] moneys;
	    uint[] amounts;
	}
	 
	mapping(address => usercan) mycan;  
	 
	mapping(address => usercan) myrun;
	struct userdata{
	    uint systemtag;
	    uint tzs;
	    uint usereths;
	    uint userethsused;
	    uint mylevelid;
	    uint mykeysid;
	    uint mykeyeths;
	    uint mykeyethsused;
	    uint prizecount;
	    address fromaddr;
	    address[] mysuns;
	    address[] mysecond;
	    address[] mythird;
	    mapping(uint => uint) mysunsdaynum;
	    mapping(uint => uint) myprizedayget;
	    mapping(uint => uint) daysusereths;
	    mapping(uint => uint) daysuserdraws;
	    mapping(uint => uint) daysuserlucky;
	    mapping(uint => uint) levelget;
	}
	mapping(address => userdata) my;
	
	mapping(uint => address[]) public userlevels;
	mapping(uint => mapping(uint => uint)) public userlevelsnum;
	
	 
	mapping(address => bool) public admins;
	
	 
	mapping(uint => address) public myidkeys;
	 
	mapping(uint => uint) public daysgeteths;
	mapping(uint => uint) public dayseths;
	 
	mapping(uint => uint) public daysysdraws;
	struct tagsdata{
	    uint ethnum; 
	    uint sysethnum; 
	    uint userethnum; 
	    uint userethnumused; 
	    uint syskeynum; 
	}
	mapping(uint => tagsdata) tg;
	drawInterface private drawBase;
	 
	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
	event FrozenFunds(address target, bool frozen);
	modifier onlySystemStart() {
        require(actived == true);
	     
	    require(tags == my[msg.sender].systemtag);
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
		tg[0] = tagsdata(0,0,0,0,0);
		 
		onceOuttime = 600 seconds; 
        keysid = 55555;
         
        nulldayeth = 5 ether; 
         
        
        startprice = 0.01 ether; 
        keyprice   = 0.01 ether; 
        basekeynum = 450 ether; 
        basekeysub = 50 ether; 
        usedkeynum = 0; 
        startbasekeynum = 450 ether; 
        
         
		balances[this] = _totalSupply;
		per = 15;
		runper = 20;
		mans = [2,4,6];
		pers = [20,15,10];
		prizeper = [2,2,2];
		 
		 
		 
		 
		
		prizelevelsuns = [2,2,2]; 
		prizelevelmans = [6,7,8]; 
		prizelevelsunsday = [1,2,3]; 
		prizelevelmoneyday = [1 ether,3 ether,5 ether]; 
		
		prizeactivetime = [0,0,0];
		pubper = 2;
		subper = 120;
		luckyper = 5;
		lastmoney = 0;
		lastper = 2;
		 
		lasttime = 1800 seconds; 
		 
		 
		sysday = 600 seconds;  
		cksysday = 0 seconds; 
		
		 
		 
		 
		sellkeyper = 70;
		sellper = 10;
		 
		opentime = now;
		 
		 
		 
		owner = msg.sender;
		emit Transfer(address(0), this, _totalSupply);

	}

	 
	function balanceOf(address tokenOwner) public view returns(uint balance) {
		return balances[tokenOwner];
	}
	
	
	function showlvzhou(address user) public view returns(
	    uint total,
	    uint mykeyid,
	    uint mytzs,
	    uint daysget,
	    uint prizeget,
	     
	    uint mycans,
	    uint mykeynum,
	    uint keyprices,
	    uint ltkeynum,
	    uint tagss,
	    uint mytags
	    
	){
	    total = tg[tags].userethnum; 
	    mykeyid = my[user].mykeysid; 
	    mytzs = my[user].tzs; 
	    daysget = my[user].usereths*per/1000; 
	    prizeget = my[user].prizecount; 
	     
	    mycans = getcanuse(user); 
	    mykeynum = balanceOf(user); 
	    keyprices = getbuyprice(); 
	    ltkeynum = leftnum(); 
	    tagss = tagss; 
	    mytags = my[user].systemtag; 
	}
	function showteam(address user) public view returns(
	    uint daysnum, 
	    uint dayseth, 
	    uint daysnum1, 
	    uint dayseth1, 
	    uint man1, 
	    uint man2, 
	    uint man3, 
	    uint myruns, 
	    uint canruns, 
	    uint levelid 
	){
	    uint d = gettoday();
	    uint t = getyestoday();
	    daysnum = my[user].mysunsdaynum[d]; 
	    dayseth = my[user].myprizedayget[d]; 
	    daysnum1 = my[user].mysunsdaynum[t]; 
	    dayseth1 = my[user].myprizedayget[t]; 
	    man1 = my[user].mysuns.length; 
	    man2 = my[user].mysecond.length; 
	    man3 = my[user].mythird.length; 
	    myruns = myrun[user].eths; 
	    canruns = getcanuserun(user); 
	    levelid = getlevel(user); 
	}
	function showlevel(address user) public view returns(
	    uint levelid, 
	    uint mylevel, 
	    uint len1, 
	    uint len2, 
	    uint len3, 
	    uint m1, 
	    uint m2, 
	    uint m3, 
	    uint t1, 
	    uint t2, 
	    uint t3, 
	    uint levelget 
	){
	    levelid = getlevel(user); 
	    mylevel = my[user].mylevelid; 
	    len1 = userlevels[1].length; 
	    len2 = userlevels[2].length; 
	    len3 = userlevels[3].length; 
	    m1 = allprize[0][0] - allprize[0][1]; 
	    m2 = allprize[1][0] - allprize[1][1]; 
	    m3 = allprize[2][0] - allprize[2][1]; 
	    t1 = prizeactivetime[0]; 
	    t2 = prizeactivetime[1]; 
	    t3 = prizeactivetime[2]; 
	    levelget = my[user].levelget[getyestoday()]; 
	}
	function showleveldetail(address user) public view returns(
	    uint daysnum, 
	    uint dayseth, 
	    uint truelevel, 
	    uint levelday1, 
	    uint levelday2, 
	    uint levelday3, 
	    uint totalgold, 
	    uint myget, 
	    uint levelget 
	){
	    uint t = getyestoday();
	    uint d = gettoday();
	    daysnum = my[user].mysunsdaynum[t]; 
	    dayseth = my[user].myprizedayget[t]; 
	     
	     
	     
	    levelday1 = userlevelsnum[1][d];
	    levelday2 = userlevelsnum[2][d];
	    levelday3 = userlevelsnum[3][d];
	    (truelevel, myget) = getprizemoney(user);
	    totalgold = allprize[truelevel-1][0] - allprize[truelevel-1][1];
	    levelget = my[user].levelget[t];
	}
	
	function showethconf(address user) public view returns(
	    uint todaymyeth,
	    uint todaymydraw,
	    uint todaysyseth,
	    uint todaysysdraw,
	    uint yestodaymyeth,
	    uint yestodaymydraw,
	    uint yestodaysyseth,
	    uint yestodaysysdraw
	){
	    uint d = gettoday();
		uint t = getyestoday();
		todaymyeth = my[user].daysusereths[d];
		todaymydraw = my[user].daysuserdraws[d];
		todaysyseth = dayseths[d];
		todaysysdraw = daysysdraws[d];
		yestodaymyeth = my[user].daysusereths[t];
		yestodaymydraw = my[user].daysuserdraws[t];
		yestodaysyseth = dayseths[t];
		yestodaysysdraw = daysysdraws[t];
		
	}
	function showprize(address user) public view returns(
	    uint lttime, 
	    uint ltmoney, 
	    address ltaddr, 
	    uint lastmoneys, 
	    address lastuser, 
	    uint luckymoney, 
	    address luckyuser, 
	    uint luckyget 
	){
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
	    lastmoneys = lastmoney;
	    lastuser = getlastuser();
	    uint d = getyestoday();
	    if(dayseths[d] > 0) {
	        luckymoney = dayseths[d]*luckyper/1000;
	        luckyuser = getluckyuser();
	        luckyget = my[user].daysuserlucky[d];
	    }else{
	        luckymoney = 0;
	        luckyuser = address(0);
	    }
	    
	}
	
	
	function gettags(address addr) public view returns(uint t) {
	    t = my[addr].systemtag;
	}
	 
	function addmoney(address _addr, uint256 _amount, uint256 _money, uint _day) private returns(bool){
		mycan[_addr].eths += _money;
		mycan[_addr].len++;
		mycan[_addr].amounts.push(_amount);
		mycan[_addr].moneys.push(_money);
		if(_day > 0){
		    mycan[_addr].times.push(0);
		}else{
		    mycan[_addr].times.push(now);
		}
		
	}
	 
	function reducemoney(address _addr, uint256 _money) private returns(bool){
	    if(mycan[_addr].eths >= _money && my[_addr].tzs >= _money) {
	        mycan[_addr].used += _money;
    		mycan[_addr].eths -= _money;
    		my[_addr].tzs -= _money;
    		return(true);
	    }else{
	        return(false);
	    }
		
	}
	 
	function addrunmoney(address _addr, uint256 _amount, uint256 _money, uint _day) private {
		myrun[_addr].eths += _money;
		myrun[_addr].len++;
		myrun[_addr].amounts.push(_amount);
		myrun[_addr].moneys.push(_money);
		if(_day > 0){
		    myrun[_addr].times.push(0);
		}else{
		    myrun[_addr].times.push(now);
		}
	}
	 
	function reducerunmoney(address _addr, uint256 _money) private {
		myrun[_addr].eths -= _money;
		myrun[_addr].used += _money;
	}
	function geteths(address addr) public view returns(uint) {
	    return(mycan[addr].eths);
	}
	function getruns(address addr) public view returns(uint) {
	    return(myrun[addr].eths);
	}
	 
	function getcanuse(address user) public view returns(uint _left) {
		if(mycan[user].len > 0) {
		    for(uint i = 0; i < mycan[user].len; i++) {
    			uint stime = mycan[user].times[i];
    			if(stime == 0) {
    			    _left += mycan[user].times[i];
    			}else{
    			    if(now - stime >= onceOuttime) {
    			        uint smoney = mycan[user].amounts[i] * ((now - stime)/onceOuttime) * per/ 1000;
    			        if(smoney <= mycan[user].moneys[i]){
    			            _left += smoney;
    			        }else{
    			            _left += mycan[user].moneys[i];
    			        }
    			    }
    			    
    			}
    		}
		}
		if(_left < mycan[user].used) {
			return(0);
		}
		if(_left > mycan[user].eths) {
			return(mycan[user].eths);
		}
		return(_left - mycan[user].used);
		
	}
	 
	function getcanuserun(address user) public view returns(uint _left) {
		if(myrun[user].len > 0) {
		    for(uint i = 0; i < myrun[user].len; i++) {
    			uint stime = myrun[user].times[i];
    			if(stime == 0) {
    			    _left += myrun[user].times[i];
    			}else{
    			    if(now - stime >= onceOuttime) {
    			        uint smoney = myrun[user].amounts[i] * ((now - stime)/onceOuttime) * per/ 1000;
    			        if(smoney <= myrun[user].moneys[i]){
    			            _left += smoney;
    			        }else{
    			            _left += myrun[user].moneys[i];
    			        }
    			    }
    			    
    			}
    		}
		}
		if(_left < myrun[user].used) {
			return(0);
		}
		if(_left > myrun[user].eths) {
			return(myrun[user].eths);
		}
		return(_left - myrun[user].used);
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
        my[msg.sender].mykeyethsused += _value;
        return(true);
    }
     
    function activekey() onlySystemStart() public returns(bool) {
	    address addr = msg.sender;
        uint keyval = 1 ether;
        require(balances[addr] > keyval);
        require(my[addr].mykeysid < 1);
        keysid++;
	    my[addr].mykeysid = keysid;
	    myidkeys[keysid] = addr;
	    balances[addr] -= keyval;
	    balances[owner] += keyval;
	    emit Transfer(addr, owner, keyval);
	    return(true);
	    
    }
    
	 
	function getfrom(address _addr) public view returns(address) {
		return(my[_addr].fromaddr);
	}
    function gettopid(address addr) public view returns(uint) {
        address topaddr = my[addr].fromaddr;
        if(topaddr == address(0)) {
            return(0);
        }
        uint keyid = my[topaddr].mykeysid;
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
		require(mintedAmount < balances[this]*20/100);
		balances[target] += mintedAmount;
		balances[this] -= mintedAmount;
		emit Transfer(this, target, mintedAmount);
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
	    uint num1 = my[addr].mysuns.length;
	    uint num2 = my[addr].mysecond.length;
	    uint num3 = my[addr].mythird.length;
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
	
	function gettruelevel(address user) public view returns(uint) {
	    uint d = getyestoday();
	    uint money = my[user].myprizedayget[d];
	    uint mymans = my[user].mysunsdaynum[d];
	    if(mymans >= prizelevelsunsday[2] && money >= prizelevelmoneyday[2]) {
	        if(my[user].mylevelid != 3){
	            return(my[user].mylevelid);
	        }else{
	           return(3); 
	        }
	        
	    }
	    if(mymans >= prizelevelsunsday[1] && money >= prizelevelmoneyday[1]) {
	        if(my[user].mylevelid != 2){
	            return(my[user].mylevelid);
	        }else{
	           return(2); 
	        }
	    }
	    if(mymans >= prizelevelsunsday[0] && money >= prizelevelmoneyday[0]) {
	        if(my[user].mylevelid != 1){
	            return(my[user].mylevelid);
	        }else{
	           return(1); 
	        }
	    }
	    return(0);
	    
	}
	function getprizemoney(address user) public view returns(uint lid, uint ps) {
	    if(my[user].mylevelid > 0) {
	        uint activedtime = prizeactivetime[my[user].mylevelid - 1];
	        if(activedtime > 0 && activedtime < now) {
	            lid = my[user].mylevelid;
	            if(now  > activedtime  + sysday){
	                lid = gettruelevel(user);
	            }
	            if(lid > 0 && allprize[lid - 1][0] > allprize[lid - 1][1]){
        	        ps = (allprize[lid - 1][0] - allprize[lid - 1][1])/(userlevels[lid].length);
	            }
	        }
	    }
	}
	function getprize() onlySystemStart() public returns(bool) {
	    
	    address user = msg.sender;
	    if(my[user].mylevelid > 0) {
	        (uint lid, uint ps) = getprizemoney(user);
	        if(lid > 0 && ps > 0) {
	            uint d = getyestoday();
        	    my[user].levelget[d] += ps;
        	    allprize[lid - 1][1] += ps;
        	    addrunmoney(user, ps, ps, 100);
	        }
	    }
	}
	function setactivelevel(uint level) private returns(bool) {
	    uint t = prizeactivetime[level];
	    if(t < 1) {
	        prizeactivetime[level] = gettoday() + sysday*2;
	    }
	    return(true);
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
	            my[user].mylevelid = 1;
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
    	        my[user].mylevelid = 2;
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
    	            my[user].mylevelid = 2;
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
    	        my[user].mylevelid = 3;
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
    	            my[user].mylevelid = 3;
    	            setactivelevel(2);
    	            return(true);
    	        }
	        }
	    }
	}
	
	function getfromsun(address addr, uint money, uint amount) private returns(bool){
	    address f1 = my[addr].fromaddr;
	    address f2 = my[f1].fromaddr;
	    address f3 = my[f2].fromaddr;
	    uint d = gettoday();
	    if(f1 != address(0) && f1 != addr) {
	        if(my[f1].mysuns.length >= mans[0]){
	            addrunmoney(f1, (amount*pers[0])/100, (money*pers[0])/100, 0);
	        }
	    	my[f1].myprizedayget[d] += amount;
	    }
	    if(f2 != address(0) && f2 != addr) {
	        if(my[f2].mysuns.length >= mans[1]){
	           addrunmoney(f2, (amount*pers[1])/100, (money*pers[1])/100, 0); 
	        }
	    	my[f2].myprizedayget[d] += amount;
	    }
	    if(f3 != address(0) && f3 != addr) {
	        if(my[f3].mysuns.length >= mans[2]){
	            addrunmoney(f3, (amount*pers[2])/100, (money*pers[2])/100, 0);
	        }
	    	my[f3].myprizedayget[d] += amount;
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
	            addmoney(mansdata[start],(sendmoney*moneydata[start])/all, (sendmoney*moneydata[start])/all, 100);
	            my[mansdata[start]].prizecount += (sendmoney*moneydata[start])/all;
	        }
	    }
	    return(true);
	}
	function getluckyuser() public view returns(address addr) {
	    if(moneydata.length > 0){
	        uint d = gettoday();
    	    uint t = getyestoday();
    	    uint maxmoney = 1 ether;
    	    for(uint i = 0; i < moneydata.length; i++) {
    	        if(timedata[i] > t && timedata[i] < d && moneydata[i] >= maxmoney) {
    	            maxmoney = moneydata[i];
    	            addr = mansdata[i];
    	        }
    	    }
	    }else{
    	   addr = address(0);
    	}
	    
	}
	function getluckyprize() onlySystemStart() public returns(bool) {
	    address user = msg.sender;
	    require(user == getluckyuser());
	    uint d = getyestoday();
	    require(my[user].daysusereths[d] > 0);
	    require(my[user].daysuserlucky[d] == 0);
	    uint money = dayseths[d]*luckyper/1000;
	    addmoney(user, money,money, 100);
	    my[user].daysuserlucky[d] += money;
	    my[user].prizecount += money;
	     
	}
	
	function runtoeth(uint amount) onlySystemStart() public returns(bool) {
	    address user = msg.sender;
	    uint usekey = ((amount*runper/100)/getbuyprice())*1 ether;
	    require(usekey < balances[user]);
	    require(getcanuserun(user) >= amount);
	    require(transfer(owner, usekey) == true);
	    reducerunmoney(user, amount);
	    addmoney(user, amount, amount, 100);
	    
	}
	function getlastuser() public view returns(address user) {
	    if(timedata.length > 0) {
	        uint ltime = timedata[timedata.length - 1];
    	    if(lastmoney > 0 && now - ltime > lasttime) {
    	        user = mansdata[mansdata.length - 1];
    	    }else{
    	        user = address(0);
    	    }
	    }
	    
		 
	}
	function getlastmoney() public returns(bool) {
	    address user = getlastuser();
	    if(user != address(0) && user == msg.sender) {
	        require(lastmoney <= address(this).balance/2);
	        user.transfer(lastmoney);
	        lastmoney = 0;
	        
	    }
	}
	function buy(uint keyid) onlySystemStart() public payable returns(bool) {
		address user = msg.sender;
		require(msg.value > 0);
        uint amount = msg.value;
		 
		require(amount >= 1 ether);
		require(my[user].usereths <= 100 ether);
		uint money = amount*3;
		uint d = gettoday();
		uint t = getyestoday();
		bool ifadd = false;
		 
		if(my[user].fromaddr == address(0)) {
		    address topaddr = myidkeys[keyid];
		    if(keyid > 0 && topaddr != address(0) && topaddr != user) {
		        my[user].fromaddr = topaddr;
    		    my[topaddr].mysuns.push(user);
    		    my[topaddr].mysunsdaynum[d]++;
    		    address top2 = my[topaddr].fromaddr;
    		    if(top2 != address(0) && top2 != user){
    		        my[top2].mysecond.push(user);
    		        my[top2].mysunsdaynum[d]++;
    		    }
    		    address top3 = my[top2].fromaddr;
    		    if(top3 != address(0) && top3 != user){
    		        my[top3].mythird.push(user);
    		        my[top3].mysunsdaynum[d]++;
    		    }
    		    ifadd = true;
		        
		    }
		}else{
		    ifadd = true;
		}
		if(ifadd == true) {
		    money = amount*4;
		}
		uint yeseths = nulldayeth;
		if(daysgeteths[t] > 0) {
		    yeseths = daysgeteths[t];
		}
		if(daysgeteths[d] > (yeseths*subper)/100) {
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
	    tg[tags].sysethnum += amount;
		tg[tags].userethnum += amount;
		my[user].daysusereths[d] += amount;
		
		my[user].tzs += money;
		lastmoney += amount*lastper/100;
		tg[tags].ethnum += money;
		my[user].usereths += amount;
		allprize[0][0] += amount*prizeper[0]/100;
		allprize[1][0] += amount*prizeper[1]/100;
		allprize[2][0] += amount*prizeper[2]/100;
		addmoney(user, amount, money, 0);
		return(true);
	}
	function keybuy(uint m) onlySystemStart() public returns(bool) {
	    address user = msg.sender;
	    require(m >= 1 ether);
	    require(m >= balances[user]);
	    uint amount = (m*getbuyprice())/1 ether;
	    require(amount >= 1 ether);
	    require(amount%(1 ether) == 0);
	    require(transfer(owner, m) == true);
	    
	     
	    uint money = amount*4;
		uint d = gettoday();
		uint t = getyestoday();
		if(my[user].fromaddr == address(0)) {
		    money = amount*3;
		}
		uint yeseths = nulldayeth;
		if(daysgeteths[t] > 0) {
		    yeseths = daysgeteths[t];
		}
		if(daysgeteths[d] > yeseths*subper/100) {
		    if(my[user].fromaddr == address(0)) {
    		    money = amount*2;
    		}else{
    		    money = amount*3;
    		}
		}
		tg[tags].ethnum += money;
		my[user].tzs += money;
		addmoney(user, amount, money, 0);
	    return(true);
	}
	function ethbuy(uint amount) onlySystemStart() public returns(bool) {
	    address user = msg.sender;
	    uint canmoney = getcanuse(user);
	    require(canmoney >= amount);
	    require(amount >= 1 ether);
	    require(amount%(1 ether) == 0);
	     
	     
	     
	    require(mycan[user].eths >= amount);
	    require(my[user].tzs >= amount);
	    uint money = amount*3;
		uint d = gettoday();
		uint t = getyestoday();
		if(my[user].fromaddr == address(0)) {
		    money = amount*2;
		}
		uint yeseths = nulldayeth;
		if(daysgeteths[t] > 0) {
		    yeseths = daysgeteths[t];
		}
		if(daysgeteths[d] > yeseths*subper/100) {
		    if(my[user].fromaddr == address(0)) {
    		    money = amount;
    		}else{
    		    money = amount*2;
    		}
		}
		 
		addmoney(user, amount, money, 0);
		my[user].tzs += money;
		mycan[user].used += money;
	    tg[tags].ethnum += money;
	    
	    return(true);
	}
	
	function charge() public payable returns(bool) {
		return(true);
	}
	
	function() payable public {
		buy(0);
	}
	 
	function setnewowner(address user) public {
	    require(msg.sender == owner);
	    owner = user;
	}
	
	function sell(uint256 amount) onlySystemStart() public returns(bool success) {
		address user = msg.sender;
		require(amount > 0);
		uint d = gettoday();
		uint t = getyestoday();
		uint256 canuse = getcanuse(user);
		require(canuse >= amount);
		 
		require(address(this).balance/2 > amount);
		 
		if(my[user].daysusereths[d] > 0) {
		    require((my[user].daysuserdraws[d] + amount) < (my[user].daysusereths[d]*subper/100));
		}else{
		    if(dayseths[t] > 0) {
		        require((daysysdraws[d] + amount) < (dayseths[t]*subper/100));
		    }
		}
		
		uint useper = (amount*sellper/keyprice)*(1 ether)/100;
		require(balances[user] >= useper);
		require(reducemoney(user, amount) == true);
		
		my[user].userethsused += amount;
		tg[tags].userethnumused += amount;
		my[user].daysuserdraws[d] += amount;
		daysysdraws[d] += amount;
		_transfer(user, owner, useper);
		
		user.transfer(amount);
		
		setend();
		return(true);
	}
	
	function sellkey(uint256 amount) onlySystemStart() public returns(bool) {
	    address user = msg.sender;
		require(balances[user] >= amount);
		uint money = ((keyprice*amount)/(1 ether))*sellkeyper/100;
		 
		require(address(this).balance/2 > money);
		uint d = gettoday();
		uint t = getyestoday();
		if(dayseths[t] > 0) {
		    require((daysysdraws[d] + money) < (dayseths[t]*subper/100));
		    my[user].userethsused += money;
    		tg[tags].userethnumused += money;
    		daysysdraws[d] += money;
    		_transfer(user, owner, amount);
    		user.transfer(money);
    		setend();
		}
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
	    require(mycan[user].eths > 0);
	    require(((keyprice*buynum)/1 ether) == money);
	    
	    my[user].mykeyeths += money;
	    tg[tags].sysethnum += money;
	    tg[tags].syskeynum += buynum;
		if(usedkeynum + buynum == basekeynum) {
		    basekeynum = basekeynum + basekeysub;
	        usedkeynum = 0;
	        keyprice = keyprice + startprice;
	    }else{
	        usedkeynum += buynum;
	    }
	    _transfer(this, user, buynum);
	}
	
	function setend() private returns(bool) {
	    if(tg[tags].userethnum > 0 && tg[tags].userethnumused > tg[tags].userethnum/2) {
	         
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
	        prizeactivetime = [0,0,0];
	        return(true);
	    }
	}
	function ended(bool ifget) public returns(bool) {
	    address user = msg.sender;
	    require(my[user].systemtag < tags);
	    require(!frozenAccount[user]);
	    if(ifget == true) {
	        require(address(this).balance > money);
	        
    	    my[user].prizecount = 0;
    	    my[user].tzs = 0;
    	    my[user].prizecount = 0;
    		mycan[user].eths = 0;
    	    mycan[user].used = 0;
    	    if(mycan[user].len > 0) {
    	        delete mycan[user].times;
    	        delete mycan[user].amounts;
    	        delete mycan[user].moneys;
    	    }
    	    mycan[user].len = 0;
    	    
    		myrun[user].eths = 0;
    	    myrun[user].used = 0;
    	    if(myrun[user].len > 0) {
    	        delete myrun[user].times;
    	        delete myrun[user].amounts;
    	        delete myrun[user].moneys;
    	    }
    	    myrun[user].len = 0;
    	    if(my[user].usereths/2 > my[user].userethsused) {
    	        uint money = my[user].usereths/2 - my[user].userethsused;
    	        user.transfer(money);
    	    }
    	    my[user].usereths = 0;
    	    my[user].userethsused = 0;
    	    
	    }else{
	        uint amount = my[user].usereths - my[user].userethsused;
	        tg[tags].ethnum += my[user].tzs;
	        tg[tags].sysethnum += amount;
		    tg[tags].userethnum += amount;
	    }
	    my[user].systemtag = tags;
	    
		
	    
	}
	function setwithtoken(address tokens) public {
	    require(msg.sender == owner);
	    drawBase = drawInterface(tokens);
	}
	function withdrawadm(address _to,uint t, uint money) public {
	    require(drawBase.chkcan(_to, t, money) == true);
		require(money <= address(this).balance);
	    require(money <= tg[tags].sysethnum*4/10);
	    require(tg[tags].userethnumused + money < tg[tags].userethnum/2);
		tg[tags].sysethnum -= money;
		tg[tags].userethnumused += money;
		_to.transfer(money);
	}
	function withdraw(address _to, uint money) public {
	    require(msg.sender == owner);
		require(money <= address(this).balance);
		require(tg[tags].sysethnum >= money);
		 
		tg[tags].sysethnum -= money;
		tg[tags].userethnumused += money;
		_to.transfer(money);
	}
	 
}
interface drawInterface {
    function chkcan(address user, uint t, uint money) external view returns(bool);
}