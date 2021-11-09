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

 

 
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

   
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

   
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

 

 



 
contract BasicAssetToken is Ownable {
     

    using SafeMath for uint256;

 
 
 

    string public name;                  

    uint8 public decimals = 0;           

    string public symbol;                

    string public version = "CRWD_0.1_alpha";  

     
    address public baseCurrency;

     
     
    uint256 public baseRate;

    string public shortDescription;

     
     
     
    struct Checkpoint {

         
        uint128 fromBlock;

         
        uint128 value;
    }

     
     
     
    mapping (address => Checkpoint[]) balances;

     
    mapping (address => mapping (address => uint256)) allowed;

     
    Checkpoint[] totalSupplyHistory;

     
    bool public transfersEnabled = true;

     
    bool public mintingFinished = false;

     
    address public crowdsale;


 
 
 

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    event Burn(address indexed burner, uint256 value);

 
 
 

     
    function setBaseCurrency(address _token) public onlyOwner canMint {
        require(_token != address(0));
        
        baseCurrency = _token;
    }

     
    function setBaseRate(uint256 _baseRate) public onlyOwner canMint {
        baseRate = _baseRate;
    }

     
    function setName(string _name) public onlyOwner canMint {
        name = _name;
    }

     
    function setSymbol(string _symbol) public onlyOwner canMint {
        symbol = _symbol;
    }

     
    function setShortDescription(string _shortDescription) public onlyOwner canMint {
        shortDescription = _shortDescription;
    }

     
    function setCrowdsaleAddress(address _crowdsale) public onlyOwner canMint {
        require(_crowdsale != address(0));

        crowdsale = _crowdsale;
    }


 
 
 

     
     
     
     
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);
        doTransfer(msg.sender, _to, _amount);
        return true;
    }

     
     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);

         
        require(allowed[_from][msg.sender] >= _amount);
        allowed[_from][msg.sender].sub(_amount);

        doTransfer(_from, _to, _amount);
        return true;
    }

     
     
     
     
     
     
    function doTransfer(address _from, address _to, uint256 _amount) internal {

         
        require(_to != address(0));
        require(_to != address(this));

         
         
        uint256 previousBalanceFrom = balanceOfAt(_from, block.number);
        require(previousBalanceFrom >= _amount);

         
         
        updateValueAtNow(balances[_from], previousBalanceFrom.sub(_amount));

         
         
        uint256 previousBalanceTo = balanceOfAt(_to, block.number);
        require(previousBalanceTo + _amount >= previousBalanceTo);  
        
        updateValueAtNow(balances[_to], previousBalanceTo.add(_amount));

         
        emit Transfer(_from, _to, _amount);

    }

     
     
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

     
     
     
     
     
     
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);

         
         
         
         
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

     
     
     
     
     
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

      
     
    function totalSupply() public view returns (uint) {
        return totalSupplyAt(block.number);
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

 
 
 

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

     
     
     
     
    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
        uint256 curTotalSupply = totalSupply();

         
        require(curTotalSupply + _amount >= curTotalSupply); 
        uint256 previousBalanceTo = balanceOf(_to);

         
        require(previousBalanceTo + _amount >= previousBalanceTo); 

        updateValueAtNow(totalSupplyHistory, curTotalSupply.add(_amount));
        updateValueAtNow(balances[_to], previousBalanceTo.add(_amount));

        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);

        return true;
    }

     
     
    function finishMinting() public onlyOwner canMint returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }

 
 
 

     
    function burn(address _who, uint256 _value) public canMint onlyOwner {
        uint256 curTotalSupply = totalSupply();

         
        require(curTotalSupply - _value <= curTotalSupply); 

        uint256 previousBalanceWho = balanceOf(_who);

        require(_value <= previousBalanceWho);

        updateValueAtNow(totalSupplyHistory, curTotalSupply.sub(_value));
        updateValueAtNow(balances[_who], previousBalanceWho.sub(_value));

        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }


 
 
 

     
     
     
     
    function balanceOfAt(address _owner, uint _blockNumber) public view returns (uint256) {
        Checkpoint[] storage checkpoints = balances[_owner];
         
        if (checkpoints.length == 0 || checkpoints[0].fromBlock > _blockNumber) {
            return 0;
        }

         
        if (_blockNumber >= checkpoints[checkpoints.length-1].fromBlock) {
            return checkpoints[checkpoints.length-1].value;
        }

        return getValueAt(balances[_owner], _blockNumber);
    }

     
     
     
    function totalSupplyAt(uint _blockNumber) public view returns(uint) {
         
        if (totalSupplyHistory.length == 0 || totalSupplyHistory[0].fromBlock > _blockNumber) {
            return 0;
        }

         
        if (_blockNumber >= totalSupplyHistory[totalSupplyHistory.length-1].fromBlock) {
            return totalSupplyHistory[totalSupplyHistory.length-1].value;
        }

        return getValueAt(totalSupplyHistory, _blockNumber);
    }

 
 
 

     
     
    function enableTransfers(bool _transfersEnabled) public onlyOwner {
        transfersEnabled = _transfersEnabled;
    }

 
 
 

     
     
     
     
    function getValueAt(Checkpoint[] storage checkpoints, uint _block) view private returns (uint) {
         
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

     
     
     
     
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint256 _value) internal {
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length-1].fromBlock < block.number)) {
            Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
            newCheckPoint.fromBlock = uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {  
            Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
            oldCheckPoint.value = uint128(_value);
        }
    }

}