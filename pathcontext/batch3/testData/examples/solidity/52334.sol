pragma solidity ^0.4.24;

 
 
 
 
 
contract DigitalCopyright {
    using SafeMath for *;
     
    address constant private IpOwner = 0x89428305344Fe5De0801EDF41C5632C1e0FA231C;
    address constant private IpBuyer = 0x4A1061Afb0aF7d9f6c2D545Ada068dA68052c060;
    ERC20Interface constant private IERC20 = ERC20Interface(0x30c01f5a16dc83711019da425f0fd8a990bb1782);
 
 
 
 
    string constant public name = "IP Digital Copyright";
    string constant public symbol = "IPDC";
 
 
 
 
    uint256 public buyCount_;
 
 
 
    mapping (uint256 => Elastos.DIDs) public nIDxDIDs_;  
 
 
 
    IPDCdatasets.distributeFee public fees_;  
 
 
 
 
    constructor ()
        public
    {
        buyCount_ = 0;
        fees_ = IPDCdatasets.distributeFee(2, 8);  
    }
 
 
 
 
     
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
 
 
 
 
      
    function buyCopyright
        (
        uint256 _rate,
        string _txid,
        string _key
        )
        public
        payable
        isHuman()
    {
        IpOwner.transfer(msg.value);
        uint256 _assets = (msg.value).mul(_rate.div(100));
        mortgage(_assets);
        updateDID(_txid, _key);
    }

     
    function mortgage (uint256 _assets)
        private
    {
        IERC20.transferFrom(IpOwner, address(this), _assets);
    }

     
    function updateDID (string _txid, string _key)
        private
    {
        buyCount_++;
        nIDxDIDs_[buyCount_].txid = _txid;
        nIDxDIDs_[buyCount_].key = _key;
    }

     
    function buyGoods ()
        public
    {
        distribute(msg.sender);
    }

     
    function distribute (address _user)
        private
    {
        uint256 _balance = IERC20.balanceOf(address(this));
        if (_balance > 0)
        {
            uint256 _ownValue = (_balance.mul(fees_.owner)).div(100);
            uint256 _retrValue = (_balance.mul(fees_.retr)).div(100);
            _balance = _balance.sub(_ownValue.add(_retrValue));
             
            IERC20.transferFrom(address(this), IpOwner, _ownValue);
            IERC20.transferFrom(address(this), IpBuyer, _balance);
            IERC20.transferFrom(address(this), _user, _retrValue);
        }
    }
}

 
 
 
 
 
interface ERC20Interface {
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

 
 
 
 
 
library Elastos {
    struct DIDs {
        string txid;
        string key;
    }
}

 
library IPDCdatasets {
    struct distributeFee {
        uint256 retr;  
        uint256 owner;  
    }
}

 
library SafeMath {
    
     
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);  
        uint256 c = a / b;
         
        return c;
    }
    
     
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

     
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
    
     
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    
     
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }
    
     
    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else 
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}