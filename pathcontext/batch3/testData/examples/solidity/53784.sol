pragma solidity ^0.4.13;

contract BlendPublisher{

    struct StrategyHiddenState {
      uint32 date;
      bytes32 hiddenHash;
    }

    address public owner;
    bytes32 public name;      

    bytes32[] underlying;
    uint32 dateInit;                  

    bool isAlive;

    mapping(bytes32 => StrategyHiddenState) private hiddenStates;

    mapping(address=>bool) public delegatinglist;

    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }

    modifier onlyAuthorized(){
        require(isdelegatinglisted(msg.sender));
        _;
    }

    event newBlend(bytes32 name, uint32 date);
    event newHiddenRecord(uint32 indexed date, bytes32 hashRecord);
    event newBlendDiscloseRecord(uint32 indexed date, int64[] positions, bytes32 underlyingReturnsHash, uint64 price, bytes16 secretPath, bytes32 previousTransactionHash);
    event newBlendBacktestRecord(uint32 indexed date, bytes32 positionsHash, bytes32 underlyingReturnsHash, uint64 price);
    event stateReset(bytes32 indexed name, uint32 indexed date, int256 stratVariation, uint64 stratPrice, int64 position,int8 category);
    event Authorized(address authorized, uint timestamp);
    event Revoked(address authorized, uint timestamp);
 
    constructor(bytes32 _name, uint32 _date, bytes32[] _underlying) public{
        underlying = _underlying;
        owner = msg.sender;
        delegatinglist[owner] = true;
        name = _name;
        dateInit = _date;
        emit newBlend(_name, _date);
    }

    function authorize(address authorized) public onlyOwner {
        delegatinglist[authorized] = true;
        emit Authorized(authorized, now);
    }

     
    function revoke(address authorized) public onlyOwner {
        delegatinglist[authorized] = false;
        emit Revoked(authorized, now);
    }

    function authorizeMany(address[50] authorized) public onlyOwner {
        for(uint i = 0; i < authorized.length; i++) {
            authorize(authorized[i]);
        }
    }

    function isdelegatinglisted(address authorized) public view returns(bool) {
      return delegatinglist[authorized];
    }

     
    function getStrategyHiddenState(bytes32 hiddenHash)
      public
      onlyAuthorized
      constant
      returns(uint32, bytes32)
    {
      return(
        hiddenStates[hiddenHash].date,
        hiddenStates[hiddenHash].hiddenHash);
    }

     
    function blendbacktest(uint32[] dates, bytes32[] positionsHashes, bytes32[] underlyingPricesHashes, uint64[] stratPrices) public onlyAuthorized {
      require(dates.length == positionsHashes.length);
      require(dates.length == underlyingPricesHashes.length);
      require(dates.length == stratPrices.length);
      for(uint i = 0; i < dates.length; i++) {
        emit newBlendBacktestRecord(dates[i], positionsHashes[i], underlyingPricesHashes[i], stratPrices[i]);
      }
    }

    function hashBacktestPositions(uint32 date, int64[] positions) public pure returns(bytes32) {
      return(sha256(abi.encodePacked(date,positions)));
    }

    function hashPositions(uint32 date, int64[] positions, bytes16 secretPath) public pure returns(bytes32) {
      return(sha256(abi.encodePacked(date,positions,secretPath)));
    }

    function hashUnderlyingPrices(uint32 date,int256[] underlyingReturns) public pure returns(bytes32) {
      return(sha256(abi.encodePacked(date,underlyingReturns)));
    }

    function addHiddenPosition(uint32 _date, bytes32 _hashRecord) public onlyAuthorized {
        StrategyHiddenState memory hiddenState = StrategyHiddenState({date:_date, hiddenHash:_hashRecord});
        hiddenStates[_hashRecord] = hiddenState;
        emit newHiddenRecord(_date, _hashRecord);
    }

    function deleteHiddenPosition(uint32 date, int64[] positions, bytes16 secretPath) public onlyAuthorized {
        bytes32 recomputedHash = sha256(abi.encodePacked(date,positions,secretPath));
        delete hiddenStates[recomputedHash];
    }

    function revealHiddenPosition(uint32 date, int64[] positions, bytes32 underlyingPricesHashes, uint64 stratPrice, bytes16 secretPath, bytes32 previousTransactionHash) public onlyAuthorized {
        bytes32 recomputedHash = sha256(abi.encodePacked(date,positions,secretPath));
        StrategyHiddenState memory matchingHiddenState =  hiddenStates[recomputedHash];
         
        require(recomputedHash == matchingHiddenState.hiddenHash);

        emit newBlendDiscloseRecord(date, positions, underlyingPricesHashes, stratPrice, secretPath, previousTransactionHash);

        delete hiddenStates[recomputedHash];
    }

}

