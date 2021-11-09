 

pragma solidity ^0.5.0;

 
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

interface IYFVIRewards {
    function stakingPower(address account) external view returns (uint256);
}

interface IYFVIGovernanceRewardScaler {
    function votingValueGovernance(address poolAddress, uint256 votingItem, uint16 votingValue) external view returns (uint16);
}

contract YFVIVote {
    using SafeMath for uint256;

    address public governance;

    uint8 public constant MAX_VOTERS_PER_ITEM = 200;

    uint16 public defaultVotingValueMin = 50;  
    uint16 public defaultVotingValueMax = 150;  

    mapping(address => mapping(uint256 => uint8)) public numVoters;  
    mapping(address => mapping(uint256 => address[MAX_VOTERS_PER_ITEM])) public voters;  
    mapping(address => mapping(uint256 => mapping(address => bool))) public isInTopVoters;  
    mapping(address => mapping(uint256 => mapping(address => uint16))) public voter2VotingValue;  

    mapping(address => mapping(uint256 => uint16)) public votingValueMinimums;  
    mapping(address => mapping(uint256 => uint16)) public votingValueMaximums;  

    address public governanceRewardScaler;

    event Voted(address poolAddress, address indexed user, uint256 votingItem, uint16 votingValue);

    constructor () public {
        governance = msg.sender;
    }

    function setDefaultVotingValueRange(uint16 minValue, uint16 maxValue) public {
        require(msg.sender == governance, "!governance");
        require(minValue < maxValue, "Invalid voting range");
        defaultVotingValueMin = minValue;
        defaultVotingValueMax = maxValue;
    }

    function setVotingValueRange(address poolAddress, uint256 votingItem, uint16 minValue, uint16 maxValue) public {
        require(msg.sender == governance, "!governance");
        require(minValue < maxValue, "Invalid voting range");
        votingValueMinimums[poolAddress][votingItem] = minValue;
        votingValueMaximums[poolAddress][votingItem] = maxValue;
    }

    function setGovernanceRewardsScaler(address _governanceRewardScaler) public {
        require(msg.sender == governance, "!governance");
        governanceRewardScaler = _governanceRewardScaler;
    }

    function isVotable(address poolAddress, address account, uint256 votingItem) public view returns (bool) {
         
        if (voter2VotingValue[poolAddress][votingItem][account] > 0) return false;

        IYFVIRewards rewards = IYFVIRewards(poolAddress);
         
        if (rewards.stakingPower(account) == 0) return false;

         
        if (numVoters[poolAddress][votingItem] < MAX_VOTERS_PER_ITEM) return true;
        for (uint8 i = 0; i < numVoters[poolAddress][votingItem]; i++) {
            if (rewards.stakingPower(voters[poolAddress][votingItem][i]) < rewards.stakingPower(account)) return true;
             
        }

        return false;
    }

    function averageVotingValueNoGovernance(address poolAddress, uint256 votingItem) public view returns (uint16) {
        if (numVoters[poolAddress][votingItem] == 0) return 0;  
        uint256 totalStakingPower = 0;
        uint256 totalWeightVotingValue = 0;
        IYFVIRewards rewards = IYFVIRewards(poolAddress);
        for (uint8 i = 0; i < numVoters[poolAddress][votingItem]; i++) {
            address voter = voters[poolAddress][votingItem][i];
            totalStakingPower = totalStakingPower.add(rewards.stakingPower(voter));
            totalWeightVotingValue = totalWeightVotingValue.add(rewards.stakingPower(voter).mul(voter2VotingValue[poolAddress][votingItem][voter]));
        }
        return (uint16) (totalWeightVotingValue.div(totalStakingPower));
    }

    function averageVotingValue(address poolAddress, uint256 votingItem) public view returns (uint16) {
        uint16 avgValue = 0;
        if (numVoters[poolAddress][votingItem] > 0) {
            avgValue = averageVotingValueNoGovernance(poolAddress, votingItem);
        }
        if (governanceRewardScaler != address(0)) {
            return IYFVIGovernanceRewardScaler(governanceRewardScaler).votingValueGovernance(poolAddress, votingItem, avgValue);
        }
        return avgValue;
    }

    function vote(address poolAddress, uint256 votingItem, uint16 votingValue) public {
        if (votingValueMinimums[poolAddress][votingItem] > 0 && votingValueMaximums[poolAddress][votingItem] > 0) {
            require(votingValue >= votingValueMinimums[poolAddress][votingItem], "votingValue is smaller than minimum accepted value");
            require(votingValue <= votingValueMaximums[poolAddress][votingItem], "votingValue is greater than maximum accepted value");
        } else {
            require(votingValue >= defaultVotingValueMin, "votingValue is smaller than defaultVotingValueMin");
            require(votingValue <= defaultVotingValueMax, "votingValue is greater than defaultVotingValueMax");
        }
        if (!isInTopVoters[poolAddress][votingItem][msg.sender]) {
            require(isVotable(poolAddress, msg.sender, votingItem), "This account is not votable");
            uint8 voterIndex = MAX_VOTERS_PER_ITEM;
            if (numVoters[poolAddress][votingItem] < MAX_VOTERS_PER_ITEM) {
                voterIndex = numVoters[poolAddress][votingItem];
            } else {
                IYFVIRewards rewards = IYFVIRewards(poolAddress);
                uint256 minStakingPower = rewards.stakingPower(msg.sender);
                for (uint8 i = 0; i < numVoters[poolAddress][votingItem]; i++) {
                    if (rewards.stakingPower(voters[poolAddress][votingItem][i]) < minStakingPower) {
                        voterIndex = i;
                        minStakingPower = rewards.stakingPower(voters[poolAddress][votingItem][i]);
                    }
                }
            }
            if (voterIndex < MAX_VOTERS_PER_ITEM) {
                if (voterIndex < numVoters[poolAddress][votingItem]) {
                     
                    isInTopVoters[poolAddress][votingItem][voters[poolAddress][votingItem][voterIndex]] = false;
                } else {
                    ++numVoters[poolAddress][votingItem];
                }
                isInTopVoters[poolAddress][votingItem][msg.sender] = true;
                voters[poolAddress][votingItem][voterIndex] = msg.sender;
            }
        }
        voter2VotingValue[poolAddress][votingItem][msg.sender] = votingValue;
        emit Voted(poolAddress, msg.sender, votingItem, votingValue);
    }

    event EmergencyERC20Drain(address token, address governance, uint256 amount);

     
    function emergencyERC20Drain(ERC20 token, uint amount) external {
        require(msg.sender == governance, "!governance");
        emit EmergencyERC20Drain(address(token), governance, amount);
        token.transfer(governance, amount);
    }
}

 
contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}