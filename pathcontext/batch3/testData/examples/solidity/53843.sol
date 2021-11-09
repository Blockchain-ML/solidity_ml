pragma solidity ^0.4.0;

 
library SafeMath {
    function safeMul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) internal pure returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

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

    function safePerc(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= 0);
        uint256 c = (a * b) / 100;
        return c;
    }
  
     
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

  
contract NOIconToken{
    using SafeMath for uint256;

    string public constant name = "NOICON Token";
    string public constant symbol = "NO_ICON";
    uint8 public constant decimals = 0;
    uint256 public totalSupply = 100000000000;
    uint256 totalSupply_;

    mapping (address => uint256) balances;
    mapping (bytes => bool) signatures;
    mapping (address => mapping (address => uint256)) internal allowed;

    constructor() public {
        balances[msg.sender] = totalSupply;
    }

     

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

     
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

     
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Error: The address of the receiver is required ");
        require(_value <= balances[msg.sender], "Error: The amount is required");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

     
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

     
     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Error: Address To: is required");
        require(_value <= balances[_from], "Error: Balance must be greater than amount");
        require(_value <= allowed[_from][msg.sender], "Error: Amount allowed must be greater than amount");

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


     

     
    event TransferPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);
    event ApprovalPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);

     
    function transferPreSigned(bytes _signature, address _to, uint256 _value, uint256 _fee, uint256 _nonce) public returns (bool)
    {
        require(_to != address(0), "Error: The address of the receiver is required");
        require(signatures[_signature] == false, "Error: signature is required");
        bytes32 hashedTx = transferPreSignedHashing(address(this), _to, _value, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0), "Error: Address from, is required");
        balances[from] = balances[from].sub(_value).sub(_fee);
        balances[_to] = balances[_to].add(_value);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        signatures[_signature] = true;
        emit Transfer(from, _to, _value);
        emit Transfer(from, msg.sender, _fee);
        emit TransferPreSigned(from, _to, msg.sender, _value, _fee);
        return true;
    }
	
	
      
    function approvePreSigned(bytes _signature, address _spender, uint256 _value, uint256 _fee, uint256 _nonce) public returns (bool)
    {
        require(_spender != address(0), "Error: Spender parametter is requiered");
        require(signatures[_signature] == false, "Error: Signature is required");
        bytes32 hashedTx = approvePreSignedHashing(address(this), _spender, _value, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0), "Error: Address from, is required");
        allowed[from][_spender] = _value;
        balances[from] = balances[from].sub(_fee);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        signatures[_signature] = true;
        emit Approval(from, _spender, _value);
        emit Transfer(from, msg.sender, _fee);
        emit ApprovalPreSigned(from, _spender, msg.sender, _value, _fee);
        return true;
    }
      
    function increaseApprovalPreSigned(bytes _signature, address _spender, uint256 _addedValue, uint256 _fee, uint256 _nonce)
        public returns (bool)
    {
        require(_spender != address(0), "ERROR: Spender address required");
        require(signatures[_signature] == false, "ERROR: Signature required");
        bytes32 hashedTx = increaseApprovalPreSignedHashing(address(this), _spender, _addedValue, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0), "ERROR: From address required");
        allowed[from][_spender] = allowed[from][_spender].add(_addedValue);
        balances[from] = balances[from].sub(_fee);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        signatures[_signature] = true;
        emit Approval(from, _spender, allowed[from][_spender]);
        emit Transfer(from, msg.sender, _fee);
        emit ApprovalPreSigned(from, _spender, msg.sender, allowed[from][_spender], _fee);
        return true;
    }

      
    function decreaseApprovalPreSigned(bytes _signature, address _spender, uint256 _subtractedValue, uint256 _fee, uint256 _nonce)
        public returns (bool)
    {
        require(_spender != address(0), "ERROR: Spender address required");
        require(signatures[_signature] == false, "ERROR: signature required");
        bytes32 hashedTx = decreaseApprovalPreSignedHashing(address(this), _spender, _subtractedValue, _fee, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0), "ERROR: From address required");
        uint oldValue = allowed[from][_spender];
        if (_subtractedValue > oldValue) {
            allowed[from][_spender] = 0;
        } else {
            allowed[from][_spender] = oldValue.sub(_subtractedValue);
        }
        balances[from] = balances[from].sub(_fee);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        signatures[_signature] = true;
        emit Approval(from, _spender, _subtractedValue);
        emit Transfer(from, msg.sender, _fee);
        emit ApprovalPreSigned(from, _spender, msg.sender, allowed[from][_spender], _fee);
        return true;
    }

      
    function transferFromPreSigned(bytes _signature, address _from, address _to, uint256 _value, uint256 _fee, uint256 _nonce)
        public returns (bool)
    {
        require(_to != address(0), "ERROR: Receiver address required");
        require(signatures[_signature] == false, "ERROR: Signature required");
        bytes32 hashedTx = transferFromPreSignedHashing(address(this), _from, _to, _value, _fee, _nonce);
        address spender = recover(hashedTx, _signature);
        require(spender != address(0), "ERROR: Spender address required");
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][spender] = allowed[_from][spender].sub(_value);
        balances[spender] = balances[spender].sub(_fee);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        signatures[_signature] = true;
        emit Transfer(_from, _to, _value);
        emit Transfer(spender, msg.sender, _fee);
        return true;
    }

      
    function transferPreSignedHashing(address _token, address _to, uint256 _value, uint256 _fee, uint256 _nonce)
        public pure returns (bytes32)
    {
         
        return keccak256(bytes4(0x48664c16), _token, _to, _value, _fee, _nonce);
    }

      
    function approvePreSignedHashing(address _token, address _spender, uint256 _value, uint256 _fee, uint256 _nonce)
        public pure returns (bytes32)
    {
         
        return keccak256(bytes4(0xf7ac9c2e), _token, _spender, _value, _fee, _nonce);
    }

      
    function increaseApprovalPreSignedHashing(address _token, address _spender, uint256 _addedValue, uint256 _fee, uint256 _nonce)
        public pure returns (bytes32)
    {
         
        return keccak256(bytes4(0xa45f71ff), _token, _spender, _addedValue, _fee, _nonce);
    }

       
    function decreaseApprovalPreSignedHashing(address _token, address _spender, uint256 _subtractedValue, uint256 _fee, uint256 _nonce)
        public pure returns (bytes32)
    {
         
        return keccak256(bytes4(0x59388d78), _token, _spender, _subtractedValue, _fee, _nonce);
    }

      
    function transferFromPreSignedHashing(address _token, address _from, address _to, uint256 _value, uint256 _fee, uint256 _nonce)
        public pure returns (bytes32)
    {
         
        return keccak256(bytes4(0xb7656dc5), _token, _from, _to, _value, _fee, _nonce);
    }

      
    function recover(bytes32 hash, bytes sig) public pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
         
        if (sig.length != 65) {
            return (address(0));
        }
         

        assembly{
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }   

         
        if (v < 27) {
            v += 27;
        }
         
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
      }
    }
}