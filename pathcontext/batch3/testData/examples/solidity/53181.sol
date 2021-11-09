pragma solidity 0.4.24;

contract FraCoinAuct {
    struct store 
    {
        bool voted ; 
        uint weight ; 
    }
    
    struct vote 
    {
        address voter; 
        uint8 votedAmount ;
    }
    
    vote[] public votes;
    
    address public _FraCoin ;                 
    address public _CoinOwner ;               
    address public owner ;                    
                            
    string public Name ;                      
    
    uint public CoinsToBeAuctioned;           
    uint public numElements;                  
    
    mapping (address => store) public stores ;
    

    
    function FraCoinAuct (string AuctName ,uint Coins , address addr) public
    {   
        owner = msg.sender; 
        _FraCoin = addr ; 
        StartAuction(AuctName,Coins); 
   }
    
    function StartAuction (string AuctName ,uint Coins ) public
    {
        Name = AuctName ; 
        
        CoinsToBeAuctioned = Coins ; 
        numElements = 0 ; 
        mintCoins(CoinsToBeAuctioned);                                 
  
    }
    
    function EndAuction () public
    {
        uint maxProStore; 
        uint remainingCoins;
        require (msg.sender == owner) ; 
         
        
        maxProStore = CoinsToBeAuctioned / numElements; 
        FraCoin FRC = FraCoin(_FraCoin) ;
        
        for (uint i = 0 ; i < numElements; i++)
        {
            if (votes[i].votedAmount > maxProStore) 
            {    
                FRC.TransferCoinsFrom (owner, votes[i].voter,votes[i].votedAmount);
            } 
            if (votes[i].votedAmount < maxProStore) 
            {    
                FRC.TransferCoinsFrom (owner, votes[i].voter,votes[i].votedAmount);
                remainingCoins = remainingCoins + (maxProStore - votes[i].votedAmount); 
            }
        }
       
    }
    
    function authorizeStore (address _store) public
    {
        require (owner == msg.sender) ; 
        require (!stores[_store].voted) ;
        
        stores[_store].weight = 1 ; 
    }
    
    function bid (uint8 amount) public 
    {
        require (stores[msg.sender].weight == 1) ; 
   
        
        votes.push(vote(msg.sender,amount)); 
        
        numElements = numElements + 1 ; 
        stores[msg.sender].voted = true ; 

    }
    
    function mintCoins (uint amount) public
    {
        FraCoin FRC = FraCoin(_FraCoin) ;                
        FRC.mintIfNecessary(amount) ;        
    }
    
}


    contract FraCoin 
    {
        function mintIfNecessary (uint amount) public; 
        function TransferCoinsFrom (address _from, address _to, uint8 amount) public; 
    }