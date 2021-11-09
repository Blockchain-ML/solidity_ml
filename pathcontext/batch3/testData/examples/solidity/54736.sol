pragma solidity 0.4.24;

 
 
 
contract CryptoList {
    
   
  address private owner;
  
   
  bool private isPaused = false;

   
  struct Item {
    uint id;
    address seller;
    address buyer;
    string name;
    string description;
    uint256 price;
	  string ipfsHash;
  }

   
  mapping (uint => Item) public items;
  uint itemCounter;
  
     
	 
	 
  event LogSellItem(uint indexed _id, address indexed _seller, string _name, uint256 _price, string _ipfsHash);
  event LogBuyItem(uint indexed _id, address indexed _seller, address indexed _buyer, string _name, uint256 _price, string _ipfsHash);

	 
	 
	 

 
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

 
  modifier counterNotZero() {
    require(itemCounter > 0);
    _;
  }

 
  modifier isHalted() {
    require(isPaused == false);
    _;
  }

	 
 
  function kill() public onlyOwner {
    selfdestruct(owner);
  }

 
 
 
 
 
 
  function sellItem(string _name, string _description, uint256 _price, string _ipfsHash) public {
     
    itemCounter++;

     
    items[itemCounter] = Item(
      itemCounter,
      msg.sender,
      0x0,
      _name,
      _description,
      _price,
      _ipfsHash
    );

    emit LogSellItem(itemCounter, msg.sender, _name, _price, _ipfsHash);
  }

 
 
  function toggleContractActive() public onlyOwner {
    isPaused = !isPaused;
  }
    
 
 
  function getNumberOfItems() public view returns (uint) {
    return itemCounter;
  }

 
 
  function getItemsForSale() public view returns (uint[]) {
     
    uint[] memory itemIds = new uint[](itemCounter);

    uint numberOfItemsForSale = 0;
     
    for(uint i = 1; i <= itemCounter;  i++) {
       
      if(items[i].buyer == 0x0) {
        itemIds[numberOfItemsForSale] = items[i].id;
        numberOfItemsForSale++;
      }
    }

     
    uint[] memory forSale = new uint[](numberOfItemsForSale);
    for(uint j = 0; j < numberOfItemsForSale; j++) {
      forSale[j] = itemIds[j];
    }
    return forSale;
  }

   
 
 
 
  function buyItem(uint _id) payable public counterNotZero {
     
    require(_id > 0 && _id <= itemCounter);

     
    Item storage item = items[_id];

     
    require(item.buyer == 0X0);

     
    require(msg.sender != item.seller);

     
    require(msg.value == item.price);

     
    item.buyer = msg.sender;

     
    item.seller.transfer(msg.value);

     
    emit LogBuyItem(_id, item.seller, item.buyer, item.name, item.price, item.ipfsHash);
  }
}