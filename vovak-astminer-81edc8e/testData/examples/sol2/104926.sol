pragma solidity ^0.6.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

 
contract TokenTimelock {
     
    IERC20 public token;

     
    address public beneficiary;

     
    uint256 public releaseTime;

    constructor () public {
        token = IERC20(0x309013d55fB0E8C17363bcC79F25d92f711A5802);
        beneficiary = 0xD7A57c0f01286C3b62F3CD3c8e184Ce6D6E7904e;
        releaseTime = block.timestamp + 730 days;
    }

     
    function release() public virtual {
        require(block.timestamp >= releaseTime, "TokenTimelock: current time is before release time");

        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        token.transfer(beneficiary, amount);
    }
}