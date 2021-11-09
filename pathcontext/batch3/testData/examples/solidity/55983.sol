pragma solidity ^0.4.24;

contract Exchange {
    
     
    struct Order {
        address creator;
        uint amount;
        uint createdAt;
    }
    
    event OrderCreation(uint _index);
    event OrderClosed(uint _index);
    event OrderAccept(uint _index);
    
    uint constant ORDER_LIFE_TIME = 300000;
    
     
    Order[] public orders;
    
     
    modifier onlyCreator(address _creator, uint _index) {
        require(_creator == orders[_index].creator);
        _;
    }
    
     
    modifier canBeClosed(uint _index) {
        require(block.timestamp > orders[_index].createdAt + ORDER_LIFE_TIME);
        _;
    }
    
     
    modifier isOpen(uint _index) {
        require(block.timestamp < orders[_index].createdAt + ORDER_LIFE_TIME);
        _;
    }
    
     
    modifier isNotNull(uint _index) {
        require(orders[_index].amount != 0);
        _;
    }
    
     
    modifier isEnoughPrice(uint _index, uint amount) {
        require(orders[_index].amount == amount);
        _;
    }
    
     
    function () public payable {
        Order memory order = Order({
            creator: msg.sender,
            amount: msg.value,
            createdAt: block.timestamp
        });
        emit OrderCreation(orders.length);
        orders.push(order);
    }
    
     
    function getOrdersLength() constant public returns (uint) {
        return orders.length;
    }
    
     
    function closeOrder(
        uint _index
    ) 
        public 
        onlyCreator(msg.sender, _index)
        canBeClosed(_index)
    {
        uint amount = orders[_index].amount;
        delete orders[_index];
        emit OrderClosed(_index);
        msg.sender.transfer(amount);
    }
    
     
    function acceptOrder(
        uint _index    
    )
        public
        payable
        isOpen(_index)
        isNotNull(_index)
        isEnoughPrice(_index, msg.value)
    {
        uint amount = orders[_index].amount;
        address seller = orders[_index].creator;
        delete orders[_index];
        emit OrderAccept(_index);
        
         
        msg.sender.transfer(amount);
        seller.transfer(msg.value);
    }
    
}