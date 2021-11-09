pragma solidity ^0.4.24;

 
 
 
 
 
 
 


 
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


interface LVECoin {
    function transfer(address _to, uint256 _value) external returns(bool);
    function balanceOf(address _owner) external view returns (uint256);
}


 
contract LVEPay {

    using SafeMath for uint256;
     
    LVECoin private tokenContr;

    event WithdrawalEther(address indexed _to, uint256 _amount);
    event Pay(address indexed _from, address indexed _to, uint256 _amount);

     
    struct PayOrder {
         
        string payID;
         
        uint256 payAmt;
    }

     
    address public walletAddr;
     
     
    mapping(string => PayOrder) payOrderMap;
     
    string[] public payOrders;
   

    constructor(address _tokenAddr, address _walletAddr) public{
        require(_tokenAddr != address(0), "");
        require(_walletAddr != address(0), "");
        walletAddr = _walletAddr;
        tokenContr = LVECoin(_tokenAddr);
    }


     
    modifier isCORRFormat(string _arg) {
        require(bytes(_arg).length > 0, "");
        _;
    }

     
     
    modifier excludeRepeatOrder(string _payOrderKey){
        PayOrder memory payOrder;
        payOrder = payOrderMap[_payOrderKey];
        require(bytes(_payOrderKey).length > 0, "");
        require(bytes(payOrder.payID).length == 0, "");
        _;
    }

     
    modifier enoughTokenAmt(uint256 _payAmt){
        uint256 tokenAmt = tokenContr.balanceOf(msg.sender);
        if (tokenAmt >= _payAmt) {
            _;
        }
    }


     
     
     
     

     
     
     
     

     
     
     

     
     
     

     
     
    function lvePay(string _payOrderKey, string _payID, uint256 _payAmt) public returns(bool){
         
         

         
         
         
         

         
         
         

         
        return true;
    }


     
    function countPayOrder() public view returns(uint256 _orderNums){
        return payOrders.length;
    }

     
    function getPayOrderKey(uint256 _index) public view returns(string _payOrderKey) {
        return payOrders[_index];
    }

     
    function getPaidInfo(string _payOrderKey) public view isCORRFormat(_payOrderKey) returns(string _payID, uint256 _payAmt){
        PayOrder memory payOrder;
        payOrder = payOrderMap[_payOrderKey];
        return (payOrder.payID, payOrder.payAmt);
    }

     
    function() public payable {
        require(msg.value > 0, "");
        walletAddr.transfer(msg.value);
        emit WithdrawalEther(walletAddr, msg.value);
    }

}