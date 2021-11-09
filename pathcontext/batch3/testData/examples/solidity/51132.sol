 

pragma solidity ^0.5.10;

contract ERC20 {
    function totalSupply() public view returns (uint);
    function balanceOf(address who) public view returns (uint);
    function transfer(address to, uint value) public;
    function allowance(address owner, address spender) public view returns (uint);
    function transferFrom(address from, address to, uint value) public;
    function approve(address spender, uint value) public;
}

contract ERC20AndBEP2AtomicSwapper {

    struct Swap {
        uint256 timelock;
        uint256 amount;
        bytes32 secretHashLock;
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

     
    event SwapInitialization(address indexed _traderAddr, bytes32 _swapID, bytes32 _secretHashLock, uint256 _timelock, address _BEP2Addr, uint256 _amount);
    event SwapExpire(bytes32 _swapID);
    event SwapCompletion(bytes32 _swapID, bytes32 _secretKey);

     
    mapping (bytes32 => Swap) private swaps;
    mapping (bytes32 => States) private swapStates;
    mapping (bytes32 => uint256) private claimedTimestamp;

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

     
    modifier onlyExpirableSwaps(bytes32 _swapID) {
         
        require(now >= swaps[_swapID].timelock, "swap not expirable");
        _;
    }

     
    modifier onlyBeforeExpireTime(bytes32 _swapID) {
         
        require(now < swaps[_swapID].timelock, "swap is expired");
        _;
    }

     
    modifier onlyWithSecretKey(bytes32 _swapID, bytes32 _secretKey) {
        require(swaps[_swapID].secretHashLock == sha256(abi.encodePacked(_secretKey)), "invalid secret");
        _;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    constructor() public {
        owner = msg.sender;
    }

    function setERC20Address(address erc20Contract) public onlyOwner returns (bool) {
        if (erc20Contract != address(0)) {
            ERC20ContractAddr = erc20Contract;
            return true;
        }
        return false;
    }

     
     
     
     
     
     
     
     
    function initiate(
        bytes32 _swapID,
        address _BEP2Addr,
        address _traderAddr,
        bytes32 _secretHashLock,
        uint256 _timelock,
        uint256 _amount
    ) external onlyInvalidSwaps(_swapID) {
         
        ERC20(ERC20ContractAddr).transferFrom(msg.sender, address(this), _amount);
         
        Swap memory swap = Swap({
            timelock: _timelock,
            amount: _amount,
            sender: msg.sender,
            traderAddr: _traderAddr,
            BEP2Addr: _BEP2Addr,
            secretHashLock: _secretHashLock,
            secretKey: 0x0
            });
        swaps[_swapID] = swap;
        swapStates[_swapID] = States.OPEN;

         
        emit SwapInitialization(_traderAddr, _swapID, _secretHashLock, _timelock, _BEP2Addr, _amount);
    }

     
     
     
     
    function claim(bytes32 _swapID, bytes32 _secretKey) external onlyBeforeExpireTime(_swapID) onlyOpenSwaps(_swapID) onlyWithSecretKey(_swapID, _secretKey) {
         
        swaps[_swapID].secretKey = _secretKey;
        swapStates[_swapID] = States.COMPLETED;
         
        claimedTimestamp[_swapID] = now;

         
        ERC20(ERC20ContractAddr).transfer(swaps[_swapID].traderAddr, swaps[_swapID].amount);

         
        emit SwapCompletion(_swapID, _secretKey);
    }

     
     
     
    function refund(bytes32 _swapID) external onlyOpenSwaps(_swapID) onlyExpirableSwaps(_swapID) {
         
        swapStates[_swapID] = States.EXPIRED;

         
        ERC20(ERC20ContractAddr).transfer(swaps[_swapID].sender, swaps[_swapID].amount);

         
        emit SwapExpire(_swapID);
    }

     
     
     
    function auditSwap(bytes32 _swapID) external view returns (uint256 timelock, uint256 amount, address from, address to, address BEP2Addr, bytes32 secretHashLock, bytes32 secretKey) {
        Swap memory swap = swaps[_swapID];
        return (
        swap.timelock,
        swap.amount,
        swap.sender,
        swap.traderAddr,
        swap.BEP2Addr,
        swap.secretHashLock,
        swap.secretKey
        );
    }

     
     
     
    function querySecret(bytes32 _swapID) external view returns (bytes32 secretKey) {
        return swaps[_swapID].secretKey;
    }

     
     
     
    function refundable(bytes32 _swapID) external view returns (bool) {
         
        return (now >= swaps[_swapID].timelock && swapStates[_swapID] == States.OPEN);
    }

     
     
     
    function initiatable(bytes32 _swapID) external view returns (bool) {
        return (swapStates[_swapID] == States.INVALID);
    }

     
     
     
    function claimable(bytes32 _swapID) external view returns (bool) {
        return (now < swaps[_swapID].timelock && swapStates[_swapID] == States.OPEN);
    }

     
     
     
    function claimedAt(bytes32 _swapID) external view returns (uint256) {
        return claimedTimestamp[_swapID];
    }

     
     
     
     
    function swapID(bytes32 _secretHashLock, uint256 _timelock) public pure returns (bytes32) {
        return sha256(abi.encodePacked(_secretHashLock, _timelock));
    }

     
     
     
    function hashSecretKey(bytes32 _secretKey) public pure returns (bytes32) {
        return sha256(abi.encodePacked(_secretKey));
    }
}