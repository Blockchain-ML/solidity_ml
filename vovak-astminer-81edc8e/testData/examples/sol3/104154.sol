pragma solidity 0.4.24;

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);  
    uint256 c = a / b;
     

    return c;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

   
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}


 
 

 
 


 
contract Initializable {

   
  bool private initialized;

   
  bool private initializing;

   
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

   
  function isConstructor() private view returns (bool) {
     
     
     
     
     
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

   
  uint256[50] private ______gap;
}


 
contract Ownable is Initializable {
  address private _owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  function initialize(address sender) public initializer {
    _owner = sender;
  }

   
  function owner() public view returns(address) {
    return _owner;
  }

   
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

   
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
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

  uint256[50] private ______gap;
}

 
 

 
 


 
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


 
contract ERC20Detailed is Initializable, IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  function initialize(string name, string symbol, uint8 decimals) public initializer {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

   
  function name() public view returns(string) {
    return _name;
  }

   
  function symbol() public view returns(string) {
    return _symbol;
  }

   
  function decimals() public view returns(uint8) {
    return _decimals;
  }

  uint256[50] private ______gap;
}


 
 

 


 
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

     
    function mul(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a * b;

         
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

     
    function div(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
         
        require(b != -1 || a != MIN_INT256);

         
        return a / b;
    }

     
    function sub(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

     
    function add(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

     
    function abs(int256 a)
        internal
        pure
        returns (int256)
    {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}


 
contract UFragments is ERC20Detailed, Ownable {
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event LogMonetaryPolicyUpdated(address monetaryPolicy);

     
    address public monetaryPolicy;

    modifier onlyMonetaryPolicy() {
        require(msg.sender == monetaryPolicy);
        _;
    }

    bool private rebasePausedDeprecated;
    bool private tokenPausedDeprecated;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    uint256 private constant DECIMALS = 9;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 50 * 10**6 * 10**DECIMALS;

     
     
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

     
    uint256 private constant MAX_SUPPLY = ~uint128(0);   

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;

     
     
    mapping (address => mapping (address => uint256)) private _allowedFragments;

     
    function setMonetaryPolicy(address monetaryPolicy_)
        external
        onlyOwner
    {
        monetaryPolicy = monetaryPolicy_;
        emit LogMonetaryPolicyUpdated(monetaryPolicy_);
    }

     
    function rebase(uint256 epoch, int256 supplyDelta)
        external
        onlyMonetaryPolicy
        returns (uint256)
    {
        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(supplyDelta.abs()));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

         
         
         
         
         
         
         
         
         
         

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function initialize(address owner_)
        public
        initializer
    {
        ERC20Detailed.initialize("AmpleForthGold", "AAU", uint8(DECIMALS));
        Ownable.initialize(owner_);

        rebasePausedDeprecated = false;
        tokenPausedDeprecated = false;

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[owner_] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        emit Transfer(address(0x0), owner_, _totalSupply);
    }

     
    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _totalSupply;
    }

     
    function balanceOf(address who)
        public
        view
        returns (uint256)
    {
        return _gonBalances[who].div(_gonsPerFragment);
    }

     
    function transfer(address to, uint256 value)
        public
        validRecipient(to)
        returns (bool)
    {
        uint256 gonValue = value.mul(_gonsPerFragment);
        _gonBalances[msg.sender] = _gonBalances[msg.sender].sub(gonValue);
        _gonBalances[to] = _gonBalances[to].add(gonValue);
        emit Transfer(msg.sender, to, value);
        return true;
    }

     
    function allowance(address owner_, address spender)
        public
        view
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

     
    function transferFrom(address from, address to, uint256 value)
        public
        validRecipient(to)
        returns (bool)
    {
        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value);

        uint256 gonValue = value.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonValue);
        _gonBalances[to] = _gonBalances[to].add(gonValue);
        emit Transfer(from, to, value);

        return true;
    }

     
    function approve(address spender, uint256 value)
        public
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] =
            _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }
}

 
 

 

 

library RB_SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }

    function div(uint x, uint y) internal pure returns (uint) {
        require(y != 0);
        return x / y;    
    }
}

