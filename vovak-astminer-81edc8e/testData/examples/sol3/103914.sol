 

 


pragma solidity ^0.5.0;

 
contract Context {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}


 
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


 


interface IKYFV2 {

    function checkVerified(
        address _user
    )
        external
        view
        returns (bool);

}

 


contract KYFToken is Ownable {

     

    mapping (address => bool) public kyfInstances;

    address[] public kyfInstancesArray;

     

    event KyfStatusUpdated(address _address, bool _status);

     

    function isVerified(
        address _user
    )
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i < kyfInstancesArray.length; i++) {
            IKYFV2 kyfContract = IKYFV2(kyfInstancesArray[i]);
            if (kyfContract.checkVerified(_user) == true) {
                return true;
            }
        }

        return false;
    }

     

    function setApprovedKYFInstance(
        address _kyfContract,
        bool _status
    )
        public
        onlyOwner
    {
        if (_status == true) {
            kyfInstancesArray.push(_kyfContract);
            kyfInstances[_kyfContract] = true;
            emit KyfStatusUpdated(_kyfContract, true);
            return;
        }

         
        for (uint i = 0; i < kyfInstancesArray.length; i++) {
            if (address(kyfInstancesArray[i]) == _kyfContract) {
                delete kyfInstancesArray[i];
                kyfInstancesArray[i] = kyfInstancesArray[kyfInstancesArray.length - 1];

                 
                kyfInstancesArray.length--;
                break;
            }
        }

         
        delete kyfInstances[_kyfContract];
        emit KyfStatusUpdated(_kyfContract, false);
    }

     

     
    function name()
        public
        view
        returns (string memory)
    {
        return "ARC KYF Token";
    }

     
    function symbol()
        public
        view
        returns (string memory)
    {
        return "ARCKYF";
    }

     
    function decimals()
        public
        view
        returns (uint8)
    {
        return 0;
    }

     
    function totalSupply()
        public
        view
        returns (uint256)
    {
        return kyfInstancesArray.length;
    }

     
    function balanceOf(
        address account
    )
        public
        view
        returns (uint256)
    {
        if (isVerified(account)) {
            return 1;
        }

        return 0;
    }

     
    function approve(
        address spender,
        uint256 amount
    )
        public
        returns (bool)
    {
        return false;
    }

     
    function transfer(
        address recipient,
        uint256 amount
    )
        public
        returns (bool)
    {
        return false;
    }

     
    function allowance(
        address owner,
        address spender
    )
        public
        view
        returns (uint256)
    {
        return 0;
    }

     
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        returns (bool)
    {
        return false;
    }

}