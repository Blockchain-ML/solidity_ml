 
pragma solidity ^0.4.18;

contract GameContract{
	GameBuilder private mainContract;
	constructor() public payable{
		mainContract=GameBuilder(msg.sender); 
	}

	function submit() public returns (bool){
		require(isPass());
		return mainContract.submit();
	}

	function isPass() view returns (bool);
}

contract GameBuilder{
	 
	mapping(address => address) public playContract ;
	 
	mapping(address => bool) public isWinned;
	 
	address[] public winnerList;
	 
	uint public winnerNums=0;

	constructor() public payable{
	}

	function() payable{
	
	}

	function submit() public returns (bool){
		require(playContract[tx.origin] != address(0));
		return isPass(tx.origin);
	}

	function isPass(address _submiter) private returns (bool){
		if (isWinned[_submiter]) {
			return true;
		}
		require(GameContract(playContract[_submiter]).isPass());
		winnerList.push(tx.origin);
		isWinned[tx.origin] = true;
		winnerNums++;
		return true;
	}

	function play() public returns (address){
		if (playContract[tx.origin] == address(0)){
			address a = gameCreate();
			playContract[tx.origin] = a;
		}
		return playContract[tx.origin];
	}
	function gameCreate() public returns (address);
}

 
library SafeMath {
    
     
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

     
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
}

contract Airdrop is GameContract {
    using SafeMath for *;

	mapping(address => uint256)  public balance;
	uint public totalSupply  = 16660;

	modifier isHuman() {
	        address _addr = msg.sender;
	        uint256 _codeLength;
	        assembly {_codeLength := extcodesize(_addr)}
	        require(_codeLength == 0, "sorry humans only");
	        _;
	}

	 
	function airDrop() public isHuman returns (bool) {
		uint256 seed = uint256(keccak256(abi.encodePacked(
            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
            (block.number)
        )));

        if((seed - ((seed / 1000) * 1000)) < 300){
            balance[msg.sender] = balance[msg.sender].add(10);
			totalSupply = totalSupply.sub(10);
			return true;
		}
        else
			return false;
	}

	function isPass() view returns (bool){
		return totalSupply == 0;
	}


}

contract AirdropGameBuilder is GameBuilder{

	function gameCreate() public returns (address){
		Airdrop c=new Airdrop();
		return address(c);
	} 
}