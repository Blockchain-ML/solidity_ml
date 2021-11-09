pragma solidity ^0.4.24;

 
contract Daily75T {

    using SafeMath for uint256;

    mapping(address => uint256) investments;
    mapping(address => uint256) joined;
    mapping(address => uint256) withdrawals;
    mapping(address => uint256) withdrawalsgross;
    mapping(address => uint256) referrer;
    uint256 public step = 14400;
    uint256 public maximumpercent = 150;
    uint256 public minimum = 10 finney;
    uint256 public stakingRequirement = 0.01 ether;
    address public ownerWallet;
    address public owner;
    address promoter1 = 0xBFb297616fFa0124a288e212d1E6DF5299C9F8d0;
    address promoter2 = 0xBFb297616fFa0124a288e212d1E6DF5299C9F8d0;
   

    event Invest(address investor, uint256 amount);
    event Withdraw(address investor, uint256 amount);
    event Bounty(address hunter, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     

    constructor() public {
        owner = msg.sender;
        ownerWallet = msg.sender;
    }

     

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address newOwner, address newOwnerWallet) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        ownerWallet = newOwnerWallet;
    }

     
    function () public payable {
        buy(0x0);
    }

    function buy(address _referredBy) public payable {
        require(msg.value >= minimum);

        address _customerAddress = msg.sender;

        if(
            
           _referredBy != 0x0000000000000000000000000000000000000000 &&

            
           _referredBy != _customerAddress &&

            
            
           investments[_referredBy] >= stakingRequirement
       ){
            
           referrer[_referredBy] = referrer[_referredBy].add(msg.value.mul(5).div(100));
       }

       if (investments[msg.sender] > 0){
           if (withdraw()){
               withdrawals[msg.sender] = 0;
           }
       }
       investments[msg.sender] = investments[msg.sender].add(msg.value);
       joined[msg.sender] = block.timestamp;
       uint256 percentmax = msg.value.mul(5).div(100);
       uint256 percentmaxhalf = percentmax.div(2);
       uint256 percentmin = msg.value.mul(1).div(100);
       uint256 percentminhalf = percentmin.div(2);
       
       ownerWallet.transfer(percentmax);
       promoter1.transfer(percentmaxhalf);
       promoter2.transfer(percentminhalf);
       emit Invest(msg.sender, msg.value);
    }

     
    function getBalance(address _address) view public returns (uint256) {
        uint256 minutesCount = now.sub(joined[_address]).div(1 minutes);
        uint256 percent = investments[_address].mul(step).div(100);
        uint256 percentfinal = percent.div(2);
        uint256 different = percentfinal.mul(minutesCount).div(1440);
        uint256 balancetemp = different.sub(withdrawals[_address]);
        uint256 maxpayout = investments[_address].mul(maximumpercent).div(100);
        uint256 balancesum = withdrawalsgross[_address].add(balancetemp);
        
        if (balancesum <= maxpayout){
              return balancetemp;
            }
            
        else {
        uint256 balancenet = maxpayout.sub(withdrawalsgross[_address]);
        return balancenet;
        }
        
        
    }

     
    function withdraw() public returns (bool){
        require(joined[msg.sender] > 0);
        uint256 balance = getBalance(msg.sender);
        if (address(this).balance > balance){
            if (balance > 0){
                withdrawals[msg.sender] = withdrawals[msg.sender].add(balance);
                withdrawalsgross[msg.sender] = withdrawalsgross[msg.sender].add(balance);
                uint256 maxpayoutfinal = investments[msg.sender].mul(maximumpercent).div(100);
                msg.sender.transfer(balance);
                if (withdrawalsgross[msg.sender] >= maxpayoutfinal){
                investments[msg.sender] = 0;
            }
              emit Withdraw(msg.sender, balance);
            }
            return true;
        } else {
            return false;
        }
    }

     
    function bounty() public {
        uint256 refBalance = checkReferral(msg.sender);
        if(refBalance >= minimum) {
             if (address(this).balance > refBalance) {
                referrer[msg.sender] = 0;
                msg.sender.transfer(refBalance);
                emit Bounty(msg.sender, refBalance);
             }
        }
    }

     
    function checkBalance() public view returns (uint256) {
        return getBalance(msg.sender);
    }

     
    function checkWithdrawals(address _investor) public view returns (uint256) {
        return withdrawals[_investor];
    }
    
    function checkWithdrawalsgross(address _investor) public view returns (uint256) {
        return withdrawalsgross[_investor];
    }

     
    function checkInvestments(address _investor) public view returns (uint256) {
        return investments[_investor];
    }

     
    function checkReferral(address _hunter) public view returns (uint256) {
        return referrer[_hunter];
    }
}

 
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        uint256 c = a / b;
         
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}