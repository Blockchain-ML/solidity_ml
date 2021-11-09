 

pragma solidity >=0.5.0 <0.6.0;

 
 
 
contract DkargoPrefix {
    
    string internal _dkargoPrefix;  
    
     
     
     
    function getDkargoPrefix() public view returns(string memory) {
        return _dkargoPrefix;
    }

     
     
     
    function _setDkargoPrefix(string memory prefix) internal {
        _dkargoPrefix = prefix;
    }
}

 

pragma solidity >=0.5.0 <0.6.0;

 
 
 
contract Ownership {
    address private _owner;

    event OwnershipTransferred(address indexed old, address indexed expected);

     
     
    modifier onlyOwner() {
        require(isOwner() == true, "Ownership: only the owner can call");
        _;
    }

     
     
    constructor() internal {
        emit OwnershipTransferred(_owner, msg.sender);
        _owner = msg.sender;
    }

     
     
     
    function transferOwnership(address expected) public onlyOwner {
        require(expected != address(0), "Ownership: new owner is the zero address");
        emit OwnershipTransferred(_owner, expected);
        _owner = expected;
    }

     
     
     
    function owner() public view returns (address) {
        return _owner;
    }

     
     
     
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
}

 

pragma solidity >=0.5.0 <0.6.0;

 
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
         
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

 

pragma solidity >=0.5.0 <0.6.0;


 
 
 
 
contract AddressChain {
    using SafeMath for uint256;

     
    struct NodeInfo {
        address prev;  
        address next;  
    }
     
    struct NodeList {
        uint256 count;  
        address head;  
        address tail;  
        mapping(address => NodeInfo) map;  
    }

     
    NodeList private _slist;  

     
    event AddressChainLinked(address indexed node);  
    event AddressChainUnlinked(address indexed node);  

     
     
     
    function count() public view returns(uint256) {
        return _slist.count;
    }

     
     
     
    function head() public view returns(address) {
        return _slist.head;
    }

     
     
     
    function tail() public view returns(address) {
        return _slist.tail;
    }

     
     
     
     
    function nextOf(address node) public view returns(address) {
        return _slist.map[node].next;
    }

     
     
     
     
    function prevOf(address node) public view returns(address) {
        return _slist.map[node].prev;
    }

     
     
     
     
    function isLinked(address node) public view returns (bool) {
        if(_slist.count == 1 && _slist.head == node && _slist.tail == node) {
            return true;
        } else {
            return (_slist.map[node].prev == address(0) && _slist.map[node].next == address(0))? (false) :(true);
        }
    }

     
     
     
    function _linkChain(address node) internal {
        require(node != address(0), "AddressChain: try to link to the zero address");
        require(!isLinked(node), "AddressChain: the node is aleady linked");
        if(_slist.count == 0) {
            _slist.head = _slist.tail = node;
        } else {
            _slist.map[node].prev = _slist.tail;
            _slist.map[_slist.tail].next = node;
            _slist.tail = node;
        }
        _slist.count = _slist.count.add(1);
        emit AddressChainLinked(node);
    }

     
     
     
    function _unlinkChain(address node) internal {
        require(node != address(0), "AddressChain: try to unlink to the zero address");
        require(isLinked(node), "AddressChain: the node is aleady unlinked");
        address tempPrev = _slist.map[node].prev;
        address tempNext = _slist.map[node].next;
        if (_slist.head == node) {
            _slist.head = tempNext;
        }
        if (_slist.tail == node) {
            _slist.tail = tempPrev;
        }
        if (tempPrev != address(0)) {
            _slist.map[tempPrev].next = tempNext;
            _slist.map[node].prev = address(0);
        }
        if (tempNext != address(0)) {
            _slist.map[tempNext].prev = tempPrev;
            _slist.map[node].next = address(0);
        }
        _slist.count = _slist.count.sub(1);
        emit AddressChainUnlinked(node);
    }
}

 

pragma solidity >=0.5.0 <0.6.0;

 
 
 
 
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 

