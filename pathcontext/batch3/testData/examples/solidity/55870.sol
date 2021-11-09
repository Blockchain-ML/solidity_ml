pragma solidity ^0.4.24;

 
library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);  
        uint256 c = a / b;
        assert(a == b * c + a % b);  
        return a / b;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ForeignToken {
    function balanceOf(address _owner) constant public returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}

contract airdropDATP {
    
    using SafeMath for uint256;
    address owner = msg.sender;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event TransferMulti(address indexed _from, address[] indexed _toMul, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    event Distr(address indexed to, uint256 amount);
    event DistrFinished();
    
    event Airdrop(address indexed _owner, uint _amount, uint _balance);

    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
    
    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }

    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    }
    
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {

        require(_amount <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }
    
    function getTokenBalance(address tokenAddress) constant public returns (uint){
        ForeignToken t = ForeignToken(tokenAddress);
        uint bal = t.balanceOf(address(this));
        return bal;
    }
    
    function withdrawForeignTokens(address _tokenContract, address _walletDest, uint256 _amountT) onlyOwner public returns (bool) {
        ForeignToken token = ForeignToken(_tokenContract);
        address dest = _walletDest;
        uint amountToken = _amountT;
        return token.transfer(dest, amountToken);
    }
    
    function withdrawForeignTokensMultiple(address _tokenContract, address[] _walletDestmulti, uint256 _amountT) onlyOwner public {
        ForeignToken token = ForeignToken(_tokenContract);
        uint amountToken = _amountT;
        for (uint i = 0; i < _walletDestmulti.length; i++) token.transfer(_walletDestmulti[i], amountToken);
    }
}