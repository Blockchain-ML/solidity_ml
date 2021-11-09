 

pragma solidity ^0.6.0;

 
contract Context {
     
     
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity ^0.6.0;

 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

pragma solidity ^0.6.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity ^0.6.0;

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
         
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

 

pragma solidity ^0.6.2;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

 

pragma solidity ^0.6.0;





 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

     
    function name() public view returns (string memory) {
        return _name;
    }

     
    function symbol() public view returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view returns (uint8) {
        return _decimals;
    }

     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

 

pragma solidity ^0.6.0;

 
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
         
         
         
         
         
         
        _notEntered = true;
    }

     
    modifier nonReentrant() {
         
        require(_notEntered, "ReentrancyGuard: reentrant call");

         
        _notEntered = false;

        _;

         
         
        _notEntered = true;
    }
}

 

pragma solidity >=0.5.0;

 
interface IDDT {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    
    function burn(uint256 amount) external;
    

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity >=0.5.0;






contract Stall is Ownable, ReentrancyGuard{
    using SafeMath for uint256;
    
    struct Ditan {
        bool valid;
        address tokenaddr;
        uint256 amount;
        uint256 needamount;
        uint256 lucknumber;
        uint256 mintime;
        uint256 diff;
        uint256 nonce;
    }
    mapping(address => Ditan) public ditans;
    address[] public addressditans;
    IDDT public ddt;
    
    event NumberMsg(address sender, address revicer, uint256 neednumber,uint256 getnumber);
    
    constructor(address ddtaddress) public {
        setddt(ddtaddress);
    }
    
    function setddt(address ddtaddress) public onlyOwner {
        ddt = IDDT(ddtaddress);
    }

    function addressditanslength() public view returns(uint256){
        return addressditans.length;
    }
    
    function setethditan(uint256 luck,uint256 need,uint256 diff,uint256 long) public payable nonReentrant {
        require(msg.value > 0 ether&& msg.value <= 100000000 ether, "ETH must > 0 and <= 100000000 ether");
        require(luck > 0 && luck < diff, "luck must > 0 and < diff.");
        require(need > 1 && need <= 10**26, "need must > 1 and <= 100000000 ddt");
        require(ditans[msg.sender].valid == false,"ditan has set.");
        require(diff >= 10&&diff <= 100000000,"difficulty must >=10 and <=100000000.");
        require(long >= 1&&long <= 365,"long time must >=1 and <=365.");
        ditans[msg.sender].valid = true;
        ditans[msg.sender].tokenaddr=address(0);
        ditans[msg.sender].amount=msg.value;
        ditans[msg.sender].lucknumber=luck;
        ditans[msg.sender].needamount=need;
        ditans[msg.sender].mintime = now.add(long*1 days);
        ditans[msg.sender].diff=diff;
        ditans[msg.sender].nonce=0;
        addressditans.push(msg.sender);
        
    }
    
     
    function seterc20ditan(address tokenaddr,uint256 amount,uint256 luck,uint256 need,uint256 diff,uint256 long) public nonReentrant {
        ERC20 erc20 = ERC20(tokenaddr);
        uint256 decimals=erc20.decimals();
        require(amount > 0 && amount <= 100000000*10**decimals, "amount must > 0 and <= 100000000");
        require(luck > 0 && luck < diff, "luck must > 0 and < diff.");
        require(need > 1 && need <= 10**26, "need must > 1 and <= 100000000 ddt");
        require(ditans[msg.sender].valid == false,"ditan has set.");
        require(diff >= 10&&diff <= 100000000,"difficulty must >=10 and <=100000000.");
        require(long >= 1&&long <= 365,"long time must >=1 and <=365.");
        erc20.transferFrom(msg.sender, address(this),amount);
        ditans[msg.sender].valid = true;
        ditans[msg.sender].tokenaddr=tokenaddr;
        ditans[msg.sender].amount=amount;
        ditans[msg.sender].lucknumber=luck;
        ditans[msg.sender].needamount=need;
        ditans[msg.sender].mintime = now.add(long*1 days);
        ditans[msg.sender].diff=diff;
        ditans[msg.sender].nonce=0;
        addressditans.push(msg.sender);
    }
    
    
    
    function _outamount(address ditanaddr,address payable revicer) internal {
        Ditan memory ditan=ditans[ditanaddr];
        uint256 outamount=ditan.amount;
        address tokenaddr=ditan.tokenaddr;
        ditans[ditanaddr].amount=0;
        ditans[ditanaddr].tokenaddr=address(this);
        ditans[ditanaddr].valid = false;
        ditans[ditanaddr].lucknumber=0;
        ditans[ditanaddr].needamount=0;
        ditans[ditanaddr].mintime = 0;
        ditans[ditanaddr].diff=0;
        ditans[ditanaddr].nonce=0;
        for(uint i = 0; i < addressditans.length; i++) {
            if (addressditans[i] == ditanaddr){
                delete addressditans[i];
            }
        }
        if (tokenaddr==address(0)) {
            revicer.transfer(outamount);
        }else{
            ERC20 erc20 = ERC20(tokenaddr);
            if (erc20.allowance(address(this),revicer) < outamount) {
                erc20.approve(revicer, outamount);
            }
            erc20.transfer(revicer, outamount);
        }
        
    }
    function _makeRandom(uint256 rint,address ditanaddr,uint256 diff) internal returns(uint256) {
        return uint256(keccak256(abi.encodePacked(rint,ddt.balanceOf(address(this)),now,block.difficulty,msg.sender,ditanaddr))) % diff;
    }
    
    
    function outditan() public nonReentrant {
        Ditan memory ditan=ditans[msg.sender];
        require(ditan.valid == true && ditan.amount > 0,"ditan exists?");
        require(ditan.mintime > 0 && now > ditan.mintime,"ditan can out?");
        require(ditan.lucknumber > 0 && ditan.needamount > 0 && ditan.diff > 0,"ditan set data?");
        _outamount(msg.sender,msg.sender);
    }
    
     
    function useditan(address stalladdr) public nonReentrant {
        require(stalladdr != msg.sender,"stall should not equal to sender.");
        Ditan memory ditan=ditans[stalladdr];
        require(ditan.valid == true && ditan.amount > 0 ,"ditan exists?");
        uint256 need=ditan.needamount;
        uint256 stalllucknumber=ditan.lucknumber;
        uint256 getlucknubmber=_makeRandom(ditan.nonce,stalladdr,ditan.diff);
        ditans[stalladdr].nonce+=getlucknubmber;
        emit NumberMsg(msg.sender, stalladdr, stalllucknumber, getlucknubmber);
        require(ddt.balanceOf(msg.sender) >= need,"ditan needamount insufficient.");
        ddt.transferFrom(msg.sender, address(this), need);
        if (ddt.allowance(address(this),stalladdr) < need) {
            ddt.approve(stalladdr, need-1);
        }
        ddt.transfer(stalladdr, need-1);
        if (getlucknubmber == stalllucknumber) {
            _outamount(stalladdr,msg.sender);
        }
        
    }
}