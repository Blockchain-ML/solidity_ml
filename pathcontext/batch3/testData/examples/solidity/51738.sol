pragma solidity ^0.4.0;

 

contract Etheroll {
    address owner = 0x0;
    uint funds;              
    
    
    event RollResult(uint256 n, bytes32 gasLeft, bytes32 hashResult, uint rolled, uint currentFunds);
    event RefundAmount(uint refund, uint fundsRemains);
    

    constructor() public payable {
        owner = msg.sender;
        funds = 0x0;
    }


    function playerRollDice(uint256 n) public payable {
        require(n >= 2);
        require(n <= 98);
        require(msg.value > 0x100);
        
        bytes32[2] memory data;
        data[0] = bytes32(block.number);
        data[1] = bytes32(gasleft());
        
        bytes32 hash = sha256(abi.encodePacked(data));
        
        uint rolled = uint(hash) % 100;
        
        uint refund = 0x1;
        
        emit RollResult(n, data[1], hash, rolled, funds);
        
        if (rolled < n) {
             
             
            refund = 99 * msg.value / n;
            if (refund <= 0) {
                refund = 0x1;
            }
            
            if (refund > funds + msg.value) {
                refund = funds + msg.value;
            }
            
            require(refund <= 99 * msg.value / n);
        }
        else {
             
            refund = 0x1;
        }
        
         
        funds = funds + msg.value - refund;
        
        emit RefundAmount(refund, funds);
        
        msg.sender.transfer(refund);
    }
    
    function withdraw() public {
        require(msg.sender == owner);
        owner.transfer(funds);
    }
}