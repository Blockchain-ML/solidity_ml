 

pragma solidity ^0.5.0;

 

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

 

 
contract MultisigVaultETH {

    using SafeMath for uint256;

    struct Approval {
        bool transfered;
        uint256 coincieded;
        mapping(address => bool) coinciedeParties;
    }

    uint256 private participantsAmount;
    uint256 private signatureMinThreshold;
    address payable private serviceAddress;
    uint256 private serviceFeeMicro;

    string  private _symbol;
    uint8   private _decimals;

    address constant public ETHER_ADDRESS = address(0x1);

    mapping(address => bool) public parties;

    mapping(
         
        address => mapping(
             
            uint256 => Approval
        )
    ) public approvals;

    event ConfirmationReceived(address indexed from, address indexed destination, address currency, uint256 amount);
    event ConsensusAchived(address indexed destination, address currency, uint256 amount);

     
    constructor(
        uint256 _signatureMinThreshold,
        address[] memory _parties,
        address payable _serviceAddress,
        uint256 _serviceFeeMicro
    ) public {
        require(_parties.length > 0 && _parties.length <= 10);
        require(_signatureMinThreshold > 0 && _signatureMinThreshold <= _parties.length);

        signatureMinThreshold = _signatureMinThreshold;
        serviceAddress = _serviceAddress;
        serviceFeeMicro = _serviceFeeMicro;

        _symbol = "ETH";
        _decimals = 18;

        for (uint256 i = 0; i < _parties.length; i++) parties[_parties[i]] = true;
    }

    modifier isMember() {
        require(parties[msg.sender]);
        _;
    }

    modifier sufficient(uint256 _amount) {
        require(address(this).balance >= _amount);
        _;
    }

    function partyCoincieded(
        address _destination,
        uint256 _amount,
        address _partyAddress
    ) public view returns (bool) {
        Approval storage approval = approvals[_destination][_amount];
        return approval.coinciedeParties[_partyAddress];
    }

     
    function approve(
        address payable _destination,
        uint256 _amount
    ) public isMember sufficient(_amount) returns (bool) {
        Approval storage approval  = approvals[_destination][_amount];  

        if (!approval.coinciedeParties[msg.sender]) {
            approval.coinciedeParties[msg.sender] = true;
            approval.coincieded += 1;

            emit ConfirmationReceived(msg.sender, _destination, ETHER_ADDRESS, _amount);

            if (
                approval.coincieded >= signatureMinThreshold &&
                !approval.transfered
            ) {
                approval.transfered = true;

                uint256 _amountToWithhold = _amount.mul(serviceFeeMicro).div(1000000);
                uint256 _amountToRelease = _amount.sub(_amountToWithhold);

                _destination.transfer(_amountToRelease);     
                serviceAddress.transfer(_amountToWithhold);  

                emit ConsensusAchived(_destination, ETHER_ADDRESS, _amount);
            }

            return true;
        } else {
             
            return false;
        }
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function() external payable { }
}