pragma solidity ^ 0.4 .22;
contract Cession_Bien_Immobilier {

     
     
     
    enum Stages {
        Initialisation,
        Lifecycle
    }
    Stages public stage = Stages.Initialisation;

     
     
     
    House[] public houseList;

     
     
     


     
     
     


     
     
     
    struct House {
        bytes32 houseAddress;
        address owner;
        bool isForSale;
        uint salePrice;
    }

     
     
     
    function from_Initialisation_to_Lifecycle() atStage(Stages.Initialisation) public {
        if (true) {
            stage = Stages.Lifecycle;
        }
    }

     
     
     
    constructor() atStage(Stages.Initialisation) public {  

         

         
        from_Initialisation_to_Lifecycle();
    }

    function register(bytes32 houseAddress) atStage(Stages.Lifecycle) public {
        uint houseAtAddress;
         
        houseAtAddress = findIndexWhereHouseProperty(houseList, "address", "==", "houseAddress");
        if (houseAtAddress < 0 && houseList[houseAtAddress].owner != msg.sender) {
            revert();
        }

         
        houseList.push(House({
            houseAddress: houseAddress,
            owner: msg.sender,
            isForSale: false,
            salePrice: 0
        }));

         


    }

    function listForSale(uint amount, bytes32 houseAddress) atStage(Stages.Lifecycle) public {
        uint houseIndex;
         
        houseIndex = findIndexWhereHouseProperty(houseList, "address", "==", "houseAddress");
        if (houseIndex < 0) {
            revert();
        }
        if (houseList[houseIndex].owner != msg.sender) {
            revert();
        }

         
        houseList[houseIndex].isForSale = true;
         
        houseList[houseIndex].salePrice = amount;

         


    }

    function buy(uint amount, address beneficiary, bytes32 houseAddress) payable atStage(Stages.Lifecycle) public {
        address oldOwner;
        uint houseIndex;
         
        houseIndex = findIndexWhereHouseProperty(houseList, "address", "==", "houseAddress");
        if (!houseList[houseIndex].isForSale) {
            revert();
        }
        if (msg.value < houseList[houseIndex].salePrice) {
            revert();
        }

         
        oldOwner = houseList[houseIndex].owner;
        houseList[houseIndex].owner = msg.sender;

         
        oldOwner.send(msg.value);


    }

     
     
     
    modifier atStage(Stages _expectedStage) {
        require(stage == _expectedStage);
        _;
    }

     
     
     


     
     
     
    function findIndexWhereHouseProperty(House[] structArray, bytes32 structProperty, bytes4 operator, bytes32 value) internal pure returns(uint) {
        uint index = 0;

        return index;
    }

    function findStructWhereHouseProperty(House[] structArray, bytes32 structProperty, bytes4 operator, bytes32 value) internal pure returns(House) {
        House memory item = structArray[0];

        return item;
    }
}