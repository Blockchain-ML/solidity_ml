 
pragma solidity >=0.4.21 <0.7.0;

library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract ReentrancyGuard {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }
}


contract BitcashPay is ReentrancyGuard{

    using SafeMath for uint256;

    string public constant name          =           'BitcashPay';
    string public constant symbol        =           'BCP';
    uint public totalSupply;
    uint8 public constant decimals       =           8;
    address payable owner;
    uint public buyPriceEth              =           100 szabo;
    uint public sellPriceEth             =           100 szabo;
    uint private constant MULTIPLIER     =           100000000;

    bool public directSellAllowed       =           false;
    bool public directBuyAllowed        =           false;

    bool public directTransferAllowed   =           false;

    uint public reservedCoin            =           175000000;
    address payable PresaleAddress;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowed;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    uint private releaseTime = 1627776000;
    
    constructor() ReentrancyGuard() public {
        uint _totalSupply = 850000000;
        owner = msg.sender;
        balanceOf[msg.sender] = _totalSupply.mul(MULTIPLIER);
        totalSupply = _totalSupply.mul(MULTIPLIER);
    }

    modifier ownerOnly {
        if (msg.sender != owner && msg.sender != address(this)) revert("Access Denied!");
        _;
    }

    function burnToken(address account, uint256 amount) ownerOnly public returns (bool success) {
        require(account != address(0), "ERC20: burn from the zero address");

        balanceOf[account] = balanceOf[account].sub(amount.mul(MULTIPLIER), "ERC20: burn amount exceeds balance");
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
        return true;
    }

    function transferEther(address payable _to, uint _amount) public ownerOnly returns (bool success)
    {
        uint amount = _amount * 10 ** 18;
        _to.transfer(amount.div(1000));
        return true;
    }

    function setBuyPrice(uint buyPrice) public ownerOnly {
        buyPriceEth = buyPrice;
    }

    function setSellPrice(uint sellPrice) public ownerOnly {
        sellPriceEth = sellPrice;
    }

    function allowDirectBuy() private {
        directBuyAllowed = true;
    }

    function allowDirectSell() private {
        directSellAllowed = true;
    }

    function allowDirectTransfer() private {
        directTransferAllowed = true;
    }

    function denyDirectBuy() private {
        directBuyAllowed = false;
    }

    function denyDirectSell() private {
        directSellAllowed = false;
    }

    function denyDirectTransfer() private {
        directTransferAllowed = false;
    }

    function ownerAllowDirectBuy() public ownerOnly {
        allowDirectBuy();
    }

    function ownerAllowDirectSell() public ownerOnly {
        allowDirectSell();
    }

    function ownerAllowDirectTransfer() public ownerOnly {
        allowDirectTransfer();
    }

    function ownerDenyDirectBuy() public ownerOnly {
        denyDirectBuy();
    }

    function ownerDenyDirectSell() public ownerOnly {
        denyDirectSell();
    }

    function ownerDenyDirectTransfer() public ownerOnly {
        denyDirectTransfer();
    }


    function setPresaleAddress(address payable _presaleAddress) public ownerOnly {
        PresaleAddress = _presaleAddress;
    }


    function transfer(address _to, uint _amount) public nonReentrant returns (bool success){
        if (msg.sender != owner && _to == address(this) && directSellAllowed) {
            sellBitcashPayAgainstEther(_amount);                             
            return true;
        }
        _transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balanceOf[_from] >= _value && allowed[_from][msg.sender] >= _value && balanceOf[_to] + _value > balanceOf[_to]) {
            balanceOf[_from] -= _value;
            balanceOf[_to] += _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(directTransferAllowed || releaseTime <= block.timestamp, "Direct Transfer is now allowed this time.");
        require(balanceOf[sender] > amount, "Insufficient Balance");
        if(msg.sender == address(this)) {
            require(releaseTime <= block.timestamp, "Reserved token is still locked");
        }

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        balanceOf[sender] = balanceOf[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function sellBitcashPayAgainstEther(uint amount) private nonReentrant returns (uint refund_amount) {
        allowDirectTransfer();
        refund_amount = (amount.div(MULTIPLIER)).mul(sellPriceEth);

        require(sellPriceEth != 0, "Sell price cannot be zero");
        require(amount.div(MULTIPLIER) >= 100, "Minimum of 100 BCP is required.");
        require(address(this).balance > refund_amount, "Contract Insuficient Balance");
        
        msg.sender.transfer(refund_amount);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount, "ERC20: transfer amount exceeds balance");
        balanceOf[owner] = balanceOf[owner].add(amount);

        emit Transfer(address(this), msg.sender, amount);
        denyDirectTransfer();
        return refund_amount;
    }

    event Bonus (address to, uint value);

    function getBonus(address _to, uint256 _value) public nonReentrant returns (uint bonus) {
        require(msg.sender == PresaleAddress, "Access Denied!");
        balanceOf[owner] = balanceOf[owner].sub(_value, "ERC20: transfer amount exceeds balance");
        balanceOf[_to] = balanceOf[_to].add(_value);
        
        emit Bonus(_to, _value.div(MULTIPLIER));
        return bonus;
    }

    function airDropper(address[] memory _to, uint[] memory _value) public nonReentrant ownerOnly returns (uint) {
        uint i = 0;
        while (i < _to.length) {
            balanceOf[owner] = balanceOf[owner].sub(_value[i].mul(MULTIPLIER), "ERC20: transfer amount exceeds balance");
            balanceOf[_to[i]] = balanceOf[_to[i]].add(_value[i].mul(MULTIPLIER));
            i += 1;
        }
        return i;
    }

    event Sold(address _from, address _to, uint _amount);

    function buyBitcashPayAgainstEther(address payable _sender, uint256 _amount) public nonReentrant returns (uint amount_sold) {
        allowDirectTransfer();
        if(balanceOf[_sender] == 0) {
            balanceOf[_sender] = balanceOf[_sender].add(MULTIPLIER);
            balanceOf[_sender] = balanceOf[_sender].sub(MULTIPLIER);
        }
        amount_sold = _amount.div(buyPriceEth);
        amount_sold = amount_sold.mul(MULTIPLIER);

        _transfer(owner, _sender, amount_sold);

        emit Sold(owner, _sender, amount_sold);
        denyDirectTransfer();
        return amount_sold;
    }

    event Received(address _from, uint _amount);

    receive() external payable {
        require(directBuyAllowed, "Direct buy to the contract is not available");
        if (msg.sender != owner) {
            buyBitcashPayAgainstEther(msg.sender, msg.value);
        }
        emit Received(msg.sender, msg.value);
    }



}