 
pragma solidity >=0.4.23 >=0.6.0 <0.7.0 >=0.6.2 <0.7.0 >=0.6.7 <0.7.0;

 
 

 

interface IController {
    function jars(address) external view returns (address);

    function rewards() external view returns (address);

    function want(address) external view returns (address);  

    function balanceOf(address) external view returns (uint256);

    function withdraw(address, uint256) external;

    function earn(address, uint256) external;
}

 

 

interface ICurveFi {
    function get_virtual_price() external view returns (uint256);

    function add_liquidity(uint256[4] calldata amounts, uint256 min_mint_amount)
        external;

    function remove_liquidity_imbalance(
        uint256[4] calldata amounts,
        uint256 max_burn_amount
    ) external;

    function remove_liquidity(uint256 _amount, uint256[4] calldata amounts)
        external;

    function exchange(
        int128 from,
        int128 to,
        uint256 _from_amount,
        uint256 _min_to_amount
    ) external;

    function balances(int128) external view returns (uint256);
}

interface ICurveGauge {
    function deposit(uint256 _value) external;

    function deposit(uint256 _value, address addr) external;

    function balanceOf(address arg0) external view returns (uint256);

    function withdraw(uint256 _value) external;

    function withdraw(uint256 _value, bool claim_rewards) external;

    function claim_rewards() external;

    function claim_rewards(address addr) external;

    function claimable_tokens(address addr) external returns (uint256);

    function claimable_reward(address addr) external view returns (uint256);

    function integrate_fraction(address arg0) external view returns (uint256);
}

interface ICurveMintr {
    function mint(address) external;

    function minted(address arg0, address arg1) external view returns (uint256);
}

 


 

 
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
 

 



 

 

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 


 
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
 

 

 

interface IJar is IERC20 {
    function token() external view returns (address);

    function claimInsurance() external;  

    function getRatio() external view returns (uint256);

    function deposit(uint256) external;

    function withdraw(uint256) external;

    function earn() external;
}

 

 

interface OneSplitAudit {
    function getExpectedReturn(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 parts,
        uint256 featureFlags
    )
        external
        view
        returns (uint256 returnAmount, uint256[] memory distribution);

    function swap(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution,
        uint256 featureFlags
    ) external payable;
}

 
 


 

 
 

 
 
 
 

