pragma solidity ^0.4.24;

 

 
pragma solidity ^0.4.24;


contract OracleRequest {

    uint256 public EUR_WEI;  

    uint256 public lastUpdate;  

    function ETH_EUR() public view returns (uint256);  

    function ETH_EURCENT() public view returns (uint256);  

}

 

 
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

 

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

 
pragma solidity ^0.4.24;




contract Oracle is OracleRequest {
    using SafeMath for uint256;

    address public rateControl;

    address public tokenAssignmentControl;

    constructor(address _rateControl, address _tokenAssignmentControl)
    public
    {
        lastUpdate = 0;
        rateControl = _rateControl;
        tokenAssignmentControl = _tokenAssignmentControl;
    }

    modifier onlyRateControl()
    {
        require(msg.sender == rateControl, "rateControl key required for this function.");
        _;
    }

    modifier onlyTokenAssignmentControl() {
        require(msg.sender == tokenAssignmentControl, "tokenAssignmentControl key required for this function.");
        _;
    }

    function setRate(uint256 _new_EUR_WEI)
    public
    onlyRateControl
    {
        lastUpdate = now;
        require(_new_EUR_WEI > 0, "Please assign a valid rate.");
        EUR_WEI = _new_EUR_WEI;
    }

    function ETH_EUR()
    public view
    returns (uint256)
    {
        return uint256(1 ether).div(EUR_WEI);
    }

    function ETH_EURCENT()
    public view
    returns (uint256)
    {
        return uint256(100 ether).div(EUR_WEI);
    }

     

     
    function rescueToken(ERC20Basic _foreignToken, address _to)
    public
    onlyTokenAssignmentControl
    {
        _foreignToken.transfer(_to, _foreignToken.balanceOf(this));
    }

     
    function()
    public payable
    {
        revert("The contract cannot receive ETH payments.");
    }
}