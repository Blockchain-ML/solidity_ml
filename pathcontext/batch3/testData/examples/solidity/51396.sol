pragma solidity ^0.4.24;


contract AcceptsProofofHumanity {
    ProofofHumanity public tokenContract;

    constructor(address _tokenContract) public {
        tokenContract = ProofofHumanity(_tokenContract);
    }

    modifier onlyTokenContract {
        require(msg.sender == address(tokenContract));
        _;
    }

     
    function tokenFallback(address _from, uint256 _value, bytes _data) external returns (bool);
}


contract ProofofHumanity {
     
     
    modifier onlyBagholders() {
        require(myTokens() > 0);
        _;
    }

     
    modifier onlyStronghands() {
        require(myDividends(true) > 0);
        _;
    }

    modifier noUnapprovedContracts() {
      require (msg.sender == tx.origin || approvedContracts[msg.sender] == true);
      _;
    }

    modifier onlyAmbassadorsIfNotPublic() { 
        if(!openToPublic)
        {
            require (ambassadors_[msg.sender] == true);    
        } 
        else
        {

            require(launchTime < now);
        }
        _;
    }
    
    modifier mustMeetMinimumAmount() { 
        require (msg.value > 10000 wei); 
        _; 
    }
    

    modifier onlyAdministrator(){
        require(administrators[msg.sender]);
        _;
    }




     
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );

     
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );


     
    string public name = "Proof of Humanity";
    string public symbol = "PoH";
    uint8 constant public decimals = 18;
    uint8 constant internal dividendFee_ = 20;  
    uint8 constant internal charityFee_ = 3;  
    uint8 constant internal humanWhaleFee_ = 2;  
    uint256 constant internal maxTokenSellDaily_ = 1500e18;
    uint256 constant internal tokenPriceInitial_ = 0.00000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.000000001 ether;
    uint256 constant internal magnitude = 2**64;
    uint256 constant internal ambassadorMaxPurchase_ = 0.5 ether;

     
    address constant public pohHumanWhale = 0x6d68603000613cdf29975914fa309650605f3dd1;
         
    uint256 constant public stakingRequirement = 10e18;

     
     
     
    address constant public giveEthCharityAddress = 0x5ADF43DD006c6C36506e2b2DFA352E60002d22Dc;
    uint256 public totalEthCharityRecieved;  
    uint256 public totalEthCharityCollected;  

    bool public openToPublic;
    uint256  internal launchTime;  

   
   




    
      
    mapping(address => bool) internal ambassadors_;
     
    mapping(address => bool) public administrators;

     
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    mapping(address => address) internal tier1Referral;
    mapping(address => address) internal tier2Referral;
    mapping(address => uint256) internal sellTimeStamp_;
    mapping(address => uint256) internal tokensSoldToday_;
    uint256 internal tokenSupply_ = 0;
    uint256 internal profitPerShare_;

     
    mapping(address => bool) public canAcceptTokens_;  

     
    mapping(address => bool) public approvedContracts;


     
     
    constructor()
        public
    {
         
        administrators[0xe8B1C589e86DEf7563aD43BebDDB7B1677beC9A9] = true;
        administrators[0x2de78fbc7e1d1c93aa5091ae28dd836cc71e8d4c] = true;

         
        ambassadors_[0xe8B1C589e86DEf7563aD43BebDDB7B1677beC9A9] = true;
        ambassadors_[0x2de78fbc7e1d1c93aa5091ae28dd836cc71e8d4c] = true;
        ambassadors_[0xC6D4a4A0bf0507749D4a23C9550A826207b5D94b] = true;
        ambassadors_[0xEc31176d4df0509115abC8065A8a3F8275aafF2b] = true;
        ambassadors_[0x72a9BCd0396C118D3b3D5D7C6B65AAf6Ba37C364] = true;
        ambassadors_[0xc7F15d0238d207e19cce6bd6C0B85f343896F046] = true;

        openToPublic = false;
        
    }

     
    function buy(address _referredBy)
        mustMeetMinimumAmount()
        onlyAmbassadorsIfNotPublic() 
        public
        payable
        returns(uint256)
    {
        purchaseInternal(msg.value, _referredBy);
    }

     
    function()
        mustMeetMinimumAmount()
        onlyAmbassadorsIfNotPublic() 
        payable
        public
    {
        purchaseInternal(msg.value, 0x0);
    }

     
    function payCharity() 
        mustMeetMinimumAmount()
        payable 
        public 
    {
      uint256 ethToPay = SafeMath.sub(totalEthCharityCollected, totalEthCharityRecieved);
      require(ethToPay > 1);
      totalEthCharityRecieved = SafeMath.add(totalEthCharityRecieved, ethToPay);
      if(!giveEthCharityAddress.call.value(ethToPay).gas(400000)()) 
      {
         totalEthCharityRecieved = SafeMath.sub(totalEthCharityRecieved, ethToPay);
      }
    }

     
    function reinvest()
        onlyStronghands()
        public
    {
         
        uint256 _dividends = myDividends(false);  

         
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

         
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

         
        uint256 _tokens = purchaseTokens(_dividends, 0x0);

         
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }

     
    function exit()
        public
    {
         
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if(_tokens > 0) sell(_tokens);

         
        withdraw();
    }

     
    function withdraw()
        onlyStronghands()
        public
    {
         
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false);  

         
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

         
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

         
        _customerAddress.transfer(_dividends);

         
        emit onWithdraw(_customerAddress, _dividends);
    }

     
    function sell(uint256 _amountOfTokens)
        onlyBagholders()
        public
    {
         
        address _customerAddress = msg.sender;

         
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress] 
                && _amountOfTokens <= maxTokenSellDaily_);

         
        if(sellTimeStamp_[_customerAddress] <= (now - 24 hours))
        {   
             
            sellTimeStamp_[_customerAddress] = now;
            tokensSoldToday_[_customerAddress] = _amountOfTokens;
        }
        else  
        {       
             
            require(SafeMath.sub(maxTokenSellDaily_, (tokensSoldToday_[_customerAddress] + _tokens)) >= 0);
            tokensSoldToday_[_customerAddress] += _amountOfTokens;
        }
        
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);

        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
        uint256 _charityPayout = SafeMath.div(SafeMath.mul(_ethereum, charityFee_), 100);
        uint256 _whaleFee = SafeMath.div(SafeMath.mul(_ethereum, humanWhaleFee_), 100);
         
        uint256 _taxedEthereum =  SafeMath.sub(SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _charityPayout), _whaleFee);

         
        totalEthCharityCollected = SafeMath.add(totalEthCharityCollected, _charityPayout);

         
        pohHumanWhale.transfer(_whaleFee);

         
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);

         
        sellTimeStamp_[_customerAddress] == now;

         
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;

         
        if (tokenSupply_ > 0) {
             
            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        }

         
        emit onTokenSell(_customerAddress, _tokens, _taxedEthereum);
    }


     
    function transfer(address _toAddress, uint256 _amountOfTokens)
        onlyBagholders()
        public
        returns(bool)
    {
         
        address _customerAddress = msg.sender;

         
         
         
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

         
        if(myDividends(true) > 0) withdraw();

         
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);

         
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);


         
        emit Transfer(_customerAddress, _toAddress, _amountOfTokens);

         
        return true;
    }

     
    function transferAndCall(address _to, uint256 _value, bytes _data) external returns (bool) {
      require(_to != address(0));
      require(canAcceptTokens_[_to] == true);  
      require(transfer(_to, _value));  

      if (isContract(_to)) {
        AcceptsProofofHumanity receiver = AcceptsProofofHumanity(_to);
        require(receiver.tokenFallback(msg.sender, _value, _data));
      }

      return true;
    }

     
     function isContract(address _addr) private constant returns (bool is_contract) {
        
       uint length;
       assembly { length := extcodesize(_addr) }
       return length > 0;
     }

       
     function sendDividends () payable public
    {
        require(msg.value > 10000 wei);

        uint256 _dividends = msg.value;
         
        profitPerShare_ += (_dividends * magnitude / (tokenSupply_));
    }      

     
     
    function GoForLaunch()
        onlyAdministrator()
        public
    {
        openToPublic = true;
        launchTime = now + 2 hours;
    }

     
    function setAdministrator(address _identifier, bool _status)
        onlyAdministrator()
        public
    {
        administrators[_identifier] = _status;
    }

     
    function setCanAcceptTokens(address _address, bool _value)
      onlyAdministrator()
      public
    {
      canAcceptTokens_[_address] = _value;
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

      
     function setApprovedContracts(address contractAddress, bool yesOrNo)
        onlyAdministrator()
        public
     {
        approvedContracts[contractAddress] = yesOrNo;
     }


     
     
    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return address(this).balance;
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

     
    function myDividends(bool _includeReferralBonus)
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
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
        return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }

     
    function sellPrice()
        public
        view
        returns(uint256)
    {
         
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
            uint256 _charityPayout = SafeMath.div(SafeMath.mul(_ethereum, charityFee_), 100);
            uint256 _whalePayout = SafeMath.div(SafeMath.mul(_ethereum, humanWhaleFee_), 100);
            uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _charityPayout), _whalePayout);
            return _taxedEthereum;
        }
    }

     
    function buyPrice()
        public
        view
        returns(uint256)
    {
         
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
            uint256 _charityPayout = SafeMath.div(SafeMath.mul(_ethereum, charityFee_), 100);
            uint256 _whalePayout = SafeMath.div(SafeMath.mul(_ethereum, humanWhaleFee_), 100);
            uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _charityPayout), _whalePayout);
            return _taxedEthereum;
        }
    }

     
    function calculateTokensReceived(uint256 _ethereumToSpend)
        public
        view
        returns(uint256)
    {
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, dividendFee_), 100);
        uint256 _charityPayout = SafeMath.div(SafeMath.mul(_ethereumToSpend, charityFee_), 100);
        uint256 _whalePayout = SafeMath.div(SafeMath.mul(_ethereumToSpend, humanWhaleFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(SafeMath.sub(_ethereumToSpend, _dividends), _charityPayout), _whalePayout);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        return _amountOfTokens;
    }

     
    function calculateEthereumReceived(uint256 _tokensToSell)
        public
        view
        returns(uint256)
    {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
        uint256 _charityPayout = SafeMath.div(SafeMath.mul(_ethereum, charityFee_), 100);
        uint256 _whalePayout = SafeMath.div(SafeMath.mul(_ethereum, humanWhaleFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _charityPayout), _whalePayout);
        return _taxedEthereum;
    }

     
    function etherToSendCharity()
        public
        view
        returns(uint256) {
        return SafeMath.sub(totalEthCharityCollected, totalEthCharityRecieved);
    }


     

     
    function purchaseInternal(uint256 _incomingEthereum, address _referredBy)

      noUnapprovedContracts() 
      internal
      returns(uint256) {
      uint256 purchaseEthereum = _incomingEthereum;
      uint256 excess;
      if(purchaseEthereum > 5 ether) {  
          if (SafeMath.sub(address(this).balance, purchaseEthereum) <= 100 ether) {  
              purchaseEthereum = 5 ether;
              excess = SafeMath.sub(_incomingEthereum, purchaseEthereum);
          }
      }

      purchaseTokens(purchaseEthereum, _referredBy);

      if (excess > 0) {
        msg.sender.transfer(excess);
      }
    }


    function purchaseTokens(uint256 _incomingEthereum, address _referredBy)
        internal
        returns(uint256)
        
    {
         
        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, dividendFee_), 100);
        uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);
        uint256 _whaleFee = SafeMath.div(SafeMath.mul(_undividedDividends, humanWhaleFee_), 100);
        uint256 _charityPayout = SafeMath.div(SafeMath.mul(_incomingEthereum, charityFee_), 100);
        uint256 _dividends = SafeMath.sub(SafeMath.sub(_undividedDividends, _referralBonus), _whaleFee);
        
        uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(SafeMath.sub(_incomingEthereum, _undividedDividends), _charityPayout), _whaleFee);

        totalEthCharityCollected = SafeMath.add(totalEthCharityCollected, _charityPayout);

        pohHumanWhale.transfer(_whaleFee);

        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        uint256 _fee = _dividends * magnitude;

         
         
         
         
        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));

         
        if(
             
            _referredBy != 0x0000000000000000000000000000000000000000 &&

             
            _referredBy != msg.sender &&

             
             
            tokenBalanceLedger_[_referredBy] >= stakingRequirement
        ){
             
            if(tier1Referral[msg.sender] == 0x0000000000000000000000000000000000000000)
            {
                tier1Referral[msg.sender] == address(_referredBy);
            }
            else
            {
                 
                if(tier2Referral[_referredBy] != 0x0000000000000000000000000000000000000000)
                {
                    referralBalance_[tier2Referral[_referredBy]] += _referralBonus / 3;
                    _referralBonus = SafeMath.sub(_referralBonus, _referralBonus / 3);
                }
                else
                {
                    tier2Referral[_referredBy] = tier1Referral[_referredBy];
                    referralBalance_[tier2Referral[_referredBy]] += _referralBonus / 3;
                    _referralBonus = SafeMath.sub(_referralBonus, _referralBonus / 3);
                }
            }
             
            referralBalance_[tier1Referral[msg.sender]]  +=  _referralBonus;
        } else {
             
             
            _dividends = SafeMath.add(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }

         
        if(tokenSupply_ > 0){

             
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);

             
            profitPerShare_ += (_dividends * magnitude / (tokenSupply_));

             
            _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));

        } else {
             
            tokenSupply_ = _amountOfTokens;
        }

         
        tokenBalanceLedger_[msg.sender] = SafeMath.add(tokenBalanceLedger_[msg.sender], _amountOfTokens);

         
         
        int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
        payoutsTo_[msg.sender] += _updatedPayouts;

         
        emit onTokenPurchase(msg.sender, _incomingEthereum, _amountOfTokens, _referredBy);

        return _amountOfTokens;
    }

     
    function ethereumToTokens_(uint256 _ethereum)
        internal
        view
        returns(uint256)
    {
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived =
         (
            (
                 
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial**2)
                            +
                            (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
                            +
                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
                            +
                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
                        )
                    ), _tokenPriceInitial
                )
            )/(tokenPriceIncremental_)
        )-(tokenSupply_)
        ;

        return _tokensReceived;
    }

     
     function tokensToEthereum_(uint256 _tokens)
        internal
        view
        returns(uint256)
    {

        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (tokenSupply_ + 1e18);
        uint256 _etherReceived =
        (
             
            SafeMath.sub(
                (
                    (
                        (
                            tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
                        )-tokenPriceIncremental_
                    )*(tokens_ - 1e18)
                ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
            )
        /1e18);
        return _etherReceived;
    }


     
     
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
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