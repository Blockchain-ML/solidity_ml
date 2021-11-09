pragma solidity ^0.4.24;

 
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

   
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

   
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract Profile is Ownable {
    struct User {
        string nickname;
        string avatar;
        string payload;
        bool isEntity;
    }
    
    mapping(address => User) private users;
    mapping(bytes32 => address) private addresses;
    
    function newUserFrom(address _addr, string _nickname, string _avatar, string _payload) public onlyOwner {
        if (!users[_addr].isEntity) {
            users[_addr] = User(_nickname, _avatar, _payload, true);
            addresses[keccak256(_nickname)] = _addr;
        }
    }
    
    function newUser(string _nickname, string _avatar, string _payload) public {
        if (!users[msg.sender].isEntity) {
            users[msg.sender] = User(_nickname, _avatar, _payload, true);
            addresses[keccak256(_nickname)] = msg.sender;
        }
    }
    
    function getNicknameByAddress(address _addr) public constant returns(string) {
        return users[_addr].nickname;
    }
    
    function getNickname() public constant returns(string) {
        return getNicknameByAddress(msg.sender);
    }
    
    function getAddressByNickname(string _nickname) public constant returns(address) {
        return addresses[keccak256(_nickname)];
    }
    
    function getAvatarByAddress(address _addr) public constant returns(string) {
        return users[_addr].avatar;
    }
    
    function getAvatarByNickname(string _nickname) public constant returns(string) {
        return getAvatarByAddress(getAddressByNickname(_nickname));
    }
    
    function getAvatar() public constant returns(string) {
        return getAvatarByAddress(msg.sender);
    }
    
    function setAvatar(string _avatar) public {
        users[msg.sender].avatar = _avatar;
    }
    
    function setAvatarFrom(address _addr, string _avatar) public onlyOwner {
        users[_addr].avatar = _avatar;
    }
    
    function setPayloadFrom(address _addr, string _payload) public onlyOwner {
        users[_addr].payload = _payload;
    }
    
    function setPayload(string _payload) public {
        users[msg.sender].payload = _payload;
    }
    
    function getPayloadFrom(address _addr) public constant returns(string) {
        return users[_addr].payload;
    }
    
    function getPayload() public constant returns(string) {
        return users[msg.sender].payload;
    }
    
    function removeUser(address _addr) public onlyOwner {
        delete addresses[keccak256(getNicknameByAddress(_addr))];
        delete users[_addr];
    }
}