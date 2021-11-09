pragma solidity ^0.4.24;

contract Ownable {
   
  address owner;

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  constructor () public {
	owner = msg.sender;
  }
}






 
contract Migratable {
   
  event Migrated(string contractName, string migrationId);

   
  mapping (string => mapping (string => bool)) internal migrated;

   
  string constant private INITIALIZED_ID = "initialized";


   
  modifier isInitializer(string contractName, string migrationId) {
    validateMigrationIsPending(contractName, INITIALIZED_ID);
    validateMigrationIsPending(contractName, migrationId);
    _;
    emit Migrated(contractName, migrationId);
    migrated[contractName][migrationId] = true;
    migrated[contractName][INITIALIZED_ID] = true;
  }

   
  modifier isMigration(string contractName, string requiredMigrationId, string newMigrationId) {
    require(isMigrated(contractName, requiredMigrationId), "Prerequisite migration ID has not been run yet");
    validateMigrationIsPending(contractName, newMigrationId);
    _;
    emit Migrated(contractName, newMigrationId);
    migrated[contractName][newMigrationId] = true;
  }

   
  function isMigrated(string contractName, string migrationId) public view returns(bool) {
    return migrated[contractName][migrationId];
  }

   
  function initialize() isInitializer("Migratable", "1.2.1") public {
  }

   
  function validateMigrationIsPending(string contractName, string migrationId) private view {
    require(!isMigrated(contractName, migrationId), "Requested target migration ID has already been run");
  }
}


contract vchain is Ownable, Migratable {
     
  struct Entity {
    string name;
    string location;
    string web;
    string  phone;
    uint NoOfPayments;
  }
  
  struct Article {
    uint id;
    address creator;
    address holder;
    string name;
  }

   
  mapping (uint => Article) public articles;
  uint articleCounter;
  uint price;
  
   
  mapping (address => Entity) public AddressToEntity;

   
  event LogSellArticle(
    uint indexed _id,
    address indexed _seller,
    string _name
  );
  event LogBuyArticle(
    uint indexed _id,
     
    address indexed _buyer
     
  );
  event SetEntity(
      address indexed _entity,
	  string _name
    );

  function initialize(uint256 _price) isInitializer("vchain", "0") public {
   price = _price;
 }

  
   
   

     
    
    function SetPrice(uint _price) public onlyOwner {
        price = _price;
    }
    
    function GetPrice() public view returns(uint) {
        return price;
    }
    
   
  function Intro(string _name, string _location, string _web, string _phone) public {
        AddressToEntity[msg.sender] = Entity(
          _name,
          _location,
          _web,
          _phone,
          0
        );
        
        emit SetEntity(msg.sender, _name);
  }
  
   
  function CreateBatch(uint _quantity, string _name) public payable {
     
    if (getSaleVolume() >= (AddressToEntity[msg.sender].NoOfPayments + 1) * 100) {
        require (msg.value == price);
        AddressToEntity[msg.sender].NoOfPayments++;
    }
      
      for(uint i = 1; i <= _quantity; i++) {
             
            articleCounter++;
            
            articles[articleCounter] = Article(
              articleCounter,
              msg.sender,
              0x0,
              _name
              );
			  
			emit LogSellArticle(articleCounter, msg.sender, _name);
      }
  }

   
  function getNumberOfArticles() public view returns (uint) {
    return articleCounter;
  }

   
  function getArticlesOwn() public view returns (uint[]) {
     
    uint[] memory articleIds = new uint[](articleCounter);

    uint numberOfArticlesOwn = 0;
     
    for(uint i = 1; i <= articleCounter;  i++) {
       
      if(
          ((msg.sender == articles[i].creator) || (msg.sender ==articles[i].holder))
         )  {
            articleIds[numberOfArticlesOwn] = articles[i].id;
            numberOfArticlesOwn++;
      }
    }

     
    uint[] memory forSale = new uint[](numberOfArticlesOwn);
    for(uint j = 0; j < numberOfArticlesOwn; j++) {
      forSale[j] = articleIds[j];
    }
    return forSale;
  }

 
  function getSaleVolume() public view returns (uint) {
    uint volume = 0;
     
    for(uint i = 1; i <= articleCounter;  i++) {
        if (articles[i].creator == msg.sender) {
            volume++;
        }
    }

    return volume;
  }
  
   
  function SellMulti(uint[] _ids, address _buyer) public {
     
    require(articleCounter > 0);
    
     
    for (uint i=0; i < _ids.length; i++) {
          
        require(_ids[i] > 0 && _ids[i] <= articleCounter);
        
         
        Article storage article = articles[_ids[i]];
         
    
        if (article.holder == 0X0) {
         
        require(msg.sender == article.creator);
        } else {
        require(msg.sender == article.holder);
        }
        
         
        article.holder = _buyer;
        
         
        emit LogBuyArticle(_ids[i], article.holder);
    }
  }
  
   
  function withdraw() public onlyOwner {
      msg.sender.transfer(address(this).balance);
  }
  
}