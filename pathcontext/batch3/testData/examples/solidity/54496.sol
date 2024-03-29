pragma solidity ^0.4.24;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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

contract ERC20 {
    uint256 public totalSupply;

    bool public transfersEnabled;

    function balanceOf(address _owner) public constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ERC223Basic {
    uint256 public totalSupply;

    bool public transfersEnabled;

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function transfer(address to, uint256 value, bytes data) public;

    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

}

contract ERC223ReceivingContract {
     
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

contract ERC223Token is ERC223Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;  

     
    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length == numwords * 32 + 4);
        _;
    }

     
    function transfer(address _to, uint _value, bytes _data) public onlyPayloadSize(3) {
         
         
        uint codeLength;
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(transfersEnabled);

        assembly {
         
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value, _data);
    }

     
    function transfer(address _to, uint _value) public onlyPayloadSize(2) returns(bool) {
        uint codeLength;
        bytes memory empty;
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(transfersEnabled);

        assembly {
         
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        emit Transfer(msg.sender, _to, _value, empty);
        return true;
    }


     
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
}

contract StandardToken is ERC20, ERC223Token {

    mapping(address => mapping(address => uint256)) internal allowed;

     
    function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize(3) returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(transfersEnabled);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function allowance(address _owner, address _spender) public onlyPayloadSize(2) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

     
    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract TimeToken is StandardToken {

    string public constant name = "First Time Token";
    string public constant symbol = "FTT";
    uint8 public constant decimals = 18;
    uint256 public rate = 1;
    uint256 public constant INITIAL_SUPPLY = 10**2 * (10**uint256(decimals));
    address public owner;
    mapping (address => bool) public contractUsers;
    bool public mintingFinished;
    uint256 public tokenAllocated = 0;
     
    mapping (address => uint) public countClaimsToken;

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);
    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
    event TokenLimitReached(uint256 tokenRaised, uint256 purchasedToken);
    event MinWeiLimitReached(address indexed sender, uint256 weiAmount);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    constructor(address _owner) public {
        totalSupply = INITIAL_SUPPLY;
        owner = _owner;
        owner = msg.sender;  
        balances[owner] = INITIAL_SUPPLY;
        transfersEnabled = true;
        mintingFinished = false;
    }

     
    function() payable public {
        buyTokens(msg.sender);
    }

    function buyTokens(address _investor) public payable returns (uint256){
        require(_investor != address(0));
        uint256 weiAmount = msg.value;
        uint256 tokens = validPurchaseTokens(weiAmount);
        if (tokens == 0) {return 0;}
        tokenAllocated = tokenAllocated.add(tokens);
        mint(_investor, tokens, owner);

        emit TokenPurchase(_investor, weiAmount, tokens);
        owner.transfer(weiAmount);
        return tokens;
    }

    function buyTokensFromContract(uint256 _weiAmount) external payable returns (uint256){
        address investor = msg.sender;
        require(investor != address(0));

        uint256 tokens = validPurchaseTokens(_weiAmount);
        if (tokens == 0) {return 0;}
        tokenAllocated = tokenAllocated.add(tokens);
        mint(investor, tokens, owner);

        emit TokenPurchase(investor, _weiAmount, tokens);
        owner.transfer(_weiAmount);
        return tokens;
    }

    function validPurchaseTokens(uint256 _weiAmount) public returns (uint256) {
        uint256 addTokens = _weiAmount.mul(rate);
        if (_weiAmount < 0.005 ether) {
            emit MinWeiLimitReached(msg.sender, _weiAmount);
            return 0;
        }
        if (tokenAllocated.add(addTokens) > balances[owner]) {
            emit TokenLimitReached(tokenAllocated, addTokens);
            return 0;
        }
        return addTokens;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

     
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }

    function changeOwner(address _newOwner) onlyOwner public returns (bool){
        require(_newOwner != address(0));
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
        return true;
    }

    function enableTransfers(bool _transfersEnabled) onlyOwner public {
        transfersEnabled = _transfersEnabled;
    }

     
    function mint(address _to, uint256 _amount, address _owner) canMint internal returns (bool) {
        require(_to != address(0));
        require(_amount <= balances[owner]);
        balances[_to] = balances[_to].add(_amount);
        balances[_owner] = balances[_owner].sub(_amount);
        emit Mint(_to, _amount);
        emit Transfer(_owner, _to, _amount);
        return true;
    }

    function claim() canMint public returns (bool) {
        uint256 currentTime = now;
        currentTime = 1540037100;  
        require(validPurchaseTime(currentTime));
        address beneficiar = msg.sender;
        require(beneficiar != address(0));

        uint256 amount = calcAmount(beneficiar);
        require(amount <= balances[owner]);

        balances[beneficiar] = balances[beneficiar].add(amount);
        balances[owner] = balances[owner].sub(amount);
        tokenAllocated = tokenAllocated.add(amount);
        emit Mint(beneficiar, amount);
        emit Transfer(owner, beneficiar, amount);
        return true;
    }

    function calcAmount(address _beneficiar) canMint public returns (uint256 amount) {  
     
        uint256 numClaimToken = 1 * (10**uint256(decimals));
        if (countClaimsToken[_beneficiar] == 0) {
            countClaimsToken[_beneficiar] = 1;
        }
        if (countClaimsToken[_beneficiar] >= 22) {
            return 0;
        }
        uint step = countClaimsToken[_beneficiar];
        amount = numClaimToken.mul(105 - 5*step).div(100);
        countClaimsToken[_beneficiar] = countClaimsToken[_beneficiar].add(1);
    }

    function validPurchaseTime(uint256 _currentTime) canMint public view returns (bool) {
        uint256 dayTime = _currentTime % 1 days;
        if (3600*12 <= dayTime && dayTime <=  3600*12 + 15*60) {
            return true;
        }
        return false;
    }

     
    function claimTokensToOwner(address _token) public onlyOwner {
        if (_token == 0x0) {
            owner.transfer(address(this).balance);
            return;
        }
        TimeToken token = TimeToken(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(owner, balance);
        emit Transfer(_token, owner, balance);
    }

    function setRate(uint256 _newRate) external onlyOwner returns (bool){
        require(_newRate > 0);
        rate = _newRate;
        return true;
    }
}