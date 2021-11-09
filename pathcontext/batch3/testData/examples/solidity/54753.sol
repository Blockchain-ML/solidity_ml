pragma solidity ^0.4.24;

contract ERC20Basic {
    function balanceOf(address _who) public constant returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}

 

contract Identity {

    enum Purposes {
        NONE,              
        READ_ONLY,         
        WRITE_ONLY,        
        ___,
        KEY_MANAGEMENT,    
        _____,
        ______,
        _______,
        FUNDS_MANAGEMENT,  
        _________,
        __________,
        ___________,
        ____________,
        _____________,
        ______________,
        ALL_PURPOSES       
    }

    event AccessorAdded(address indexed key, uint8 indexed purpose);
    event AccessorRemoved(address indexed key, uint8 indexed purpose);
    event AccessorUpdated(address indexed key, uint8 indexed oldPurpose, uint8 indexed newPurpose);

    mapping(address => uint8) accessorMap;

     
    constructor(address[] _initialAccessors, uint8[] _purposes) public {
        uint arrayLength = _initialAccessors.length;
        require(arrayLength == _purposes.length, "Arrays must be of the same size");
        for(uint i = 0; i < arrayLength; i++) {
            accessorMap[_initialAccessors[i]] = _purposes[i];
            emit AccessorAdded(_initialAccessors[i], _purposes[i]);
        }
    }

    modifier allowedByPurpose(Purposes _purpose) {
        require(accessorMap[msg.sender] & uint8(_purpose) != 0, "Not authorized");
        _;
    }

    modifier checkPurpose(uint8 _purpose) {
        require(_purpose > uint8(Purposes.NONE) && _purpose <= uint8(Purposes.ALL_PURPOSES), "Invalid purpose");
        _;
    }

     
    function getAccessorPurpose(address _key) public view returns(uint8) {
        return accessorMap[_key];
    }

     
    function addAccessor(address _key, uint8 _purpose) public allowedByPurpose(Purposes.KEY_MANAGEMENT) checkPurpose(_purpose) {
        uint8 oldPurpose = accessorMap[_key];
        accessorMap[_key] = _purpose;
        if (oldPurpose != 0) {
            emit AccessorUpdated(_key, oldPurpose, _purpose);
        } else {
            emit AccessorAdded(_key, _purpose);
        }
    }

     
    function removeAccessor(address _key) public allowedByPurpose(Purposes.KEY_MANAGEMENT) {
        uint8 purpose = accessorMap[_key];
        delete accessorMap[_key];
        emit AccessorRemoved(_key, purpose);
    }

     
    function withdraw() public allowedByPurpose(Purposes.FUNDS_MANAGEMENT) {
        msg.sender.transfer(address(this).balance);
    }

     
    function transferEth(uint _amount, address _account) allowedByPurpose(Purposes.FUNDS_MANAGEMENT) public {
        require(_amount <= address(this).balance, "Amount should be less than total balance of the contract");
        require(_account != address(0), "must be valid address");
        _account.transfer(_amount);
    }

     
    function getBalance() public view returns(uint)  {
        return address(this).balance;
    }

     
    function getTokenBalance(address _token) public view returns (uint) {
        return ERC20Basic(_token).balanceOf(this);
    }

     
    function withdrawTokens(address _token) public allowedByPurpose(Purposes.FUNDS_MANAGEMENT) {
        require(_token != address(0));
        ERC20Basic token = ERC20Basic(_token);
        uint balance = token.balanceOf(this);
         
        assert(token.transfer(msg.sender, balance));
    }

     
    function transferTokens(address _token, address _to, uint _amount) public allowedByPurpose(Purposes.FUNDS_MANAGEMENT) {
        require(_token != address(0));
        require(_to != address(0));
        ERC20Basic token = ERC20Basic(_token);
        uint balance = token.balanceOf(this);
        require(_amount <= balance);
        assert(token.transfer(_to, _amount));
    }

    function () public payable {}
}