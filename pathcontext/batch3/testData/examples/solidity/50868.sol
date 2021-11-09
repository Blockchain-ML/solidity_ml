pragma solidity ^0.4.24;

 
 
 
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract EscrowManager {

     

    uint public numberOfSuccessfullExecutions;

     
    struct Escrow {
        address creator;           
        uint amountTokenSell;      
        address tokenAddressSell;  
        uint amountTokenBuy;       
        address tokenAddressBuy;   
    }

    mapping (address => mapping (address => Escrow[])) allOrders;  

    enum EscrowState{
        Created,        
        Accepted,       
        Completed,      
        Died            
    }

     


     

    event EscrowManagerInitialized();                
    event EscrowCreated(EscrowState escrowState);    
    event EscrowAccepted(EscrowState escrowState);   
    event EscrowCompleted(EscrowState escrowState);  
    event EscrowDied(EscrowState escrowState);       

     


     

     
     
     
     
     
    modifier onlyValidEscrowId(address _tokenAddressSell, address _tokenAddressBuy, uint escrowId){
        require(
            allOrders[_tokenAddressSell][_tokenAddressBuy].length > escrowId,  
            "Invalid Escrow Order!"                                            
        );
        _;
    }

     
     
     
     
    modifier onlyNonZeroAmts(uint sellTokenAmount, uint buyTokenAmount){
        require(
            sellTokenAmount > 0 && buyTokenAmount > 0,  
            "Escrow order amounts are 0!"               
        );
        _;
    }

     


     

     
    function EscrowManager() {
        numberOfSuccessfullExecutions = 0;
        EscrowManagerInitialized();
    }

     
     
     
     
     
     
     
     
    function createEscrow(address _tokenAddressSell, uint _amountTokenSell,
                          address _tokenAddressBuy, uint _amountTokenBuy)
        payable
        onlyNonZeroAmts(_amountTokenSell, _amountTokenBuy)
    {

        Escrow memory newEscrow = Escrow({        
            creator: msg.sender,                  
            amountTokenSell: _amountTokenSell,    
            tokenAddressSell: _tokenAddressSell,  
            amountTokenBuy: _amountTokenBuy,      
            tokenAddressBuy: _tokenAddressBuy     
        });

        ERC20Interface(_tokenAddressSell).transferFrom(msg.sender, this, _amountTokenSell);  
        allOrders[_tokenAddressSell][_tokenAddressBuy].push(newEscrow);                      
        EscrowCreated(EscrowState.Created);                                                  
    }

     
     
     
     
     
     
     
    function acceptEscrow(address _tokenAddressSell, address _tokenAddressBuy, uint escrowId)
        payable
        onlyValidEscrowId(_tokenAddressSell, _tokenAddressBuy, escrowId)
    {
        Escrow memory chosenEscrow = allOrders[_tokenAddressSell][_tokenAddressBuy][escrowId];                     
        ERC20Interface(chosenEscrow.tokenAddressBuy).transferFrom(msg.sender, this, chosenEscrow.amountTokenBuy);  
        EscrowAccepted(EscrowState.Accepted);                                                                      
        executeEscrow(chosenEscrow, msg.sender);                                                                   
        escrowDeletion(_tokenAddressSell, _tokenAddressBuy, escrowId);                                             
    }

     
     
     
     
     
     
    function executeEscrow(Escrow escrow, address buyer)
        private
    {
        ERC20Interface(escrow.tokenAddressBuy).transfer(escrow.creator, escrow.amountTokenBuy);  
        ERC20Interface(escrow.tokenAddressSell).transfer(buyer, escrow.amountTokenSell);         
        numberOfSuccessfullExecutions++;                                                         
        EscrowCompleted(EscrowState.Completed);                                                  
    }

     
     
     
     
     
     
     
    function escrowDeletion(address _tokenAddressSell, address _tokenAddressBuy, uint escrowId)
        private
    {
        for(uint i=escrowId; i<allOrders[_tokenAddressSell][_tokenAddressBuy].length-1; i++){                         
            allOrders[_tokenAddressSell][_tokenAddressBuy][i] = allOrders[_tokenAddressSell][_tokenAddressBuy][i+1];  
        }
        allOrders[_tokenAddressSell][_tokenAddressBuy].length--;                                                      
        EscrowDied(EscrowState.Died);                                                                                 
    }

     


     

     
     
     
     
     
     
     
    function getOrderBook(address _tokenAddressSell, address _tokenAddressBuy)
        constant returns (uint[] sellAmts, uint[] buyAmts)
    {
        Escrow[] memory escrows = allOrders[_tokenAddressSell][_tokenAddressBuy];  
        uint numEscrows = escrows.length;                                          
        uint[] memory sellAmounts = new uint[](numEscrows);                        
        uint[] memory buyAmounts = new uint[](numEscrows);                         
        for(uint i = 0; i < numEscrows; i++){                                      
            sellAmounts[i] = escrows[i].amountTokenSell;                           
            buyAmounts[i] = escrows[i].amountTokenBuy;                             
        }
        return (sellAmounts, buyAmounts);                                          
    }

     

}