pragma solidity ^0.4.25;

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

contract Platform
{
    address public platform = address(0);

    constructor()
    public
    {
         
        if (platform == address (0))
        {
            platform = msg.sender;
        }
    }


    modifier onlyPlatform() {
        require(msg.sender == platform);
        _;
    }

    modifier onlyWhenPlatformIsTxOrigin() {
        require(tx.origin == platform);
        _;
    }

    function isPlatform() public view returns (bool) {
        return platform == msg.sender;
    }

    function setPlatform(address new_platform)
    public
        onlyPlatform
    {
        require(new_platform != address(0));

        platform = new_platform;
    }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract CINStockToken is ERC20Basic {

    using SafeMath for uint256;


     

     
     
    function checkCanAddStockProfit() internal view returns (bool);

     
     
     
    function moveInvestmentsBaseCompany(address, address, uint, uint) public;

     

     
    mapping (address => uint256) balances;

     
    mapping (address => uint256) withdrawn;

    uint public constant         decimals = 18;

     
    uint internal full_profit;

     
    uint internal full_withdrawn_profit;

     
    event profitAdded(uint value);

     
    event profitWithdrawn(address withdawer, uint value);


     
    function addStockProfitInternal(uint _value)
    internal
    {
        require(checkCanAddStockProfit());
        full_profit = full_profit.add(_value);
        emit profitAdded(_value);
    }

     
    function fullProfit()
    public view
    returns (uint)
    {
        return full_profit;
    }

     
    function fullWithdrawnProfit()
    public view
    returns (uint)
    {
        return full_withdrawn_profit;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

         
        require(_to != address(this));

         
        this.moveInvestmentsBaseCompany(msg.sender, _to, _value, balances[msg.sender]);

         
        uint withdraw_to_transfer = withdrawn[msg.sender];
        withdraw_to_transfer = withdraw_to_transfer.mul(_value);
        withdraw_to_transfer = withdraw_to_transfer.div(balances[msg.sender]);

         
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

         
        withdrawn[msg.sender] = withdrawn[msg.sender].sub(withdraw_to_transfer);
        withdrawn[_to] = withdrawn[_to].add(withdraw_to_transfer);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }


     
     
    function returnTokensToContractFrom(address from)
    internal
    {
        uint balance = balances[from];
        balances[from] = balances[from].sub(balance);
        balances[this] = balances[this].add(balance);
    }

     
    function getAvailableWithdrawProfitValue(address addr)
    public view
    returns (uint)
    {
        require(addr != address(0));
        require(addr != address(this));


        uint available_withdraw_wei = balances[addr];
        available_withdraw_wei = available_withdraw_wei.mul(full_profit);
        available_withdraw_wei = available_withdraw_wei.div(totalSupply.sub(balances[this]));
        available_withdraw_wei = available_withdraw_wei.sub(withdrawn[addr]);

        return available_withdraw_wei;
    }



     
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

     
     
    function withdrawnOf(address _owner) public constant returns (uint256) {
        return withdrawn[_owner];
    }
}


contract StandardCINStockToken is ERC20, CINStockToken {

    mapping (address => mapping (address => uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

         
        require(_to != address(this));

         
        this.moveInvestmentsBaseCompany( _from, _to, _value,balances[_from]);


         
         
        uint withdraw_to_transfer = withdrawn[_from];
        withdraw_to_transfer = withdraw_to_transfer.mul(_value);
        withdraw_to_transfer = withdraw_to_transfer.div(balances[_from]);

         
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

         
        withdrawn[_from] = withdrawn[_from].sub(withdraw_to_transfer);
        withdrawn[_to] = withdrawn[_to].add(withdraw_to_transfer);


        emit Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool) {
         
        require(_spender != address(this));

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
         
        require(_spender != address(this));

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
         
        require(_spender != address(this));

        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        }
        else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract DebugNow
{
    uint  public                            DEBUG_NOW;

     
    function setDebugNow(uint epoch)
    public
    {
        DEBUG_NOW = epoch;
    }

     
     
    function getDebugNow()
    public view
    returns(uint)
    {
        return DEBUG_NOW;
    }

     
     
    function currentTime()
    public view
    returns(uint)
    {
        return DEBUG_NOW;
         
         
    }
}

contract OwnerInterface
{
    function canChangeOwnerParams() internal returns (bool);
    function canSetNewOwnerPercentage(uint percentage) internal returns (bool);
}

contract Owner is OwnerInterface, Platform
{
    address public owner = address(0);

     
    uint   public                   OWNER_TOKEN_PERCENTAGE = 0;
     
    uint   internal              _all_investments_withdrawn_by_owner;

    constructor()
    public
    {
        require(OWNER_TOKEN_PERCENTAGE <= 100);

         
        if (owner == address(0))
        {
            owner = msg.sender;
        }
    }

    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }

    function isOwner()
    public view returns (bool)
    {
        return owner == msg.sender;
    }

     
    function setOwner(address new_owner)
        onlyPlatform
    public
    {
        require(new_owner != address(0));
        require(canChangeOwnerParams());

        owner = new_owner;
    }

     
     
    function setOwnerTokenPercentage(uint new_percentage)
        onlyOwner
    public
    {
        require(canSetNewOwnerPercentage(new_percentage));
        OWNER_TOKEN_PERCENTAGE = new_percentage;
    }

     
    function getAllInvestmentsWithdrawnByOwner()
    public view
    returns (uint)
    {
        return _all_investments_withdrawn_by_owner;
    }
}


contract BeneficiaryInterface
{
    function getAvailableWithdrawInvestmentsForBeneficiary() public view returns (uint);
    function withdrawInvestmentsBeneficiary(address withdraw_address) public;
    function canChangeBeneficiaryParams() internal returns (bool);
}


contract Beneficiary is BeneficiaryInterface, Platform
{
    address public                  beneficiary = address(0);

     
    uint public                     BENEFICIARY_TOKEN_PERCENTAGE = 0;

     
    uint public                     BENEFICIARY_INVESTMENTS_PERCENTAGE = 0;

     
    uint internal                   _all_investments_withdrawn_by_beneficiary = 0;


    constructor()
    public
    {
        require(BENEFICIARY_TOKEN_PERCENTAGE <= 100);
        require(BENEFICIARY_INVESTMENTS_PERCENTAGE <= 100);
    }

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary);
        _;
    }

     
    function getAllInvestmentsWithdrawnByBeneficiary()
    public view
    returns (uint)
    {
        return _all_investments_withdrawn_by_beneficiary;
    }

    function setBeneficiary(address new_beneficiary)
    public
        onlyPlatform
    {
        require(new_beneficiary != address(0));
        require(canChangeBeneficiaryParams());

        beneficiary = new_beneficiary;
    }
}


