 

pragma solidity 0.5.17;

interface IERC20 {  
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IWETH {  
    function deposit() payable external;
    
    function transfer(address dst, uint wad) external returns (bool);
}

library Address {  
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

library SafeERC20 {  
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

   function _callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {  
            require(abi.decode(returndata, (bool)), "SafeERC20: erc20 operation did not succeed");
        }
    }
}

library SafeMath {  
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }
    
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
}

contract Context {  
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

contract LexGuildLocker is Context {  
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

     
    address public lexDAO;
    address public wETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;  
    uint256 public lockerCount;
    uint256 public MAX_DURATION;  
    uint256 public resolutionRate;
    mapping(uint256 => Locker) public lockers; 

    struct Locker {  
        address client; 
        address[] provider;
        address resolver;
        address token;
        uint8 confirmed;
        uint8 locked;
        uint256[] batch;
        uint256 cap;
        uint256 released;
        uint256 termination;
        bytes32 details; 
    }
    
    event RegisterLocker(address indexed client, address[] indexed provider, address indexed resolver, address token, uint256[] batch, uint256 cap, uint256 index, uint256 termination, bytes32 details);	
    event ConfirmLocker(uint256 indexed index, uint256 indexed sum);  
    event Release(uint256 indexed index, uint256[] indexed milestone); 
    event Withdraw(uint256 indexed index, uint256 indexed remainder);
    event Lock(address indexed sender, uint256 indexed index, bytes32 indexed details);
    event Resolve(address indexed resolver, uint256 indexed clientAward, uint256[] indexed providerAward, uint256 index, uint256 resolutionFee, bytes32 details); 
    event UpdateLockerSettings(address indexed lexDAO, uint256 indexed MAX_DURATION, uint256 indexed resolutionRate, bytes32 details);
    
    constructor (address _lexDAO, uint256 _MAX_DURATION, uint256 _resolutionRate) public {
        lexDAO = _lexDAO;
        MAX_DURATION = _MAX_DURATION;
        resolutionRate = _resolutionRate;
    }

     
    function registerLocker(  
        address client,
        address[] calldata provider,
        address resolver,
        address token,
        uint256[] calldata batch, 
        uint256 cap,
        uint256 milestones,
        uint256 termination,  
        bytes32 details) external returns (uint256) {
        uint256 sum;
        for (uint256 i = 0; i < provider.length; i++) {
            sum = sum.add(batch[i]);
        }
        
        require(sum.mul(milestones) == cap, "deposit != milestones");
        require(termination <= now.add(MAX_DURATION), "duration maxed");
        
        lockerCount = lockerCount + 1;
        uint256 index = lockerCount;
        
        lockers[index] = Locker( 
            client, 
            provider,
            resolver,
            token,
            0,
            0,
            batch,
            cap,
            0,
            termination,
            details);

        emit RegisterLocker(client, provider, resolver, token, batch, cap, index, termination, details); 
        return index;
    }
    
    function confirmLocker(uint256 index) payable external {  
        Locker storage locker = lockers[index];
        
        require(locker.confirmed == 0, "confirmed");
        require(_msgSender() == locker.client, "!client");
        
        uint256 sum = locker.cap;
        
        if (locker.token == wETH && msg.value > 0) {
            require(msg.value == sum, "!ETH");
            IWETH(wETH).deposit();
            (bool success, ) = wETH.call.value(msg.value)("");
            require(success, "!transfer");
            IWETH(wETH).transfer(address(this), msg.value);
        } else {
            IERC20(locker.token).safeTransferFrom(msg.sender, address(this), sum);
        }
        
        locker.confirmed = 1;
        
        emit ConfirmLocker(index, sum); 
    }

    function release(uint256 index) external {  
    	Locker storage locker = lockers[index];
	    
	    require(locker.locked == 0, "locked");
	    require(locker.confirmed == 1, "!confirmed");
	    require(locker.cap > locker.released, "released");
    	require(_msgSender() == locker.client, "!client"); 
        
        uint256[] memory milestone = locker.batch;
        
        for (uint256 i = 0; i < locker.provider.length; i++) {
            IERC20(locker.token).safeTransfer(locker.provider[i], milestone[i]);
            locker.released = locker.released.add(milestone[i]);
        }

	    emit Release(index, milestone); 
    }
    
    function withdraw(uint256 index) external {  
    	Locker storage locker = lockers[index];
        
        require(locker.locked == 0, "locked");
        require(locker.confirmed == 1, "!confirmed");
        require(locker.cap > locker.released, "released");
        require(now > locker.termination, "!terminated");
        
        uint256 remainder = locker.cap.sub(locker.released); 
        
        IERC20(locker.token).safeTransfer(locker.client, remainder);
        
        locker.released = locker.released.add(remainder); 
        
	    emit Withdraw(index, remainder); 
    }
    
     
    function lock(uint256 index, bytes32 details) external {  
        Locker storage locker = lockers[index]; 
        
        require(locker.confirmed == 1, "!confirmed");
        require(locker.cap > locker.released, "released");
        require(now < locker.termination, "terminated"); 
        require(_msgSender() == locker.client || _msgSender() == locker.provider[0], "!party"); 

	    locker.locked = 1; 
	    
	    emit Lock(_msgSender(), index, details);
    }
    
    function resolve(uint256 index, uint256 clientAward, uint256[] calldata providerAward, bytes32 details) external {  
        Locker storage locker = lockers[index];
        
        uint256 remainder = locker.cap.sub(locker.released); 
	    uint256 resolutionFee = remainder.div(resolutionRate);  
	    
	    require(locker.locked == 1, "!locked"); 
	    require(locker.cap > locker.released, "released");
	    require(_msgSender() == locker.resolver, "!resolver");
	    require(_msgSender() != locker.client, "resolver == client");
	    
	    for (uint256 i = 0; i < locker.provider.length; i++) {
            require(msg.sender != locker.provider[i], "resolver == provider");
            require(clientAward.add(providerAward[i]) == remainder.sub(resolutionFee), "resolution != remainder");
            IERC20(locker.token).safeTransfer(locker.provider[i], providerAward[i]);
        }
  
        IERC20(locker.token).safeTransfer(locker.client, clientAward);
        IERC20(locker.token).safeTransfer(locker.resolver, resolutionFee);
	    
	    locker.released = locker.released.add(remainder); 
	    
	    emit Resolve(_msgSender(), clientAward, providerAward, index, resolutionFee, details);
    }
    
     
    function updateLockerSettings(address _lexDAO, uint256 _MAX_DURATION, uint256 _resolutionRate, bytes32 details) external { 
        require(_msgSender() == lexDAO, "!lexDAO");
        
        lexDAO = _lexDAO;
        MAX_DURATION = _MAX_DURATION;
        resolutionRate = _resolutionRate;
	    
	    emit UpdateLockerSettings(lexDAO, MAX_DURATION, resolutionRate, details);
    }
}