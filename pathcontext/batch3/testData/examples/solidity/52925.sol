pragma solidity ^0.4.24;


 
library Math {
    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}


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



 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

     
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

     
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

     
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

}



 
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

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

     
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

     
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

     
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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



 
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
    function Ownable() public {
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



 
contract MyToken is StandardToken, Ownable {

    string public constant name = "MyToken";  
    string public constant symbol = "MT";  
    uint8 public constant decimals = 18;  

    uint256 public constant INITIAL_SUPPLY = 100000000 * (10 ** uint256(decimals));


     
    function MyToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;

        
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }

    function Destruct() public {
         
        selfdestruct(owner);
    }

}


 
contract MyTokenSale is Ownable{
    using SafeMath for uint256;

     
    MyToken public token;

     
    address public wallet;

     
    uint256 public rate;

     
    uint256 public weiRaised;

    enum ICOStage { Stop, PreICO1, PreICO2, PreICO3, ICO}
    ICOStage public stage = ICOStage.PreICO1; 
    
    uint256 public availableTokenForPreICO1 = 0;
    uint256 public availableTokenForPreICO2 = 0;
    uint256 public availableTokenForPreICO3 = 0;
    uint256 public availableTokenForICO = 0;

    uint256 public currentRate = 0;

    uint256 public startTime = now;
    uint256 public endTime = now + 20 * 86400;

    uint256 public minCap = 10000;
    uint256 public cap = 11717;

    
     

     
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

     
    function MyTokenSale(uint256 _rate, address _wallet, MyToken _tokenContract) public {
        require(_rate > 0);
        require(_wallet != address(0));
        
        
         
        token = _tokenContract;
        require(token != address(0));

        rate = _rate;
        wallet = _wallet;
        
        weiRaised = 0;

        

         
        availableTokenForPreICO1 = 6000000 * (10 ** uint256(token.decimals()));
        availableTokenForPreICO2 = 8000000 * (10 ** uint256(token.decimals()));
        availableTokenForPreICO3 = 6000000 * (10 ** uint256(token.decimals()));
        availableTokenForICO = 30000000 * (10 ** uint256(token.decimals()));
    }

     
     
     

     
    function () external payable {
        buyTokens(msg.sender);
    }

     
    function buyTokens(address _beneficiary) public payable {

        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);

         
        uint256 tokens = _getTokenAmount(weiAmount);

         
        weiRaised = weiRaised.add(weiAmount);

        _processPurchase(_beneficiary, tokens);
         
        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

         

         
    }

     
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal pure{
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
    }

     
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
         
         
        return _weiAmount.mul(currentRate);
    }


     
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
    }

     
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        token.transfer(_beneficiary, _tokenAmount);
    }

     
    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }



    function destructSale() public {
        require(msg.sender == owner);
        require(token.transfer(owner, token.balanceOf(address(this))));
        _forwardFunds();
        rate = 0;
        selfdestruct(owner);
    }

    
     

     
     

     
    function setICOStage(uint value) public onlyOwner {

        ICOStage _stage;

        if (uint(ICOStage.PreICO1) == value) {
            _stage = ICOStage.PreICO1;
        } else if (uint(ICOStage.PreICO2) == value) {
            _stage = ICOStage.PreICO2;
        } else if (uint(ICOStage.PreICO3) == value) {
            _stage = ICOStage.PreICO3;
        } else if (uint(ICOStage.ICO) == value){
            _stage = ICOStage.ICO;
        } else if (uint(ICOStage.Stop) == value){
            _stage = ICOStage.Stop;
        }


        stage = _stage;

        if (stage == ICOStage.PreICO1) {
            setCurrentRate(rate.mul(3947).div(3000));
        } else if (stage == ICOStage.PreICO2) {
            setCurrentRate(rate.mul(3571).div(3000));
        } else if (stage == ICOStage.PreICO3) {
            setCurrentRate(rate.mul(3261).div(3000));
        } else if (stage == ICOStage.ICO) {
            setCurrentRate(rate.mul(3000).div(3000));
        } else if (stage == ICOStage.Stop) {
            setCurrentRate(rate.mul(0));
        }
    }



     
    function setCurrentRate(uint256 _rate) private {
        currentRate = _rate;
    }

}