 

pragma solidity >=0.4.24 <0.7.0;


 
contract Initializable {

   
  bool private initialized;

   
  bool private initializing;

   
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

   
  function isConstructor() private view returns (bool) {
     
     
     
     
     
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

   
  uint256[50] private ______gap;
}

 

interface IController {
    function owner() view external returns (address);
}

 

pragma solidity ^0.5.0;

 
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

 

pragma solidity ^0.5.0;

 
library Math {
     
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

     
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

     
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

 

pragma solidity ^0.5.0;


 
library Arrays {
    
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

             
             
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

         
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}

 

pragma solidity ^0.5.16;



 
library Counters {
    using SafeMath for uint256;

    struct Counter {
         
         
         
        uint256 _value;  
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
         
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

 

pragma solidity ^0.5.16;






contract DfDepositToken is
    Initializable
{
    using SafeMath for uint256;
    using Arrays for uint256[];
    using Counters for Counters.Counter;

     
     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);

     
     
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping (address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

     
    Counters.Counter private _currentSnapshotId;

     
    event Snapshot(uint256 id);

    struct BalanceData {
        uint256 balance;
        uint256 lockedBalance;
        uint256 timestampDivs;
    }

    mapping (address => BalanceData) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    string private _name;

    string private _symbol;

    uint8 private _decimals;

    address private _controller;


    function initialize(string memory name, string memory symbol, uint8 decimals, address controller) public initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _controller = controller;
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

     
     
    function snapshot() external returns (uint256) {
        require(msg.sender == _controller, 'Access denied');
        _currentSnapshotId.increment();

        uint256 currentId = _currentSnapshotId.current();
        emit Snapshot(currentId);
        return currentId;
    }

     
    function balanceOfAt(address account, uint256 snapshotId) public view returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

     
    function totalSupplyAt(uint256 snapshotId) public view returns(uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
    private view returns (bool, uint256)
    {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
         
        require(snapshotId <= _currentSnapshotId.current(), "ERC20Snapshot: nonexistent id");

         
         
         
         
         
         
         
         
         
         
         
         
         

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _currentSnapshotId.current();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
     

     
    function transfer(address[] memory recipients, uint256[] memory amounts) public returns(bool) {
        require(recipients.length == amounts.length, "Arrays lengths not equal");

         
        for (uint i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }

        return true;
    }

     
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view returns (uint256) {
        if (block.timestamp >= _balances[account].timestampDivs) return balanceOfWithoutLocked(account);

        return _balances[account].balance;
    }

    function balanceOfWithoutLocked(address account) public view returns (uint256) {
        return _balances[account].balance.sub(_balances[account].lockedBalance);
    }

    function transferBackLockedTokens(address[] memory accounts, address target) public {
        require(msg.sender == _controller);
        uint256 totalTokens = 0;
        for(uint16 i = 0; i < accounts.length;i++) {
            BalanceData storage data = _balances[accounts[i]];
            if (data.lockedBalance > 0 && block.timestamp >= data.timestampDivs) {
                totalTokens = totalTokens.add(data.lockedBalance);
                emit Transfer(accounts[i], target, data.lockedBalance);
                data.balance = data.balance.sub(data.lockedBalance);
                data.lockedBalance = 0;
                data.timestampDivs = 0;
            }
        }
        _balances[target].balance = _balances[target].balance.add(totalTokens);
    }

    function transferWithLock(address sender, address recipient, uint256 amount, uint256 timestampDivs) public returns (bool) {
        require(msg.sender == _controller);
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(sender != recipient, "ERC20: cant send with lock to yourself");

        BalanceData storage _senderData = _balances[sender];
        BalanceData storage _recipientData = _balances[recipient];

        require(_senderData.balance.sub(_senderData.lockedBalance).sub(amount) >= 0);

        _senderData.balance = _senderData.balance.sub(amount);
        _recipientData.balance = _recipientData.balance.add(amount);
        _recipientData.lockedBalance = _recipientData.lockedBalance.add(amount);
        if (timestampDivs > _recipientData.timestampDivs) _recipientData.timestampDivs = timestampDivs;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(address account, uint256 amount) public {
        require(msg.sender == _controller, 'Access denied');
        _mint(account, amount);
    }

    function info(address account) public view returns (uint256 balance, uint256 lockedBalance, uint256 timestampDivs) {
        balance = _balances[account].balance;
        lockedBalance = _balances[account].lockedBalance;
        timestampDivs = _balances[account].timestampDivs;
    }

     
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _updateAccountSnapshot(sender);
        _updateAccountSnapshot(recipient);

        BalanceData storage _senderData = _balances[sender];
        BalanceData storage _recipientData = _balances[recipient];

        require(_senderData.balance.sub(_senderData.lockedBalance) >= amount);

        _senderData.balance = _senderData.balance.sub(amount);
        _recipientData.balance = _recipientData.balance.add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();

        _totalSupply = _totalSupply.add(amount);
        _balances[account].balance = _balances[account].balance.add(amount);
        emit Transfer(address(0), account, amount);
    }



     
    function burn(address account, uint256 amount) public {
        require(msg.sender == _controller);
        require(account != address(0), "ERC20: burn from the zero address");

        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();

        require(_balances[account].balance.sub(_balances[account].lockedBalance) >= amount, "ERC20: burn amount exceeds balance");

        _balances[account].balance = _balances[account].balance.sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}