contract StrategyCurveSCRVv1 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

     
    address public constant want = 0xC25a3A3b969415c80451098fa907EC722572917F;

     
    address public constant curve = 0xA5407eAE9Ba41422680e2e00537571bcC53efBfD;

     
    address public constant crv = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address public constant snx = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;

     
    address public constant gauge = 0xA90996896660DEcC6E997655E065b23788857849;
    address public constant mintr = 0xd061D61a4d941c39E5453435B6345Dc261C2fcE0;

     
    address public constant dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant susd = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;

     
    address public constant pickle = 0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5;

     
    address public constant burn = 0x000000000000000000000000000000000000dEaD;

     
    address public onesplit = 0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E;
    uint256 public parts = 2;  

     
     
     
     

     
    uint256 public performanceFee = 300;
    uint256 public constant performanceMax = 10000;

    uint256 public burnFee = 150;
    uint256 public constant burnMax = 10000;

    uint256 public callerFee = 50;
    uint256 public constant callerMax = 10000;

    uint256 public withdrawalFee = 50;
    uint256 public constant withdrawalMax = 10000;

    address public governance;
    address public controller;
    address public strategist;

    constructor(
        address _governance,
        address _strategist,
        address _controller
    ) public {
        governance = _governance;
        strategist = _strategist;
        controller = _controller;
    }

     

    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfPool() public view returns (uint256) {
        return ICurveGauge(gauge).balanceOf(address(this));
    }

    function balanceOf() public view returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }

    function getName() external pure returns (string memory) {
        return "StrategyCurveSCRVv1";
    }

    function getMostPremiumStablecoin() public view returns (address, uint256) {
        uint256[] memory balances = new uint256[](4);
        balances[0] = ICurveFi(curve).balances(0);  
        balances[1] = ICurveFi(curve).balances(1).mul(10**12);  
        balances[2] = ICurveFi(curve).balances(2).mul(10**12);  
        balances[3] = ICurveFi(curve).balances(3);  

         
        if (
            balances[0] < balances[1] &&
            balances[0] < balances[2] &&
            balances[0] < balances[3]
        ) {
            return (dai, 0);
        }

         
        if (
            balances[1] < balances[0] &&
            balances[1] < balances[2] &&
            balances[1] < balances[3]
        ) {
            return (usdc, 1);
        }

         
        if (
            balances[2] < balances[0] &&
            balances[2] < balances[1] &&
            balances[2] < balances[3]
        ) {
            return (usdt, 2);
        }

         
        if (
            balances[3] < balances[0] &&
            balances[3] < balances[1] &&
            balances[3] < balances[2]
        ) {
            return (susd, 3);
        }

         
        return (dai, 0);
    }

     
     
     
    function getExpectedRewards()
        public
        returns (
            address,  
            uint256,  
            uint256  
        )
    {
         
        (address to, ) = getMostPremiumStablecoin();

         
        uint256 _to;
        uint256 _pickleBurn;
        uint256 _retAmount;

         
        uint256 _crv = ICurveGauge(gauge).claimable_tokens(address(this));
        if (_crv > 0) {
            (_retAmount, ) = OneSplitAudit(onesplit).getExpectedReturn(
                crv,
                to,
                _crv,
                parts,
                0
            );
            _to = _to.add(_retAmount);
        }

         
        uint256 _snx = ICurveGauge(gauge).claimable_reward(address(this));
        if (_snx > 0) {
            (_retAmount, ) = OneSplitAudit(onesplit).getExpectedReturn(
                snx,
                to,
                _snx,
                parts,
                0
            );
            _to = _to.add(_retAmount);
        }

        if (_to > 0) {
            (_pickleBurn, ) = OneSplitAudit(onesplit).getExpectedReturn(
                to,
                pickle,
                _to.mul(burnFee).div(burnMax),
                parts,
                0
            );
        }

        return (
            to,
            _to.mul(callerFee).div(callerMax),  
            _pickleBurn  
        );
    }

     

    function setStrategist(address _strategist) external {
        require(msg.sender == governance, "!governance");
        strategist = _strategist;
    }

    function setWithdrawalFee(uint256 _withdrawalFee) external {
        require(msg.sender == governance, "!governance");
        withdrawalFee = _withdrawalFee;
    }

    function setPerformanceFee(uint256 _performanceFee) external {
        require(msg.sender == governance, "!governance");
        performanceFee = _performanceFee;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }

    function setOneSplit(address _onesplit) public {
        require(msg.sender == governance, "!governance");
        onesplit = _onesplit;
    }

    function setParts(uint256 _parts) public {
        require(msg.sender == governance, "!governance");
        parts = _parts;
    }

     

    function deposit() public {
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            IERC20(want).safeApprove(gauge, 0);
            IERC20(want).approve(gauge, _want);
            ICurveGauge(gauge).deposit(_want);
        }
    }

     
    function withdraw(IERC20 _asset) external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        require(crv != address(_asset), "crv");
        require(snx != address(_asset), "snx");
        require(dai != address(_asset), "dai");
        require(usdc != address(_asset), "usdc");
        require(usdt != address(_asset), "usdt");
        require(susd != address(_asset), "susd");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

     
    function withdraw(uint256 _amount) external {
        require(msg.sender == controller, "!controller");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        uint256 _fee = _amount.mul(withdrawalFee).div(withdrawalMax);

        IERC20(want).safeTransfer(IController(controller).rewards(), _fee);
        address _jar = IController(controller).jars(address(want));
        require(_jar != address(0), "!jar");  

        IERC20(want).safeTransfer(_jar, _amount.sub(_fee));
    }

     
    function withdrawAll() external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();

        balance = IERC20(want).balanceOf(address(this));

        address _jar = IController(controller).jars(address(want));
        require(_jar != address(0), "!jar");  
        IERC20(want).safeTransfer(_jar, balance);
    }

    function _withdrawAll() internal {
        ICurveGauge(gauge).withdraw(
            ICurveGauge(gauge).balanceOf(address(this))
        );
    }

    function _withdrawSome(uint256 _amount) internal returns (uint256) {
        ICurveGauge(gauge).withdraw(_amount);
        return _amount;
    }

    function brine() public {
        harvest();
    }

    function harvest() public {
         
         
         
         
         

         
        (address to, uint256 toIndex) = getMostPremiumStablecoin();

         
         
        ICurveMintr(mintr).mint(gauge);
        uint256 _crv = IERC20(crv).balanceOf(address(this));
        if (_crv > 0) {
            _swap(crv, to, _crv);
        }

         
        ICurveGauge(gauge).claim_rewards(address(this));
        uint256 _snx = IERC20(snx).balanceOf(address(this));
        if (_snx > 0) {
            _swap(snx, to, _snx);
        }

         
         
        uint256 _to = IERC20(to).balanceOf(address(this));
        if (_to > 0) {
             
             
            uint256 _callerFee = _to.mul(callerFee).div(callerMax);
            IERC20(to).safeTransfer(msg.sender, _callerFee);

             
            uint256 _burnFee = _to.mul(burnFee).div(burnMax);
            _swap(to, pickle, _burnFee);
            IERC20(pickle).transfer(
                burn,
                IERC20(pickle).balanceOf(address(this))
            );

             
            _to = _to.sub(_callerFee).sub(_burnFee);
            IERC20(to).safeApprove(curve, 0);
            IERC20(to).safeApprove(curve, _to);
            uint256[4] memory liquidity;
            liquidity[toIndex] = _to;
            ICurveFi(curve).add_liquidity(liquidity, 0);
        }

         
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
             
             
             
             
             
            IERC20(want).safeTransfer(
                IController(controller).rewards(),
                _want.mul(performanceFee).div(performanceMax)
            );

            deposit();
        }
    }

    function _swap(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
         
        uint256 expected;
        uint256[] memory distribution;

        IERC20(_from).safeApprove(onesplit, 0);
        IERC20(_from).safeApprove(onesplit, _amount);

        (expected, distribution) = OneSplitAudit(onesplit).getExpectedReturn(
            _from,
            _to,
            _amount,
            parts,
            0
        );
        OneSplitAudit(onesplit).swap(
            _from,
            _to,
            _amount,
            parts,
            distribution,
            0
        );
    }
}