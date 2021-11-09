pragma solidity ^0.4.18;

 
contract Ownable {
    address public owner;
   

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    function Ownable() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }
    
 
 

     
       address private ownerCandidate;
       
        modifier onlyOwnerCandidate() {
        assert(msg.sender == ownerCandidate);
        _;
    }
       
 function transferOwnership(address candidate) external onlyOwner {
        ownerCandidate = candidate;
    }
    function acceptOwnership() external onlyOwnerCandidate {
        owner = ownerCandidate;
    }


}


contract Token{
  function transfer(address to, uint value) returns (bool);
}


contract CashexRedeemWallet is Ownable {

    function multisend(address _tokenAddr, address[] _to, uint256[] _value)
    returns (bool _success) {
        assert(_to.length == _value.length);
        assert(_to.length <= 150);
         
        for (uint8 i = 0; i < _to.length; i++) {
                assert((Token(_tokenAddr).transfer(_to[i], _value[i])) == true);
            }
            return true;
        }

     
     
    function () public payable {
        revert();
    }

}