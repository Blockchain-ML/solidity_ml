pragma solidity ^0.4.18;

 
 
contract Mintable {
    function mintToken(address to, uint amount) external returns (bool success);  
    function setupMintableAddress(address _mintable) public returns (bool success);
}

contract ApproveAndCallReceiver {
    function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData);    
}

contract Token {

     
    uint256 public totalSupply;

     
     
    function balanceOf(address _owner) public view returns (uint256 balance);

     
     
     
     
    function transfer(address _to, uint256 _value) public returns (bool success);

     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

     
     
     
     
    function approve(address _spender, uint256 _value) public returns (bool success);

     
     
     
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
         
        require(balances[_to] + _value >= balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
         
        require(balances[_to] + _value >= balances[_to]);          
        balances[_to] += _value;    
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }  

        Transfer(_from, _to, _value);
        return true; 
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
}


 
contract FlowchainToken is StandardToken, Mintable {

     
    string public name = "FlowchainCoin";
    string public symbol = "FLC";    
    uint8 public decimals = 18;
    string public version = "1.0";
    address public mintableAddress;
    address public multiSigWallet;    
    address public creator;

    function() payable { revert(); }

    function FlowchainToken() public {
         
        totalSupply = 10**27;                   
        creator = msg.sender;
        mintableAddress = 0x9581973c54fce63d0f5c4c706020028af20ff723;
        multiSigWallet = 0x9581973c54fce63d0f5c4c706020028af20ff723;        
         
        balances[multiSigWallet] = totalSupply;  
        Transfer(0x0, multiSigWallet, totalSupply);
    }

    function setupMintableAddress(address _mintable) public returns (bool success) {
        require(msg.sender == creator);    
        mintableAddress = _mintable;
        return true;
    }

     
     
     
     
    function mintToken(address to, uint256 amount) external returns (bool success) {
        require(msg.sender == mintableAddress);
        require(balances[multiSigWallet] >= amount);
        balances[multiSigWallet] -= amount;
        balances[to] += amount;
        Transfer(multiSigWallet, to, amount);
        return true;
    }

     
     
    function getCreator() constant returns (address) {
        return creator;
    }

     
     
    function getMintableAddress() constant returns (address) {
        return mintableAddress;
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) external returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

         

        ApproveAndCallReceiver(_spender).receiveApproval(msg.sender, _value, this, _extraData);

        return true;
    }
}