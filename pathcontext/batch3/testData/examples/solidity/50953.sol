 

pragma solidity ^0.5.0;
contract Shop {
    
     
     
     
    
     
     
    struct Product
    {
         
        uint64 price;
        
         
        uint64 feePerProduct;
        
         
        uint8 feePercent;
        
         
        bool sellableByProducer;
        
         
        bool sellableByShop;
        
         
        bool downloadable;
    
         
        bool published;
        
         
        bytes32[] bundle;
    }
    
    
     
    struct Producer
    {
         
        mapping(bytes32 => Product) products;
        
         
        bytes32[] productsList;
        
         
        bool alive;
    }
    
     
     
     
    
     
    mapping (address => Producer) producers;
    
     
    address[] producersList;
    
     
    mapping (address => uint) public balances;
    
     
    mapping (address => mapping(address => mapping(bytes32 => bool))) ownings;
    
     
    address shopOwner;
    
     
    bool isShopOnline;
    
     
     
    uint closingTime;
    
     
    bytes32 hashedPassword;
    
     
     
    uint64 public minimalProductPrice;
    
     
     
    uint64 public feeForPriceChange;
    
     
     
    uint64 public feeForPublish;
    
    
     
     
     
    
     
    event Update(address indexed producer, bytes32 indexed productHash);
    
     
    event Buy(address indexed producer, bytes32 indexed productHash, address indexed buyer);
    
     
    event Withdraw(address indexed producer, uint amount);
    
     
    event ClosedWithdraw(address indexed producer, address indexed shopOwner, uint amount);

     
     
     

     
    modifier onlyBy(address _account)
    {
        require(msg.sender == _account);
        _;
    }
    
     
     
    modifier costs(uint _amount) {
        require(isShopOnline);
        require(msg.value >= _amount);
        
        _;
        
        balances[shopOwner] += _amount;
        
        if (msg.value > _amount)
            balances[msg.sender] += (msg.value - _amount);
    }
    
    
     
     
     
    
     
    function Constructor(bytes32 _HashedPassword) public
    {
        shopOwner = msg.sender;
        hashedPassword = _HashedPassword;
        isShopOnline = true;
    }
    
     
     
     
     
     
     
    function publish(bytes32 _productHash, uint64 _price, bool _onTopFeeType) public payable costs(feeForPublish)
    {
         
        require(producers[msg.sender].products[_productHash].published == false);
        require(isShopOnline);
        require(_price >= minimalProductPrice);
        
         
        
        Product memory product;
        
        (product.price, product.feePerProduct) = getPrice(_price, _onTopFeeType, 10);

        product.feePercent = 10;
        product.published = true;
            
        producers[msg.sender].products[_productHash] = product;
        producers[msg.sender].productsList.push(_productHash);
        
        if (producers[msg.sender].alive == false)
        {
            producersList.push(msg.sender);
            producers[msg.sender].alive = true;
        }
        
        emit Update(msg.sender, _productHash);
    }
    
    
     
     
    function setSellable (bytes32 _productHash, bool _sellable) public
    {
        producers[msg.sender].products[_productHash].sellableByProducer = _sellable;
        
        emit Update(msg.sender, _productHash);
    }
    
     
     
    function addBundle (bytes32 _productHash, bytes32 bundle) public
    {
        producers[msg.sender].products[_productHash].bundle.push(bundle);
        
        emit Update(msg.sender, _productHash);
    }
    
     
    function getPrice(uint64 _price, bool _onTopFeeType, uint8 _percent) internal pure returns(uint64, uint64)
    {
        if (_onTopFeeType)
            return(_price, _price*100/(100-_percent)-_price);
        
        return(_price*(100-_percent)/100,_percent*_price/100);
    }
    
     
     
    function setPriceForProduct (bytes32 _productHash , uint64 _newPrice, bool _onTopFeeType) public payable costs(feeForPriceChange)
    {
        require(_newPrice >= minimalProductPrice);
        
        Product storage p  = producers[msg.sender].products[_productHash];
        
        require(p.published == true);
           
        
        (p.price, p.feePerProduct) = getPrice(_newPrice, _onTopFeeType, p.feePercent);
        
        
        emit Update(msg.sender, _productHash);
    }
    
    
     
    function buy(address _producer, bytes32 _productHash) public payable
    {
        Product memory p  = producers[_producer].products[_productHash];
        
        uint64 price = p.price + p.feePerProduct;
        
         
        require(p.sellableByProducer);
        require(p.sellableByShop);
        
         
        require(msg.value >= price);
        
         
        require(isShopOnline);
        
         
        balances[shopOwner] += p.feePerProduct;
        balances[_producer] += p.price;
        
         
        if (msg.value > price)
            balances[msg.sender] += (msg.value - price);
        
         
        ownings[msg.sender][_producer][_productHash] = true;
        
         
        emit Buy(_producer, _productHash, msg.sender);
    }
    
     
    function setFeePercentForProduct (address _producer, bytes32 _productHash , uint8 _newFeePercent) public onlyBy(shopOwner)
    {
        require(_newFeePercent < 31);
        
        Product storage p  = producers[_producer].products[_productHash];
        
        require(p.published == true);
        
        p.feePercent = _newFeePercent;

        p.feePerProduct = p.price*100/(100-_newFeePercent)-p.price;
        
        emit Update(_producer, _productHash);
    }
    
     
    function setFeeForPriceChange (uint64 _newFee) public onlyBy(shopOwner)
    {
        feeForPriceChange = _newFee;
    }
    
     
    function setFeeForPublish (uint64 _newFee) public onlyBy(shopOwner)
    {
        feeForPublish = _newFee;
    }
    
     
    function setSellable (address _producer, bytes32 _productHash, bool _sellable) public onlyBy(shopOwner)
    {
        producers[_producer].products[_productHash].sellableByShop = _sellable;
        
        emit Update(_producer, _productHash);
    }
    
     
    function setDownloadable (address _producer, bytes32 _productHash, bool _downloadable) public onlyBy(shopOwner)
    {
        producers[_producer].products[_productHash].downloadable = _downloadable;
        
        emit Update(_producer, _productHash);
    }
    
     
    function changeShopOwner(address _newShopOwner) public onlyBy(shopOwner)
    {
        shopOwner = _newShopOwner;
    }
    
     
     
    function changeShopOwner(bytes32 _password, bytes32 _newHashedPassword) public
    {
        require(hashedPassword == keccak256(abi.encodePacked(_password)));
        
        
        balances[msg.sender] += balances[shopOwner];
        balances[shopOwner] = 0;
        
        shopOwner = msg.sender;
        
        hashedPassword = _newHashedPassword;
    }
    
     
    function closeShop () public onlyBy(shopOwner)
    {
        isShopOnline = false;
        closingTime = now;
    }
    
     
    function reopenShop () public onlyBy(shopOwner)
    {
        isShopOnline = true;
        closingTime = 0;
    }
    
     
    function withdraw() public 
    {
        uint amount = balances[msg.sender];

        balances[msg.sender] = 0;
    
        emit Withdraw(msg.sender, amount);
        
        msg.sender.transfer(amount);
    }
    
     
     
    function closedWithdraw(address balance) public onlyBy(shopOwner)
    {
        require(isShopOnline == false);
        require(closingTime - 90 days > now);
        
        uint amount = balances[balance];

        balances[balance] = 0;
        
        emit ClosedWithdraw(balance, msg.sender, amount);
        
        msg.sender.transfer(amount);
    }
    
}