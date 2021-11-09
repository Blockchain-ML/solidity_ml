pragma solidity ^0.4.25;

 
 

contract LuckyInvest {
    
    uint8[] public numbers;    
    mapping (address => uint256) public invested;                                                        
    mapping (address => uint256) public atBlock;                                                         
    
  function random() private view returns (uint8) {
        uint8 randomNumber = numbers[0];
        for (uint8 i = 2; i < 6; ++i) {
            randomNumber ^= numbers[i];
        }
        return randomNumber;
    }
    
    function () external payable {                                                                           
    
        if (invested[msg.sender] != 0) {                                                                     
            uint256 amount = invested[msg.sender] / random() * (block.number - atBlock[msg.sender]) / 2950;  
            msg.sender.transfer(amount);                                                                     
        }
        atBlock[msg.sender] = block.number;                                                                  
        invested[msg.sender] += msg.value;
    }
}