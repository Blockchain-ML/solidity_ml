pragma solidity 0.5.1;

contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes memory _data)public;
}


contract ERC223Interface {
    function balanceOf(address who)public view returns (uint);
    function transfer(address to, uint value)public returns (bool success);
    function transfer(address to, uint value, bytes memory data)public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}


 
library safemathlib {
     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract Ownable {
    address payable public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
    constructor() internal{
        owner = msg.sender;
    }


     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


     
    function transferOwnership(address payable newOwner) onlyOwner public {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
     
    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    }

}
contract BlackList is Ownable{
    
    mapping (address => bool) public isBlackListed;
    
    event AddedBlackList(address _user);
    event RemovedBlackList(address _user);
     
    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }
    
    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

}

contract ERC223 is BlackList,ERC223Interface{
    
    using safemathlib for uint256;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    uint256 internal _totalSupply;
    uint public basisPointsRate = 0;
    uint public minimumFee = 0;
    uint public maximumFee = 0;
    
    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    mapping (address => bool) internal isBlackListed;
    
    constructor(string memory name, string memory symbol, uint8 decimals, uint256 totalSupply) public {
        _symbol = symbol;
        _name = name;
        _decimals = decimals;
        _totalSupply = totalSupply;
        balances[msg.sender] = totalSupply;
    }
    
     
     
     
    
     
    event IncreaseSupply(uint amount);
    event DecreaseSupply(uint amount);
    
     
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
    
     
    event Params(uint feeBasisPoints,uint maximumFee,uint minimumFee);
    event DestroyedBlackFunds(address _blackListedUser,uint _balance);
    
     
    function balanceOf(address _address)public view returns(uint256 balance) {
        return balances[_address];
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
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
  
    
    function transfer(address _to, uint256  _value)onlyPayloadSize(2 * 32) public returns (bool success){
        bytes memory empty;
        require(!isBlackListed[msg.sender] && !isBlackListed[_to]);
    
        return transfer(_to,_value,empty);
    }
    
    function transfer(address _to, uint _value, bytes memory _data)onlyPayloadSize(2 * 32) public returns (bool success){
        
        require(!isBlackListed[msg.sender] && !isBlackListed[_to]);
          
        uint codeLength;

        assembly {
             
            codeLength := extcodesize(_to)
        }
        uint fee = calculateFee(_value);
         
        require (_to != address(0x0));
         
        require(_to != address(0));
         
        require (_value > 0);
         
        require (balances[msg.sender] >= _value);
         
        require (balances[_to].add(_value) >= balances[_to]);
         
        uint sendAmount = _value.sub(fee);
         
        balances[msg.sender] = balances[msg.sender].sub(_value);
         
        balances[_to] = balances[_to].add(sendAmount);
         
        if (fee > 0) {
            balances[owner] = balances[owner].add(fee);
            emit Transfer(msg.sender, owner, fee,_data);
        }
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    
    
     
    function calculateFee(uint _amount) internal view returns(uint){
        uint fee = (_amount.mul(basisPointsRate)).div(1000);
        if (fee > maximumFee) {
                fee = maximumFee;
        }
        if (fee < minimumFee) {
            fee = minimumFee;
        }
        return fee;
    }
    
    
     
    function increaseSupply(uint amount) public onlyOwner {
        require(amount <= 10000000);
        amount = amount.mul(10**uint(_decimals));
        require(_totalSupply.add(amount) > _totalSupply);
        require(balances[owner].add(amount) > balances[owner]);
        balances[owner] = balances[owner].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit IncreaseSupply(amount);
    }
    
     
    function decreaseSupply(uint amount) public onlyOwner {
        require(amount <= 10000000);
        amount = amount.mul(10**uint(_decimals));
        require(_totalSupply >= amount);
        require(balances[owner] >= amount);
        _totalSupply = _totalSupply.sub(amount);
        balances[owner] = balances[owner].sub(amount);
        emit DecreaseSupply(amount);
    }
    
      
    function setParams(uint newBasisPoints,uint newMaxFee,uint newMinFee) public onlyOwner {
         
        require(newBasisPoints <= 9);
        require(newMaxFee <= 100);
        require(newMinFee <= 5);
        basisPointsRate = newBasisPoints;
        maximumFee = newMaxFee.mul(10**uint(_decimals));
        minimumFee = newMinFee.mul(10**uint(_decimals));
        emit Params(basisPointsRate, maximumFee, minimumFee);
    }
    
    
    function destroyBlackFunds (address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser]);
        uint dirtyFunds = balances[_blackListedUser];
        balances[_blackListedUser] = 0;
        _totalSupply = _totalSupply.sub(dirtyFunds);
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }

    function withdrawForeignTokens(address _tokenContract) onlyOwner public returns (bool) {
        ERC223Interface token = ERC223Interface(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }
    

     
    function destroy(address payable _owner) public onlyOwner{
        require(_owner == owner);
        selfdestruct(_owner);
    }

}