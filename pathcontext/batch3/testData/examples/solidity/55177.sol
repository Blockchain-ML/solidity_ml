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

contract MultiOwner {
	event OwnerAdded(address newOwner);
    event OwnerRemoved(address oldOwner);
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    mapping (address => bool) public isOwner;
	address[] owners;
	
     
	modifier validAddress(address _address) {
        assert(0x0 != _address);
        _;
    }
	
     
    modifier onlyOwner {
		require(isOwner[msg.sender]);
        _;
    }
	
	 
	modifier ownerDoesNotExist(address owner) {
		require(!isOwner[owner]);
        _;
    }

	 
    modifier ownerExists(address owner) {
		require(isOwner[owner]);
        _;
    }
	
     
    constructor() public{
		isOwner[msg.sender] = true;
        owners.push(msg.sender);
    }

	 
	function numberOwners() public constant returns (uint256 NumberOwners){
	    NumberOwners = owners.length;
	}
	
	 
	function addOwner(address owner) onlyOwner validAddress(owner) ownerDoesNotExist(owner) external{
        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAdded(owner);
    }
	
	 
	function removeOwner(address owner) onlyOwner ownerExists(owner) external{
		require(owners.length > 1);
        isOwner[owner] = false;
        for (uint256 i=0; i<owners.length - 1; i++){
            if (owners[i] == owner) {
				owners[i] = owners[owners.length - 1];
                break;
            }
		}
		owners.length -= 1;
        emit OwnerRemoved(owner);
    }
	
	 
	function kill() public onlyOwner(){
		selfdestruct(msg.sender);
    }
}

 
 
contract ERC20 {
    function balanceOf(address _who) public view returns (uint256);
	function allowance(address _owner, address _spender) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
	function approve(address _spender, uint256 _value) public returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract AsiaPacific is ERC20, MultiOwner{
	using SafeMath for uint256;
	
	event SingleTransact(address owner, uint value, address to, bytes data);
	event Burn(address indexed _account, uint256 _value);
	event FrozenFunds(address target, bool frozen);
	
	string public name = "Asia Pacific Cipher Chain";
	string public symbol = "APCC";
	uint8 public decimals = 8;
	uint256 public decimalFactor = 10 ** uint256(decimals);
	uint256 public totalSupply = 2000000000 * decimalFactor;

	mapping(address => uint256) private balances;
	mapping (address => mapping (address => uint256)) private allowed;
	mapping(address => bool) public frozenAccount;
	
	 
	constructor() MultiOwner() public {
		balances[msg.sender] = totalSupply;                    
    }
	
	 
	function() public payable{
        revert();
    }
	
	 
	function execute(address _to, uint _value, bytes _data) external onlyOwner {
		emit SingleTransact(msg.sender, _value, _to, _data);
		require(_to.call.value(_value)(_data));
    }

	 
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}
	
	 
	function allowance(address _owner, address _spender) public view returns (uint256){
		return allowed[_owner][_spender];
	}
  
	 
	function _transfer(address _from, address _to, uint256 _value) validAddress(_from) validAddress(_to) internal{
		require (!frozenAccount[_from]); 						 
        require (balances[_from] >= _value);                	 
        require (balances[_to] + _value >= balances[_to]); 	 
                            
        balances[_from] = balances[_from].sub(_value);         
        balances[_to] = balances[_to].add(_value);             
        emit Transfer(_from, _to, _value);
    }
	
	 
	function transfer(address _to, uint256 _value) validAddress(_to) public returns (bool) {
		_transfer(msg.sender, _to, _value);
		return true;
	}
	
	 
	function approve(address _spender, uint256 _value) public returns (bool) {
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}
  
	 
	function transferFrom(address _from, address _to, uint256 _value) validAddress(_from) validAddress(_to) public returns (bool success) {
		require(_value <= allowed[_from][msg.sender]);
		_transfer(_from, _to, _value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		return true;
    }

	 
     
     
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20(tokenAddress).transfer(msg.sender, tokens);
    }
	
	 
	function burn(address _account, uint256 _value) validAddress(_account) onlyOwner internal{
		require(balances[_account] >= _value);
		balances[_account] = balances[_account].sub(_value);
		balances[msg.sender] = balances[msg.sender].add(_value);
		emit Burn(_account, _value);
	}

	 
	function freezeAccount(address target, bool freeze) onlyOwner internal {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

	 
	 
	function EcRecover(bytes32 hash, bytes _signature) public pure returns (address recoveredAddress) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        if (_signature.length != 65) return address(0);
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }
		
        if (v < 27) {
          v += 27;
        }
        if (v != 27 && v != 28) return address(0);
        return ecrecover(hash, v, r, s);
    }
	
	 
	function getTransferHash(address _contract, address _to, uint _value, uint _fee, uint _nonce) public pure returns(bytes32 txHash){
        txHash = keccak256(abi.encodePacked(_contract, _to, _value, _fee, _nonce));
    }

	 
	function transferPreSigned(bytes _signature, address _to, uint256 _value, uint256 _fee, uint256 _nonce) validAddress(_to) public returns (bool){
        bytes32 hashedTx = getTransferHash(address(this), _to, _value, _fee, _nonce);

        address _from = EcRecover(hashedTx, _signature);
		require(0x0 != _from);
		require (balances[_from] >= _value.add(_fee));
		
        balances[_from] = balances[_from].sub(_value).sub(_fee);
        balances[_to] = balances[_to].add(_value);
        balances[msg.sender] = balances[msg.sender].add(_fee);

        emit Transfer(_from, _to, _value);
        emit Transfer(_from, msg.sender, _fee);
        return true;
    }

	 
	function isContract(address addr) public view returns (bool) {
		uint size;
		assembly { size := extcodesize(addr) }
		return size > 0;
	}
}