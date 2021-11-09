 

 

pragma solidity ^0.4.11;


contract FlightDelayAccessControllerInterface {

    function setPermissionById(uint8 _perm, bytes32 _id) public;

    function setPermissionById(uint8 _perm, bytes32 _id, bool _access) public;

    function setPermissionByAddress(uint8 _perm, address _addr) public;

    function setPermissionByAddress(uint8 _perm, address _addr, bool _access) public;

    function checkPermission(uint8 _perm, address _addr) public returns (bool _success);
}

 

 

pragma solidity ^0.4.11;


contract FlightDelayConstants {

     

 
 
 
 
 
 
 
 
 
 
 
 
 

    event LogPolicyApplied(
        uint _policyId,
        address _customer,
        bytes32 strCarrierFlightNumber,
        uint ethPremium
    );
    event LogPolicyAccepted(
        uint _policyId,
        uint _statistics0,
        uint _statistics1,
        uint _statistics2,
        uint _statistics3,
        uint _statistics4,
        uint _statistics5
    );
    event LogPolicyPaidOut(
        uint _policyId,
        uint ethAmount
    );
    event LogPolicyExpired(
        uint _policyId
    );
    event LogPolicyDeclined(
        uint _policyId,
        bytes32 strReason
    );
    event LogPolicyManualPayout(
        uint _policyId,
        bytes32 strReason
    );
    event LogSendFunds(
        address _recipient,
        uint8 _from,
        uint ethAmount
    );
    event LogReceiveFunds(
        address _sender,
        uint8 _to,
        uint ethAmount
    );
    event LogSendFail(
        uint _policyId,
        bytes32 strReason
    );
    event LogOraclizeCall(
        uint _policyId,
        bytes32 hexQueryId,
        string _oraclizeUrl,
        uint256 _oraclizeTime
    );
    event LogOraclizeCallback(
        uint _policyId,
        bytes32 hexQueryId,
        string _result,
        bytes hexProof
    );
    event LogSetState(
        uint _policyId,
        uint8 _policyState,
        uint _stateTime,
        bytes32 _stateMessage
    );
    event LogExternal(
        uint256 _policyId,
        address _address,
        bytes32 _externalId
    );

     
     
    uint public constant MAJOR_VERSION = 1;
    uint public constant MINOR_VERSION = 0;
    uint public constant PATCH_VERSION = 2;

     
    uint constant MIN_OBSERVATIONS = 10;
     
    uint constant MIN_PREMIUM = 50 finney;
     
    uint constant MAX_PREMIUM = 1 ether;
     
    uint constant MAX_PAYOUT = 1100 finney;

    uint constant MIN_PREMIUM_EUR = 1500 wei;
    uint constant MAX_PREMIUM_EUR = 29000 wei;
    uint constant MAX_PAYOUT_EUR = 30000 wei;

    uint constant MIN_PREMIUM_USD = 1700 wei;
    uint constant MAX_PREMIUM_USD = 34000 wei;
    uint constant MAX_PAYOUT_USD = 35000 wei;

    uint constant MIN_PREMIUM_GBP = 1300 wei;
    uint constant MAX_PREMIUM_GBP = 25000 wei;
    uint constant MAX_PAYOUT_GBP = 270 wei;

     
    uint constant MAX_CUMULATED_WEIGHTED_PREMIUM = 60 ether;
     
    uint8 constant REWARD_PERCENT = 2;
     
    uint8 constant RESERVE_PERCENT = 1;
     
     
     
    uint8[6] WEIGHT_PATTERN = [
        0,
        0,
        0,
        30,
        50,
        50
    ];

 
     
     
    uint constant MIN_TIME_BEFORE_DEPARTURE	= 24 hours;  
     
    uint constant CHECK_PAYOUT_OFFSET = 15 minutes;  
 

 
 
 
 
 
 
 

     
    uint constant MAX_FLIGHT_DURATION = 2 days;
     
    uint constant CONTRACT_DEAD_LINE = 1922396399;

     
    uint constant ORACLIZE_GAS = 700000;
    uint constant ORACLIZE_GASPRICE = 4000000000;


     

 
     
    string constant ORACLIZE_RATINGS_BASE_URL =
         
        "[URL] json(https://api.flightstats.com/flex/ratings/rest/v1/json/flight/";
    string constant ORACLIZE_RATINGS_QUERY =
        "?${[decrypt] BCGB+KxK9Hi0+HSuAjqUImcDiycjuUNPi8ibBGo6KFP/m9gOK6xtJbyi5lbPxPfDypCywVtTwe13VZbu02337Lw0mhTFO0OkUltmxGxi2mWgDBwN+VZdiXjtStOwuNYnhj8hjm71ppPGCVKXExvl1z3qDXkSbMMYZNBG+JNVFP7/YWhSZCXW}).ratings[0][&#39;observations&#39;,&#39;late15&#39;,&#39;late30&#39;,&#39;late45&#39;,&#39;cancelled&#39;,&#39;diverted&#39;,&#39;arrivalAirportFsCode&#39;,&#39;departureAirportFsCode&#39;]";
    string constant ORACLIZE_STATUS_BASE_URL =
         
        "[URL] json(https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/";
    string constant ORACLIZE_STATUS_QUERY =
         
        "?${[decrypt] BKc9+sMSvpu/p3qUjdu0QrHliQpNylhoQmHqL/8mQ/jKfsf7wdIiwwdMizp5u6LoP8rIvGhRfEcjK1SgotQDGFqws/5+9S9D5OXdEPXnkEsjQZJsyu8uhRRWg/0QSSP6LYP2ONUQc92QncGJbPCDxOcf3lGiNRrhznHfjFW7n+lwz4mVxN76}&utc=true).flightStatuses[0][&#39;status&#39;,&#39;delays&#39;,&#39;operationalTimes&#39;]";
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
}

 

 

