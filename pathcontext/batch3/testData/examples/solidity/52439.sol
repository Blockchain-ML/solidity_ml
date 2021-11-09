pragma solidity 0.4.25;

 
 
 
 
 
 
 
 


 
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

 
contract Owned {
  modifier onlyOwner { require(msg.sender == owner); _; }
  address public owner = msg.sender;
  event NewOwner(address indexed old, address indexed current);
  function setOwner(address _new) onlyOwner public { emit NewOwner(owner, _new); owner = _new; }
}

 
contract CanYaCoin is Owned {

    using SafeMath for uint256;

     
    string public name;                                          
    string public symbol;                                        
    string public URI;                                           
    uint256 public decimals  = 18;                               
    uint256 public totalSupply  = 100000000 * (10 ** decimals);  

     
    bool public publicCanWhitelist = true;                       
    uint256 public maxRefundableGasPrice = 10000000000;          
    uint256 public transferFeePercentTenths = 10;                
    uint256 public transferFeeFlat = 0;                          
    address public feeRecipient;                                 
    address public owner;

     
    mapping(address => uint256) balances_;                       
    mapping(address => mapping(address => uint256)) allowances_; 
    mapping(address => bool) feeWhitelist_;                      
    
     
    event Approval(address indexed owner, address indexed spender, uint value);  
    event Transfer(address indexed from, address indexed to, uint256 value);     
    event Gas(uint256 gasPrice, uint256 gasUsed, uint256 weiRefund);             
    event Burn(address indexed from, uint256 value);                             
    
     
    constructor() public{
        feeWhitelist_[address(this)] = true;
        owner = msg.sender;
        balances_[msg.sender] = totalSupply;
        name = "testCanYaCoin";
        symbol  = "CAN223-1";
        emit Transfer(address(0), msg.sender, totalSupply);
    }

     
    function() public payable { } 

     
     
     
     
     
    modifier refundable () {
        uint256 _startGas = gasleft();
        _;
        if (feeWhitelist_[msg.sender]) return;
        uint256 gasPrice = tx.gasprice;
        if (gasPrice > maxRefundableGasPrice) gasPrice = maxRefundableGasPrice;
        uint256 _endGas = gasleft();
        uint256 _gasUsed = _startGas.sub(_endGas).add(31000);
        uint256 weiRefund = _gasUsed.mul(gasPrice);
        if (address(this).balance >= weiRefund) tx.origin.transfer(weiRefund);
    }
    
     
    function updateDetails (string _updatedName,
    string _updatedSymbol) public onlyOwner {
    name = _updatedName;
    symbol  = _updatedSymbol;
    }

     
    function getURI() public view returns (string) {
    return URI;
    }
    
     
    function updateURI (string _updatedURI) public onlyOwner {
    URI = _updatedURI;
    }

     
    function setFeePercentTenths (uint256 _feePercent) public onlyOwner {
        transferFeePercentTenths = _feePercent;
    }

     
    function setFeeFlat (uint256 _feeFlat) public onlyOwner {
        transferFeeFlat = _feeFlat;
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

     
    function setPublicWhitelistAbility (bool _canWhitelist) public onlyOwner {
        publicCanWhitelist = _canWhitelist;
    }

     
    function exemptMeFromFees () public {
        if (publicCanWhitelist) {
            feeWhitelist_[msg.sender] = true;
        }
    }

     
    function balanceOf(address tokenOwner) public constant returns (uint) {
        return balances_[tokenOwner];
    }

     
    function approve(address spender, uint256 value) public returns (bool success) {
        allowances_[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
     
    function approveMe(address spender) public returns (bool success) {
        uint256 value = balances_[msg.sender];
        allowances_[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
     
    function approveAll(address spender) public returns (bool success) {
        uint256 value = totalSupply;
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

     
    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining) {
        return allowances_[tokenOwner][spender];
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

     
    function _transfer(address from, address to, uint value, bytes data) internal refundable {
        require(to != 0x0);
        require(balances_[from] >= value);
        require(balances_[to].add(value) >= balances_[to]);                   

        uint256 _feeAmount = _getTransferFeeAmount(from, value);             
 
        balances_[from] = balances_[from].sub(value);                        
        balances_[to] = balances_[to].add(value.sub(_feeAmount));            

        balances_[feeRecipient] = balances_[feeRecipient].add(_feeAmount);   

        emit Transfer(from, to, value.sub(_feeAmount));                      
        
         
        if (!feeWhitelist_[from]) {
            if(_feeAmount > 0){
                emit Transfer(from, feeRecipient, _feeAmount);               
            }
        }
    }

     
    function _getTransferFeeAmount(address _from, uint256 _value) internal returns (uint256) {
        if (!feeWhitelist_[_from]) {
            if (transferFeePercentTenths > 0){
                return (_value.mul(transferFeePercentTenths)).div(1000) + transferFeeFlat;
            } else{
               return transferFeeFlat; 
            }
        }
        return 0;
    }
    
     
    function burn(uint256 value) public returns (bool success) {
        require(balances_[msg.sender] >= value);
        balances_[msg.sender] -= value;
        totalSupply -= value;
        emit Burn(msg.sender, value);
        return true;
    }

     
    function burnFrom(address from, uint256 value) public returns (bool success) {
        require(balances_[from] >= value);
        require(value <= allowances_[from][msg.sender]);
        balances_[from] -= value;
        allowances_[from][msg.sender] -= value;
        totalSupply -= value;
        emit Burn(from, value);
        return true;
    }
}