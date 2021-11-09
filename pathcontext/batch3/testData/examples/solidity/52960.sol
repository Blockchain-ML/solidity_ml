pragma solidity ^0.4.25;

 
library SafeMath {
     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        require(b > 0);
        uint256 c = a / b;
         
        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface tokenReward {
    function mint(address receiver, uint amount) external;
    function transferOwnership(address newOwner) external;
}

 
contract Crowdsale {
    using SafeMath for uint;
    
    uint private million = 1000000;
    uint private decimals = 18;

     
    tokenReward private token;
    
    address private owner;
    address private constant fundsWallet = 0xD8CAb37A560D8B22104508ac42bd045a5Abcb2E7; 
    address private constant tokenWallet = 0xf8Fab9fa6C154bd2A59035283AD508705aa49641; 
    
    uint private start;
    uint private finish;

    uint private tokensPerEth;
    
    uint private tokensReserved = 65 * million * 10 ** uint256(decimals);
    uint private tokensCrowdsaled = 0;
    uint private tokensLeft = 90 * million * 10 ** uint256(decimals);
    uint private tokensTotal = 155 * million * 10 ** uint256(decimals);
    
    event Mint(address indexed to, uint value);
    event SaleFinished(address target, uint amountRaised);
    
     
    constructor(
        address addressOfTokenUsedAsReward,
        uint UnixTimestampOfICOStart, 
        uint UnixTimestampOfICOEnd, 
        uint _tokensPerEth
    ) public {
        owner = msg.sender;
        token = tokenReward(addressOfTokenUsedAsReward);
        start = UnixTimestampOfICOStart;
        finish = UnixTimestampOfICOEnd;
        tokensPerEth = _tokensPerEth;
    }
    

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
     
    modifier saleIsOn() {
    	require(now >= start && now <= finish);
    	_;
    }
    
         
    modifier isUnderHardCap() { 
        require(getTokensReleased() <= tokensTotal);  
        _;
    }
    
     

     
    function getAddressOfTokenUsedAsReward() constant public returns(address){
        return token;
    } 
    
     
    function getTokensCrowdsaled() constant public returns(uint){
        return tokensCrowdsaled;
    }
    
      
    function getTokensLeft() constant public returns(uint){
        return tokensLeft;
    }
    
      
    function getOwner() constant public returns(address){
        return owner;
    }
    
     
    function getStart() constant public returns(uint){
        return start;
    }
    
     
    function getFinish() constant public returns(uint){
        return finish;
    }
    
      
    function getTokensPerEth() constant public returns(uint){
        return tokensPerEth;
    }
    
     

     
    function setStart(uint newStart) onlyOwner public {
        start = newStart; 
    }
    
     
    function setFinish(uint newFinish) onlyOwner public {
        finish = newFinish; 
    }
    
     
    function setTokensPerEth(uint _tokensPerEth) onlyOwner public {
        tokensPerEth = _tokensPerEth; 
    }
    
    
     
     
    function getTokensReleased() constant public returns(uint){
        return tokensReserved + tokensCrowdsaled;
    }
    
     
    function getIfBonus() constant public returns(bool){
        return (getTokensCrowdsaled() < 50 * million * 10 ** uint256(decimals));
    }
    

      
    function setICOIsFinished() onlyOwner public {
        token.mint(tokenWallet, tokensLeft);
        tokensLeft = 0;
        emit SaleFinished(fundsWallet, getTokensReleased());
    }
    
     
    function transferOwnership() onlyOwner public{
        token.transferOwnership(owner);
    }
    
     
    function mintReserve() onlyOwner public  {
        token.mint(tokenWallet, tokensReserved);
    }
    
     
    function() isUnderHardCap saleIsOn public payable {
        
        require(msg.sender != 0x0);
        
         
        require(msg.value >= 3 ether);
        fundsWallet.transfer(msg.value);
        
         
        uint firstFifty = 50 * million * 10 ** uint256(decimals);
        uint amount = msg.value;
        uint tokensToMint = 0;

        tokensToMint = amount.mul(tokensPerEth);
        
         
        if (tokensCrowdsaled.add(tokensToMint) <= firstFifty){
            tokensToMint = tokensToMint.mul(11).div(10); 
        }
        
        token.mint(msg.sender, tokensToMint);
        emit Mint(msg.sender, tokensToMint);
        
        tokensLeft = tokensLeft.sub(tokensToMint);
        tokensCrowdsaled = tokensCrowdsaled.add(tokensToMint);
    }

}