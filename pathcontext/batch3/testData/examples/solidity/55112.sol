pragma solidity ^0.4.21;



 
library SafeMath {

   
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
     
     
     
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

   
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0);  
    uint256 c = _a / _b;
     

    return c;
  }

   
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

   
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

   
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract ERC777Token {
     
    function name() public view returns (string);
     
    function symbol() public view returns (string);
     
    function totalSupply() public view returns (uint256);
     
    function granularity() public view returns (uint256);
    
     
    function defaultOperators() public view returns (address[]);
     
    function isOperatorFor(address operator, address tokenHolder) public view returns (bool);
     
    function authorizeOperator(address operator) public;
     
    function revokeOperator(address operator) public;

     
    function send(address to, uint256 amount, bytes holderData) public;
    function operatorSend(address from, address to, uint256 amount, bytes holderData, bytes operatorData) public;

    function burn(uint256 amount, bytes holderData) public;
    function operatorBurn(address from, uint256 amount, bytes holderData, bytes operatorData) public;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes holderData,
        bytes operatorData
    );  
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes operatorData);
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes holderData, bytes operatorData);
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

contract ERC777DemoToken is ERC777Token {
    string internal mName = "ERC777DemoToken";
    string internal mSymbol = "EDT1";
    uint8 public mDecimals = 18;
    uint256 internal mGranularity = 1;
    uint256 internal mTotalSupply = 1000000;

    mapping(address => uint) internal mBalances;
    mapping(address => mapping(address => bool)) internal mAuthorized;

    address[] internal mDefaultOperators;
    mapping(address => bool) internal mIsDefaultOperator;
    mapping(address => mapping(address => bool)) internal mRevokedDefaultOperator;
    
    function ERC777DemoToken(string name, string symbol, uint256 initialSupply) {
        mTotalSupply = initialSupply * 10 ** uint256(mDecimals); 
        
        mName = name;
        mSymbol = symbol;
        mBalances[msg.sender] = mTotalSupply;
    }
    
     
     
     
    function name() public constant returns (string) { return mName; }

     
    function symbol() public constant returns (string) { return mSymbol; }

     
    function granularity() public constant returns (uint256) { return mGranularity; }

     
    function totalSupply() public constant returns (uint256) { return mTotalSupply; }
    
     
     
     
    function balanceOf(address _tokenHolder) public constant returns (uint256) { return mBalances[_tokenHolder]; }
    
     
     
    function defaultOperators() public view returns (address[]) { return mDefaultOperators; }

     
     
    function authorizeOperator(address _operator) public {
        require(_operator != msg.sender);
        if (mIsDefaultOperator[_operator]) {
            mRevokedDefaultOperator[_operator][msg.sender] = false;
        } else {
            mAuthorized[_operator][msg.sender] = true;
        }
         
    }

     
     
    function revokeOperator(address _operator) public {
        require(_operator != msg.sender);
        if (mIsDefaultOperator[_operator]) {
            mRevokedDefaultOperator[_operator][msg.sender] = true;
        } else {
            mAuthorized[_operator][msg.sender] = false;
        }
         
    }

     
     
     
     
    function isOperatorFor(address _operator, address _tokenHolder) public constant returns (bool) {
        return (_operator == _tokenHolder
            || mAuthorized[_operator][_tokenHolder]
            || (mIsDefaultOperator[_operator] && !mRevokedDefaultOperator[_operator][_tokenHolder]));
    }

     
     
     
    function send(address _to, uint256 _amount, bytes _userData) public {
        doSend(msg.sender, msg.sender, _to, _amount, _userData, "", true);
    }

     
     
     
     
     
     
    function operatorSend(address _from, address _to, uint256 _amount, bytes _userData, bytes _operatorData) public {
        require(isOperatorFor(msg.sender, _from));
        doSend(msg.sender, _from, _to, _amount, _userData, _operatorData, true);
    }

    function burn(uint256 _amount, bytes _holderData) public {
        doBurn(msg.sender, msg.sender, _amount, _holderData, "");
    }

    function operatorBurn(address _tokenHolder, uint256 _amount, bytes _holderData, bytes _operatorData) public {
        require(isOperatorFor(msg.sender, _tokenHolder));
        doBurn(msg.sender, _tokenHolder, _amount, _holderData, _operatorData);
    }

     
     
    function requireMultiple(uint256 _amount) internal view {
        require(_amount/mGranularity*mGranularity == _amount);
    }

     
     
     
     
     
     
     
     
     
     
    function callSender(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _userData,
        bytes _operatorData
    )
        internal
    {
        return;
         
         
         
         
    }


     
     
     
     
     
     
     
     
     
     
     
     
    function callRecipient(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _userData,
        bytes _operatorData,
        bool _preventLocking
    )
        internal
    {
         
         
         
         
         
         
         
         
    }
    

     
     
     
     
     
     
     
     
     
     
     
    function doSend(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _userData,
        bytes _operatorData,
        bool _preventLocking
    )
        internal
    {
         

         

        require(_to != address(0));           
        require(mBalances[_from] >= _amount);  

        mBalances[_from] = mBalances[_from] - _amount;
        mBalances[_to] = mBalances[_to] + _amount;

         

        Sent(_operator, _from, _to, _amount, _userData, _operatorData);
    }

     
     
     
     
     
     
    function doBurn(address _operator, address _tokenHolder, uint256 _amount, bytes _holderData, bytes _operatorData)
        internal
    {
        requireMultiple(_amount);
        require(balanceOf(_tokenHolder) >= _amount);

        mBalances[_tokenHolder] = mBalances[_tokenHolder] - _amount;
        mTotalSupply = mTotalSupply - _amount;

        callSender(_operator, _tokenHolder, 0x0, _amount, _holderData, _operatorData);
        Burned(_operator, _tokenHolder, _amount, _holderData, _operatorData);
    }
}