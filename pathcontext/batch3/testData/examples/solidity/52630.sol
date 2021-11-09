pragma solidity ^0.4.25;

contract FastMultipliers {

     
    address public support;

    constructor() public {
        support = msg.sender;  
    }

     
	uint constant public prize_percent = 3;
    uint constant public support_percent = 1;
    
   
 
    uint constant public MAX_INVESTMENT = 3 ether;
    uint constant public MIN_INVESTMENT_FOR_PRIZE = 0.05 ether;

 
    uint constant public MAX_IDLE_TIME = 1 minutes;  

 
    uint8[] MULTIPLIERS = [
        115,  
        120,  
        125  
    ];

   
    struct Deposit {
        address depositor;  
        uint128 deposit;    
        uint128 expect;     
    }

    
    struct DepositCount {
        int128 stage;
        uint128 count;
    }

	 
    struct LastDepositInfo {
        uint128 index;
        uint128 time;
    }

    Deposit[] private queue;   

    uint public currentReceiverIndex = 0;  
    uint public currentQueueSize = 0;  
    LastDepositInfo public lastDepositInfo;  

    uint public prizeAmount = 0;  
    int public stage = 0;  
    mapping(address => DepositCount) public depositsMade;  

     
     
    function () public payable {
         
         
        if(msg.value > 0){
            require(gasleft() >= 250000, "We require more gas!");  
            require(msg.value <= MAX_INVESTMENT, "The investment is too much!");  
             
            
            checkAndUpdateStage();

             
            require(getStageStartTime(stage) <= now - MAX_IDLE_TIME);  

            addDeposit(msg.sender, msg.value);

             
            pay();  

        }else if(msg.value == 0){
            withdrawPrize();  
        }
    }

     
     
     
    function pay() private {
         
        uint balance = address(this).balance;
        uint128 money = 0;
        if(balance > prizeAmount)  
            money = uint128(balance - prizeAmount);

         
        for(uint i=currentReceiverIndex; i<currentQueueSize; i++){

            Deposit storage dep = queue[i];  

            if(money >= dep.expect){   
                dep.depositor.send(dep.expect);  
                money -= dep.expect;             

                 
                delete queue[i];
            }else{
                 
                dep.depositor.send(money);  
                dep.expect -= money;        
                break;                      
            }

            if(gasleft() <= 50000)          
                break;                      
        }

        currentReceiverIndex = i;  
    }

    function addDeposit(address depositor, uint value) private {
         
        DepositCount storage c = depositsMade[depositor];
        if(c.stage != stage){
            c.stage = int128(stage);
            c.count = 0;
        }

         
         
        if(value >= MIN_INVESTMENT_FOR_PRIZE) 
            lastDepositInfo = LastDepositInfo(uint128(currentQueueSize), uint128(now));

         
        uint multiplier = getDepositorMultiplier(depositor);
         
        push(depositor, value, value*multiplier/100);

         
        c.count++;

         
        prizeAmount += value*prize_percent/100;

         
        support.send(value*support_percent/100);
    }

    function checkAndUpdateStage() private{
        int _stage = getCurrentStageByTime();

        require(_stage >= stage, "We should only go forward in time");  

        if(_stage != stage){
            proceedToNewStage(_stage);
        }
    }

    function proceedToNewStage(int _stage) private {
         
         
        stage = _stage;
        currentQueueSize = 0;  
        currentReceiverIndex = 0;
        delete lastDepositInfo;
    }

 
    function withdrawPrize() private {
         
        require(lastDepositInfo.time > 0 && lastDepositInfo.time <= now - MAX_IDLE_TIME, "The last depositor is not confirmed yet");
         
        require(currentReceiverIndex <= lastDepositInfo.index, "The last depositor should still be in queue");

        uint balance = address(this).balance;
            if(prizeAmount > balance)  
                prizeAmount = balance;

         
         

         
         

        uint prize = prizeAmount;
        queue[lastDepositInfo.index].depositor.send(prize);

        prizeAmount = 0;
        proceedToNewStage(stage + 1);
    }

     
    function push(address depositor, uint deposit, uint expect) private {
         
        Deposit memory dep = Deposit(depositor, uint128(deposit), uint128(expect));
        assert(currentQueueSize <= queue.length);  
        if(queue.length == currentQueueSize)
            queue.push(dep);
        else
            queue[currentQueueSize] = dep;

        currentQueueSize++;
    }

     
     
    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }

     
    function getDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=currentReceiverIndex; i<currentQueueSize; ++i){
            if(queue[i].depositor == depositor)
                c++;
        }
        return c;
    }

     
    function getDeposits(address depositor) public view returns (uint[] idxs, uint128[] deposits, uint128[] expects) {
        uint c = getDepositsCount(depositor);

        idxs = new uint[](c);
        deposits = new uint128[](c);
        expects = new uint128[](c);

        if(c > 0) {
            uint j = 0;
            for(uint i=currentReceiverIndex; i<currentQueueSize; ++i){
                Deposit storage dep = queue[i];
                if(dep.depositor == depositor){
                    idxs[j] = i;
                    deposits[j] = dep.deposit;
                    expects[j] = dep.expect;
                    j++;
                }
            }
        }
    }

     
    function getQueueLength() public view returns (uint) {
        return currentQueueSize - currentReceiverIndex;
    }

     
    function getDepositorMultiplier(address depositor) public view returns (uint) {
        DepositCount storage c = depositsMade[depositor];
        uint count = 0;
        if(c.stage == getCurrentStageByTime())
            count = c.count;
        if(count < MULTIPLIERS.length)
            return MULTIPLIERS[count];

        return MULTIPLIERS[MULTIPLIERS.length - 1];
    }

     
    function getCurrentStageByTime() public view returns (int) {
        return (int(now - 18 hours) - 17840*1 days)/5 minutes;
    }

     
    function getStageStartTime(int _stage) public pure returns (uint) {
        return (18 hours + uint(_stage + 1))*5 minutes + 17840*1 days;
    }

    function getCurrentCandidateForPrize() public view returns (address addr, int timeLeft){
         
        if(currentReceiverIndex <= lastDepositInfo.index && lastDepositInfo.index < currentQueueSize){
            Deposit storage d = queue[lastDepositInfo.index];
            addr = d.depositor;
            timeLeft = int(lastDepositInfo.time + MAX_IDLE_TIME) - int(now);
        }
    }

}