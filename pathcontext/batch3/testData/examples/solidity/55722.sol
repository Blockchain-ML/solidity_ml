pragma solidity 0.4.24;
 
library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        uint256 c = a / b;
        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        uint256 c = a - b;
        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "MOD_ERROR");
        return a % b;
    }
}

contract Erc20Token {

     
    function totalSupply() public pure returns (uint) {}

     
    function balanceOf(address _owner) public view returns (uint);

     
    function transfer(address _to, uint _value) public returns (bool success);

     
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);

     
    function approve(address _spender, uint _value) public returns (bool success);

     
    function allowance(address _owner, address _spender) public view returns (uint remaining);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract LibOwnable {
    address private _owner;

    event OwnershipTransferred(
      address indexed previousOwner,
      address indexed newOwner
    );

     
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns(address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner(), "NOT_OWNER");
        _;
    }

     
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "INVALID_OWNER");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract LibWhitelist is LibOwnable {
    mapping (address => bool) public whitelist;
    address[] public allAddresses;

    event AddressAdded(
        address indexed adr
    );

    event AddressRemoved(
        address indexed adr
    );

     
    modifier onlyAddressInWhitelist {
        require(whitelist[msg.sender], "SENDER_NOT_IN_WHITELIST");
        _;
    }

     
    function addAddress(address adr) external onlyOwner {
        emit AddressAdded(adr);
        whitelist[adr] = true;
        allAddresses.push(adr);
    }

     
    function removeAddress(address adr) external onlyOwner {
        emit AddressRemoved(adr);
        delete whitelist[adr];
        for(uint i = 0; i < allAddresses.length; i++){
            if(allAddresses[i] == adr) {
                allAddresses[i] = allAddresses[allAddresses.length - 1];
                allAddresses.length -= 1;
                break;
            }
        }
    }

     
    function getAllAddresses() external view returns (address[] memory) {
        return allAddresses;
    }
}

contract HotReward is LibWhitelist {
    using SafeMath for uint256;

    uint256 public hotPrice = 1;
    address public constant HotTokenAddress = 0x958113Ee9Def5ACa1698E1f5C4d7E9eB50Ff6f4F;

    function updateHotPrice(uint256 price) public onlyOwner {
        hotPrice = price;
    }

    function reward(address to, uint256 gasCost) external onlyAddressInWhitelist {
         
        address hotTokenAddress = HotTokenAddress;
        uint256 amount = gasCost;
        address selfAddress = address(this);

        assembly {
            let tmp1 := mload(0)
            let tmp2 := mload(4)
            let tmp3 := mload(32)

             
            mstore(0, 0x70a0823100000000000000000000000000000000000000000000000000000000)
            mstore(4, selfAddress)

            let result := call(gas, hotTokenAddress, 0, 0, 36, 0, 32)
            result := mload(0)

            if lt(result, amount) {
                mstore(0, tmp1)
                mstore(4, tmp2)
                mstore(32, tmp3)
                return(0, 0)
            }

             
            mstore(0, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(4, to)
            mstore(36, amount)
             
            result := call(gas, hotTokenAddress, 0, 0, 68, 0, 32)

            if and(eq(result, 1), eq(mload(0), 1)) {
                mstore(0, tmp1)
                mstore(4, tmp2)
                mstore(32, tmp3)
                return(0, 0)
            }
        }

        revert("REWARD_ERROR");
    }
}