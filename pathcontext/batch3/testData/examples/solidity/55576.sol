pragma solidity ^0.4.24;


 
library SafeMath {

   
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
     
     
     
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

   
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
     
     
     
    return _a / _b;
  }

   
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

   
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


 
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


 
contract Contactable is Ownable {

  string public contactInformation;

   
  function setContactInformation(string _info) public onlyOwner {
    contactInformation = _info;
  }
}


contract IERC223Basic {
  function balanceOf(address _owner) public constant returns (uint);
  function transfer(address _to, uint _value) public;
  function transfer(address _to, uint _value, bytes _data) public;
  event Transfer(
    address indexed from, 
    address indexed to, 
    uint value, 
    bytes data
  );
}


contract IERC223 is IERC223Basic {
  function allowance(address _owner, address _spender) 
    public view returns (uint);

  function transferFrom(address _from, address _to, uint _value, bytes _data) 
    public;

  function approve(address _spender, uint _value) public;
  event Approval(address indexed owner, address indexed spender, uint value);
}


contract IERC223BasicReceiver {
  function tokenFallback(address _from, uint _value, bytes _data) public;
}


contract IERC223Receiver is IERC223BasicReceiver {
  function receiveApproval(address _owner, uint _value) public;
}


 
contract ERC223BasicReceiver is IERC223BasicReceiver {
  event TokensReceived(address sender, address origin, uint value, bytes data);
  
   
  function tokenFallback(address _from, uint _value, bytes _data) public {
    require(_from != address(0));
    emit TokensReceived(msg.sender, _from, _value, _data);
  }
}


 
contract ERC223Receiver is ERC223BasicReceiver, IERC223Receiver {
  event ApprovalReceived(address sender, address owner, uint value);

   
  function receiveApproval(address _owner, uint _value) public {
    require(_owner != address(0));
    emit ApprovalReceived(msg.sender, _owner, _value);
  }
}


 
contract Fund is ERC223Receiver, Contactable {
  IERC223 public token;
  string public fundName;

   
  constructor(IERC223 _token, string _fundName) public {
    require(address(_token) != address(0));
    token = _token;
    fundName = _fundName;
  }

   
  function transfer(address _to, uint _value) public onlyOwner {
    token.transfer(_to, _value);
  }

   
  function transfer(address _to, uint _value, bytes _data) public onlyOwner {
    token.transfer(_to, _value, _data);
  }

   
  function transferFrom(
    address _from, 
    address _to, 
    uint _value, 
    bytes _data
  ) 
    public
    onlyOwner
  {
    token.transferFrom(_from, _to, _value, _data);
  }

   
  function approve(address _spender, uint _value) public onlyOwner {
    token.approve(_spender, _value);
  }
}


 
contract ReserveFund is Fund {
  using SafeMath for uint;

  uint public constant creationTime = 1537056000;

  uint public firstLimit = 200000000000;
  uint public secondLimit = 100000000000;
  uint public thirdLimit = 200000000000;

   
  constructor(IERC223 _token) public Fund(_token, "Reserve Fund") {
  }

   
  function transfer(address _to, uint _value) public onlyOwner {
    _timeLimit(_value);
    super.transfer(_to, _value);
  }
  
   
  function transfer(address _to, uint _value, bytes _data) public onlyOwner {
    _timeLimit(_value);
    super.transfer(_to, _value, _data);
  }

   
  function approve(address _spender, uint _value) public onlyOwner {
    _timeLimit(_value);
    super.approve(_spender, _value);
  }

   
  function _timeLimit(uint _value) internal {
    if (block.timestamp < creationTime.add(360 days)) {
      require(_value <= firstLimit);
      firstLimit = firstLimit.sub(_value);
    } else if (
      block.timestamp >= creationTime.add(360 days) && 
      block.timestamp < creationTime.add(540 days)
    ) {
      require(_value <= firstLimit.add(secondLimit));
      if (firstLimit >= _value) {
        firstLimit = firstLimit.sub(_value);
      } else {
        secondLimit = secondLimit.sub(_value);
      }
    } else if (
      block.timestamp >= creationTime.add(540 days) && 
      block.timestamp < creationTime.add(720 days)
    ) {
      require(_value <= firstLimit.add(secondLimit).add(thirdLimit));
      if (firstLimit >= _value) {
        firstLimit = firstLimit.sub(_value);
      } else if (secondLimit >= _value) {
        secondLimit = secondLimit.sub(_value);
      } else {
        thirdLimit = thirdLimit.sub(_value);
      }
    }
  }

}