contract PriceFeeder{
    address public owner;
    bytes32 name;

    struct FeederState {
        uint32 previousDate;
        uint64 previousPrice;
        uint32 date;
        uint64 price;
    }

    event newPrice(uint32 indexed date, bytes32 indexed underlying, uint64 price);

    mapping(bytes32 => FeederState) public priceData;

    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }

    constructor(bytes15 _name) public{
        owner = msg.sender;
        name = _name;
    }

    function updatePrice(bytes32 underlying, uint32 date, uint64 price, uint32 previousDate) onlyOwner public{
        FeederState storage state = priceData[underlying];
        state.previousDate = state.date;
        state.previousPrice = state.price;
        if (state.date != 0){
           
          require(previousDate == state.previousDate);
        }
        state.date = date;
        state.price = price;
        priceData[underlying] = state;
        emit newPrice(date, underlying, price);
    }


    function getState(bytes32 underlying) public constant returns (uint32 date, uint64 price, uint32 previousDate, uint64 previousPrice){
      FeederState storage record = priceData[underlying];
      return (record.date, record.price, record.previousDate, record.previousPrice);
    }

    function getDate(bytes32 underlying) public constant returns (uint32){
      FeederState storage record = priceData[underlying];
      return record.date;
    }

    function getPrice(bytes32 underlying) public constant returns (uint64){
      FeederState storage record = priceData[underlying];
      return record.price;
    }

    function getPreviousDate(bytes32 underlying) public constant returns (uint32){
      FeederState storage record = priceData[underlying];
      return record.previousDate;
    }

    function getPreviousPrice(bytes32 underlying) public constant returns (uint64){
      FeederState storage record = priceData[underlying];
      return record.previousPrice;
    }
}

