 
 

pragma solidity ^0.4.24;

contract U42 {
	function balanceOf (
			address _owner ) 
		public view returns (
			uint256 );

	function transfer (
			address _to, 
			uint256 _value ) 
		public returns (
			bool );
}

contract U42_Faucet {

	 
	 

	 
	U42 u42c = U42(0xAd186aF79Fb35d4992A636D4C88Db8835C171144);

	function requestTokens() public returns (bool success) {
		 
		 

		 
		uint256 b = u42c.balanceOf(this);

		 
		uint256 giveAmt = b / 1000;

		 
		return u42c.transfer(msg.sender, giveAmt);
	}

}