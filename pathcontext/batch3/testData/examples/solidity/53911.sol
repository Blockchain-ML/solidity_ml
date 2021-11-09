pragma solidity ^0.4.24;

 
 
library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        return a / b;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20 {
    mapping (address => uint256) public balanceOf;
    function transfer(address _to, uint256 _value) public;
    function sale(address to, uint256 value) public;
}

contract Sale {
    struct Player {
        address addr;
        uint256 etherInvested;
        bool notFirstTime;
    }

    uint public preSaleEnd = 1527120000;  
    uint public saleEnd1 = 1528588800;  
    uint public saleEnd2 = 1529971200;  
    uint public saleEnd3 = 1531267200;  
    uint public eventSaleEnd = 1537920000;  
    uint public saleEnd4 = 1539129600;  

    uint256 public saleExchangeRate1 = 17500;
    uint256 public saleExchangeRate2 = 10000;
    uint256 public saleExchangeRate3 = 8750;
    uint256 public saleExchangeRate4 = 7778;
    uint256 public saleExchangeRate5 = 7368;
    
    uint256 public volumeType1 = 1429 * 10 ** 16;  
    uint256 public volumeType2 = 7143 * 10 ** 16;
    uint256 public volumeType3 = 14286 * 10 ** 16;
    uint256 public volumeType4 = 42857 * 10 ** 16;
    uint256 public volumeType5 = 71429 * 10 ** 16;
    uint256 public volumeType6 = 142857 * 10 ** 16;
    uint256 public volumeType7 = 428571 * 10 ** 16;
    
    uint256 public minEthValue = 10 ** 15;  
    
    using SafeMath for uint256;
    uint256 public maxSale;
    uint256 public totalSaled;
    ERC20 public Token;
    address public ETHWallet;

    address public creator;

    mapping (address => uint256) public heldTokens;
    mapping (address => uint) public heldTimeline;

    uint256 public minEthValueForGame = 25 * 10 ** 15;  
    mapping(address => Player) public players;  
    Player[] arrPlayers;  
    address lastPersonParticipated = creator;  
    uint256 public timestamp;
    bool public hasGameOver = false;

    uint256 public gameTotalEtherInvested = 0;  
    uint256 public mainGamePot = 0;  
    uint256 public airdropPot = 0;  
    uint256 public airdropChance = 0;  

    uint256 public mainGameFee = 2;  
    uint256 public airdropFee = 1;  
    uint256 public referralFee = 10;  
    uint256 public referrerBonus = 10;  
    uint256 public winnerReward = 50;  
    uint256 public maxTimeInHours = 6 hours;
    uint256 public timePerETH = 30 seconds;

    event Contribution(address from, uint256 amount);
    event ParticipateGame(address from, uint256 ethForMainGame, uint256 ethForAirdrop);
    event Referral(address referrer, address referredAddress, uint256 rewardGiven);
    event GameOver(address winner, uint256 rewardGained, uint256 tokenDistributedToAll);

    constructor(address _wallet, address _token_address) public {
        ETHWallet = _wallet;
        creator = msg.sender;
        Token = ERC20(_token_address);
        maxSale = Token.balanceOf(_token_address);  
        timestamp = now;
    }

    function () external payable {
        buy();
    }

     
     
    function contribute() external payable {
        buy();
    }
    
    function buy() internal {
        require(msg.value>=minEthValue, "Cannot buy with less than min ETH");
        require(now < saleEnd4, "Cannot sell after the sale ended");  

        uint256 amount = conversion(msg.value);
        uint256 total = totalSaled + amount;
        
        require(total<=maxSale, "Cannot sell more than max");
        
        totalSaled = total;

        ETHWallet.transfer(msg.value);
        Token.sale(msg.sender, amount);
        emit Contribution(msg.sender, amount);
    }
    function getYumWithETH(uint256 value) private {
        require(value<=msg.value, "value cannot be higher than it&#39;s original value");

        uint256 amount = conversion(value);
        uint256 total = totalSaled + amount;
        
        require(total<=maxSale, "Cannot sell more than max");
        
        totalSaled = total;

        ETHWallet.transfer(value);
        Token.sale(msg.sender, amount);
        emit Contribution(msg.sender, amount);
    }
    function gameoverGetYUM(uint256 value) private returns(uint256) {
        uint256 amount = conversion(value);
        uint256 total = totalSaled + amount;
        
        require(total<=maxSale, "Cannot sell more than max");
        
        totalSaled = total;

        ETHWallet.transfer(value);
        Token.sale(this, amount);
        emit Contribution(this, amount);
        return amount;
    }
    function conversion(uint256 value) public view returns(uint256) {
        uint256 amount;
        uint256 exchangeRate;
        if(now < preSaleEnd) {
            exchangeRate = saleExchangeRate1;
        } else if(now < saleEnd1) {
            exchangeRate = saleExchangeRate2;
        } else if(now < saleEnd2) {
            exchangeRate = saleExchangeRate3;
        } else if(now < eventSaleEnd) {
            exchangeRate = saleExchangeRate4;
        } else {  
            exchangeRate = saleExchangeRate5;
        }
        
        amount = value.mul(exchangeRate).div(10 ** 10);
        
        if(value >= volumeType7) {
            amount = amount * 180 / 100;
        } else if(value >= volumeType6) {
            amount = amount * 160 / 100;
        } else if(value >= volumeType5) {
            amount = amount * 140 / 100;
        } else if(value >= volumeType4) {
            amount = amount * 130 / 100;
        } else if(value >= volumeType3) {
            amount = amount * 120 / 100;
        } else if(value >= volumeType2) {
            amount = amount * 110 / 100;
        } else if(value >= volumeType1) {
            amount = amount * 105 / 100;
        }
        return amount;
    }

     
    function changeCreator(address _creator) external {
        require(msg.sender==creator, "Changed the creator");
        creator = _creator;
    }

    function getTimeLeft() public view returns(uint256) {
        uint256 timeLeft = now.sub(timestamp);
        if (timeLeft >= maxTimeInHours) {
            return 0;
        }
        return maxTimeInHours.sub(timeLeft);
    }

    function participateEvent(address referredAddress) external payable {
        require(msg.value >= minEthValueForGame, "the amount of ETH invested is less than minimum participating fee");
        require(!hasGameOver, "The game has already been over");
        
        uint256 timePassed = now.sub(timestamp);
         
        if (timePassed >= maxTimeInHours || now >= eventSaleEnd)
        {
            gameOver();
        }
        else {
            distribute(msg.sender, msg.value, referredAddress);
        }
    }

    function gameOver() public {
        require(!hasGameOver, "The game has already been over");
        uint256 timePassed = now.sub(timestamp);
        require(timePassed >= maxTimeInHours || now >= eventSaleEnd, "game must have triggered the following conditions");
        uint256 amountForWinner = mainGamePot.mul(winnerReward).div(100);
        uint256 remainETH = mainGamePot.sub(amountForWinner);
        uint256 TotalYUMToDistribute = gameoverGetYUM(remainETH);
        for (uint256 i = 0; i < arrPlayers.length; i = i.add(1))
        {
            uint256 tokenToGive = TotalYUMToDistribute.mul(arrPlayers[i].etherInvested).div(gameTotalEtherInvested);
            Token.transfer(arrPlayers[i].addr, tokenToGive);
        }
        hasGameOver = true;
    }

    function distribute(address sender, uint256 value, address referredAddress) private {

        if (!players[sender].notFirstTime) {
            players[sender].addr == sender;
            arrPlayers.push(players[sender]);
        }
        players[sender].etherInvested = players[sender].etherInvested.add(value);
        lastPersonParticipated = sender;

        uint256 distributionForMainGame = value.mul(mainGameFee).div(100);
        uint256 distributionForAirdrop = value.mul(airdropFee).div(100);
        uint256 remainingEther = value.sub(distributionForMainGame).sub(distributionForAirdrop);

         
        gameTotalEtherInvested = gameTotalEtherInvested.add(value);
        mainGamePot = mainGamePot.add(distributionForMainGame);
        
         
        airdropPot = airdropPot.add(distributionForAirdrop);
        airdropChance = airdropChance.add(1);
        airdrop(sender, value);

         
        if (referredAddress != address(0) && referredAddress != msg.sender)
        {
            uint256 distributionToReferredAddress = value.mul(referralFee).div(100);
            uint256 tokenBonusByReferral = value.mul(referrerBonus).div(100);
            remainingEther = remainingEther.sub(distributionToReferredAddress);
            referredAddress.transfer(distributionToReferredAddress);
            getYumWithETH(tokenBonusByReferral);
        }
        
        uint256 timeAdded = value.div(minEthValueForGame).mul(timePerETH);
        timestamp = timestamp.add(timeAdded);
        if (now.sub(timestamp) >= maxTimeInHours)
            timestamp = now;
        getYumWithETH(remainingEther);
        uint256 amountForWinner = mainGamePot.mul(winnerReward).div(100);
        uint256 remainTotalETH = mainGamePot.sub(amountForWinner);
        uint256 TotalYUMToDistribute = conversion(remainTotalETH);
        require(totalSaled.add(TotalYUMToDistribute)<=maxSale, "Cannot distribute YUM token more than its maxsale");
        emit ParticipateGame(sender, distributionForMainGame, distributionForAirdrop);
    }

    function airdrop(address sender, uint256 amountInvested) private {
        uint256 seed = uint256(keccak256(abi.encodePacked((block.timestamp)
        .add(block.difficulty)
        .add((uint256(keccak256(abi.encodePacked(
            block.coinbase)))) / 
            (now))
            .add(block.gaslimit)
            .add((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add(block.number)
        )));

        if((seed - ((seed / 1000) * 1000)) < airdropChance)
        {
            uint256 amountReceive = 0;
             
            if (amountInvested >= 10 * 10 ** 18) {
                amountReceive = airdropPot;
            }
             
            else if (amountInvested >= 1 * 10 ** 18) {
                amountReceive = airdropPot.mul(75).div(100);
            }
              
            else if (amountInvested >= 1 * 10 ** 17) {
                amountReceive = airdropPot.mul(50).div(100);
            }
              
            else if (amountInvested >= 1 * 10 ** 16) {
                amountReceive = airdropPot.mul(25).div(100);
            }
             
            else {
                amountReceive = airdropPot.mul(10).div(100);
            }

            airdropPot = airdropPot.sub(amountReceive);
            sender.transfer(amountReceive);
            airdropChance = 0;
        }
    }

    function etherDonation(bool trueForMainFalseForAirdrop) external payable {
        if (trueForMainFalseForAirdrop)
        {
            mainGamePot.add(msg.value);
        }
        else
        {
            airdropPot.add(msg.value);
        }
    }
}