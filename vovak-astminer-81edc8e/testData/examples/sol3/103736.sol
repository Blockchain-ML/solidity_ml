pragma solidity ^0.5.17;

 
contract Initializable {

   
  bool private initialized;

   
  bool private initializing;

   
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

   
  function isConstructor() private view returns (bool) {
     
     
     
     
     
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

   
  uint256[50] private ______gap;
}

 
contract Context is Initializable {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    function initialize(address sender) public initializer {
        _owner = sender;
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

    uint256[50] private ______gap;
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

 
interface ERC20Basic {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


 
interface ERC20Advanced {
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
contract ERC20Standard is ERC20Basic, ERC20Advanced {}

contract TokenDistribution is Ownable {
    using SafeMath for uint256;

     
     

    ERC20Standard public token;                          

    uint256 constant internal base18 = 1000000000000000000;

    uint256 public standardRate;

    uint256 public percentBonus;                         
    uint256 public withdrawDate;                         
    uint256 public totalNumberOfInvestments;             
    uint256 public totalEtherInvested;                   

     
    struct Investment {
        address investAddr;
        uint256 ethAmount;
        bool hasClaimed;
        uint256 principalClaimed;
        uint256 bonusClaimed;
        uint256 claimTime;
    }

     
    mapping(uint256 => Investment) public investments;

     
    mapping(address => uint256[]) public investmentIDs;

    uint256 private unlocked;

     
     
    modifier lock() {
        require(unlocked == 1, 'Locked');
        unlocked = 0;
        _;
        unlocked = 1;
    }          

     
     
    function initialize
    (
        address[] calldata _investors,
        uint256[] calldata _ethAmounts,
        ERC20Standard _erc20Token,
        uint256 _withdrawDate,
        uint256 _standardRate,
        uint256 _percentBonus
    )
        external initializer
    {
        Ownable.initialize(_msgSender());

         
        addInvestments(_investors, _ethAmounts);
         
        setERC20Token(_erc20Token);

         
        withdrawDate = _withdrawDate;

        standardRate = _standardRate;

         
        percentBonus = _percentBonus;

         
        unlocked = 1;
    }

     
     
    event WithDrawn(
        address indexed investor,
        uint256 indexed investmentID,
        uint256 principal,
        uint256 bonus,
        uint256 withdrawTime
    );

     
     

     
    function withdraw(uint256 investmentID) external lock returns (bool) {
        require(investments[investmentID].investAddr == msg.sender, "You are not the investor of this investment");
        require(block.timestamp >= withdrawDate, "Can only withdraw after withdraw date");
        require(!investments[investmentID].hasClaimed, "Tokens already withdrawn for this investment");
        require(investments[investmentID].ethAmount > 0, "0 ether in this investment");

         
        uint256 _ethAmount = investments[investmentID].ethAmount;

        (uint256 _principal, uint256 _bonus, uint256 _principalAndBonus) = calculatePrincipalAndBonus(_ethAmount);

        _updateWithdraw(investmentID, _principal, _bonus);

         
        require(token.transfer(msg.sender, _principalAndBonus), "Fail to transfer tokens");

        emit WithDrawn(msg.sender, investmentID, _principal, _bonus, block.timestamp);
        return true;
    }

     
     
     
    function addInvestments(address[] memory _investors, uint256[] memory _ethAmounts) public onlyOwner {
        require(_investors.length == _ethAmounts.length, "The number of investing addresses should equal the number of ether amounts");
        for (uint256 i = 0; i < _investors.length; i++) {
             addInvestment(_investors[i], _ethAmounts[i]); 
        }
    }

     
    function setERC20Token(ERC20Standard _erc20Token) public onlyOwner {
        token = _erc20Token; 
    }

     
    function setPercentBonus(uint256 _percentBonus) public onlyOwner {
        percentBonus = _percentBonus; 
    }

     
    function returnTokens(address _token, uint256 _amount, address _newAddress) external onlyOwner {
        require(block.timestamp >= withdrawDate.add(7 * 24 * 60 * 60), "Cannot return any token within 7 days of withdraw date");
        uint256 balance = ERC20Standard(_token).balanceOf(address(this));
        require(_amount <= balance, "Exceeds balance");
        require(ERC20Standard(_token).transfer(_newAddress, _amount), "Fail to transfer tokens");
    }

     
    function setWithdrawDate(uint256 _withdrawDate) public onlyOwner {
        withdrawDate = _withdrawDate;
    }

     
     
    
     
    function canWithdraw() public view returns (bool, uint256) {
        if (block.timestamp >= withdrawDate) {
            return (true, 0);
        } else {
            return (false, withdrawDate.sub(block.timestamp));
        }
    }

     
    function calculatePrincipalAndBonus(uint256 _ether)
        public view returns (uint256, uint256, uint256)
    {
        uint256 principal = _ether.mul(standardRate).div(base18);
        uint256 bonus = principal.mul(percentBonus).div(base18);
        uint256 principalAndBonus = principal.add(bonus);
        return (principal, bonus, principalAndBonus);
    }

     
    function getInvestmentIDs(address _investAddr) external view returns (uint256[] memory) {
        return investmentIDs[_investAddr];
    }

     
    function getInvestment(uint256 _investmentID) external view
        returns(address _investAddr, uint256 _ethAmount, bool _hasClaimed,
                uint256 _principalClaimed, uint256 _bonusClaimed, uint256 _claimTime)
    {
        _investAddr = investments[_investmentID].investAddr;
        _ethAmount = investments[_investmentID].ethAmount;
        _hasClaimed = investments[_investmentID].hasClaimed;
        _principalClaimed = investments[_investmentID].principalClaimed;
        _bonusClaimed = investments[_investmentID].bonusClaimed;
        _claimTime = investments[_investmentID].claimTime;
    }
    

     
     
     
    function _updateWithdraw(uint256 _investmentID, uint256 _principal, uint256 _bonus) 
        private
    {
        investments[_investmentID].hasClaimed = true;
        investments[_investmentID].principalClaimed = _principal;
        investments[_investmentID].bonusClaimed = _bonus;
        investments[_investmentID].claimTime = block.timestamp;
        investments[_investmentID].ethAmount = 0;
    }

     
    function addInvestment(address _investor, uint256 _eth) private {
        uint256 investmentID = totalNumberOfInvestments.add(1);
        investments[investmentID].investAddr = _investor;
        investments[investmentID].ethAmount = _eth;
   
        totalEtherInvested = totalEtherInvested.add(_eth);
        totalNumberOfInvestments = investmentID;

        investmentIDs[_investor].push(investmentID);
    }
}