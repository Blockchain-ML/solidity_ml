 

pragma solidity ^0.5.0;



library SafeMath {
     
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) public pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) public pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) public pure returns (uint256) {
         
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract crowdsale{
    using SafeMath for uint256;
    
    uint256 private OpenTime;
    uint256 private CloseTime;
    
    uint256 private  _rate;
    address payable private  _wallet;
    uint256 private weiRaised;
    uint256 private weiAmount;
    
    modifier TimeSpan(){
      require(block.timestamp > OpenTime && block.timestamp < CloseTime);
      _;
    }
   
    
      
    constructor() public{
     
        _rate = 4;
        _wallet = msg.sender;
        OpenTime = 1562672544;
        CloseTime = 1562704301;
    }
    
    
    event _buyTokens(uint256 tokens,address beneficiary);
    uint256 public  NumberOftokens;
    address public  beneficiary;
    
     
    function buyTokens(address _beneficiary) public payable TimeSpan returns(bool){
        
        weiAmount = msg.value;
        require((weiAmount * _rate).div(1e18 wei) > 0,"Number Of Tokens Cant be Zero or less than one");  
        weiRaised += weiAmount;
        NumberOftokens = 0;
        NumberOftokens = (weiAmount * _rate).div(1e18 wei);
        beneficiary = _beneficiary;
        return true;
    
    }
    
    function GetBeneficiaryInfo() public view returns (uint256,address){
        return (NumberOftokens,beneficiary);
    }
    
    function fundsTransfer() public payable
    {
        _wallet.transfer(weiAmount);
    }
    
    
}