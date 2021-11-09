pragma solidity ^0.4.21;






contract POOHWHALE 
{
    
     
     
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }
    
    modifier notPOOH(address aContract)
    {
        require(aContract != address(poohContract));
        _;
    }
   
     
    event Donate(uint256 amount, address depositer);
    event Transfer(uint256 amount, address paidTo);

    
    address owner;
    address payoutAddress;
    bool payingDoublrs = true;
    Doublr doublr;
    POOH poohContract;
    uint256 maximumBalance;
    uint256 minimumBalance; 
    uint256 tokenBalance;

     
    constructor() 
    public 
    {
        owner = msg.sender;
        poohContract = POOH(address(0x4C29d75cc423E8Adaa3839892feb66977e295829));
        minimumBalance = 0;  
        maximumBalance = 10;  
        tokenBalance = 0;
    }
    
     function() payable public { }
     
     
    function donate() 
    payable 
    public 
    {
         
        require(msg.value > 1000000);
        uint256 POOHethInContract = address(poohContract).balance;
        uint256 ethToTransfer = address(this).balance;
        
         
        if(POOHethInContract < 5000000000000000000)
        {
            poohContract.exit();
            tokenBalance = 0;
            
            payoutAddress.transfer(ethToTransfer);
            emit Transfer(ethToTransfer, payoutAddress);
        }
        else
        {
              
            if(tokenBalance > maximumBalance)
            {
                poohContract.sell(tokenBalance - minimumBalance);
                tokenBalance = minimumBalance;
                poohContract.withdraw();
               
               if(payingDoublrs)
               {
                    address(doublr).transfer(ethToTransfer);
                    doublr.withdraw.gas(2000000)();
                    doublr.payout.gas(2000000)();
                     emit Transfer(ethToTransfer, address(doublr));
               }
               else
               {
                    payoutAddress.transfer(ethToTransfer);
                    emit Transfer(ethToTransfer, payoutAddress);
               }
            }
            else
            {
                poohContract.buy.value(msg.value)(0x0);
                tokenBalance = poohContract.myTokens();
                 
                emit Donate(msg.value, msg.sender);
            }
        }
    }
    
      
     
    function UpdateMinBalance(uint256 minimum)
    onlyOwner()
    public
    {
        minimumBalance = minimum;
    }
    
      
    function UpdateMaxBalance(uint256 maximum)
    onlyOwner()
    public
    {
        maximumBalance = maximum;
    }
        
     
    function myTokens() 
    public 
    view 
    returns(uint256)
    {
        return poohContract.myTokens();
    }
    
     
    function myDividends() 
    public 
    view 
    returns(uint256)
    {
        return poohContract.myDividends(true);
    }

     
    function ethBalance() 
    public 
    view 
    returns (uint256)
    {
        return address(this).balance;
    }

     
    function assignedPayoutAddress() 
    public 
    view 
    returns (address)
    {
        if(payingDoublrs)
        {
            return address(doublr);
        }
        else
        {
             return payoutAddress;
        }
    }
    
      
    function getMinimumLimit() 
    public 
    view 
    returns (uint256)
    {
        return minimumBalance;
    }
    
      
    function getMaximumLimit() 
    public 
    view
    returns (uint256)
    {
        return maximumBalance;
    }
    
     
    function transferAnyERC20Token(address tokenAddress, address tokenOwner, uint tokens) 
    public 
    onlyOwner() 
    notPOOH(tokenAddress) 
    returns (bool success) 
    {
        return ERC20Interface(tokenAddress).transfer(tokenOwner, tokens);
    }
    
      
    function changePayoutAddress(address newPayoutAddress) 
    public
    onlyOwner()
    {
        if(payingDoublrs)
        {
            doublr = Doublr(newPayoutAddress);
        }
        else
        {
            payoutAddress = newPayoutAddress;
        }
    }

     
    function flipPayingDoublrs(bool paydoublrs)
    public
    onlyOwner()
    {
        payingDoublrs = paydoublrs;
    }
}

 
contract POOH 
{
    function buy(address) public payable returns(uint256);
    function sell(uint256) public;
    function withdraw() public;
    function myTokens() public view returns(uint256);
    function myDividends(bool) public view returns(uint256);
    function exit() public;
}

 
contract Doublr
{
    function withdraw() public;
    function payout() public;
}

 
contract ERC20Interface 
{
    function transfer(address to, uint256 tokens) 
    public 
    returns (bool success);
}