pragma solidity ^0.4.11;


contract FlightDelayControllerInterface {

    function isOwner(address _addr) public returns (bool _isOwner);

    function selfRegister(bytes32 _id) public returns (bool result);

    function getContract(bytes32 _id) public returns (address _addr);
}

 

 

pragma solidity ^0.4.11;


contract FlightDelayDatabaseModel {

     
    enum Acc {
        Premium,       
        RiskFund,      
        Payout,        
        Balance,       
        Reward,        
        OraclizeCosts  
    }

     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     


     
    enum policyState { Applied, Accepted, Revoked, PaidOut, Expired, Declined, SendFailed }

     
    enum oraclizeState { ForUnderwriting, ForPayout }

     
    enum Currency { ETH, EUR, USD, GBP }

     
     
    struct Policy {
         
        address customer;

         
        uint premium;
         
         
        bytes32 riskId;
         
         
         
         
         
        uint weight;
         
        uint calculatedPayout;
         
        uint actualPayout;

         
         
        policyState state;
         
        uint stateTime;
         
        bytes32 stateMessage;
         
        bytes proof;
         
        Currency currency;
         
        bytes32 customerExternalId;
    }

     
     
     
     
    struct Risk {
         
        bytes32 carrierFlightNumber;
         
        bytes32 departureYearMonthDay;
         
        uint arrivalTime;
         
        uint delayInMinutes;
         
        uint8 delay;
         
        uint cumulatedWeightedPremium;
         
        uint premiumMultiplier;
    }

     
     
     
    struct OraclizeCallback {
         
        uint policyId;
         
        oraclizeState oState;
         
        uint oraclizeTime;
    }

    struct Customer {
        bytes32 customerExternalId;
        bool identityConfirmed;
    }
}

 

 

pragma solidity ^0.4.11;




contract FlightDelayControlledContract is FlightDelayDatabaseModel {

    address public controller;
    FlightDelayControllerInterface FD_CI;

    modifier onlyController() {
        require(msg.sender == controller);
        _;
    }

    function setController(address _controller) internal returns (bool _result) {
        controller = _controller;
        FD_CI = FlightDelayControllerInterface(_controller);
        _result = true;
    }

    function destruct() public onlyController {
        selfdestruct(controller);
    }

    function setContracts() public onlyController {}

    function getContract(bytes32 _id) internal returns (address _addr) {
        _addr = FD_CI.getContract(_id);
    }
}

 

 

pragma solidity ^0.4.11;



contract FlightDelayDatabaseInterface is FlightDelayDatabaseModel {

    uint public MIN_DEPARTURE_LIM;

    uint public MAX_DEPARTURE_LIM;

    bytes32[] public validOrigins;

    bytes32[] public validDestinations;

    function countOrigins() public constant returns (uint256 _length);

    function getOriginByIndex(uint256 _i) public constant returns (bytes32 _origin);

    function countDestinations() public constant returns (uint256 _length);

    function getDestinationByIndex(uint256 _i) public constant returns (bytes32 _destination);

    function setAccessControl(address _contract, address _caller, uint8 _perm) public;

    function setAccessControl(
        address _contract,
        address _caller,
        uint8 _perm,
        bool _access
    ) public;

    function getAccessControl(address _contract, address _caller, uint8 _perm) public returns (bool _allowed) ;

    function setLedger(uint8 _index, int _value) public;

    function getLedger(uint8 _index) public returns (int _value) ;

    function getCustomerPremium(uint _policyId) public returns (address _customer, uint _premium) ;

    function getPolicyData(uint _policyId) public returns (address _customer, uint _weight, uint _premium);

    function getPolicyState(uint _policyId) public returns (policyState _state) ;

    function getRiskId(uint _policyId) public returns (bytes32 _riskId);

    function createPolicy(address _customer, uint _premium, Currency _currency, bytes32 _customerExternalId, bytes32 _riskId) public returns (uint _policyId) ;

    function setState(
        uint _policyId,
        policyState _state,
        uint _stateTime,
        bytes32 _stateMessage
    ) public;

    function setWeight(uint _policyId, uint _weight, bytes _proof) public;

    function setPayouts(uint _policyId, uint _calculatedPayout, uint _actualPayout) public;

    function setDelay(uint _policyId, uint8 _delay, uint _delayInMinutes) public;

    function getRiskParameters(bytes32 _riskId)
        public returns (bytes32 _carrierFlightNumber, bytes32 _departureYearMonthDay, uint _arrivalTime) ;

    function getPremiumFactors(bytes32 _riskId)
        public returns (uint _cumulatedWeightedPremium, uint _premiumMultiplier);

    function createUpdateRisk(bytes32 _carrierFlightNumber, bytes32 _departureYearMonthDay, uint _arrivalTime)
        public returns (bytes32 _riskId);

    function setPremiumFactors(bytes32 _riskId, uint _cumulatedWeightedPremium, uint _premiumMultiplier) public;

    function getOraclizeCallback(bytes32 _queryId)
        public returns (uint _policyId, uint _oraclizeTime) ;

    function getOraclizePolicyId(bytes32 _queryId)
        public returns (uint _policyId) ;

    function createOraclizeCallback(
        bytes32 _queryId,
        uint _policyId,
        oraclizeState _oraclizeState,
        uint _oraclizeTime
    ) public;

    function checkTime(bytes32 _queryId, bytes32 _riskId, uint _offset)
        public returns (bool _result) ;
}

 

 

