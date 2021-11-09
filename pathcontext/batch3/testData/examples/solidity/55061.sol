pragma solidity ^0.4.24;

 
 
 
 
 
 
 

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract ALH {
     
    string public name = "ALOHA";
    string public symbol = "ALH";
    uint8 public decimals = 18;
     
    uint256 public totalSupply;
    uint256 public tokenSupply = 200000000;
    uint public bonus1;
    uint public bonus2;
    uint public bonus3;
    
    address public creator;
     
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
     
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    
     
    function ALH() public {
        totalSupply = tokenSupply * 10 ** uint256(decimals);   
        balanceOf[msg.sender] = totalSupply;     
        creator = msg.sender;
        bonus1 = now + 13 days;
        bonus2 = now + 23 days;
        bonus3 = now + 43 days;
    }
     
    function _transfer(address _from, address _to, uint _value) internal {
         
        require(_to != 0x0);
         
        require(balanceOf[_from] >= _value);
         
        require(balanceOf[_to] + _value >= balanceOf[_to]);
         
        balanceOf[_from] -= _value;
         
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
      
    }

     
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    
    
     
    function () payable internal {
        uint amount;                   
        uint amountRaised;

        if (now <= bonus1) {
            amount = msg.value * 15000;
        } else if (now > bonus1 && now <= bonus2) {
            amount = msg.value * 13000;
        } else if (now > bonus2 && now <= bonus3) {
            amount = msg.value * 12000;
        } else if (now > bonus3) {
            amount = msg.value * 10000;
        }
        

                                             
        amountRaised += msg.value;                             
        require(balanceOf[creator] >= amount);                
        balanceOf[msg.sender] += amount;                   
        balanceOf[creator] -= amount;                         
        Transfer(creator, msg.sender, amount);                
        creator.transfer(amountRaised);
    }

 }