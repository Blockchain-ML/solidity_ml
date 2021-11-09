pragma solidity ^0.4.24;

contract KyberNetworkProxy  {
    function swapTokenToToken(ERC20 src, uint srcAmount, ERC20 dest, uint minConversionRate) public returns(uint);
    function swapEtherToToken(ERC20 token, uint minConversionRate) public payable returns(uint);
    function swapTokenToEther(ERC20 token, uint srcAmount, uint minConversionRate) public returns(uint);
    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public view returns(uint expectedRate, uint slippageRate);
}

contract ERC20 {
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

contract SwapTokenToToken {

    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

     
    function execSwap(
        KyberNetworkProxy proxy, 
        ERC20 srcToken, 
        uint256 srcQty, 
        ERC20 destToken, 
        address destAddress
    ) public payable returns (uint) {

         
        require(srcToken.transferFrom(msg.sender, this, srcQty));

         
        require(srcToken.approve(proxy, srcQty));

        (uint minConversionRate,) = proxy.getExpectedRate(srcToken, ETH_TOKEN_ADDRESS, srcQty);

         
        uint destAmount = proxy.swapTokenToToken(srcToken, srcQty, destToken, minConversionRate);

         
        require(destToken.transfer(destAddress, destAmount));

        return destAmount;
    }
}