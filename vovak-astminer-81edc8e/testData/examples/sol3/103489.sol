pragma solidity 0.6.12;

 

 

 
contract Ownable {
    address private _owner;
    address public pendingOwner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    
     
  modifier onlyPendingOwner() {
    assert(msg.sender != address(0));
    require(msg.sender == pendingOwner);
    _;
  }

     
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

     
  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    pendingOwner = _newOwner;
  }
  
   
  function claimOwnership() onlyPendingOwner public {
    _transferOwnership(pendingOwner);
    pendingOwner = address(0);
  }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface token {
    function transfer(address, uint) external returns (bool);
}

contract TokenLock is Ownable {
    

    address public constant beneficiary = 0x1Cb48D072A5Df6fE62AE79cCbF1B83288e44257E;

    
     
    uint public constant unlockTime = 1633322356;

    function isUnlocked() public view returns (bool) {
        return now > unlockTime;
    }
    
    function claim(address _tokenAddr, uint _amount) public onlyOwner {
        require(isUnlocked(), "Cannot transfer tokens while locked.");
        token(_tokenAddr).transfer(beneficiary, _amount);
    }
}