library RB_UnsignedSafeMath {
    function add(int x, int y) internal pure returns (int z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(int x, int y) internal pure returns (int z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(int x, int y) internal pure returns (int z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }

    function div(int x, int y) internal pure returns (int) {
        require(y != 0);
        return x / y;    
    }
}


 

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes   data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


 
contract RebaseDelta {

    using RB_SafeMath for uint256;
    using RB_UnsignedSafeMath for int256;
    
    uint256 private constant PRICE_PRECISION = 10**9;

    function getPrice(IUniswapV2Pair pair_, bool flip_) 
    public
    view
    returns (uint256) 
    {
        require(address(pair_) != address(0));

        (uint256 reserves0, uint256 reserves1, ) = pair_.getReserves();

        if (flip_) {
            (reserves0, reserves1) = (reserves1, reserves0);            
        }

         
         

         

        uint256 price = (reserves1.mul(PRICE_PRECISION)).div(reserves0);

        return price;
    }

     
     
     
    function calculate(IUniswapV2Pair X_,
                      bool flipX_,
                      uint256 decimalsX_,
                      uint256 SupplyX_, 
                      IUniswapV2Pair Y_,
                      bool flipY_,
                      uint256 decimalsY_)
    public
    view
    returns (int256)
    {
        uint256 px = getPrice(X_, flipX_);
        require(px != uint256(0));
        uint256 py = getPrice(Y_, flipY_);
        require(py != uint256(0));

        uint256 targetSupply = (SupplyX_.mul(py)).div(px);

         
        if (decimalsX_ == decimalsY_) {
             
        }
        else if (decimalsX_ > decimalsY_) {
            uint256 ddg = (10**decimalsX_).div(10**decimalsY_);
            require (ddg != uint256(0));
            targetSupply = targetSupply.mul(ddg); 
        }
        else {
            uint256 ddl = (10**decimalsY_).div(10**decimalsX_);
            require (ddl != uint256(0));
            targetSupply = targetSupply.div(ddl);        
        }

        int256 delta = int256(SupplyX_).sub(int256(targetSupply));

        return delta;
    }
}

 
 
 
 
 

 
contract Orchestrator is Ownable {

    using SafeMath for uint16;
    using SafeMath for uint256;
    using SafeMathInt for int256;
    
     
    UFragments public afgToken = UFragments(0x8E54954B3Bbc07DbE3349AEBb6EAFf8D91Db5734);
    
     
    RebaseDelta public oracle = RebaseDelta(0xF09402111AF6409B410A8Dd07B82F1cd1674C55F);
    IUniswapV2Pair public tokenPairX = IUniswapV2Pair(0x2d0C51C1282c31d71F035E15770f3214e20F6150);
    IUniswapV2Pair public tokenPairY = IUniswapV2Pair(0x9C4Fe5FFD9A9fC5678cFBd93Aa2D4FD684b67C4C);
    bool public flipX = false;
    bool public flipY = false;
    uint8 public decimalsX = 9;
    uint8 public decimalsY = 9;
    
     
     
     
     
    uint64 public lastRebase = uint64(0);

     
     
     
     
    uint16 public epoch = 3;

     
     
     
     
     
    struct Transaction {
        bool enabled;
        address destination;
        bytes data;
    }
    event TransactionFailed(address indexed destination, uint index, bytes data);
    Transaction[] public transactions;
    
     
    constructor() 
        public {
        Ownable.initialize(msg.sender);
    }

      
    function ownerForcedRebase(int256 supplyDelta, bool disable_)
        external
        onlyOwner
    {
         
        if (disable_) {
            lastRebase = uint64(0);
        } else {
            lastRebase = uint64(block.timestamp);
        }
         
        afgToken.rebase(epoch.add(1), supplyDelta);
        popTransactionList();
    }

     
    function rebase()
        external
        returns (uint256)
    {
         
         
         
         
        if (Ownable.isOwner())
        {
            return internal_rebase();
        }

         
        require (lastRebase != uint64(0));        

         
        require (lastRebase + 1 days < uint64(block.timestamp));

         
         
        if (lastRebase + 2 days < uint64(block.timestamp))
        {
            return internal_rebase();
        }

         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
        uint256 odds = uint256(blockhash(block.number - 1)) ^ uint256(block.coinbase);
        if ((odds % uint256(5)) == uint256(1))
        {
            return internal_rebase(); 
        }      

         
        return uint256(0);
    }

     
    function internal_rebase() 
        private 
        returns(uint256) {
        lastRebase = uint64(block.timestamp);
        uint256 z = afgToken.rebase(epoch.add(1), calculateRebaseDelta(true));
        popTransactionList();
        return z;
    }

     
    function configureOracle(IUniswapV2Pair tokenPairX_,
                      bool flipX_,
                      uint8 decimalsX_,
                      IUniswapV2Pair tokenPairY_,
                      bool flipY_,
                      uint8 decimalsY_,
                      RebaseDelta oracle_)
        external
        onlyOwner
        {
            tokenPairX = tokenPairX_;
            flipX = flipX_;
            decimalsX = decimalsX_;
            tokenPairY = tokenPairY_;
            flipY = flipY_;
            decimalsY = decimalsY_;
            oracle = oracle_;
    }

     
    function calculateRebaseDelta(bool limited_) 
        public
        view 
        returns (int256) 
        { 
            require (afgToken != UFragments(0));
            require (oracle != RebaseDelta(0));
            require (tokenPairX != IUniswapV2Pair(0));
            require (tokenPairY != IUniswapV2Pair(0));
            require (decimalsX != uint8(0));
            require (decimalsY != uint8(0));
            
            uint256 supply = afgToken.totalSupply();
            int256 delta = - oracle.calculate(
                tokenPairX,
                flipX,
                decimalsX,
                supply, 
                tokenPairY,
                flipY,
                decimalsY);

            if (!limited_) {
                 
                return delta;
            }   

            if (delta == int256(0))
            {
                 
                return int256(0);
            }

             
            int256 supply5p = int256(supply.div(uint256(20)));  
   
            if (delta < int256(0)) {
                if (-delta < supply5p) {
                    return int256(0);  
                }
                if (-delta < supply5p.mul(int256(2))) {
                    return (-supply5p).div(int256(5));  
                }
            } else {
                if (delta < supply5p) {
                    return int256(0);  
                }
                if (delta < supply5p.mul(int256(2))) {
                    return supply5p.div(int256(5));  
                }
            }

            return (delta.div(2));  
    }

     
     
    function windbacktime() 
        public
        onlyOwner {         
        require (lastRebase > 1 days);
        lastRebase-= 1 days;
    }

     

     
    function popTransactionList()
        private
    {
         
         
         
        if (tokenPairX != IUniswapV2Pair(0)) {  
            tokenPairX.sync();
        }

         
         
        for (uint i = 0; i < transactions.length; i++) {
            Transaction storage t = transactions[i];
            if (t.enabled) {
                bool result =
                    externalCall(t.destination, t.data);
                if (!result) {
                    emit TransactionFailed(t.destination, i, t.data);
                    revert("Transaction Failed");
                }
            }
        }
    } 

     
    function addTransaction(address destination, bytes data)
        external
        onlyOwner
    {
        transactions.push(Transaction({
            enabled: true,
            destination: destination,
            data: data
        }));
    }

     
    function removeTransaction(uint index)
        external
        onlyOwner
    {
        require(index < transactions.length, "index out of bounds");

        if (index < transactions.length - 1) {
            transactions[index] = transactions[transactions.length - 1];
        }

        transactions.length--;
    }

     
    function setTransactionEnabled(uint index, bool enabled)
        external
        onlyOwner
    {
        require(index < transactions.length, "index must be in range of stored tx list");
        transactions[index].enabled = enabled;
    }

     
    function transactionsSize()
        external
        view
        returns (uint256)
    {
        return transactions.length;
    }

     
    function externalCall(address destination, bytes data)
        internal
        returns (bool)
    {
        bool result;
        assembly {   
             
             
            let outputAddress := mload(0x40)

             
            let dataAddress := add(data, 32)

            result := call(
                 
                 
                 
                 
                sub(gas, 34710),


                destination,
                0,  
                dataAddress,
                mload(data),   
                outputAddress,
                0   
            )
        }
        return result;
    }
}