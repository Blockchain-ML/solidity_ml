pragma solidity ^0.4.18;  


contract EtherAsteroid{
  using SafeMath for uint;
  uint16 public xPos; 
  uint16 public yPos;
  int256 public xVel=0; 
  int256 public yVel=0;
  uint public Nfuel=0; 
  uint public Sfuel=0; 
  uint public Efuel=0; 
  uint public Wfuel=0; 
  uint public FUEL_BURN_PERCENT; 
  uint16 public MAXVALUE=0; 
  uint public constant NUM_SECTORS=64; 
  uint16 public sectorDivisor;
  uint public lastBurn; 
  uint public BURN_INTERVAL=1 hours; 
  address public ceo;
  FuelBuys public fuelMarket;
  bool public initialized=false;
  uint public constant PLANET_START_PRICE=0.05 ether;
  struct Planet{
    address owner;
    uint price;
  }
  uint[NUM_SECTORS][NUM_SECTORS] public planetLocations; 
  Planet[10] public planets; 


  function EtherAsteroid(){
       
      MAXVALUE-=1;
      xPos=MAXVALUE/2;
      yPos=MAXVALUE/2;
      sectorDivisor=uint16(MAXVALUE/NUM_SECTORS);
      lastBurn=now;
      ceo=msg.sender;
      fuelMarket=new FuelBuys();
      fuelMarket.setFuelDestination(address(this));
      for(uint i=1;i<planets.length;i++){
        planets[i]=Planet({owner:address(0),price:PLANET_START_PRICE});
      }
       
  }
  function setFuelContract(address fuel) public{
    require(msg.sender==ceo);
    fuelMarket=FuelBuys(fuel);
  }
   
  function addFuelFree(uint n,uint s,uint e,uint w) public{
    Nfuel+=n;
    Sfuel+=s;
    Efuel+=e;
    Wfuel+=w;
    updatePosition();
  }

  function addFuel(uint n,uint s,uint e,uint w,uint fuelBought) public payable{
    require(msg.sender==address(fuelMarket));
    require(initialized);
     
    require(fuelBought>=n.add(s).add(e).add(w));  
    Nfuel+=n;
    Sfuel+=s;
    Efuel+=e;
    Wfuel+=w;
    updatePosition();

  }
   
  function () public payable {}

  function updatePosition() public{
    while(lastBurn.add(BURN_INTERVAL)<now){
      xPos=uint16(xPos+xVel); 
      yPos=uint16(yPos+yVel);
      processCollision();

       
      uint wBurn=Wfuel.mul(FUEL_BURN_PERCENT).div(100);
      uint eBurn=Efuel.mul(FUEL_BURN_PERCENT).div(100);
      uint nBurn=Nfuel.mul(FUEL_BURN_PERCENT).div(100);
      uint sBurn=Sfuel.mul(FUEL_BURN_PERCENT).div(100);
      xVel+=int(wBurn)-int(eBurn);
      yVel+=int(sBurn)-int(nBurn);
      Wfuel=Wfuel.sub(wBurn);
      Efuel=Efuel.sub(eBurn);
      Nfuel=Nfuel.sub(nBurn);
      Sfuel=Sfuel.sub(sBurn);

      lastBurn=lastBurn.add(BURN_INTERVAL);
    }
  }
  function processCollision() public{
    uint planetId=planetLocations[xPos/sectorDivisor][yPos/sectorDivisor];
    if(planetId!=0){
       
      planets[planetId].owner.send(this.balance);
      initialized=false;
    }
  }
  function purchasePlanet(uint index) public payable{
    Planet storage planet=planets[index];
    require(msg.value >= planet.price);
    uint256 sellingPrice=planet.price;
    uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);
    uint256 payment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 90), 100));
     
     
    if(planet.owner!=0x0){
        planet.owner.send(payment);
    }
    planet.price= SafeMath.div(SafeMath.mul(sellingPrice, 120), 90);  
    planet.owner=msg.sender; 
    msg.sender.transfer(purchaseExcess); 
  }
}
contract FuelBuys{
  using SafeMath for uint;
  mapping(address => uint256) public tokenBalanceLedger_;
  mapping(address => int256) public payoutsTo_;
  uint256 public tokenSupply_ = 0;
  uint256 public profitPerShare_;
  uint8 constant public decimals = 18;
  uint256 constant internal magnitude = 2**64;
  uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
  uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;
   
  uint public constant POT_TAKE=20; 
  uint public constant DEV_FEE=3; 
  uint public constant REF_FEE=2; 
  EtherAsteroid fuelDestination;

  event onTokenPurchase(
      address indexed customerAddress,
      uint256 incomingEthereum,
      uint256 tokensMinted,
      address indexed referredBy
  );

  function setFuelDestination(address dest){
    fuelDestination=EtherAsteroid(dest);
  }
  function buyFuel(uint n,uint s,uint e,uint w, address referral) public payable{
    uint dfee=msg.value.mul(DEV_FEE).div(100);
    uint rfee=msg.value.mul(REF_FEE).div(100);
    uint pfee=msg.value.mul(POT_TAKE).div(100);
    uint fuelPay=msg.value.sub(dfee).sub(rfee).sub(pfee);

    uint fuelBought=purchaseTokens(fuelPay); 

    fuelDestination.addFuel(n,s,e,w,fuelBought);

     
    fuelDestination.send(pfee);
    fuelDestination.ceo().send(dfee);
    if(referral!=0x0){
      referral.send(rfee);
    }
    else{
      fuelDestination.ceo().send(rfee);
    }
  }
  function purchaseTokens(uint _incomingEthereum) private returns(uint256)
    {
        address _customerAddress = msg.sender;
         
        uint256 _dividends = _incomingEthereum; 
         
        uint256 _amountOfTokens = ethereumToTokens_(_incomingEthereum); 
        uint256 _fee = _dividends * magnitude;

        require(_amountOfTokens.add(tokenSupply_) > tokenSupply_);

         
        if(tokenSupply_ > 0){

             
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);

             
            profitPerShare_ += (_dividends * magnitude / (tokenSupply_));

             
            _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));

        } else {
             
            tokenSupply_ = _amountOfTokens;
        }

         
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

         
        int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
        payoutsTo_[_customerAddress] += _updatedPayouts;

         
        onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, 0);

        return _amountOfTokens;
    }
  function withdraw() public
{
     
    address _customerAddress = msg.sender;
    uint256 _dividends = myDividends();
    require(_dividends>0);

     
    payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

     
    _customerAddress.transfer(_dividends);
}
function myDividends()
    public
    view
    returns(uint256)
{
    return dividendsOf(msg.sender) ;
}
  function dividendsOf(address _customerAddress)
    view
    public
    returns(uint256)
{
    return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
}
  function ethereumToTokens_(uint256 _ethereum)
    public
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