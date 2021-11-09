pragma solidity ^0.4.23;
 
 
 
 
 
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

interface Token {
    function transfer(address to, uint256 value) external returns (bool success);
    function transferFrom(address from, address to, uint256 value) external returns (bool success);
    function approve(address spender, uint256 value) external returns (bool success);

     
    function totalSupply() external constant returns (uint256 supply);
    function balanceOf(address owner) external constant returns (uint256 balance);
    function allowance(address owner, address spender) external constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface PromissoryToken {

	function claim() payable external;
	function lastPrice() external returns(uint256);
}

contract DutchAuction {

     
    event BidSubmission(address indexed sender, uint256 amount);
    event logPayload(bytes _data, uint _lengt);

     
    uint constant public MAX_TOKENS_SOLD = 10000000 * 10**18;  
    uint constant public WAITING_PERIOD = 45 days;

     


    address public pWallet;
    Token public KittieFightToken;
    address public owner;
    PromissoryToken public PromissoryTokenIns; 
    address constant public promissoryAddr = 0x0348B55AbD6E1A99C6EBC972A6A4582Ec0bcEb5c;
    uint public ceiling;
    uint public priceFactor;
    uint public startBlock;
    uint public endTime;
    uint public totalReceived;
    uint public finalPrice;
    mapping (address => uint) public bids;
    Stages public stage;

     
    enum Stages {
        AuctionDeployed,
        AuctionSetUp,
        AuctionStarted,
        AuctionEnded,
        TradingStarted
    }

     
    modifier atStage(Stages _stage) {
        require(stage == _stage);
             
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner);
             
        _;
    }

    modifier isWallet() {
         require(msg.sender == address(pWallet));
             
        _;
    }

    modifier isValidPayload() {
        emit logPayload(msg.data, msg.data.length);
        require(msg.data.length == 4 || msg.data.length == 36, "No valid payload");
        _;
    }

    modifier timedTransitions() {
        if (stage == Stages.AuctionStarted && calcTokenPrice() <= calcStopPrice())
            finalizeAuction();
        if (stage == Stages.AuctionEnded && now > endTime + WAITING_PERIOD)
            stage = Stages.TradingStarted;
        _;
    }

     
     
     
     
     
    constructor(address _pWallet, uint _ceiling, uint _priceFactor)
        public
    {
        if (_pWallet == 0 || _ceiling == 0 || _priceFactor == 0)
             
            revert();
        owner = msg.sender;
        PromissoryTokenIns = PromissoryToken(promissoryAddr);
        pWallet = _pWallet;
        ceiling = _ceiling;
        priceFactor = _priceFactor;
        stage = Stages.AuctionDeployed;
    }

     
     
    function setup(address _kittieToken)
        public
        isOwner
        atStage(Stages.AuctionDeployed)
    {
        if (_kittieToken == 0)
             
            revert();
        KittieFightToken = Token(_kittieToken);
         
        if (KittieFightToken.balanceOf(this) != MAX_TOKENS_SOLD)
            revert();
        stage = Stages.AuctionSetUp;
    }

     
    function startAuction()
        public
        isOwner
        atStage(Stages.AuctionSetUp)
    {
        stage = Stages.AuctionStarted;
        startBlock = block.number;
    }

     
     
     
    function changeSettings(uint _ceiling, uint _priceFactor)
        public
        isWallet
        atStage(Stages.AuctionSetUp)
    {
        ceiling = _ceiling;
        priceFactor = _priceFactor;
    }

     
     
    function calcCurrentTokenPrice()
        public
        timedTransitions
        returns (uint)
    {
        if (stage == Stages.AuctionEnded || stage == Stages.TradingStarted)
            return finalPrice;
        return calcTokenPrice();
    }

     
     
    function updateStage()
        public
        timedTransitions
        returns (Stages)
    {
        return stage;
    }

     
     
    function bid(address receiver)
        public
        payable
         
