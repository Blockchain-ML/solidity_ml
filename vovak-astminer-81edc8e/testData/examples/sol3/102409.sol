 

 

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

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
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

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
             
            if (returndata.length > 0) {
                 

                 
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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

 

pragma solidity ^0.6.2;

interface ICompatibleDerivativeToken {
    event Issue(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 derivativeAmount,
        uint256 underlyingAmount
    );
    event Reclaim(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 derivativeAmount,
        uint256 underlyingAmount
    );

    event Move(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 derivativeAmount,
        uint256 underlyingAmount
    );

    function issue(address to, uint256 derivativeAmount) external;
    function issueIn(address to, uint256 underlyingAmount) external;

    function reclaim(address to, uint256 derivativeAmount) external;
    function reclaimIn(address to, uint256 underlyingAmount) external;

    function underlying() external view returns (address);

    function sync() external;

    function underlyingBalanceOf(address account) external view returns (uint256);

    function toUnderlyingForIssue(uint256 derivativeAmount) external view returns(uint256);
    function toDerivativeForIssue(uint256 underlyingAmount) external view returns(uint256);
    function toUnderlyingForReclaim(uint256 derivativeAmount) external view returns(uint256);
    function toDerivativeForReclaim(uint256 underlyingAmount) external view returns(uint256);
}

interface IDerivativeToken is ICompatibleDerivativeToken {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

 


pragma solidity ^0.6.8;





contract Campl is ERC20, ICompatibleDerivativeToken {
    using SafeMath for uint256;

    IERC20 ampl;
    uint256 constant E26 = 1.00E26;

    constructor(IERC20 _ampl) public ERC20("Compatable AMPL", "CAMPL") {
        ampl = _ampl;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20) {
        emit Move(_msgSender(), from, to, amount, toUnderlyingForReclaim(amount));
    }

    function roundUpDiv(uint256 x, uint256 y) private pure returns (uint256) {
        return (x.add(y.sub(1))).div(y);
    }

    function issue(address to, uint256 derivativeAmount) external override {
        require(derivativeAmount != 0, "Campl.issue: 0 amount");
        uint256 underlyingAmount = toUnderlyingForIssue(derivativeAmount);

        require(ampl.allowance(_msgSender(), address(this)) >= underlyingAmount, "Campl.issue: not enough AMPL allowance");
        require(ampl.balanceOf(_msgSender()) >= underlyingAmount, "Campl.issue: not enough AMPL balance");
        ampl.transferFrom(_msgSender(), address(this), underlyingAmount);

        _mint(to, derivativeAmount);

        emit Issue(_msgSender(), _msgSender(), to, derivativeAmount, underlyingAmount);
    }

    function issueIn(address to, uint256 underlyingAmount) external override {
        require(underlyingAmount != 0, "Campl.issueIn: 0 amount");
        require(ampl.allowance(_msgSender(), address(this)) >= underlyingAmount, "Campl.issueIn: not enough AMPL allowance");
        require(ampl.balanceOf(_msgSender()) >= underlyingAmount, "Campl.issueIn: not enough AMPL balance");
        uint256 derivativeAmount = toDerivativeForIssue(underlyingAmount);
        ampl.transferFrom(_msgSender(), address(this), underlyingAmount);

        _mint(to, derivativeAmount);

        emit Issue(_msgSender(), _msgSender(), to, derivativeAmount, underlyingAmount);
    }

    function reclaim(address to, uint256 derivativeAmount) external override {
        require(derivativeAmount != 0, "Campl.reclaim: 0 amount");
        require(to != address(0), "Campl.reclaim: reclaim to the zero address");

        uint256 underlyingAmount = toUnderlyingForReclaim(derivativeAmount);

        _burn(_msgSender(), derivativeAmount);

        ampl.transfer(to, underlyingAmount);
        emit Reclaim(_msgSender(), _msgSender(), to, derivativeAmount, underlyingAmount);
    }

    function reclaimIn(address to, uint256 underlyingAmount) external override {
        require(underlyingAmount != 0, "Campl.reclaimIn: 0 amount");
        require(to != address(0), "Campl.reclaimIn: reclaimIn to the zero address");
        uint256 derivativeAmount = toDerivativeForReclaim(underlyingAmount);

        _burn(_msgSender(), derivativeAmount);

        ampl.transfer(to, underlyingAmount);
        emit Reclaim(_msgSender(), _msgSender(), to, derivativeAmount, underlyingAmount);
    }

    function underlying() external view override returns (address) {
        return address(ampl);
    }

    function sync() public override {
    }

    function underlyingBalanceOf(address account) external view override returns (uint256) {
        return toUnderlyingForReclaim(balanceOf(account));
    }

    function toUnderlyingForIssue(uint256 derivativeAmount) public view override returns(uint256) {
        return roundUpDiv(derivativeAmount.mul(ampl.totalSupply()), E26);
    }

    function toDerivativeForIssue(uint256 underlyingAmount) public view override returns(uint256) {
        return underlyingAmount.mul(E26).div(ampl.totalSupply());
    }

    function toUnderlyingForReclaim(uint256 derivativeAmount) public view override returns(uint256) {
        return derivativeAmount.mul(ampl.totalSupply()).div(E26);
    }

    function toDerivativeForReclaim(uint256 underlyingAmount) public view override returns(uint256) {
        return roundUpDiv(underlyingAmount.mul(E26), ampl.totalSupply());
    }
}