pragma solidity >=0.5.0 <0.6.0;


 
 
 
contract ERC165 is IERC165 {
    
    mapping(bytes4 => bool) private _infcs;  

     
     
     
    constructor() internal {
        _registerInterface(0x01ffc9a7);  
    }

     
     
     
     
    function supportsInterface(bytes4 infcid) external view returns (bool) {
        return _infcs[infcid];
    }

     
     
     
    function _registerInterface(bytes4 infcid) internal {
        require(infcid != 0xffffffff, "ERC165: invalid interface id");
        _infcs[infcid] = true;
    }
}

 

pragma solidity >=0.5.0 <0.6.0;

 
 
 
 
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity >=0.5.0 <0.6.0;



 
 
 
contract ERC20 is IERC20 {
    using SafeMath for uint256;
    
    uint256 private _supply;  
    mapping(address => uint256) private _balances;  
    mapping(address => mapping(address => uint256)) private _allowances;  
    
     
     
     
    constructor(uint256 supply) internal {
        uint256 pebs = supply;
        _mint(msg.sender, pebs);
    }
    
     
     
     
     
     
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
     
     
     
     
     
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
     
     
     
     
     
     
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
     
     
    function totalSupply() public view returns (uint256) {
        return _supply;
    }
    
     
     
     
     
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
     
     
     
     
     
    function allowance(address approver, address spender) public view returns (uint256) {
        return _allowances[approver][spender];
    }
    
     
     
     
     
     
    function _approve(address approver, address spender, uint256 value) internal {
        require(approver != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[approver][spender] = value;
        emit Approval(approver, spender, value);
    }
    
     
     
     
     
     
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
     
     
     
     
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _supply = _supply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
     
     
     
     
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(value, "ERC20: burn amount exceeds balance");
        _supply = _supply.sub(value);
        emit Transfer(account, address(0), value);
    }
}

 

pragma solidity >=0.5.0 <0.6.0;



 
 
 
contract ERC20Safe is ERC20 {
    using SafeMath for uint256;

     
     
     
     
     
     
    function approve(address spender, uint256 amount) public returns (bool) {
        require((amount == 0) || (allowance(msg.sender, spender) == 0), "ERC20Safe: approve from non-zero to non-zero allowance");
        return super.approve(spender, amount);
    }

     
     
     
     
     
     
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        uint256 amount = allowance(msg.sender, spender).add(addedValue);
        return super.approve(spender, amount);
    }
    
     
     
     
     
     
     
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 amount = allowance(msg.sender, spender).sub(subtractedValue, "ERC20: decreased allowance below zero");
        return super.approve(spender, amount);
    }
}

 

pragma solidity >=0.5.0 <0.6.0;






 
 
 
 
contract DkargoToken is Ownership, ERC20Safe, AddressChain, ERC165, DkargoPrefix {
    
    string private _name;  
    string private _symbol;  
    
     
     
     
     
     
     
    constructor(string memory name, string memory symbol, uint256 supply) ERC20(supply) public {
        _setDkargoPrefix("token");  
        _registerInterface(0x946edbed);  
        _name = name;
        _symbol = symbol;
        _linkChain(msg.sender);
    }

     
     
     
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

     
     
     
     
     
    function transfer(address to, uint256 value) public returns (bool) {
        bool ret = super.transfer(to, value);
        if(isLinked(msg.sender) && balanceOf(msg.sender) == 0) {
            _unlinkChain(msg.sender);
        }
        if(!isLinked(to) && balanceOf(to) > 0) {
            _linkChain(to);
        }
        return ret;
    }

     
     
     
     
     
     
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        bool ret = super.transferFrom(from, to, value);
        if(isLinked(from) && balanceOf(from) == 0) {
            _unlinkChain(from);
        }
        if(!isLinked(to) && balanceOf(to) > 0) {
            _linkChain(to);
        }
        return ret;
    }

     
     
     
    function name() public view returns(string memory) {
        return _name;
    }
    
     
     
     
    function symbol() public view returns(string memory) {
        return _symbol;
    }

     
     
     
     
    function decimals() public pure returns(uint256) {
        return 18;
    }
}