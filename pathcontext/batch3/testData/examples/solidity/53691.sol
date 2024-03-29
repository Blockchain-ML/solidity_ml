pragma solidity ^0.4.24;

contract ETC{

     
    event onCreateETCOrder
    (
        uint256 logisticOrderId, 
        address customerAddr, 
        uint256 eth  
    );

     
    event onExcuteETCOnce
    (
        uint256 logisticOrderId, 
        address etcAddr, 
        uint256 eth  
    );

     
    event onConfirm
    (
        uint256 logisticOrderId, 
        address customerAddr, 
        uint256 eth  
    );

      
    uint256 public pool = 0;
    address private etcAddr = 0xf866d0f8d7bceee394adc5d3dadeb32be7c84e81;
    address private admin = msg.sender;
    address public comfirmAddr;

     
     
     
    mapping (uint256 => EtcOrder) public EtcOrders;           

    modifier onlyAdmin(address _adminAddr){
        require(admin == _adminAddr,"must be admin address");
        _;
    }

    modifier onlyConfirmAddr(address _confirmAddr){
       require(comfirmAddr == _confirmAddr,"must be confirm address");
        _;
    }

    modifier onlyETCAddr(address _etcAddr){
       require(etcAddr == _etcAddr,"must be etc address");
        _;
    }

    function core(uint256 logisticOrderId,address customerAddr)
    onlyConfirmAddr(msg.sender)
    public payable{
        pool = pool + msg.value;
        EtcOrders[logisticOrderId] = EtcOrder(customerAddr,msg.value);
        emit onCreateETCOrder(logisticOrderId,customerAddr,msg.value);
    }

    function setConfirmAddr(address _confirmAddr)
    onlyAdmin(msg.sender)
    public {
        comfirmAddr = _confirmAddr;
    }

    function reduce(uint256 logisticOrderId)
    onlyETCAddr(msg.sender)
    public payable{
        require(EtcOrders[logisticOrderId].eth > 0,"order id must be exists");
        EtcOrders[logisticOrderId].eth = EtcOrders[logisticOrderId].eth - 10 ** 17;
        etcAddr.transfer(10 ** 17);
        pool = pool - 10 ** 17;
        emit onExcuteETCOnce(logisticOrderId,EtcOrders[logisticOrderId].customerAddr,10 ** 17);
    }

    function confirm(uint256 logisticOrderId)
    onlyConfirmAddr(msg.sender)
    public{
        if (EtcOrders[logisticOrderId].eth > 0) {
            pool = pool - EtcOrders[logisticOrderId].eth;
            address customerAddr = EtcOrders[logisticOrderId].customerAddr;
            customerAddr.transfer(EtcOrders[logisticOrderId].eth);
            emit onConfirm(logisticOrderId,customerAddr,EtcOrders[logisticOrderId].eth);
        }
    }

    struct EtcOrder{
        address customerAddr;        
        uint256 eth;                 
    }
}