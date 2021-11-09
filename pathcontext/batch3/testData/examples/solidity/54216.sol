 
 
 
 
 
 
 
 
 


pragma solidity ^0.4.24;


 
 
 
contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


 
 
 
 
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


 
 
 
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


 

contract UltimosData is SafeMath {
     
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public _totalSupply;
    address public tokenSupplierAddress;

    uint public sellPrice;
    uint public buyPrice;

    bool private dataIsSet;
    
     
    mapping (address => uint) public _balanceOf;

    mapping (address => mapping (address => uint)) public _allowance;
    mapping (address => bool) public _frozenAccount;
    
    constructor() public {
        dataIsSet = false;
        name = "ULTIMOS Token";                                    
        symbol = "ULTIMOS";                                
        decimals = 18;
        _totalSupply = safeMul(1000000000, 10 ** uint256(decimals));   
    }
    
    function setInitialData(address tokenSupplier) public  {
        require(dataIsSet == false);
        tokenSupplierAddress = tokenSupplier;
        _balanceOf[tokenSupplierAddress] = _totalSupply;                 
        dataIsSet = true;
    }


    function balanceOf(address tokenHolder) public constant returns (uint balance) {
        balance = _balanceOf[tokenHolder];
    }
    
    function setBalance(address tokenHolder, uint newBalance) public {
        _balanceOf[tokenHolder] = newBalance;
    }

     function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        remaining = _allowance[tokenOwner][spender];
     }
     
     function setAllowance(address tokenOwner, address spender, uint _value) public {
         _allowance[tokenOwner][spender] = _value;
     }
     
     function setTotalSupply(uint newTotalSupply) public {
         _totalSupply = newTotalSupply;
     }

    function setBuyPrice(uint _buyPrice) public {
        buyPrice = _buyPrice;
    }
    
    function setSellPrice(uint _sellPrice) public {
        sellPrice = _sellPrice;
    }
    
    function frozenAccount(address _acc) public constant returns (bool) {
        return _frozenAccount[_acc];
    }
    
    function setFrozenAccount(address _acc, bool _frozen) public {
        _frozenAccount[_acc] = _frozen;
    }
    
    function setTokenSupplierAddress(address _tsAddress) public {
        tokenSupplierAddress = _tsAddress;
    }
}


interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData)  external; }


contract TokenERC20 is ERC20Interface, SafeMath, Owned {
    UltimosData data;
    
    string public symbol;
    string public name;
    uint8 public decimals;
    

     
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

     
    event Burn(address indexed from, uint256 value);

     
    constructor (
        address dataAddress
    ) public {
        data = UltimosData(dataAddress);
        data.setInitialData(msg.sender);
        
        symbol = data.symbol();
        name = data.name();
        decimals = data.decimals();
    }

    function totalSupply() public constant returns (uint supply) {
        supply = data._totalSupply();
    }

    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        balance = data.balanceOf(tokenOwner);
    }

     function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        remaining = data.allowance(tokenOwner, spender);
     }


     
    function _transfer(address _from, address _to, uint _value) internal {
         
        require(_to != 0x0);
         
        require(balanceOf(_from) >= _value);
         
        require(balanceOf(_to) + _value > balanceOf(_to));
         
        uint previousBalances = safeAdd(balanceOf(_from), balanceOf(_to));
         
        data.setBalance(_from, safeSub(balanceOf(_from), _value));
         
        data.setBalance(_to, safeAdd(balanceOf(_to), _value));
        emit Transfer(_from, _to, _value);
         
        assert(safeAdd(balanceOf(_from), balanceOf(_to)) == previousBalances);
    }

     
    function transfer(address _to, uint256 _value) public returns(bool success) {
        _transfer(msg.sender, _to, _value);
        success = true;
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance(_from, msg.sender));      
        data.setAllowance(_from, msg.sender, safeSub(allowance(_from, msg.sender), _value));
        _transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        data.setAllowance(msg.sender, _spender, _value);
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

     
    function burn(uint256 _value) onlyOwner public returns (bool success) {
        require(balanceOf(data.tokenSupplierAddress()) >= _value);    
        data.setBalance(data.tokenSupplierAddress(), safeSub(balanceOf(data.tokenSupplierAddress()), _value));             
        data.setTotalSupply(safeSub(totalSupply(), _value));                       
        emit Burn(data.tokenSupplierAddress(), _value);
        return true;
    }

     
    function burnFrom(address _from, uint256 _value) onlyOwner public returns (bool success) {
        require(balanceOf(_from) >= _value);                 
        require(_value <= allowance(_from, msg.sender));     
        data.setBalance(_from, safeSub(balanceOf(_from), _value));                          
        data.setAllowance(_from, msg.sender, safeSub(allowance(_from, msg.sender), _value));              
        data.setTotalSupply(safeSub(totalSupply(), _value));                               
        emit Burn(_from, _value);
        return true;
    }
}


 
 
 

