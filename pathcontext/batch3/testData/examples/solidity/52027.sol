pragma solidity ^0.4.24;

 
contract Controlled {

     
    address public controller;

     
    modifier onlyController { 
        require(msg.sender == controller); 
        _; 
    }

     
    constructor() public { 
        controller = msg.sender;
    }

     
     
    function changeController(address _newController) public onlyController {
        controller = _newController;
    }

}

 
contract ERC20Interface {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
  
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
contract BondWhitelist is Controlled {

     
    mapping(address => bool) whitelisted;

     
     
    function add(address _address) onlyController public {
        whitelisted[_address] = true;
    }

     
     
    function remove(address _address) onlyController public {
        whitelisted[_address] = false;
    }

     
     
    function bulkAdd(address[] _addresses) onlyController public {
        for(uint256 i = 0; i < _addresses.length; i++) {
            whitelisted[_addresses[i]] = true;
        }
    }

     
     
    function bulkRemove(address[] _addresses) onlyController public {
        for(uint256 i = 0; i < _addresses.length; i++) {
            whitelisted[_addresses[i]] = false;
        }
    }

     
     
     
    function isWhitelisted(address _address) public view returns (bool) {
        return whitelisted[_address];
    }

     
    function () public payable {
        revert();
    }

     
     
     
     
    function claimTokens(address _token) public onlyController {
        if (_token == address(0)) {
            controller.transfer(address(this).balance);
            return;
        }

        ERC20Interface token = ERC20Interface(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        emit ClaimedTokens(_token, controller, balance);
    }

    event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);

}