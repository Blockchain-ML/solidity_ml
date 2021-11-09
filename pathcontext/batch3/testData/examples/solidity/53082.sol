pragma solidity ^0.4.24;

 
 
 
 
 
 
 


 
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


 
contract Ownable {

    address public owner;
    
     
    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public{
        owner = msg.sender;
    }

     
    modifier onlyOwner {
        require(msg.sender == owner, "");
        _;
    }

     
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


 
contract Pausable is Ownable {

    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused {
        require(!paused, "");
        _;
    }
    modifier whenPaused {
        require(paused, "");
        _;
    }

     
    function pause() public onlyOwner whenNotPaused returns (bool) {
        paused = true;
        emit Pause();
        return true;
    }

     
    function unpause() public onlyOwner whenPaused returns (bool) {
        paused = false;
        emit Unpause();
        return true;
    }

}


interface LVECoin {
    function transfer(address _to, uint256 _value) external returns(bool);
    function balanceOf(address _owner) external view returns (uint256);
}


 
contract OpenSale is Pausable {

    using SafeMath for uint256;

     
    LVECoin private tokenContract;
     
    uint256 private totalToken              = 2000000000 * (10 ** 18);
     
    uint256 private tokenSoldThreshold      = totalToken.mul(25).div(1000);

     
     
     
     
     


     
     
    uint256 public saleStartTime            = 1535535000;
     
    uint256 public saleEndTime              = 1535536800;



     
     
     
     
     


     
    uint256 public tokenPrice               = 700;

     
    uint256 public weiCrowded               = 0;
     
    uint256 public tokensSold               = 0;
    address private walletAddr;

     
    struct Investor{
        address addr;        
        uint256 amount;      
    }
     
    mapping(address => Investor) public investorMap;
     
    mapping(address => bool) public freezeAccountMap;
     
    address[] public investorsList;

     
    event Lock(address indexed _to, uint256 _amount, uint _endTime);
     
    event UnLock(address indexed _to, uint256 _amount);
     
    event Freeze(address indexed _to);
     
    event Unfreeze(address indexed _to);
    event WithdrawalToken(address indexed _to, uint256 _amount);
    event WithdrawalEther(address indexed _to, uint256 _amount);

    constructor(address _tokenAddr) public{
        require(_tokenAddr != address(0), "");
        tokenContract = LVECoin(_tokenAddr);
        walletAddr = 0x4a26c38d74c7aad9a8c5f60703487572602eba7f;
    }


     
    modifier isInSaleTime {
        require(now >= saleStartTime && now <= saleEndTime, "");
        _;
    }
     
    modifier isOnSale() {
         
        uint256 tokenBalance = tokenContract.balanceOf(address(this));
        require(tokenBalance > 0, "");
        _;
    }
     
    modifier freezeable(address _addr) {
        require(_addr != address(0), "");
        require(!freezeAccountMap[_addr], "");
        _;
    }


     
    function getContractTokenBalance() public view returns(uint256 _rContractTokenAmount){
        return tokenContract.balanceOf(address(this));
    }

    
     
     
    function() public payable isInSaleTime isOnSale whenNotPaused freezeable(msg.sender){
        require(msg.sender != address(0), "");
        require(msg.value > 0, "");
         
        uint256 weiAmount = msg.value;
        weiCrowded = weiCrowded.add(weiAmount);
        walletAddr.transfer(weiAmount);
        emit WithdrawalEther(walletAddr, msg.value);
         
        uint256 investToken = calculateToken(weiAmount);
        tokensSold = tokensSold.add(investToken);
         
        uint256 tokenBalance = tokenContract.balanceOf(address(this));
        require(tokenBalance >= investToken, "");
        require(tokenContract.transfer(msg.sender, investToken), "");
         
        addInvestor(msg.sender, investToken);
    }

    
     
    function transferToken(address _beneficiary, uint256 _amount) public onlyOwner isInSaleTime isOnSale whenNotPaused freezeable(_beneficiary){
        require(_beneficiary != address(0), "");
         
        tokensSold = tokensSold.add(_amount);
         
        uint256 tokenBalance = tokenContract.balanceOf(address(this));
        require(tokenBalance >= _amount, "");
         
        require(tokenContract.transfer(_beneficiary, _amount), "");
        addInvestor(_beneficiary, _amount);
    }


     
    function addInvestor(address _investorAddr, uint256 _amount) internal returns(bool){
        require(_investorAddr != address(0), "");
        require(_amount > 0, "");
        if(investorMap[_investorAddr].addr != _investorAddr){
            investorsList.push(_investorAddr);
        }
        Investor memory investor;
        investor.addr = _investorAddr;
        investor.amount = investorMap[_investorAddr].amount.add(_amount);
        investorMap[_investorAddr] = investor;
        return true;
    }

     
    function freezeAccount(address _freezeAddr) public onlyOwner returns (bool) {
        require(_freezeAddr != address(0), "");
        freezeAccountMap[_freezeAddr] = true;
        emit Freeze(_freezeAddr);
        return true;
    }
    
     
    function unfreezeAccount(address _freezeAddr) public onlyOwner returns (bool) {
        require(_freezeAddr != address(0), "");
        freezeAccountMap[_freezeAddr] = false;
        emit Unfreeze(_freezeAddr);
        return true;
    }


     
    function calculateToken(uint256 weiAmount) internal view returns(uint256 _rInvestToken){
         
        uint256 investToken = weiAmount.mul(tokenPrice);
        return investToken;
    }

    
     
    function recyclingRemainToken() public onlyOwner whenNotPaused returns(bool){
        require(now > saleEndTime, "");
        uint256 remainToken = tokenContract.balanceOf(address(this));
        require(remainToken > 0, "");
        require (tokenContract.transfer(msg.sender, remainToken), "");
        pause();
        return true;   
    }


}