pragma solidity 0.4.24;

 
 
 
 
 
 
 

contract Owned {
  modifier only_owner { require(msg.sender == owner); _; }

  event NewOwner(address indexed old, address indexed current);

  function setOwner(address _new) only_owner public { NewOwner(owner, _new); owner = _new; }

  address public owner = msg.sender;
}

 
interface ContractReceiver {
  function tokenFallback( address from, uint value, bytes data ) external;
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);  
    uint256 c = a / b;
     

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}


contract CanYaCoin {

    using SafeMath for uint256;

    string public name = "CanYaCoin";
    string public symbol  = "CAN";
    uint256 public decimals  = 18;
    uint256 public totalSupply  = 100000000 * (10 ** decimals);

    uint256 public maxRefundableGasPrice = 10000000000;  
    uint256 public transferFeePercentTenths = 10;
    address public feeRecipient;
    address public owner;

     
    mapping(address => uint256) balances_;
    mapping(address => mapping(address => uint256)) allowances_;
    mapping(address => bool) feeWhitelist_;

    modifier onlyOwner () {
        require(owner == msg.sender);
        _;
    }

    modifier refundable () {
        uint256 _startGas = gasleft();

        _;

        uint256 gasPrice = tx.gasprice;
        if (gasPrice > maxRefundableGasPrice) gasPrice = maxRefundableGasPrice;
        
        uint256 _endGas = gasleft();
        uint256 _gasUsed = _startGas.sub(_endGas);
        uint256 weiRefund = _gasUsed.mul(gasPrice);
        if (address(this).balance >= weiRefund) msg.sender.transfer(weiRefund);
    }
    
     
    function CanYaCoin(address _feeRecipient) public {
        require(_feeRecipient != address(0x0));
        feeWhitelist_[address(this)] = true;
        owner = msg.sender;
        feeRecipient = _feeRecipient;
        balances_[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function() public payable onlyOwner { }  
    
     
    event Approval(address indexed owner, address indexed spender, uint value);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setOwner (address _newOwner) public onlyOwner {
        require(_newOwner != address(0x0));
        owner = _newOwner;
    }

    function setFeePercentTenths (uint256 _feePercent) public onlyOwner {
        transferFeePercentTenths = _feePercent;
    }

    function setFeeRecipient (address _feeRecipient) public onlyOwner {
        feeRecipient = _feeRecipient;
    }

    function setMaxRefundableGasPrice (uint256 _newMax) public onlyOwner {
        maxRefundableGasPrice = _newMax;
    }

    function exemptFromFees (address _exempt) public onlyOwner {
        feeWhitelist_[_exempt] = true;
    }

    function revokeFeeExemption (address _notExempt) public onlyOwner {
        feeWhitelist_[_notExempt] = false;
    }

     
    function balanceOf(address owner) public constant returns (uint) {
        return balances_[owner];
    }

     
    function approve(address spender, uint256 value) public returns (bool success) {
        allowances_[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
     
    function safeApprove(address _spender, uint256 _currentValue, uint256 _value) public returns (bool success) {
         
         
        if (allowances_[msg.sender][_spender] == _currentValue) {
            return approve(_spender, _value);
        }
        return false;
    }

     
    function allowance(address owner, address spender) public constant returns (uint256 remaining) {
        return allowances_[owner][spender];
    }

     
    function transfer(address to, uint256 value) public returns (bool success) {
        bytes memory empty;  
        _transfer(msg.sender, to, value, empty);
        return true;
    }

     
    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(value <= allowances_[from][msg.sender]);
        allowances_[from][msg.sender] -= value;
        bytes memory empty;
        _transfer(from, to, value, empty);
        return true;
    }

     
    function transfer(address to, uint value, bytes data, string custom_fallback) public returns (bool success)
    {
        _transfer( msg.sender, to, value, data );
        if (isContract(to)) {
            ContractReceiver rx = ContractReceiver( to );
            require(
                address(rx).call.value(0)(
                    bytes4(keccak256(custom_fallback)),
                    msg.sender,
                    value,
                    data
                )
            );
        }
        return true;
    }

     
    function transfer(address to, uint value, bytes data) public returns (bool success) {
        if (isContract(to)) {
            return transferToContract(to, value, data);
        }
        _transfer(msg.sender, to, value, data);
        return true;
    }

     
    function transferToContract(address to, uint value, bytes data) private returns (bool success) {
        _transfer(msg.sender, to, value, data);

        ContractReceiver rx = ContractReceiver(to);
        rx.tokenFallback(msg.sender, value, data);

        return true;
    }

     
    function isContract(address _addr) private constant returns (bool) {
        uint length;
        assembly { length := extcodesize(_addr) }
        return (length > 0);
    }

    event Gas(uint256 gasPrice, uint256 gasUsed, uint256 weiRefund);

    function _transfer(address from, address to, uint value, bytes data) internal refundable {
        require(to != 0x0);
        require(balances_[from] >= value);
        require(balances_[to].add(value) > balances_[to]);  

        uint256 _feeAmount = _getTransferFeeAmount(from, to, value);
 
        balances_[from] = balances_[from].sub(value);
        balances_[to] = balances_[to].add(value.sub(_feeAmount));

        balances_[address(this)] = balances_[address(this)].add(_feeAmount);

        emit Transfer(from, to, value);  
    }

    function _getTransferFeeAmount(address _from, address _to, uint256 _value) internal returns (uint256) {
        if (!feeWhitelist_[_from]) {
            return _value.div(transferFeePercentTenths.mul(10));
        }
        return 0;
    }

    function releaseFees () public {
        bytes memory empty;
        _transfer(address(this), feeRecipient, balances_[address(this)], empty);
    }
    
     
    event Burn(address indexed from, uint256 value);
    
     
    function burn(uint256 value) public returns (bool success) {
        require(balances_[msg.sender] >= value);
        balances_[msg.sender] -= value;
        totalSupply -= value;

        emit Burn(msg.sender, value);
        return true;
    }

     
    function burnFrom( address from, uint256 value ) public returns (bool success) {
        require(balances_[from] >= value);
        require(value <= allowances_[from][msg.sender]);

        balances_[from] -= value;
        allowances_[from][msg.sender] -= value;
        totalSupply -= value;

        emit Burn(from, value);
        return true;
    }
}


contract AssetSplit is Owned {
  using SafeMath for uint256;

  CanYaCoin public CanYaCoinToken;

  address public operationalAddress;
  address public daoAddress;
  address public charityAddress;

  uint256 public operationalSplitPercent = 30;
  uint256 public daoSplitPercent = 30;
  uint256 public charitySplitPercent = 10;
  uint256 public burnSplitPercent = 30;

  event OperationalSplit(uint256 _split);
  event RewardSplit(uint256 _split);
  event CharitySplit(uint256 _split);
  event BurnSplit(uint256 _split);

   
   
   
   
   
  function AssetSplit (
    address _tokenAddress,
    address _operational,
    address _reward,
    address _charity) public {
    require(_tokenAddress != 0);
    require(_operational != 0);
    require(_reward != 0);
    require(_charity != 0);
    CanYaCoinToken = CanYaCoin(_tokenAddress);
    operationalAddress = _operational;
    daoAddress = _reward;
    charityAddress = _charity;
  }

   
   
  function split (uint256 _amountToSplit) public only_owner {
    require(_amountToSplit != 0);
     
    require(CanYaCoinToken.allowance(owner, this) >= _amountToSplit);

     
    uint256 onePercentOfSplit = _amountToSplit / 100;
    uint256 operationalSplitAmount = onePercentOfSplit.mul(operationalSplitPercent);
    uint256 daoSplitAmount = onePercentOfSplit.mul(daoSplitPercent);
    uint256 charitySplitAmount = onePercentOfSplit.mul(charitySplitPercent);
    uint256 burnSplitAmount = onePercentOfSplit.mul(burnSplitPercent);

     
    require(
      operationalSplitAmount
        .add(daoSplitAmount)
        .add(charitySplitAmount)
        .add(burnSplitAmount)
      <= _amountToSplit
    );

     
    require(CanYaCoinToken.transferFrom(owner, operationalAddress, operationalSplitAmount));
    require(CanYaCoinToken.transferFrom(owner, daoAddress, daoSplitAmount));
    require(CanYaCoinToken.transferFrom(owner, charityAddress, charitySplitAmount));
    require(CanYaCoinToken.burnFrom(owner, burnSplitAmount));

    OperationalSplit(operationalSplitAmount);
    RewardSplit(daoSplitAmount);
    CharitySplit(charitySplitAmount);
    BurnSplit(burnSplitAmount);
  }

  function updateOperationalAddress (address _new) public only_owner {
    operationalAddress = _new;
  }

  function updateDaoAddress (address _new) public only_owner {
    daoAddress = _new;
  }

  function updateCharityAddress (address _new) public only_owner {
    charityAddress = _new;
  }

  function updateSplits (uint256 _ope, uint256 _dao, uint256 _cha, uint256 _bur) only_owner {
    require(_ope + _dao + _cha + _bur == 100);
    operationalSplitPercent = _ope;
    daoSplitPercent = _dao;
    charitySplitPercent = _cha;
    burnSplitPercent = _bur;
  }

}