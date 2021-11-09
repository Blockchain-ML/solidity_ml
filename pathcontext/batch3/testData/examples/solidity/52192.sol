pragma solidity ^0.4.18;

 
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

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract PaoToken is Lockable {
    using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    string public name = "PAO Token";
    uint8 public decimals = 0;
    uint256 totalSupply_ = 10000000000 * 10 ** uint256(decimals);
    uint256 public tokenBuyPrice = 5000;
    string public symbol = "PAO";
    address public publicSaleWallet = 0x5A0DA1fD7f6b084A81F07fb9d641D295b2E7e669;
    address public reservedWallet = 0x8a7fe9893c63f718Ad066a1dd48458eC47F2FbaD;
    uint publicSaleRatio = 3;
    uint reservedRatio = 7;

    address public consumeAddress;
    ConsumeToken public consumeToken;   

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

     
    constructor() public {
        balances[reservedWallet] = totalSupply_ * reservedRatio / 10;
        balances[publicSaleWallet] = totalSupply_ * publicSaleRatio / 10;
    }

    function totalSupply() external view returns (uint256) {
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
    external
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

    function _buyToken(address _to, uint _value) internal {
        require (_to != 0x0);                                                    
        require (balances[publicSaleWallet] >= _value);                          
        require (balances[_to].add(_value) >= balances[_to]);                    
        balances[publicSaleWallet] = balances[publicSaleWallet].sub(_value);     
        balances[_to] = balances[_to].add(_value);                               

         
        consumeToken.giveBonus(_to, 1000);

        emit Transfer(publicSaleWallet, _to, _value);
    }

     
    function () payable public {
        uint amount = msg.value.mul(tokenBuyPrice);              
        _buyToken(msg.sender, amount);                           
        publicSaleWallet.transfer(msg.value);                    
    }

    function setBuyPrices(uint256 _newBuyPrice) external onlyOwner{
        tokenBuyPrice = _newBuyPrice;
    }

    function transferSaleWallet(address _newAddr) external onlyOwner {
        require(_newAddr != address(0));
        publicSaleWallet = _newAddr;
    }

    function transferEth() onlyOwner external {
        publicSaleWallet.transfer(address(this).balance);
    }

    function setConsumeTokenAddress(address _tokenAddress) public {
        consumeAddress = _tokenAddress;
        consumeToken = ConsumeToken(_tokenAddress);
    }

}

contract ConsumeToken is Lockable {
    using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    string public name = "Consume Token";
    uint8 public decimals = 2;
    uint256 totalSupply_ = 10000000000 * 10 ** uint256(decimals);
    uint256 public tokenBuyPrice = 54106;            
    string public symbol = "Con";
    address public fundWallet = 0x5A0DA1fD7f6b084A81F07fb9d641D295b2E7e669;
    address public paoContactAddress;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

     
    constructor() public {
        balances[fundWallet] = totalSupply_;
    }

    function totalSupply() external view returns (uint256) {
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
    external
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

    function _buyToken(address _to, uint _value) internal {
        require (_to != 0x0);                                        
        require (balances[fundWallet] >= _value);                    
        require (balances[_to].add(_value) >= balances[_to]);        
        balances[fundWallet] = balances[fundWallet].sub(_value);     
        balances[_to] = balances[_to].add(_value);                   
        emit Transfer(fundWallet, _to, _value);
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

     
    function () payable public {
        uint amount = msg.value.mul(tokenBuyPrice);              
        _buyToken(msg.sender, amount);                           
        fundWallet.transfer(msg.value);                    
    }

    function setPrices(uint256 newBuyPrice) onlyOwner public {
        tokenBuyPrice = newBuyPrice;
    }

    function transferFundWalletWallet(address newAddr) external onlyOwner {
        require(newAddr != address(0));
        fundWallet = newAddr;
    }

    function transferEth() onlyOwner external {
        fundWallet.transfer(address(this).balance);
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
            require(_value <= balances[fundWallet]);

            balances[fundWallet] = balances[fundWallet].sub(_value);
            balances[_to] = balances[_to].add(_value);
            emit Transfer(fundWallet, _to, _value);
            return true;
        }
        return false;
    }
}