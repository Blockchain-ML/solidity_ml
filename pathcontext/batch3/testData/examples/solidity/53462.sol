pragma solidity 0.4.24;
contract TokenMaster
{
    address public owner;
    
    uint256 public tokenCostInEth = 0.001 ether;
    uint256 public actualTokenValue = 0.00095 ether;
    uint256 public devCut = 0.00005 ether;
    
    mapping(address => uint256) public allTokens;
    uint256 public tokenSupply;
    address[] allAddresses;
    
    address devAddress = 0xcd7c53462067f0d0b8809be9e3fb143679a270bb;
    
      
    event MyTokens(uint256 tokens);
    event SentTokens(bool didSend);
    
      
    
    constructor() public
    {
       owner = msg.sender; 
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function buyTokens(uint256 _amount) public payable
    {
        require(_amount * tokenCostInEth == msg.value);  
        require(tokenSupply >= _amount);    
        
        if(allTokens[msg.sender] == 0)
            allAddresses.push(msg.sender);
        
        devAddress.transfer(devCut);  
        
        allTokens[msg.sender] += _amount;
        tokenSupply -= _amount;
        
    }
    
    function stockSupply(uint256 _amount) public payable onlyOwner
    {
        require(_amount * tokenCostInEth == msg.value);  
        
        tokenSupply += _amount;
    }
    
    function cashOut() public 
    {
        require(allTokens[msg.sender] != 0);     
        
        uint256 amountToCashOut = allTokens[msg.sender];
        msg.sender.transfer(amountToCashOut * actualTokenValue);
        allTokens[msg.sender] = 0;
    }
    
    function payTokens(uint256 _amount) external 
    {
        require(_amount > 0);
        require(allTokens[msg.sender] >= _amount);
        
        allTokens[msg.sender] -= _amount;
        tokenSupply += _amount;
        
        emit SentTokens(true);
    }
    
     
     
    function winTokens(uint256 _amount, address _whoWon) external 
    {
        require(tokenSupply >= _amount);
        
        tokenSupply-= _amount;
        allTokens[_whoWon] += _amount;
    }
    
        
    function changeDevAddress(address _newAddress) public onlyOwner
    {
        devAddress = _newAddress;
    }
    
     
     
     
     
     
     
     
     
     
     
     
     
    
     
    function changeTokenCostInEth(uint256 _costInEth) public onlyOwner
    {
        tokenCostInEth = _costInEth;
    }
    
     
    function changeActualTokenValue(uint256 _actualValue) public onlyOwner
    {
        actualTokenValue = _actualValue;
    }
    
     
    function changeDevCut(uint256 _devCut) public onlyOwner
    {
        devCut = _devCut;
    }
    
     
    function emptyContract() public onlyOwner
    {
         
         
         
         
         
        owner.transfer(address(this).balance);
        
         
        for(uint256 i = 0; i < allAddresses.length; i++)
        {
            allTokens[allAddresses[i]] = 0;
        }
        
        delete allAddresses;
        
         
        tokenSupply = 0;
        
    }

        
    function getMyTokens() external view returns(uint256)
    {
        emit MyTokens(allTokens[msg.sender]);
        return(allTokens[msg.sender]);
    }
    
    function getMyTokensReturns() external view returns(uint256)
    {
        return(allTokens[msg.sender]);
    }
    
    function getMyTokensEmits() external view
    {
        emit MyTokens(allTokens[msg.sender]);
    }
    
    function getTokensFromAddressReturns(address _address) external view returns(uint256)
    {
        return(allTokens[_address]);
    }
    
    function getTokensFromAddressEmits(address _address) external view
    {
        emit MyTokens(allTokens[_address]);
    }
    
    function getMyTokensValue() view public returns(uint256)
    {
        return(allTokens[msg.sender] * tokenCostInEth);
    }
    
}