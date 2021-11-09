 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

pragma solidity ^0.6.0;

 
contract ReentrancyGuard {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }
}
 

pragma solidity ^0.6.11;
interface IERC20Token {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 

pragma solidity ^0.6.11;

 
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
 

pragma solidity ^0.6.11;




interface IERC721 {
    function burn(uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function mint( address _to, uint256 _tokenId, string calldata _uri, string calldata _payload) external;
    function changeName(string calldata name, string calldata symbol) external;
    function updateTokenUri(uint256 _tokenId,string memory _uri) external;
}

interface Ownable {
    function transferOwnership(address newOwner) external;
}

interface BasicERC20 {
    function decimals() external view returns (uint8);
}

contract VaultHandler is ReentrancyGuard {
    
    using SafeMath for uint256;
    using SafeMath for uint8;
    address payable private owner;
    bool public initialized;
    address public nftAddress;
    address public paymentAddress;
    address public recipientAddress;
    address public couponAddress;
    uint256 public price;
    
    mapping(address => uint256[]) public balances;
    
     
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
     
    modifier isOwner() {
         
         
         
         
         
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
     
    function transferOwnership(address payable newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }
    
     
    function getOwner() external view returns (address) {
        return owner;
    }
    
    constructor(address _nftAddress, address _paymentAddress, address _recipientAddress, uint256 _price) public {
        owner = msg.sender;  
        emit OwnerSet(address(0), owner);
        
        nftAddress = _nftAddress;
        paymentAddress = _paymentAddress;
        recipientAddress = _recipientAddress;
        initialized = true;
        uint decimals = BasicERC20(paymentAddress).decimals();
        price = _price * 10 ** decimals;
    }
    
    function claim(uint256 tokenId) public isOwner {
        IERC721 token = IERC721(nftAddress);
        token.burn(tokenId);
    }
    
    function buyWithPaymentOnly(address _from, address _to, uint256 _tokenId, string calldata _uri, string calldata _payload) public payable {
        IERC20Token paymentToken = IERC20Token(paymentAddress);
        IERC721 nftToken = IERC721(nftAddress);
        require(paymentToken.transferFrom(_from, address(recipientAddress), price), 'Transfer ERROR');
        nftToken.mint(_to, _tokenId, _uri, _payload);
    }
    
    function transferNftOwnership(address newOwner) external isOwner {
        Ownable nftToken = Ownable(nftAddress);
        nftToken.transferOwnership(newOwner);
    }
    
    function mint( address _to, uint256 _tokenId, string calldata _uri, string calldata _payload) external isOwner {
        IERC721 nftToken = IERC721(nftAddress);
        nftToken.mint(_to, _tokenId, _uri, _payload);
    }
    
    function changeName(string calldata name, string calldata symbol) external isOwner {
        IERC721 nftToken = IERC721(nftAddress);
        nftToken.changeName(name, symbol);
    }
    
    function updateTokenUri(uint256 _tokenId,string memory _uri) external isOwner {
        IERC721 nftToken = IERC721(nftAddress);
        nftToken.updateTokenUri(_tokenId, _uri);
    }
    
    function getPaymentDecimals() public view returns (uint8){
        BasicERC20 token = BasicERC20(paymentAddress);
        return token.decimals();
    }
    
    function changePayment(address payment) public isOwner {
       paymentAddress = payment;
    }
    
    function changeCoupon(address coupon) public isOwner {
       couponAddress = coupon;
    }
    
    function changeRecipient(address _recipient) public isOwner {
       recipientAddress = _recipient;
    }
    
    function changeNft(address token) public isOwner {
        nftAddress = token;
    }
    
    function changePrice(uint256 _price) public isOwner {
        uint decimals = BasicERC20(paymentAddress).decimals();
        price = _price * 10 ** decimals;
    }
}