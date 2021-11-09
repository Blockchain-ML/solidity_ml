pragma solidity ^0.4.25;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0);  
    uint256 c = a / b;
    assert(a == b * c + a % b);  
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure  returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

     
    contract IFiat {
        
        string public constant name = "iFiat Wrapper";
        string public constant symbol = "IFIAT";
        uint8 public constant decimals = 4;
        uint public _totalSupply = 7000000000;
        uint256 public RATE = 500;
        bool public isMinting = true;
        string public constant generatedBy  = "Geopay.me by FinTech Services";
        
        using SafeMath for uint256;
        address public owner;
        
          
         modifier onlyOwner() {
            if (msg.sender != owner) {
                revert();
            }
             _;
         }
     
         
        mapping(address => uint256) balances;
         
        mapping(address => mapping(address=>uint256)) allowed;

         
        function () public payable{
            createTokens();
        }

         
        constructor() public {
            owner = msg.sender; 
            balances[owner] = _totalSupply;
        }

         
        function burnTokens(uint256 _value) public onlyOwner {

             require(balances[msg.sender] >= _value && _value > 0 );
             _totalSupply = _totalSupply.sub(_value);
             balances[msg.sender] = balances[msg.sender].sub(_value);
             
        }



         
         function createTokens() public payable {
            if(isMinting == true){
                require(msg.value > 0);
                uint256  tokens = msg.value.mul(RATE);
                balances[msg.sender] = balances[msg.sender].add(tokens);
                _totalSupply = _totalSupply.add(tokens);
                owner.transfer(msg.value);
            }
            else{
                revert();
            }
        }


        function endCrowdsale() public onlyOwner {
            isMinting = false;
        }

        function changeCrowdsaleRate(uint256 _value) public onlyOwner {
            RATE = _value;
        }


        
        function totalSupply() public constant returns(uint256){
            return _totalSupply;
        }
         
        function balanceOf(address _owner) public constant returns(uint256){
            return balances[_owner];
        }

          
        function transfer(address _to, uint256 _value) public returns(bool) {
            require(balances[msg.sender] >= _value && _value > 0 );
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        
     
     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(allowed[_from][msg.sender] >= _value && balances[_from] >= _value && _value > 0);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
     
     
    function approve(address _spender, uint256 _value) public returns(bool){
        allowed[msg.sender][_spender] = _value; 
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
     
    function allowance(address _owner, address _spender) public constant returns(uint256) {
        return allowed[_owner][_spender];
    }
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}