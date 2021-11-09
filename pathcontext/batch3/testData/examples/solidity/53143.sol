pragma solidity ^0.4.24;

contract owned {
    address public owner;

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract ERC20 is owned {
     
    string public name = "Fiat Coin";
    string public symbol = "FIAT";
    uint8 public decimals = 8;
    uint256 public totalSupply = 70400000 * 10 ** uint256(decimals);

     
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;
   
     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event FrozenFunds(address target, bool frozen);

     
    constructor () public {
        balanceOf[owner] = totalSupply;
    }

     
    function _transfer(address _from, address _to, uint256 _value) internal {
         
        require(_to != 0x0);
         
        require(balanceOf[_from] >= _value);
         
        require(balanceOf[_to] + _value > balanceOf[_to]);
         
        require(!frozenAccount[_from]);
         
        require(!frozenAccount[_to]);
         
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
         
        balanceOf[_from] -= _value;
         
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
         
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

     
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);      
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

     
     
     
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
}

contract Killable is owned {
    function kill() onlyOwner public {
        selfdestruct(owner);
    }
}

contract ERC20_ICO is Killable {

     
    ERC20 public token;

     
    address beneficiary;

     
    uint256 public startsAt = 1531180800;

     
    uint256 public endsAt = 1532649600;

     
    uint256 public TokenPerETH = 1000;

     
    bool public finalized = false;

     
    uint256 public tokensSold = 0;

     
    uint256 public weiRaised = 0;

     
    uint256 public investorCount = 0;

     
    mapping (address => uint256) public investedAmountOf;

     
    event Invested(address investor, uint256 weiAmount, uint256 tokenAmount);
     
    event StartsAtChanged(uint256 startsAt);
     
    event EndsAtChanged(uint256 endsAt);
     
    event RateChanged(uint256 oldValue, uint256 newValue);
    
    constructor (address _token, address _beneficiary) public {
        token = ERC20(_token);
        beneficiary = _beneficiary;
    }

    function investInternal(address receiver) private {
        require(!finalized);
        require(startsAt <= now && endsAt > now);

        if(investedAmountOf[receiver] == 0) {
             
            investorCount++;
        }

         
        uint256 tokensAmount = msg.value * TokenPerETH / 10000000000;
        investedAmountOf[receiver] += msg.value;
         
        tokensSold += tokensAmount;
        weiRaised += msg.value;

         
        emit Invested(receiver, msg.value, tokensAmount);
        
         
        token.transfer(receiver, tokensAmount);

         
        beneficiary.transfer(address(this).balance);

    }

    function () public payable {
        investInternal(msg.sender);
    }

    function setStartsAt(uint256 time) onlyOwner public {
        require(!finalized);
        startsAt = time;
        emit StartsAtChanged(startsAt);
    }
    function setEndsAt(uint256 time) onlyOwner public {
        require(!finalized);
        endsAt = time;
        emit EndsAtChanged(endsAt);
    }
    function setRate(uint256 value) onlyOwner public {
        require(!finalized);
        require(value > 0);
        emit RateChanged(TokenPerETH, value);
        TokenPerETH = value;
    }

    function finalize() public onlyOwner {
         
        finalized = true;
        uint256 tokensAmount = token.balanceOf(this);
        token.transfer(beneficiary, tokensAmount);
    }

    function setBeneficiary(address _beneficiary) public onlyOwner {
         
        beneficiary = _beneficiary;
    }
}