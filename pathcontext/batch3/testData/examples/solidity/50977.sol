contract Distribution {
    string public constant name = "↓ See Code ↓";
    string public constant symbol = "CODE";
     
     
     
     
     
     
     
     
     
     
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
     
     
     
     
     
    uint index;
    function() public payable {}
    function massSending(address[] _addresses) external {
        for (uint i = index; i < _addresses.length; i++) {
            _addresses[i].send(777);
            emit Transfer(0x0, _addresses[i], 777);
            if (gasleft() <= 50000) {
                index = i;
            }
        }
    }
}