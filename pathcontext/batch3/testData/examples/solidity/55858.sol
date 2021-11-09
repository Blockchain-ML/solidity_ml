 
 
 

 
 
 
 
 
pragma solidity ^0.4.22;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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


contract Base {

    uint private bitlocks = 0;

    modifier noAnyReentrancy {
        uint _locks = bitlocks;
        require(_locks <= 0);
        bitlocks = uint(-1);
        _;
        bitlocks = _locks;
    }

    modifier only(address allowed) {
        require(msg.sender == allowed);
        _;
    }

    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length == size + 4);
        _;
    } 

}


contract ERC20 is Base {
    
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    using SafeMath for uint;
    uint public totalSupply;
    bool public isFrozen = false;  
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    modifier isNotFrozenOnly() {
        require(!isFrozen);
        _;
    }

    modifier isFrozenOnly(){
        require(isFrozen);
        _;
    }

    function transferFrom(address _from, address _to, uint _value) public isNotFrozenOnly onlyPayloadSize(3 * 32) returns (bool success) {
        require(_to != address(0));
        require(_to != address(this));
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    function approve_fixed(address _spender, uint _currentValue, uint _value) public isNotFrozenOnly onlyPayloadSize(3 * 32) returns (bool success) {
        if(allowed[msg.sender][_spender] == _currentValue){
            allowed[msg.sender][_spender] = _value;
            emit Approval(msg.sender, _spender, _value);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint _value) public isNotFrozenOnly onlyPayloadSize(2 * 32) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}

contract Whitelist {

    mapping(address => bool) public whitelist;
    mapping(address => bool) operators;
    address authority;

    constructor(address _authority) {
        authority = _authority;
        operators[_authority] = true;
    }
    
    function set(address _address) public {
        require(operators[msg.sender]);
        whitelist[_address] = true;
    }

    function unSet(address _address) public {
        require(operators[msg.sender]);
        whitelist[_address] = false;
    }

    function addOperator(address _address) public {
        require(authority == msg.sender);
        operators[_address] = true;
    }

    function removeOperator(address _address) public {
        require(authority == msg.sender);
        operators[_address] = false;
    }
}


contract Token is ERC20 {

    string public name = "Array.io Token";
    string public symbol = "eRAY";
    uint8 public decimals = 18;
    bool public tgrLive = false;
    uint public tgrStartBlock;
    uint public tgrNumber;
    uint public tgrSettingsMinimalInvestment;
    uint public tgrSettingsAmount;
    uint public tgrSettingsPartInvestor;
    uint public tgrSettingsPartProject;
    uint public tgrSettingsPartFounders;
    uint public tgrSettingsBlocksPerStage;
    uint public tgrSettingsPartInvestorIncreasePerStage;
    uint public tgrSettingsAmountCollected;
    uint public tgrSettingsMaxStages;
    address public projectWallet;
    address public foundersWallet;
    address constant public burnAddress = address(0);
    mapping (address => uint) public invBalances;
    uint public totalInvSupply;
    Whitelist public whitelist;


    modifier isTgrLive(){
        require(tgrLive);
        _;
    }

    modifier isNotTgrLive(){
        require(!tgrLive);
        _;
    }

    event Burn(address indexed _owner,  uint _value);
    event TGRStarted(uint tgrSettingsAmount,
                     uint tgrSettingsMinimalInvestment,
                     uint tgrSettingsPartInvestor,
                     uint tgrSettingsPartProject, 
                     uint tgrSettingsPartFounders, 
                     uint tgrSettingsBlocksPerStage, 
                     uint tgrSettingsPartInvestorIncreasePerStage,
                     uint tgrSettingsMaxStages,
                     uint blockNumber,
                     uint tgrNumber); 

     
     
     
    constructor(address _projectWallet, address _foundersWallet) public {
        projectWallet = _projectWallet;
        foundersWallet = _foundersWallet;
    }

     
    function () public payable isTgrLive isNotFrozenOnly noAnyReentrancy {
        require(whitelist.whitelist(msg.sender));  
        require(tgrSettingsAmountCollected < tgrSettingsAmount);  
        require(msg.value >= tgrSettingsMinimalInvestment); 

        uint stage = block.number.sub(tgrStartBlock).div(tgrSettingsBlocksPerStage);
        require(stage < tgrSettingsMaxStages);  

         
        uint refundAmount = 0;
        uint senderAmount = msg.value;
        if(tgrSettingsAmountCollected.add(msg.value) >= tgrSettingsAmount){
            refundAmount = tgrSettingsAmountCollected.add(msg.value).sub(tgrSettingsAmount);
            senderAmount = (msg.value).sub(refundAmount);
        }
        
        uint currentPartInvestor = tgrSettingsPartInvestor.add(stage.mul(tgrSettingsPartInvestorIncreasePerStage));
        uint allStakes = currentPartInvestor.add(tgrSettingsPartProject).add(tgrSettingsPartFounders);
        uint amountProject = senderAmount.mul(tgrSettingsPartProject).div(allStakes);
        uint amountFounders = senderAmount.mul(tgrSettingsPartFounders).div(allStakes);
        uint amountSender = senderAmount.sub(amountProject).sub(amountFounders);
        _mint(amountProject, amountFounders, amountSender);
        msg.sender.transfer(refundAmount);
        this.updateStatus();
    }

     
    function tgrSetLive() public only(projectWallet) isNotTgrLive isNotFrozenOnly {
        tgrNumber +=1;
        tgrLive = true;
        tgrStartBlock = block.number;
        tgrSettingsAmountCollected = 0;
        emit TGRStarted(tgrSettingsAmount,
                     tgrSettingsMinimalInvestment,
                     tgrSettingsPartInvestor,
                     tgrSettingsPartProject, 
                     tgrSettingsPartFounders, 
                     tgrSettingsBlocksPerStage, 
                     tgrSettingsPartInvestorIncreasePerStage,
                     tgrSettingsMaxStages,
                     block.number,
                     tgrNumber); 
    }

    function tgrSetFinished() public only(projectWallet) isTgrLive isNotFrozenOnly {
            tgrLive = false;
    }

     
    function updateStatus() public {
            uint stage = block.number.sub(tgrStartBlock).div(tgrSettingsBlocksPerStage);
            if (stage > tgrSettingsMaxStages || isFrozen) {
                tgrLive = false;
            }
            if (tgrSettingsAmountCollected >= tgrSettingsAmount){
                tgrLive = false;
            }
    }

     
     
    function burn(uint _amount) public isNotFrozenOnly noAnyReentrancy returns(bool _success) {
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[burnAddress] = balances[burnAddress].add(_amount);
        totalSupply = totalSupply.sub(_amount);
        msg.sender.transfer(_amount);
        emit Transfer(msg.sender, burnAddress, _amount);
        emit Burn(burnAddress, _amount);
        return true;
    }

    function transfer(address _to, uint _value) public isNotFrozenOnly onlyPayloadSize(2 * 32) returns (bool success) {
        require(_to != address(0));
        require(_to != address(this));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

     
     
     
    function multiTransfer(address[] dests, uint[] values) public isNotFrozenOnly returns(uint) {
        uint i = 0;
        while (i < dests.length) {
           transfer(dests[i], values[i]);
           i += 1;
        }
        return i;
    }
    
     
    function withdrawFrozen() public isFrozenOnly noAnyReentrancy {
        uint amountWithdraw = totalSupply.mul(invBalances[msg.sender]).div(totalInvSupply);
         
        if (amountWithdraw > address(this).balance) {
            amountWithdraw = address(this).balance;
        }
        invBalances[msg.sender] = 0;
        msg.sender.transfer(amountWithdraw);
    }

    function setWhitelist(address _address) public only(projectWallet) isNotFrozenOnly returns (bool) {
        whitelist = Whitelist(_address);
    }

     
    function executeSettingsChange(
        uint amount, 
        uint minimalInvestment,
        uint partInvestor,
        uint partProject, 
        uint partFounders, 
        uint blocksPerStage, 
        uint partInvestorIncreasePerStage,
        uint maxStages
    ) 
    public
    only(projectWallet)
    isNotTgrLive 
    isNotFrozenOnly
    returns(bool success) 
    {
        tgrSettingsAmount = amount;
        tgrSettingsMinimalInvestment = minimalInvestment;
        tgrSettingsPartInvestor = partInvestor;
        tgrSettingsPartProject = partProject;
        tgrSettingsPartFounders = partFounders;
        tgrSettingsBlocksPerStage = blocksPerStage;
        tgrSettingsPartInvestorIncreasePerStage = partInvestorIncreasePerStage;
        tgrSettingsMaxStages = maxStages;
        return true;
    }

     
    function setFreeze() public only(projectWallet) isNotFrozenOnly returns (bool) {
        isFrozen = true;
        return true;
    }

    function _mint(uint _amountProject, uint _amountFounders, uint _amountSender) internal {
        balances[projectWallet] = balances[projectWallet].add(_amountProject);
        balances[foundersWallet] = balances[foundersWallet].add(_amountFounders);
        balances[msg.sender] = balances[msg.sender].add(_amountSender);

        invBalances[msg.sender] = invBalances[msg.sender].add(_amountSender).add(_amountFounders).add(_amountProject);
        totalInvSupply = totalInvSupply.add(_amountSender).add(_amountFounders).add(_amountProject);
        tgrSettingsAmountCollected = tgrSettingsAmountCollected.add(_amountProject).add(_amountFounders).add(_amountSender);
        totalSupply = totalSupply.add(_amountProject).add(_amountFounders).add(_amountSender);

        emit Transfer(0x0, msg.sender, _amountSender);
        emit Transfer(0x0, projectWallet, _amountProject);
        emit Transfer(0x0, foundersWallet, _amountFounders);
    }

     
     
    function tgrStageBlockLeft() public view returns(uint) {
        uint stage = block.number.sub(tgrStartBlock).div(tgrSettingsBlocksPerStage);
        return tgrStartBlock.add(stage.mul(tgrSettingsBlocksPerStage)).sub(block.number);
    }

    function tgrCurrentPartInvestor() public view returns(uint) {
        uint stage = block.number.sub(tgrStartBlock).div(tgrSettingsBlocksPerStage);
        return tgrSettingsPartInvestor.add(stage.mul(tgrSettingsPartInvestorIncreasePerStage));
    }

    function tgrNextPartInvestor() public view returns(uint) {
        uint stage = block.number.sub(tgrStartBlock).div(tgrSettingsBlocksPerStage).add(1);        
        return tgrSettingsPartInvestor.add(stage.mul(tgrSettingsPartInvestorIncreasePerStage));
    }

     
    function tgrCurrentStage() public view returns(uint) {
        return block.number.sub(tgrStartBlock).div(tgrSettingsBlocksPerStage).add(1);        
    }

     
    function minimumCap() public view returns(uint) {
        uint allStakes = (tgrSettingsMaxStages.mul(tgrSettingsPartInvestorIncreasePerStage)).add(tgrSettingsPartInvestor).add(tgrSettingsPartProject).add(tgrSettingsPartFounders);
        if (allStakes == 0) {
            return 0;
        }
        return (tgrSettingsPartProject.add(tgrSettingsPartFounders))*tgrSettingsAmount/allStakes;
    }

}