 

 

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

 


pragma solidity ^0.6.2;

interface Controller {
    function strategist() external view returns (address);
    function vaults(address) external view returns (address);
    function rewards() external view returns (address);
    function balanceOf(address) external view returns (uint);
    function withdraw(address, uint) external;
    function earn(address, uint) external;
}

 


pragma solidity ^0.6.2;

interface Vault {
    function token() external view returns (address);
    function priceE18() external view returns (uint);
    function deposit(uint) external;
    function withdraw(uint) external;
    function depositAll() external;
    function withdrawAll() external;
}

 


pragma solidity ^0.6.2;

interface ICurveFi {
  function coins(int128) external view returns (address);
  function get_virtual_price() external view returns (uint);
  function add_liquidity(uint256[4] calldata amounts, uint256 min_mint_amount) external;
  function remove_liquidity_imbalance(uint256[4] calldata amounts, uint256 max_burn_amount) external;
  function remove_liquidity(uint256 _amount, uint256[4] calldata amounts) external;
  function exchange(int128 from, int128 to, uint256 _from_amount, uint256 _min_to_amount) external;
  function exchange_underlying(int128 from, int128 to, uint256 _from_amount, uint256 _min_to_amount) external;
}

interface ICurveFiBTC {
  function coins(int128) external view returns (address);
  function get_virtual_price() external view returns (uint);
  function add_liquidity(uint256[3] calldata amounts, uint256 min_mint_amount) external;
  function remove_liquidity_imbalance(uint256[3] calldata amounts, uint256 max_burn_amount) external;
  function remove_liquidity(uint256 _amount, uint256[3] calldata amounts) external;
  function exchange(int128 from, int128 to, uint256 _from_amount, uint256 _min_to_amount) external;
  function exchange_underlying(int128 from, int128 to, uint256 _from_amount, uint256 _min_to_amount) external;
}

 


pragma solidity ^0.6.2;

interface IYFIVault {
  function token() external view returns (address);
  function deposit(uint256 _amount) external;
  function withdraw(uint256 _amount) external;
  function getPricePerFullShare() external view returns (uint);
}

 



pragma solidity ^0.6.0;

 
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

 


pragma solidity ^0.6.2;







abstract contract StrategyBaseline {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public want;
    address public governance;
    address public controller;

    constructor(address _want, address _controller) public {
        governance = msg.sender;
        controller = _controller;
        want = _want;
    }

    function deposit() public virtual;

    function withdraw(IERC20 _asset) external virtual returns (uint256 balance);

    function withdraw(uint256 _amount) external virtual;

    function withdrawAll() external virtual returns (uint256 balance);

    function balanceOf() public virtual view returns (uint256);

    function SetGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function SetController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
}

 


pragma solidity ^0.6.2;








abstract contract StrategyBaselineBenzene is StrategyBaseline {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public recv;
    address public fwant;
    address public frecv;

    constructor(address _want, address _controller)
        public
        StrategyBaseline(_want, _controller)
    {}

    function DepositToken(uint256 _amount) internal virtual;

    function WithdrawToken(uint256 _amount) internal virtual;

    function GetPriceE18OfRecvInWant() public virtual view returns (uint256);

    function SetRecv(address _recv) internal {
        recv = _recv;
        frecv = Controller(controller).vaults(recv);
        fwant = Controller(controller).vaults(want);
        require(recv != address(0), "!recv");
        require(fwant != address(0), "!fwant");
        require(frecv != address(0), "!frecv");
    }

    function deposit() public override {
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            DepositToken(_want);
        }
        uint256 _recv = IERC20(recv).balanceOf(address(this));
        if (_recv > 0) {
            IERC20(recv).safeApprove(frecv, 0);
            IERC20(recv).safeApprove(frecv, _recv);
            Vault(frecv).deposit(_recv);
        }
    }

    function withdraw(IERC20 _asset)
        external
        override
        returns (uint256 balance)
    {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        require(recv != address(_asset), "recv");
        require(frecv != address(_asset), "frecv");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    function withdraw(uint256 _aw) external override {
        require(msg.sender == controller, "!controller");
        uint256 _w = IERC20(want).balanceOf(address(this));
        if (_w < _aw) {
            uint256 _ar = _aw.sub(_w).mul(1e18).div(GetPriceE18OfRecvInWant());
            uint256 _r = IERC20(recv).balanceOf(address(this));
            if (_r < _ar) {
                uint256 _af = _ar.sub(_r).mul(1e18).div(
                    Vault(frecv).priceE18()
                );
                uint256 _f = IERC20(frecv).balanceOf(address(this));
                Vault(frecv).withdraw(Math.min(_f, _af));
            }
            _r = IERC20(recv).balanceOf(address(this));
            WithdrawToken(Math.min(_r, _ar));
        }
        _w = IERC20(want).balanceOf(address(this));
        IERC20(want).safeTransfer(fwant, Math.min(_aw, _w));
    }

    function withdrawAll() external override returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        uint256 _frecv = IERC20(frecv).balanceOf(address(this));
        if (_frecv > 0) {
            Vault(frecv).withdraw(_frecv);
        }
        uint256 _recv = IERC20(recv).balanceOf(address(this));
        if (_recv > 0) {
            WithdrawToken(_recv);
        }
        balance = IERC20(want).balanceOf(address(this));
        IERC20(want).safeTransfer(fwant, balance);
    }

    function balanceOf() public override view returns (uint256) {
        uint256 _frecv = IERC20(frecv).balanceOf(address(this));
        uint256 _recv = IERC20(recv).balanceOf(address(this));
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_frecv > 0) {
            _frecv = Vault(frecv).priceE18().mul(_frecv).div(1e18);
            _recv = _recv.add(_frecv);
        }
        if (_recv > 0) {
            _recv = GetPriceE18OfRecvInWant().mul(_recv).div(1e18);
            _want = _want.add(_recv);
        }
        return _want;
    }
}

 


pragma solidity ^0.6.2;










contract StrategyBaselineBenzeneYearn is StrategyBaselineBenzene {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;


    constructor(address _y, address _controller)
        public
        StrategyBaselineBenzene(IYFIVault(_y).token(), _controller)
    {
        SetRecv(_y);
    }

    function DepositToken(uint256 _amount) internal override {
        IERC20(want).safeApprove(recv, 0);
        IERC20(want).safeApprove(recv, _amount);
        IYFIVault(recv).deposit(_amount);
    }

    function WithdrawToken(uint256 _amount) internal override {
        IYFIVault(recv).withdraw(_amount);
    }

    function GetPriceE18OfRecvInWant() public override view returns (uint256) {
        return IYFIVault(recv).getPricePerFullShare();
    }
}

 


pragma solidity ^0.6.2;


contract StrategyBaselineBenzeneYearnDAI is StrategyBaselineBenzeneYearn {
    constructor()
        public
        StrategyBaselineBenzeneYearn(
            address(0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}