contract BaseInvestmentCompany is  Beneficiary, DebugNow, Owner
{
    using SafeMath for uint256;

     
    string public               name;
    string public               symbol;
    uint public constant        decimals = 18;

    uint8 public constant       MAX_NAME_LENGTH = 32;
    uint8 public constant       MAX_SYMBOL_LENGTH = 4;


     
     
     
    uint256 public constant     WEI_COUNT_IN_ONE_TOKEN = uint256(10) ** decimals;

     
    uint   public               min_investment_size_in_wei = 0;


     
    uint   internal              _all_investments_withdrawn_back;

     
    Phase[] internal            _phases;


     
    bool internal               _phases_committed;

     
    uint public constant        MAX_PHASES_COUNT = 5;
    uint public constant        MAX_SUBPHASES_COUNT  = 5;


     

     
     
    function withdrawMyInvestmentsBack() public;

     
     
    function checkCanAddPhaseDerived(Phase phase) internal view returns (bool);

     
     
    function commitPhasesDerived() internal;

     
     
    function transferFromContractTo(address, uint) public;

     
     
     
    function isInitialized() public view returns (bool);

     
     
    function getBalance() public view returns (uint);

     
    function getContractType() public pure returns (string);
     


     

     
    event InvestmentsWithdrawnByOwner(address withdraw_address, uint value);

     
    event InvestmentMade(address investor,  uint invest_value,  uint tokens_value);

     


     
    constructor()
    public
    {
        require(BENEFICIARY_TOKEN_PERCENTAGE.add(OWNER_TOKEN_PERCENTAGE) <= 100);
    }


     
    function()
    public payable
    {
        revert();
    }

    function canChangeBeneficiaryParams() internal returns (bool)
    {
        return (state() == CompanyState.waiting_for_initialization);
    }

    function canChangeOwnerParams() internal returns (bool)
    {
        return (state() == CompanyState.waiting_for_initialization);
    }

     
    function canSetNewOwnerPercentage(uint percentage) internal returns (bool)
    {
        return (state() == CompanyState.waiting_for_initialization)
               &&
               (percentage.add(BENEFICIARY_TOKEN_PERCENTAGE) <= 100);
    }

     

     
    function setTokenNameSymbol(
        string       token_name,
        string       token_symbol)
            onlyOwner
    public
    {
        require(state() == CompanyState.waiting_for_initialization);
        require(bytes(name).length==0 && bytes(symbol).length==0);
        require(bytes(token_name).length <= MAX_NAME_LENGTH);
        require(bytes(token_symbol).length <= MAX_SYMBOL_LENGTH);

        name = token_name;
        symbol = token_symbol;
    }

     
     
    function addPhase(
        uint32   start_time,
        uint[]   prices_in_wei,
        uint32[] prices_in_wei_ends,
        uint     phase_emission,  
        uint     min_tokens_to_sell  
    )
        onlyOwner
    public
    {
        require(state() == CompanyState.waiting_for_initialization);

         
        Phase memory phase;
        phase.start_time =  start_time;
        phase.prices_in_wei = prices_in_wei;
        phase.prices_in_wei_ends = prices_in_wei_ends;
        phase.phase_emission = phase_emission.mul(WEI_COUNT_IN_ONE_TOKEN);
        phase.min_tokens_to_sell = min_tokens_to_sell.mul(WEI_COUNT_IN_ONE_TOKEN);

         
        require(checkCanAddPhaseBase(phase));
        require(checkCanAddPhaseDerived(phase));

         
        _phases.push(phase);
    }

     
     
    function commitPhases()
        onlyOwner
    public
    {
        require(state() == CompanyState.waiting_for_initialization);
        require(_phases.length !=0);
        require(!_phases_committed);

        commitPhasesDerived();

        _phases_committed = true;
    }


     
    function checkCanAddPhaseBase(Phase phase)
    internal view
    returns (bool)
    {
         
         
        if (_phases.length >= MAX_PHASES_COUNT)
        {
            return false;
        }

         
        if (phase.min_tokens_to_sell == 0)
        {
            return false;
        }

         
        if (phase.prices_in_wei.length == 0 ||  phase.prices_in_wei.length != phase.prices_in_wei_ends.length)
        {
            return false;
        }

         
         
        if (phase.prices_in_wei.length >= MAX_SUBPHASES_COUNT )
        {
            return false;
        }

         
        if (phase.start_time <= currentTime())
        {
            return false;
        }

         
        if (_phases.length > 0)
        {
            if (phase.start_time <= getEndTime())
            {
                return false;
            }
        }

         
        uint32 last_date = phase.start_time;
        for (uint i=0; i < phase.prices_in_wei.length; i++)
        {
             
            if (phase.prices_in_wei[i] == 0)
            {
                return false;
            }

             
            if (phase.prices_in_wei_ends[i] <= last_date)
            {
                return false;
            }

            last_date = phase.prices_in_wei_ends[i];
        }

         
        if (_phases.length > 0)
        {
            if ((_phases[_phases.length-1].phase_emission == 0 && phase.phase_emission > 0) ||
                (_phases[_phases.length-1].phase_emission  > 0 && phase.phase_emission == 0))
            {
                return false;
            }

        }

         
         
         
        if (phase.phase_emission != 0)   
        {
            uint available_to_sell =
                phase.phase_emission
                    .mul(
                        uint256(100)
                        .sub(BENEFICIARY_TOKEN_PERCENTAGE)
                        .sub(OWNER_TOKEN_PERCENTAGE))
                    .div(100);

            if (available_to_sell < phase.min_tokens_to_sell)
            {
                return false;
            }
        }

        return true;
    }
     



     
    function checkCanInvestInternal(address investor, uint invest_value)
    internal view
    returns(bool)
    {
        return
            (investor != owner) &&
            (investor != platform) &&
            (invest_value >= min_investment_size_in_wei) &&
            (state() == CompanyState.collecting);
    }

     
     
    function cancel()
    public
        onlyOwner
    {
        require((state() == CompanyState.initialized) || (state() == CompanyState.collecting));
         
        for (uint i = 0; i < _phases.length; i++)
        {
            PhaseState p_state = getPhaseState(i);
            if (p_state == PhaseState.waiting_for_collecting || p_state == PhaseState.collecting)
            {
                _phases[i].cancelled = true;
            }
        }
    }

     
    function state()
    public view
    returns (CompanyState)
    {
         
        if (!isInitialized())
        {
            return CompanyState.waiting_for_initialization;
        }

         
        for (uint i = 0; i < _phases.length; i++)
        {
            if (getPhaseState(i) == PhaseState.cancelled)
            {
                return CompanyState.cancelled;
            }
        }

         
        if (currentTime() < getStartTime())
        {
            return CompanyState.initialized;
        }

         
         
         
        for (i = 0; i < _phases.length; i++)
        {
            if (getPhaseState(i) == PhaseState.failed)
            {
                return CompanyState.collecting_failed;
            }
        }

         
        if (currentTime() >= getStartTime() &&
            currentTime() <= getEndTime())
        {
            return CompanyState.collecting;
        }

         
        return CompanyState.collecting_succeed;
    }


     
     
    function getAvailableTokensToSellTillPhaseIdxValue(
        uint last_phase_idx
    )
    public view
    returns (uint available_to_sell)
    {
        require(last_phase_idx < _phases.length);

         
        if (getEmissionType() == EmissionType.unlimited)
        {
            return 0;
        }

        for (uint i = 0; i <= last_phase_idx; i++)
        {
            available_to_sell = available_to_sell.add(getAvailableTokensToSellCurrentPhaseIdx(i));
        }
        return available_to_sell;
    }

     
     
    function getAvailableTokensToSellCurrentPhaseIdx(uint idx)
    public view
    returns(uint)
    {
        require(idx < _phases.length);

         
        if (getEmissionType() == EmissionType.unlimited)
        {
            return 0;
        }

        return  _phases[idx].phase_emission
                    .mul(
                        uint256(100)
                        .sub(BENEFICIARY_TOKEN_PERCENTAGE)
                        .sub(OWNER_TOKEN_PERCENTAGE))
                    .div(100)
                    .sub(_phases[idx].tokens_sold);
    }


     
    function getPhasesCount()
    public view
    returns (uint)
    {
        return _phases.length;
    }


     
    function getPhasePricesPeriods(uint idx)
    public view
    returns (
        uint[] prices_in_wei,
        uint32[] prices_in_wei_ends)
    {
        require(idx < _phases.length);

        return (
            _phases[idx].prices_in_wei,
            _phases[idx].prices_in_wei_ends
        );
    }


     
    function getPhaseStatus(uint idx)
    public view
    returns (
        uint32,  
        uint32,  
        uint,    
        uint,    
        uint,    
        uint,    
        uint     
    )
    {
        require(idx < _phases.length);
        return (
            _phases[idx].start_time,
            _phases[idx].prices_in_wei_ends[_phases[idx].prices_in_wei_ends.length-1],
            _phases[idx].min_tokens_to_sell,
            _phases[idx].tokens_sold,
            _phases[idx].phase_emission,
            _phases[idx].investments_collected,
            getAvailableTokensToSellCurrentPhaseIdx(idx)
        );
    }

     
    function getPhaseState(uint idx)
    public view
    returns (PhaseState)
    {
        require(idx < _phases.length);

         
        if (_phases[idx].cancelled)
        {
            return PhaseState.cancelled;
        }

         
        if (currentTime() < _phases[idx].start_time)
        {
            return PhaseState.waiting_for_collecting;
        }

         
        if (currentTime() >= _phases[idx].start_time &&
            currentTime() <= _phases[idx].prices_in_wei_ends[_phases[idx].prices_in_wei_ends.length-1])
        {
            return PhaseState.collecting;
        }

         
        if (_phases[idx].tokens_sold >= _phases[idx].min_tokens_to_sell)
            return PhaseState.succeed;

        return PhaseState.failed;
    }


     
     
    function getEmissionType()
    public view
    returns (EmissionType)
    {
        if (_phases.length ==0)
        {
            return EmissionType.undefined;
        }

         
        return getPhaseEmissionType(0);
    }


     
    function getPhaseEmissionType(uint idx)
    public view
    returns (EmissionType em_type)
    {
        require(idx < _phases.length);

        return _phases[idx].phase_emission == 0 ? EmissionType.unlimited : EmissionType.limited;
    }


     
     
    function getTokenPriceInWeiAndPhaseIdxs()
    public view
    returns (
        uint price,
        uint phase_idx,
        uint phase_sub_idx)
    {
        return getTokenPriceInWeiAndPhaseIdxsForDate(currentTime());
    }


     
     
    function getTokenPriceInWeiAndPhaseIdxsForDate(uint date)
    public view
    returns (
        uint price,
        uint phase_idx,
        uint phase_sub_idx)
    {
        for (uint i = 0; i < _phases.length; i++)
        {
            uint32 stage_start_time = _phases[i].start_time;
            for (uint j = 0; j < _phases[i].prices_in_wei_ends.length; j++)
            {
                if (stage_start_time <= date &&
                    date < _phases[i].prices_in_wei_ends[j])
                        return (_phases[i].prices_in_wei[j], i, j);
                stage_start_time = _phases[i].prices_in_wei_ends[j];
            }
        }
        return (0, 0, 0);
    }

     
    function getAllInvestmentsCollected()
    public view
    returns (uint all_investments_collected)
    {
        for (uint i = 0; i < _phases.length; i++)
            all_investments_collected = all_investments_collected.add(_phases[i].investments_collected);
        return all_investments_collected;
    }




     
    function getAllSuccessInvestmentsCollected()
    public view
    returns (uint success_investments_collected)
    {
        for (uint i = 0; i < _phases.length; i++)
        {
            if (getPhaseState(i) == PhaseState.succeed)
            {
                success_investments_collected = success_investments_collected.add(_phases[i].investments_collected);
            }
        }
        return success_investments_collected;
    }


     
    function getAllFailedInvestmentsCollected()
    public view
    returns (uint failed_investments_collected)
    {
        for (uint i = 0; i < _phases.length; i++)
        {
            PhaseState p_state = getPhaseState(i);
            if (p_state == PhaseState.failed || p_state == PhaseState.cancelled)
            {
                failed_investments_collected =  failed_investments_collected.add(_phases[i].investments_collected);
            }
        }
        return failed_investments_collected;
    }



     
    function getAllInvestmentsWithdrawnBack()
    public view
    returns (uint)
    {
          return _all_investments_withdrawn_back;
    }


     
    function getAvailableWithdrawInvestmentsForOwner()
    public view
    returns (uint)
    {
        return getAllSuccessInvestmentsCollected()
                    .mul(
                        uint256(100)
                        .sub(BENEFICIARY_INVESTMENTS_PERCENTAGE))
                    .div(100)
                    .sub(_all_investments_withdrawn_by_owner);
    }


     
     
    function getAvailableInvestmentsBackValue(address addr)
    public view
    returns (uint investments_back_value)
    {
        require(addr != address(0));

        CompanyState c_state = state();


        if (c_state == CompanyState.collecting_failed || c_state == CompanyState.cancelled)
        {
             
             
             
            for (uint i = 0; i < _phases.length; i++)
            {
                PhaseState p_state = getPhaseState(i);
                if (p_state == PhaseState.failed || p_state == PhaseState.cancelled)
                {
                    investments_back_value = investments_back_value.add(_phases[i].investments[addr]);
                }
            }

        }
    }


     
    function getAvailableWithdrawInvestmentsForBeneficiary()
    public view
    returns (uint)
    {
        return getAllSuccessInvestmentsCollected()
                .mul(BENEFICIARY_INVESTMENTS_PERCENTAGE)
                .div(100)
                .sub(_all_investments_withdrawn_by_beneficiary);
    }


     
    function getAllTokenSold()
    public view
    returns (uint all_tokens_sold)
    {
        for (uint i = 0; i < _phases.length; i++)
            all_tokens_sold = all_tokens_sold.add(_phases[i].tokens_sold);
    }


     
    function getEndTime()
    public view
    returns(uint)
    {
        require(_phases.length !=0);

        return _phases[_phases.length-1].prices_in_wei_ends[
            _phases[_phases.length-1].prices_in_wei_ends.length-1
        ];
    }


     
    function getStartTime()
    public view
    returns(uint)
    {
        require(_phases.length !=0);

        return _phases[0].start_time;
    }



     
     
    function withdrawInvestmentsBeneficiary(address withdraw_address)
        onlyBeneficiary
    public
    {
        uint to_withdraw = getAvailableWithdrawInvestmentsForBeneficiary();
        if (to_withdraw != 0)
        {
            _all_investments_withdrawn_by_beneficiary = _all_investments_withdrawn_by_beneficiary.add(to_withdraw);
            this.transferFromContractTo(withdraw_address, to_withdraw);
        }
    }


     
     
     
    function moveInvestmentsBaseCompany(
        address from,  
        address to,    
        uint value,    
        uint balance   
    )
    public
    {
        require(msg.sender == address(this));
        require(isInitialized());
        require(value !=0);
        require(balance !=0);
        require(balance >= value);

         
         
        for (uint i = 0; i < _phases.length; i++)
        {
            uint investments_to_move_value = _phases[i].investments[from].mul(value).div(balance);
            _phases[i].investments[from] = _phases[i].investments[from].sub(investments_to_move_value);
            _phases[i].investments[to] = _phases[i].investments[to].add(investments_to_move_value);
        }
    }


     
     
    function zeroInvestments()  
    internal
    {
        CompanyState c_state = state();
        require(c_state == CompanyState.collecting_failed || c_state == CompanyState.cancelled);

        for (uint i = 0; i < _phases.length; i++)
        {
            PhaseState p_state = getPhaseState(i);
            if (p_state == PhaseState.failed || p_state == PhaseState.cancelled )
            {
                _phases[i].investments[msg.sender] = 0;
            }
        }
    }


    struct Phase
    {
         
        uint32   start_time;

         
        uint[]   prices_in_wei;

         
        uint32[] prices_in_wei_ends;

         
        uint     min_tokens_to_sell;

         
        uint     tokens_sold;

         
         
        uint     phase_emission;

         
        uint     investments_collected;

         
        mapping(address => uint256) investments;

         
        bool     cancelled;

    }


    enum CompanyState
    {
        undefined,  
        waiting_for_initialization,  
        initialized,  
        collecting,  
        collecting_succeed,  
        collecting_failed,  
        cancelled  
    }


    enum PhaseState
    {
        undefined,  
        waiting_for_collecting,  
        collecting,  
        succeed,  
        failed,   
        cancelled  
    }


    enum EmissionType
    {
        undefined,  
        limited,  
        unlimited  
    }
}

 










