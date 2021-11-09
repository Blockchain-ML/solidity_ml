pragma solidity ^0.4.25;


contract FckDice {
     

     
     
     
    uint public HOUSE_EDGE_OF_TEN_THOUSAND = 98;
    uint public HOUSE_EDGE_MINIMUM_AMOUNT = 0.0003 ether;

     
     
    uint public MIN_JACKPOT_BET = 0.1 ether;

     
    uint public JACKPOT_MODULO = 1000;
    uint public JACKPOT_FEE = 0.001 ether;

     
    uint constant MIN_BET = 0.01 ether;
    uint constant MAX_AMOUNT = 300000 ether;

     
     
     
     
     
     
     
     
     
    uint constant MAX_MODULO = 255;

     
     
     
     
     
     
     
     
     
     
    uint constant MAX_MASK_MODULO = 40;

     
    uint constant MAX_BET_MASK = 2 ** (MAX_MASK_MODULO * 6);

     
     
     
     
     
     
    uint constant BET_EXPIRATION_BLOCKS = 250;

     
     
     

     
    address public owner1;
    address public owner2;
     

     
    uint public maxProfit;

     
    address public secretSigner;

     
    uint128 public jackpotSize;

     
     
    uint128 public lockedInBets;

     
    struct Bet {
         
        uint amount;
         
        uint8 modulo;
         
         
        uint8 rollUnder;
         
        uint40 placeBlockNumber;
         
        uint240 mask;
         
        address gambler;
    }

     
    mapping(uint => Bet) bets;

     
    address public croupier;

     
    event FailedPayment(address indexed beneficiary, uint amount);
    event Payment(address indexed beneficiary, uint amount);
    event JackpotPayment(address indexed beneficiary, uint amount);

     
    event Commit(uint commit);

     
    constructor (address _owner1, address _owner2,
        address _secretSigner, address _croupier, uint _maxProfit
    ) public payable {
        owner1 = _owner1;
        owner2 = _owner2;
        secretSigner = _secretSigner;
        croupier = _croupier;
        require(_maxProfit < MAX_AMOUNT, "maxProfit should be a sane number.");
        maxProfit = _maxProfit;
    }

     
    modifier onlyOwner {
        require(msg.sender == owner1 || msg.sender == owner2, "OnlyOwner methods called by non-owner.");
        _;
    }

     
    modifier onlyCroupier {
        require(msg.sender == croupier, "OnlyCroupier methods called by non-croupier.");
        _;
    }

     
     
     
     
     
     
     
     
     
     

     
     
    function() public payable {
    }

    function setOwner1(address o) external onlyOwner {
        require(o != address(0));
        require(o != owner1);
        require(o != owner2);
        owner1 = o;
    }

    function setOwner2(address o) external onlyOwner {
        require(o != address(0));
        require(o != owner1);
        require(o != owner2);
        owner2 = o;
    }

     
    function setSecretSigner(address newSecretSigner) external onlyOwner {
        secretSigner = newSecretSigner;
    }

     
    function setCroupier(address newCroupier) external onlyOwner {
        croupier = newCroupier;
    }

     
    function setMaxProfit(uint _maxProfit) public onlyOwner {
        require(_maxProfit < MAX_AMOUNT, "maxProfit should be a sane number.");
        maxProfit = _maxProfit;
    }

     
    function increaseJackpot(uint increaseAmount) external onlyOwner {
        require(increaseAmount <= address(this).balance, "Increase amount larger than balance.");
        require(jackpotSize + lockedInBets + increaseAmount <= address(this).balance, "Not enough funds.");
        jackpotSize += uint128(increaseAmount);
    }

     
    function withdrawFunds(address beneficiary, uint withdrawAmount) external onlyOwner {
        require(withdrawAmount <= address(this).balance, "Increase amount larger than balance.");
        require(jackpotSize + lockedInBets + withdrawAmount <= address(this).balance, "Not enough funds.");
        sendFunds(beneficiary, withdrawAmount, withdrawAmount);
    }

     
     
    function kill() external onlyOwner {
        require(lockedInBets == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(owner1);
    }

    function getBetInfo(uint commit) external view returns (uint amount, uint8 modulo, uint8 rollUnder, uint40 placeBlockNumber, uint240 mask, address gambler) {
        Bet storage bet = bets[commit];
        amount = bet.amount;
        modulo = bet.modulo;
        rollUnder = bet.rollUnder;
        placeBlockNumber = bet.placeBlockNumber;
        mask = bet.mask;
        gambler = bet.gambler;
    }

     

     
     
     
     
     
     
     

     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
    function placeBet(uint betMask, uint modulo, uint commitLastBlock, uint commit, bytes32 r, bytes32 s) external payable {
         
        Bet storage bet = bets[commit];
        require(bet.gambler == address(0), "Bet should be in a &#39;clean&#39; state.");

         
        uint amount = msg.value;
        require(modulo > 1 && modulo <= MAX_MODULO, "Modulo should be within range.");
        require(amount >= MIN_BET && amount <= MAX_AMOUNT, "Amount should be within range.");
        require(betMask > 0 && betMask < MAX_BET_MASK, "Mask should be within range.");

         
        require(block.number <= commitLastBlock, "Commit has expired.");
        bytes32 signatureHash = keccak256(abi.encodePacked(commitLastBlock, commit));
        require(secretSigner == ecrecover(signatureHash, 27, r, s), "ECDSA signature is not valid.");

        uint rollUnder;
        uint mask;

        if (modulo <= MAX_MASK_MODULO) {
             
             
             
             
            rollUnder = ((betMask * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO;
            mask = betMask;
        } else if (modulo <= MAX_MASK_MODULO * 2) {
            rollUnder = getRollUnder(betMask, 2);
            mask = betMask;
        } else if (modulo == 100) {
            require(betMask > 0 && betMask <= modulo, "High modulo range, betMask larger than modulo.");
            rollUnder = betMask;
        } else if (modulo <= MAX_MASK_MODULO * 3) {
            rollUnder = getRollUnder(betMask, 3);
            mask = betMask;
        } else if (modulo <= MAX_MASK_MODULO * 4) {
            rollUnder = getRollUnder(betMask, 4);
            mask = betMask;
        } else if (modulo <= MAX_MASK_MODULO * 5) {
            rollUnder = getRollUnder(betMask, 5);
            mask = betMask;
        } else if (modulo <= MAX_MASK_MODULO * 6) {
            rollUnder = getRollUnder(betMask, 6);
            mask = betMask;
        } else {
             
             
            require(betMask > 0 && betMask <= modulo, "High modulo range, betMask larger than modulo.");
            rollUnder = betMask;
        }

         
        uint possibleWinAmount;
        uint jackpotFee;

         
        (possibleWinAmount, jackpotFee) = getDiceWinAmount(amount, modulo, rollUnder);

         
        require(possibleWinAmount <= amount + maxProfit, "maxProfit limit violation.");

         
        lockedInBets += uint128(possibleWinAmount);
        jackpotSize += uint128(jackpotFee);

         
        require(jackpotSize + lockedInBets <= address(this).balance, "Cannot afford to lose this bet.");

         
        emit Commit(commit);

         
        bet.amount = amount;
        bet.modulo = uint8(modulo);
        bet.rollUnder = uint8(rollUnder);
        bet.placeBlockNumber = uint40(block.number);
        bet.mask = uint240(mask);
        bet.gambler = msg.sender;
         
    }

    function getRollUnder(uint betMask, uint n) private pure returns (uint rollUnder) {
        rollUnder += (((betMask & MASK40) * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO;
        for (uint i = 1; i < n; i++) {
            betMask = betMask >> MAX_MASK_MODULO;
            rollUnder += (((betMask & MASK40) * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO;
        }
        return rollUnder;
    }

     
     
     
     
    function settleBet(bytes20 reveal1, bytes20 reveal2, bytes32 blockHash) external onlyCroupier {
        uint commit = uint(keccak256(abi.encodePacked(reveal1, reveal2)));
         
         
         

        Bet storage bet = bets[commit];
        uint placeBlockNumber = bet.placeBlockNumber;

         
         

         
        require(block.number > placeBlockNumber, "settleBet in the same block as placeBet, or before.");
        require(block.number <= placeBlockNumber + BET_EXPIRATION_BLOCKS, "Blockhash can&#39;t be queried by EVM.");
        require(blockhash(placeBlockNumber) == blockHash, "blockHash invalid");

         
        settleBetCommon(bet, reveal1, reveal2, blockHash);
    }

     
     
     

     
    function settleBetCommon(Bet storage bet, bytes20 reveal1, bytes20 reveal2, bytes32 entropyBlockHash) private {
         
        uint amount = bet.amount;
        uint modulo = bet.modulo;
        uint rollUnder = bet.rollUnder;
        address gambler = bet.gambler;

         
        require(amount != 0, "Bet should be in an &#39;active&#39; state");

         
        bet.amount = 0;

         
         
         
         
        bytes32 entropy = keccak256(abi.encodePacked(reveal1, entropyBlockHash, reveal2));
         

         
        uint dice = uint(entropy) % modulo;

        uint diceWinAmount;
        uint _jackpotFee;
        (diceWinAmount, _jackpotFee) = getDiceWinAmount(amount, modulo, rollUnder);

        uint diceWin = 0;
        uint jackpotWin = 0;

         
        if ((modulo != 100) && (modulo <= MAX_MASK_MODULO * 6)) {
             
            if ((2 ** dice) & bet.mask != 0) {
                diceWin = diceWinAmount;
            }
        } else {
             
            if (dice < rollUnder) {
                diceWin = diceWinAmount;
            }
        }

         
        lockedInBets -= uint128(diceWinAmount);

         
        if (amount >= MIN_JACKPOT_BET) {
             
             
            uint jackpotRng = (uint(entropy) / modulo) % JACKPOT_MODULO;

             
            if (jackpotRng == 0) {
                jackpotWin = jackpotSize;
                jackpotSize = 0;
            }
        }

         
        if (jackpotWin > 0) {
            emit JackpotPayment(gambler, jackpotWin);
        }

         
        sendFunds(gambler, diceWin + jackpotWin == 0 ? 1 wei : diceWin + jackpotWin, diceWin);
    }

     
     
     
     
     
    function refundBet(uint commit) external {
         
        Bet storage bet = bets[commit];
        uint amount = bet.amount;

        require(amount != 0, "Bet should be in an &#39;active&#39; state");

         
        require(block.number > bet.placeBlockNumber + BET_EXPIRATION_BLOCKS, "Blockhash can&#39;t be queried by EVM.");

         
        bet.amount = 0;

        uint diceWinAmount;
        uint jackpotFee;
        (diceWinAmount, jackpotFee) = getDiceWinAmount(amount, bet.modulo, bet.rollUnder);

        lockedInBets -= uint128(diceWinAmount);
        if (jackpotSize >= jackpotFee) {
            jackpotSize -= uint128(jackpotFee);
        }

         
        sendFunds(bet.gambler, amount, amount);
    }

     
    function getDiceWinAmount(uint amount, uint modulo, uint rollUnder) private view returns (uint winAmount, uint jackpotFee) {
        require(0 < rollUnder && rollUnder <= modulo, "Win probability out of range.");

        jackpotFee = amount >= MIN_JACKPOT_BET ? JACKPOT_FEE : 0;

        uint houseEdge = amount * HOUSE_EDGE_OF_TEN_THOUSAND / 10000;

        if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
        }

        require(houseEdge + jackpotFee <= amount, "Bet doesn&#39;t even cover house edge.");

        winAmount = (amount - houseEdge - jackpotFee) * modulo / rollUnder;
    }

     
    function sendFunds(address beneficiary, uint amount, uint successLogAmount) private {
        if (beneficiary.send(amount)) {
            emit Payment(beneficiary, successLogAmount);
        } else {
            emit FailedPayment(beneficiary, amount);
        }
    }

     
     
    uint constant POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;
    uint constant POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;
    uint constant POPCNT_MODULO = 0x3F;
    uint constant MASK40 = 0xFFFFFFFFFF;
}