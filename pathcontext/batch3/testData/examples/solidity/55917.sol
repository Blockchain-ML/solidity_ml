pragma solidity ^0.4.24;

 
contract Factory {

    address[] public derivatives;
    address owner;


    event NewDerivative(
        address maker,
        bool long,
        uint8 leverage,
        uint256 indexed terminationDate,
        uint256 strikePrice,
        bytes16 underlying,
        uint256 minStake
    );


    constructor()
        public
    {
        owner = msg.sender;
    }


     
    function createDerivative (bool long, uint8 leverage, uint256 dueDate, uint256 strikePrice, bytes16 underlying, uint256 minStake, uint256 takerDeadline)
        payable
        public
    {
        Derivative newDerivative = (new Derivative).value(msg.value)(long, leverage, dueDate, strikePrice, underlying, minStake, takerDeadline);
        derivatives.push(newDerivative);
    }

     
    function createStandardDerivative ()
        payable
        public
    {
        Derivative newDerivative = (new Derivative).value(msg.value)(true, 2, now+70, 100, 0x00, msg.value/5, now + 65);
        derivatives.push(newDerivative);
    }

    function getNumberOfDerivatives()
        public
        view
        returns (uint)
    {
        return derivatives.length;
    }

    function withdraw ()
        public
    {
        require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);
    }
}


