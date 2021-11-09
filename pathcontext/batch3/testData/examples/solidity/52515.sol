pragma solidity ^0.4.13;

contract Publisher{

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

    event newStrat(bytes32 name, uint32 date);
    event newHiddenRecord(uint32 indexed date, bytes32 hashRecord);
    event newStratDiscloseRecord(uint32 indexed date, bytes32 currentPositionsHash, bytes32 currentUnderlyingPricesHash, uint64 currentIndexValue, bytes16 secret, bytes32 previousHiddenTransactionHash, bytes32 previousRevealTransactionHash);
    event newStratBacktestRecord(uint32 indexed date, bytes32 positionsHash, bytes32 underlyingPricesHash, uint64 price, bytes32 previousBacktestTransactionHash);
    event Authorized(address authorized, uint timestamp);
    event Revoked(address authorized, uint timestamp);
 
    constructor(bytes32 _name, uint32 _date, bytes32[] _underlying) public{
        underlying = _underlying;
        owner = msg.sender;
        delegatinglist[owner] = true;
        name = _name;
        dateInit = _date;
        emit newStrat(_name, _date);
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

     
    function strategybacktest(uint32[] dates, bytes32[] positionsHashes, bytes32[] underlyingPricesHashes, uint64[] stratPrices, bytes32 previousBacktestTransactionHash) public onlyAuthorized {
      require(dates.length == positionsHashes.length);
      require(dates.length == underlyingPricesHashes.length);
      require(dates.length == stratPrices.length);
      for(uint i = 0; i < dates.length; i++) {
        emit newStratBacktestRecord(dates[i], positionsHashes[i], underlyingPricesHashes[i], stratPrices[i],previousBacktestTransactionHash);
      }
    }

    function hashBacktestPositions(uint32 date, int64[] positions) public pure returns(bytes32) {
      return(sha256(abi.encodePacked(date,positions)));
    }

    function hashPositions(uint32 date, int64[] positions, bytes16 secretPath) public pure returns(bytes32) {
      return(sha256(abi.encodePacked(date,positions,secretPath)));
    }

    function hashUnderlyingPrices(uint32 date,int256[] underlyingPrices) public pure returns(bytes32) {
      return(sha256(abi.encodePacked(date,underlyingPrices)));
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

    function revealHiddenPosition(uint32 date, int64[] positions, bytes32 underlyingPricesHashes, uint64 stratPrice, bytes16 secret, bytes32 previousHiddenTransactionHash, bytes32 previousRevealTransactionHash) public onlyAuthorized {
        bytes32 recomputedHash = sha256(abi.encodePacked(date,positions,secret));
        StrategyHiddenState memory matchingHiddenState =  hiddenStates[recomputedHash];
         
        require(recomputedHash == matchingHiddenState.hiddenHash);
        bytes32 positionsHash = sha256(abi.encodePacked(date,positions));

        emit newStratDiscloseRecord(date, positionsHash, underlyingPricesHashes, stratPrice, secret, previousHiddenTransactionHash, previousRevealTransactionHash);

        delete hiddenStates[recomputedHash];
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