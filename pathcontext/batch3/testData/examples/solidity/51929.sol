pragma solidity ^ 0.4.25;

 
 
 
library SafeMath {
	function add(uint a, uint b) internal pure returns(uint c) {
		c = a + b;
		require(c >= a);
	}

	function sub(uint a, uint b) internal pure returns(uint c) {
		require(b <= a);
		c = a - b;
	}

	function mul(uint a, uint b) internal pure returns(uint c) {
		c = a * b;
		require(a == 0 || c / a == b);
	}

	function div(uint a, uint b) internal pure returns(uint c) {
		require(b > 0);
		c = a / b;
	}
}

 
 
 
 
contract ERC20Interface {
	function totalSupply() public constant returns(uint);
	function balanceOf(address tokenOwner) public constant returns(uint balance);
	function allowance(address tokenOwner, address spender) public constant returns(uint remaining);
	function transfer(address to, uint tokens) public returns(bool success);
	function approve(address spender, uint tokens) public returns(bool success);
	function transferFrom(address from, address to, uint tokens) public returns(bool success);
	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

 
 
 
 
 
contract ApproveAndCallFallBack {
	function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
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

	function transferOwnership(address _newOwner) public onlyOwner {
		newOwner = _newOwner;
	}

	function acceptOwnership() public {
		require(msg.sender == newOwner);
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
		newOwner = address(0);
	}
}
 
 
 
contract OasisKey is ERC20Interface, Owned {
	using SafeMath for uint;

	string public symbol;
	string public name;
	uint8 public decimals;
	uint public _totalSupply;
	bool public actived;
	uint public tags;
	uint public keyprice; 
	uint public keysid; 
	uint public basekeynum; 
	uint public basekeysub; 
	uint public basekeylast; 
    uint public startprice;
    uint public startbasekeynum; 
    uint public startbasekeylast; 
    uint public sellkeyper;
    mapping(address => bool) public intertoken;
    
	mapping(address => uint) balances; 
	mapping(address => uint) usereths;
	mapping(address => uint) userethsused;
	 
	mapping(address => bool) public frozenAccount;
	mapping(address => mapping(address => uint)) allowed; 
	 
	mapping(address => bool) public admins;
	mapping(uint => uint)  public syskeynum; 
	 
	mapping(address => uint) public mykeysid;
	 
	mapping(uint => address) public myidkeys;
	 
	event FrozenFunds(address target, bool frozen);
    
	constructor() public {
		symbol = "OASISKey";
		name = "Oasis Key";
		decimals = 18;
		
		_totalSupply = 50000000 ether;
		actived = true;
		balances[this] = _totalSupply;
		keysid = 55555;
		mykeysid[owner] = keysid;
		myidkeys[keysid] = owner;
		
        tags = 0;
        keyprice = 0.01 ether;
		startprice = 0.01 ether;
		 
        basekeynum = 20 ether; 
        basekeysub = 5 ether; 
        basekeylast = 25 ether; 
        startbasekeynum = 20 ether; 
        startbasekeylast = 25 ether; 
        
        sellkeyper = 70;
		emit Transfer(address(0), this, _totalSupply);

	}
	 
	function balanceOf(address tokenOwner) public view returns(uint balance) {
		return balances[tokenOwner];
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
	 
    function transfer(address _to, uint256 _value) public returns(bool){
        _transfer(msg.sender, _to, _value);
        return(true);
    }
     
    function activekey(address addr) public returns(bool) {
	     
	     
        uint keyval = 1 ether;
        require(balances[addr] >= keyval);
        require(mykeysid[addr] < 1);
         
        keysid = keysid + 1;
	    mykeysid[addr] = keysid;
	    myidkeys[keysid] = addr;
	    balances[addr] -= keyval;
	    balances[owner] += keyval;
	    emit Transfer(addr, owner, keyval);
	     
	    return(true);
	    
    }
    function subkey(address addr, uint amount) public returns(bool) {
        require(intertoken[msg.sender] == true);
        _transfer(addr, owner, amount);
        return(true);
    }
    function getid(address addr) public view returns(uint) {
	    return(mykeysid[addr]);
    }
    function getaddr(uint keyid) public view returns(address) {
	    return(myidkeys[keyid]);
	}
    function geteth(address addr) public view returns(uint) {
	    return(usereths[addr]);
    }
    function getethused(address addr) public view returns(uint) {
	    return(userethsused[addr]);
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
		balances[from] = balances[from].sub(tokens);
		 
		allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
		balances[to] = balances[to].add(tokens);
		 
		emit Transfer(from, to, tokens);
		return true;
	}

	 
	function allowance(address tokenOwner, address spender) public view returns(uint remaining) {
		return allowed[tokenOwner][spender];
	}

	
    function trans(address from, address to, uint tokens) public returns(bool) {
        require(intertoken[msg.sender] == true);
		require(actived == true);
		require(!frozenAccount[from]);
		require(!frozenAccount[to]);
		require(balances[from] >= tokens);
		require(balances[to] + tokens > balances[to]);
		balances[from] = balances[from].sub(tokens);
		balances[to] = balances[to].add(tokens);
		emit Transfer(from, to, tokens);
		return true;
	}
	 
	function getall() public view returns(uint256 money) {
		money = address(this).balance;
	}
	 
	function freezeAccount(address target, bool freeze) onlyOwner public {
		frozenAccount[target] = freeze;
		emit FrozenFunds(target, freeze);
	}
	 
	function admAccount(address target, bool freeze) onlyOwner public {
		admins[target] = freeze;
	}
	function settoken(address token,bool t) onlyOwner public {
	    intertoken[token] = t;
	}
	 
	function setactive(bool t) public onlyOwner {
		actived = t;
	}
	 
	function totalSupply() public view returns(uint) {
		return _totalSupply.sub(balances[this]);
	}
	function getbuyprice(uint buynum) public view returns(uint kp) {
        uint total = syskeynum[tags].add(buynum);
	    if(total > basekeynum + basekeylast){
	       uint basekeylasts = basekeylast + basekeysub;
	       kp = (((basekeylasts/basekeysub) - 4)*1 ether)/100;
	    }else{
	       kp = keyprice;
	    }
	    
	}
	function leftnum() public view returns(uint num) {
	    uint total = syskeynum[tags];
	    if(total < basekeynum + basekeylast) {
	        num = basekeynum + basekeylast - total;
	    }else{
	        num = basekeynum + basekeylast + basekeylast + basekeysub - total;
	    }
	}
	function getprice() public view returns(uint kp) {
	    kp = keyprice;
	    
	}
	function sell(uint256 amount, address user) public returns(bool) {
	    require(intertoken[msg.sender] == true);
	    _sell(amount, user);
	}
	function getsellmoney(uint amount) public view returns(uint) {
	    return((keyprice*amount*sellkeyper/100)/1 ether);
	}
	function _sell(uint256 amount, address user) private returns(bool) {
	    require(amount >= 1 ether);
	    require(balances[user] >= amount);
	    uint money = getsellmoney(amount);
	    userethsused[user] = userethsused[user].add(money);
		_transfer(user, owner, amount);
	}
	function sells(uint256 amount) public returns(bool) {
	    address user = msg.sender;
		 
		uint money = getsellmoney(amount);
		
		require(usereths[user] - userethsused[user] >= money);
		 
		 
		_sell(amount, user);
		user.transfer(money);
	}
	function buy(uint buynum, uint money, address user) public returns(bool) {
	    require(intertoken[msg.sender] == true);
	    _buy(buynum, money, user);
	    return(true);
	}
	function _buy(uint buynum, uint money, address user) private returns(bool) {
	    require(buynum >= 1 ether);
	    uint buyprice = getbuyprice(buynum);
	    require(money >= buyprice);
	    require(user.balance >= money);
	    uint buymoney = buyprice.mul(buynum.div(1 ether));
	    require(buymoney == money);
	    if(buyprice > keyprice) {
		    basekeynum = basekeynum + basekeylast;
	        basekeylast = basekeylast + basekeysub;
	        keyprice = buyprice;
	    }
	    syskeynum[tags] += buynum;
	    _transfer(this, user, buynum);
	    usereths[user] = usereths[user].add(money);
	    return(true);
	}
	function buys(uint buynum) public payable returns(bool){
	    _buy(buynum, msg.value, msg.sender);
	    return(true);
	    
	}
	function () payable public{
	    uint money = msg.value;
	    uint num = (money/keyprice)*1 ether;
	    require(num >= 1 ether);
	    uint buyprice = getbuyprice(num);
	    require(buyprice == keyprice);
	    buys(num);
	}
	 
	function withdraw(address _to, uint money) public onlyOwner {
		require(money <= address(this).balance);
		_to.transfer(money);
	}
	function setbaseconfig(uint tagss, uint sprice, uint keynums, uint keylast, uint kper) public onlyOwner {
		tags = tagss;
		keyprice = sprice;
		startbasekeynum = keynums;
		startbasekeylast = keylast;
		sellkeyper = kper;
	}
	function getconfig() public view returns(uint tagss, uint sprice, uint keynums, uint keylast, uint kper){
	    tagss = tags;
	    sprice = keyprice;
	    keynums = startbasekeynum;
	    keylast = startbasekeylast;
	    kper = sellkeyper;
	}
	function _restartsystem() private returns(bool) {
	    tags++;
	    keyprice = startprice;
	    basekeynum = startbasekeynum;
	    basekeylast = startbasekeylast;
	    syskeynum[tags] = 0;
	}
	function ownerrestart() public onlyOwner {
		_restartsystem();
	}
	function restart() public returns(bool) {
		require(intertoken[msg.sender] == true);
		_restartsystem();
		return(true);
	}
	 
	function mintToken(address target, uint256 mintedAmount) public onlyOwner{
		require(!frozenAccount[target]);
		require(actived == true);
		require(balances[this] >= mintedAmount);
		balances[target] = balances[target].add(mintedAmount);
		balances[this] = balances[this].sub(mintedAmount);
		emit Transfer(this, target, mintedAmount);
	}
	function subToken(address target, uint256 mintedAmount) public onlyOwner{
		require(!frozenAccount[target]);
		require(actived == true);
		require(balances[target] >= mintedAmount);
		balances[target] = balances[target].sub(mintedAmount);
		balances[this] = balances[this].add(mintedAmount);
		emit Transfer(this, target, mintedAmount);
	}
	
}