        timedTransitions
        atStage(Stages.AuctionStarted)
        returns (uint amount)
    {
         
        if (receiver == 0)
            receiver = msg.sender;
        amount = msg.value;
         
        uint maxWei = (MAX_TOKENS_SOLD / 10**18) * calcTokenPrice() - totalReceived;
        uint maxWeiBasedOnTotalReceived = ceiling - totalReceived;
        if (maxWeiBasedOnTotalReceived < maxWei)
            maxWei = maxWeiBasedOnTotalReceived;
         
        if (amount > maxWei) {
            amount = maxWei;
             
            if (!receiver.send(msg.value - amount))
                 
                revert();
        }
         
        if (amount == 0 || !address(pWallet).send(amount))
             
            revert();
        bids[receiver] += amount;
        totalReceived += amount;
        if (maxWei == amount)
             
            finalizeAuction();
        emit BidSubmission(receiver, amount);
    }

     
     
    function claimTokens(address receiver)
        public
        isValidPayload
        timedTransitions
        atStage(Stages.TradingStarted)
    {
        if (receiver == 0)
            receiver = msg.sender;
        uint tokenCount = bids[receiver] * 10**18 / finalPrice;
        bids[receiver] = 0;
        KittieFightToken.transfer(receiver, tokenCount);
    }

     
     
    function calcStopPrice()
        view
        public
        returns (uint)
    {
        return totalReceived * 10**18 / MAX_TOKENS_SOLD + 1;
    }

     
     
    function calcTokenPrice()
        view
        public
        returns (uint)
    {
        return priceFactor * 10**18 / (block.number - startBlock + 7500) + 1;
    }

     
    function finalizeAuction()
        private
    {
        stage = Stages.AuctionEnded;

        if (totalReceived == ceiling)
            finalPrice = calcTokenPrice();
        else
            finalPrice = calcStopPrice();

        endTime = now;
    }


}

