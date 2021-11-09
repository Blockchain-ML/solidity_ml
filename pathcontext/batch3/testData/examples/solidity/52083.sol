pragma solidity ^0.4.24;

 
contract Owned {
    address public owner;
    address public newOwner;
    mapping (address => bool) public admins;

    event OwnershipTransferred(
        address indexed _from, 
        address indexed _to
    );

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmins {
        require(admins[msg.sender]);
        _;
    }

    function transferOwnership(address _newOwner) 
        public 
        onlyOwner 
    {
        newOwner = _newOwner;
    }

    function acceptOwnership() 
        public 
    {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    function addAdmin(address _admin) 
        onlyOwner 
        public 
    {
        admins[_admin] = true;
    }

    function removeAdmin(address _admin) 
        onlyOwner 
        public 
    {
        delete admins[_admin];
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
}

 
library AddressUtils {

     
    function isContract(address addr) 
        internal 
        view 
        returns (bool) 
    {
        uint256 size;
         
         
         
         
         
         
         
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

contract WareHouse_Admins is Owned {
    using AddressUtils for address;
    using SafeMath for uint256;

    mapping(address => mapping(uint256 => uint256)) depositOf;  
    mapping(address => mapping(uint256 => mapping(address => uint256))) usedOf;  
    mapping(string => bool) isLock;  
     
    address[] public addressOf;
    address public BPaddress;

    uint256 tokenId;

    mapping(string => uint256) indexOfBPhash;
    mapping(address => mapping(uint256 => string)) BPhashOfBPTokenId;  

    event AddABaddress(uint256 indexed _indexed, address _ABaddress);
    event DelABaddress(uint256 indexed _indexed, address _BeforeAddress, address _nowAddress, uint256 _length);
    event ChangeBPaddress(address _before, address _now);
    event Compose(uint256 _BPindex, string _BPhash);
    event DeCompose(uint256 _BPindex, string _BPhash);
    
    event GetAB(address _ABaddress, address _toAddress, uint256 _amount);

    constructor() 
        public 
    {
        owner = msg.sender;
        admins[msg.sender] = true;
        tokenId = 1;
    }

    function addABaddress(address _ABaddress)
        public
        onlyAdmins
    {
        require(_ABaddress.isContract());

        addressOf.push(_ABaddress);

        emit AddABaddress(addressOf.length - 1, _ABaddress);
    }

     
    function delABaddress(uint256 _index, address _ABaddress)
        public
        onlyAdmins
    {
        require(addressOf[_index] == _ABaddress);
        addressOf[_index] = addressOf[addressOf.length - 1];
        delete addressOf[addressOf.length - 1];
        addressOf.length--;

        emit DelABaddress(_index, _ABaddress, addressOf[_index], addressOf.length);
    }

    function changeBPaddress(address _new)
        public
        onlyAdmins
    {
        require(_new.isContract());
        address _before = BPaddress;
        BPaddress = _new;
        
        emit ChangeBPaddress(_before, BPaddress);
    }

    function compose(string BPhash, address maker, uint256[] cost)
        public
        onlyAdmins
    {
        uint256[] memory arr = cost;

         
        uint256 _tokenId = tokenId;

        require(canCompose(BPhash, cost, maker, _tokenId));

        BP bp = BP(BPaddress);

            
         
        for (uint256 i = 0; i < arr.length; i++) {
            ERC20 AB = ERC20(addressOf[i]);
            AB.transferFrom(maker,this, arr[i]);
            depositOf[maker][i] = depositOf[maker][i].add(arr[i]);
            usedOf[maker][_tokenId][addressOf[i]] = usedOf[maker][_tokenId][addressOf[i]].add(arr[i]);
        
        }


        bp.mint(owner, _tokenId, maker);
        indexOfBPhash[BPhash] = _tokenId;
        BPhashOfBPTokenId[maker][_tokenId] = BPhash;
        
        tokenId = tokenId.add(1);

        emit Compose(_tokenId, BPhash);

    }

    function canCompose(string BPhash, uint256[] cost, address maker, uint256 _tokenId)
        public
        view
        returns(bool)
    {

        BP bp = BP(BPaddress);

        if(checkBalance(cost, maker) && !bp.exists(_tokenId) && indexOfBPhash[BPhash] == 0) {
            return true;
        } else {
            return false;
        }        
    }

    function deCompose(string BPhash)
        public
    {
        BP bp = BP(BPaddress);
        uint256 _tokenId = indexOfBPhash[BPhash];

        require(canDeCompose(BPhash));

        for (uint256 i = 0; i < addressOf.length; i++) {
            ERC20 AB = ERC20(addressOf[i]);
            AB.transfer(msg.sender,usedOf[msg.sender][_tokenId][addressOf[i]]);
            depositOf[msg.sender][i] = depositOf[msg.sender][i].sub(usedOf[msg.sender][_tokenId][addressOf[i]]);
            usedOf[msg.sender][_tokenId][addressOf[i]] = 0;
        }

        address _owner = bp.ownerOf(_tokenId);
        bp.burn(_owner, _tokenId, msg.sender);
        delete indexOfBPhash[BPhash];
        delete BPhashOfBPTokenId[msg.sender][_tokenId];

        emit DeCompose(_tokenId, BPhash);     
    }

    function canDeCompose(string BPhash)
        public
        view
        returns(bool)
    {
        BP bp = BP(BPaddress);
        uint256 _tokenId = indexOfBPhash[BPhash];

        if(bp.exists(_tokenId) && msg.sender == bp.makerOf(_tokenId) && !isLock[BPhash]) {
            return true;
        } else {
            return false;
        }
    }

     
    function setTokenId(uint256 k)
        public
        onlyAdmins
    {
        tokenId = k;
    }    

    function setLock(string BPhash, bool lock)
        public
        onlyAdmins
    {
        isLock[BPhash] = lock;
    }

    function lockState(string BPhash)
        public
        view
        returns(bool)
    {
        return isLock[BPhash];    
    }


    function checkBalance(uint256[] _array, address maker)
        public
        view
        returns(bool)
    {
        for(uint256 i = 0; i < _array.length; i++) {
            ERC20 AB = ERC20(addressOf[i]);
            if (AB.balanceOf(maker) < _array[i]) {
                return false;
            } 
        }

        return true;
    }

    function getABsort() 
        public
        view
        returns(uint256)
    {
        return addressOf.length;
    }

    function getABaddress(uint256 _index)
        public
        view
        returns(address)
    {
        require(_index < addressOf.length);
        return addressOf[_index];
    }

    function getTokenIdFrombBPhash(string BPhash)
        public
        view
        returns(uint256)
    {
        return indexOfBPhash[BPhash];
    }

    function getBPhashFromBPTokenId(address _maker, uint256 _tokenId)
        public
        view
        returns(string)
    {
        return BPhashOfBPTokenId[_maker][_tokenId];
    }
    
    function getTokenId()
        public
        view
        returns(uint256)
    {
        return tokenId;
    }

    function getERC20(address _ABaddress, address _toAddress, uint256 _amount)
        public
        onlyAdmins
    {
        ERC20 AB = ERC20(_ABaddress);
        AB.transfer(_toAddress, _amount);

        emit GetAB(_ABaddress, _toAddress, _amount);
    }

}

interface  ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

interface BP {
    function mint(address _to, uint256 _tokenId, address _maker) external;
    function burn(address _owner, uint256 _tokenId, address _maker) external;
    function totalSupply() external view returns (uint256);
    function exists(uint256 _tokenId) external view returns (bool _exists);    
    function makerOf(uint256 _tokenId) external view returns (address);
    function ownerOf(uint256 _tokenId) external view returns (address);
}