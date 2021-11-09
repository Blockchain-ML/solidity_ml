 
pragma solidity ^0.6.0;

 
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

 
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 
interface ApproveAndCallFallback { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) external;
    function tokenCallback(address _from, uint256 _tokens, bytes memory _data) external;
} 




 
contract DefiBids is Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public BURN_RATE = 0;
    uint256 constant STACKING_POOL_RATE = 10;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	
	bool public isStackingActive = false;
	address payable public stackingPoolAddress;
    
     
    uint256 private _releaseTime;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor (address _tokenHolder, address _presaleContract) public{
        _name = "DeFi Bids";
        _symbol = "BIDS";
        _decimals = 18;
        _releaseTime = 1630713600;
        _mint(_tokenHolder, 24300000 * 10**uint256(_decimals));
        _mint(_presaleContract, 20700000 * 10**uint256(_decimals));
        _mint(address(this), 5000000 * 10**uint256(_decimals));
    }
    
     
    function name() public view returns (string memory) {
        return _name;
    }
    
     
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
     
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
     
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
     
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
     
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }
    
     
    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
     
    function burnMyBIDS(uint256 amount) public virtual returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }
    
     
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }
    
     
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
     
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
     
    function _transfer(address sender, address recipient, uint256 amount) internal virtual returns(uint256) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

        uint256 remainingAmount = amount;
        if(BURN_RATE > 0){
            uint256 burnAmount = amount.mul(BURN_RATE).div(PERCENTS_DIVIDER);
            _burn(sender, burnAmount);
            remainingAmount = remainingAmount.sub(burnAmount);

        }
        
        if(isStackingActive){
            uint256 amountToStackPool = amount.mul(STACKING_POOL_RATE).div(PERCENTS_DIVIDER);
            remainingAmount = remainingAmount.sub(amountToStackPool);
            _balances[msg.sender] = _balances[msg.sender].sub(amountToStackPool, "ERC20: transfer amount exceeds balance");
            _balances[stackingPoolAddress] = _balances[stackingPoolAddress].add(amountToStackPool);
            emit Transfer(msg.sender, stackingPoolAddress, amountToStackPool);

        }

        _balances[sender] = _balances[sender].sub(remainingAmount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(remainingAmount);
        emit Transfer(sender, recipient, remainingAmount);
        return remainingAmount;
    }
    
     
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    
     
    function releaseLokedBIDS() public virtual onlyOwner returns(bool){
        require(block.timestamp >= _releaseTime, "TokenTimelock: current time is before release time");

        uint256 amount = _balances[address(this)];
        require(amount > 0, "TokenTimelock: no tokens to release");

        _transfer(address(this), msg.sender, amount);
        
        return true;
    }
    
     
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)  public returns (bool success) {
	    if (approve(_spender, _value)) {
	    	ApproveAndCallFallback(_spender).receiveApproval(msg.sender, _value, address(this), _extraData);
	    	return true;
	    }
    }
    
      
    function transferAndCall(address _to, uint256 _tokens, bytes calldata _data) external returns (bool) {
		uint256 _transferred = _transfer(msg.sender, _to, _tokens);
		ApproveAndCallFallback(_to).tokenCallback(msg.sender, _transferred, _data);
		return true;
	}
    
     
    function bulkTransfer(address[] calldata _receivers, uint256[] calldata _amounts) external {
		require(_receivers.length == _amounts.length);
		for (uint256 i = 0; i < _receivers.length; i++) {
			_transfer(msg.sender, _receivers[i], _amounts[i]);
		}
	}
    
     
    function setStackingPoolContract(address payable _a) public onlyOwner returns (bool) { 
        stackingPoolAddress = _a;
        return true;
    }
    
     
    function changeStackingStatus() public virtual onlyOwner returns (bool currentStackingStatus) { 
        if(isStackingActive){
            isStackingActive = false;
        } else {
            isStackingActive = true;
        }
        return isStackingActive;
    }
    
     
    function chnageTransferBurnRate(uint256 burnRatio_) public onlyOwner returns (bool) { 
        BURN_RATE = burnRatio_;
        return true;
    }

}