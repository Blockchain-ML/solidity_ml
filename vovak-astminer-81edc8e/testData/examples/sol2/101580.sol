 

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

library SafeMath_Chainlink {
   
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
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
     
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;
     

    return c;
  }

   
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);
  function approve(address spender, uint256 value) external returns (bool success);
  function balanceOf(address owner) external view returns (uint256 balance);
  function decimals() external view returns (uint8 decimalPlaces);
  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);
  function increaseApproval(address spender, uint256 subtractedValue) external;
  function name() external view returns (string memory tokenName);
  function symbol() external view returns (string memory tokenSymbol);
  function totalSupply() external view returns (uint256 totalTokensIssued);
  function transfer(address to, uint256 value) external returns (bool success);
  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool success);
}

contract VRFRequestIDBase {

   
  function makeVRFInputSeed(bytes32 _keyHash, uint256 _userSeed,
    address _requester, uint256 _nonce)
    internal pure returns (uint256)
  {
    return  uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

   
  function makeRequestId(
    bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

 
abstract contract VRFConsumerBase is VRFRequestIDBase {

  using SafeMath_Chainlink for uint256;

   
  function fulfillRandomness(bytes32 requestId, uint256 randomness)
    internal virtual;

   
  function requestRandomness(bytes32 _keyHash, uint256 _fee, uint256 _seed)
    public returns (bytes32 requestId)
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, _seed));
     
     
     
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, _seed, address(this), nonces[_keyHash]);
     
     
     
     
     
    nonces[_keyHash] = nonces[_keyHash].add(1);
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

   
   
   
  mapping(bytes32   => uint256  ) public nonces;
  constructor(address _vrfCoordinator, address _link) public {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

   
   
   
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

 
contract RandomWinner is Ownable, VRFConsumerBase {

    event WinnerSelected(uint256 timestamp, address winner);

    address[] addressList;
    uint256 public addressCount;
    
    address[] winners;
    mapping(address => bool) winnersMapping;
    uint256 public winnerCount;
    
    bool winnersSelected = false;

    bytes32 internal keyHash;
    uint256 internal randomFee;
    
    uint256 public randomResult;
    uint256 public previousWinnerSeed;
    
     
    constructor() 
        VRFConsumerBase(
            0xf0d54349aDdcf704F77AE15b96510dEA15cb7952,  
            0x514910771AF9Ca656af840dff83E8264EcF986CA   
        ) public
    {
        keyHash = 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445;
        randomFee = 2 * 10 ** 18;  
    }
    
     
    function getRandomNumber(uint256 userProvidedSeed) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) > randomFee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, randomFee, userProvidedSeed);
    }

     
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }
    
    function updateAddressList(address[] memory _addresses) public onlyOwner {
        require(!winnersSelected);
        
        for (uint256 i = 0; i < _addresses.length; i++) {
            addressList.push(_addresses[i]);
            addressCount++;
        }
    }
    
    function selectWinners(uint256 count) public onlyOwner {
        require(randomResult != 0);
        require((count + winnerCount) < addressCount);

        if (previousWinnerSeed == 0) {
            previousWinnerSeed = randomResult;
        }
        
        for (uint256 i = 0; i < count; i++) {
            
            uint256 winnerSeed;
            uint256 winnerIndex;
            address winner;
            
            bool winnerSelected = false;
            uint256 nonce = 0;
            do {
                winnerSeed = uint256(keccak256(abi.encodePacked(previousWinnerSeed, i, nonce)));
                winnerIndex =  winnerSeed % addressCount;
                winner = addressList[winnerIndex];
                nonce++;
                
                winnerSelected = !winnersMapping[winner];
            } while (!winnerSelected);
            
            winners.push(winner);
            winnersMapping[winner] = true;
            previousWinnerSeed = winnerSeed;

            emit WinnerSelected(block.timestamp, winner);

            winnerCount++;
        }
        
        winnersSelected = true;
    }

    function getAddressList() public view returns (address[] memory) {
        return addressList;
    }
    
    function getWinners() public view returns (address[] memory) {
        return winners;
    }
    
    function isWinner(address _address) public view returns (bool) {
        return winnersMapping[_address];
    }
}