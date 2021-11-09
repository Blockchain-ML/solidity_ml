pragma solidity ^0.4.24;

 
library SafeMath {

     
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        uint256 c = a / b;
         
        return c;
    }

     
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

     
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

     
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y)
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

     
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

     
    function pwr(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }

    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
}

 
library NumberCompressor {

    uint256 constant private MASK = 16777215;    

    function encode(uint256 _begin, uint256 _end, uint256 _ceiling) internal pure returns (uint256)
    {
        require(_begin <= _end && _end < _ceiling, "number is invalid");

        return _begin << 24 | _end;
    }

    function decode(uint256 _value) internal pure returns (uint256, uint256)
    {
        uint256 end = _value & MASK;
        uint256 begin = (_value >> 24) & MASK;
        return (begin, end);
    }

}

library DataSet {

    enum RoundState {
        UNKNOWN,         
        STARTED,         
        STOPPED,         
        DRAWN,           
        ASSIGNED         
    }

    struct Round {
        uint256                         count;               
        uint256                         timestamp;           
        uint256                         blockNumber;         
        uint256                         drawBlockNumber;     
        RoundState                      state;               
        uint256                         pond;                
        uint256                         winningNumber;       
        address                         winner;              
    }

}

contract Events {

    event onActivate
    (
        address indexed addr,
        uint256 timestamp,
        uint256 bonus,
        uint256 issued_numbers
    );

    event onDraw
    (
        uint256 timestatmp,
        uint256 blockNumber,
        uint256 roundID,
        uint256 winningNumber
    );

    event onStartRunnd
    (
        uint256 timestamp,
        uint256 roundID
    );

    event onBet
    (
        address indexed addr,
        uint256 timestamp,
        uint256 roundID,
        uint256 beginNumber,
        uint256 endNumber
    );

    event onAssign
    (
        address indexed operatorAddr,
        uint256 timestatmp,
        address indexed winnerAddr,
        uint256 roundID,
        uint256 pond,
        uint256 bonus,       
        uint256 fund         
    );

    event onRefund
    (
        address indexed operatorAddr,
        uint256 timestamp,
        address indexed playerAddr,
        uint256 count,
        uint256 amount
    );

    event onLastRefund
    (
        address indexed operatorAddr,
        uint256 timestamp,
        address indexed platformAddr,
        uint256 amout
    );

}

