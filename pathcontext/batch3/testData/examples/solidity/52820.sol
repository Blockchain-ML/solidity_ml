pragma solidity ^0.4.25;

contract AssetManager {
	address[] public contracts;
    address public lastContractAddress;
    
    event newAssetContract(
       address contractAddress
    );

	constructor()
		public
	{

	}

	function getContractCount()
		public
		constant
		returns(uint contractCount)
	{
		return contracts.length;
	}

	 
	function newAsset(string contractHash, uint assetValue, string assetLocation, string assetDescription)
		public
		payable
		returns(address newContract)
	{
		Asset c = (new Asset).value(msg.value)(address(msg.sender), contractHash, assetValue, assetLocation, assetDescription);
		contracts.push(c);
		lastContractAddress = address(c);
		emit newAssetContract(c);
		return c;
	}

	 
	function seeAsset(uint pos)
		public
		constant
		returns(address contractAddress)
	{
		return address(contracts[pos]);
	}
}

contract Asset {
	uint private value;
	address public owner;
	string public ipfsHash;
	string private location;
	string public description;
	enum State { Active, Inactive }
	State public state;
    address[] private pastOwners;
		
	constructor(address contractOwner, string contractHash, uint assetValue, string assetLocation, string assetDescription) public payable {
		owner = contractOwner;
		ipfsHash = contractHash;
		value = assetValue;
		location = assetLocation;
		description = assetDescription;
		state = State.Active;
	}

	modifier condition(bool _condition) {
		require(_condition);
		_;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	modifier inState(State _state) {
		require(state == _state);
		_;
	}

	event Discarded();
	event NewOwner();
	event NewDescription();
	event NewLocation();
	event NewValue();
	
	function discard()
		public
		onlyOwner
		inState(State.Active)
	{
		emit Discarded();
		state = State.Inactive;
	}
	
	function transfer(address newOwner)
		public
		onlyOwner
		inState(State.Active)
	{
		 
		if (newOwner != 0x0){
			emit NewOwner();
			pastOwners.push(owner);
			owner = newOwner;
		}
	}
	
	function updateLocation(string newLocation)
		public
		onlyOwner
		inState(State.Active)
	{
	    emit NewLocation();
        location = newLocation;
	}
	
	function updateDescription(string newDescription)
		public
		onlyOwner
		inState(State.Active)
	{
	    emit NewDescription();
        description = newDescription;
	}
	
	function updateValue(uint newValue)
		public
		onlyOwner
		inState(State.Active)
	{
	    emit NewValue();
        value = newValue;
	}
	
	function getValue()
	    public
	    onlyOwner
	    constant
	    returns(uint assetValue)
	{
	    return value;
	}
	
	function getLocation()
	    public
	    onlyOwner
	    constant
	    returns(string assetLocation)
	{
	    return location;
	}
	
	 
	function seeOwner(uint pos)
		public
		constant
		returns(address oldOwnerAddress)
	{
		return address(pastOwners[pos]);
	}
}