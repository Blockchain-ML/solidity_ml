 

pragma solidity ^0.6.2;

 
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

interface IuFFYI is IERC20 {
    function mint(address account, uint256 amount) external returns (bool);
    function burn(address account, uint256 amount) external;
}

interface Aave {
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external;
}

interface AToken is IERC20 {
    function redeem(uint256 amount) external;
}

interface LendingPoolAddressesProvider {
    function getLendingPool() external view returns (address);
    function getLendingPoolCore() external view returns (address);
}

interface Uniswap {
    function swapExactTokensForTokens(
                uint amountIn,
                uint amountOutMin,
                address[] calldata path,
                address to,
                uint deadline
              ) external returns (uint[] memory amounts);
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
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
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


 
abstract contract ERC20Burnable is Context, ERC20 {
     
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

     
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
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
         
         
         

        uint256 size;
         
        assembly { size := extcodesize(account) }
        return size > 0;
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


 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract fDAIpool is ERC20, ReentrancyGuard, Ownable {
  using SafeERC20 for IERC20;
  using SafeERC20 for IuFFYI;
  using Address for address;
  using SafeMath for uint256;

  mapping(address => uint256) private startStaking;
  mapping(address => uint256) private rewards;
  mapping(uint256 => uint256) private totalBlocks;
  uint256[] private blocks;

  uint256 private rewardSpeed = 10000000000000000000000000000000000; 
  uint16 private refcode = 0; 
  address aave = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);
  address UniswapV2Router02 = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

  uint256 private minRedeem = 1; 
  address WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

  address uFFYIAddress = address(0x021576770CB3729716CCfb687afdB4c6bF720CB6);
  IuFFYI public uFFYI  = IuFFYI(uFFYIAddress);

  address poolTokenAddress = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);  
  IERC20 public poolToken  = IERC20(poolTokenAddress);  

  address aaveTokenAddress = address(0xfC1E690f61EFd961294b3e1Ce3313fBD8aa4f85d);
  AToken public aaveToken  = AToken(aaveTokenAddress);  


  constructor () public ERC20("wrapped DAI", "fDAI")  {
    uint256 blockNumber = getBlockNumber();
    blocks.push(blockNumber);
    totalBlocks[blockNumber] = totalSupply();
    poolToken.safeApprove(getAaveCore(), uint(-1));
    poolToken.safeApprove(UniswapV2Router02, uint(-1));
  }



  function stake(uint256 amount) public {
      

      if (startStaking[_msgSender()] > 0) {   
          rewards[_msgSender()] = earned(_msgSender());
      }
      _mint(_msgSender(), amount);
      uint256 blockNumber = getBlockNumber();
      startStaking[_msgSender()] = blockNumber;


      totalBlocks[blockNumber] = totalSupply();
      if (blocks.length>0) {
        if (blocks[blocks.length - 1] < blockNumber) {
          blocks.push(blockNumber);
        }
      } else {
        blocks.push(blockNumber);
      }
      
      poolToken.safeTransferFrom(_msgSender(), address(this), amount);
      Aave(getAave()).deposit(poolTokenAddress, amount, refcode);
  }

  function withdraw(uint256 amount) public {
      rewards[_msgSender()] = earned(_msgSender());

      uint256 blockNumber = getBlockNumber();
      if (balanceOf(_msgSender()) == amount) {
        startStaking[_msgSender()] = 0;
      } else {
        startStaking[_msgSender()] = blockNumber;
      }

      if (blocks.length>0) {
        if (blocks[blocks.length - 1] < blockNumber) {
          blocks.push(blockNumber);
        }
      } else {
        blocks.push(blockNumber);
      }
      totalBlocks[blockNumber] = totalSupply();

      uint256 uDAIrewards = checkRewards();
      aaveToken.redeem(amount.add(uDAIrewards));
      
      _burn(_msgSender(), amount);
      
      poolToken.safeTransfer(_msgSender(), amount);
      if (uDAIrewards > 0) {
          swapAndBurn(uDAIrewards);
      }
  }

  function stopPool () public onlyOwner {
    rewardSpeed = 1;
  }

  
  function checkRewards() private view returns (uint256) {
      uint256 aavebalance = aaveToken.balanceOf(address(this));
      uint256 wrappedbalance = totalSupply();
      uint256 uDAIrewards = aavebalance.sub(wrappedbalance);
      if ( uDAIrewards > minRedeem ) {
          return uDAIrewards;
      } else {
          return 0;
      }
  }

  function swapAndBurn(uint256 uDAIrewards) private {
      uint256 amountOutMin = 0;
      address[] memory path = new address[](3);
      path[0] = poolTokenAddress;
      path[1] = WETH;
      path[2] = uFFYIAddress;
      
      Uniswap(UniswapV2Router02).swapExactTokensForTokens(uDAIrewards,amountOutMin,path,address(this),block.timestamp+1);
      uFFYI.burn(address(this), uFFYI.balanceOf(address(this)));
  }

  function earned(address account) public view returns (uint256) {
      uint256 lastblock = getBlockNumber();
      uint256 deltaRewards = 0;
      
      if (startStaking[account] > 0) {
        
        for (uint256 i=blocks.length-1; i>0; i--) {
          uint256 firstblock = blocks[i];
          if (blocks[i]<startStaking[account]) {
            firstblock = startStaking[account];
          }
          deltaRewards = deltaRewards.add(balanceOf(account).mul(_rewardPerToken(totalBlocks[blocks[i]])).mul(lastblock.sub(firstblock)).div(1e18));
          if (blocks[i]<startStaking[account]) {
            break;
          }
          lastblock = blocks[i];
        }
      }
      
      return
          deltaRewards
              .add(rewards[account]);
  }
  
  function rewardPerToken() public view returns (uint256) {
    if (totalSupply() == 0) {
        return 0;
    }
    return
        rewardSpeed.div(totalSupply());
  }
  
  function _rewardPerToken(uint256 total) private view returns (uint256) {
    if (total == 0) {
        return 0;
    }
    return
        rewardSpeed.div(total);
  }

  function exit() public {
      withdraw(balanceOf(_msgSender()));
      if (rewards[_msgSender()] > 0) {
          uFFYI.safeTransfer(_msgSender(), rewards[_msgSender()]);
          rewards[_msgSender()] = 0;
      }
  }

  function getReward() public {
      uint256 reward = earned(_msgSender());
      if (reward > 0) {
          rewards[_msgSender()] = 0;
          startStaking[_msgSender()] = getBlockNumber();
          uFFYI.mint(_msgSender(), reward);
      }
  }
  

  function getBlockNumber() public view returns (uint256) {
      return block.number;
  }

  function getAave() public view returns (address) {
      return LendingPoolAddressesProvider(aave).getLendingPool();
  }
  
  function getAaveCore() public view returns (address) {
    return LendingPoolAddressesProvider(aave).getLendingPoolCore();
  }
}