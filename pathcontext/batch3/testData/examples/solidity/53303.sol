pragma solidity ^ 0.4 .11;

 
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
         
        uint256 c = a / b;
         
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

 
interface token {
    function transfer(address, uint) external;
}
contract Crowdsale {
    using SafeMath
    for uint256;

     
    address public wallet;
     
    address public addressOfTokenUsedAsReward;

    uint256 public price = 3000;

    token tokenReward;
 



     
    uint256 public weiRaised;

     
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


    constructor() public {
         
        wallet = 0xdE06f20D59775A4a4bee9fE3993De58413b8449C;
         
        addressOfTokenUsedAsReward = 0x1F3c9d7Ebc9C030BB13a2bbD08bCB4486b8D808c;


        tokenReward = token(addressOfTokenUsedAsReward);
    }

    bool public started = true;

    function startSale() public {
        require(msg.sender == wallet);
        started = true;
    }

    function stopSale() public {
        require(msg.sender == wallet);
        started = false;
    }

    function setPrice(uint256 _price) public {
        require(msg.sender == wallet);
        price = _price;
    }

    function changeWallet(address _wallet) public {
        require(msg.sender == wallet);
        wallet = _wallet;
    }

    function changeTokenReward(address _token) public {
        require(msg.sender == wallet);
        tokenReward = token(_token);
        addressOfTokenUsedAsReward = _token;
    }

     
    function () public payable {
        buyTokens(msg.sender);
    }

     
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 weiAmount = msg.value;


         
        uint256 tokens = (weiAmount) * price;  

         
        weiRaised = weiRaised.add(weiAmount);

        tokenReward.transfer(beneficiary, tokens);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
        forwardFunds();
    }

     
     
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

     
    function validPurchase() internal constant returns(bool) {
        bool withinPeriod = started;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    function withdrawTokens(uint256 _amount) public {
        require(msg.sender == wallet);
        tokenReward.transfer(wallet, _amount);
    }
}