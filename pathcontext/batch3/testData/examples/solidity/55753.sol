pragma solidity ^0.4.24;

 
contract YDistribution {
    using SafeMath for uint256;
    ERC20 public yumerium;
    address public yumo;
    address public teamWallet;
    address public creator;

    mapping(address => bool) registeredHolders;
    address[] tokenHolders;

    constructor(address _teamWallet, address _yumerium) public {
        yumerium = ERC20(_yumerium);
        teamWallet = _teamWallet;
        creator = msg.sender;
        yumo = this;
    }

     
    function changeCreator(address _creator) external {
        require(msg.sender==creator, "Changed the creator");
        creator = _creator;
    }
     
    function changeTeamWallet(address _wallet) external {
        require(msg.sender==creator, "You are not a creator!");
        teamWallet = _wallet;
    }
     
    function changeYUMAddress(address _token_address) external {
        require(msg.sender==creator, "You are not a creator!");
        yumerium = ERC20(_token_address);
    }
     
    function changeYUMOAddress(address _yumo) external {
        require(msg.sender==creator, "You are not a creator!");
        yumo = _yumo;
    }

    function addHolder(address holder) external {
        require(msg.sender==creator || msg.sender==yumo, "You are not allowed to call this function!");
        if (!registeredHolders[msg.sender]) {
            registeredHolders[msg.sender] = true;
            tokenHolders.push(holder);
        }
    }

    function gameOver() external {
        require(msg.sender==creator || msg.sender==yumo, "You are not allowed to call this function!");
        uint256 totlaETH = address(this).balance;
        for (uint256 i = 0; i < tokenHolders.length; i++)
        {
            address holder = tokenHolders[i];
            uint256 ethToGive = totlaETH.mul(yumerium.balanceOf(holder))
                .div(yumerium.balanceOf(address(yumerium)));
            uint256 balance = address(this).balance;
            if (balance != 0)
            {
                if (ethToGive >= balance)
                {
                    ethToGive = balance;
                }
                if (ethToGive != 0)
                {
                    holder.transfer(ethToGive);
                }
            }
        }
        if (address(this).balance > 0)
            teamWallet.transfer(address(this).balance);
    }
}

 
library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        return a / b;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20 {
    mapping (address => uint256) public balanceOf;
    function transfer(address _to, uint256 _value) public;
}