pragma solidity 0.4.24;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) return 0;
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

contract TESTToken {
    using SafeMath for uint256;

     
     

     
     
    uint256 public constant OPENING_RATE = 7143;

     
     
     
    address public NEUREAL_ETH_WALLET;

     
     
     
    address public WHITELIST_PROVIDER;

     
    uint256 public constant MAX_SALE = 700 * 10**18;  
    uint256 public constant MIN_PURCHASE = 7 * 10**18;  
    uint256 public constant MAX_ALLOCATION = 50 * 10**18;  
    uint256 public constant MAX_SUPPLY = MAX_SALE + MAX_ALLOCATION;  
     
    uint256 public constant MAX_WEI_WITHDRAWAL = (70 * 10**18) / OPENING_RATE;  

    address public owner_;                   

    mapping(address => bool) public whitelist_;

    uint256 private totalSale_ = 0;          
    function totalSale() external view returns (uint256) {
        return totalSale_;
    }
    uint256 private totalWei_ = 0;           
    function totalWei() external view returns (uint256) {
        return totalWei_;
    }
    uint256 public weiWithdrawn_ = 0;        

    uint256 public totalRefunds_ = 0;        
    mapping(address => uint256) public pendingRefunds_;

    uint256 public totalAllocated_ = 0;     

    enum Phase {
        BeforeSale,
        Sale,
        Finalized
    }
    Phase public phase_ = Phase.BeforeSale;


     
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event TokenPurchase(uint256 _totalTokenSold, uint256 _totalWei);
    event Refunded(address indexed _who, uint256 _weiValue);
    event SaleStarted();
    event Finalized();


     

    string public constant name = "Neureal TGE Test";
    string public constant symbol = "TEST";
    uint8 public constant decimals = 18;

    uint256 private totalSupply_ = 0;
    function totalSupply() external view returns (uint256) {
        return totalSupply_;
    }
    
    mapping(address => uint256) private balances_;
    function balanceOf(address _who) external view returns (uint256) {
        return balances_[_who];
    }
    
    function transfer(address _to, uint256 _value) external returns (bool) {
         
        revert();  
         
         
         
        return false;  
    }


     

     
     
    constructor(address _NEUREAL_ETH_WALLET, address _WHITELIST_PROVIDER) public {
        owner_ = msg.sender;
        NEUREAL_ETH_WALLET = _NEUREAL_ETH_WALLET;  
        WHITELIST_PROVIDER = _WHITELIST_PROVIDER;  
    }


     

     
    function whitelist(address _who) external {
        require(phase_ != Phase.Finalized);                 
        require(msg.sender == WHITELIST_PROVIDER);           
        whitelist_[_who] = true;
         
    }
     
    function whitelistMany(address[] _who) external {
        require(phase_ != Phase.Finalized);                 
        require(msg.sender == WHITELIST_PROVIDER);           
        for (uint256 i = 0; i < _who.length; i++) {
            whitelist_[_who[i]] = true;
        }
    }
     
    function whitelistRemove(address _who) external {
        require(phase_ != Phase.Finalized);                 
        require(msg.sender == WHITELIST_PROVIDER);           
        whitelist_[_who] = false;
    }

     
    function() external payable {
        require(phase_ == Phase.Sale);                      
        require(msg.value != 0);                             
        require(msg.sender != address(0));                   
        require(msg.sender != address(this));                
        require(whitelist_[msg.sender]);                     
         
        
        uint256 tokens = msg.value.mul(OPENING_RATE);

        require(tokens >= MIN_PURCHASE);                     

        uint256 newTotalSale = totalSale_.add(tokens);
        require(newTotalSale <= MAX_SALE);                   
        uint256 newTotalSupply = totalSupply_.add(tokens);
        require(newTotalSupply <= MAX_SUPPLY);                

        balances_[msg.sender] = balances_[msg.sender].add(tokens);
        totalSupply_ = newTotalSupply;
        totalSale_ = newTotalSale;

        totalWei_ = totalWei_.add(msg.value);
         

        emit Transfer(address(0), msg.sender, tokens);
        emit TokenPurchase(totalSale_, totalWei_);
    }
    
     
    function withdraw() external {
        require(msg.sender == owner_);                       
        uint256 withdrawalValue = address(this).balance.sub(totalRefunds_);
        if (phase_ != Phase.Finalized) {
            uint256 newWeiWithdrawn = weiWithdrawn_.add(withdrawalValue);
            if (newWeiWithdrawn > MAX_WEI_WITHDRAWAL) {
                withdrawalValue = MAX_WEI_WITHDRAWAL.sub(weiWithdrawn_);  
                require(withdrawalValue != 0);               
                newWeiWithdrawn = MAX_WEI_WITHDRAWAL;
            }
            weiWithdrawn_ = newWeiWithdrawn;
        }
        
        NEUREAL_ETH_WALLET.transfer(withdrawalValue);        
         
    }


     

     
    function refund(address _who) external payable {
        require(phase_ == Phase.Sale);              
        require(msg.sender == owner_);               
        require(_who != address(0));                 
        require(balances_[_who] != 0);               
        require(pendingRefunds_[_who] == 0);         
        
        uint256 tokenValue = balances_[_who];
        uint256 weiValue = tokenValue.div(OPENING_RATE);
        assert(weiValue != 0);                        

        require(address(this).balance >= weiValue);   
        totalRefunds_ = totalRefunds_.add(weiValue);
        pendingRefunds_[_who] = weiValue;

        totalSupply_ = totalSupply_.sub(tokenValue);
        totalSale_ = totalSale_.sub(tokenValue);
        balances_[_who] = 0;

        emit Transfer(_who, address(0), tokenValue);
    }
     
    function sendRefund(address _who) external {
        require(pendingRefunds_[_who] != 0);          

        uint256 weiValue = pendingRefunds_[_who];
        pendingRefunds_[_who] = 0;
        totalRefunds_ = totalRefunds_.sub(weiValue);
        emit Refunded(_who, weiValue);
        
        _who.transfer(weiValue);
         
    }
    
    
     
    
     
    function allocate(address _to, uint256 _value) external {
        require(phase_ != Phase.Finalized);         
        require(msg.sender == owner_);               
        require(_value != 0);                        
        require(_to != address(0));                  
        require(_to != address(this));               

        uint256 newTotalAllocated = totalAllocated_.add(_value);
        require(newTotalAllocated <= MAX_ALLOCATION);  
        uint256 newTotalSupply = totalSupply_.add(_value);
        require(newTotalSupply <= MAX_SUPPLY);     
        
        balances_[_to] = balances_[_to].add(_value);
        totalSupply_ = newTotalSupply;
        totalAllocated_ = newTotalAllocated;

        emit Transfer(address(0), _to, _value);
    }
    
    
     

     
    function transition() external {
        require(phase_ != Phase.Finalized);         
        require(msg.sender == owner_);               
        
        if (phase_ == Phase.BeforeSale) {
            phase_ = Phase.Sale;
            emit SaleStarted();
        } else if (phase_ == Phase.Sale) {
            phase_ = Phase.Finalized;
            emit Finalized();
        }
    }

}

 