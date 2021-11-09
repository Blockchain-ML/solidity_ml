 

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

 

pragma solidity ^0.5.0;

 
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

 

pragma solidity 0.5.16;




contract TTTdefiFundV2 is Ownable {
  using SafeMath for uint;

   

   
  uint public expiration;

   
  address public beneficiary;

   
  address[] public tokenLUT;

   
  mapping(address => bool) public tokens;

   

   
  event Deposit(address indexed _from, uint _value, address indexed _token);

   
  event Withdraw(address indexed _to, uint _value, address indexed _token);

   
  event IncreaseTime(uint _newExpiration);

   
  event UpdateBeneficiary(address indexed _newBeneficiary);

   

   
  modifier isExpired() {
    require(expiration < block.timestamp, 'contract is still locked');
    _;
  }

   
  modifier onlyBeneficiary() {
    require(msg.sender == beneficiary, 'only the beneficiary can perform this function');
    _;
  }

   
  constructor(uint _expiration, address _beneficiary, address _owner) public {
    expiration = _expiration;
    beneficiary = _beneficiary;
    transferOwnership(_owner);
  }

   

   
  function getTokenSize() public view returns(uint) {
    return tokenLUT.length;
  }

   

   
  function deposit(uint _amount, address _token) public payable {
    if(_token == address(0)) {
      require(msg.value == _amount, 'incorrect amount');
      if(!tokens[_token]) {
        tokenLUT.push(_token);
        tokens[_token] = true;
      }
      emit Deposit(msg.sender, _amount, _token);
    }
    else {
      IERC20 token = IERC20(_token);
      require(token.transferFrom(msg.sender, address(this), _amount), 'transfer failed');
      if(!tokens[_token]) {
        tokenLUT.push(_token);
        tokens[_token] = true;
      }
      emit Deposit(msg.sender, _amount, _token);
    }
  }

   
  function withdraw(uint _amount, address _token) public isExpired() onlyBeneficiary() {
    if(_token == address(0)) {
      (bool success, ) = msg.sender.call.value(_amount)("");
      require(success, "Transfer failed.");
      emit Withdraw(msg.sender, _amount, _token);
    } else {
      IERC20 token = IERC20(_token);
      require(token.transfer(msg.sender, _amount), 'transfer failed');
      emit Withdraw(msg.sender, _amount, _token);
    }
  }

   
  function increaseTime(uint _newExpiration) public onlyOwner() {
    require(_newExpiration > expiration, 'can only increase expiration');
    expiration = _newExpiration;
    emit IncreaseTime(_newExpiration);
  }

   
  function updateBeneficiary(address _newBeneficiary) public onlyOwner() {
    require(_newBeneficiary != beneficiary, 'same beneficiary');
    require(_newBeneficiary != address(0), 'cannot set as burn address');
    beneficiary = _newBeneficiary;
    emit UpdateBeneficiary(_newBeneficiary);
  }
}

 

pragma solidity 0.5.16;


contract TTTdefiFundFactoryV2 {
   

   
  mapping(uint => address) funds;

   
  mapping(address => uint[]) userFunds;

   
  uint public nextId;

   

   
  event CreateFund(
    uint expiration,
    address indexed beneficiary,
    address indexed owner
  );

   

   
  function getFund(uint _id) public view returns(address) {
    return funds[_id];
  }

   
  function getUserFunds(address _user) public view returns(uint[] memory) {
    return userFunds[_user];
  }

   

   
  function createFund(uint _expiration, address _beneficiary) public {
    require(funds[nextId] == address(0), 'id already in use');
    require(_beneficiary != address(0), 'beneficiary is burn address');
    TTTdefiFundV2 fund = new TTTdefiFundV2(_expiration, _beneficiary, msg.sender);
    funds[nextId] = address(fund);
    userFunds[msg.sender].push(nextId);
    nextId++;
    emit CreateFund(_expiration, _beneficiary, msg.sender);
  }
}