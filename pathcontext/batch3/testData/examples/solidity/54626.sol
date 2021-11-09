pragma solidity ^0.4.15;


 
 
 
library Math {

    enum EstimationMode { LowerBound, UpperBound, Midpoint }

     
     
    uint public constant ONE =  0x10000000000000000;
    uint public constant LN2 = 0xb17217f7d1cf79ac;
    uint public constant LOG2_E = 0x171547652b82fe177;

     
     
     
     
    function exp(int x)
        public
        constant
        returns (uint)
    {
         
         
        require(x <= 2454971259878909886679);
         
         
        if (x <= -818323753292969962227)
            return 0;

         
        var (lower, upper) = pow2Bounds(x * int(ONE) / int(LN2));
        return (upper - lower) / 2 + lower;
    }

     
     
     
     
    function pow2(int x, EstimationMode estimationMode)
        public
        constant
        returns (uint)
    {
        var (lower, upper) = pow2Bounds(x);
        if(estimationMode == EstimationMode.LowerBound) {
            return lower;
        }
        if(estimationMode == EstimationMode.UpperBound) {
            return upper;
        }
        if(estimationMode == EstimationMode.Midpoint) {
            return (upper - lower) / 2 + lower;
        }
        revert();
    }

     
     
     
     
     
     
    function pow2Bounds(int x)
        public
        constant
        returns (uint lower, uint upper)
    {
         
         
        require(x <= 3541774862152233910271);
         
         
        if (x < -1180591620717411303424)
            return (0, 1);

         
         
         
        int shift;
        int z;
        if (x >= 0) {
            shift = x / int(ONE);
            z = x % int(ONE);
        }
        else {
            shift = (x+1) / int(ONE) - 1;
            z = x - (int(ONE) * shift);
        }
        assert(z >= 0);
         
         
         
         
         
         
         
         
        int result = int(ONE) << 64;
        int zpow = z;
        result += 0xb17217f7d1cf79ab * zpow;
        zpow = zpow * z / int(ONE);
        result += 0xf5fdeffc162c7543 * zpow >> (66 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xe35846b82505fc59 * zpow >> (68 - 64);
        zpow = zpow * z / int(ONE);
        result += 0x9d955b7dd273b94e * zpow >> (70 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xaec3ff3c53398883 * zpow >> (73 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xa184897c363c3b7a * zpow >> (76 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xffe5fe2c45863435 * zpow >> (80 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xb160111d2e411fec * zpow >> (83 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xda929e9caf3e1ed2 * zpow >> (87 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xf267a8ac5c764fb7 * zpow >> (91 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xf465639a8dd92607 * zpow >> (95 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xe1deb287e14c2f15 * zpow >> (99 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xc0b0c98b3687cb14 * zpow >> (103 - 64);
        zpow = zpow * z / int(ONE);
        result += 0x98a4b26ac3c54b9f * zpow >> (107 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xe1b7421d82010f33 * zpow >> (112 - 64);
        zpow = zpow * z / int(ONE);
        result += 0x9c744d73cfc59c91 * zpow >> (116 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xcc2225a0e12d3eab * zpow >> (121 - 64);
        zpow = zpow * z / int(ONE);
        zpow = 0xfb8bb5eda1b4aeb9 * zpow >> (126 - 64);
        result += zpow;
        zpow = int(8 * ONE);

        shift -= 64;
        if (shift >= 0) {
            if (result >> (256-shift) == 0) {
                lower = uint(result) << shift;
                zpow <<= shift;  
                if (safeToAdd(lower, uint(zpow)))
                    upper = lower + uint(zpow);
                else
                    upper = 2**256-1;
                return;
            }
            else
                return (2**256-1, 2**256-1);
        }
        zpow = (zpow >> (-shift)) + 1;
        lower = uint(result) >> (-shift);
        upper = lower + uint(zpow);
        return;
    }

     
     
     
    function ln(uint x)
        public
        constant
        returns (int)
    {
        var (lower, upper) = log2Bounds(x);
        return ((upper - lower) / 2 + lower) * int(ONE) / int(LOG2_E);
    }

     
     
     
     
    function log2(uint x, EstimationMode estimationMode)
        public
        constant
        returns (int)
    {
        var (lower, upper) = log2Bounds(x);
        if(estimationMode == EstimationMode.LowerBound) {
            return lower;
        }
        if(estimationMode == EstimationMode.UpperBound) {
            return upper;
        }
        if(estimationMode == EstimationMode.Midpoint) {
            return (upper - lower) / 2 + lower;
        }
        revert();
    }

     
     
     
     
     
     
    function log2Bounds(uint x)
        public
        constant
        returns (int lower, int upper)
    {
        require(x > 0);
         
        lower = floorLog2(x);

        uint y;
        if (lower < 0)
            y = x << uint(-lower);
        else
            y = x >> uint(lower);

        lower *= int(ONE);

         
         
         
        for (int m = 1; m <= 64; m++) {
            if(y == ONE) {
                break;
            }
            y = y * y / ONE;
            if(y >= 2 * ONE) {
                lower += int(ONE >> m);
                y /= 2;
            }
        }

        return (lower, lower + 4);
    }

     
     
     
    function floorLog2(uint x)
        public
        constant
        returns (int lo)
    {
        lo = -64;
        int hi = 193;
         
        int mid = (hi + lo) >> 1;
        while((lo + 1) < hi) {
            if (mid < 0 && x << uint(-mid) < ONE || mid >= 0 && x >> uint(mid) < ONE)
                hi = mid;
            else
                lo = mid;
            mid = (hi + lo) >> 1;
        }
    }

     
     
     
    function max(int[] nums)
        public
        constant
        returns (int max)
    {
        require(nums.length > 0);
        max = -2**255;
        for (uint i = 0; i < nums.length; i++)
            if (nums[i] > max)
                max = nums[i];
    }

     
     
     
     
    function safeToAdd(uint a, uint b)
        public
        constant
        returns (bool)
    {
        return a + b >= a;
    }

     
     
     
     
    function safeToSub(uint a, uint b)
        public
        constant
        returns (bool)
    {
        return a >= b;
    }

     
     
     
     
    function safeToMul(uint a, uint b)
        public
        constant
        returns (bool)
    {
        return b == 0 || a * b / b == a;
    }

     
     
     
     
    function add(uint a, uint b)
        public
        constant
        returns (uint)
    {
        require(safeToAdd(a, b));
        return a + b;
    }

     
     
     
     
    function sub(uint a, uint b)
        public
        constant
        returns (uint)
    {
        require(safeToSub(a, b));
        return a - b;
    }

     
     
     
     
    function mul(uint a, uint b)
        public
        constant
        returns (uint)
    {
        require(safeToMul(a, b));
        return a * b;
    }

     
     
     
     
    function safeToAdd(int a, int b)
        public
        constant
        returns (bool)
    {
        return (b >= 0 && a + b >= a) || (b < 0 && a + b < a);
    }

     
     
     
     
    function safeToSub(int a, int b)
        public
        constant
        returns (bool)
    {
        return (b >= 0 && a - b <= a) || (b < 0 && a - b > a);
    }

     
     
     
     
    function safeToMul(int a, int b)
        public
        constant
        returns (bool)
    {
        return (b == 0) || (a * b / b == a);
    }

     
     
     
     
    function add(int a, int b)
        public
        constant
        returns (int)
    {
        require(safeToAdd(a, b));
        return a + b;
    }

     
     
     
     
    function sub(int a, int b)
        public
        constant
        returns (int)
    {
        require(safeToSub(a, b));
        return a - b;
    }

     
     
     
     
    function mul(int a, int b)
        public
        constant
        returns (int)
    {
        require(safeToMul(a, b));
        return a * b;
    }
}


 
contract Token {

     
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

     
    function transfer(address to, uint value) public returns (bool);
    function transferFrom(address from, address to, uint value) public returns (bool);
    function approve(address spender, uint value) public returns (bool);
    function balanceOf(address owner) public constant returns (uint);
    function allowance(address owner, address spender) public constant returns (uint);
    function totalSupply() public constant returns (uint);
}



 
contract StandardToken is Token {
    using Math for *;

     
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowances;
    uint totalTokens;

     
     
     
     
     
    function transfer(address to, uint value)
        public
        returns (bool)
    {
        if (   !balances[msg.sender].safeToSub(value)
            || !balances[to].safeToAdd(value))
            return false;
        balances[msg.sender] -= value;
        balances[to] += value;
        Transfer(msg.sender, to, value);
        return true;
    }

     
     
     
     
     
    function transferFrom(address from, address to, uint value)
        public
        returns (bool)
    {
        if (   !balances[from].safeToSub(value)
            || !allowances[from][msg.sender].safeToSub(value)
            || !balances[to].safeToAdd(value))
            return false;
        balances[from] -= value;
        allowances[from][msg.sender] -= value;
        balances[to] += value;
        Transfer(from, to, value);
        return true;
    }

     
     
     
     
    function approve(address spender, uint value)
        public
        returns (bool)
    {
        allowances[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }

     
     
     
     
    function allowance(address owner, address spender)
        public
        constant
        returns (uint)
    {
        return allowances[owner][spender];
    }

     
     
     
    function balanceOf(address owner)
        public
        constant
        returns (uint)
    {
        return balances[owner];
    }

     
     
    function totalSupply()
        public
        constant
        returns (uint)
    {
        return totalTokens;
    }
}


 
 
contract OutcomeToken is StandardToken {
    using Math for *;

     
    event Issuance(address indexed owner, uint amount);
    event Revocation(address indexed owner, uint amount);

     
    address public eventContract;

     
    modifier isEventContract () {
         
        require(msg.sender == eventContract);
        _;
    }

     
     
    function OutcomeToken()
        public
    {
        eventContract = msg.sender;
    }
    
     
     
     
    function issue(address _for, uint outcomeTokenCount)
        public
        isEventContract
    {
        balances[_for] = balances[_for].add(outcomeTokenCount);
        totalTokens = totalTokens.add(outcomeTokenCount);
        Issuance(_for, outcomeTokenCount);
    }

     
     
     
    function revoke(address _for, uint outcomeTokenCount)
        public
        isEventContract
    {
        balances[_for] = balances[_for].sub(outcomeTokenCount);
        totalTokens = totalTokens.sub(outcomeTokenCount);
        Revocation(_for, outcomeTokenCount);
    }
}


 
contract Oracle {

    function isOutcomeSet() public constant returns (bool);
    function getOutcome() public constant returns (int);
}


 
 
contract Event {

     
    event OutcomeTokenCreation(OutcomeToken outcomeToken, uint8 index);
    event OutcomeTokenSetIssuance(address indexed buyer, uint collateralTokenCount);
    event OutcomeTokenSetRevocation(address indexed seller, uint outcomeTokenCount);
    event OutcomeAssignment(int outcome);
    event WinningsRedemption(address indexed receiver, uint winnings);

     
    Token public collateralToken;
    Oracle public oracle;
    bool public isOutcomeSet;
    int public outcome;
    OutcomeToken[] public outcomeTokens;

     
     
     
     
     
    function Event(Token _collateralToken, Oracle _oracle, uint8 outcomeCount)
        public
    {
         
        require(address(_collateralToken) != 0 && address(_oracle) != 0 && outcomeCount >= 2);
        collateralToken = _collateralToken;
        oracle = _oracle;
         
        for (uint8 i = 0; i < outcomeCount; i++) {
            OutcomeToken outcomeToken = new OutcomeToken();
            outcomeTokens.push(outcomeToken);
            OutcomeTokenCreation(outcomeToken, i);
        }
    }

     
     
    function buyAllOutcomes(uint collateralTokenCount)
        public
    {
         
        require(collateralToken.transferFrom(msg.sender, this, collateralTokenCount));
         
        for (uint8 i = 0; i < outcomeTokens.length; i++)
            outcomeTokens[i].issue(msg.sender, collateralTokenCount);
        OutcomeTokenSetIssuance(msg.sender, collateralTokenCount);
    }

     
     
    function sellAllOutcomes(uint outcomeTokenCount)
        public
    {
         
        for (uint8 i = 0; i < outcomeTokens.length; i++)
            outcomeTokens[i].revoke(msg.sender, outcomeTokenCount);
         
        require(collateralToken.transfer(msg.sender, outcomeTokenCount));
        OutcomeTokenSetRevocation(msg.sender, outcomeTokenCount);
    }

     
    function setOutcome()
        public
    {
         
        require(!isOutcomeSet && oracle.isOutcomeSet());
         
        outcome = oracle.getOutcome();
        isOutcomeSet = true;
        OutcomeAssignment(outcome);
    }

     
     
    function getOutcomeCount()
        public
        constant
        returns (uint8)
    {
        return uint8(outcomeTokens.length);
    }

     
     
    function getOutcomeTokens()
        public
        constant
        returns (OutcomeToken[])
    {
        return outcomeTokens;
    }

     
     
    function getOutcomeTokenDistribution(address owner)
        public
        constant
        returns (uint[] outcomeTokenDistribution)
    {
        outcomeTokenDistribution = new uint[](outcomeTokens.length);
        for (uint8 i = 0; i < outcomeTokenDistribution.length; i++)
            outcomeTokenDistribution[i] = outcomeTokens[i].balanceOf(owner);
    }

     
     
    function getEventHash() public constant returns (bytes32);

     
     
    function redeemWinnings() public returns (uint);
}



 
contract Market {

     
    event MarketFunding(uint funding);
    event MarketClosing();
    event FeeWithdrawal(uint fees);
    event OutcomeTokenPurchase(address indexed buyer, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint outcomeTokenCost, uint marketFees);
    event OutcomeTokenSale(address indexed seller, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint outcomeTokenProfit, uint marketFees);
    event OutcomeTokenShortSale(address indexed buyer, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint cost);

     
    address public creator;
    uint public createdAtBlock;
    Event public eventContract;
    MarketMaker public marketMaker;
    uint24 public fee;
    uint public funding;
    int[] public netOutcomeTokensSold;
    Stages public stage;

    enum Stages {
        MarketCreated,
        MarketFunded,
        MarketClosed
    }

     
    function fund(uint _funding) public;
    function close() public;
    function withdrawFees() public returns (uint);
    function buy(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint maxCost) public returns (uint);
    function sell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit) public returns (uint);
    function shortSell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit) public returns (uint);
    function calcMarketFee(uint outcomeTokenCost) public constant returns (uint);
}


 
contract MarketMaker {

     
    function calcCost(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount) public constant returns (uint);
    function calcProfit(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount) public constant returns (uint);
    function calcMarginalPrice(Market market, uint8 outcomeTokenIndex) public constant returns (uint);
}


 
 
contract LMSRMarketMaker is MarketMaker {
    using Math for *;

     
    uint constant ONE = 0x10000000000000000;
    int constant EXP_LIMIT = 3394200909562557497344;

     
     
     
     
     
     
    function calcCost(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount)
        public
        constant
        returns (uint cost)
    {
        require(market.eventContract().getOutcomeCount() > 1);
        int[] memory netOutcomeTokensSold = getNetOutcomeTokensSold(market);
         
        int log2N = Math.log2(netOutcomeTokensSold.length * ONE, Math.EstimationMode.UpperBound);
        uint funding = market.funding();
        int costLevelBefore = calcCostLevel(log2N, netOutcomeTokensSold, funding, Math.EstimationMode.LowerBound);
         
        require(int(outcomeTokenCount) >= 0);
        netOutcomeTokensSold[outcomeTokenIndex] = netOutcomeTokensSold[outcomeTokenIndex].add(int(outcomeTokenCount));
         
        int costLevelAfter = calcCostLevel(log2N, netOutcomeTokensSold, funding, Math.EstimationMode.UpperBound);
         
        if(costLevelAfter < costLevelBefore)
            costLevelAfter = costLevelBefore;
        cost = uint(costLevelAfter - costLevelBefore);
         
        if (cost / ONE * ONE == cost)
            cost /= ONE;
        else
             
            cost = cost / ONE + 1;
         
        if (cost > outcomeTokenCount)
            cost = outcomeTokenCount;
    }

     
     
     
     
     
    function calcProfit(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount)
        public
        constant
        returns (uint profit)
    {
        require(market.eventContract().getOutcomeCount() > 1);
        int[] memory netOutcomeTokensSold = getNetOutcomeTokensSold(market);
         
        int log2N = Math.log2(netOutcomeTokensSold.length * ONE, Math.EstimationMode.UpperBound);
        uint funding = market.funding();
        int costLevelBefore = calcCostLevel(log2N, netOutcomeTokensSold, funding, Math.EstimationMode.LowerBound);
         
        require(int(outcomeTokenCount) >= 0);
        netOutcomeTokensSold[outcomeTokenIndex] = netOutcomeTokensSold[outcomeTokenIndex].sub(int(outcomeTokenCount));
         
        int costLevelAfter = calcCostLevel(log2N, netOutcomeTokensSold, funding, Math.EstimationMode.UpperBound);
         
        if(costLevelBefore <= costLevelAfter)
            costLevelBefore = costLevelAfter;
         
        profit = uint(costLevelBefore - costLevelAfter) / ONE;
    }

     
     
     
     
    function calcMarginalPrice(Market market, uint8 outcomeTokenIndex)
        public
        constant
        returns (uint price)
    {
        require(market.eventContract().getOutcomeCount() > 1);
        int[] memory netOutcomeTokensSold = getNetOutcomeTokensSold(market);
        int logN = Math.log2(netOutcomeTokensSold.length * ONE, Math.EstimationMode.Midpoint);
        uint funding = market.funding();
         
         
         
        var (sum, , outcomeExpTerm) = sumExpOffset(logN, netOutcomeTokensSold, funding, outcomeTokenIndex, Math.EstimationMode.Midpoint);
        return outcomeExpTerm / (sum / ONE);
    }

     
     
     
     
     
     
     
    function calcCostLevel(int logN, int[] netOutcomeTokensSold, uint funding, Math.EstimationMode estimationMode)
        private
        constant
        returns(int costLevel)
    {
         
         
         
        var (sum, offset, ) = sumExpOffset(logN, netOutcomeTokensSold, funding, 0, estimationMode);
        costLevel = Math.log2(sum, estimationMode);
        costLevel = costLevel.add(offset);
        costLevel = (costLevel.mul(int(ONE)) / logN).mul(int(funding));
    }

     
     
     
     
     
     
     
    function sumExpOffset(int logN, int[] netOutcomeTokensSold, uint funding, uint8 outcomeIndex, Math.EstimationMode estimationMode)
        private
        constant
        returns (uint sum, int offset, uint outcomeExpTerm)
    {
         
         
         

         
         
         
         
         
         

         
         
         

        require(logN >= 0 && int(funding) >= 0);
        offset = Math.max(netOutcomeTokensSold);
        offset = offset.mul(logN) / int(funding);
        offset = offset.sub(EXP_LIMIT);
        uint term;
        for (uint8 i = 0; i < netOutcomeTokensSold.length; i++) {
            term = Math.pow2((netOutcomeTokensSold[i].mul(logN) / int(funding)).sub(offset), estimationMode);
            if (i == outcomeIndex)
                outcomeExpTerm = term;
            sum = sum.add(term);
        }
    }

     
     
     
     
     
     
    function getNetOutcomeTokensSold(Market market)
        private
        constant
        returns (int[] quantities)
    {
        quantities = new int[](market.eventContract().getOutcomeCount());
        for (uint8 i = 0; i < quantities.length; i++)
            quantities[i] = market.netOutcomeTokensSold(i);
    }
}