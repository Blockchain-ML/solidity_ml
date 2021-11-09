pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;


 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract IChi is IERC20 {
    function freeUpTo(uint256 value) external returns (uint256 freed);
    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);
}


contract ChiSpender {
    IChi public constant chi = IChi(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    address public owner = msg.sender;

    function burnChi(uint gasSpent) external returns(uint256) {
        require(msg.sender == owner, "Access restricted");
        return chi.freeFromUpTo(tx.origin, (gasSpent + 14154) / 41130);
    }
}