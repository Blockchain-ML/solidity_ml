pragma solidity 0.4.24;

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
    int256 constant private INT256_MIN = - 2 ** 255;

     
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

        require(!(a == - 1 && b == INT256_MIN));
         

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
         
        require(!(b == - 1 && a == INT256_MIN));
         

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

 
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowed;

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

 
contract ERC20Detailed is ERC20, Ownable {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string name, string symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

     
    function name() public view returns (string) {
        return _name;
    }

     
    function symbol() public view returns (string) {
        return _symbol;
    }

     
    function decimals() public view returns (uint8) {
        return _decimals;
    }

     
    function mint(address to, uint256 value) public onlyOwner returns (bool) {
        _mint(to, value);
        return true;
    }
}

contract BSHORT is ERC20Detailed {
    uint public cursETHtoUSD = 94;
    uint public costETH = 1 ether / 10000;
    uint public costUSD = costETH * cursETHtoUSD;
    uint public DEC = 10 ** 18;
    bool public buyOpen = true;
    bool public sellOpen = true;

    event Buy(address user, uint valueETH, uint amount);
    event Sell(address user, uint valueETH, uint amount);
    event Deposit(address user, uint value);
    event Withdraw(address user, uint value);

    modifier buyIsOpen() {
        require(buyOpen == true, "Buying are closed");
        _;
    }

    modifier sellIsOpen() {
        require(sellOpen == true, "Selling are closed");
        _;
    }

    constructor () public ERC20Detailed("BSHORT", "BSHORT", 18) {
        _mint(msg.sender, 10000 * DEC);
    }

    function updateCursETHtoUSD(uint _value) onlyOwner public {
        cursETHtoUSD = _value;
        costUSD = costETH.mul(cursETHtoUSD);
    }

    function updateCostETH(uint _value) onlyOwner public {
        costETH = _value;
        costUSD = costETH.mul(cursETHtoUSD);
    }

    function updateCostUSD(uint _value) onlyOwner public {
        costUSD = _value;
        costETH = costUSD.div(cursETHtoUSD);
    }

    function closeBuy() onlyOwner public {
        buyOpen = false;
    }

    function openBuy() onlyOwner public {
        buyOpen = true;
    }

    function closeSell() onlyOwner public {
        sellOpen = false;
    }

    function openSell() onlyOwner public {
        sellOpen = true;
    }

    function buyTokens() buyIsOpen payable public {
        require(msg.value > 0, "ETH amount must be greater than 0");

        uint amount = msg.value.div(costETH).mul(DEC);
        if (balanceOf(owner()) < amount) {
            _mint(owner(), amount.sub(balanceOf(owner())));
        }

        _transfer(owner(), msg.sender, amount);

        emit Buy(msg.sender, msg.value, amount);
    }

    function() external payable {
        buyTokens();
    }

    function sellTokens(uint amount) sellIsOpen public {
        require(amount > 0, "Tokens amount must be greater than 0");

        uint valueETH = amount.div(DEC).mul(costETH);
        require(valueETH <= address(this).balance, "Not enough balance on the contract");

        _transfer(msg.sender, owner(), amount);
        msg.sender.transfer(valueETH);

        emit Sell(msg.sender, valueETH, amount);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        if (keccak256(to) == keccak256(this)) {
            sellTokens(value);
        } else {
            _transfer(msg.sender, to, value);
        }
        return true;
    }

    function withdraw(address to, uint256 value) onlyOwner public {
        require(address(this).balance >= value, "Not enough balance on the contract");
        to.transfer(value);

        emit Withdraw(to, value);
    }

    function deposit() payable public {
        emit Deposit(msg.sender, msg.value);
    }
}