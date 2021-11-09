 
pragma solidity >0.4.13 >=0.4.23 >=0.5.0 >=0.6.0 <0.7.0 >=0.6.2 <0.7.0 >=0.6.7 <0.7.0;

 
 
 
 
 

 
 
 
 

 
 

 

interface DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) external view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

 
 

 
 
 
 

 
 
 
 

 
 

 

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

     
    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
     
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
     
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
     
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

 
 

 

 
 
 
 

 
 
 
 

 
 

 

 
 


contract DSToken is DSMath, DSAuth {
    bool                                              public  stopped;
    uint256                                           public  totalSupply;
    mapping (address => uint256)                      public  balanceOf;
    mapping (address => mapping (address => uint256)) public  allowance;
    bytes32                                           public  symbol;
    uint256                                           public  decimals = 18;  
    bytes32                                           public  name = "";      

    constructor(bytes32 symbol_) public {
        symbol = symbol_;
    }

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event Mint(address indexed guy, uint wad);
    event Burn(address indexed guy, uint wad);
    event Stop();
    event Start();

    modifier stoppable {
        require(!stopped, "ds-stop-is-stopped");
        _;
    }

    function approve(address guy) external returns (bool) {
        return approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public stoppable returns (bool) {
        allowance[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }

    function transfer(address dst, uint wad) external returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        stoppable
        returns (bool)
    {
        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad, "ds-token-insufficient-approval");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }

        require(balanceOf[src] >= wad, "ds-token-insufficient-balance");
        balanceOf[src] = sub(balanceOf[src], wad);
        balanceOf[dst] = add(balanceOf[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function push(address dst, uint wad) external {
        transferFrom(msg.sender, dst, wad);
    }

    function pull(address src, uint wad) external {
        transferFrom(src, msg.sender, wad);
    }

    function move(address src, address dst, uint wad) external {
        transferFrom(src, dst, wad);
    }


    function mint(uint wad) external {
        mint(msg.sender, wad);
    }

    function burn(uint wad) external {
        burn(msg.sender, wad);
    }

    function mint(address guy, uint wad) public auth stoppable {
        balanceOf[guy] = add(balanceOf[guy], wad);
        totalSupply = add(totalSupply, wad);
        emit Mint(guy, wad);
    }

    function burn(address guy, uint wad) public auth stoppable {
        if (guy != msg.sender && allowance[guy][msg.sender] != uint(-1)) {
            require(allowance[guy][msg.sender] >= wad, "ds-token-insufficient-approval");
            allowance[guy][msg.sender] = sub(allowance[guy][msg.sender], wad);
        }

        require(balanceOf[guy] >= wad, "ds-token-insufficient-balance");
        balanceOf[guy] = sub(balanceOf[guy], wad);
        totalSupply = sub(totalSupply, wad);
        emit Burn(guy, wad);
    }

    function stop() public auth {
        stopped = true;
        emit Stop();
    }

    function start() public auth {
        stopped = false;
        emit Start();
    }

    function setName(bytes32 name_) external auth {
        name = name_;
    }
}

 
 


library Constants {
     
    address constant SNX = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant SUSHI = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
    address constant UNIV2_SUSHI_ETH = 0xCE84867c3c02B05dc570d0135103d3fB9CC19433;
    address constant UNIV2_SNX_ETH = 0x43AE24960e5534731Fc831386c07755A2dc33D47;

     
    address constant UNIV2_ROUTER2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

     
    address constant MASTERCHEF = 0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd;
}
 
 
 

interface Masterchef {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function pendingSushi(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function poolInfo(uint256)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accSushiPerShare
        );

    function userInfo(uint256, address)
        external
        view
        returns (uint256 amount, uint256 rewardDebt);

    function updatePool(uint256 _pid) external;
}

 
 
 

interface UniswapRouterV2 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}

interface UniswapPair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestamp
        );
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
 
 

 

 
 

 
 

 
 

 

contract LPFarm {
    using SafeMath for uint256;

     
    DSToken public sushi = DSToken(Constants.SUSHI);
    DSToken public snx = DSToken(Constants.SNX);
    DSToken public weth = DSToken(Constants.WETH);
    DSToken public lpToken = DSToken(Constants.UNIV2_SNX_ETH);
    DSToken public degenLpToken;

     
    UniswapRouterV2 public univ2 = UniswapRouterV2(Constants.UNIV2_ROUTER2);
    UniswapPair public univ2Pair = UniswapPair(address(lpToken));

     
    Masterchef public masterchef = Masterchef(Constants.MASTERCHEF);
    uint256 public poolId = 6;

     
     
     
    uint256 public maxharvesterRewards = 5 ether;
    address public dev = 0xAbcCB8f0a3c206Bb0468C52CCc20f3b81077417B;


    constructor() public {
        degenLpToken = new DSToken("dUNI-V2");
        degenLpToken.setName("Degen UNI-V2");
    }

     

    function harvestAndWithdrawAll() external {
        harvest();
        withdrawAll();
    }

    function harvest() public {
         
        masterchef.withdraw(poolId, 0);

        uint256 sushiBal = sushi.balanceOf(address(this));
        require(sushiBal > 0, "no-sushi");

         
         
        uint256 _before = getLpTokenBalance();
        _convertSushiToLp(sushiBal);
        uint256 _after = getLpTokenBalance();

        uint256 _amount = _after.sub(_before);

         
        uint256 _rewards = _amount.mul(maxharvesterRewards).div(100 ether);
        lpToken.transfer(dev, _rewards.div(2));
        lpToken.transfer(msg.sender, _rewards.div(2));

         
        _amount = lpToken.balanceOf(address(this));
        lpToken.approve(address(masterchef), _amount);
        masterchef.deposit(poolId, _amount);
    }

    function _convertSushiToLp(uint256 _amount) internal {
         
        address[] memory wethPath = new address[](2);
        wethPath[0] = address(sushi);
        wethPath[1] = address(weth);
        sushi.approve(address(univ2), _amount);
        univ2.swapExactTokensForTokens(
            _amount,
            0,
            wethPath,
            address(this),
            now + 60
        );

         
         
        uint256 wethHalf = weth.balanceOf(address(this)).div(2);
        address[] memory snxPath = new address[](2);
        snxPath[0] = address(weth);
        snxPath[1] = address(snx);
        weth.approve(address(univ2), wethHalf);
        univ2.swapExactTokensForTokens(
            wethHalf,
            0,
            snxPath,
            address(this),
            now + 60
        );

         
        uint256 snxBal = snx.balanceOf(address(this));
        uint256 wethBal = weth.balanceOf(address(this));
        snx.approve(address(univ2), snxBal);
        weth.approve(address(univ2), wethBal);
        univ2.addLiquidity(
            address(snx),
            address(weth),
            snxBal,
            wethBal,
            0,
            0,
            address(this),
            now + 60
        );
    }

     

    function withdrawAll() public {
        withdraw(degenLpToken.balanceOf(msg.sender));
    }

    function withdraw(uint256 _shares) public {
         
        uint256 _amount = getLpTokenBalance()
            .div(degenLpToken.totalSupply())
            .mul(_shares);

        degenLpToken.burn(msg.sender, _shares);

         
        masterchef.withdraw(poolId, _amount);

         
        lpToken.transfer(msg.sender, _amount);
    }

    function depositAll() public {
        deposit(lpToken.balanceOf(msg.sender));
    }

    function deposit(uint256 _amount) public {
        uint256 _lpBal = getLpTokenBalance();
        uint256 _before = lpToken.balanceOf(address(this));
        lpToken.transferFrom(msg.sender, address(this), _amount);
        uint256 _after = lpToken.balanceOf(address(this));

        uint256 _obtained = _after.sub(_before);
        uint256 _shares = 0;
        uint256 _degenSupply = degenLpToken.totalSupply();

        if (_degenSupply == 0) {
            _shares = _obtained;
        } else {
            _shares = _obtained.mul(_degenSupply).div(_lpBal);
        }

         
        lpToken.approve(address(masterchef), _amount);
        masterchef.deposit(poolId, _obtained);

        degenLpToken.mint(msg.sender, _shares);
    }

    function getRatioPerShare() public view returns (uint256) {
        if (degenLpToken.totalSupply() == 0) {
            return 0;
        }
        
        return getLpTokenBalance().mul(1e18).div(degenLpToken.totalSupply());
    }

    function getLpTokenBalance() public view returns (uint256) {
        (uint256 stakedBal, ) = masterchef.userInfo(poolId, address(this));

        uint256 holdingBal = lpToken.balanceOf(address(this));

        return stakedBal.add(holdingBal);
    }
}