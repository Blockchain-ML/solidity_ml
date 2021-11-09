pragma solidity 0.5.0;

contract IM03 {
    
     
    bytes32[] list;  
    
     
    function stringToBytes32(string memory source) pure private returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(source, 32))
        }
    }
    
     
    struct ShopOwner {
        bytes32 id;
        bytes32 name;
        mapping(bytes32 => bytes32[]) mapShopOwnerProduct;  
        mapping(bytes32 => bool) mapProductAvailable;  
        bytes32[] products;
        bool isValue;
    }
    
    struct Product {
        bytes32 id;
        bytes32 name;
        bytes32 ownerId;
        bytes32 categoryId;
        uint256 quantity;
        bool isValue;
    }
    
    struct Category {
        bytes32 id;
        bytes32 name;
        bool isValue;
    }
    
     
    bytes32[] shopOwnerList;
    bytes32[] productList;
    bytes32[] categoryList;
    
    
     
    mapping(bytes32 => ShopOwner) mapShopOwner;
    mapping(bytes32 => Product) mapProduct;
    mapping(bytes32 => Category) mapCategory;
    
    function addShopOwner(string memory _shopOwnerId, string memory _name) public payable {
        bytes32 id = stringToBytes32(_shopOwnerId);
        bytes32 name = stringToBytes32(_name);
        mapShopOwner[id] = ShopOwner(id, name, list, true);
    }
    
    function addCategory(string memory _id, string memory _name) public payable {
        bytes32 id = stringToBytes32(_id);
        bytes32 name = stringToBytes32(_name);
        
        mapCategory[id] = Category(id, name, true);
    }
    
    function addProduct(string memory _id, string memory _name, string memory _ownerId, string memory _categoryId, uint256 _quantity) public payable {
        bytes32 id = stringToBytes32(_id);
        bytes32 name = stringToBytes32(_name);
        bytes32 ownerId = stringToBytes32(_ownerId);
        bytes32 categoryId = stringToBytes32(_categoryId);
        
         
        mapShopOwner[ownerId].mapShopOwnerProduct[categoryId].push(id);  
        mapShopOwner[ownerId].products.push(id);  
        mapShopOwner[ownerId].mapProductAvailable[id] = true;  
        
         
        mapProduct[id] = Product(id, name, ownerId, categoryId, _quantity, true);  
        productList.push(id);  
    }
    
    function getShopOwner(string memory _id) public view returns(bytes32) {
        bytes32 id = stringToBytes32(_id);
        return (mapShopOwner[id].name);
    }
    
    function getCategory(string memory _id) public view returns(bytes32) {
        bytes32 id = stringToBytes32(_id);
        return (mapCategory[id].name);
    }
    
    function getShopOwnerProductList(string memory _shopOwnerId) public view returns(bytes32[]  memory) {
        bytes32 id = stringToBytes32(_shopOwnerId);
        return (mapShopOwner[id].products);
    }
    
    function getShopOwnerCategorizedProducts(string memory _shopOwnerId, string memory _categoryId) public view returns(bytes32[] memory) {
        bytes32 ownerId = stringToBytes32(_shopOwnerId);
        bytes32 categoryId = stringToBytes32(_categoryId);
        
        return (mapShopOwner[ownerId].mapShopOwnerProduct[categoryId]);
    }
    
    function getShopOwnerAllProductList(string memory _shopOwnerId) public view returns(bytes32[] memory) {
        bytes32 id = stringToBytes32(_shopOwnerId);
        return (mapShopOwner[id].products);
    }
    
    function getProduct(string memory _id) public view returns(bytes32, bytes32) {
        bytes32 id = stringToBytes32(_id);
        return (mapProduct[id].id, mapProduct[id].name);
    }
    
    function getAllProductList() public view returns(bytes32[] memory) {
        return (productList);
    }
    
    function removeProduct(string memory _productId, string memory _ownerId) public payable {
        bytes32 productId = stringToBytes32(_productId);
        bytes32 ownerId = stringToBytes32(_ownerId);
        
         
        for (uint256 index=0; index<productList.length; index++) {
            if (productList[index] == productId) {
                productList[index] = productList[productList.length - 1];
                delete productList[productList.length - 1];
                productList.length--;
                break;
            }
        }
        
         
        mapProduct[productId].isValue = false;
        
         
        for (uint256 index=0; index<mapShopOwner[ownerId].products.length; index++) {
            if (mapShopOwner[ownerId].products[index] == productId) {
                mapShopOwner[ownerId].products[index] = mapShopOwner[ownerId].products[mapShopOwner[ownerId].products.length - 1];
                delete mapShopOwner[ownerId].products[mapShopOwner[ownerId].products.length - 1];
                mapShopOwner[ownerId].products.length--;
                break;
            }
        }
        
         
        mapShopOwner[ownerId].mapProductAvailable[productId] = false;
    }
}