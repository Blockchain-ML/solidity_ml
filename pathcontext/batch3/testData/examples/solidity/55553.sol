pragma solidity 0.4.24;

interface Token {
    function mint(address to, uint256 value) public returns (bool);
}

 
library SafeMath {
     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        require(b > 0);
        uint256 c = a / b;
         

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

 
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
    constructor() public {
        owner = msg.sender;
    }


     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract Investing is Ownable {
    using SafeMath for uint;
    Token public token;
    address public trust;
    address[] public investors;

    struct Investor {
        address investor;
        string currency;
        uint rate;
        uint amount;
        bool redeemed;
    }

    mapping(address => Investor) public investments;

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyTrust() {
        require(msg.sender == trust);
        _;
    }

    function makeInvestment(address _investor, string _currency, uint _rate, uint _amount) onlyTrust public returns (bool){
        uint numberOfTokens;
        investments[msg.sender] = Investor(_investor, _currency, _rate, _amount, false);
        numberOfTokens = _amount.div(_rate);
        require(token.mint(_investor, numberOfTokens));
        investors.push(_investor);
        return true;
    }

    function redeem(address _investor) public onlyTrust returns (bool) {
        require(investments[_investor].redeemed == false);
        investments[_investor].redeemed = true;
        return true;
    }

    function setTokenContractsAddress(address _tokenContract) public onlyOwner {
        require(_tokenContract != address(0));
        token = Token(_tokenContract);
    }

    function setTrustAddress(address _trust) public onlyOwner {
        require(_trust != address(0));
        trust = _trust;
    }

    function returnInvestors() public view returns (address[]) {
        return investors;
    }

    function isRedeemed(address _investor) public view returns(bool) {
        return investments[_investor].redeemed;
    }
}