pragma solidity ^0.4.25;
interface ERC20 {
    function allowance(address _tokenOwner, address _tokenSpender) external view returns(uint);
    function transferFrom(address _from, address _to, uint _value) external returns(bool);
    event Transfer(address indexed _from, address indexed _to, uint _value);
}

contract MyIntermediary {
     
    address reference;  
    address public seller;  
    address public instantToken;  
    mapping(address => uint) rates;  
    
    event Sold(address indexed _from, address indexed _to, address indexed _token, uint _amount);
    event Paid(address indexed _payer, address indexed _seller, uint _amount);
    event Returned(address indexed _seller, address indexed _payer, uint _amount);
    
    constructor(address _reference, address _tokenSeller, address _instantToken, uint _instantRate) public {
        reference = _reference;
        seller = _tokenSeller;
        instantToken = _instantToken;
        rates[_instantToken] = _instantRate;
    }
    
    modifier onlySeller() {
        require(msg.sender == seller, "Limited function for use by seller!");
        _;
    }
    
    function buyable(address token) public view returns(uint) {
         
        return ERC20(token).allowance(seller, address(this));
    }
    function perETH(address token) public view returns(uint) {
         
         
        return rates[token];
    }
    
    function buy(address token) public payable returns(bool) {
         
         
        require(address(0) != token, "Invalid Token address!");
        require(msg.value > 1 szabo, "Minimum transaction is 0.000001 ETH!");
        require(rates[token] > 0, "Undefined token price!");
        uint paymentValue = msg.value;  
        uint amount = msg.value * rates[token];  
        uint returnValue = 0;  
        uint available = buyable(token);  
        require(available > 0, "Out of Stock!");
        require(amount > 0, "Amaunt less than allowed!");
        if (amount > available) {
             
             
            amount = available;
             
            returnValue = paymentValue - (amount / rates[token]);
            paymentValue -= returnValue;
        }
        if (!ERC20(token).transferFrom(seller, msg.sender, amount)) revert("Failed when sending token to your wallet!");
        if (returnValue > 0) {
             
            msg.sender.transfer(returnValue);
            emit Returned(seller, msg.sender, returnValue);
        }
        seller.transfer(paymentValue);  
        emit Paid(msg.sender, seller, amount);
        emit Sold(seller, msg.sender, token, amount);
        return true;
    }
    function() public payable {
         
         
        require(msg.value > 1 szabo, "Minimum transaction is 0.000001 ETH!");
        buy(instantToken);
    }
    
     
    function setRate(address token, uint newRate) public onlySeller returns(bool) {
        require(token != address(0), "Invalid token address!");
        rates[token] = newRate;
        return true;
    }
    function setSeller(address newSeller) public onlySeller returns(bool) {
        require(newSeller != address(0) && address(this) != newSeller);
        seller = newSeller;
        return true;
    }
    function setInstantToken(address _newInstantToken) public onlySeller returns(bool) {
        require(_newInstantToken != address(0) && rates[_newInstantToken] > 0);
        instantToken = _newInstantToken;
        return true;
    }
}

contract IntermediaryDeployer {
    address contractReference = address(0);
    
    event Created(address indexed _contractAddress, address indexed _sellerAddress);
    
    function setReference(address newContractReference) public returns(bool) {
        require(contractReference == address(0) && newContractReference != address(0) && address(this) != newContractReference);
        contractReference = newContractReference;
        return true;
    }
    
    function create(address _seller, address _instantToken, uint _instantTokenRate) public returns(address) {
        address newIntermediary = address(new MyIntermediary(contractReference, _seller, _instantToken, _instantTokenRate));
        emit Created(newIntermediary, _seller);
        return newIntermediary;
    }
}