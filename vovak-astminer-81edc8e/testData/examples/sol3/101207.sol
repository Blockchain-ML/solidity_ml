 
pragma solidity 0.6.11;

 


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

 

pragma solidity 0.6.11;

interface IFUSDSupplyOracle {
    function getSupply() external view returns (uint256, uint256);
}

 

pragma solidity 0.6.11;


contract FUSDSupplyOracleProxy is Ownable {
    IFUSDSupplyOracle public supplyOracle;

    constructor(IFUSDSupplyOracle _supplyOracle) public {
        supplyOracle = _supplyOracle;
    }

    function setSupplyOracle(IFUSDSupplyOracle _supplyOracle)
        external
        onlyOwner
    {
        supplyOracle = _supplyOracle;
    }

    function getSupply() external view returns (uint256, uint256) {
        return supplyOracle.getSupply();
    }
}