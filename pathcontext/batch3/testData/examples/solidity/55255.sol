pragma solidity ^0.5.0;

 

 
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

 
library SafeMath {
    int256 constant private INT256_MIN = -2**255;

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function mul(int256 a, int256 b) internal pure returns (int256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN));  

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        require(b > 0);
        uint256 c = a / b;
         

        return c;
    }

     
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0);  
        require(!(b == -1 && a == INT256_MIN));  

        int256 c = a / b;

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

 

 
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

     
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

interface Observer {
    function balanceUpdate(address _token, address _account, int _change) external;
}

 

 
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

     
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

     
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

     
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

     
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

     
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

     
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

     
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

     
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

     
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

 

contract Token is ERC20, Ownable {

    string public name;
    string public symbol;
    uint8 public decimals = 18;

    constructor(string memory _name, string memory _symbol) public {
        name = _name;
        symbol = _symbol;
    }

    function burn(uint amount) public onlyOwner {
        _burn(msg.sender, amount);
    }

    function mint(uint amount) public onlyOwner {
        _mint(msg.sender, amount);
    }
}

 

contract Treasury is Ownable {
    using SafeMath for uint;

    Token public digm;
    mapping(address => uint) private digmBalances;
    Token public nickl;
    mapping(address => uint) private nicklBalances;
    Token public penny;
    mapping(address => uint) private pennyBalances;

    mapping(address => bool) private whitelist;
    mapping(address => address[]) listeners;

    constructor() public {
        digm = new Token("DIGM", "DIGM");
        nickl = new Token("NICKL", "NICKL");
        penny = new Token("PENNY", "PENNY");
        whitelist[msg.sender] = true;
    }

    function deposit(address token, address account, uint amount) onlyWhitelisted public {
        require(IERC20(token).transferFrom(account, address(this), amount));
        notifyObservers(token, account, int(amount));
        setBalance(token, account, getBalance(token, account).add(amount));
    }

    function withdraw(address token, address account, uint amount) onlyWhitelisted public {
        require(getBalance(token, account) >= amount);
        require(IERC20(token).transfer(account, amount));
        notifyObservers(token, account, int(amount) * -1);
        setBalance(token, account, getBalance(token, account).sub(amount));
    }

    function updateBalance(address token, address account, uint amount) onlyWhitelisted public {
        uint currentBalance = getBalance(token, account);
        if(currentBalance > amount) {
            uint amountToWithdraw = currentBalance.sub(amount);
            withdraw(token, account, amountToWithdraw);
        } else if (currentBalance < amount) {
            uint amountToDeposit = amount.sub(currentBalance);
            deposit(token, account, amountToDeposit);
        }
    }

    function adjustBalance(address token, address account, int amount) onlyWhitelisted public {
        if(amount < 0) {
            withdraw(token, account, uint(amount * -1));
        } else if (amount > 0) {
            deposit(token, account, uint(amount));
        }
    }

    function currentBalance(address token, address account) public view returns (uint)  {
        return getBalance(token, account);
    }

    function currentBalances(address account) public view returns (uint, uint, uint) {
        return (digmBalances[account], nicklBalances[account], pennyBalances[account]);
    }

    function split(uint amount) public {
        require(digm.transferFrom(msg.sender, address(this), amount));

        digm.burn(amount);
        nickl.mint(amount);
        penny.mint(amount);

        require(nickl.transfer(msg.sender, amount));
        require(penny.transfer(msg.sender, amount));
    }

    function merge(uint amount) public {
        require(nickl.transferFrom(msg.sender, address(this), amount));
        require(penny.transferFrom(msg.sender, address(this), amount));


        nickl.burn(amount);
        penny.burn(amount);
        digm.mint(amount);

        require(digm.transfer(msg.sender, amount));
    }

    function addListener(address token, address _contract) onlyOwner public {
        if(isListening(token, _contract)) return;

        listeners[token].push(_contract);
    }

    function removeListener(address token, address _contract) onlyOwner public {
        for(uint i = 0; i < listeners[token].length; i++) {
            if(listeners[token][i] == _contract) {
                if(i == listeners[token].length - 1) {
                    listeners[token].length--;
                } else {
                    listeners[token][i] = listeners[token][listeners[token].length - 1];
                    listeners[token].length--;
                }
            }
        }
    }

    function whitelistAccount(address account) onlyOwner public {
        whitelist[account] = true;
    }

    function blacklistAccount(address account) onlyOwner public {
        whitelist[account] = false;
    }

    function ownerTokenTransfer(address token, address recipient, uint amount) onlyOwner public {
        IERC20(token).transfer(recipient, amount);
    }

    function mintDigm(uint amount) onlyOwner public {
        digm.mint(amount);
    }

 
    function isListening(address token, address _contract) internal view returns (bool) {
        for(uint i = 0; i < listeners[token].length; i++) {
            if(listeners[token][i] == _contract) return true;
        }
        return false;
    }

    function notifyObservers(address token, address account, int change) internal {
        for(uint i = 0; i < listeners[token].length; i++) {
            if(listeners[token][i] != msg.sender) {
                Observer(listeners[token][i]).balanceUpdate(token, account, change);
            }
        }
    }

    function getBalance(address token, address account) internal view returns (uint) {
        if(token == address(digm)) {
            return digmBalances[account];
        }

        if(token == address(nickl)) {
            return nicklBalances[account];
        }

        if(token == address(penny)) {
            return pennyBalances[account];
        }
    }

    function setBalance(address token, address account, uint amount) internal {
        if(token == address(digm)) {
            digmBalances[account] = amount;
        }

        if(token == address(nickl)) {
            nicklBalances[account] = amount;
        }

        if(token == address(penny)) {
            pennyBalances[account] = amount;
        }
    }

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender]);
        _;
    }
}

 

contract ParadigmStake is Observer {
    using SafeMath for uint;

    uint public totalStaked = 0;
    address public token;
    Treasury private treasury;

    event StakeMade(address staker, uint amount);
    event StakeRemoved(address staker, uint amount);

    constructor(address _treasury) public {
        treasury = Treasury(_treasury);
        token = address(treasury.penny());
    }

    function stake(uint amount) public {
        treasury.deposit(token, msg.sender, amount);
        totalStaked = totalStaked.add(amount);
        emit StakeMade(msg.sender, amount);
    }

    function removeStake(uint amount) public {
        treasury.withdraw(token, msg.sender, amount);
        totalStaked = totalStaked.sub(amount);
        emit StakeRemoved(msg.sender, amount);
    }

    function stakeFor(address a) public view returns (uint) {
        return treasury.currentBalance(token, a);
    }

    function balanceUpdate(address _token, address _account, int _change) external {
        if(_change < 0) {
            emit StakeRemoved(_account, uint(_change * -1));
        } else {
            emit StakeMade(_account, uint(_change));
        }
    }
}