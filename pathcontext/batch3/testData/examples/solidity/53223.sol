pragma solidity ^0.4.24;

contract Sacrific3d {
    
    uint8 constant public PLAYERS_PER_ROUND = 5;
    uint256 constant public SACRIFICE_SIZE = 0.1 ether;
    
    HourglassInterface constant private p3dContract = HourglassInterface(0x0E62d6a4E8354EFC62b1eA7fDFfff2eff0FE5712);
    StrongHandsManagerInterface constant private strongHandsManagerContract = StrongHandsManagerInterface(0x7Fce0b3caeD2c2d2d70D6cA59A653014a405aFC5);
    StrongHandInterface private strongHandContract;
    
     
    uint256 public winningsPerRound = SACRIFICE_SIZE + (SACRIFICE_SIZE / (PLAYERS_PER_ROUND - 1)) / 2;
    
    uint8 public currentPlayers;
    uint256 public round;
    
    uint256 private blocknumber;
    
    mapping(uint8 => address) public slotXplayer;
    
    mapping(address => uint256) private playerVault;
    mapping(address => uint256) private playerRound;
    
    event SacrificeOffered(address indexed player);
    event SacrificeChosen(address indexed sarifice);
    event EarningsWithdrawn(address indexed sarifice, uint256 indexed amount);
    event RoundInvalidated(uint256 indexed round);
    
    constructor()
        public
    {
         
        strongHandsManagerContract.getStrong();
        strongHandContract = StrongHandInterface(strongHandsManagerContract.strongHands(address(this)));
        
        currentPlayers = 0;
        round = 0;
    }
    
    function()
        public
        payable
    {
        acceptSacrifice(msg.value);
    }
    
    function offerSacrifice()
        external
        payable
    {
        acceptSacrifice(msg.value);
    }
    
    function myEarnings()
        external
        view
        returns(uint256)
    {
        return playerVault[msg.sender];
    }
    
    function withdraw()
        external
    {
         
        require(playerRound[msg.sender] < round, "you can not withdraw during a round you are participating in");
        
        uint256 amount = playerVault[msg.sender];
        playerVault[msg.sender] = 0;
        msg.sender.transfer(amount);
        
        emit EarningsWithdrawn(msg.sender, amount);     
    }
    
    function acceptSacrifice(uint256 sacrificeAmount)
        private
    {
        require(sacrificeAmount == SACRIFICE_SIZE, "invalid amount");
        
         
        if(currentPlayers == PLAYERS_PER_ROUND) {
             
            if(block.number == blocknumber) {
                revert();
            }
             
            if(blockhash(blocknumber) != 0) {
                uint8 sacrificeSlot = uint8(blockhash(blocknumber)) % PLAYERS_PER_ROUND;
                address sacrificePlayer = slotXplayer[sacrificeSlot];
                
                 
                playerVault[sacrificePlayer]-= winningsPerRound;
                
                 
                uint256 dividends = p3dContract.dividendsOf(address(strongHandContract));
                if(dividends > 0) {
                    strongHandContract.withdraw();
                    playerVault[sacrificePlayer]+= dividends;
                }
                
                 
                strongHandContract.buy.value(SACRIFICE_SIZE / 2)(address(0x1EB2acB92624DA2e601EEb77e2508b32E49012ef));
                
                emit SacrificeChosen(sacrificePlayer);
            } else {
                emit RoundInvalidated(round);
            }
            
             
            currentPlayers = 0;
            round++;
        }
        
         
        else if(currentPlayers == PLAYERS_PER_ROUND - 1) {
            blocknumber = block.number;
        }
        
         
        playerRound[msg.sender] = round;
        slotXplayer[currentPlayers] = msg.sender;
        
         
        playerVault[msg.sender]+= winningsPerRound;
        
        currentPlayers++;
        
        emit SacrificeOffered(msg.sender);
    }
}

interface HourglassInterface {
    function dividendsOf(address _customerAddress) view external returns(uint256);
}

interface StrongHandsManagerInterface {
    function getStrong() external;
    function strongHands(address owner) external returns (address);
}

interface StrongHandInterface {
    function buy(address _referrer) external payable;
    function withdraw() external;
}