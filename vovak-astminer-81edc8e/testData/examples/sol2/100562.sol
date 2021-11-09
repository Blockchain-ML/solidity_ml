pragma solidity 0.5.0;

 


 
 

 
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



 
 

 
 

 
contract Context {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}


 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


 
 

 
 

 
contract TokenPool is Ownable {
    IERC20 public token;

    constructor(IERC20 _token) public {
        token = _token;
    }

    function balance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function transfer(address to, uint256 value)
        external
        onlyOwner
        returns (bool)
    {
        return token.transfer(to, value);
    }
}

 
contract MidasDistributor is Ownable {
    using SafeMath for uint256;

    event TokensLocked(uint256 amount, uint256 total);
    event TokensDistributed(uint256 amount, uint256 total);

     
    IERC20 public token;

     
    uint256 public lastDistributionTimestamp;

     
    bool public distributing = false;

     
    uint256 public constant DECIMALS_EXP = 10**12;

     
    uint256 public constant PER_SECOND_INTEREST 
        = (DECIMALS_EXP * 5) / (1000 * 1 days);

     
    struct MidasAgent {
        
         
        address agent;

         
        uint8 share;
    }
    MidasAgent[] public agents;

     
    constructor(IERC20 _distributionToken) public {
        token = _distributionToken;
        lastDistributionTimestamp = block.timestamp;
    }

     
    function setDistributionState(bool _distributing) external onlyOwner {
         
        if (_distributing == true) {
            require(checkAgentPercentage() == true);
        }

        distributing = _distributing;
    }

     
    function addAgent(address _agent, uint8 _share) external onlyOwner {
        require(_share <= uint8(100));
        distributing = false;
        agents.push(MidasAgent({agent: _agent, share: _share}));
    }

     
    function removeAgent(uint256 _index) external onlyOwner {
        require(_index < agents.length, "index out of bounds");
        distributing = false;
        if (_index < agents.length - 1) {
            agents[_index] = agents[agents.length - 1];
        }
        agents.length--;
    }

     
    function setAgentShare(uint256 _index, uint8 _share) external onlyOwner {
        require(
            _index < agents.length,
            "index must be in range of stored tx list"
        );
        require(_share <= uint8(100));
        distributing = false;
        agents[_index].share = _share;
    }

     
    function agentsSize() public view returns (uint256) {
        return agents.length;
    }

     
    function checkAgentPercentage() public view returns (bool) {
        uint256 sum = 0;
        for (uint256 i = 0; i < agents.length; i++) {
            sum += agents[i].share;
        }
        return (uint256(100) == sum);
    }

     
    function balance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getElapsedTime() public view returns(uint256) {
         
        require(block.timestamp >= lastDistributionTimestamp);
        return (block.timestamp - lastDistributionTimestamp);
    }

     
    function getDistributionAmount() public view returns (uint256) {
        return
            balance()
            .mul(getElapsedTime())
            .mul(PER_SECOND_INTEREST)
            .div(DECIMALS_EXP);
    }

     
    function getAgentDistributionAmount(uint256 index)
        public
        view
        returns (uint256)
    {
        require(checkAgentPercentage() == true);
        require(index < agents.length);

        return
            getDistributionAmount()
            .mul(agents[index].share)
            .div(100);
    }

     
    function distribute() external {
        require(distributing == true);
        require(checkAgentPercentage() == true);
        require(getDistributionAmount() > 0);

        for (uint256 i = 0; i < agents.length; i++) {
            uint256 amount = getAgentDistributionAmount(i);
            if (amount > 0) {
                require(token.transfer(agents[i].agent, amount));
            }
        }
        lastDistributionTimestamp = block.timestamp;
    }

     
    function returnBalance2Owner() external onlyOwner returns (bool) {
        uint256 value = balance();
        if (value == 0) {
            return true;
        }
        return token.transfer(owner(), value);
    }
}