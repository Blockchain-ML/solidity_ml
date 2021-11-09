pragma solidity ^0.4.21;






contract PoCGame
{
    
     
     
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }
    
   modifier isOpenToPublic()
    {
        require(openToPublic);
        _;
    }

    modifier onlyRealPeople()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  onlyPlayers()
    { 
        require (wagers[msg.sender] > 0); 
        _; 
    }
    
   
     
    event Bet(uint256 amount, address depositer);
    event Payout(uint256 amount, address paidTo);
    event PayWhale(uint256 amount, address paidTo);

     
    address owner;
    PoCWHALE whale;
     
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openToPublic;
    uint256 totalDonated;

     
    constructor(address whaleAddress) 
    onlyRealPeople()
    public 
    {
        openToPublic = false;
        owner = msg.sender;
        whale = PoCWHALE(whaleAddress);
        totalDonated = 0;
    }


     
    function OpenToThePublic() 
    onlyOwner()
    public
    {
        openToPublic = true;
    }
    
    function() 
    public 
    payable { }

     
    function wager()
    isOpenToPublic()
    onlyRealPeople() 
    payable
    public 
    {
         
        require(msg.value == 1000000000000000);

         
        timestamps[msg.sender] = block.number;
        wagers[msg.sender] = msg.value;
        emit Bet(msg.value, msg.sender);
    }
    
     
    function play()
    isOpenToPublic()
    onlyRealPeople()
    onlyPlayers()
    public
    {
        uint256 blockNumber = timestamps[msg.sender];
        timestamps[msg.sender] = 0;

        uint256 winningNumber = uint256(keccak256(blockhash(blockNumber),  msg.sender))%300 +1;

        if(winningNumber > 100 && winningNumber < 200)
        {
            payout(msg.sender);
        }
        else 
        {
             
            donateToWhale(500000000000000);
        }                 
    }

     
    function donate()
    isOpenToPublic()
    public 
    payable
    {
        donateToWhale(msg.value);
    }

     
    function payout(address winner) 
    internal 
    {
        uint256 ethToTransfer = address(this).balance / 2;
        
        winner.transfer(ethToTransfer);
        emit Payout(ethToTransfer, winner);
    }

     
    function donateToWhale(uint256 amount) 
    internal 
    {
        
        
        whale.donate.value(amount)();
        totalDonated += amount;
        emit PayWhale(amount, whale);
    }

     
    function ethBalance() 
    public 
    view 
    returns (uint256)
    {
        return address(this).balance;
    }

     
    function winnersPot() 
    public 
    view 
    returns (uint256)
    {
        return address(this).balance / 2;
    }

     
    function transferAnyERC20Token(address tokenAddress, address tokenOwner, uint tokens) 
    public 
    onlyOwner() 
    returns (bool success) 
    {
        return ERC20Interface(tokenAddress).transfer(tokenOwner, tokens);
    }
}

 
contract PoCWHALE 
{
    function donate() payable public; 
}

 
contract ERC20Interface 
{
    function transfer(address to, uint256 tokens) public returns (bool success);
}