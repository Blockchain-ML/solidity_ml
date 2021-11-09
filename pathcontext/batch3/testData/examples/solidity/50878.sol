pragma solidity ^0.4.23;


 
library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
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

     
    function balanceOf(address _owner) public view returns (uint256 balance) {
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

 
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


     
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

     
    modifier whenPaused() {
        require(paused);
        _;
    }

     
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

     
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}


 
contract PausableToken is StandardToken, Pausable {

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}


contract  Lock is PausableToken{

    mapping(address => uint256) public locked; 
    mapping(address => uint256) public teamLockTime;  
    mapping(address => uint256) public fundLockTime;  
    mapping(address => uint256) public used;    

    function teamAvailable(address _to) internal constant returns (uint256) {
        uint256 now1 = block.timestamp;
        uint256 lockTime = teamLockTime[_to];
        uint256 time = now1 - lockTime;
        uint256 percent = 0;
        percent =  (time / 30 days) + 1;
        percent = percent > 12 ? 12 : percent;
        uint256 avail = locked[_to];
        avail = avail.mul(percent);
        avail = avail.div(12);
        avail = avail.sub(used[_to]);
        return avail ;
    }

    function fundAvailable(address _to) internal constant returns (uint256) {
        uint256 now1 = block.timestamp;
        uint256 lockTime = fundLockTime[_to];
        uint256 time = now1 - lockTime;
        uint256 percent = 250;
        if(time >= 3 days) {
            percent += (((time - 3 days) / 1 days)  + 1) * 5;
        }
        percent = percent > 1000 ? 1000 : percent;
        uint256 avail = locked[_to];
        avail = avail.mul(percent);
        avail = avail.div(1000);
        avail = avail.sub(used[_to]);
        return avail ;
    }

    function teamLock(address _to,uint256 _value) internal {
        locked[_to] = locked[_to].add(_value);
        teamLockTime[_to] = block.timestamp;   
    }
    function fundLock(address _to,uint256 _value) internal {
        locked[_to] = locked[_to].add(_value);
        fundLockTime[_to] = block.timestamp;   
    }

    function teamLockTransfer(address _to, uint256 _value) internal returns (bool) {
        uint256 avail1 = teamAvailable(msg.sender);
        uint256 avail2 = balances[msg.sender].add(used[msg.sender]).sub(locked[msg.sender]);
        uint256 totalAvail = avail1.add(avail2);
        require(_value <= totalAvail);
        bool ret = super.transfer(_to,_value);
        if(ret == true) {
            if(_value > avail2){
                used[msg.sender] = used[msg.sender].add(_value).sub(avail2);
            }
        }
        if(used[msg.sender] >= locked[msg.sender]){
            delete teamLockTime[msg.sender];
        }
        return ret;
    }

    function teamLockTransferFrom(address _from,address _to, uint256 _value) internal returns (bool) {
        uint256 avail1 = teamAvailable(_from);
        uint256 avail2 = balances[_from].add(used[_from]).sub(locked[_from]);
        uint256 totalAvail = avail1.add(avail2);
        require(_value <= totalAvail);
        bool ret = super.transferFrom(_from,_to,_value);
        if(ret == true) {
            if(_value > avail2){
                used[_from] = used[_from].add(_value).sub(avail2);
            }
        }
        if(used[_from] >= locked[_from]){
            delete teamLockTime[_from];
        }
        return ret;
    }

    function fundLockTransfer(address _to, uint256 _value) internal returns (bool) {
        uint256 avail1 = fundAvailable(msg.sender);
        uint256 avail2 = balances[msg.sender].add(used[msg.sender]).sub(locked[msg.sender]);
        uint256 totalAvail = avail1.add(avail2);
        require(_value <= totalAvail);
        bool ret = super.transfer(_to,_value);
        if(ret == true) {
            if(_value > avail2){
                used[msg.sender] = used[msg.sender].add(_value).sub(avail2);
            }
        }
        if(used[msg.sender] >= locked[msg.sender]){
            delete fundLockTime[msg.sender];
        }
        return ret;
    }

    function fundLockTransferFrom(address _from,address _to, uint256 _value) internal returns (bool) {
        uint256 avail1 = fundAvailable(_from);
        uint256 avail2 = balances[_from].add(used[_from]).sub(locked[_from]);
        uint256 totalAvail = avail1.add(avail2);
        require(_value <= totalAvail);
        bool ret = super.transferFrom(_from,_to,_value);
        if(ret == true) {
            if(_value > avail2){
                used[_from] = used[_from].add(_value).sub(avail2);
            }
        }
        if(used[_from] >= locked[_from]){
            delete fundLockTime[_from];
        }
        return ret;
    }
}


contract HitToken is Lock {
    string public name;
    string public symbol;
    uint8 public decimals;


    function HitToken(string _name, string _symbol, uint8 _decimals, uint256 _initialSupply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply_ = _initialSupply * 10 ** uint256(_decimals);
    }

    function burn(uint256 _value) public onlyOwner returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[address(0)] = balances[address(0)].add(_value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        if(teamLockTime[msg.sender] > 0){
            return super.teamLockTransfer(_to,_value);
        }else if(fundLockTime[msg.sender] > 0){
            return super.fundLockTransfer(_to,_value);
        }else {
            return super.transfer(_to, _value);
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if(teamLockTime[_from] > 0){
            return super.fundLockTransferFrom(_from,_to,_value);
        }else if(fundLockTime[_from] > 0 ){
            return super.fundLockTransferFrom(_from,_to,_value);
        }else{
            return super.transferFrom(_from, _to, _value);
        }
    }

    function mintTeam(address _to, uint256 _value) public onlyOwner returns (bool){
        super.transfer(_to,_value);
        teamLock(_to,_value);
    }

    function mintFund(address _to, uint256 _value) public onlyOwner returns (bool){
        super.transfer(_to,_value);
        fundLock(_to,_value);
    }
}