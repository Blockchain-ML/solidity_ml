pragma solidity ^0.4.25;

contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

   
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

   
  function owner() public view returns(address) {
    return _owner;
  }

   
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

   
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }


   
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function withdrawAllEther() public onlyOwner {  
    _owner.transfer(this.balance);
  }

   
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract blackJack is Ownable {
    mapping (uint => uint) cardsPower;
    uint minBet = 0.01 ether;
    uint maxBet = 0.1 ether;
    uint requiredHouseBankroll = 3 ether;  
    uint autoWithdrawBuffer = 1 ether;  
    mapping (address => bool) public isActive;
    mapping (address => bool) public isPlayerActive;
    mapping (address => bool) public insuranceOption;  
    mapping (address => bool) public insurancePurchased;  
    mapping (address => bool) public splitPossible;
    mapping (address => bool) public isSplit;  
    mapping (address => bool) public isSplitActive;  
    mapping (address => uint) public betAmount;
    mapping (address => uint) public gamestatus;  
    mapping (address => uint) public payoutAmount;
    mapping (address => uint) dealTime;
    mapping (address => uint) blackJackHouseProhibited;
    mapping (address => uint[]) playerCards;
    mapping (address => uint[]) playerCards2;  
    mapping (address => uint[]) houseCards;
    mapping (address => bool) public playerExists;  

    event handEndEvent(uint indexed playerPower, uint indexed housePower, bool indexed playerWin);  
    event blackjackEvent(bool indexed playerBlackjack, bool indexed dealerBlackjack);

    constructor() {
    cardsPower[0] = 11;  
    cardsPower[1] = 2;
    cardsPower[2] = 3;
    cardsPower[3] = 4;
    cardsPower[4] = 5;
    cardsPower[5] = 6;
    cardsPower[6] = 7;
    cardsPower[7] = 8;
    cardsPower[8] = 9;
    cardsPower[9] = 10;
    cardsPower[10] = 10;  
    cardsPower[11] = 10;  
    cardsPower[12] = 10;  
    }

    function contractbalance() public view returns (uint) {
        return uint(address(this).balance);
    }


     
     
     



    function card2PowerConverter(uint[] cards) internal view returns (uint) {  
        uint powerMax = 0;
        uint aces = 0;  
        uint power;
        for (uint i = 0; i < cards.length; i++) {
             power = cardsPower[(cards[i] + 13) % 13];
             powerMax += power;
             if (power == 11) {
                 aces += 1;
             }
        }
        if (powerMax > 21) {  
            for (uint i2=0; i2<aces; i2++) {
                powerMax-=10;
                if (powerMax <= 21) {
                    break;
                }
            }
        }
        return uint(powerMax);
    }


     

    uint randNonce = 0;
    function randgenNewHand() internal returns(uint,uint,uint) {  
         
        randNonce++;
        uint a = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 52;
        randNonce++;
        uint b = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 52;
        randNonce++;
        uint c = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 52;
        return (a,b,c);
      }

    function randgen() internal returns(uint) {  
         
        randNonce++;
        return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 52;  
      }

    modifier requireHandActive(bool truth) {
        require(isActive[msg.sender] == truth);
        _;
    }

    modifier requirePlayerActive(bool truth) {
        require(isPlayerActive[msg.sender] == truth);
        require(insuranceOption[msg.sender] == false);
        _;
    }

    function _play() public payable {  
         
        if (playerExists[msg.sender]) {
            require(isActive[msg.sender] == false);
        }
        else {
            playerExists[msg.sender] = true;
        }
        require(msg.value >= minBet);  
        require(msg.value <= maxBet);
         
        uint a;  
        uint b;
        uint c;
        (a,b,c) = randgenNewHand();
        gamestatus[msg.sender] = 1;
        payoutAmount[msg.sender] = 0;
        isActive[msg.sender] = true;
        isPlayerActive[msg.sender] = true;
        isSplit[msg.sender] = false;
        betAmount[msg.sender] = msg.value;
        dealTime[msg.sender] = now;
        playerCards[msg.sender] = new uint[](0);
        playerCards[msg.sender].push(a);
        playerCards[msg.sender].push(b);
        houseCards[msg.sender] = new uint[](0);
        houseCards[msg.sender].push(c);
        if (cardsPower[(a + 13) % 13] == cardsPower[(b + 13) % 13]) {  
            splitPossible[msg.sender] = true;
        }
        else {
            splitPossible[msg.sender] = false;
        }
        if (cardsPower[(c + 13) % 13] == 11) {
             
            insuranceOption[msg.sender] = true;
        }
        else {
            isBlackjack();
        }
        withdrawToOwnerCheck();
    }

    function _DeclineInsurance() public requireHandActive(true) {
        require(insuranceOption[msg.sender] == true);
        require(playerCards[msg.sender].length == 2);
        require(isSplit[msg.sender] == false);
        require(card2PowerConverter(houseCards[msg.sender]) == 11);
        insuranceOption[msg.sender] = false;
        insurancePurchased[msg.sender] = false;
        isBlackjack();
    }

    function _PurchaseInsurance() public payable requireHandActive(true) {
        require(insuranceOption[msg.sender] == true);
        require(msg.value == betAmount[msg.sender]/2);
        require(playerCards[msg.sender].length == 2);
        require(isSplit[msg.sender] == false);
        require(card2PowerConverter(houseCards[msg.sender]) == 11);
        insuranceOption[msg.sender] = false;
        insurancePurchased[msg.sender] = true;
        isBlackjack();
    }

    function _Split() public payable requireHandActive(true) requirePlayerActive(true) {
        require(msg.value == betAmount[msg.sender]);  
        require(splitPossible[msg.sender] == true);
        require(isSplit[msg.sender] == false);
        require(playerCards[msg.sender].length == 2);
        isSplit[msg.sender] = true;
        isSplitActive[msg.sender] = false;
        uint card1 = playerCards[msg.sender][0];
        uint card2 = playerCards[msg.sender][1];
        playerCards2[msg.sender] = new uint[](0);
        playerCards2[msg.sender].push(card2);
        playerCards[msg.sender][1] = randgen();
         
        if (cardsPower[(card1 + 13) % 13] == 0 || card2PowerConverter(playerCards[msg.sender]) == 21) {  
            uint newCard = randgen();
            playerCards2[msg.sender].push(newCard);
            if (cardsPower[(card2 + 13) % 13] == 0 || card2PowerConverter(playerCards2[msg.sender]) == 21) {  
                isPlayerActive[msg.sender] = false;
                dealerHit();
            }
            else {
                isSplitActive[msg.sender] = true;
            }
        }
    }

    function _DoubleDown() public payable requireHandActive(true) requirePlayerActive(true) {
        require(msg.value == betAmount[msg.sender]);
        require(playerCards[msg.sender].length == 2);
        require(isSplit[msg.sender] == false);
        uint newCard = randgen();
        playerCards[msg.sender].push(newCard);
        betAmount[msg.sender] += msg.value;
        uint handPower1 = card2PowerConverter(playerCards[msg.sender]);
        if (handPower1 > 21) {  
                    processHandEnd(false);
                }
        else {
            assert(handPower1 < 21);  
            isPlayerActive[msg.sender] = false;
            checkGameState();
            }
    }

    function _Hit() public requireHandActive(true) requirePlayerActive(true) {  
        uint a=randgen();
        if (isSplitActive[msg.sender] == true && isSplit[msg.sender] == true) {
            playerCards2[msg.sender].push(a);
        }
        else {
              
            playerCards[msg.sender].push(a);
        }
        checkGameState();
    }

    function _Stand() public requireHandActive(true) requirePlayerActive(true) {  
        if (isSplitActive[msg.sender] == false && isSplit[msg.sender] == true) {  
            isSplitActive[msg.sender] = true;
            uint a=randgen();
            playerCards2[msg.sender].push(a);
        }
        else {
            isPlayerActive[msg.sender] = false;  
        }
        checkGameState();
    }

    function checkGameState() internal requireHandActive(true) {  
         
        if (isPlayerActive[msg.sender] == true) {
            uint handPower1 = card2PowerConverter(playerCards[msg.sender]);
            if (isSplit[msg.sender] == true && isSplitActive[msg.sender] == false) {
                if (handPower1 >= 21) {  
                    uint firstCardHand2 = playerCards2[msg.sender][0];
                    isSplitActive[msg.sender] = true;
                    uint a=randgen();
                    playerCards2[msg.sender].push(a);
                    if (cardsPower[(firstCardHand2 + 13) % 13] == 0 || card2PowerConverter(playerCards2[msg.sender]) == 21) {  
                        isPlayerActive[msg.sender] = false;
                        dealerHit();
                    }
                    else {
                         
                    }
                }
                else {
                     
                }
            }
            else if (isSplit[msg.sender] == true && isSplitActive[msg.sender] == true) {
                uint handPower2 = card2PowerConverter(playerCards2[msg.sender]);
                if (handPower1 > 21 && handPower2 > 21) {  
                    processHandEnd(false);
                }
                else if (handPower2 >= 21) {  
                    isPlayerActive[msg.sender] = false;
                    dealerHit();
                }
                else {
                     
                }
            }
            else {
                if (handPower1 > 21) {  
                    processHandEnd(false);
                }
                else if (handPower1 == 21) {  
                    isPlayerActive[msg.sender] = false;
                    dealerHit();
                }
                else if (handPower1 <21) {
                     
                }
            }
        }
        else if (isPlayerActive[msg.sender] == false) {
            dealerHit();
            }
    }


    function dealerHit() internal requireHandActive(true) requirePlayerActive(false)  {  
        uint[] storage houseCardstemp = houseCards[msg.sender];
        uint[] storage playerCardstemp = playerCards[msg.sender];
        uint[] storage playerCards2temp = playerCards2[msg.sender];

        uint tempCard;
        while (card2PowerConverter(houseCardstemp) < 17) {  
             
            tempCard = randgen();
            if (blackJackHouseProhibited[msg.sender] != 0) {
                while (cardsPower[(tempCard + 13) % 13] == blackJackHouseProhibited[msg.sender]) {  
                    tempCard = randgen();
                }
                blackJackHouseProhibited[msg.sender] = 0;
                }
            houseCardstemp.push(tempCard);
        }
         
        if (isSplit[msg.sender] == true) {
            bool hand1Checked;
            bool hand2Checked;
            bool hand1win;
            bool hand2win;
             
            if (card2PowerConverter(playerCardstemp) > 21) {
                hand1win = false;
                hand1Checked = true;
            }
            if (card2PowerConverter(playerCards2temp) > 21) {
                hand2win = false;
                hand2Checked = true;
            }
             
            if (card2PowerConverter(houseCardstemp) > 21 && hand1Checked == false) {
                hand1win = true;
            }
            if (card2PowerConverter(houseCardstemp) > 21 && hand2Checked == false) {
                hand2win = true;
            }
            if (card2PowerConverter(houseCardstemp) > 21) {   
                if (hand1win && hand2win) {
                    processHandEndSplit(4, 5);  
                }
                else if (hand1win || hand2win) {
                    processHandEndSplit(2, 4);  
                }
                else {
                    assert(hand1win || hand2win);  
                     
                }
            }
            else if (hand1Checked == false && hand2Checked == false) {  
                if (card2PowerConverter(playerCardstemp) == card2PowerConverter(houseCardstemp)) {
                    if (card2PowerConverter(playerCards2temp) == card2PowerConverter(houseCardstemp)) {
                         
                        processHandEndSplit(2, 4);
                    }
                    else if (card2PowerConverter(playerCards2temp) > card2PowerConverter(houseCardstemp)) {
                         
                        processHandEndSplit(3, 5);
                    }
                    else {
                         
                        processHandEndSplit(1, 4);
                    }
                }
                else if (card2PowerConverter(playerCardstemp) > card2PowerConverter(houseCardstemp)) {
                    if (card2PowerConverter(playerCards2temp) == card2PowerConverter(houseCardstemp)) {
                         
                        processHandEndSplit(3, 5);
                    }
                    else if (card2PowerConverter(playerCards2temp) > card2PowerConverter(houseCardstemp)) {
                         
                        processHandEndSplit(4, 5);
                    }
                    else {
                         
                        processHandEndSplit(2, 4);
                    }
                }
                else if (card2PowerConverter(playerCardstemp) < card2PowerConverter(houseCardstemp)) {
                    if (card2PowerConverter(playerCards2temp) == card2PowerConverter(houseCardstemp)) {
                         
                        processHandEndSplit(1, 4);
                    }
                    else if (card2PowerConverter(playerCards2temp) > card2PowerConverter(houseCardstemp)) {
                         
                        processHandEndSplit(2, 4);
                    }
                    else {
                         
                        processHandEnd(false);
                    }
                }
            }
            else if (hand1Checked == false) {
                if (card2PowerConverter(playerCardstemp) == card2PowerConverter(houseCardstemp)) {
                         
                        processHandEndSplit(1, 4);
                    }
                else if (card2PowerConverter(playerCardstemp) > card2PowerConverter(houseCardstemp)) {
                     
                    processHandEndSplit(2, 4);
                }
                else {
                     
                    processHandEnd(false);
                    }
                }
            else if (hand2Checked == false) {
                if (card2PowerConverter(playerCards2temp) == card2PowerConverter(houseCardstemp)) {
                         
                        processHandEndSplit(1, 4);
                    }
                else if (card2PowerConverter(playerCards2temp) > card2PowerConverter(houseCardstemp)) {
                     
                    processHandEndSplit(2, 4);
                }
                else {
                     
                    processHandEnd(false);
                    }
                }
        }
        else {
         
            if (card2PowerConverter(houseCardstemp) > 21 ) {
                processHandEnd(true);
            }
             
            if (card2PowerConverter(playerCardstemp) == card2PowerConverter(houseCardstemp)) {
                 
                msg.sender.transfer(betAmount[msg.sender]);
                payoutAmount[msg.sender]=betAmount[msg.sender];
                gamestatus[msg.sender] = 4;
                isActive[msg.sender] = false;  
            }
            else if (card2PowerConverter(playerCardstemp) > card2PowerConverter(houseCardstemp)) {
                 
                processHandEnd(true);
            }
            else {
                 
                processHandEnd(false);
            }
        }
    }

    function processHandEnd(bool _win) internal {  
        if (_win == false) {
            emit handEndEvent(uint(card2PowerConverter(playerCards[msg.sender])), uint(card2PowerConverter(houseCards[msg.sender])), bool(false));
            }
        else if (_win == true) {
            uint winAmount = betAmount[msg.sender] * 2;
            msg.sender.transfer(winAmount);
            payoutAmount[msg.sender]=winAmount;
            emit handEndEvent(uint(card2PowerConverter(playerCards[msg.sender])), uint(card2PowerConverter(houseCards[msg.sender])), bool(true));
        }
        gamestatus[msg.sender] = 5;
        isActive[msg.sender] = false;

    }

    function processHandEndSplit(uint _betMultiplierReturned, uint _gamestatus) internal {  
        if (_betMultiplierReturned != 0) {
            uint winAmount = betAmount[msg.sender] * _betMultiplierReturned;
            msg.sender.transfer(winAmount);
            payoutAmount[msg.sender]=winAmount;
        }
        gamestatus[msg.sender] = _gamestatus;
        isActive[msg.sender] = false;
}


     

    function isBlackjack() internal returns (bool aceHole){  
         
         
        blackJackHouseProhibited[msg.sender]=0;  
        bool houseIsBlackjack = false;
        bool playerIsBlackjack = false;
         
        uint housePower = card2PowerConverter(houseCards[msg.sender]);  
        if (housePower == 10 || housePower == 11) {
            uint _card = randgen();
            if (housePower == 10) {
                if (cardsPower[_card] == 11) {
                     
                    houseCards[msg.sender].push(_card);  
                    houseIsBlackjack = true;
                }
                else {
                    blackJackHouseProhibited[msg.sender]=uint(11);  
                }
            }
            else if (housePower == 11) {
                if (cardsPower[_card] == 10) {
                     
                    houseCards[msg.sender].push(_card);   
                    houseIsBlackjack = true;
                }
                else{
                    blackJackHouseProhibited[msg.sender]=uint(10);  
                }
            }
        }
         
        uint playerPower = card2PowerConverter(playerCards[msg.sender]);
        if (playerPower == 21) {
            playerIsBlackjack = true;
        }
         
        uint winAmount;
        if (playerIsBlackjack == false && houseIsBlackjack == false) {
             
        }
        else if (playerIsBlackjack == true && houseIsBlackjack == false) {
             
            winAmount = betAmount[msg.sender] * 5/2;  
            if (insurancePurchased[msg.sender] == true) {
                gamestatus[msg.sender] = 7;
            }
            else {
                gamestatus[msg.sender] = 2;
            }
            msg.sender.transfer(winAmount);
            payoutAmount[msg.sender] = betAmount[msg.sender] * 5/2;
            isActive[msg.sender] = false;
            emit blackjackEvent(bool(true), bool(false));
        }
        else if (playerIsBlackjack == true && houseIsBlackjack == true) {
             
            if (insurancePurchased[msg.sender] == true) {
                winAmount = betAmount[msg.sender] * 5/2;
                gamestatus[msg.sender] = 7;
            }
            else {
                winAmount = betAmount[msg.sender];
                gamestatus[msg.sender] = 4;
            }
            msg.sender.transfer(winAmount);
            payoutAmount[msg.sender] = winAmount;
            isActive[msg.sender] = false;
            emit blackjackEvent(bool(true), bool(true));
        }
        else if (playerIsBlackjack == false && houseIsBlackjack == true) {
             
            if (insurancePurchased[msg.sender] == true) {
                winAmount = betAmount[msg.sender] * 3/2;
                gamestatus[msg.sender] = 6;
                msg.sender.transfer(winAmount);
                payoutAmount[msg.sender] = winAmount;
            }
            else {
                gamestatus[msg.sender] = 3;
                }
            isActive[msg.sender] = false;
            emit blackjackEvent(bool(false), bool(true));
        }
        insurancePurchased[msg.sender] = false;
        return false;
    }

    function readCards() external view returns(uint[],uint[],uint[]) {  
        return (playerCards[msg.sender],houseCards[msg.sender],playerCards2[msg.sender]);
    }

    function readPower() external view returns(uint, uint, uint) {  
        return (card2PowerConverter(playerCards[msg.sender]),card2PowerConverter(houseCards[msg.sender]), card2PowerConverter(playerCards2[msg.sender]));
    }

    function donateEther() public payable {
         
    }

    function withdrawToOwnerCheck() internal {  
         
         
        uint houseBalance = address(this).balance;
        if (houseBalance > requiredHouseBankroll + autoWithdrawBuffer) {  
            uint permittedWithdraw = houseBalance - requiredHouseBankroll;  
            address _owner = owner();
            _owner.transfer(permittedWithdraw);
        }
    }
}