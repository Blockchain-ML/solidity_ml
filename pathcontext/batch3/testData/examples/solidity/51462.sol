pragma solidity ^ 0.4 .22;
contract Cession_Bien_Immobilier {

     
     
     
    enum Stages {
        Initialisation,
        Lifecycle
    }
    Stages public stage = Stages.Initialisation;

     
     
     
    mapping(bytes32 => uint) public houseAddressToId;
    mapping(address => uint) public etherList;
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

     
     
     
    function init() atStage(Stages.Initialisation) public {  

         

         
        from_Initialisation_to_Lifecycle();
    }

    function register(bytes32 houseAddress) atStage(Stages.Lifecycle) public {  
        if (houseAddressToId[houseAddress] > 0) {
            revert();
        }

         
        houseAddressToId[houseAddress] = (houseList.length + 1);
        houseList.push(House({
            houseAddress: houseAddress,
            owner: msg.sender,
            isForSale: false,
            salePrice: 0
        }));

         


    }

    function listForSale(uint amount, bytes32 houseAddress) atStage(Stages.Lifecycle) public {
        uint houseIndex;
         
        houseIndex = houseAddressToId[houseAddress];
        if (houseIndex == 0) {
            revert();
        }
        if (houseList[houseIndex].owner != msg.sender) {
            revert();
        }

         
        houseList[(houseIndex - 1)].isForSale = true;
        houseList[(houseIndex - 1)].salePrice = amount;

         


    }

    function buy(uint amount, address beneficiary, bytes32 houseAddress) payable atStage(Stages.Lifecycle) public {
        address oldOwner;
        uint houseIndex;
         
        houseIndex = houseAddressToId[houseAddress];
        if (houseIndex == 0) {
            revert();
        }
        if (!houseList[(houseIndex - 1)].isForSale) {
            revert();
        }
        if (msg.value < houseList[(houseIndex - 1)].salePrice) {
            revert();
        }

         
        oldOwner = houseList[(houseIndex - 1)].owner;
        houseList[(houseIndex - 1)].owner = msg.sender;

         
        oldOwner.transfer(msg.value);


    }

     
     
     
    modifier atStage(Stages _expectedStage) {
        if (stage == _expectedStage) {
            _;
        }
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