 

 

pragma solidity ^0.6.0;

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

 

pragma solidity ^0.6.0;

 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

 

 

pragma solidity >=0.6.0;




contract WOMTokenLocker is Ownable {

    IERC20 public WOM_TOKEN;
    mapping (address => Allocation) public allocation;

    struct Allocation {
        uint256 release;  
        uint256 amount;   
    }

    event AllocationAdded(address indexed recipient, uint256 release, uint256 amount);
    event AllocationRemoved(address indexed recipient);
    event AllocationClaimed(address indexed recipient, uint256 release, uint256 amount);

    constructor(address _womToken) public {
        WOM_TOKEN = IERC20(_womToken);
    }

     
    function addAllocation(address recipient, uint256 release, uint256 amount) 
        public
        onlyOwner
    {
        require(WOM_TOKEN.allowance(owner(), address(this)) >= amount, 'WOMTokenLocker: allowance is less than amount');
        
        WOM_TOKEN.transferFrom(owner(), address(this), amount);
        allocation[recipient] = Allocation({
            release: release,
            amount: amount
        });

        emit AllocationAdded(msg.sender, release, amount);
    }

     
    function removeAllocation(address recipient) 
        public
        onlyOwner
    {
        Allocation memory alloc = allocation[recipient];

        require(alloc.amount != 0, 'WOMTokenLocker: client does not exist');

        delete allocation[msg.sender];
        WOM_TOKEN.transfer(owner(), alloc.amount);

        emit AllocationRemoved(msg.sender);
    }

     
    function claimAllocation() 
        public
    {
        Allocation memory alloc = allocation[msg.sender];

        require(alloc.amount != 0, 'WOMTokenLocker: client does not have allocation');
        require(now >= alloc.release, 'WOMTokenLocker: client cannot claim with time lock');

        require(WOM_TOKEN.balanceOf(address(this)) >= alloc.amount, 'WOMTokenLocker: contract does not have sufficient funds');

        delete allocation[msg.sender];
        WOM_TOKEN.transfer(msg.sender, alloc.amount);
        
        emit AllocationClaimed(msg.sender, alloc.release, alloc.amount);
    }
}