library StrategyLib{
   
  event newRecord(bytes32 indexed name, uint32 indexed date, int256 stratVariation, uint64 prevStratPrice, uint64 stratPrice, uint64 truncatedStratPrice, uint64 prevUnderPrice, uint64 underPrice, int64 position,int category);
  event newBiRecord(bytes32 indexed name,uint32 indexed date,int256 stratVariation, uint64 prevStratPrice, uint64 stratPrice, uint64 truncatedStratPrice, uint64 prevUnderPrice, uint64 underPrice, int64 position, uint64 secondPrevUnderPrice, uint64 secondUnderPrice, int64 secondPosition, int category);
  event succinctBiRecord(uint32 indexed date, uint64 prevStratPrice, uint64 stratPrice, uint64 truncatedStratPrice,int category);
  event succinctBiUnder(uint64 prevUnderPrice, uint64 underPrice, int64 position, uint64 secondPrevUnderPrice, uint64 secondUnderPrice, int64 secondPosition);

     
  function libbibatchbacktest(uint64 strategyInitPrice, uint32[] dates, uint64[] prices, uint64[] secondPrices, int64[] positions, int64[] secondPositions) public returns (uint64) {
       uint64 strategyPrice = strategyInitPrice;
       uint64 truncatedStrategyPrice;
        
       for(uint8 i=1; i<dates.length; i++){
            
           int256 variation = calculateVariation(prices[i-1], prices[i], positions[i]) + calculateVariation(secondPrices[i-1], secondPrices[i], secondPositions[i]);
           uint64 prevStratPrice = strategyPrice;
           (strategyPrice,truncatedStrategyPrice) = calculateValue(variation, strategyPrice);
            
            
           emit succinctBiRecord(dates[i], prevStratPrice, strategyPrice, truncatedStrategyPrice,-1);
           emit succinctBiUnder(prices[i-1], prices[i], positions[i], secondPrices[i-1], secondPrices[i], secondPositions[i]);
           
           strategyPrice=truncatedStrategyPrice;
       }
       return strategyPrice;
 }

   
  function libbatchbacktest(bytes32 name, uint64 strategyInitPrice, uint32[] dates, uint64[] prices, int64[] positions) public returns (uint64) {
       uint64 strategyPrice = strategyInitPrice;
       uint64 truncatedStrategyPrice;
        
       for(uint8 i=1; i<dates.length; i++){
            
           int256 variation = calculateVariation(prices[i-1], prices[i], positions[i]);
           uint64 prevStratPrice = strategyPrice;
           (strategyPrice,truncatedStrategyPrice) = calculateValue(variation, strategyPrice);
           emit newRecord(name,dates[i],variation, prevStratPrice, strategyPrice, truncatedStrategyPrice, prices[i-1], prices[i], positions[i],-1);
           strategyPrice=truncatedStrategyPrice;
       }
       return strategyPrice;
 }

   
   
  function advance(bytes32 name, uint32 date, uint64 udlPreviousPrice, uint64 udlPrice, int64 position, uint64 stratPrice) public returns (uint64) {
    int256 variation = calculateVariation(udlPreviousPrice, udlPrice, position);
    uint64 newStrategyPrice;
    uint64 truncatedNewStrategyPrice;
    (newStrategyPrice,truncatedNewStrategyPrice) = calculateValue(variation,stratPrice);
    emit newRecord(name,date,variation, stratPrice, newStrategyPrice, truncatedNewStrategyPrice, udlPreviousPrice, udlPrice, position,1);

    return truncatedNewStrategyPrice;
  }

  function biAdvance(uint32 date, uint64[2] udlPreviousPrice, uint64[2] udlPrice, int64[2] position, uint64 stratPrice) public returns (uint64) {
    int256 variation = calculateVariation(udlPreviousPrice[0], udlPrice[0], position[0])+calculateVariation(udlPreviousPrice[1], udlPrice[1], position[1]);
    uint64 newStrategyPrice;
    uint64 truncatedNewStrategyPrice;
    (newStrategyPrice,truncatedNewStrategyPrice) = calculateValue(variation,stratPrice);
        
    emit succinctBiRecord(date, stratPrice, newStrategyPrice, truncatedNewStrategyPrice, 1);
    emit succinctBiUnder(udlPreviousPrice[0], udlPrice[0], position[0], udlPreviousPrice[1], udlPrice[1], position[1]);

    return truncatedNewStrategyPrice;
  }

 
 function calculateVariation(uint64 pxPre, uint64 pxCur, int64 lastPosit) internal pure returns (int256){
    int256 variation = int256(pxCur) - int256(pxPre);
     
    variation *=  1e32;
    variation /=  pxPre;
    variation *=  int256(lastPosit);
    return variation;
 }


 function calculateValue(int256 variation, uint64 lastValue) internal pure returns (uint64,uint64){
    uint64 newStrategyPrice;
    uint64 truncatedNewStrategyPrice;

    int256 delta = int256(lastValue) * variation;
     
    delta/=1e40;
    newStrategyPrice=uint64(int256(lastValue) +delta);

     
    truncatedNewStrategyPrice = newStrategyPrice/1e4;
    truncatedNewStrategyPrice = truncatedNewStrategyPrice*1e4;
    return (newStrategyPrice,truncatedNewStrategyPrice);
 }

  
  
  
  
 
  
  
  
  
 
  
  
  
  
  

 function hashPosition(uint32 date, int64 position, bytes16 secretPath) public pure returns(bytes32) {
    return(sha256(abi.encodePacked(date,position,secretPath)));
 }
}