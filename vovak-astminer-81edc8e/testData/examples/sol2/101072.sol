pragma solidity ^0.6.5;


 
 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}


 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
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

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
             
            if (returndata.length > 0) {
                 

                 
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

contract RoniToken is ERC20  {
    using SafeMath for uint256;
   
    address public owner;   
    
    uint public stakeholdersIndexFor3Months = 0;
    uint public stakeholdersIndexFor6Months = 0;
    uint public stakeholdersIndexFor12Months = 0;
    uint public totalStakes = 0;
    uint public stakingPool = 0;
    uint public totalStakesFor3Months = 0;
    uint public totalStakesFor6Months = 0;
    uint public totalStakesFor12Months = 0;
   
    struct Stakeholder {
         bool staker;
         uint id;
    }
    
    struct UserInfo {
        uint id;
        uint[] stake;
        uint[] lockUpTime;
    }
    
    mapping (address => Stakeholder) public stakeholdersFor3Months;
    
    mapping (uint => address) public stakeholdersReverseMappingFor3Months;
    
    mapping(address => UserInfo) public stakesFor3Months;
    
    mapping (address => Stakeholder) public stakeholdersFor6Months;
    
    mapping (uint => address) public stakeholdersReverseMappingFor6Months;
    
    mapping(address => UserInfo) public stakesFor6Months;
    
    mapping (address => Stakeholder) public stakeholdersFor12Months;
    
    mapping (uint => address) public stakeholdersReverseMappingFor12Months;
    
    mapping(address => UserInfo) public stakesFor12Months;
    
    mapping (address => address) public admins;
    
    constructor(address _owner, uint256 _supply) public ERC20("Pepperoni", "Roni") {
        owner = _owner;
        uint supply = _supply.mul(1e18);
        _mint(_owner, supply); 
        admins[owner] = owner;
        admins[0x0E8eB83e976AEa321Cab0d60B54Bc6Ba1c5E26ab] = 0x0E8eB83e976AEa321Cab0d60B54Bc6Ba1c5E26ab;
    }
    
    function stakeAndLockUpTimeDetailsFor3Months(uint id) view external returns(uint,uint){
      return (stakesFor3Months[msg.sender].stake[id],stakesFor3Months[msg.sender].lockUpTime[id]);
    }
    
    function stakeFor3Months(uint _stake) external {
        if(stakeholdersFor3Months[msg.sender].staker == false){
            addStakeholderFor3Months(msg.sender);
        }
        
        uint availableTostake = calculateStakingCost(_stake);
        stakesFor3Months[msg.sender].stake.push(availableTostake);
        stakesFor3Months[msg.sender].lockUpTime.push(now+90 days);
        stakesFor3Months[msg.sender].id = stakesFor3Months[msg.sender].stake.length-1;
        stakingPool = stakingPool.add(_stake);
        totalStakes = totalStakes.add(availableTostake);
        totalStakesFor3Months = totalStakesFor3Months.add(availableTostake);
        _burn(msg.sender, _stake);
    } 
    
    function withdrawStakeAfter3months(uint _stake, uint id) external {
        require(stakesFor3Months[msg.sender].stake[id] > 0, 'must have stake');
        require(stakesFor3Months[msg.sender].stake[id] >= _stake, 'not enough stake');
        
        if(stakesFor3Months[msg.sender].lockUpTime[id] <= now){
          stakesFor3Months[msg.sender].stake[id] = stakesFor3Months[msg.sender].stake[id].sub(_stake);
          uint reward = _stake.mul(25).div(100);
          uint sum = _stake.add(reward);
          require(stakingPool> sum,'no enough funds in pool');
          stakingPool = stakingPool.sub(sum);
          totalStakes = totalStakes.sub(_stake);
          totalStakesFor3Months = totalStakesFor3Months.sub(_stake);
          _mint(msg.sender, sum);
        }
        else{
            uint stakeToReceive = calculateUnstakingCost(_stake);
            require(stakingPool> stakeToReceive,'no enough funds in pool');
            stakingPool = stakingPool.sub(stakeToReceive);
            totalStakes = totalStakes.sub(_stake);
            stakesFor3Months[msg.sender].stake[id] = stakesFor3Months[msg.sender].stake[id].sub(_stake);
            totalStakesFor3Months = totalStakesFor3Months.sub(_stake);
            _mint(msg.sender, stakeToReceive);
        }
        
        if(stakeholdersFor3Months[msg.sender].staker == true){
            removeStakeholderFor3Months(msg.sender);
        }
    }
    
    function addStakeholderFor3Months(address _stakeholder) private {
       stakeholdersFor3Months[_stakeholder].staker = true;    
       stakeholdersFor3Months[_stakeholder].id = stakeholdersIndexFor3Months;
       stakeholdersReverseMappingFor3Months[stakeholdersIndexFor3Months] = _stakeholder;
       stakeholdersIndexFor3Months = stakeholdersIndexFor3Months.add(1);
    }
   
    function removeStakeholderFor3Months(address _stakeholder) private  {
        if(stakesFor3Months[msg.sender].stake[stakesFor3Months[msg.sender].id] == 0){
             
             
            uint swappableId = stakeholdersFor3Months[_stakeholder].id;
            
             
             
            address swappableAddress = stakeholdersReverseMappingFor3Months[stakeholdersIndexFor3Months -1];
            
             
            stakeholdersReverseMappingFor3Months[swappableId] = stakeholdersReverseMappingFor3Months[stakeholdersIndexFor3Months - 1];
            
             
            stakeholdersFor3Months[swappableAddress].id = swappableId;
            
             
            delete(stakeholdersFor3Months[_stakeholder]);
            delete(stakeholdersReverseMappingFor3Months[stakeholdersIndexFor3Months - 1]);
            stakeholdersIndexFor3Months = stakeholdersIndexFor3Months.sub(1);
        }
    }
    
    function stakeAndLockUpTimeDetailsFor6Months(uint id) view external returns(uint,uint){
      return (stakesFor6Months[msg.sender].stake[id],stakesFor6Months[msg.sender].lockUpTime[id]);
    }
    
    function stakeFor6Months(uint _stake) external {
        if(stakeholdersFor6Months[msg.sender].staker == false){
            addStakeholderFor6Months(msg.sender);
        }
        
        uint availableTostake = calculateStakingCost(_stake);
        stakesFor6Months[msg.sender].stake.push(availableTostake);
        stakesFor6Months[msg.sender].lockUpTime.push(now + 180 days);
        stakesFor6Months[msg.sender].id = stakesFor6Months[msg.sender].stake.length-1;
        stakingPool = stakingPool.add(_stake);
        totalStakes = totalStakes.add(availableTostake);
        totalStakesFor6Months = totalStakesFor6Months.add(availableTostake);
        _burn(msg.sender, _stake);
    } 
    
    function withdrawStakeAfter6months(uint _stake, uint id) external {
        require(stakesFor6Months[msg.sender].stake[id] > 0, 'must have stake');
        require(stakesFor6Months[msg.sender].stake[id] >= _stake, 'not enough stake');
        
        if(stakesFor6Months[msg.sender].lockUpTime[id] <= now){
          stakesFor6Months[msg.sender].stake[id] = stakesFor6Months[msg.sender].stake[id].sub(_stake);
          uint reward = _stake.mul(200).div(100);
          uint sum = _stake.add(reward);
          require(stakingPool> sum,'no enough funds in pool');
          stakingPool = stakingPool.sub(sum);
          totalStakes = totalStakes.sub(_stake);
          totalStakesFor6Months = totalStakesFor6Months.sub(_stake);
          _mint(msg.sender, sum);
        }
        else{
            uint stakeToReceive = calculateUnstakingCost(_stake);
            require(stakingPool> stakeToReceive,'no enough funds in pool');
            stakingPool = stakingPool.sub(stakeToReceive);
            totalStakes = totalStakes.sub(_stake);
            stakesFor6Months[msg.sender].stake[id] = stakesFor6Months[msg.sender].stake[id].sub(_stake);
            totalStakesFor6Months = totalStakesFor6Months.sub(_stake);
            _mint(msg.sender, stakeToReceive);
        }
        
        if(stakeholdersFor6Months[msg.sender].staker == true){
            removeStakeholderFor6Months(msg.sender);
        }
    }
    
    function addStakeholderFor6Months(address _stakeholder) private {
       stakeholdersFor6Months[_stakeholder].staker = true;    
       stakeholdersFor6Months[_stakeholder].id = stakeholdersIndexFor6Months;
       stakeholdersReverseMappingFor6Months[stakeholdersIndexFor6Months] = _stakeholder;
       stakeholdersIndexFor6Months = stakeholdersIndexFor6Months.add(1);
    }
   
    function removeStakeholderFor6Months(address _stakeholder) private  {
        if(stakesFor6Months[msg.sender].stake[stakesFor6Months[msg.sender].id] == 0){
             
            uint swappableId = stakeholdersFor6Months[_stakeholder].id;
            
             
             
            address swappableAddress = stakeholdersReverseMappingFor6Months[stakeholdersIndexFor6Months -1];
            
             
            stakeholdersReverseMappingFor6Months[swappableId] = stakeholdersReverseMappingFor6Months[stakeholdersIndexFor6Months - 1];
            
             
            stakeholdersFor6Months[swappableAddress].id = swappableId;
            
             
            delete(stakeholdersFor6Months[_stakeholder]);
            delete(stakeholdersReverseMappingFor6Months[stakeholdersIndexFor6Months - 1]);
            stakeholdersIndexFor6Months = stakeholdersIndexFor6Months.sub(1);
        }
    }
    
    function stakeAndLockUpTimeDetailsFor12Months(uint id) view external returns(uint,uint){
      return (stakesFor12Months[msg.sender].stake[id],stakesFor12Months[msg.sender].lockUpTime[id]);
    }
    
    function stakeFor12Months(uint _stake) external {
        if(stakeholdersFor12Months[msg.sender].staker == false){
            addStakeholderFor12Months(msg.sender);
        }
        
        uint availableTostake = calculateStakingCost(_stake);
        stakesFor12Months[msg.sender].stake.push(availableTostake);
        stakesFor12Months[msg.sender].lockUpTime.push(now + 360 days);
        stakesFor12Months[msg.sender].id = stakesFor12Months[msg.sender].stake.length-1;
        stakingPool = stakingPool.add(_stake);
        totalStakes = totalStakes.add(availableTostake);
        totalStakesFor12Months = totalStakesFor12Months.add(availableTostake);
        _burn(msg.sender, _stake);
    } 
    
    function withdrawStakeAfter12months(uint _stake, uint id) external {
        require(stakesFor12Months[msg.sender].stake[id] > 0, 'must have stake');
        require(stakesFor12Months[msg.sender].stake[id] >= _stake, 'not enough stake');
        
        if(stakesFor12Months[msg.sender].lockUpTime[id] <= now){
          stakesFor12Months[msg.sender].stake[id] = stakesFor12Months[msg.sender].stake[id].sub(_stake);
          uint reward = _stake.mul(500).div(100);
          uint sum = _stake.add(reward);
          require(stakingPool> sum,'no enough funds in pool');
          stakingPool = stakingPool.sub(sum);
          totalStakes = totalStakes.sub(_stake);
          totalStakesFor12Months = totalStakesFor12Months.sub(_stake);
          _mint(msg.sender, sum);
        }
        else{
            uint stakeToReceive = calculateUnstakingCost(_stake);
            require(stakingPool> stakeToReceive,'no enough funds in pool');
            stakingPool = stakingPool.sub(stakeToReceive);
            totalStakes = totalStakes.sub(_stake);
            stakesFor12Months[msg.sender].stake[id] = stakesFor12Months[msg.sender].stake[id].sub(_stake);
            totalStakesFor12Months = totalStakesFor12Months.sub(_stake);
            _mint(msg.sender, stakeToReceive);
        }
        
        if(stakeholdersFor12Months[msg.sender].staker == true){
            removeStakeholderFor12Months(msg.sender);
        }
    }
    
    function addStakeholderFor12Months(address _stakeholder) private {
       stakeholdersFor12Months[_stakeholder].staker = true;    
       stakeholdersFor12Months[_stakeholder].id = stakeholdersIndexFor12Months;
       stakeholdersReverseMappingFor12Months[stakeholdersIndexFor12Months] = _stakeholder;
       stakeholdersIndexFor12Months = stakeholdersIndexFor12Months.add(1);
    }
   
    function removeStakeholderFor12Months(address _stakeholder) private  {
        if(stakesFor12Months[msg.sender].stake[stakesFor12Months[msg.sender].id] == 0){
             
            uint swappableId = stakeholdersFor12Months[_stakeholder].id;
            
             
             
            address swappableAddress = stakeholdersReverseMappingFor12Months[stakeholdersIndexFor12Months -1];
            
             
            stakeholdersReverseMappingFor12Months[swappableId] = stakeholdersReverseMappingFor12Months[stakeholdersIndexFor12Months - 1];
            
             
            stakeholdersFor12Months[swappableAddress].id = swappableId;
            
             
            delete(stakeholdersFor12Months[_stakeholder]);
            delete(stakeholdersReverseMappingFor12Months[stakeholdersIndexFor12Months - 1]);
            stakeholdersIndexFor12Months = stakeholdersIndexFor12Months.sub(1);
        }
    }
    
    function transfer(address _to, uint256 _tokens) public override  returns (bool) {
       if(msg.sender == admins[msg.sender]){
              _transfer(msg.sender, _to, _tokens);  
          }
        else{
            uint toSend = transferFee(msg.sender, _tokens);
            _transfer(msg.sender, _to, toSend);
           }
        return true;
    }
    
    function bulkTransfer(address[] calldata _receivers, uint256[] calldata _tokens) external returns (bool) {
        require(_receivers.length == _tokens.length);
        
        uint toSend;
        for (uint256 i = 0; i < _receivers.length; i++) {
            if(msg.sender == admins[msg.sender]){
              _transfer(msg.sender, _receivers[i], _tokens[i].mul(1e18));  
            }
            else{
             toSend = transferFee(msg.sender, _tokens[i]);
            _transfer(msg.sender, _receivers[i], toSend);
            }
        }
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 _tokens) public override returns (bool)  {
        if(sender == admins[msg.sender]){
              _transfer(sender, recipient, _tokens);  
        }
        else{
           uint  toSend = transferFee(sender, _tokens);
           _transfer(sender, recipient, toSend);
        }
        _approve(sender, _msgSender(),allowance(sender,msg.sender).sub(_tokens, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function transferFee(address sender, uint _token) private returns(uint _transferred){
        uint transferFees =  _token.div(10);
        uint burn = transferFees.div(10);
        uint addToPool = transferFees.sub(burn);
        stakingPool = stakingPool.add(addToPool);
        _transferred = _token - transferFees;
        _burn(sender, transferFees);
    }
    
     
    function calculateStakingCost(uint256 _stake) private pure returns(uint) {
        uint stakingCost =  (_stake).mul(10);
        uint percent = stakingCost.div(100);
        uint availableForstake = _stake.sub(percent);
        return availableForstake;
    }
    
     
    function calculateUnstakingCost(uint _stake) private pure returns(uint ) {
        uint unstakingCost =  (_stake).mul(20);
        uint percent = unstakingCost.div(100);
        uint stakeReceived = _stake.sub(percent);
        return stakeReceived;
    }
}