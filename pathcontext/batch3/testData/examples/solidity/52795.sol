 

pragma solidity ^0.5.10;

contract ERC20Basic {
    function totalSupply() public view returns (uint);
    function balanceOf(address who) public view returns (uint);
    function transfer(address to, uint value) public;
    event Transfer(address indexed from, address indexed to, uint value);
}
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint);
    function transferFrom(address from, address to, uint value) public;
    function approve(address spender, uint value) public;
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract ERC20AndBEP2AtomicSwapper {

    struct Swap {
        uint256 timelock;
        uint256 value;
        bytes32 secretLock;
        bytes32 secretKey;
        address sender;
        address traderAddr;
        address BEP2Addr;
    }

    enum States {
        INVALID,
        OPEN,
        COMPLETED,
        EXPIRED
    }

     
    event SwapInitialization(bytes32 _swapID, bytes32 _secretHashLock, uint256 _timelock, address _traderAddr, uint256 _amount);
    event SwapExpire(bytes32 _swapID);
    event SwapCompletion(bytes32 _swapID, bytes32 _secretKey);

     
    mapping (bytes32 => Swap) private swaps;
    mapping (bytes32 => States) private swapStates;
    mapping (bytes32 => uint256) public redeemedAt;

    address public ERC20ContractAddr;
    address public owner;

     
    modifier onlyInvalidSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == States.INVALID, "swap opened previously");
        _;
    }

     
    modifier onlyOpenSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == States.OPEN, "swap not open");
        _;
    }

     
    modifier onlyCompletedSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == States.COMPLETED, "swap not redeemed");
        _;
    }

     
    modifier onlyExpirableSwaps(bytes32 _swapID) {
         
        require(now >= swaps[_swapID].timelock, "swap not expirable");
        _;
    }

     
    modifier onlyBeforeExpireTime(bytes32 _swapID) {
         
        require(now < swaps[_swapID].timelock, "swap is expired");
        _;
    }

     
    modifier onlyWithSecretKey(bytes32 _swapID, bytes32 _secretKey) {
        require(swaps[_swapID].secretLock == sha256(abi.encodePacked(_secretKey)), "invalid secret");
        _;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    constructor() public {
        owner = msg.sender;
    }

    function setERC20Address(address erc20Contract) public onlyOwner {
        if (erc20Contract != address(0)) {
            ERC20ContractAddr = erc20Contract;
        }
    }

     
     
     
     
     
     
     
     
    function initiate(
        bytes32 _swapID,
        address _BEP2Addr,
        address _traderAddr,
        bytes32 _secretLock,
        uint256 _timelock,
        uint256 _amount
    ) external onlyInvalidSwaps(_swapID) {
        ERC20(ERC20ContractAddr).transferFrom(msg.sender, address(this), _amount);
         
        Swap memory swap = Swap({
            timelock: _timelock,
            value: _amount,
            sender: msg.sender,
            traderAddr: _traderAddr,
            BEP2Addr: _BEP2Addr,
            secretLock: _secretLock,
            secretKey: 0x0
            });
        swaps[_swapID] = swap;
        swapStates[_swapID] = States.OPEN;

         
        emit SwapInitialization(_swapID, _secretLock, _timelock, _BEP2Addr, _amount);
    }

     
     
     
     
    function redeem(bytes32 _swapID, bytes32 _secretKey) external onlyBeforeExpireTime(_swapID) onlyOpenSwaps(_swapID) onlyWithSecretKey(_swapID, _secretKey) {
         
        swaps[_swapID].secretKey = _secretKey;
        swapStates[_swapID] = States.COMPLETED;
         
        redeemedAt[_swapID] = now;

        ERC20(ERC20ContractAddr).transfer(swaps[_swapID].traderAddr, swaps[_swapID].value);

         
        emit SwapCompletion(_swapID, _secretKey);
    }

     
     
     
    function refund(bytes32 _swapID) external onlyOpenSwaps(_swapID) onlyExpirableSwaps(_swapID) {
         
        swapStates[_swapID] = States.EXPIRED;

        ERC20(ERC20ContractAddr).transfer(swaps[_swapID].sender, swaps[_swapID].value);

         
        emit SwapExpire(_swapID);
    }

     
     
     
    function audit(bytes32 _swapID) external view returns (uint256 timelock, uint256 value, address from, address to, address BEP2Addr, bytes32 secretLock) {
        Swap memory swap = swaps[_swapID];
        return (
        swap.timelock,
        swap.value,
        swap.sender,
        swap.traderAddr,
        swap.BEP2Addr,
        swap.secretLock
        );
    }

     
     
     
    function auditSecret(bytes32 _swapID) external view onlyCompletedSwaps(_swapID) returns (bytes32 secretKey) {
        return swaps[_swapID].secretKey;
    }

     
     
     
    function refundable(bytes32 _swapID) external view returns (bool) {
         
        return (now >= swaps[_swapID].timelock && swapStates[_swapID] == States.OPEN);
    }

     
     
     
    function initiatable(bytes32 _swapID) external view returns (bool) {
        return (swapStates[_swapID] == States.INVALID);
    }

     
     
     
    function redeemable(bytes32 _swapID) external view returns (bool) {
        return (swapStates[_swapID] == States.OPEN);
    }

     
     
     
     
    function swapID(bytes32 _secretLock, uint256 _timelock) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_secretLock, _timelock));
    }
}