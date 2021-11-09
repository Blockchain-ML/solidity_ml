 

pragma solidity ^0.5.0;


contract Config {
     
    bytes4 constant POSTPROCESS_SIG = 0xc2722916;

     
    enum HandlerType {Token, Custom, Others}
}

 

pragma solidity ^0.5.0;


library LibCache {
    function setAddress(bytes32[] storage _cache, address _input) internal {
        _cache.push(bytes32(uint256(uint160(_input))));
    }

    function set(bytes32[] storage _cache, bytes32 _input) internal {
        _cache.push(_input);
    }

    function setHandlerType(bytes32[] storage _cache, uint256 _input) internal {
        require(_input < uint96(-1), "Invalid Handler Type");
        _cache.push(bytes12(uint96(_input)));
    }

    function setSender(bytes32[] storage _cache, address _input) internal {
        require(_cache.length == 0, "cache not empty");
        setAddress(_cache, _input);
    }

    function getAddress(bytes32[] storage _cache)
        internal
        returns (address ret)
    {
        ret = address(uint160(uint256(peek(_cache))));
        _cache.pop();
    }

    function getSig(bytes32[] storage _cache) internal returns (bytes4 ret) {
        ret = bytes4(peek(_cache));
        _cache.pop();
    }

    function get(bytes32[] storage _cache) internal returns (bytes32 ret) {
        ret = peek(_cache);
        _cache.pop();
    }

    function peek(bytes32[] storage _cache)
        internal
        view
        returns (bytes32 ret)
    {
        require(_cache.length > 0, "cache empty");
        ret = _cache[_cache.length - 1];
    }

    function getSender(bytes32[] storage _cache)
        internal
        returns (address ret)
    {
        require(_cache.length > 0, "cache empty");
        ret = address(uint160(uint256(_cache[0])));
    }
}

 

pragma solidity ^0.5.0;



 
contract Cache {
    using LibCache for bytes32[];

    bytes32[] cache;

    modifier isCacheEmpty() {
        require(cache.length == 0, "Cache not empty");
        _;
    }
}

 

pragma solidity ^0.5.0;


interface IRegistry {
    function isValid(address handler) external view returns (bool result);

    function getInfo(address handler) external view returns (bytes32 info);
}

 

pragma solidity ^0.5.5;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
pragma experimental ABIEncoderV2;







 
contract Proxy is Cache, Config {
    using Address for address;
    using SafeERC20 for IERC20;

     
    bytes32 private constant HANDLER_REGISTRY = 0x6874162fd62902201ea0f4bf541086067b3b88bd802fac9e150fd2d1db584e19;

    constructor(address registry) public {
        bytes32 slot = HANDLER_REGISTRY;
        assembly {
            sstore(slot, registry)
        }
    }

     
    function() external payable {
        require(Address.isContract(msg.sender), "Not allowed from EOA");

         
         
         
        if (msg.data.length != 0) {
            require(_isValid(msg.sender), "Invalid caller");

            address target = address(
                bytes20(IRegistry(_getRegistry()).getInfo(msg.sender))
            );
            _exec(target, msg.data);
        }
    }

     
    function batchExec(address[] memory tos, bytes[] memory datas)
        public
        payable
    {
        _preProcess();
        _execs(tos, datas);
        _postProcess();
    }

     
    function execs(address[] memory tos, bytes[] memory datas) public payable {
        require(msg.sender == address(this), "Does not allow external calls");
        _execs(tos, datas);
    }

     
    function _execs(address[] memory tos, bytes[] memory datas) internal {
        require(
            tos.length == datas.length,
            "Tos and datas length inconsistent"
        );
        for (uint256 i = 0; i < tos.length; i++) {
            _exec(tos[i], datas[i]);
             
            _setPostProcess(tos[i]);
        }
    }

     
    function _exec(address _to, bytes memory _data)
        internal
        returns (bytes memory result)
    {
        require(_isValid(_to), "Invalid handler");
        assembly {
            let succeeded := delegatecall(
                sub(gas, 5000),
                _to,
                add(_data, 0x20),
                mload(_data),
                0,
                0
            )
            let size := returndatasize

            result := mload(0x40)
            mstore(
                0x40,
                add(result, and(add(add(size, 0x20), 0x1f), not(0x1f)))
            )
            mstore(result, size)
            returndatacopy(add(result, 0x20), 0, size)

            switch iszero(succeeded)
                case 1 {
                    revert(add(result, 0x20), size)
                }
        }
    }

     
    function _setPostProcess(address _to) internal {
         
         
         
        require(cache.length > 0, "cache empty");
        if (cache.length == 1) return;
        else if (cache.peek() == bytes32(bytes12(uint96(HandlerType.Custom)))) {
            cache.pop();
             
            if (bytes4(cache.peek()) != 0x00000000) cache.setAddress(_to);
            cache.setHandlerType(uint256(HandlerType.Custom));
        }
    }

     
    function _preProcess() internal isCacheEmpty {
         
        cache.setSender(msg.sender);
    }

     
    function _postProcess() internal {
         
         
         
         
        while (cache.length > 1) {
            address addr = cache.getAddress();
            if (addr == address(0)) {
                addr = cache.getAddress();
                _exec(addr, abi.encodeWithSelector(POSTPROCESS_SIG));
            } else {
                uint256 amount = IERC20(addr).balanceOf(address(this));
                if (amount > 0) IERC20(addr).safeTransfer(msg.sender, amount);
            }
        }

         
        uint256 amount = address(this).balance;
        if (amount > 0) msg.sender.transfer(amount);

         
        cache.pop();
    }

     
    function _getRegistry() internal view returns (address registry) {
        bytes32 slot = HANDLER_REGISTRY;
        assembly {
            registry := sload(slot)
        }
    }

     
    function _isValid(address handler) internal view returns (bool result) {
        return IRegistry(_getRegistry()).isValid(handler);
    }
}