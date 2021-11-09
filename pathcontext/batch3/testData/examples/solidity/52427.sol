pragma solidity ^0.4.24;

 
library SafeMath {

 
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        return a / b;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

     
contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
    constructor() public {
        owner = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Lockable is Ownable {
    uint256 public creationTime;
    bool public tokenTransferLocker;
    mapping(address => bool) lockaddress;

    event Locked(address lockaddress);
    event Unlocked(address lockaddress);
    event TokenTransferLocker(bool _setto);

     
    modifier isTokenTransfer {
         
        if(msg.sender != owner) {
             
            require(!tokenTransferLocker);
            if(lockaddress[msg.sender]){
                revert();
            }
        }
        _;
    }

     
     
     
    modifier checkLock {
        if (lockaddress[msg.sender]) {
            revert();
        }
        _;
    }

    constructor() public {
        creationTime = now;
        owner = msg.sender;
    }


    function isTokenTransferLocked()
    external
    view
    returns (bool)
    {
        return tokenTransferLocker;
    }

    function enableTokenTransfer()
    external
    onlyOwner
    {
        delete tokenTransferLocker;
        emit TokenTransferLocker(false);
    }

    function disableTokenTransfer()
    external
    onlyOwner
    {
        tokenTransferLocker = true;
        emit TokenTransferLocker(true);
    }
}


contract ERC20 {
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    uint256 totalSupply_;
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) view external returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract CoolPandaToken is ERC20, Lockable  {
    using SafeMath for uint256;

    uint256 public decimals = 18;
    address public fundWallet = 0x5A0DA1fD7f6b084A81F07fb9d641D295b2E7e669;
    uint256 public tokenPrice;

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address _addr) external view returns (uint256) {
        return balances[_addr];
    }

    function allowance(address _from, address _spender) external view returns (uint256) {
        return allowed[_from][_spender];
    }

    function transfer(address _to, uint256 _value)
    isTokenTransfer
    public
    returns (bool success) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value)
    isTokenTransfer
    external
    returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
    isTokenTransfer
    public
    returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        isTokenTransfer
        external
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function setFundWallet(address _newAddr) external onlyOwner {
        require(_newAddr != address(0));
        fundWallet = _newAddr;
    }

    function transferEth() onlyOwner external {
        fundWallet.transfer(address(this).balance);
    }

    function setTokenPrice(uint256 _newBuyPrice) external onlyOwner {
        tokenPrice = _newBuyPrice;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract PaoToken is CoolPandaToken {
    using SafeMath for uint256;

    string public name = "PAO Token";
    uint256 totalSupply_ = 10000000000 * 10 ** uint256(decimals);
    uint256 public tokenPrice = 5000;
    string public symbol = "PAO";
    uint fundRatio = 6;
    uint256 public minBuyAmount = 10000;

    mapping (uint256 => uint256) internal _levelPAO;
    mapping (uint256 => uint256) internal _levelBonusJPYC;

    JPYC public jpyc;                        
    uint256 public jypcBonus = 5000;       

    event JypcBonus(uint256 paoAmount, uint256 jpycAmount);

     
    constructor() public {
        balances[fundWallet] = totalSupply_ * fundRatio / 10;
        balances[address(this)] = totalSupply_.sub(balances[fundWallet]);

        _levelBonusJPYC[1] = 11000;
        _levelBonusJPYC[2] = 52000;
        _levelBonusJPYC[3] = 230000;    
        _levelBonusJPYC[4] = 1400000;
        _levelPAO[1] = 100;
        _levelPAO[2] = 200;
        _levelPAO[3] = 300;
        _levelPAO[4] = 400;
    }

     
    function () payable public {
        if(fundWallet != msg.sender){
            uint256 amount = msg.value.mul(tokenPrice);                      
            require (amount >= (minBuyAmount * 10 ** uint256(decimals)));    
            _buyToken(msg.sender, amount);                                   
            address(this).transfer(msg.value);                               
        }
    }

    function _buyToken(address _to, uint256 _value) isTokenTransfer internal {
        address _from = address(this);
        require (_to != 0x0);                                                    
        require (balances[_from] >= _value);                                     
        require (balances[_to].add(_value) >= balances[_to]);                    
        balances[_from] = balances[_from].sub(_value);                           
        balances[_to] = balances[_to].add(_value);                               
        emit Transfer(_from, _to, _value);

         
         
        uint256 _jpycAmount = _getJYPCBonus();
        jpyc.giveBonus(_to, _jpycAmount);

        emit JypcBonus(_value,_jpycAmount);
    }

    function _getJYPCBonus() internal view returns (uint256 amount){
        return msg.value.mul(jypcBonus); 
        
         
         
         
         
         
         
         
         
         
         
         
    }  

    function setMinBuyAmount(uint256 _amount) external onlyOwner{
        minBuyAmount = _amount;
    }

    function setLevelPAO(uint256 _lv1,uint256 _lv2,uint256 _lv3,uint256 _lv4) external onlyOwner{
        _levelPAO[1] = _lv1;
        _levelPAO[2] = _lv2;
        _levelPAO[3] = _lv3;
        _levelPAO[4] = _lv4;
    }

    function setLevelBonusJPYC(uint256 _lv1,uint256 _lv2,uint256 _lv3,uint256 _lv4) external onlyOwner{
        _levelBonusJPYC[1] = _lv1;
        _levelBonusJPYC[2] = _lv2;
        _levelBonusJPYC[3] = _lv3;
        _levelBonusJPYC[4] = _lv4;
    }

    function transferToken() onlyOwner external {
         transfer(fundWallet,balances[address(this)]);
    }

    function setJpycContactAddress(address _tokenAddress) external onlyOwner {
        jpyc = JPYC(_tokenAddress);
    }
}

contract JPYC is CoolPandaToken {
    using SafeMath for uint256;

    string public name = "Japan Yen Coin";
    uint256 _initialSupply = 10000000000 * 10 ** uint256(decimals);
    uint256 totalSupply_;
    uint256 public tokenPrice = 47000;            
    string public symbol = "JPYC";
    address public paoContactAddress;

    event Issue(uint256 amount);

     
    constructor() public {
        totalSupply_ = _initialSupply;
        balances[fundWallet] = _initialSupply;
    }

    function () payable public {
        uint amount = msg.value.mul(tokenPrice);              
        _giveToken(msg.sender, amount);                           
        fundWallet.transfer(msg.value);                          
    }

    function _giveToken(address _to, uint256 _value) isTokenTransfer internal {
        require (_to != 0x0);                                        
        require(totalSupply_.add(_value) >= totalSupply_);
        require (balances[_to].add(_value) >= balances[_to]);        

        totalSupply_ = totalSupply_.add(_value);
        balances[_to] = balances[_to].add(_value);                   
        emit Transfer(address(this), _to, _value);
    }

    function issue(uint256 amount) external onlyOwner {
        _giveToken(fundWallet, amount);

        emit Issue(amount);
    }

    function setPaoContactAddress(address _newAddr) external onlyOwner {
        require(_newAddr != address(0));
        paoContactAddress = _newAddr;
    }

    function giveBonus(address _to, uint256 _value)
    isTokenTransfer
    external
    returns (bool success) {
        require(_to != address(0));
        if(msg.sender == paoContactAddress){
            _giveToken(_to,_value);
            return true;
        }
        return false;
    }
}