pragma solidity ^0.5.5;


contract Ownable {
    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

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
}


contract IERC20 {
    function balanceOf(address who) public view returns (uint256);
    function totalSupply() external view returns (uint256);    
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
}


pragma solidity ^0.5.5;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

         
         
         
        bytes32 codehash;

        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }

      
    function toPayable(address account)
        internal
        pure
        returns (address payable)
    {
        return address(uint160(account));
    }
}

 

pragma solidity ^0.5.5;

 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

     
    function callOptionalReturn(IERC20 token, bytes memory data) private {
         
         

         
         
         
         
         
        require(address(token).isContract(), "SafeERC20: call to non-contract");

         
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
             
             
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

contract PublicFunds is Ownable {
    
  using Address for address;
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  IERC20 TOPS = IERC20(0xF5a04b9E798892e96dE68733AD8FFedDa39B7E5A);

  mapping (address => uint256) public exchanged;
  uint256 public LIMIT = 50000 * 10 ** 8;
  uint256 public totalSupply;
  uint256 public issued;

  uint256 public rate;
  uint256 public periodStart;
  address public bank;

  constructor (address _bank, uint256 total, uint256 _rate, uint256 startTimestamp) public {
      bank = _bank;
      totalSupply = total;
      rate = _rate;
      issued = 0;
      periodStart = startTimestamp;
  }


  function() external payable{
      exchange();
  }

  modifier checkStart() {
    require(block.timestamp >= periodStart, "Not started!");
    _;
  }

  function exchange() public checkStart payable {
     
    uint256 tops = msg.value.mul(rate).div(10 ** 10);
     
    require(issued.add(tops) <= totalSupply, "TOPS is insufficient"); 
     
    require(exchanged[msg.sender].add(tops) <= LIMIT, "Limit 50000 TOPS per address!");

    TOPS.safeTransferFrom(bank, msg.sender, tops);
    issued = issued.add(tops);
    exchanged[msg.sender] = exchanged[msg.sender].add(tops);
    emit Exchange(msg.sender, msg.value, tops);
  }

  function withdraw(address to) public onlyOwner{
      uint256 balance = address(this).balance;
      address(to).toPayable().transfer(balance);
      emit Withdraw(to, balance);
  }

  event Exchange(address indexed from, uint256 eth, uint256 tops);
  event Withdraw(address indexed to, uint256 eth);
}