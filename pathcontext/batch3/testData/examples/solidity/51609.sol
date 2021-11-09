pragma solidity ^0.4.25;

library SafeMath {
   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function mul(uint256 a, uint256 b) 
      internal 
      pure 
      returns (uint256 c) 
  {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    require(c / a == b, "SafeMath mul failed");
    return c;
  }

   
  function sub(uint256 a, uint256 b)
      internal
      pure
      returns (uint256) 
  {
    require(b <= a, "SafeMath sub failed");
    return a - b;
  }

   
  function add(uint256 a, uint256 b)
      internal
      pure
      returns (uint256 c) 
  {
    c = a + b;
    require(c >= a, "SafeMath add failed");
    return c;
  }
  
   
  function sqrt(uint256 x)
      internal
      pure
      returns (uint256 y) 
  {
    uint256 z = ((add(x,1)) / 2);
    y = x;
    while (z < y) 
    {
      y = z;
      z = ((add((x / z),z)) / 2);
    }
  }
  
   
  function sq(uint256 x)
      internal
      pure
      returns (uint256)
  {
    return (mul(x,x));
  }
  
   
  function pwr(uint256 x, uint256 y)
      internal 
      pure 
      returns (uint256)
  {
    if (x==0)
        return (0);
    else if (y==0)
        return (1);
    else 
    {
      uint256 z = x;
      for (uint256 i=1; i < y; i++)
        z = mul(z,x);
      return (z);
    }
  }
}

contract TomoRoll{
    address public admin;
    uint256 sizebet;
    uint256 win;
    uint256 _seed = now;
    event BetResult(
    address from,
    uint256 betvalue,
    uint256 prediction,
    uint8 luckynumber,
    bool win,
    uint256 wonamount
    );
    
    event LuckyDrop(
    address from,
    uint256 betvalue,
    uint256 prediction,
    uint8 luckynumber,
    string congratulation
    );
    
    event Shake(
    address from,
    bytes32 make_chaos
    );
    
    constructor() public{
        admin = 0xc69d39d0681D74A2b24F36965e3e43aBDEf638F0;
    }
    
    function random() private view returns (uint8) {
        return uint8(uint256(keccak256(block.timestamp, block.difficulty, _seed))%100);  
    }

    function bet(uint8 under) public payable{
        require(msg.value >= 1000000000000000);
        require(under > 0 && under < 96);
        sizebet = msg.value;
        win = uint256 (sizebet*98/under);
        uint8 _random = random();
        
        if (_random < under) {
            if (msg.value*98/under < address(this).balance) {
                msg.sender.transfer(win);
                emit BetResult(msg.sender, msg.value, under, _random, true, win);
            }
            else {
                msg.sender.transfer(address(this).balance);
                emit BetResult(msg.sender, msg.value, under, _random, true, address(this).balance);
            }
        } else {
            emit BetResult(msg.sender, msg.value, under, _random, false, 0x0);
        }
    }
    

    modifier onlyAdmin() {
         
        require(msg.sender == admin);
        _;
    }
    
    function withdrawEth(address to, uint256 balance) onlyAdmin {
        if (balance == uint256(0x0)) {
            to.transfer(address(this).balance);
        } else {
            to.transfer(balance);
        }
    }
    
    function shake(uint256 choose_a_number_to_chaos_the_algo) public {
        _seed = uint256(keccak256(choose_a_number_to_chaos_the_algo));
        emit Shake(msg.sender, "You changed the algo");
    }
    
}