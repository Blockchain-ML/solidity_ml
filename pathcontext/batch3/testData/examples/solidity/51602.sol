pragma solidity ^0.4.24;

 
 
 
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

 
 
contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Evoai {
  
  using SafeMath for uint256;
  address public admin;  
  uint256 public feeETH;  
  uint256 public feeEVOT;  
  uint256 public totalEthFee;  
  uint256 public totalTokenFee;  
  address private owner;
  address public tokenEVOT;
  mapping (address => uint256) public tokenBalance;  
  mapping (address => uint256) public etherBalance;  

   
  event Deposit(uint256 types, address user, uint256 amount);  
  event Withdraw(uint256 types, address user, uint256 amount);  
  event Transfered(uint256 types, address _from, uint256 amount, address _to); 
  
   
  constructor() public {
    admin = msg.sender;
    totalEthFee = 0;  
    totalTokenFee = 0;  
  }

  modifier onlyAdmin {
    require(msg.sender == admin);
    _;
  }
  
   
  function setTokenAddress(address _token) onlyAdmin() public {
      tokenEVOT = _token;
  }
  
   
  function setETHFee(uint256 amount) onlyAdmin() public {
    feeETH = amount;
  }
  
   
  function setTokenFee(uint256 amount) onlyAdmin() public {
    feeEVOT = amount;
  }
  
   
  function changeAdmin(address admin_) onlyAdmin() public {
    admin = admin_;
  }

   
  function deposit() payable public {
    totalEthFee = totalEthFee.sub(feeETH);
    etherBalance[msg.sender] = (etherBalance[msg.sender]).add(msg.value.sub(feeETH));
    emit Deposit(0, msg.sender, msg.value);  
  }

  function() payable public {
      
  }
  
   
  function withdraw(uint256 amount) public {
    require(etherBalance[msg.sender] >= amount);
    etherBalance[msg.sender] = etherBalance[msg.sender].sub(amount);
    msg.sender.transfer(amount);
    emit Withdraw(0, msg.sender, amount);  
  }

   
  function depositToken(address token, uint256 amount) public {
    require(tokenEVOT == token);
     
    if (!ERC20(token).transferFrom(msg.sender, this, amount)) revert();
    totalTokenFee = totalTokenFee.add(feeEVOT);
    tokenBalance[msg.sender] = tokenBalance[msg.sender].add(amount.sub(feeEVOT));
    emit Deposit(1, msg.sender, amount);  
  }

   
  function withdrawToken(address token, uint256 amount) public {
    require(tokenBalance[msg.sender] >= amount);
    tokenBalance[msg.sender] = tokenBalance[msg.sender].sub(amount);
    if (!ERC20(token).transfer(msg.sender, amount)) revert();
    emit Withdraw(1, msg.sender, amount);  
  }

   
  function transferETH(address _receiver, uint256 amount) public {
    require(etherBalance[msg.sender] >= amount);
    etherBalance[msg.sender] = etherBalance[msg.sender].sub(amount);
    _receiver.transfer(amount);
    emit Transfered(0, msg.sender, amount, msg.sender);
  }

   
  function transferToken(address token, address _receiver, uint256 amount) public {
    if (token==0) revert();
    require(tokenBalance[msg.sender] >= amount);
    tokenBalance[msg.sender] = tokenBalance[msg.sender].sub(amount);
    if (!ERC20(token).transfer(_receiver, amount)) revert();
    emit Transfered(1, msg.sender, amount, msg.sender);
  }
  
   
  function feeWithdrawEthAmount(uint256 amount) onlyAdmin() public {
    require(totalEthFee >= amount);
    totalEthFee = totalEthFee.sub(amount);
    msg.sender.transfer(amount);
  }

   
  function feeWithdrawEthAll() onlyAdmin() public {
    if (totalEthFee == 0) revert();
    totalEthFee = 0;
    msg.sender.transfer(totalEthFee);
  }

   
  function feeWithdrawTokenAmount(address token, uint256 amount) onlyAdmin() public {
    require(totalTokenFee >= amount);
    if (!ERC20(token).transfer(msg.sender, amount)) revert();
    totalTokenFee = totalTokenFee.sub(amount);
  }

   
  function feeWithdrawTokenAll(address token) onlyAdmin() public {
    if (totalTokenFee == 0) revert();
    if (!ERC20(token).transfer(msg.sender, totalTokenFee)) revert();
    totalTokenFee = 0;
  }
  
   
  function getEvotTokenAddress() public constant returns (address) {
    return tokenEVOT;    
  }
  
   
  function balanceOfToken(address user) public constant returns (uint256) {
    return tokenBalance[user];
  }

   
  function balanceOfETH(address user) public constant returns (uint256) {
    return etherBalance[user];
  }

   
  function balanceOfContractFeeEth() public constant returns (uint256) {
    return totalEthFee;
  }

   
  function balanceOfContractFeeToken() public constant returns (uint256) {
    return totalTokenFee;
  }
  
   
  function getCurrentEthFee() public constant returns (uint256) {
      return feeETH;
  }
  
   
  function getCurrentTokenFee() public constant returns (uint256) {
      return feeEVOT;
  }
}