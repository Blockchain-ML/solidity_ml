pragma solidity ^0.4.15;


 
contract RpSafeMath {
    function safeAdd(uint256 x, uint256 y) internal pure returns(uint256) {
      uint256 z = x + y;
      require((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal pure returns(uint256) {
      require(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {
      uint256 z = x * y;
      require((x == 0)||(z/x == y));
      return z;
    }

    function min(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a < b) { 
          return a;
        } else { 
          return b; 
        }
    }
    
    function max(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a > b) { 
          return a;
        } else { 
          return b; 
        }
    }
}

contract Token {
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success);
    function balanceOf(address _owner) public view returns (uint256 balance);
}

contract BytesUtils {
    function readBytes32(bytes data, uint256 index) internal pure returns (bytes32 o) {
        require(data.length / 32 > index);
        assembly {
            o := mload(add(data, add(32, mul(32, index))))
        }
    }
}

contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

     
    function transferTo(address _to) public onlyOwner returns (bool) {
        require(_to != address(0));
        owner = _to;
        return true;
    }
}

interface ERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable returns(bool);
    function approve(address _approved, uint256 _tokenId) external payable returns(bool);
    function getApproved(uint256 _tokenId) external view returns (address);
}

contract ErcBundle is ERC721, BytesUtils, Ownable, RpSafeMath {
    mapping (uint256 => address) bundleToOwner;
    mapping (uint256 => address) bundleToApproved;
    mapping (address => uint256) addresToBalance;

    Bundle[] private bundles;
    struct Bundle {
        mapping (address => uint) erc20ToBalance;  
        Token[] erc20Addrs;  
        mapping (address => uint[]) erc721ToNfts;  
        ERC721[] erc721Addrs;  
    }

     
     
    function createBundle() public returns(bool) {
        bundleToOwner[bundles.length] = msg.sender;
        addresToBalance[msg.sender]++;
        bundles.push(Bundle(new Token[](0), new ERC721[](0))); 
        return true;
    }
     
    function addERC20ToBundle(uint _bundleId, Token _erc20, uint _amount) public returns(bool) {
        require(bundleToOwner[_bundleId] == msg.sender, "sender its not the owner");

        require(_erc20.transferFrom(msg.sender, address(this), _amount), "the transfer its no approved");

        Bundle storage bundle = bundles[_bundleId];
        if(bundle.erc20ToBalance[_erc20] == 0){
            bundle.erc20Addrs.push(_erc20);
            bundle.erc20ToBalance[_erc20] = _amount;
        } else {
            bundle.erc20ToBalance[_erc20] = safeAdd(bundle.erc20ToBalance[_erc20], _amount);
        }
        return true;
    }
     
    function addERC721ToBundle(uint _bundleId, ERC721 _erc721, uint[] _nfts) public returns(bool) {
        require(bundleToOwner[_bundleId] == msg.sender, "sender its not the owner");
        require(_nfts.length > 0, "need at last one nft");

        Bundle storage bundle = bundles[_bundleId];
        uint[] storage nfts = bundle.erc721ToNfts[_erc721];

        if(nfts.length == 0)
            bundle.erc721Addrs.push(_erc721);
        for(uint i; i < _nfts.length; i++){
            require(_erc721.transferFrom(msg.sender, address(this), _nfts[i]), "the transfer its no approved");
            nfts.push(_nfts[i]);
        }
        return true;
    }

     
     
    function withdrawERC20(uint256 _bundleId, uint _erc20Id, address _to, uint _amount) public returns(bool){
        require(bundleToOwner[_bundleId] == msg.sender, "sender its not the owner");
        Bundle storage bundle = bundles[_bundleId];
        Token erc20 = bundle.erc20Addrs[_erc20Id];
        require(bundle.erc20ToBalance[erc20] >= _amount, "low balance");

        bundle.erc20ToBalance[erc20] = safeSubtract(bundle.erc20ToBalance[erc20], _amount);
        require(erc20.transfer(_to, _amount), "fail token transfer");

        if(bundle.erc20ToBalance[erc20] == 0) {
            if(bundle.erc20Addrs.length > 1)
                bundle.erc20Addrs[_erc20Id] = bundle.erc20Addrs[bundle.erc20Addrs.length - 1];
            bundle.erc20Addrs.length -= 1;
        }

        return true;
    }
     
    function withdrawERC721(uint256 _bundleId, uint _erc721Id, address _to, uint _nftId) public returns(bool){
        require(bundleToOwner[_bundleId] == msg.sender, "sender its not the owner");
        Bundle storage bundle = bundles[_bundleId];
        ERC721 erc721 = bundle.erc721Addrs[_erc721Id];
        uint nft = bundle.erc721ToNfts[erc721][_nftId];

        if(bundle.erc721ToNfts[erc721].length > 1)
            bundle.erc721ToNfts[erc721][_nftId] = bundle.erc721ToNfts[erc721][bundle.erc721ToNfts[erc721].length - 1];
        bundle.erc721ToNfts[erc721].length -= 1;

        require(erc721.transferFrom(address(this), _to, nft), "fail nft transfer");

        if(bundle.erc721ToNfts[erc721].length == 0) {
            if(bundle.erc721Addrs.length > 1)
                bundle.erc721Addrs[_erc721Id] = bundle.erc721Addrs[bundle.erc721Addrs.length - 1];
            bundle.erc721Addrs.length -= 1;
        }

        return true;
    }

     
    function getApproved(uint256 _bundleId) external view returns (address) { return bundleToApproved[_bundleId]; }

    function ownerOf(uint256 _bundleId) external view returns (address) { return bundleToOwner[_bundleId]; }

    function balanceOf(address _owner) external view returns (uint256) { return addresToBalance[_owner]; }

    function approve(address _approved, uint256 _bundleId) external payable returns(bool) {
        require(msg.sender == bundleToOwner[_bundleId], "sender its not the owner");
        require(msg.sender != _approved, "sender and approved should not be equal");

        bundleToApproved[_bundleId] = _approved;

        emit Approval(msg.sender, _approved, _bundleId);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _bundleId) external payable returns(bool) {
        address owner = bundleToOwner[_bundleId];
        require(owner != 0x0, "the bundle dont exist");
        require(owner == msg.sender || bundleToApproved[_bundleId] == msg.sender, "sender its not the owner or not approved");
        require(owner != _to, "the owner and `_to` should not be equal");
        require(owner == _from, "the owner and `_from` should be equal");
        require(_to != address(0), "`_to` is the zero address");

        addresToBalance[_from]--;
        addresToBalance[_to]++;

        bundleToOwner[_bundleId] = _to;

        emit Transfer(msg.sender, _to, _bundleId);

        return true;
    }

     
     
    function getERC20Id(uint _bundleId, address _erc20) public view returns(uint erc20Id) {
        Token[] storage erc20s = bundles[_bundleId].erc20Addrs;

        for(uint i; i < erc20s.length; i++)
            if(erc20s[i] == _erc20)
                return i;
        revert("ERC20 dont found");
    }
     
    function getAllERC20(uint _bundleId) public view returns(address[] memory addrs, uint[] memory balances){
        Token[] storage erc20s = bundles[_bundleId].erc20Addrs;

        uint length = erc20s.length;
        addrs = new address[](length);
        balances = new uint[](length);

        for(uint i; i < length; i++){
            addrs[i] = erc20s[i];
            balances[i] = bundles[_bundleId].erc20ToBalance[erc20s[i]];
        }
    }
     
    function getERC721Id(uint _bundleId, address _erc721) public view returns(uint erc721Id) {
        ERC721[] storage erc721s = bundles[_bundleId].erc721Addrs;

        for(uint i; i < erc721s.length; i++)
            if(erc721s[i] == _erc721)
                return i;
        revert("ERC721 not found");
    }
     
    function getNftId(uint _bundleId, address _erc721, uint _nft) public view returns(uint nftId) {
        uint[] storage nfts = bundles[_bundleId].erc721ToNfts[_erc721];

        for(uint i; i < nfts.length; i++)
            if(nfts[i] == _nft)
                return i;
        revert("nft not found");
    }
     
    function getERC721Addrs(uint _bundleId) public view returns(ERC721[] addrs){
        return bundles[_bundleId].erc721Addrs;
    }
     
    function getERC721Nfts(uint _bundleId, address _addr) public view returns(uint[] nfts){
        return bundles[_bundleId].erc721ToNfts[_addr];
    }
     
    function bundleOfOwner(address _owner) external view returns(uint256[]) {
        uint256 bundleCount = this.balanceOf(_owner);

        if (bundleCount == 0) {
             
            return new uint256[](0);
        } else {
            uint256[] memory bundleIds = new uint256[](bundleCount);
            uint256 totalBundles = bundles.length;

            uint256 j;
            for (uint256 i; i < totalBundles; i++){
                if(bundleToOwner[i] == _owner) {
                    bundleIds[j] = i;
                    j++;
                }
                if(j >= bundleCount) return bundleIds;
            }
        }
    }
}