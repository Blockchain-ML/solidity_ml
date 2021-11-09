pragma solidity ^0.4.24;


contract Demo {

	string public message;

	

  	function Demo() {
  		message = "";
  	}

  	 
  	function writeMessage(string _message) public {
  		message = _message;
  	}

  	 
  	function readMessage() public view returns(string){
  		return message;
  	}
  	



  	 
  	event EditMessageEvent(address _bidder, string _message);
  	 
  	function editMessage(string _message) public{
  		message = _message;
  		 
  		emit EditMessageEvent(msg.sender, _message);
  	}
	

  	

  	 
  	event PayEtherEvent(address _bidder, uint _amount);
  	 
    function payEther() public payable{ 
    	require (msg.value > 0);

    	 
    	emit PayEtherEvent(msg.sender, msg.value);


    }
  	


}