pragma solidity ^0.4.23;

 
contract ArcadiaEscrows {
    address public arbitrator;
    address public owner;
    uint32 public requestCancellationMinimumTime;
    uint256 public arcadiaAvailFees;

    event Created(uint16 tradeHash);
    event SellerCancelDisabled(uint16 tradeHash);
    event SellerRequestedCancel(uint16 tradeHash);
    event CancelledBySeller(uint16 tradeHash);
    event CancelledByBuyer(uint16 tradeHash);
    event Released(uint16 tradeHash);
    event ReleasedDebug(string msg);
    event TransferDebug(string msg, uint256 val);
    event DisputeResolved(uint16 tradeHash);

     
     struct Trade {
        bool     exists;
        address  seller;
        address  buyer;
        uint256  value;
        uint16   fee;
        uint32   sellerCanCancelAfter;
    }

     
    mapping (uint16 => Trade) public trades;

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only owner can call this.");
        _;
    }

    modifier onlyArbitrator() {
        require(
            msg.sender == arbitrator,
            "Only arbitrator can call this.");
        _;
    }

    constructor() public {
        owner = msg.sender;
        arbitrator = msg.sender;
        requestCancellationMinimumTime = 2 hours;
    }

     
    function getTradeAndHash (uint16 tradeID, address seller, address buyer) view private returns (Trade, uint16) {
         
        uint16 tradeHash = tradeID;
        return (trades[tradeHash], tradeHash);
    }

    uint16 constant GAS = 40000;

     
    function createTrade (
      uint16 tradeID, 
      address seller, address buyer, 
      uint256 value, uint16 fee, uint32 paymentWindow
    ) payable external {
        require(msg.sender == seller);
         
        uint16 tradeHash = tradeID;
        require(!trades[tradeHash].exists);
         
        require(msg.value == value && msg.value > 0);
        uint32 sellerCanCancelAfter = paymentWindow == 0 ? 1 : uint32(block.timestamp) + paymentWindow;
        trades[tradeHash] = Trade(true, seller, buyer, value, fee, sellerCanCancelAfter);
        emit Created(tradeHash);
    }

     
    function releaseFunds (uint16 tradeID, address seller, address buyer) 
      external returns (bool) {
        require(msg.sender == seller);
        uint16 tradeHash;
        Trade memory trade;
        (trade, tradeHash) = getTradeAndHash(tradeID, seller, buyer);
        if (!trade.exists) return false;

        uint128 gasFees = GAS * uint128(tx.gasprice);
        delete trades[tradeHash];
        emit Released(tradeHash);
        transferMinusFees(buyer, trade.value, gasFees, trade.fee);
        return true;
    }

     
    function disableSellerCancel (uint16 tradeID, address seller, address buyer) 
      external returns (bool) {
        require(msg.sender == buyer);
        uint16 tradeHash;
        Trade memory trade;
        (trade, tradeHash) = getTradeAndHash(tradeID, seller, buyer);
        if (!trade.exists) return false;
        if(trade.sellerCanCancelAfter == 0) return false;
        trades[tradeHash].sellerCanCancelAfter = 0;
        emit SellerCancelDisabled(tradeHash);
        return true;
    }

     
    function buyerCancel (uint16 tradeID, address seller, address buyer)
      external returns (bool) {
        require(msg.sender == buyer);
        uint16 tradeHash;
        Trade memory trade;
        (trade, tradeHash) = getTradeAndHash(tradeID, seller, buyer);
        if (!trade.exists) return false;
        delete trades[tradeHash];
        emit CancelledByBuyer(tradeHash);
        uint128 gasFees = GAS * uint128(tx.gasprice);
        transferMinusFees(seller, trade.value, gasFees, 0);
        return true;
    }

     
    function sellerCancel (uint16 tradeID, address seller, address buyer)
      external returns (bool) {
        require(msg.sender == seller);
        uint16 tradeHash;
        Trade memory trade;
        (trade, tradeHash) = getTradeAndHash(tradeID, seller, buyer);
        if (!trade.exists) return false;
        if(trade.sellerCanCancelAfter <= 1 || trade.sellerCanCancelAfter > block.timestamp) return false;
        delete trades[tradeHash];
        emit CancelledBySeller(tradeHash);
        uint128 gasFees = GAS * uint128(tx.gasprice);
        transferMinusFees(seller, trade.value, gasFees, 0);
        return true;
    }

     
    function sellerRequestCancel (uint16 tradeID, address seller, address buyer) 
      external returns (bool) {
        require(msg.sender == seller);
        uint16 tradeHash;
        Trade memory trade;
        (trade, tradeHash) = getTradeAndHash(tradeID, seller, buyer);
        if (!trade.exists) return false;
        if(trade.sellerCanCancelAfter != 1) return false;
        trades[tradeHash].sellerCanCancelAfter = uint32(block.timestamp) + requestCancellationMinimumTime;
        emit SellerRequestedCancel(tradeHash);
        return true;
    }

     
    function resolveDispute (uint16 tradeID, address seller, address buyer, uint8 buyerPercent)
      external onlyArbitrator {
        uint16 tradeHash;
        Trade memory trade;
        (trade, tradeHash) = getTradeAndHash(tradeID, seller, buyer);
        require(trade.exists);
        require(buyerPercent <= 100);

        uint256 totalFees =  GAS * uint128(tx.gasprice);
        uint256 value = trade.value;
        require(value - totalFees <= value);
        arcadiaAvailFees += totalFees;

        delete trades[tradeHash];
        emit DisputeResolved(tradeHash);
        buyer.transfer((value - totalFees) * buyerPercent / 100);
        seller.transfer((value - totalFees) * (100 - buyerPercent) / 100);
    }

     
    function transferMinusFees(address to, uint256 value, uint128 gasFees, uint16 fee) 
      private {
         
        uint256 totalFees = (value * fee / 10000);
        if(value - totalFees > value) {
            emit TransferDebug("Not enough funds to cover fees", value - totalFees);
            return; 
        }
        arcadiaAvailFees += (value * fee / 10000);
        emit TransferDebug("Attempt transfer of:", value - totalFees);
        to.transfer(value - totalFees);
    }

     
    function withdrawFees(address to, uint256 value) 
      onlyOwner external {
        require(value <= arcadiaAvailFees);
        arcadiaAvailFees -= value;
        to.transfer(value);
    }

     
    function setArbitrator(address newArbitrator) 
      onlyOwner external {
        arbitrator = newArbitrator;
    }

     
    function setOwner(address newOwner) 
      onlyOwner external {
        owner = newOwner;
    }

     
    function setRequestCancellationMinimumTime(uint32 newMinimumTime) 
      onlyOwner external {
        requestCancellationMinimumTime = newMinimumTime;
    }
}