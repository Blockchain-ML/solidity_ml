 

pragma solidity >=0.5.0 <0.6.0;

 
 
 
contract DkargoPrefix {
    
    string internal _dkargoPrefix;  
    
     
     
     
    function getDkargoPrefix() public view returns(string memory) {
        return _dkargoPrefix;
    }

     
     
     
    function _setDkargoPrefix(string memory prefix) internal {
        _dkargoPrefix = prefix;
    }
}

 

pragma solidity >=0.5.0 <0.6.0;

 
 
 
contract Ownership {
    address private _owner;

    event OwnershipTransferred(address indexed old, address indexed expected);

     
     
    modifier onlyOwner() {
        require(isOwner() == true, "Ownership: only the owner can call");
        _;
    }

     
     
    constructor() internal {
        emit OwnershipTransferred(_owner, msg.sender);
        _owner = msg.sender;
    }

     
     
     
    function transferOwnership(address expected) public onlyOwner {
        require(expected != address(0), "Ownership: new owner is the zero address");
        emit OwnershipTransferred(_owner, expected);
        _owner = expected;
    }

     
     
     
    function owner() public view returns (address) {
        return _owner;
    }

     
     
     
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
}

 

pragma solidity >=0.5.0 <0.6.0;

 
library SafeMath64 {
     
    function add(uint64 a, uint64 b) internal pure returns (uint64) {
        uint64 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint64 a, uint64 b) internal pure returns (uint64) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint64 a, uint64 b, string memory errorMessage) internal pure returns (uint64) {
        require(b <= a, errorMessage);
        uint64 c = a - b;

        return c;
    }

     
    function mul(uint64 a, uint64 b) internal pure returns (uint64) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint64 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint64 a, uint64 b) internal pure returns (uint64) {
         
        require(b > 0, "SafeMath: division by zero");
        uint64 c = a / b;
         

        return c;
    }

     
    function mod(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

 

pragma solidity >=0.5.0 <0.6.0;


 
 
 
 
contract Uint64Chain {
    using SafeMath64 for uint64;

     
    struct NodeInfo {
        uint64 prev;  
        uint64 next;  
    }
     
    struct NodeList {
        uint64 count;  
        uint64 head;  
        uint64 tail;  
        mapping(uint64 => NodeInfo) map;  
    }

     
    NodeList private _slist;  

     
    event Uint64ChainLinked(uint64 indexed node);  
    event Uint64ChainUnlinked(uint64 indexed node);  

     
     
     
    function count() public view returns(uint64) {
        return _slist.count;
    }

     
     
     
    function head() public view returns(uint64) {
        return _slist.head;
    }

     
     
     
    function tail() public view returns(uint64) {
        return _slist.tail;
    }

     
     
     
     
    function nextOf(uint64 node) public view returns(uint64) {
        return _slist.map[node].next;
    }

     
     
     
     
    function prevOf(uint64 node) public view returns(uint64) {
        return _slist.map[node].prev;
    }

     
     
     
     
    function isLinked(uint64 node) public view returns (bool) {
        if(_slist.count == 1 && _slist.head == node && _slist.tail == node) {
            return true;
        } else {
            return (_slist.map[node].prev == uint64(0) && _slist.map[node].next == uint64(0))? (false) :(true);
        }
    }

     
     
     
    function _linkChain(uint64 node) internal {
        require(!isLinked(node), "Uint64Chain: the node is aleady linked");
        if(_slist.count == 0) {
            _slist.head = _slist.tail = node;
        } else {
            _slist.map[node].prev = _slist.tail;
            _slist.map[_slist.tail].next = node;
            _slist.tail = node;
        }
        _slist.count = _slist.count.add(1);
        emit Uint64ChainLinked(node);
    }

     
     
     
    function _unlinkChain(uint64 node) internal {
        require(isLinked(node), "Uint64Chain: the node is aleady unlinked");
        uint64 tempPrev = _slist.map[node].prev;
        uint64 tempNext = _slist.map[node].next;
        if (_slist.head == node) {
            _slist.head = tempNext;
        }
        if (_slist.tail == node) {
            _slist.tail = tempPrev;
        }
        if (tempPrev != uint64(0)) {
            _slist.map[tempPrev].next = tempNext;
            _slist.map[node].prev = uint64(0);
        }
        if (tempNext != uint64(0)) {
            _slist.map[tempNext].prev = tempPrev;
            _slist.map[node].next = uint64(0);
        }
        _slist.count = _slist.count.sub(1);
        emit Uint64ChainUnlinked(node);
    }
}

 

pragma solidity >=0.5.0 <0.6.0;

 
 
 
 
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 

pragma solidity >=0.5.0 <0.6.0;


 
 
 
contract ERC165 is IERC165 {
    
    mapping(bytes4 => bool) private _infcs;  

     
     
     
    constructor() internal {
        _registerInterface(0x01ffc9a7);  
    }

     
     
     
     
    function supportsInterface(bytes4 infcid) external view returns (bool) {
        return _infcs[infcid];
    }

     
     
     
    function _registerInterface(bytes4 infcid) internal {
        require(infcid != 0xffffffff, "ERC165: invalid interface id");
        _infcs[infcid] = true;
    }
}

 

pragma solidity >=0.5.0 <0.6.0;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        uint256 size;
         
        assembly { size := extcodesize(account) }
        return size > 0;
    }

     
     
     

     
     
     
     
     
    function _call(address addr, bytes memory rawdata) internal returns(bytes memory) {
        (bool success, bytes memory data) = address(addr).call(rawdata);
        require(success == true, "Address: function(call) call failed");
        return data;
    }

     
     
     
     
     
    function _dcall(address addr, bytes memory rawdata) internal returns(bytes memory) {
        (bool success, bytes memory data) = address(addr).delegatecall(rawdata);
        require(success == true, "Address: function(delegatecall) call failed");
        return data;
    }

     
     
     
     
     
     
    function _vcall(address addr, bytes memory rawdata) internal view returns(bytes memory) {
        (bool success, bytes memory data) = address(addr).staticcall(rawdata);
        require(success == true, "Address: function(staticcall) call failed");
        return data;
    }
}

 

