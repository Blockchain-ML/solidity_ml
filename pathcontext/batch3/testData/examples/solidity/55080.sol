pragma solidity 0.4.25;

 
contract Justice {
    function disagree(address) public payable {}
}

contract Disagree {
    address constant jadd = 0xc4e88842d7263D577E39C7216c78567909B74777;
    Justice constant jc = Justice(jadd);

    function() public payable {
        jc.disagree.value(msg.value)(msg.sender);
    }
}