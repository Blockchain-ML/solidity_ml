 

pragma solidity ^0.4.25;



 
library SafeMath256 {
     
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
}


 
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = msg.sender;
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

   
}


 
interface IERC20{
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}


 
contract BatchTransfer is Ownable{

using SafeMath256 for uint256;
uint8 public constant decimals = 18;
uint256 public constant decimalFactor = 10 ** uint256(decimals);
uint256 public  ceshi = 0;

function batchTtransferEther(address[] _to,uint256[] _value) public payable {
     require(_to.length>0);
     require(_value.length>0);
     require(_to.length==_value.length);
     
    for(uint256 i=0;i<_to.length;i++)
    {
        _to[i].transfer(_value[i]);
    }
}


function batchTtransferEtherToNum(address[] _to,uint256[] _value) public payable {
     require(_to.length>0);
     require(_value.length>0);
     require(_to.length==_value.length);
     uint256 _values=0;
     
    for(uint256 i=0;i<_to.length;i++)
    {
        _values=_value[i] * decimalFactor;
        _to[i].transfer(_values);
    }
}


     
    function batchTransferAgileToken(address[] accounts,uint256[] _value,address caddress) public {
        IERC20 VOKEN = IERC20(caddress);
        for (uint256 i = 0; i < accounts.length; i++) {
            VOKEN.transferFrom(msg.sender, accounts[i], _value[i]);
        }
    }
    
 

}