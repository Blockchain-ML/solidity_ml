pragma solidity ^0.4.13;

contract BiUnderlyingStrategyPublisher{

     
    struct StrategyExplicitexplicitState {
      uint32 date;
      int64[2] position;
      int256 variation;
      uint64 price;
      int8 category;
    }

    struct StrategyHiddenState {
      uint32 date;
      bytes32 hiddenHash;
    }


    address public owner;
    bytes32 public name;       

    bytes10[2] underlying;
    uint32 dateInit;                     

    bool isAlive;

    StrategyExplicitexplicitState explicitState;
    mapping(bytes32 => StrategyHiddenState) private hiddenStates;

    mapping(address=>bool) public delegatinglist;

    PriceFeeder feeder;

    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }

    modifier onlyAuthorized(){
        require(isdelegatinglisted(msg.sender));
        _;
    }

 
    event succinctBiRecord(uint32 indexed date, uint64 stratPrice, uint64 truncatedStratPrice, int category);
    event succinctBiUnder(uint64 prevUnderPrice, uint64 underPrice, int64 position, uint64 secondPrevUnderPrice, uint64 secondUnderPrice, int64 secondPosition);

    event newBiRecord(bytes32 indexed name, uint32 indexed date, int256 stratVariation, uint64 prevStratPrice, uint64 stratPrice, uint64 truncatedStratPrice, uint64 prevUnderPrice, uint64 underPrice, int64 position, uint64 secondPrevUnderPrice, uint64 secondUnderPrice, int64 secondPosition, int category);
    event newStrat(bytes32 indexed name, uint32 indexed date, bytes10[2] underlying, uint64 price, int64[2] position);
    event newHiddenRecord(uint32 indexed date, bytes32 hashRecord);
    event newDiscloseRecord(uint32 indexed date, int64[2] position, bytes16 secretPath);
    event stateReset(bytes32 indexed name, uint32 indexed date, int256 stratVariation, uint64 stratPrice, int64[2] position,int8 category);
    event Authorized(address authorized, uint timestamp);
    event Revoked(address authorized, uint timestamp);
    
    constructor(bytes32 _name, address _priceFeeder, uint32 _date, bytes10[2] _underlying, int64[2] _position, uint64 _price) public{
        owner = msg.sender;
        delegatinglist[owner] = true;
        name = _name;
        feeder = PriceFeeder(_priceFeeder);
        dateInit = _date;
        underlying = _underlying;
         
        explicitState = StrategyExplicitexplicitState({date:_date, position:_position,variation:0,price:_price,category:0});
        emit newStrat(_name, _date,_underlying, _price, _position);
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

    function resetExplicitState(uint32 date, int64[2] position,int256 variation, uint64 price, int8 category) public onlyAuthorized {
      explicitState.date=date;
      explicitState.position=position;
      explicitState.variation=variation;
      explicitState.price=price;
      explicitState.category=category;
      emit stateReset(name, date, variation, price, position, category);
    }

    function getExplicitStrategyState()
      public
      onlyAuthorized
      constant
      returns(uint32 date, int64[2] position,int256 variation, uint64 price,  int8 category)
    {
      return(
        explicitState.date,
        explicitState.position,
        explicitState.variation,
        explicitState.price,
        explicitState.category);
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


     
    function bibatchbacktest(uint32[]dates, uint64[] prices, uint64[] secondPrices, int64[] positions, int64[] secondPositions) public onlyAuthorized {
      require(positions.length == secondPositions.length);
      require(prices.length == secondPrices.length);
      
      uint batchlength =positions.length;
       
      require(batchlength >= 2);
      require(dates.length==batchlength && prices.length==batchlength);

      int64[2] storage strategyInitPosition = explicitState.position;
      uint32 strategyInitDate = explicitState.date;
      uint64 strategyInitPrice = explicitState.price;

       
      require(strategyInitPosition[0]==positions[0]);
      require(strategyInitPosition[1]==secondPositions[0]);

      require(strategyInitDate==dates[0]);

      uint64 strategyPrice = StrategyLib.libbibatchbacktest(strategyInitPrice,dates,prices,secondPrices, positions, secondPositions);

       
       
      explicitState.position[0] = positions[batchlength-1];
      explicitState.position[1] = secondPositions[batchlength-1];
      explicitState.date = dates[batchlength-1];
      explicitState.price = strategyPrice;
    }

    function addExplicitPosition(uint32 date, int64[2] position) public onlyAuthorized {
 
       
 
 
 
 
 
       
       
 
 
 
    }

    function hashPosition(uint32 date, int64[2] position, bytes16 secretPath) public pure returns(bytes32) {
      return(sha256(abi.encodePacked(date,position,secretPath)));
    }

    function addHiddenPosition(uint32 _date, bytes32 _hashRecord) public onlyAuthorized {
        StrategyHiddenState memory hiddenState = StrategyHiddenState({date:_date, hiddenHash:_hashRecord});
        hiddenStates[_hashRecord] = hiddenState;
        emit newHiddenRecord(_date, _hashRecord);
    }

    function deleteHiddenPosition(uint32 date, int64[2] position, bytes16 secretPath) public onlyAuthorized {
        bytes32 recomputedHash = sha256(abi.encodePacked(date,position,secretPath));
        delete hiddenStates[recomputedHash];
    }

    function revealHiddenPosition(uint32 date, int64[2] position, bytes16 secretPath) public onlyAuthorized {
 
 

 
 

 
 
 
         
 
 
 
 
    }

}

contract PriceFeeder{
    address public owner;
    bytes15 name;

    struct FeederState {
        uint32 previousDate;
        uint64 previousPrice;
        uint32 date;
        uint64 price;
    }

    event newPrice(uint32 indexed date, bytes10 indexed underlying, uint64 price);

    mapping(bytes10 => FeederState) public priceData;

    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }

    constructor(bytes15 _name) public{
        owner = msg.sender;
        name = _name;
    }

    function updatePrice(bytes10 underlying, uint32 date, uint64 price, uint32 previousDate) onlyOwner public{
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


    function getState(bytes10 underlying) public constant returns (uint32 date, uint64 price, uint32 previousDate, uint64 previousPrice){
      FeederState storage record = priceData[underlying];
      return (record.date, record.price, record.previousDate, record.previousPrice);
    }

    function getDate(bytes10 underlying) public constant returns (uint32){
      FeederState storage record = priceData[underlying];
      return record.date;
    }

    function getPrice(bytes10 underlying) public constant returns (uint64){
      FeederState storage record = priceData[underlying];
      return record.price;
    }

    function getPreviousDate(bytes10 underlying) public constant returns (uint32){
      FeederState storage record = priceData[underlying];
      return record.previousDate;
    }

    function getPreviousPrice(bytes10 underlying) public constant returns (uint64){
      FeederState storage record = priceData[underlying];
      return record.previousPrice;
    }
}

library StrategyLib{
   
  event newRecord(bytes32 indexed name, uint32 indexed date, int256 stratVariation, uint64 prevStratPrice, uint64 stratPrice, uint64 truncatedStratPrice, uint64 prevUnderPrice, uint64 underPrice, int64 position,int category);
  event newBiRecord(bytes32 indexed name,uint32 indexed date,int256 stratVariation, uint64 prevStratPrice, uint64 stratPrice, uint64 truncatedStratPrice, uint64 prevUnderPrice, uint64 underPrice, int64 position, uint64 secondPrevUnderPrice, uint64 secondUnderPrice, int64 secondPosition, int category);
  event succinctBiRecord(uint32 indexed date, uint64 stratPrice, uint64 truncatedStratPrice,int category);
  event succinctBiUnder(uint64 prevUnderPrice, uint64 underPrice, int64 position, uint64 secondPrevUnderPrice, uint64 secondUnderPrice, int64 secondPosition);

     
  function libbibatchbacktest(uint64 strategyInitPrice, uint32[] dates, uint64[] prices, uint64[] secondPrices, int64[] positions, int64[] secondPositions) public returns (uint64) {
       uint64 strategyPrice = strategyInitPrice;
       uint64 truncatedStrategyPrice;
        
       for(uint8 i=1; i<dates.length; i++){
            
           int256 variation = calculateVariation(prices[i-1], prices[i], positions[i]) + calculateVariation(secondPrices[i-1], secondPrices[i], secondPositions[i]);
           uint64 prevStratPrice = strategyPrice;
           (strategyPrice,truncatedStrategyPrice) = calculateValueMantisseTrick(variation, strategyPrice);
            
            
           emit succinctBiRecord(dates[i], strategyPrice, truncatedStrategyPrice,-1);
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

 
 function calculateVariation(uint64 pxPre, uint64 pxCur, int64 lastPosit) internal pure returns (int256){
    int256 variation = int256(pxCur) - int256(pxPre);
     
    variation *=  1e32;
    variation /=  pxPre;
    variation *=  int256(lastPosit);
    return variation;
 }

 function calculateValueMantisseTrick(int256 variation, uint64 lastValue) internal pure returns (uint64,uint64){
    uint64 newStrategyPrice;
    uint64 truncatedNewStrategyPrice;

    int256 delta = int256(lastValue) * variation;
     
    delta/=1e44;
    newStrategyPrice=uint64(int256(lastValue) +delta);

     
    truncatedNewStrategyPrice = newStrategyPrice/1e8;
    truncatedNewStrategyPrice = truncatedNewStrategyPrice*1e8+1;
    return (newStrategyPrice,truncatedNewStrategyPrice);
 }

 function calculateValue(int256 variation, uint64 lastValue) internal pure returns (uint64,uint64){
    uint64 newStrategyPrice;
    uint64 truncatedNewStrategyPrice;

    int256 delta = int256(lastValue) * variation;
     
    delta/=1e44;
    newStrategyPrice=uint64(int256(lastValue) +delta);

     
    truncatedNewStrategyPrice = newStrategyPrice/1e8;
    truncatedNewStrategyPrice = truncatedNewStrategyPrice*1e8;
    return (newStrategyPrice,truncatedNewStrategyPrice);
 }

 function hashPosition(uint32 date, int64 position, bytes16 secretPath) public pure returns(bytes32) {
    return(sha256(abi.encodePacked(date,position,secretPath)));
 }
}