pragma solidity >=0.5.0 <0.6.0;

 
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
         
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

 

pragma solidity >=0.5.0 <0.6.0;







 
 
 
contract DkargoFund is Ownership, Uint64Chain, ERC165, DkargoPrefix {
    using Address for address;
    using SafeMath for uint256;

    mapping(uint64 => uint256) private _plans;  
    address private _beneficier;  
    address private _token;  
    uint256 private _totals;  
    
    event BeneficierUpdated(address indexed beneficier);  
    event PlanSet(uint64 time, uint256 amount);  
    event Withdraw(uint256 amount);  

     
     
     
     
    constructor(address token, address beneficier) public {
        require(token != address(0), "DkargoFund: token is null");
        require(beneficier != address(0), "DkargoFund: beneficier is null");
        _setDkargoPrefix("fund");  
        _registerInterface(0x946edbed);  
        _token = token;
        _beneficier = beneficier;
    }

     
     
     
     
    function setBeneficier(address beneficier) onlyOwner public {
        require(beneficier != address(0), "DkargoFund: beneficier is null");
        require(beneficier != _beneficier, "DkargoFund: should be not equal");
        _beneficier = beneficier;
        emit BeneficierUpdated(beneficier);
    }

     
     
     
     
     
     
     
     
    function setPlan(uint64 time, uint256 amount) onlyOwner public {
        require(time > block.timestamp, "DkargoFund: invalid time");
        _totals = _totals.add(amount);  
        _totals = _totals.sub(_plans[time]);  
        require(_totals <= fundAmount(), "DkargoFund: over the limit");  
        _plans[time] = amount;  
        emit PlanSet(time, amount);  
        if(amount == 0) {  
            _unlinkChain(time);  
        } else if(isLinked(time) == false) {  
            _linkChain(time);
        }
    }

     
     
     
     
     
    function withdraw(uint64 index) onlyOwner public {
        require(index <= block.timestamp, "DkargoFund: an unexpired plan");
        require(_plans[index] > 0, "DkargoFund: plan is not set");
        bytes memory cmd = abi.encodeWithSignature("transfer(address,uint256)", _beneficier, _plans[index]);
        bytes memory data = address(_token)._call(cmd);
        bool result = abi.decode(data, (bool));
        require(result == true, "DkargoFund: failed to proceed raw-data");
        _totals = _totals.sub(_plans[index]);  
        emit Withdraw(_plans[index]);
        _plans[index] = 0;
        _unlinkChain(index);
    }

     
     
     
    function fundAmount() public view returns(uint256) {
        bytes memory data = address(_token)._vcall(abi.encodeWithSignature("balanceOf(address)", address(this)));
        return abi.decode(data, (uint256));
    }

     
     
     
    function totalPlannedAmount() public view returns(uint256) {
        return _totals;
    }
    
     
     
     
     
    function plannedAmountOf(uint64 index) public view returns(uint256) {
        return _plans[index];
    }

     
     
     
    function beneficier() public view returns(address) {
        return _beneficier;
    }

     
     
     
    function token() public view returns(address) {
        return _token;
    }
}