contract UltimosToken is TokenERC20 {
    string public _version;
    
     
    event FrozenFunds(address target, bool frozen);

     
    constructor(address dataContract) TokenERC20(dataContract) public {
        _version = "1.0";
        data.setBuyPrice(515350000000000);
        data.setSellPrice(0);
    }

     
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                                
        require (balanceOf(_from) >= _value);                
        require (balanceOf(_to) + _value >= balanceOf(_to));  
        require(!data.frozenAccount(_from));                      
        require(!data.frozenAccount(_to));                        
        data.setBalance(_from, safeSub(balanceOf(_from), _value));                          
        data.setBalance(_to, safeAdd(balanceOf(_to), _value));                            
        emit Transfer(_from, _to, _value);
    }

    function setTokenSupplier(address newTokenSupplierAddress) onlyOwner public {
        _transfer(data.tokenSupplierAddress(), newTokenSupplierAddress, balanceOf(data.tokenSupplierAddress()));
        data.setTokenSupplierAddress(newTokenSupplierAddress);
    }

     
     
     
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        data.setBalance(target, safeAdd(balanceOf(target), mintedAmount));
        data.setTotalSupply(safeAdd(totalSupply(), mintedAmount));
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }

     
     
     
    function freezeAccount(address target, bool freeze) onlyOwner public {
        data.setFrozenAccount(target, freeze);
        emit FrozenFunds(target, freeze);
    }

     
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyOwner {
        data.setSellPrice(newSellPrice);
        data.setBuyPrice(newBuyPrice);
    }

     
    function getPrices() public view returns(uint256, uint256) {
        return (data.sellPrice(), data.buyPrice());
    }

     
    function buy() payable public {
        require(data.buyPrice() > 0);                             
        uint amount = safeDiv(msg.value, data.buyPrice());                
        _transfer(this, msg.sender, amount);               
    }

     
     
    function sell(uint256 amount) public {
        require(data.sellPrice() > 0);
        require(address(this).balance > safeMul(amount, data.sellPrice()));       
        _transfer(msg.sender, this, amount);               
        msg.sender.transfer(safeMul(amount, data.sellPrice()));           
    }


    function () payable public {
        require(msg.sender.balance >= msg.value);
        owner.transfer(msg.value);
    }


    function version() public constant returns(string) {
        return _version;
    }


    function refund(address target, uint256 amount) public onlyOwner {
        uint txAmount = amount > 0 && amount <= address(this).balance
            ? amount
            : address(this).balance;
        require(address(this).balance >= txAmount);
        target.transfer(txAmount);
    }
}


contract UltimosICO is SafeMath, Owned {

    UltimosData data;

    uint public startDate;
    uint public endDate;
    uint public bonusEnds;
    uint8 public bonusPercent;
    bool public isICORunning;

    event Transfer(address indexed from, address indexed to, uint tokens);

    constructor (address dataContract) public {
        startDate = 0;
        endDate = 0;
        bonusEnds = 0;
        bonusPercent = 0;
        isICORunning = false;
        data = UltimosData(dataContract);
    }


    function startICO(uint icoStartDate, uint icoEndDate, uint presaleEndDate, uint8 presalesDiscountPercent) onlyOwner public  {
        require(isICORunning == false);
        startDate = icoStartDate;
        endDate = icoEndDate;
        bonusEnds = presaleEndDate;
        bonusPercent = presalesDiscountPercent;
        isICORunning = true;
    }


    function extendICO(uint extendUntilDate) public onlyOwner {
        require(isICORunning);
        require(endDate < extendUntilDate);
        endDate = extendUntilDate;
    }


    function () public payable {
        require(isICORunning);
        require(startDate > 0 && endDate > 0 && startDate <= endDate);
        require(now <= endDate);
        uint tokens;
        if (now <= bonusEnds) {
            tokens = safeDiv(msg.value, safeSub(data.buyPrice(), safeMul(safeDiv(data.buyPrice(),  100), bonusPercent)));
        } else {
            tokens = safeDiv(msg.value, data.buyPrice());
        }
        data.setBalance(msg.sender, safeAdd(data.balanceOf(msg.sender), tokens));
         
        owner.transfer(msg.value);
        emit Transfer(data.tokenSupplierAddress(), msg.sender, tokens);
    }
}