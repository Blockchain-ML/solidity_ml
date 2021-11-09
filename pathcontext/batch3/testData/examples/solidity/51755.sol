pragma solidity ^0.4.24;


 
contract DataContract {


	string public message;

	function DataContract() public{
  	}

  	 
  	function wirteData(string _message) public{
  		message = _message;
  	}


  	 
  	function readData() public returns(string){
  		return message;
  	}
  	

}





 
contract ControlContract {

	 
	DataContract  dataContract;

	 
	address private owner;


	 
	function strConcat(string _a, string _b) internal returns (string){
		bytes memory _ba = bytes(_a);
		bytes memory _bb = bytes(_b);
		string memory abcde = new string(_ba.length + _bb.length);
		bytes memory babcde = bytes(abcde);
		uint k = 0;
		for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
		for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
		return string(babcde);
	}



	function ControlContract(address _dataContractAddr) public{
		 
		owner = msg.sender;
		 
		dataContract = DataContract(_dataContractAddr);
  	}
	
	
  	 
	function writeMessage(string _message) public{
		string memory combineStr = "==>銷毀合約測試";
		_message = strConcat(_message, combineStr);
		dataContract.wirteData(_message);

	}


	 
	function readMessage() public returns(string){

		string memory message =  dataContract.readData();
		return message;

	}



	 
	function killContract() public{
		if( owner == msg.sender){
			selfdestruct(owner);
		}
	}
	

	
}