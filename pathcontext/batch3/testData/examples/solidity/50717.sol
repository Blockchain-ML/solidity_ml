pragma solidity ^0.4.20;


contract Investors {
     
 
    modifier onlyAdmin(){
        require(msg.sender == ADMINISTRATOR);
        _;
    }
    
     
    event onWithdraw(
        address customerAddress,
        uint256 amount
    );
    
     
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
    
    
     
    string public name = "S3DInvestors";
    string public symbol = "S3DInvestors";
    address private ADMINISTRATOR;
    
        
    
    
    struct investor 
    {   
        address walletAddress;
        uint256 percent;
    }
    mapping(int256 => investor) internal investors_;
    address companyWallet = address(0xB789A1C6e916B20771583aB3Aa8341b054e2CCF9);
    address S3DContract;

     
     
    constructor()
        public
    {
        ADMINISTRATOR = address(msg.sender);

         
        investors_[0] = investor({walletAddress: address(0x6b9aB2e66f55B81f68Ed66787C3D47ae3EBcFED9), percent: 20});  
        investors_[1] = investor({walletAddress: address(0xc53b3878b2c8f7bbc33b9a2f6ec30d7d7cff23b2), percent: 20});  
        investors_[2] = investor({walletAddress: address(0xEb7741354A5682A1a0c4196C842a648Dd7D53E53), percent: 15});  
        investors_[3] = investor({walletAddress: address(0xf028a085e78c93FC2E549B8A4EfE5A08A453C86D), percent: 15});  
        investors_[4] = investor({walletAddress: address(0x074F21a36217d7615d0202faA926aEFEBB5a9999), percent: 10});  
        investors_[5] = investor({walletAddress: companyWallet, percent: 20});  
    }
    
    
     
    function()
        payable
        public
    {
        distributeRewards(msg.value);
    }
    
     
   
     
    function withdraw(uint256 withdrawAmount)
        onlyAdmin()
        public
    {
        require(withdrawAmount < address(this).balance && withdrawAmount > 0.01 ether);
        
        companyWallet.transfer(withdrawAmount);
        
         
        emit onWithdraw(companyWallet, withdrawAmount);
    }
  

    
     

      
    function distributeRewards(uint256 rewards)
        payable
        public
    {   
        require(rewards > 10000 wei);

        uint256 percent1 = (investors_[0].percent * rewards) / 100;
        uint256 percent2 = (investors_[1].percent * rewards) / 100;
        uint256 percent3 = (investors_[2].percent * rewards) / 100;
        uint256 percent4 = (investors_[3].percent * rewards) / 100;
        uint256 percent5 = (investors_[4].percent * rewards) / 100;

        investors_[0].walletAddress.transfer(percent1);
        investors_[1].walletAddress.transfer(percent2);
        investors_[2].walletAddress.transfer(percent3);
        investors_[3].walletAddress.transfer(percent4);
        investors_[4].walletAddress.transfer(percent5);
        investors_[5].walletAddress.transfer(address(this).balance);
    }
    
     
    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return address(this).balance;
    }
   
}