contract Winner is Events {

    using SafeMath for *;

    uint256     constant private    MIN_BET = 0.01 ether;                                    
    uint256     constant private    PRICE   = 0.01 ether;                                    
    uint256     constant private    MAX_DURATION = 5 days;                                   
    uint256     constant private    REFUND_RATE = 90;                                        
    address     constant private    platform = 0xe379D8F62F07BFD179Eb8C071F1D63Af3AfFee2c;   
    uint256     private             curRoundID;                                              
    uint256     private             drawnRoundID;                                            
    uint256     private             drawnBlockNumber;                                        
    uint256     private             bonus;                                                   
    uint256     private             issued_numbers;                                          
    bool        private             activated;                                               

     
    mapping (uint256 => DataSet.Round) private rounds;
     
    mapping (uint256 => mapping(address => uint256[])) private playerNumbers;
    mapping (address => bool) private administrators;

     
    constructor(uint256 _bonus, uint256 _issued_numbers) public {
        require(_bonus > 0, "bonus is invalid");
        require(_issued_numbers > 0, "issued_numbers is invalid");

        administrators[msg.sender] = true;

        bonus = _bonus;
        issued_numbers = _issued_numbers;
    }

     
    modifier isAdmin() {
        require(administrators[msg.sender], "only administrators");
        _;
    }

     
    modifier isActivated() {
        require(activated == true, "game is inactive");
        _;
    }

     
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry, humans only");
        _;
    }

     
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= MIN_BET, "the bet is too small");
        require(_eth <= PRICE.mul(issued_numbers).mul(2), "the bet is too big");
        _;
    }

     
    function() public payable isHuman() isActivated() isWithinLimits(msg.value)
    {
        bet(msg.value);
    }

    function activate() public isAdmin()
    {
         
        require(activated == false, "it has activated already");

        emit onActivate(msg.sender, block.timestamp, bonus, issued_numbers);

        activated = true;
        curRoundID = 1;
        rounds[curRoundID].state = DataSet.RoundState.STARTED;
        rounds[curRoundID].timestamp = block.timestamp;
        drawnRoundID = 0;

        emit onStartRunnd(block.timestamp, curRoundID);
    }

     
    function drawNumber() private view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(

            ((uint256(keccak256(abi.encodePacked(block.blockhash(block.number))))) / (block.timestamp)).add
            ((uint256(keccak256(abi.encodePacked(block.blockhash(block.number - 1))))) / (block.timestamp)).add
            ((uint256(keccak256(abi.encodePacked(block.blockhash(block.number - 2))))) / (block.timestamp)).add
            ((uint256(keccak256(abi.encodePacked(block.blockhash(block.number - 3))))) / (block.timestamp)).add
            ((uint256(keccak256(abi.encodePacked(block.blockhash(block.number - 4))))) / (block.timestamp)).add
            ((uint256(keccak256(abi.encodePacked(block.blockhash(block.number - 5))))) / (block.timestamp)).add
            ((uint256(keccak256(abi.encodePacked(block.blockhash(block.number - 6))))) / (block.timestamp))

        ))) % issued_numbers;

    }

     
    function bet(uint256 _amount) private
    {
         
        if (block.number != drawnBlockNumber
            && curRoundID > drawnRoundID
            && rounds[drawnRoundID + 1].count == issued_numbers
            && block.number >= rounds[drawnRoundID + 1].blockNumber + 7)
        {
            drawnBlockNumber = block.number;
            drawnRoundID += 1;

            rounds[drawnRoundID].winningNumber = drawNumber();
            rounds[drawnRoundID].state = DataSet.RoundState.DRAWN;
            rounds[drawnRoundID].drawBlockNumber = drawnBlockNumber;

            emit onDraw(block.timestamp, drawnBlockNumber, drawnRoundID, rounds[drawnRoundID].winningNumber);
        }

         
        uint256 amount = _amount;
        while (true)
        {
             
            uint256 max = issued_numbers - rounds[curRoundID].count;
            uint256 available = amount.div(PRICE).min(max);

            if (available == 0)
            {
                 
                 
                 
                if (amount != 0)
                {
                    rounds[curRoundID].pond += amount;
                }
                break;
            }
            uint256[] storage numbers = playerNumbers[curRoundID][msg.sender];
            uint256 begin = rounds[curRoundID].count;
            uint256 end = begin + available - 1;
            uint256 compressedNumber = NumberCompressor.encode(begin, end, issued_numbers);
            numbers.push(compressedNumber);
            rounds[curRoundID].pond += available.mul(PRICE);
            rounds[curRoundID].count += available;
            amount -= available.mul(PRICE);

            emit onBet(msg.sender, block.timestamp, curRoundID, begin, end);

            if (rounds[curRoundID].count == issued_numbers)
            {
                 
                rounds[curRoundID].blockNumber = block.number;
                rounds[curRoundID].state = DataSet.RoundState.STOPPED;
                curRoundID += 1;
                rounds[curRoundID].state = DataSet.RoundState.STARTED;
                rounds[curRoundID].timestamp = block.timestamp;

                emit onStartRunnd(block.timestamp, curRoundID);
            }
        }
    }

     
    function assign(uint256 _roundID) external isHuman() isActivated()
    {
        assign(msg.sender, _roundID);
    }

     
    function assign(address _player, uint256 _roundID) public isHuman() isActivated()
    {
        require(rounds[_roundID].state == DataSet.RoundState.DRAWN, "it&#39;s not time for assigning");

        uint256[] memory numbers = playerNumbers[_roundID][_player];
        require(numbers.length > 0, "player did not involve in");
        uint256 targetNumber = rounds[_roundID].winningNumber;
        for (uint256 i = 0; i < numbers.length; i ++)
        {
            (uint256 start, uint256 end) = NumberCompressor.decode(numbers[i]);
            if (targetNumber >= start && targetNumber <= end)
            {
                 
                uint256 fund = rounds[_roundID].pond.sub(bonus);
                _player.transfer(bonus);
                platform.transfer(fund);
                rounds[_roundID].state = DataSet.RoundState.ASSIGNED;
                rounds[_roundID].winner = _player;

                emit onAssign(msg.sender, block.timestamp, _player, _roundID, rounds[_roundID].pond, bonus, fund);

                break;
            }
        }
    }

     
    function refund() external isHuman() isActivated()
    {
        refund(msg.sender);
    }

     
    function refund(address _player) public isActivated() isHuman()
    {
        require(block.timestamp.sub(rounds[curRoundID].timestamp) >= MAX_DURATION, "it&#39;s not time for refunding");

         
        uint256[] storage numbers = playerNumbers[curRoundID][_player];
        require(numbers.length > 0, "player did not involve in");

        uint256 count = 0;
        for (uint256 i = 0; i < numbers.length; i ++)
        {
            (uint256 begin, uint256 end) = NumberCompressor.decode(numbers[i]);
            count += (end - begin + 1);
        }

         
        uint256 amount = count.mul(PRICE).mul(REFUND_RATE).div(100);
        rounds[curRoundID].pond = rounds[curRoundID].pond.sub(amount);
        _player.transfer(amount);

        emit onRefund(msg.sender, block.timestamp, _player, count, amount);

         
        rounds[curRoundID].count -= count;
        if (rounds[curRoundID].count == 0)
        {
            uint256 last = rounds[curRoundID].pond;
            platform.transfer(last);
            rounds[curRoundID].pond = 0;

            emit onLastRefund(msg.sender, block.timestamp, platform, last);
        }
    }

     
    function getPlayerRoundNumbers(uint256 _roundID, address _palyer) public view returns(uint256[])
    {
        return playerNumbers[_roundID][_palyer];
    }

     
    function getRoundInfo(uint256 _roundID) public view
        returns(uint256, uint256, uint256, uint256, uint256, uint256, address)
    {
        return (
            rounds[_roundID].count,
            rounds[_roundID].blockNumber,
            rounds[_roundID].drawBlockNumber,
            uint256(rounds[_roundID].state),
            rounds[_roundID].pond,
            rounds[_roundID].winningNumber,
            rounds[_roundID].winner
        );
    }

     
    function gameInfo() public view
        returns(bool, uint256, uint256, uint256, uint256)
    {
        return (
            activated,
            bonus,
            issued_numbers,
            curRoundID,
            drawnRoundID
        );
    }

}