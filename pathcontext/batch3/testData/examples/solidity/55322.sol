pragma solidity ^0.4.18;

 
 
 
 

contract Splitter {

	address[] public contracts;

	function NewContent(string Content)
    public
    returns(address newContract)
  {
    Contenter c = new Contenter(Content);
    contracts.push(c);
    return c;
  }
}

contract Contenter {

	string public Content;

	constructor (string initContent){
		Content = initContent;
	}



	function getContent()
    public
    constant
    returns (string)
	  {
	    return Content;
	  }   
}