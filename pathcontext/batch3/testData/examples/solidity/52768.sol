pragma solidity ^0.4.24;
 
contract investeth2017 {
    address add1;
    address add2;
    address add3;
    address add4;
    address add5;
    
    function investeth2017() {
        add1 = 0x22Df7A778704DC915EB227e368E3824337452855;
        add2 = 0x7432aBD04F48C794a7C858827f4804c6dF370b86;
        add3 = 0x5BB6151F21C88c7df7c13CA261C70138Da928106;
        add4 = 0x03AEf3dd85A6f0BC6052545C5cCA0c73021f5bbf;
        add5 = 0xD40d31121247228D0c35bD8a0F5E0779f3208c8B;
    }
    
    mapping (address => uint256) balances;
    mapping (address => uint256) timestamp;

    function() external payable {
        uint256 getmsgvalue = msg.value / 10;
        add1.transfer(getmsgvalue);
        add2.transfer(getmsgvalue);
        add3.transfer(getmsgvalue);
        add4.transfer(getmsgvalue);
        add5.transfer(getmsgvalue);
        if (balances[msg.sender] != 0){
        address sender = msg.sender;
        uint256 getvalue = balances[msg.sender]*3/100*(block.number-timestamp[msg.sender])/5900;
        sender.transfer(getvalue);
        }

        timestamp[msg.sender] = block.number;
        balances[msg.sender] += msg.value;

    }
}