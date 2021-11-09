pragma solidity 0.4.24;

 


 
contract MilkMachineHotPotato {

     

     
    struct Potato {
        uint price;
        uint64 startTime;
        uint64 lastPurchaseTime;
        uint32 purchaseCount;
        uint32 priceIncreasePercent;
        uint32 milkProductionMultiplier;
    }


     

     
    uint public constant OWNER_CUT = 200;

     
    uint public constant SPONSOR_CUT = 200;

     
    uint public constant MILK_FUND_CUT = 600;

     
    uint public constant MAX_PRICE_INCREASE_PERCENT = 100;

     
    uint public constant MAX_MILK_PRODUCTION_MULTIPLIER = 8;


     

     
    address public owner;

     
    Potato[] public potatoes;

     
    mapping(address => uint[]) public ownerPotatoes;

     
    mapping(uint => address) potatoIdToOwner;

     
    mapping(uint => address) potatoIdToSponsor;

     
    mapping(uint => uint) potatoIdToOwnerPotatoesIndex;

     
    uint[] public potatoStartTime;

     
    uint public totalMilkProduction;
    uint private totalMilkBalance;
    uint private lastTotalMilkSaveTime;  

     
    mapping(address => uint) public milkProduction;
    mapping(address => uint) public milkBalance;
    mapping(address => uint) private lastMilkSaveTime;  


     

     
    event PotatoSold(uint timestamp, address indexed oldOwner, uint indexed potatoId, uint sellingPrice, uint paymentToOldOwner, address indexed newOwner);


     

     
    constructor() public payable {
        owner = msg.sender;

         
        _createPotato(0.01 ether, 1529175600 - 3 days, 50, 1, owner);
        _createPotato(0.01 ether, 1529175600 + 2 hours - 3 days, 50, 2, owner);
        _createPotato(0.01 ether, 1529175600 + 4 hours - 3 days, 50, 3, owner);
    }

     
    function purchasePotato(uint _potatoId) public payable {
         
        uint initialContractBalance = address(this).balance;

        address oldOwner = potatoIdToOwner[_potatoId];
        address newOwner = msg.sender;

        Potato storage potato = potatoes[_potatoId];
        uint currentPrice = potato.price;

         
        require(now >= potato.startTime);

         
        require(oldOwner != newOwner);

         
        require(newOwner != address(0));

         
        require(newOwner != address(this));

         
        require(msg.value >= currentPrice);

         
        uint ownerEarnings = currentPrice * OWNER_CUT / 10000;
        uint sponsorEarnings = currentPrice * SPONSOR_CUT / 10000;
        uint addToMilkFund = currentPrice * MILK_FUND_CUT / 10000;
        uint paymentToOldOwner = currentPrice - ownerEarnings - sponsorEarnings - addToMilkFund;

         
        potato.price += uint128(currentPrice * potato.priceIncreasePercent / 100);

         
        potato.lastPurchaseTime = uint64(now);

         
        potato.purchaseCount++;

         
        _handleProductionDecrease(oldOwner, potato.milkProductionMultiplier);
        _handleProductionIncrease(newOwner, potato.milkProductionMultiplier);

         
        _transfer(oldOwner, newOwner, _potatoId);

         
        uint bidExcess = msg.value - currentPrice;

         
        if (bidExcess > 0) {
            msg.sender.transfer(bidExcess);
        }

         
        owner.transfer(ownerEarnings);

         
        potatoIdToSponsor[_potatoId].transfer(sponsorEarnings);

         
        oldOwner.transfer(paymentToOldOwner);

         
        emit PotatoSold(now, oldOwner, _potatoId, currentPrice, paymentToOldOwner, newOwner);

         
        uint newContractBalance = address(this).balance;
        assert(newContractBalance - initialContractBalance + 1 >= addToMilkFund);
    }

     
    function sellAllMilk() public {
        _updatePlayersMilk(msg.sender);

        uint sellPrice = computeMilkSellPrice();

        require(sellPrice > 0);

        uint myMilk = milkBalance[msg.sender];
        uint value = myMilk * sellPrice;

        milkBalance[msg.sender] = 0;

        msg.sender.transfer(value);
    }

     
    function createPotato(uint _initialPrice, uint _startTime, uint _priceIncreasePercent, uint _milkProductionMultiplier, address _sponsor) external returns (uint) {
        require(msg.sender == owner);

         
        uint previousPotatoStartTime = potatoStartTime[potatoStartTime.length - 1];
        require(_startTime >= previousPotatoStartTime && _startTime >= now + 6 hours);
        require(_milkProductionMultiplier <= MAX_MILK_PRODUCTION_MULTIPLIER);
        require(_priceIncreasePercent <= MAX_PRICE_INCREASE_PERCENT);

        return _createPotato(_initialPrice, _startTime, _priceIncreasePercent, _milkProductionMultiplier, _sponsor);
    }


     

     
    function potatoTotalSupply() public view returns (uint) {
        return potatoes.length;
    }

     
    function potatoBalanceOf(address _owner) public view returns (uint) {
        return ownerPotatoes[_owner].length;
    }

     
    function getOwnerPotatoes(address _owner) external view returns(uint[]) {
        return ownerPotatoes[_owner];
    }

     
    function getPotato(uint _potatoId) external view returns (
        address _owner,
        address _sponsor,
        uint _price,
        uint _startTime,
        uint _lastPurchaseTime,
        uint _purchaseCount,
        uint _priceIncreasePercent,
        uint _milkProductionMultiplier
    ) {
        Potato storage potato = potatoes[_potatoId];

        return (potatoIdToOwner[_potatoId], potatoIdToSponsor[_potatoId], potato.price, potato.startTime, potato.lastPurchaseTime,
            potato.purchaseCount, potato.priceIncreasePercent, potato.milkProductionMultiplier);
    }

     
    function getState() public view returns (uint, uint, uint, uint, uint, uint, uint) {
        return (totalMilkProduction, milkProduction[msg.sender], milkTotalSupply(), milkBalanceOf(msg.sender), 
            address(this).balance, lastTotalMilkSaveTime, computeMilkSellPrice());
    }

    function milkTotalSupply() public constant returns(uint) {
        return totalMilkBalance + balanceOfTotalUnclaimedMilk();
    }

    function milkBalanceOf(address player) public constant returns(uint) {
        return milkBalance[player] + _balanceOfUnclaimedMilk(player);
    }

    function balanceOfTotalUnclaimedMilk() public constant returns(uint) {
        if (lastTotalMilkSaveTime > 0 && lastTotalMilkSaveTime < block.timestamp) {
            return (totalMilkProduction * (block.timestamp - lastTotalMilkSaveTime));
        }

        return 0;
    }

     
    function computeMilkSellPrice() public view returns (uint) {
        uint supply = milkTotalSupply();

        if (supply == 0) {
            return 0;
        }

        uint index;
        uint lastPotatoStartTime = now;

        while (index < potatoStartTime.length && potatoStartTime[index] < now) {
            lastPotatoStartTime = potatoStartTime[index];
            index++;
        }

        if (now < lastPotatoStartTime + 1 hours) {
            return 0;
        }

        uint timeToMaxValue = 6 hours;

        uint secondsPassed = now - lastPotatoStartTime;
        secondsPassed = secondsPassed <= timeToMaxValue ? secondsPassed : timeToMaxValue;
        uint multiplier = 5000 + 5000 * secondsPassed / timeToMaxValue;

        return address(this).balance / supply * multiplier / 10000;
    }


     

     
    function _createPotato(uint _initialPrice, uint _startTime, uint _priceIncreasePercent, uint _milkProductionMultiplier, address _sponsor) internal returns (uint) {
         
        potatoes.push(Potato(uint128(_initialPrice), uint64(_startTime), 0, 0, uint32(_priceIncreasePercent), uint32(_milkProductionMultiplier)));

         
        uint newPotatoId = potatoes.length - 1;

        potatoIdToSponsor[newPotatoId] = _sponsor;

         
        potatoStartTime.push(_startTime);

         
        _transfer(address(0), _sponsor, newPotatoId);

         
        _handleProductionIncrease(_sponsor, _milkProductionMultiplier);

        return newPotatoId;
    }

     
    function _transfer(address _from, address _to, uint _potatoId) internal {
         
         
        if (_from != address(0)) {
            uint[] storage fromPotatoes = ownerPotatoes[_from];
            uint potatoIndex = potatoIdToOwnerPotatoesIndex[_potatoId];

             
            uint lastPotatoId = fromPotatoes[fromPotatoes.length - 1];

             
            if (_potatoId != lastPotatoId) {
                fromPotatoes[potatoIndex] = lastPotatoId;
                potatoIdToOwnerPotatoesIndex[lastPotatoId] = potatoIndex;
            }

            fromPotatoes.length--;
        }

         
         
        potatoIdToOwner[_potatoId] = _to;

         
        potatoIdToOwnerPotatoesIndex[_potatoId] = ownerPotatoes[_to].length;
        ownerPotatoes[_to].push(_potatoId);
    }

    function _handleProductionIncrease(address _player, uint _amount) internal {
        _updatePlayersMilk(_player);

        totalMilkProduction = SafeMath.add(totalMilkProduction, _amount);
        milkProduction[_player] = SafeMath.add(milkProduction[_player], _amount);
    }

    function _handleProductionDecrease(address _player, uint _amount) internal {
        _updatePlayersMilk(_player);

        totalMilkProduction = SafeMath.sub(totalMilkProduction, _amount);
        milkProduction[_player] = SafeMath.sub(milkProduction[_player], _amount);
    }

    function _balanceOfUnclaimedMilk(address _player) internal view returns (uint) {
        uint lastSave = lastMilkSaveTime[_player];

        if (lastSave > 0 && lastSave < block.timestamp) {
            return (milkProduction[_player] * (block.timestamp - lastSave));
        }

        return 0;
    }

    function _updatePlayersMilk(address _player) internal {
        totalMilkBalance += balanceOfTotalUnclaimedMilk();
        milkBalance[_player] += _balanceOfUnclaimedMilk(_player);
        lastTotalMilkSaveTime = block.timestamp;
        lastMilkSaveTime[_player] = block.timestamp;
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