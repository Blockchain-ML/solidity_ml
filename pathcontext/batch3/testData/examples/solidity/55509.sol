pragma solidity ^0.4.22;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
         
        uint256 c = a / b;
         
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


 
contract Ownable {
    address public owner;


     
    function Ownable() {
        owner = msg.sender;
    }


     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


     
    function transferOwnership(address newOwner) onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

}
contract ERC20Token {
    function transferFrom(address _from, address _to, uint _value) public returns (bool);
    function freeze(address _spender,uint256 _value) public  returns (bool);
}
 

contract RevStaking {
    struct stakingDetail{
        uint256 duration;
        address stakingAddress;
        uint256 amount;
        uint256 timeStart;
    }
   
    
    uint256 public stakingCount=0;
    mapping (address => stakingDetail) stakingDetails;
    mapping (address => bool) public frozenAccount;

     
    event FrozenFunds(address target, bool frozen);
    address [] public stakedAddress;
    
    function stack(address _stakingAddress, uint256 _amount, uint256 _duration) public{
        require(_amount>10000);
        
        ERC20Token _token = ERC20Token(0x53981B4004FE67fB3D0Da666D635fDdadeeD5cf8);
        _token.transferFrom(msg.sender, _stakingAddress, _amount);
         
        
        var stakingDetail = stakingDetails[_stakingAddress];
        stakingDetail.duration = _duration;
        stakingDetail.stakingAddress = _stakingAddress;
        stakingDetail.amount = _amount;
        stakingDetail.timeStart = now;
        
        stakedAddress.push(_stakingAddress);
        stakingCount++;
    }
    
    function getStakedAddresses() view public returns (address[]){
        return stakedAddress;
    }
    
    function getStakedAddress(address _stakingAddress) view public returns (uint256, address, uint256, uint256){
        return (stakingDetails[_stakingAddress].duration,stakingDetails[_stakingAddress].stakingAddress,stakingDetails[_stakingAddress].amount,stakingDetails[_stakingAddress].timeStart);
    }
    
    function freezeAccount(address target, bool freeze) {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
    function confirmStaking() returns (bool){
        ERC20Token _token = ERC20Token(0x53981B4004FE67fB3D0Da666D635fDdadeeD5cf8);
        for(uint256 i = 0; i<stakingCount; i++){
            var stakingDetail = stakingDetails[stakedAddress[i]];
            _token.freeze(stakingDetail.stakingAddress,stakingDetail.amount);
        } 
    }
}