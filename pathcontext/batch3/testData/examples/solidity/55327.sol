pragma solidity ^0.4.24;

 

 
pragma solidity ^0.4.24;


contract OracleRequest {

    uint256 public EUR_WEI;  

    uint256 public lastUpdate;  

    function ETH_EUR() public view returns (uint256);  

    function ETH_EURCENT() public view returns (uint256);  

}

 

 
library SafeMath {

   
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
     
     
     
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

   
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
     
     
     
    return _a / _b;
  }

   
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

   
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

 

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

 
interface ERC165 {

   
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);
}

 

 
contract ERC721Basic is ERC165 {

  bytes4 internal constant InterfaceId_ERC721 = 0x80ac58cd;
   

  bytes4 internal constant InterfaceId_ERC721Exists = 0x4f558e79;
   

  bytes4 internal constant InterfaceId_ERC721Enumerable = 0x780e9d63;
   

  bytes4 internal constant InterfaceId_ERC721Metadata = 0x5b5e139f;
   

  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );
  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );
  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function exists(uint256 _tokenId) public view returns (bool _exists);

  function approve(address _to, uint256 _tokenId) public;
  function getApproved(uint256 _tokenId)
    public view returns (address _operator);

  function setApprovalForAll(address _operator, bool _approved) public;
  function isApprovedForAll(address _owner, address _operator)
    public view returns (bool);

  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId)
    public;

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public;
}

 

 
contract ERC721Enumerable is ERC721Basic {
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    public
    view
    returns (uint256 _tokenId);

  function tokenByIndex(uint256 _index) public view returns (uint256);
}


 
contract ERC721Metadata is ERC721Basic {
  function name() external view returns (string _name);
  function symbol() external view returns (string _symbol);
  function tokenURI(uint256 _tokenId) public view returns (string);
}


 
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

 

 
contract ERC721Receiver {
   
  bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;

   
  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes _data
  )
    public
    returns(bytes4);
}

 

contract ERC721Holder is ERC721Receiver {
  function onERC721Received(
    address,
    address,
    uint256,
    bytes
  )
    public
    returns(bytes4)
  {
    return ERC721_RECEIVED;
  }
}

 

 
pragma solidity ^0.4.24;






contract OnChainShop is ERC721Receiver {
    using SafeMath for uint256;

    ERC721 internal cryptostamp;
    OracleRequest internal oracle;

    address public beneficiary;
    address public shippingControl;
    address public tokenAssignmentControl;

    uint256 public priceEurCent;

    bool public isOpen = true;

    enum Status{
        Initial,
        Sold,
        ShippingSubmitted,
        ShippingConfirmed
    }

    event AssetSold(address indexed buyer, uint256 indexed tokenId, uint256 priceWei);
    event ShippingSubmitted(address indexed owner, uint256 indexed tokenId, string deliveryInfo);
    event ShippingFailed(address indexed owner, uint256 indexed tokenId, string reason);
    event ShippingConfirmed(address indexed owner, uint256 indexed tokenId);

    mapping(uint256 => Status) public deliveryStatus;

    constructor(ERC721 _cryptostamp,
        OracleRequest _oracle,
        uint256 _priceEurCent,
        address _beneficiary,
        address _shippingControl,
        address _tokenAssignmentControl)
    public
    {
        cryptostamp = _cryptostamp;
        require(address(cryptostamp) != 0x0, "You need to provide an actual Cryptostamp contract.");
        oracle = _oracle;
        require(address(oracle) != 0x0, "You need to provide an actual Oracle contract.");
        beneficiary = _beneficiary;
        require(address(beneficiary) != 0x0, "You need to provide an actual beneficiary address.");
        tokenAssignmentControl = _tokenAssignmentControl;
        require(address(tokenAssignmentControl) != 0x0, "You need to provide an actual tokenAssignmentControl address.");
        shippingControl = _shippingControl;
        require(address(shippingControl) != 0x0, "You need to provide an actual shippingControl address.");
        priceEurCent = _priceEurCent;
        require(priceEurCent > 0, "You need to provide a non-zero price.");
    }

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Only the current benefinicary can call this function.");
        _;
    }

    modifier onlyTokenAssignmentControl() {
        require(msg.sender == tokenAssignmentControl, "tokenAssignmentControl key required for this function.");
        _;
    }

    modifier onlyShippingControl() {
        require(msg.sender == shippingControl, "shippingControl key required for this function.");
        _;
    }

    modifier requireOpen() {
        require(isOpen == true, "This call only works when the shop is open.");
        _;
    }

     

    function newPrice(uint256 _newPriceEurCent)
    public
    onlyBeneficiary
    {
        require(_newPriceEurCent > 0, "You need to provide a non-zero price.");
        priceEurCent = _newPriceEurCent;
    }

    function newBeneficiary(address _newBeneficiary)
    public
    onlyBeneficiary
    {
        beneficiary = _newBeneficiary;
    }

    function newOracle(OracleRequest _newOracle)
    public
    onlyBeneficiary
    {
        require(address(_newOracle) != 0x0, "You need to provide an actual Oracle contract.");
        oracle = _newOracle;
    }

    function openShop()
    public
    onlyBeneficiary
    {
        isOpen = true;
    }

    function closeShop()
    public
    onlyBeneficiary
    {
        isOpen = false;
    }

     

     
     
    function priceWei()
    public view
    returns (uint256)
    {
        return priceEurCent.mul(oracle.EUR_WEI()).div(100);
    }

     
    function()
    public payable
    requireOpen
    {
         
        uint256 curPriceWei = priceWei();
        require(msg.value >= curPriceWei, "You need to send enough currency to actually pay the item.");
        beneficiary.transfer(curPriceWei);
        if (msg.value > curPriceWei) {
            msg.sender.transfer(msg.value.sub(curPriceWei));
        }
         
        uint256 tokenId = cryptostamp.tokenOfOwnerByIndex(this, 0);
        cryptostamp.safeTransferFrom(this, msg.sender, tokenId);
        emit AssetSold(msg.sender, tokenId, curPriceWei);
        deliveryStatus[tokenId] = Status.Sold;
    }

     

     
     
    function shipToMe(string _deliveryInfo, uint256 _tokenId)
    public
    requireOpen
    {
        require(cryptostamp.ownerOf(_tokenId) == msg.sender, "You can only request shipping for your own tokens.");
        require(deliveryStatus[_tokenId] == Status.Sold, "Shipping was already requested for this token or it was not sold by this shop.");
        emit ShippingSubmitted(msg.sender, _tokenId, _deliveryInfo);
        deliveryStatus[_tokenId] = Status.ShippingSubmitted;
    }

     
    function confirmShipping(uint256 _tokenId)
    public
    onlyShippingControl
    {
        deliveryStatus[_tokenId] = Status.ShippingConfirmed;
        emit ShippingConfirmed(cryptostamp.ownerOf(_tokenId), _tokenId);
    }

     
    function rejectShipping(uint256 _tokenId, string _reason)
    public
    onlyShippingControl
    {
        deliveryStatus[_tokenId] = Status.Sold;
        emit ShippingFailed(cryptostamp.ownerOf(_tokenId), _tokenId, _reason);
    }

     

     
     
     
     
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data)
    public
    returns (bytes4)
    {
        require(_from == beneficiary, "Only the current benefinicary can send assets to the shop.");
        return ERC721_RECEIVED;
    }

     
    function rescueToken(ERC20Basic _foreignToken, address _to)
    public
    onlyTokenAssignmentControl
    {
        _foreignToken.transfer(_to, _foreignToken.balanceOf(this));
    }
}