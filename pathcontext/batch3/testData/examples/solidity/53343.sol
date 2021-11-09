pragma solidity 0.4.25;




 
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() public {
        owner = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }



     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


contract Token {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint value) returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);
   

}


 
contract Airdropper is Ownable {
  
Token public token;
 
   
    function Airdropper(address tokenAddress, uint decimals) public {
        require(decimals <= 77);   

        token = Token(tokenAddress);
        
    }
 
function multisend(address _tokenAddr, address[] _to, uint256[] _value)
    returns (bool _success) {
        assert(_to.length == _value.length);
        assert(_to.length <= 150);
         
        for (uint8 i = 0; i < _to.length; i++) {
                assert((Token(_tokenAddr).transfer(_to[i], _value[i])) == true);
            }
            return true;
        }

   
    function returnTokens() public onlyOwner {
        token.transfer(owner, token.balanceOf(this));
    }

  

     
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
}