contract Derivative {

     

    address factory;

     
    uint8 leverage;
    uint256 public dueDate;
    uint256 strikePrice;
    uint256 public minStake;
    bytes16 underlying;
    bool public makerLong;

     
    mapping(address => uint256) public stakes;
    uint256 public totalStakeTaker;

     
    mapping(address => uint256) public sellPrices;
    address[] sellers;

     
    address maker;

     
    uint8 public noOfTakers;
    uint256 public takerDeadline;

     
    mapping(address => bool) public hasSubmittedPrice;
    uint8 public noOfSubmittedPrices;
    uint256 public previousSubmittedPrice;

     
    address oracleAddress = 0x0;
    uint256 oracleFee = 100000;
    bool oracleRequest;

     
    uint256 public priceAtTermination;
    bool public isTerminated;


     

    modifier hasMaker(bool yes) {
        require((maker != 0) ==  yes);
        _;
    }

    modifier hasTaker(bool yes) {
        require((noOfTakers != 0) == yes);
        _;
    }

    modifier derivativeIsTerminated(bool yes) {
        require(isTerminated == yes);
        _;
    }

    modifier onlyBy(address who) {
        require(who == msg.sender);
        _;
    }

    modifier onlyByParticipants() {
        require(stakes[msg.sender]!=0);
        _;
    }
    
    modifier takerDeadlineNotExceeded() {
        require(takerDeadline > now);
        _;
    }


     

     
    constructor(bool _long,uint8 _leverage,uint256 _dueDate, uint256 _strikePrice, bytes16 _underlying, uint256 _minStake, uint256 _takerDeadline)
        payable
        public
    {
        factory = msg.sender;
        make(_long,_leverage,_dueDate,_strikePrice,_underlying,_minStake,_takerDeadline);
    }


     

     
     
     

     
    function make (bool _long, uint8 _leverage,uint256 _dueDate, uint256 _strikePrice, bytes16 _underlying, uint256 _minStake, uint256 _takerDeadline)
        payable
        public
        hasMaker(false)
         
    {
         
        maker = tx.origin;
        makerLong = _long;
        stakes[maker] = msg.value;

         
        strikePrice = _strikePrice;
        dueDate = _dueDate;
        leverage = _leverage;
        underlying = _underlying;
        minStake = _minStake;
        takerDeadline = _takerDeadline;
    }


     

     
    function changeStrikePrice(uint256 newStrikePrice)
        public
        onlyBy(maker)
        hasTaker(false)
        derivativeIsTerminated(false)
    {
        strikePrice = newStrikePrice;
    }

     
    function changeDueDate(uint256 newDueDate)
        public
        onlyBy(maker)
        hasTaker(false)
        derivativeIsTerminated(false)
    {
        dueDate = newDueDate;
    }
    
     
    function changeTakerDeadline(uint256 newTakerDeadline)
        public
        onlyBy(maker)
        derivativeIsTerminated(false)
    {
        takerDeadline = newTakerDeadline;
    }
    
     
    function reduceStake(uint256 amount)
        public
        onlyBy(maker)
    {
        uint256 remainder = sub(stakes[maker],amount);
        require(remainder > totalStakeTaker);
        stakes[maker] = remainder;
        maker.transfer(amount);
    }

     
     
     

     
    function take ()
        payable
        public
        hasMaker(true)
        derivativeIsTerminated(false)
        takerDeadlineNotExceeded()
    {
        totalStakeTaker += msg.value;
        require(totalStakeTaker <= stakes[maker] && msg.value >= minStake);
        if (stakes[msg.sender] == 0)
        {
            noOfTakers += 1;
        }
        stakes[msg.sender] += msg.value;  
    }


     
     
     

    function sellPosition (uint256 sellPrice)
        public
    {
        sellPrices[msg.sender] = sellPrice;
    }

    function buyPosition (address sellerAddress)
        public
        payable
    {
        require (sellPrices[sellerAddress] != 0);
        require (msg.value == sellPrices[sellerAddress]);
        stakes[msg.sender] = stakes[sellerAddress];
        stakes[sellerAddress] = 0;
        sellerAddress.transfer(msg.value);
    }


     
     
     

     
    function agreedTermination (uint256 submittedPrice)
        public
        onlyByParticipants()
    {
         
        require(!hasSubmittedPrice[msg.sender]);
        if (noOfSubmittedPrices != 0 && previousSubmittedPrice != submittedPrice)
        {
            sendPriceRequestToOracle(underlying, bytes16(dueDate));
            return;
        }
        if (noOfSubmittedPrices == noOfTakers)
        {
            terminate(submittedPrice);
        }
        else
        {
            previousSubmittedPrice = submittedPrice;
            hasSubmittedPrice[msg.sender] = true;
            noOfSubmittedPrices++;
        }
    }


     

     
    function terminate (uint256 price)
        private
        derivativeIsTerminated(false)
    {
         
        priceAtTermination = price;
        isTerminated = true;
    }


     
     
     

     
    function withdraw ()
        public
        derivativeIsTerminated(true)
    {
        uint256 surplus;
        uint256 stakeMemory;
         
        if (msg.sender == maker)
        {
            stakeMemory = stakes[msg.sender];
            stakes[msg.sender] = 0;
            maker = 0;
             
            if (priceAtTermination > strikePrice)
            {
                surplus = sub(mul(priceAtTermination,mul(totalStakeTaker,leverage))/strikePrice , mul(totalStakeTaker,leverage));
                if (surplus > totalStakeTaker)
                    surplus = totalStakeTaker;
                if (makerLong)
                {
                    msg.sender.transfer(add(stakeMemory,surplus));
                }
                else
                {
                    msg.sender.transfer(sub(stakeMemory,surplus));
                }
            }
             
            else
            {
                surplus = sub(mul(totalStakeTaker,leverage) , mul(priceAtTermination,mul(totalStakeTaker,leverage))/strikePrice);
                if (surplus > totalStakeTaker)
                    surplus = totalStakeTaker;
                if (makerLong)
                {
                    msg.sender.transfer(sub(stakeMemory,surplus));
                }
                else
                {
                    msg.sender.transfer(add(stakeMemory,surplus));
                }
            }
            return;
        }
        if (msg.sender != maker && stakes[msg.sender] != 0)
         
        {
             
            stakeMemory = stakes[msg.sender];
            stakes[msg.sender] = 0;
             
            if (priceAtTermination > strikePrice)
            {
                surplus = sub(mul(priceAtTermination,mul(stakeMemory,leverage))/strikePrice , mul(stakeMemory,leverage));
                if (surplus > stakeMemory)
                    surplus = stakeMemory;
                if (!makerLong)
                {
                    msg.sender.transfer(add(stakeMemory,surplus));
                }
                else
                {
                    msg.sender.transfer(sub(stakeMemory,surplus));
                }
            }
             
            else
            {
                surplus = sub(mul(stakeMemory,leverage) , mul(priceAtTermination,mul(stakeMemory,leverage))/strikePrice);
                if (surplus > stakeMemory)
                    surplus = stakeMemory;
                if (!makerLong)
                {
                    msg.sender.transfer(sub(stakeMemory,surplus));
                }
                else
                {
                    msg.sender.transfer(add(stakeMemory,surplus));
                }
            }
        }
    }


     
     
     

     
    function sub (uint256 _a, uint256 _b)
        internal
        pure
        returns (uint256)
    {
        if (_b > _a) return 0;
        return _a - _b;
    }

     
    function mul (uint256 _a, uint256 _b)
        internal
        pure
        returns (uint256)
    {
        if (_a == 0) return 0;
        uint256 c = _a * _b;
        if(c / _a != _b) return 0;
        return c;
    }

     
    function add(uint256 _a, uint256 _b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = _a + _b;
        assert(c >= _a);
        return c;
    }


     
     
     

    function getNow ()
        public
        view
        returns(uint256)
    {
        return(now);
    }

    function balanceOfDerivative()
        public
        view
        returns (uint256)
    {
        return (address(this).balance);
    }

    function getStatus()
        public
        view
        returns(uint8,uint256,uint256,bytes16,uint256,address,bool)
    {
        return(
            leverage,
            dueDate,
            strikePrice,
            underlying,
            minStake,
            maker,
            makerLong
        );
    }


     
     
     

    function sendPriceRequestToOracle (bytes16 _nameOfAsset, bytes16 _date)
        public
        payable
    {
        Oracle o = Oracle(oracleAddress);
        o.receivePriceRequest.value(msg.value)(_nameOfAsset, _date, this.receivePriceFromOracle);
        oracleRequest = true;
    }

     
    function receivePriceFromOracle (uint256 _price)
        public
    {
        terminate(_price);
    }

}


 

contract Oracle {

  function receivePriceRequest(bytes16 _nameOfAsset, bytes16 _date, function(uint256) external _callback)
    public
    payable
  {

  }

}