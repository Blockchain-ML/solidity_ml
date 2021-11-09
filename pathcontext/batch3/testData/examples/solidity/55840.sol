pragma solidity ^0.4.24;

 

 
contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 
    constructor() public{
        _owner = msg.sender;
    }

 
    function owner() public view returns(address){
        return _owner;
    }

 
    modifier onlyOwner(){
        require(isOwner(), "msg.sender is not the onwer of this contract");
        _;
    }

 
    function isOwner() public view returns(bool){
        return msg.sender == _owner;
    }

 
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

 
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

 
    function _transferOwnership(address newOwner) internal{
        require(newOwner != address(0), "Address incorrect");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
}

 

 
library SafeMath {

 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0){
            return a;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    } 
 

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "b must be larger than zero");
        uint256 c = a / b;
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "b must be lower than a");
        uint256 c = a - b;
        return c;
    }
 
    function add(uint256 a, uint256 b) internal pure returns (uint256){
        uint256 c = a + b;
        require(c >= a, "c must be larger than a");
        return c;
    }

 
    function mod(uint256 a, uint256 b) internal pure returns (uint256){
        require(b!=0,"b can not equal to zero");
        return a % b;
    }

}

 

contract ContributorList is Ownable {

    using SafeMath for uint256;

    
    mapping(address => bool) _whiteListAddresses;
    mapping(address => uint256) _contributors;

    uint256 private _minContribution;  
    uint256 private _maxContribution;  
    address private _adminAddress;

    modifier onlyAdmin(){
        require(msg.sender == _adminAddress, "Permision denied");
        _;
    }

    constructor(uint256 minContribution, uint256 maxContribution, address adminAddress) public {
        require(minContribution > 0, "Invalid MinContribution");
        require(maxContribution > 0, "Invalid MaxContribution");
        _minContribution = minContribution;
        _maxContribution = maxContribution;
        _adminAddress = adminAddress;
    }

    event UpdateWhiteList(address user, bool isAllowed, uint256 time );

 
    function updateWhiteList(address user, bool isAllowed) 
    public
    onlyAdmin{
        _whiteListAddresses[user] = isAllowed;
        emit UpdateWhiteList(user,isAllowed, block.timestamp);
    }

 
    function updateWhiteLists(address[] users, bool[] isAlloweds)
    public
    onlyAdmin{
        for (uint i = 0 ; i < users.length ; i++) {
            address _user = users[i];
            bool _allow = isAlloweds[i];
            _whiteListAddresses[_user] = _allow;
            emit UpdateWhiteList(_user, _allow, block.timestamp);
        }
    }

 
    function getEligibleAmount(address contributor, uint256 amount) public view returns(uint256){
        
        if(amount < _minContribution){
            return 0;
        }

        uint256 contributorMaxContribution = _maxContribution;
        uint256 remainingCap = contributorMaxContribution.sub(_contributors[contributor]);

        return (remainingCap > amount) ? amount : remainingCap;
    }

 
    function increaseContribution(address contributor, uint256 amount)
    internal
    returns(uint256)
    {
        if(!_whiteListAddresses[contributor]){
            return 0;
        }
        uint256 result = getEligibleAmount(contributor,amount);
        _contributors[contributor] = _contributors[contributor].add(result);
        return result;
    }


}

 

contract CrowdSaleTest  {
    ContributorList public _contributorList;

    constructor (ContributorList contributorList) public{
        _contributorList = contributorList;
    }
}