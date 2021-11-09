pragma solidity ^0.5.0;

 

 
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

     
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

 
library SafeMath {
    int256 constant private INT256_MIN = -2**255;

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function mul(int256 a, int256 b) internal pure returns (int256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN));  

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        require(b > 0);
        uint256 c = a / b;
         

        return c;
    }

     
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0);  
        require(!(b == -1 && a == INT256_MIN));  

        int256 c = a / b;

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

 

 
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

 
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

     
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

     
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

     
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

     
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

     
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

     
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

     
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

     
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

     
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

 

 
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

     
    function name() public view returns (string memory) {
        return _name;
    }

     
    function symbol() public view returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

 

contract TokenInterface {
    function name() public view returns (string memory);
}

contract SendERC20Token is Ownable {
    using SafeMath for uint256;

    mapping (address => TokenInheritanceInfo) tokenInheritanceInfo;
    mapping (address => bool) public addedERC20TokenAddress;
    mapping (uint => TokenInfo) tokens;
    uint public tokenIndex = 0;
    address   internal ancestor;

    string public tokenName;

    struct TokenInheritanceInfo{
        
        address[] tokenAddress;
        
        mapping (address => uint) tokenAmountPerHeritorAddress;
         
    }

    struct TokenInfo {
        address tokenContract;
        string tokenName;
        string symbolName;
        uint8 decimal;
        uint256 tokenAmountOfContract;
        uint256 tokenBalanceOfContract;
    }

    modifier isAncestor(address _address) {
        require(ancestor == _address, "The address is not a ancestor.");
        _;
    }

    modifier checkSetTokenAddressHeritor(address _heritor, address _tokenAddress) {
        require(tokenInheritanceInfo[_heritor].tokenAmountPerHeritorAddress[_tokenAddress] > 0, "has been set token address.");
        _;
    }

    modifier checkAddedTokenAddress(address _tokenAddress) {
        require(addedERC20TokenAddress[_tokenAddress]);
        _;
    }

    function setAncestor(address   _address) public onlyOwner {
        ancestor = _address;
    }

    function getAncestor() public view returns (address) {
        return ancestor;
    }

    function setAmount(address _tokenAddress, uint256 _amount) public isAncestor(msg.sender) {
        uint index = getTokenAddressIndex(_tokenAddress);
        
        require(index > 0, "Token address does not exist.");

        tokens[index].tokenAmountOfContract = _amount;
    }

    function getAmount(address _tokenAddress) public view isAncestor(msg.sender) returns (uint256) {
        uint index = getTokenAddressIndex(_tokenAddress);

        require(index > 0, "Token address does not exist.");

        return tokens[index].tokenAmountOfContract;
    }

    function addToken(address _tokenAddress) public   {
       
      
         

        TokenInterface tokenInterface = TokenInterface(_tokenAddress);
      
        tokenName = tokenInterface.name();

        
         

        tokenIndex.add(1);
      
       
        
        
        addedERC20TokenAddress[_tokenAddress] = true;
    }

    function getTokenAddressIndex(address _tokenAddress) internal view returns (uint) {
        for (uint i = 1; i <= tokenIndex; i++) {
            if (tokens[i].tokenContract == _tokenAddress) {
                return i;
            }
        }
        return 0;
    }

    function setTokenAmountPerHeritor(address _to, address _tokenAddress, uint _tokenAmount) public isAncestor(msg.sender)
          {

        tokenInheritanceInfo[_to].tokenAddress.push(_tokenAddress);
        
        tokenInheritanceInfo[_to].tokenAmountPerHeritorAddress[_tokenAddress] = _tokenAmount;
    }

    function getTokenAmountPerHeritor(address _heritor, address _tokenAddress) public view 
      returns (uint256) {
        
        return (tokenInheritanceInfo[_heritor].tokenAmountPerHeritorAddress[_tokenAddress]);
    }

    function getTokenInfo(address _tokenAddress) public view 
    returns (address tokenAddress, string memory symbolName, uint8 decimal, uint256 tokenAmountOfContract) {
        uint index = getTokenAddressIndex(_tokenAddress);

        require(index > 0, "Token address does not exist.");

        tokenAddress = tokens[index].tokenContract;
        symbolName = tokens[index].symbolName;
        decimal = tokens[index].decimal;
        tokenAmountOfContract = tokens[index].tokenAmountOfContract;

        return (tokenAddress, symbolName, decimal, tokenAmountOfContract);
    }

    function getTokenBalance(address _tokenAddress) public view returns (uint256 tokenBalance) {
        ERC20 token = ERC20(_tokenAddress);
        tokenBalance = token.balanceOf(address(this));

        return (tokenBalance);
    }

    function withdrawToken() public   {
        ERC20 token;
        uint256 tokenAmount;
        address tokenAddress;

        for (uint i = 0; i < tokenInheritanceInfo[msg.sender].tokenAddress.length; i++) {
            tokenAddress = tokenInheritanceInfo[msg.sender].tokenAddress[i];
            tokenAmount = tokenInheritanceInfo[msg.sender].tokenAmountPerHeritorAddress[tokenAddress];

            if (tokenAmount == 0){
                continue;
            }

            token = ERC20(tokenAddress);
            tokenInheritanceInfo[msg.sender].tokenAmountPerHeritorAddress[tokenAddress] = 0;
            token.transfer(msg.sender, tokenAmount);
        }
    }
}