pragma solidity ^0.4.21;

contract GreenX {
    address public adminAddress;
    address public owner;
    function transfer(address _to, uint256 _value) public returns (bool);
    function allocateReservedTokens(address _addr, uint _amount) external;
}

contract GEXAirDrop {
    GreenX public greenx;
    address public greenxAdmin;
    address public owner;
    
    modifier onlyAdmin {
         
        require(greenxAdmin == msg.sender);
        _;
    }
    
    modifier onlyOwnerOrAdmin() {
        require(msg.sender == owner || msg.sender == greenxAdmin);
        _;
    }
    
     
    function GEXAirDrop (address _contract) public {
         
        greenx = GreenX(_contract);
         
        owner = greenx.owner();
        greenxAdmin = greenx.adminAddress();
    }
    
    function batchReservedTokenAllocation(address[] _toAddress, uint256[] _tokenAmount) public onlyOwnerOrAdmin {
         
        uint count = _toAddress.length;
        
        for(uint i = 0; i < count; i++){
            greenx.allocateReservedTokens(_toAddress[i], _tokenAmount[i]);
        }
    }
    
    function batchAirDrop(address[] _to, uint256[] _amount) public   {
        uint count = _to.length;
        
        for(uint i = 0; i < count; i++){
            require(greenx.transfer(_to[i], _amount[i]));
        }
        
    }
    
    function airDrop(address _to, uint256 _amount) public {
        require(greenx.transfer(_to, _amount));
    }
}