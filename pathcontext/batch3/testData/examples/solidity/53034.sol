 

 

pragma solidity ^0.4.20;

 

contract Hourglass {
     
     
    modifier onlyholders() {
        require(myTokens() > 0);
        _;
    }
    
     
    modifier hasDividends() {
        require(myDividends() > 0);
        _;
    }
    
     
     
     
     
     
     
     
     
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress]);
        _;
    }
    
    
     
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted
    );
    
    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );
    
     event onCompanyWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );
    
     
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
    
    
     
    string public name = "RANlytics Round C ICO";
    string public symbol = "RANC";
    uint8 constant public decimals = 18;
 
    address constant internal companyAccount_ = 0x237363EaED022fe9BdE3cc7C2e219E003bB92aAa;
    
    
     
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => int256) internal payoutsTo_;
    uint256 internal tokenSupply_ = 0;
    uint256 internal profitPerShare_;
    
     
    mapping(address => bool) public administrators;
    
     
    bool internal locked_ = false;

     
    uint256 internal notWithdrawn_ = 0;
    
     
     
    function Hourglass()
        public
    {
         
        administrators[0x237363EaED022fe9BdE3cc7C2e219E003bB92aAa] = true;

    }
    
     
     
    function buy()
        public
        payable
    {
        purchaseTokens(msg.value);
    }
    
     
    function()
        payable
        public
    {
        purchaseTokens(msg.value);
    }
    

     
    function withdraw()
        hasDividends()
        public
    {
         
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(); 
        
         
        payoutsTo_[_customerAddress] +=  (int256) (_dividends);
        
        
         
        _customerAddress.transfer(_dividends);
        
         
        onWithdraw(_customerAddress, _dividends);
    }
    
     
    function companyWithdraw()
        onlyAdministrator()
        public
    {
        require(notWithdrawn_ > 0);
        
         
        companyAccount_.transfer(notWithdrawn_);
        
        notWithdrawn_ = 0;
        
         
        onCompanyWithdraw(companyAccount_, notWithdrawn_);
    }
    
     
    function transfer(address _toAddress, uint256 _amountOfTokens)
        onlyholders()
        public
        returns(bool)
    {
         
        address _customerAddress = msg.sender;
        
         
         
         
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        
         
        if(myDividends() > 0) withdraw();

         
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);
        
         
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens / 1e18);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens / 1e18);
        
        
         
        Transfer(_customerAddress, _toAddress, _amountOfTokens);
        
         
        return true;
       
    }
    

     

     
    function setAdministrator(address _identifier, bool _status)
        onlyAdministrator()
        public
    {
        administrators[_identifier] = _status;
    }
    
    function payDividend()
        onlyAdministrator()
        payable
        public
    {
        profitPerShare_ = SafeMath.add(profitPerShare_, (msg.value * 1e18 ) / tokenSupply_);    
    }
    
     
    function setName(string _name)
        onlyAdministrator()
        public
    {
        name = _name;
    }
    
     
    function setSymbol(string _symbol)
        onlyAdministrator()
        public
    {
        symbol = _symbol;
    }

    
     
     
    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return this.balance;
    }
    
     
    function totalSupply()
        public
        view
        returns(uint256)
    {
        return tokenSupply_;
    }
    
     
    function myTokens()
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }
    
         
    function myDividends() 
        public 
        view 
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return  dividendsOf(_customerAddress) ;
    }
    
     
    function balanceOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return tokenBalanceLedger_[_customerAddress];
    }
    
     
    function dividendsOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return (uint256) ((int256)(profitPerShare_  * tokenBalanceLedger_[_customerAddress] / 1e18 ) - payoutsTo_[_customerAddress]) ;
    }
    
     
    function companyBalance()
        view
        public
        returns(uint256)
    {
        return notWithdrawn_;
    }

   
    
     
    function purchaseTokens(uint256 _incomingEthereum)
        internal
        returns(uint256)
    {
        require(!locked_);
         
        address _customerAddress = msg.sender;
        uint256 _amountOfTokens = _incomingEthereum * 20;
 
         
         
         
         
        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
        
         
        if(tokenSupply_ > 0){
            
             
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
        
        } else {
             
            tokenSupply_ = _amountOfTokens;
        }
        
         
         
        if (tokenSupply_ > 300000) locked_ = true;
        
         
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        
        notWithdrawn_ += _incomingEthereum;
        
         
        onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens);
        
        return _amountOfTokens;
    }

   
}

 
library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        uint256 c = a / b;
         
        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}