contract Dutchwrapper is DutchAuction {


    uint constant public MAX_TOKEN_REFERRAL = 1800000 * 10**18;  
    uint constant public MAX_TOKEN_SOCIAL = 200000 * 10**18;  

    uint public claimedTokenReferral = 0;  
    uint public claimedSocial = 0;  


     
    uint constant public TOTAL_BONUS_TOKEN = 2000000 * 10**18;


    uint constant public Partners = 1;  
    uint constant public Referrals = 2;  
    uint constant public Social = 3;  

    uint constant public ONE = 1;  

    mapping (address => uint) public SuperDAOTokens;  
     

    struct PartnerForEth {
        bytes4 hash;  
        address addr;  
        uint totalReferrals;  
        uint totalContribution;  
        uint[] individualContribution;  
        uint percentage;  
        uint EthEarned;  
    }

	address [] public PartnersList;  

     
    struct tokenForReferral {
        bytes4 hash;  
        address addr;  
        uint totalReferrals;  
        uint totalTokensEarned;  
        mapping(uint => uint) tokenAmountPerReferred; 
    }

    address [] public TokenReferalList;  


     
    struct SocialProfile{
        address addr;  
        bytes32 socialAction;  
        uint tokensEarned;  
        bool approved;  
        bytes32 username;  
    }

    struct TokenforSocial{
        bytes4 hash;  
        uint maxParticipators;  
        SocialProfile [] SocialLinkProfile;  
        address [] profileList;  
        mapping(address => uint) index;  
        mapping(address => bool) disqualified;  
        uint tokenAmountForEach;  
    }

    mapping(bytes4 => PartnerForEth )  public MarketingPartners;
    mapping(bytes4 => tokenForReferral)  public TokenReferrals;
    mapping(bytes4 => TokenforSocial )  public SocialCampaigns;
    mapping(address => bool ) public Admins;

     
    struct bidder {
        address addr;
        uint amount;
    }

    bidder [] public CurrentBidders;  


    event PartnerReferral(bytes4 _partnerHash,address _addr, uint _amount); 
    event SocialReferral(bytes4 _campaignHash,address _addr, uint _amount); 
    event TokenReferral(bytes4 _campaignHash,address _addr, uint _amount); 
    event BidEvent(bytes4 _hash, address _addr, uint _amount);  
    event SetupReferal(uint _type);  
    event ConfirmSocial(bytes4 _campaignHash, address _addr, bytes32 _userName);  
    event AdminRemoveBatch(bytes4 _campaignHash, address _addr, bytes32 _userName);  
    event ReferalSignup(bytes4 _Hash, address _addr);  
    event ClaimtokenBonus(bytes4 _Hash, address _addr, bool success);  



     
    modifier isAdmin(){
        require(Admins[msg.sender] == true);
        _;
    }

     
    modifier isDisqualified(bytes4 _campaignHash){
        require(SocialCampaigns[_campaignHash].disqualified[msg.sender] == false);
        _;
    }

     
    modifier tradingstarted(){
        require(stage == Stages.TradingStarted);
        _;
    }

     
    modifier onlyMarketingPartners(bytes4 _hash) {
        require((msg.sender == owner) || ((msg.sender == MarketingPartners[_hash].addr) && ( _hash == MarketingPartners[_hash].hash)));
             
        _;
    }


     
     
     
     
     


     
     


     
    modifier ReferalCampaignLimit() {
        require (claimedTokenReferral < MAX_TOKEN_REFERRAL);
        _;
    }

     
    modifier SocialCampaignLimit() {
        require (claimedSocial< MAX_TOKEN_SOCIAL);
        _;
    }

     
    modifier checkSocialDuplicates(bytes4 _campaignHash, bytes32 _userName) {
    	for (uint i=0; i<SocialCampaigns[_campaignHash].SocialLinkProfile.length; i++ ) {
    		if (SocialCampaigns[_campaignHash].SocialLinkProfile[i].username == _userName) {
    			revert();
    		}
        }
    	_;
    }

    constructor  (address _pWallet, uint _ceiling, uint _priceFactor)
        DutchAuction(_pWallet, _ceiling, _priceFactor)  public {
    }

     
    function setAdmin(address _addr) public isOwner returns (bool success){
        Admins[_addr] = true;
    		    return true;
    }

     
    function removeAdmin(address _addr) public isOwner returns (bool success){
        Admins[_addr] = false;
    		    return true;
    }


     
     

    function setupReferal(address _addr, uint _percentage, uint _type, uint _tokenAmt, uint _numUsers)
        public
        isOwner
        returns (string successmessage)
    {

        bytes4 tempHash = bytes4(keccak256(abi.encodePacked(_addr, msg.sender)));

        if (_type == Partners) {

            MarketingPartners[tempHash].hash = tempHash;
            MarketingPartners[tempHash].addr = _addr;
            MarketingPartners[tempHash].percentage = _percentage;
            InternalReferalSignup(_addr);
    		    emit SetupReferal(_type);
            return "partner signed up";

        } else {

            SocialCampaigns[tempHash].hash = tempHash;
            SocialCampaigns[tempHash].maxParticipators = _numUsers;
            SocialCampaigns[tempHash].tokenAmountForEach = _tokenAmt;
            emit SetupReferal(_type);
            return "social campaign started";
        }
    }

     
     
    function InternalReferalSignup(address _addr) internal returns (bytes4 referalhash) {
        bytes4 tempHash = bytes4(keccak256(abi.encodePacked(_addr)));
        TokenReferrals[tempHash].addr = msg.sender;
        TokenReferrals[tempHash].hash = tempHash;
        referalhash = tempHash;
        emit ReferalSignup(tempHash, _addr);
    }


     
    function referralSignup() public ReferalCampaignLimit returns (bytes4 referalhash) {
        bytes4 tempHash = bytes4(keccak256(abi.encodePacked(msg.sender)));
        TokenReferrals[tempHash].addr = msg.sender;
        TokenReferrals[tempHash].hash = tempHash;
        referalhash = tempHash;
        emit ReferalSignup(tempHash, msg.sender);
    }


     
    function bidReferral(address _receiver, bytes4 _hash) public payable returns (uint) {

        uint bidAmount = msg.value;
        uint256 promissorytokenLastPrice = PromissoryTokenIns.lastPrice();


        if(bidAmount > ceiling - totalReceived) {
            bidAmount = ceiling - totalReceived;
        }

        require( bid(_receiver) == bidAmount );

		uint amount = msg.value;
		bidder memory _bidder;
		_bidder.addr = _receiver;
		_bidder.amount = amount;
        SuperDAOTokens[msg.sender] += amount/promissorytokenLastPrice;
		CurrentBidders.push(_bidder);

        emit BidEvent(_hash, msg.sender, amount);

        if (_hash == MarketingPartners[_hash].hash) {

            MarketingPartners[_hash].totalReferrals += ONE;
            MarketingPartners[_hash].totalContribution += amount;
            MarketingPartners[_hash].individualContribution.push(amount);
            MarketingPartners[_hash].EthEarned += referalPercentage(amount, MarketingPartners[_hash].percentage);

            if(claimedTokenReferral < MAX_TOKEN_REFERRAL){
            TokenReferrals[_hash].totalReferrals += ONE;

            if( (msg.value >= 1 ether) && (msg.value <= 3 ether) ) {
              TokenReferrals[_hash].tokenAmountPerReferred[amount] = 100 * 10**18;
              TokenReferrals[_hash].totalTokensEarned += 100 * 10**18;
              claimedTokenReferral += 100 * 10**18;
              emit TokenReferral(_hash ,msg.sender, amount);


              } else if ((msg.value > 3 ether)&&(msg.value <= 6 ether)) {
                  TokenReferrals[_hash].tokenAmountPerReferred[amount] = 500 * 10**18;
                  TokenReferrals[_hash].totalTokensEarned += 500 * 10**18;
                  claimedTokenReferral += 500 * 10**18;
                  emit TokenReferral(_hash ,msg.sender, amount);


                  } else if (msg.value > 6 ether) {
                    TokenReferrals[_hash].tokenAmountPerReferred[amount] = 1000 * 10**18;
                    TokenReferrals[_hash].totalTokensEarned += 1000 * 10**18;
                    claimedTokenReferral += 1000 * 10**18;
                    emit TokenReferral(_hash, msg.sender, amount);

                  }
                }
            emit PartnerReferral(_hash, MarketingPartners[_hash].addr, amount);

            return Partners;

          } else if ((_hash == TokenReferrals[_hash].hash) && (claimedTokenReferral < MAX_TOKEN_REFERRAL)) {

        			TokenReferrals[_hash].totalReferrals += ONE;

        			if( (msg.value >= 1 ether) && (msg.value <= 3 ether) ) {
        				TokenReferrals[_hash].tokenAmountPerReferred[amount] = 100 * 10**18;
        				TokenReferrals[_hash].totalTokensEarned += 100 * 10**18;
                claimedTokenReferral += 100 * 10**18;
        				emit TokenReferral(_hash ,msg.sender, amount);
        				return Referrals;

        				} else if ((msg.value > 3 ether)&&(msg.value <= 6 ether)) {
        						TokenReferrals[_hash].tokenAmountPerReferred[amount] = 500 * 10**18;
        						TokenReferrals[_hash].totalTokensEarned += 500 * 10**18;
                    claimedTokenReferral += 500 * 10**18;
        						emit TokenReferral(_hash ,msg.sender, amount);
        						return Referrals;

        						} else if (msg.value > 6 ether) {
        							TokenReferrals[_hash].tokenAmountPerReferred[amount] = 1000 * 10**18;
        							TokenReferrals[_hash].totalTokensEarned += 1000 * 10**18;
                      claimedTokenReferral += 1000 * 10**18;
        							emit TokenReferral(_hash, msg.sender, amount);
        							return Referrals;
        						}
                            }


    }



	function confirmSocial(bytes4 _campaignHash, bytes32 _userName, bytes32 _retweetOrdiscord) public
	   SocialCampaignLimit
	   checkSocialDuplicates(_campaignHash, _userName)
    	returns (uint) {
			uint id = SocialCampaigns[_campaignHash].index[msg.sender];

            if(SocialCampaigns[_campaignHash].SocialLinkProfile.length != 0){
                require(msg.sender != SocialCampaigns[_campaignHash].SocialLinkProfile[id].addr);  
            }

			require(SocialCampaigns[_campaignHash].SocialLinkProfile.length <= SocialCampaigns[_campaignHash].maxParticipators); 
            SocialProfile memory tempProfile;
			tempProfile.addr = msg.sender;
 			tempProfile.socialAction = _retweetOrdiscord;  
			tempProfile.tokensEarned = SocialCampaigns[_campaignHash].tokenAmountForEach;
			tempProfile.approved = true;
			tempProfile.username = _userName;
			SocialCampaigns[_campaignHash].SocialLinkProfile.push(tempProfile);
			SocialCampaigns[_campaignHash].index[msg.sender] = SocialCampaigns[_campaignHash].SocialLinkProfile.length;
			 


			claimedSocial += SocialCampaigns[_campaignHash].tokenAmountForEach;
			emit ConfirmSocial(_campaignHash, msg.sender, _userName);
    }


    function adminRemoveBatch(bytes4 _campaignHash, address [] _batchList) public
        isAdmin
        SocialCampaignLimit
        returns (uint) {
        	 for (uint i=0; i < _batchList.length; i++){
        	   address tempAddr = _batchList[i];
        	   uint userIndex = SocialCampaigns[_campaignHash].index[tempAddr];
        	   delete SocialCampaigns[_campaignHash].SocialLinkProfile[userIndex];
        	   SocialCampaigns[_campaignHash].disqualified[tempAddr] = true;
        	   claimedSocial -= SocialCampaigns[_campaignHash].tokenAmountForEach;
        	   emit AdminRemoveBatch(_campaignHash, tempAddr, SocialCampaigns[_campaignHash].SocialLinkProfile[userIndex].username);
        }
    }



	function referalPercentage(uint _amount, uint _percent)
	    public
	    returns (uint) {
            return SafeMath.mul( SafeMath.div( SafeMath.sub(_amount, _amount%100), 100 ), _percent );
	}



  function claimtokenBonus (bytes4 _campaignHash) public
	timedTransitions
	atStage(Stages.TradingStarted)
	isDisqualified(_campaignHash)
	returns (bool success) {

	 	uint userIndex = SocialCampaigns[_campaignHash].index[msg.sender];
        bytes4 _personalHash = bytes4(keccak256(abi.encodePacked(msg.sender)));

		if ((_personalHash == TokenReferrals[_personalHash].hash) && (TokenReferrals[_personalHash].totalTokensEarned > 0)){

			uint TokensToTransfer1 = TokenReferrals[_personalHash].totalTokensEarned;
			TokenReferrals[_personalHash].totalTokensEarned = 0;
            KittieFightToken.transfer(TokenReferrals[_personalHash].addr , TokensToTransfer1);
			emit ClaimtokenBonus(_campaignHash, msg.sender, true);
			return true;

	  }else if((msg.sender == SocialCampaigns[_campaignHash].SocialLinkProfile[userIndex].addr) && (SocialCampaigns[_campaignHash].SocialLinkProfile[userIndex].tokensEarned > 0)){

		uint TokensToTransfer2 = SocialCampaigns[_campaignHash].SocialLinkProfile[userIndex].tokensEarned;
		SocialCampaigns[_campaignHash].SocialLinkProfile[userIndex].tokensEarned = 0;
		KittieFightToken.transfer(msg.sender, TokensToTransfer2);
		emit ClaimtokenBonus(_campaignHash, msg.sender, true);
		return true;
		}else return false;

  }

     
    function transferUnsoldTokens(uint _unsoldTokens, address _addr)
        public
        isOwner
        atStage(Stages.TradingStarted)

     {

        uint soldTokens = totalReceived * 10**18 / finalPrice;
        require (_unsoldTokens < (MAX_TOKENS_SOLD + claimedTokenReferral + claimedSocial) - soldTokens);
        KittieFightToken.transfer(_addr, _unsoldTokens);
    }


     
     
    

    function getCurrentBiddersCount () public view returns(uint biddersCount)  {
        biddersCount = CurrentBidders.length;
    }
    

     
    function calculatPersonalHash() public view returns (bytes4 _hash) {
        _hash = bytes4(keccak256(abi.encodePacked(msg.sender)));
    }

    function calculateCampaignHash(address _addr) public view returns (bytes4 _hash) {
        _hash = bytes4(keccak256(abi.encodePacked(_addr, msg.sender)));
    }

     
    function setPromissoryTokenInstance(address _promissoryAddr) public isOwner {
        PromissoryTokenIns = PromissoryToken(_promissoryAddr);
    }
  

}