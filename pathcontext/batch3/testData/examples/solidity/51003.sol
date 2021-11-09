pragma solidity ^0.4.21;
 
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

 
contract Ownable {
    address public owner;
    address public Publisher;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event PublisherTransferred(address indexed Publisher, address indexed newPublisher);

     
    function Ownable() public {
        owner = msg.sender;
        Publisher = msg.sender;
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

     

    function OwnerAddress() public view returns(address){
        return owner;
    }

     
    function transferPublisher(address newPublisher) public onlyOwner {
        emit PublisherTransferred(Publisher, newPublisher);
        Publisher = newPublisher;
    }

     

    function PublisherAddress() public view returns(address){
        return Publisher;
    }

}


 
contract YDHTOKEN is Ownable{
    using SafeMath for uint256;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    event Setlockaddress(address indexed target, bool lock);
    event Setlockall(uint lock);

    mapping(address => uint256) balances;
    mapping(address => bool) public lockaddress;    
    mapping (address => mapping (address => uint256)) internal allowed;

    uint256 public totalSupply;
    bool public mintingFinished;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public lockall;

    function YDHTOKEN (
        string name_,
        string symbol_,        
        uint256 totalSupply_
    ) public {
        lockall = 1;
        mintingFinished = false;
        decimals = 18;                
        name = name_;
        symbol = symbol_;
        totalSupply = totalSupply_ * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
    }

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    modifier hasMintPermission() {
        require(msg.sender == owner);
        _;
    }

     
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(!lockaddress[msg.sender]);
        if((msg.sender != address(0)) && (msg.sender != PublisherAddress()) && (lockall != 0)){
            revert();
        } 

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(!lockaddress[msg.sender]);
        if((msg.sender != address(0)) && (msg.sender != PublisherAddress()) && (lockall != 0)){
            revert();
        } 

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {
        require(!lockaddress[msg.sender]);
        if((msg.sender != address(0)) && (msg.sender != PublisherAddress()) && (lockall != 0)){
            revert();
        } 

        return allowed[_owner][_spender];
    }

     
    function increaseApproval(
        address _spender,
        uint _addedValue
    )
        public
        returns (bool)
    {
        require(!lockaddress[msg.sender]);
        if((msg.sender != address(0)) && (msg.sender != PublisherAddress()) && (lockall != 0)){
            revert();
        } 
        
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

     
    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
        public
        returns (bool)
    {
        require(!lockaddress[msg.sender]);
        if((msg.sender != address(0)) && (msg.sender != PublisherAddress()) && (lockall != 0)){
            revert();
        }

        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

     
    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }

     
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(!lockaddress[msg.sender]);
        if((msg.sender != address(0)) && (msg.sender != PublisherAddress()) && (lockall != 0)){
            revert();
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

     
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

     
    function burn(address _who, uint256 _value) onlyOwner public {
        _burn(_who, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who]);
         
         

        balances[_who] = balances[_who].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }

     
    function mint(
        address _to,
        uint256 _amount
    )
        hasMintPermission
        canMint
        public
        returns (bool)
    {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

     
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }

     
    function setlockaddress(address target, bool lock) onlyOwner public {
        lockaddress[target] = lock;
        emit Setlockaddress(target, lock);
    }

     
    function setlockall(uint lock) onlyOwner public {
        lockall = lock;
        emit Setlockall(lock);
    }    

}