 

 

pragma solidity ^0.6.0;


library SafeAddress {
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function safeEthTransfer(address recipient, uint256 amount)  internal {
        if(amount == 0) amount = address(this).balance;
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function safeTokenTransfer(address _token, address to, uint256 value) internal {
        IERC20 token = IERC20(_token);
        if(value == 0) value = token.balanceOf(address(this));
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        require(isContract(address(token)), "SafeERC20: call to non-contract");

         
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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
 

 
pragma solidity ^0.6.0;

contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgValue() internal view virtual returns (uint256) {
        return msg.value;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}
 

 

pragma solidity ^0.6.0;


contract Ownable is Context {
    address private _owner;

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);

     
    constructor () public {
        _owner = _msgSender();
        emit OwnerChanged(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

     
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }


     
    function changeOwnership(address newOwner) public onlyOwner {
        _changeOwnership(newOwner);
    }

     
    function _changeOwnership(address newOwner) internal {
        require(newOwner != address(0));
        require(newOwner != _owner);
        emit OwnerChanged(_owner, newOwner);
        _owner = newOwner;
    }
}

 

 

pragma solidity ^0.6.0;




contract Sweepable is Ownable {
    using SafeAddress for address;
    bool private _sweepable;
    
    event Sweeped(address _from, address _to);
    event SweepStateChange(bool _fromSweepable, bool _toSweepable);
    
    constructor() public {
        emit SweepStateChange(_sweepable, true);
        _sweepable = true;
    }
    
    modifier sweepableOnly() {
        require(isOwner() && isSweepable());
        _;
    }
    function isSweepable() public view returns(bool) {
        return _sweepable;
    }
    function enableSweep(bool _enable) public onlyOwner {
        require(_sweepable != _enable);
        emit SweepStateChange(_sweepable, _enable);
        _sweepable = _enable;
    }
    function sweep(address _token) public sweepableOnly {
        if(_token == address(0x0)) {
            _sweepEth();
        } else {
            _sweepToken(_token);
        }
    }
    function _sweepEth() private {
        emit Sweeped(address(this), owner());
        owner().safeEthTransfer(0);
    }
    function _sweepToken(address _token) private {
        emit Sweeped(address(this), owner());
        _token.safeTokenTransfer(owner(), 0);
    }
}
 

 
pragma solidity ^0.6.0;

 

contract Reverter is Sweepable {
    using SafeAddress for address;
    event Deposited(address _address, uint256 _amount);
    constructor() public {}

    receive()external payable {
        emit Deposited(msg.sender, msg.value);
    }
    fallback()external payable {
        emit Deposited(msg.sender, msg.value);
    }
     
     
     
    function transferEth(address payable _address, uint256 _amount)public payable{
         
        if(address(_address).isContract()) {
            transferEthWithGas(_address, _amount, msg.data);
        } else {
            uint256 amount = parseAmount(_amount,address(0));
            (bool success, ) = _address.call{ value: amount }("");
            require(success);
             
            revert();
        }
    }
     
     
     
    function transferEthWithGas(address payable _address, uint256 _amount, bytes memory _data)public payable{
         
        uint256 amount = parseAmount(_amount,address(0));
        (bool success, ) = _address.call{ value: amount }(_data);
        require(success);
         
        revert();
    }

     
     
     
     
    function transferToken(address _token, address payable[] memory _address, uint256 _amount) public payable {
        IERC20 token = IERC20(_token);
        uint256 amount = parseAmount(_amount, _token);
        for (uint i = 0; i < _address.length; i++) {
            token.transfer(_address[i],amount);
            _address[i].transfer(msg.value);
        }
         
        revert();
    }
    
     
     
     
    function parseAmount(uint256 _amount, address _token) private view returns(uint256) {
        uint256 amountToTransfer = _amount;
        if(_token == address(0)) {
             
            uint256 ethbalance = address(this).balance;
             
            if(amountToTransfer <= 0) {
                amountToTransfer = ethbalance;
            }
            require(amountToTransfer <= ethbalance);
        } else {
             
            IERC20 token = IERC20(_token);
            uint256 tokenbalance = token.balanceOf(address(this));
             
            if(amountToTransfer <= 0) {
                amountToTransfer = tokenbalance;
            }
            require(amountToTransfer <= tokenbalance);
        }
        return amountToTransfer;
    }
}