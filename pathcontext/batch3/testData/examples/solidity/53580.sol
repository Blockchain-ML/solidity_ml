pragma solidity ^0.4.25;

contract HexBoard3 {

   
  uint8 constant public minTileId= 1;
  uint8 constant public maxTileId = 19;
  uint8 constant public numTiles = 19;

   
  mapping(uint8 => uint8[6]) public tileToNeighbors;
  uint8 constant public nullNeighborValue = 0;

   
  constructor() public {
  }
}

contract JackpotRules {
  using SafeMath for uint256;

  constructor() public {}

   

   
  function _winnerJackpot(uint256 jackpot) public pure returns (uint256) {
    return jackpot.div(2);
  }

   
  function _landholderJackpot(uint256 jackpot) public pure returns (uint256) {
    return (jackpot.mul(2)).div(5);
  }

   
  function _nextPotJackpot(uint256 jackpot) public pure returns (uint256) {
    return jackpot.div(20);
  }

   
  function _teamJackpot(uint256 jackpot) public pure returns (uint256) {
    return jackpot.div(20);
  }
}

library Math {
   
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

   
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

   
  function average(uint256 a, uint256 b) internal pure returns (uint256) {
     
    return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
  }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() public {
        owner = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract PullPayment {
    using SafeMath for uint256;

    mapping(address => uint256) public payments;
    uint256 public totalPayments;

     
    function withdrawPayments() public {
        address payee = msg.sender;
        uint256 payment = payments[payee];

        require(payment != 0);
        require(address(this).balance >= payment);

        totalPayments = totalPayments.sub(payment);
        payments[payee] = 0;

        payee.transfer(payment);
    }

     
    function asyncSend(address dest, uint256 amount) internal {
        payments[dest] = payments[dest].add(amount);
        totalPayments = totalPayments.add(amount);
    }
}

library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);  
        uint256 c = a / b;
         

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract TaxRules {
    using SafeMath for uint256;

    constructor() public {}

     
    function _priceToTax(uint256 price) public pure returns (uint256) {
        return price.div(10);
    }

     

     
    function _jackpotTax(uint256 tax) public pure returns (uint256) {
        return (tax.mul(2)).div(5);
    }

     
    function _totalLandholderTax(uint256 tax) public pure returns (uint256) {
        return (tax.mul(19)).div(50);
    }

     
    function _teamTax(uint256 tax, bool hasReferrer) public pure returns (uint256) {
        if (hasReferrer) {
            return (tax.mul(3)).div(25);
        } else {
            return (tax.mul(17)).div(100);
        }
    }
    
     
    function _p3dSellPercentage(uint256 tokens) public pure returns (uint256) {
        return tokens.div(4);
    }

     
    function _referrerTax(uint256 tax, bool hasReferrer)  public pure returns (uint256) {
        if (hasReferrer) {
            return tax.div(20);
        } else {
            return 0;
        }
    }

     
    function _nextPotTax(uint256 tax) public pure returns (uint256) {
        return tax.div(20);
    }
}

contract Microverse is
    HexBoard3,
    PullPayment,
    Ownable,
    TaxRules,
    JackpotRules {
    using SafeMath for uint256;
    using Math for uint256;

     
    enum Stage {
        DutchAuction,
        GameRounds
    }
    Stage public stage = Stage.DutchAuction;

    modifier atStage(Stage _stage) {
        require(
            stage == _stage,
            "Function cannot be called at this time."
        );
        _;
    }

     
    constructor(uint startingStage) public {
        if (startingStage == uint(Stage.GameRounds)) {
            stage = Stage.GameRounds;
            _startGameRound();
        } else {
            _startAuction();
        }
    }

    mapping(uint8 => address) public tileToOwner;
    mapping(uint8 => uint256) public tileToPrice;
    uint256 public totalTileValue;

    function _changeTilePrice(uint8 tileId, uint256 newPrice) private {
        uint256 oldPrice = tileToPrice[tileId];
        tileToPrice[tileId] = newPrice;
        totalTileValue = (totalTileValue.sub(oldPrice)).add(newPrice);
    }

    event TileOwnerChanged(
        uint8 indexed tileId,
        address indexed oldOwner,
        address indexed newOwner,
        uint256 oldPrice,
        uint256 newPrice
    );

     
     
     
     

     
    HourglassInterface constant P3DContract = HourglassInterface(0x765a944008f08e8366c4ac4c88db63961f65be79);
    
    function _buyP3D(uint256 amount) private {
        P3DContract.buy.value(amount)(0x008d8fF688E895A0607e4135E5e18C22f41D7885);
    }
    
    function _sendP3D(address to, uint256 amount) private {
        P3DContract.transfer(to, amount);
    }
    
    function getP3DBalance() view public returns(uint256) {
        return (P3DContract.balanceOf(address(this)));
    }
    
    function getDivsBalance() view public returns(uint256) {
        return (P3DContract.dividendsOf(address(this)));
    }
    
    function withdrawContractBalance() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        uint256 withdrawableBalance = contractBalance.sub(totalPayments);

         
        require(withdrawableBalance > 0);

        asyncSend(msg.sender, withdrawableBalance);
    }

     
     
     

    event AuctionStarted(
        uint256 startingAuctionPrice,
        uint256 endingAuctionPrice,
        uint256 auctionDuration,
        uint256 startTime
    );

    event AuctionEnded(
        uint256 endTime
    );

    uint256 constant public startingAuctionPrice = 1 ether;
    uint256 constant public endingAuctionPrice = 0.05 ether;
    uint256 constant public auctionDuration = 5 days;  

    uint256 public numBoughtTiles;
    uint256 public auctionStartTime;

    function buyTileAuction(uint8 tileId, uint256 newPrice, address referrer) public payable atStage(Stage.DutchAuction) {
        require(
            tileToOwner[tileId] == address(0) && tileToPrice[tileId] == 0,
            "Can&#39;t buy a tile that&#39;s already been auctioned off"
        );

        uint256 tax = _priceToTax(newPrice);
        uint256 price = getTilePriceAuction();

        require(
            msg.value >= tax.add(price),
            "Must pay the full price and tax for a tile on auction"
        );

         
        _distributeAuctionTax(msg.value, referrer);

        tileToOwner[tileId] = msg.sender;
        _changeTilePrice(tileId, newPrice);

        numBoughtTiles = numBoughtTiles.add(1);

        emit TileOwnerChanged(tileId, address(0), msg.sender, price, newPrice);

        if (numBoughtTiles >= numTiles) {
            endAuction();
        }
    }

     
    function _distributeAuctionTax(uint256 tax, address referrer) private {
        _distributeLandholderTax(_totalLandholderTax(tax));

         
        uint256 totalJackpotTax = _jackpotTax(tax).add(_nextPotTax(tax));
        nextJackpot = nextJackpot.add(totalJackpotTax);

         
        bool hasReferrer = referrer != address(0);
        _buyP3D(_teamTax(tax, hasReferrer));
        asyncSend(referrer, _referrerTax(tax, hasReferrer));
    }

    function getTilePriceAuction() public view atStage(Stage.DutchAuction) returns (uint256) {
        uint256 secondsPassed = 0;

         
        if (now > auctionStartTime) {
            secondsPassed = now.sub(auctionStartTime);
        }

        if (secondsPassed >= auctionDuration) {
            return endingAuctionPrice;
        } else {
            uint256 maxPriceDelta = startingAuctionPrice.sub(endingAuctionPrice);
            uint256 actualPriceDelta = (maxPriceDelta.mul(secondsPassed)).div(auctionDuration);

            return startingAuctionPrice.sub(actualPriceDelta);
        }
    }

    function endAuction() private {
        require(
            numBoughtTiles >= numTiles,
            "Can&#39;t end auction if are unbought tiles"
        );

        stage = Stage.GameRounds;
        _startGameRound();

        emit AuctionEnded(now);
    }

    function _startAuction() private {
        auctionStartTime = now;
        numBoughtTiles = 0;

        emit AuctionStarted(startingAuctionPrice,
                            endingAuctionPrice,
                            auctionDuration,
                            auctionStartTime);
    }

     
     
     

    uint256 constant public startingRoundExtension = 12 hours;
    uint256 constant public halvingVolume = 10 ether;  
    uint256 constant public minRoundExtension = 10 seconds;  

    uint256 public roundNumber = 0;

    uint256 public curExtensionVolume;
    uint256 public curRoundExtension;

    uint256 public roundEndTime;

    uint256 public jackpot;
    uint256 public nextJackpot;

     
    event TilePriceChanged(
        uint8 indexed tileId,
        address indexed owner,
        uint256 oldPrice,
        uint256 newPrice
    );

    event GameRoundStarted(
        uint256 initJackpot,
        uint256 endTime,
        uint256 roundNumber
    );

    event GameRoundExtended(
        uint256 endTime
    );

    event GameRoundEnded(
        uint256 jackpot
    );

     
     
     

    function roundTimeRemaining() public view atStage(Stage.GameRounds) returns (uint256)  {
        if (_roundOver()) {
            return 0;
        } else {
            return roundEndTime.sub(now);
        }
    }

    function _extendRound() private {
        roundEndTime = roundEndTime.max(now.add(curRoundExtension));

        emit GameRoundExtended(roundEndTime);
    }

    function _startGameRound() private {
        curExtensionVolume = 0 ether;
        curRoundExtension = startingRoundExtension;

        jackpot = nextJackpot;
        nextJackpot = 0;

        roundNumber = roundNumber.add(1);

        _extendRound();

        emit GameRoundStarted(jackpot, roundEndTime, roundNumber);
    }

    function _roundOver() private view returns (bool) {
        return now >= roundEndTime;
    }

    modifier duringRound() {
        require(
            !_roundOver(),
            "Round can&#39;t be over!"
        );
        _;
    }

     
    function _logRoundExtensionVolume(uint256 amount) private {
        curExtensionVolume = curExtensionVolume.add(amount);

        if (curExtensionVolume >= halvingVolume) {
            curRoundExtension = curRoundExtension.div(2).max(minRoundExtension);
            curExtensionVolume = 0 ether;
        }
    }

     
     
     

    function endGameRound() public atStage(Stage.GameRounds) {
        require(
            _roundOver(),
            "Round must be over!"
        );

        _distributeJackpot();

        emit GameRoundEnded(jackpot);

        _startGameRound();
    }

    function setTilePrice(uint8 tileId, uint256 newPrice, address referrer)
        public
        payable
        atStage(Stage.GameRounds)
        duringRound {
        require(
            tileToOwner[tileId] == msg.sender,
            "Can&#39;t set tile price for a tile you don&#39;t own!"
        );

        uint256 tax = _priceToTax(newPrice);

        require(
            msg.value >= tax,
            "Must pay tax on new tile price!"
        );

        uint256 oldPrice = tileToPrice[tileId];
        _distributeTax(msg.value, referrer);
        _changeTilePrice(tileId, newPrice);

         
         
        _extendRound();
        _logRoundExtensionVolume(msg.value);

        emit TilePriceChanged(tileId, tileToOwner[tileId], oldPrice, newPrice);
    }

    function buyTile(uint8 tileId, uint256 newPrice, address referrer)
        public
        payable
        atStage(Stage.GameRounds)
        duringRound {
        address oldOwner = tileToOwner[tileId];
        require(
            oldOwner != msg.sender,
            "Can&#39;t buy a tile you already own"
        );

        uint256 tax = _priceToTax(newPrice);

        uint256 oldPrice = tileToPrice[tileId];
        require(
            msg.value >= tax.add(oldPrice),
            "Must pay full price and tax for tile"
        );

         
        asyncSend(oldOwner, tileToPrice[tileId]);
        tileToOwner[tileId] = msg.sender;

        uint256 actualTax = msg.value.sub(oldPrice);
        _distributeTax(actualTax, referrer);

        _changeTilePrice(tileId, newPrice);
        _extendRound();
        _logRoundExtensionVolume(msg.value);

        emit TileOwnerChanged(tileId, oldOwner, msg.sender, oldPrice, newPrice);
    }

     
     
     

    function _distributeJackpot() private {
        uint256 winnerJackpot = _winnerJackpot(jackpot);
        uint256 landholderJackpot = _landholderJackpot(jackpot);
        
         
        uint256 divs = getDivsBalance();
        if (divs > 0) {
            P3DContract.withdraw();
        }
        
         
        landholderJackpot = landholderJackpot + divs;
        
        _distributeWinnerAndLandholderJackpot(winnerJackpot, landholderJackpot);

        _buyP3D(_teamJackpot(jackpot));
        
        nextJackpot = nextJackpot.add(_nextPotJackpot(jackpot));
    }

    function _calculatePriceComplement(uint8 tileId) private view returns (uint256) {
        return totalTileValue.sub(tileToPrice[tileId]);
    }

     
    function _distributeWinnerAndLandholderJackpot(uint256 winnerJackpot, uint256 landholderJackpot) private {
        uint256[] memory complements = new uint256[](numTiles + 1);  
        uint256 totalPriceComplement = 0;

        uint256 bestComplement = 0;
        uint8 lastWinningTileId = 0;
        for (uint8 i = minTileId; i <= maxTileId; i++) {
            uint256 priceComplement = _calculatePriceComplement(i);

             
            if (bestComplement == 0 || priceComplement > bestComplement) {
                bestComplement = priceComplement;
                lastWinningTileId = i;
            }

            complements[i] = priceComplement;
            totalPriceComplement = totalPriceComplement.add(priceComplement);
        }
        uint256 numWinners = 0;
        for (i = minTileId; i <= maxTileId; i++) {
            if (_calculatePriceComplement(i) == bestComplement) {
                numWinners++;
            }
        }
        
         
        uint256 p3dTokens = getP3DBalance();
    
         
        if (numWinners == 1) {
            asyncSend(tileToOwner[lastWinningTileId], winnerJackpot);
            
            if (p3dTokens > 0) {
                _sendP3D(tileToOwner[lastWinningTileId], _p3dSellPercentage(p3dTokens));
            }
        } else {
            for (i = minTileId; i <= maxTileId; i++) {
                if (_calculatePriceComplement(i) == bestComplement) {
                    asyncSend(tileToOwner[i], winnerJackpot.div(numWinners));
                    
                    if (p3dTokens > 0) {
                        _sendP3D(tileToOwner[i], _p3dSellPercentage(p3dTokens));
                    }
                }
            }
        }

         
        for (i = minTileId; i <= maxTileId; i++) {
             
            uint256 landholderAllocation = complements[i].mul(landholderJackpot).div(totalPriceComplement);

            asyncSend(tileToOwner[i], landholderAllocation);
        }
    }

    function _distributeTax(uint256 tax, address referrer) private {
        jackpot = jackpot.add(_jackpotTax(tax));

        _distributeLandholderTax(_totalLandholderTax(tax));
        nextJackpot = nextJackpot.add(_nextPotTax(tax));

         
        bool hasReferrer = referrer != address(0);
        _buyP3D(_teamTax(tax, hasReferrer));
        asyncSend(referrer, _referrerTax(tax, hasReferrer));
    }

    function _distributeLandholderTax(uint256 tax) private {
        for (uint8 tile = minTileId; tile <= maxTileId; tile++) {
            if (tileToOwner[tile] != address(0) && tileToPrice[tile] != 0) {
                uint256 tilePrice = tileToPrice[tile];
                uint256 allocation = tax.mul(tilePrice).div(totalTileValue);

                asyncSend(tileToOwner[tile], allocation);
            }
        }
    }
}

interface HourglassInterface  {
    function() payable external;
    function buy(address _playerAddress) payable external returns(uint256);
    function sell(uint256 _amountOfTokens) external;
    function reinvest() external;
    function withdraw() external;
    function exit() external;
    function dividendsOf(address _playerAddress) external view returns(uint256);
    function balanceOf(address _playerAddress) external view returns(uint256);
    function transfer(address _toAddress, uint256 _amountOfTokens) external returns(bool);
    function stakingRequirement() external view returns(uint256);
}