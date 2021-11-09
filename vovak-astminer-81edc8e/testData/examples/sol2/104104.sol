 

pragma solidity ^0.5.0;

 
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

 

pragma solidity ^0.5.0;

 
contract Context {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
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




 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

     
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
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

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

      
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

 

pragma solidity ^0.5.5;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

     
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

 

pragma solidity ^0.5.0;




 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function callOptionalReturn(IERC20 token, bytes memory data) private {
         
         

         
         
         
         
         
        require(address(token).isContract(), "SafeERC20: call to non-contract");

         
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 

pragma solidity ^0.5.0;


 
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
}

 

pragma solidity 0.5.16;

contract DyDxStructs {
  enum ActionType {
    Deposit,    
    Withdraw,   
    Transfer,   
    Buy,        
    Sell,       
    Trade,      
    Liquidate,  
    Vaporize,   
    Call        
  }
  enum AssetDenomination { Wei }
  enum AssetReference { Delta }  

  struct AssetAmount {
    bool sign;  
    AssetDenomination denomination;
    AssetReference ref;
    uint256 value;
  }

  struct ActionArgs {
    ActionType actionType;
    uint256 accountId;
    AssetAmount amount;
    uint256 primaryMarketId;
    uint256 secondaryMarketId;
    address otherAddress;
    uint256 otherAccountId;
    bytes data;
  }

  struct Info {
    address owner;   
    uint256 number;  
  }

  struct Wei {
    bool sign;  
    uint256 value;
  }
}

 

pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


contract DyDx is DyDxStructs {
  function getEarningsRate() external view returns (uint256 value);
  function getMarketInterestSetter(uint256 marketId) external view returns (address interestSetter);
  function getMarketInterestRate(uint256 marketId) external view returns (uint256 value);
  function getMarketCurrentIndex(uint256 marketId) external view returns (uint256 borrow, uint256 supply);
  function getMarketTotalPar(uint256 marketId) external view returns (uint256 borrow, uint256 supply);
  function getAccountWei(Info calldata account, uint256 marketId) external view returns (Wei memory);
  function operate(Info[] calldata, ActionArgs[] calldata) external;
}

 

 

pragma solidity 0.5.16;







contract yxToken is DyDxStructs, ERC20, ERC20Detailed {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  uint256 public marketId;
  uint256 public secondsInAYear;
   
  address public underlying;
  address public constant dydxAddressesProvider = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
  DyDx dydx = DyDx(dydxAddressesProvider);
   
  constructor(address _underlying, uint256 _marketId, string memory _name, string memory _symbol, uint8 _decimals)
    public ERC20Detailed(_name, _symbol, _decimals) {
    require(_underlying != address(0), 'Underlying is 0');

    underlying = _underlying;
    marketId = _marketId;  
    IERC20(_underlying).approve(dydxAddressesProvider, uint256(-1));
  }

   
  function price() public view returns (uint256) {
    (, uint256 supplyIndex) = dydx.getMarketCurrentIndex(marketId);
    return supplyIndex;
  }

  function availableLiquidity() external view returns (uint256) {
    return IERC20(underlying).balanceOf(dydxAddressesProvider);
  }

  function balanceInUnderlying(address who) external view returns (uint256) {
    return balanceOf(who).mul(price()).div(10**18);
  }

   
  function mint(uint256 _amount)
    external
    returns (uint256 newTokens) {
       
      newTokens = _amount.mul(10**18).div(price());
      _mint(msg.sender, newTokens);

      IERC20(underlying).safeTransferFrom(msg.sender, address(this), _amount);

       
      _mintDyDx(_amount);
  }

  function _mintDyDx(uint256 _amount)
    internal {
      Info[] memory infos = new Info[](1);
      infos[0] = Info(address(this), 0);
      AssetAmount memory amt = AssetAmount(true, AssetDenomination.Wei, AssetReference.Delta, _amount);
      ActionArgs memory act;
      act.actionType = ActionType.Deposit;
      act.accountId = 0;
      act.amount = amt;
      act.primaryMarketId = marketId;
      act.otherAddress = address(this);

      ActionArgs[] memory args = new ActionArgs[](1);
      args[0] = act;

      dydx.operate(infos, args);
  }

   
  function redeem(uint256 _amount, address _account)
    external
    returns (uint256 tokens) {
      _redeemDyDx(_amount.mul(price()).div(10**18));

       
      IERC20 _underlying = IERC20(underlying);
      tokens = _underlying.balanceOf(address(this));
      _underlying.safeTransfer(_account, tokens);

      _burn(msg.sender, _amount);
  }

  function _redeemDyDx(uint256 _amount)
    internal {
      Info[] memory infos = new Info[](1);
      infos[0] = Info(address(this), 0);

      AssetAmount memory amt = AssetAmount(false, AssetDenomination.Wei, AssetReference.Delta, _amount);
      ActionArgs memory act;
      act.actionType = ActionType.Withdraw;
      act.accountId = 0;
      act.amount = amt;
      act.primaryMarketId = marketId;
      act.otherAddress = address(this);

      ActionArgs[] memory args = new ActionArgs[](1);
      args[0] = act;

      dydx.operate(infos, args);
  }
}