contract CINInvestmentCompanyInterface
{
    function invest_cin(address, uint) public;
    function add_profit(address, uint) public;
    function withdraw_profit(address) public;
}


contract CINInvestmentCompany is StandardCINStockToken, BaseInvestmentCompany, CINInvestmentCompanyInterface
{
     
    address public                 _CIN_token_address;

    function getContractType() public pure returns (string)
    {
        return "CINCrowdInvestingLimited";
    }

     
     
    function isInitialized()
    public view
    returns (bool)
    {
        return (
            _phases_committed &&
             bytes(name).length != 0 &&
             bytes(symbol).length != 0 &&
             _CIN_token_address != address(0) &&
            owner != address(0) &&
             
            ((BENEFICIARY_TOKEN_PERCENTAGE == 0 && BENEFICIARY_INVESTMENTS_PERCENTAGE == 0)  || (beneficiary != address(0)))
        );
    }


     
    function getBalance()
    public view
    returns (uint)
    {
        return ERC20Basic(_CIN_token_address).balanceOf(address(this));
    }



     
     
    function setCINTokenAddress(address cin_token_address)
    public
        onlyPlatform
    {
        require(state() == CompanyState.waiting_for_initialization);

         
        require(_CIN_token_address == address(0));

         
        _CIN_token_address = cin_token_address;
    }


     
     
    function transferFromContractTo(address dest, uint value) public
    {
         
        require(
            msg.sender == _CIN_token_address ||
            msg.sender == address(this));

        ERC20Basic(_CIN_token_address).transfer(dest, value);
    }


    function invest_cin(address _investor, uint _value)
    public
    {
        require(msg.sender == _CIN_token_address);
        require(checkCanInvestInternal(_investor, _value));

        uint token_price_in_wei;
        uint phase_idx;

        (token_price_in_wei, phase_idx, ) = getTokenPriceInWeiAndPhaseIdxsForDate(currentTime());

         
        require(token_price_in_wei > 0);

         
        uint user_wants =_value.mul(WEI_COUNT_IN_ONE_TOKEN).div(token_price_in_wei);

         
        require(user_wants <= getAvailableTokensToSellTillPhaseIdxValue(phase_idx));

         
        balances[_investor] = balances[_investor].add(user_wants);
        balances[this] = balances[this].sub(user_wants);
        emit Transfer(this, _investor, user_wants);

         
        _phases[phase_idx].tokens_sold = _phases[phase_idx].tokens_sold.add(user_wants);
        _phases[phase_idx].investments_collected = _phases[phase_idx].investments_collected.add(_value);
        _phases[phase_idx].investments[_investor] = _phases[phase_idx].investments[_investor].add(_value);

         
        emit InvestmentMade(_investor, _value, user_wants);
    }


     
    function checkCanAddStockProfit()
    internal view
    returns (bool)
    {
        return (
            state() == CompanyState.collecting_succeed &&
            msg.sender == _CIN_token_address
        );
    }



    function checkCanAddPhaseDerived(Phase phase) internal view returns (bool)
    {
         
         
        if(phase.phase_emission == 0)
        {
            return false;
        }

        return true;
    }

    function commitPhasesDerived()
        onlyOwner
    internal
    {
        require(state() == CompanyState.waiting_for_initialization);

         
         
        for (uint i = 0; i < _phases.length; i++)
        {
            totalSupply = totalSupply.add(_phases[i].phase_emission);
        }

        uint beneficiary_token_benefit = totalSupply.mul(BENEFICIARY_TOKEN_PERCENTAGE).div(100);
        uint owner_token_benefit = totalSupply.mul(OWNER_TOKEN_PERCENTAGE).div(100);

         
         
        balances[this] = totalSupply.sub(beneficiary_token_benefit).sub(owner_token_benefit);
        balances[beneficiary] = beneficiary_token_benefit;
        balances[owner] = owner_token_benefit;

         
        emit Transfer(address(0), this, totalSupply);

        if (beneficiary_token_benefit != 0)
        {
            emit Transfer(address(this), beneficiary, beneficiary_token_benefit);
        }

        if (owner_token_benefit != 0)
        {
            emit Transfer(address(this), owner, owner_token_benefit);
        }
    }


     
     
    function add_profit(address _sender,uint _value)
    public
    {
        require(state() == CompanyState.collecting_succeed);
        require(msg.sender == _CIN_token_address);
        require(_sender == owner);

        addStockProfitInternal(_value);
    }

     
     
    function withdraw_profit(address dest_address)
    public
    {
        require(state() == CompanyState.collecting_succeed);
        require(msg.sender == _CIN_token_address);
        require(dest_address != address(0));

        uint profit_value = getAvailableWithdrawProfitValue(dest_address);
        if (profit_value != 0 )
        {
            full_withdrawn_profit = full_withdrawn_profit.add(profit_value);
            withdrawn[dest_address] = withdrawn[dest_address].add(profit_value);
            this.transferFromContractTo(dest_address, profit_value);
            emit profitWithdrawn(dest_address, profit_value);
        }

    }

     
    function withdrawInvestmentsOwner(address withdraw_address)
        onlyOwner
    public
    {

         

        uint to_withdraw = getAvailableWithdrawInvestmentsForOwner();
        if (to_withdraw != 0)
        {
            _all_investments_withdrawn_by_owner = _all_investments_withdrawn_by_owner.add(to_withdraw);
            emit InvestmentsWithdrawnByOwner(withdraw_address, to_withdraw);
            this.transferFromContractTo(withdraw_address, to_withdraw);
        }
    }



     
    function withdrawMyInvestmentsBack()
    public
    {
        CompanyState c_state = state();
        require(c_state == CompanyState.collecting_failed || c_state == CompanyState.cancelled);

        uint to_withdraw = getAvailableInvestmentsBackValue(msg.sender);

        if (to_withdraw != 0)
        {
            _all_investments_withdrawn_back = _all_investments_withdrawn_by_owner.add(to_withdraw);

             
            zeroInvestments();

             
            returnTokensToContractFrom(msg.sender);

             
            this.transferFromContractTo(msg.sender, to_withdraw);
        }
    }
}