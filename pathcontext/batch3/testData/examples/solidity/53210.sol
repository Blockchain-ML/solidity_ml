pragma solidity ^0.4.24;

library SafeMath {

   
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
     
     
     
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

   
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
     
     
     
    return _a / _b;
  }

   
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

   
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract Test {
    using SafeMath for uint256;
    
    uint256 public kickOff;
    
    uint256[] periods;
    uint8[] percentages;
    
    constructor() public {
        kickOff = 0;
        
        periods.push(120);
        periods.push(180);
        periods.push(240);
        periods.push(320);
        periods.push(380);
        
        percentages.push(5);
        percentages.push(10);
        percentages.push(15);
        percentages.push(20);
        percentages.push(50);
    }
    
    function start() public returns (bool) {
        kickOff = now + 60 * 5;
    }
    
    function getUnlockedPercentage() public view returns (uint256, uint256) {
        if (kickOff == 0 ||
            kickOff > now)
        {
            return (100, 123);
        }
        
        uint256 unlockedPercentage = 0;
        for (uint256 i = 0; i < periods.length; i++) {
            if (kickOff + periods[i] <= now) {
                unlockedPercentage = unlockedPercentage.add(percentages[i]);
            }
        }
        
        if (unlockedPercentage > 100) {
            return (0, 123);
        }
        
        return (100 - unlockedPercentage, ((now - kickOff) / 60));
    }
    
    function getPeriods() public view returns (uint256[]) {
        return periods;
    }
    
    function getPercentages() public view returns (uint8[]) {
        return percentages;
    }
    
    function getNow() public view returns (uint256) {
        return now;
    }
}