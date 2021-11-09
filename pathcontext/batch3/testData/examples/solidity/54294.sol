pragma solidity ^0.4.24;

contract TwogapContract {
    uint256 internal initialSupply = 210000000000e18;

    uint256 constant companyTokens = 31500000000e18;
    uint256 constant teamTokens = 31500000000e18;
    uint256 constant crowdsaleTokens = 69300000000e18;
    uint256 constant bountyTokens = 84000000000e18;
    uint256 constant mintingTokens = 69300000000e18;

    address company = 0x039a4c3a8014182d280bC49597F8aB66001B5e90;
    address team = 0x43285E497D1E57aBd161a26315EE7e58445f4CE6;
    address crowdsale = 0x5C0DF0a7BeA5dBc3a6e82AC37A8d9498C288a620;
    address bounty = 0x36D7a3C8d915Bd12bF30559195a7B33dde6CeB81;
    address minting = 0x9D8434F8177F7ECa84bD14749A6D23bDFc7A5BED;

    uint256 public totalSupply;
    uint8 constant public decimals = 18;
    string constant public name = "Twogap";
    string constant public symbol = "TGT";

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Burn(address indexed from, uint256 value);
    
    constructor() public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
         
         
         
         
         
         
    }

    function preSale(address _address, uint _amount) internal returns (bool) {
        balanceOf[_address] = _amount;
         
    }

     
    
     
    function _transfer(address _from, address _to, uint _value) internal {
         
        require(_to != 0x0);
         
        require(balanceOf[_from] >= _value);
         
        require(balanceOf[_to] + _value >= balanceOf[_to]);
         
        uint previousbalanceOf = balanceOf[_from] + balanceOf[_to];
         
        balanceOf[_from] -= _value;
         
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
         
        assert(balanceOf[_from] + balanceOf[_to] == previousbalanceOf);
    }

     
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
    
     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);      
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

     
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);    
        balanceOf[msg.sender] -= _value;             
        totalSupply -= _value;                       
        emit Burn(msg.sender, _value);
        return true;
    }

     
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                 
        require(_value <= allowance[_from][msg.sender]);     
        balanceOf[_from] -= _value;                          
        allowance[_from][msg.sender] -= _value;              
        totalSupply -= _value;                               
        emit Burn(_from, _value);
        return true;
    }
}