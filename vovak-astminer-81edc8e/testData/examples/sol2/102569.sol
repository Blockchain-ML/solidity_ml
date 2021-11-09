pragma solidity ^0.6.0;
 

 
 
 

 
 
 

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
    
    function ceil(uint a, uint m) internal pure returns (uint r) {
        return (a + m - 1) / m * m;
    }
}

 
 
 
interface IFORMS {
    function transfer(address to, uint256 tokens) external returns (bool success);
    function setTokenLock (uint256 lockedTokens, uint256 cliffTime, address purchaser) external;
    function burnTokens(uint256 _amount) external;
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
}

contract FORMS_SALE_1{
    
    using SafeMath for uint256;
    
    string public tokenPrice = '0.000128 ether';
    address public FORMS_TOKEN_ADDRESS;
    uint256 public saleEndDate = 0;
    address payable owner = 0xA6a3E445E613FF022a3001091C7bE274B6a409B0;
    modifier onlyOwner {
        require(owner == msg.sender, "UnAuthorized");
        _;
    }
    
    function setTokenAddress(address _tokenAddress) external onlyOwner{
        require(FORMS_TOKEN_ADDRESS == address(0), "TOKEN ADDRESS ALREADY CONFIGURED");
        FORMS_TOKEN_ADDRESS = _tokenAddress;
    }
    
    function startSale() external onlyOwner{
        require(saleEndDate == 0, "SALE ALREADY STARTED");
        saleEndDate = block.timestamp.add(2 days);
    }
    
    receive() external payable{
         
        require(saleEndDate > 0, "Sale has not started");
        
         
        require(msg.value >= 0.1 ether, "Not enough investment");
        
        uint256 remainingSaleTokens = IFORMS(FORMS_TOKEN_ADDRESS).balanceOf(address(this));
        
         
        if(remainingSaleTokens > 0 && block.timestamp > saleEndDate)
            IFORMS(FORMS_TOKEN_ADDRESS).burnTokens(remainingSaleTokens);
            
         
        require(IFORMS(FORMS_TOKEN_ADDRESS).balanceOf(address(this)) > 0, "Sale is finished");
        
         
        uint tokens = getTokenAmount(msg.value);
        
         
        IFORMS(FORMS_TOKEN_ADDRESS).transfer(msg.sender, tokens);
        
         
        IFORMS(FORMS_TOKEN_ADDRESS).setTokenLock(tokens, saleEndDate.add(24 hours), msg.sender);
        
         
        owner.transfer(msg.value);
    }
    
    function getTokenAmount(uint256 amount) private pure returns(uint256){
        return amount.mul(7812);  
    }
}