pragma solidity ^0.4.11;



contract FlightDelayLedgerInterface is FlightDelayDatabaseModel {

    function receiveFunds(Acc _to) public payable;

    function sendFunds(address _recipient, Acc _from, uint _amount) public returns (bool _success);

    function bookkeeping(Acc _from, Acc _to, uint amount) public;
}

 

 

pragma solidity ^0.4.11;







contract FlightDelayLedger is FlightDelayControlledContract, FlightDelayLedgerInterface, FlightDelayConstants {

    FlightDelayDatabaseInterface FD_DB;
    FlightDelayAccessControllerInterface FD_AC;

    function FlightDelayLedger(address _controller) public {
        setController(_controller);
    }

    function setContracts() public onlyController {
        FD_AC = FlightDelayAccessControllerInterface(getContract("FD.AccessController"));
        FD_DB = FlightDelayDatabaseInterface(getContract("FD.Database"));

        FD_AC.setPermissionById(101, "FD.NewPolicy");
        FD_AC.setPermissionById(101, "FD.Controller");  

        FD_AC.setPermissionById(102, "FD.Payout");
        FD_AC.setPermissionById(102, "FD.NewPolicy");
        FD_AC.setPermissionById(102, "FD.Controller");  
        FD_AC.setPermissionById(102, "FD.Underwrite");
        FD_AC.setPermissionById(102, "FD.Owner");

        FD_AC.setPermissionById(103, "FD.Funder");
        FD_AC.setPermissionById(103, "FD.Underwrite");
        FD_AC.setPermissionById(103, "FD.Payout");
        FD_AC.setPermissionById(103, "FD.Ledger");
        FD_AC.setPermissionById(103, "FD.NewPolicy");
        FD_AC.setPermissionById(103, "FD.Controller");
        FD_AC.setPermissionById(103, "FD.Owner");

        FD_AC.setPermissionById(104, "FD.Funder");
    }

     
    function () public payable {
        require(FD_AC.checkPermission(104, msg.sender));

        bookkeeping(Acc.Balance, Acc.RiskFund, msg.value);
    }

    function withdraw(uint256 _amount) {
        require(FD_AC.checkPermission(104, msg.sender));
        require(this.balance >= _amount);

        bookkeeping(Acc.RiskFund, Acc.Balance, _amount);

        getContract("FD.Funder").transfer(_amount);
    }

    function receiveFunds(Acc _to) public payable {
        require(FD_AC.checkPermission(101, msg.sender));

        LogReceiveFunds(msg.sender, uint8(_to), msg.value);

        bookkeeping(Acc.Balance, _to, msg.value);
    }

    function sendFunds(address _recipient, Acc _from, uint _amount) public returns (bool _success) {
        require(FD_AC.checkPermission(102, msg.sender));

        if (this.balance < _amount) {
            return false;  
        }

        LogSendFunds(_recipient, uint8(_from), _amount);

        bookkeeping(_from, Acc.Balance, _amount);  

        if (!_recipient.send(_amount)) {
            bookkeeping(Acc.Balance, _from, _amount);
            _success = false;
        } else {
            _success = true;
        }
    }

     

    function bookkeeping(Acc _from, Acc _to, uint256 _amount) public {
        require(FD_AC.checkPermission(103, msg.sender));

         
        assert(int256(_amount) > 0);

         
        FD_DB.setLedger(uint8(_from), -int(_amount));
        FD_DB.setLedger(uint8(_to), int(_amount));
    }
}