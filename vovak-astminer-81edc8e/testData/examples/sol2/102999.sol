 

 

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



 

 

pragma solidity ^0.6.0;



 
 
 
 

 
 
 
 

 
 
 

abstract contract Vesting is Ownable {

     
    struct Timelock {
        address beneficiary;
        uint256 balance;
        uint256 releaseTimeOffset;
    }

     
    Timelock[] public timelocks;

     
    uint256 public listingTime = 0;

     
    IERC20 token;

     
    event TimelockRelease(address receiver, uint256 amount, uint256 timelock);

     
    constructor(address tokenContract) public {
        token = IERC20(tokenContract);
    }

     
    function setupTimelock(address beneficiary, uint256 amount, uint256 releaseTimeOffset)
    internal
    {
         
        Timelock memory timelock;

         
        timelock.beneficiary = beneficiary;

         
        timelock.balance = amount;

         
        timelock.releaseTimeOffset = releaseTimeOffset;

         
        timelocks.push(timelock);
    }

     
    function setListingTime()
    public
    onlyOwner
    {
         
        require(listingTime == 0, "Listingtime was already set");

         
        listingTime = block.timestamp;
    }

     
     
     
     
    function release(uint256 timelockNumber)
    public
    {
         
        require(listingTime > 0, "Listing time was not set yet");

         
        Timelock storage timelock = timelocks[timelockNumber];

         
        require(listingTime + timelock.releaseTimeOffset <= now, "Timelock can not be released yet.");

         
        uint256 amount = timelock.balance;

         
        timelock.balance = 0;

         
        require(token.transfer(timelock.beneficiary, amount), "Transfer of amount failed");

         
        emit TimelockRelease(timelock.beneficiary, amount, timelockNumber);

    }

}


 

 

pragma solidity ^0.6.0;



contract VestingPrivateSale is Vesting {

    constructor(address tokenContract, address beneficiary) Vesting(tokenContract) public {

         
        setupTimelock(beneficiary, 36000000e18, 0 days);

         
        setupTimelock(beneficiary, 36000000e18, 91 days);

         
        setupTimelock(beneficiary, 36000000e18, 182 days);

         
        setupTimelock(beneficiary, 36000000e18, 273 days);

         
        setupTimelock(beneficiary, 36000000e18, 365 days);

         
        transferOwnership(beneficiary);
    }

}