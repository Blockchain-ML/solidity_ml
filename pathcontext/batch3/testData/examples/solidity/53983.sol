 

pragma solidity ^0.4.24;

contract DataToBlockchainKeeper {

     
    address public ceoAddress;

     
    event HashUpload(string hash, address dealer, uint time);

     
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

     
    struct HashData {
        address uploader; 
        uint timeUploaded;
        string hashData;
        bool isInChain;
    }

     
    mapping (bytes32 => HashData) public trades; 


     
    function DataToBlockchainKeeper() {

        ceoAddress = msg.sender;
    }

     
    function add_new_hash(string hash) public payable  onlyCEO{
    	require( !check_hash_exist_in_chain(hash) );

        HashData storage newHash = trades[ hashFromHash(hash) ];
        newHash.uploader = msg.sender;
        newHash.hashData = hash;
        newHash.timeUploaded = now;
        newHash.isInChain = true;

        emit HashUpload(hash, newHash.uploader, newHash.timeUploaded);
    }

    function check_hash_exist_in_chain(string hash) public view returns (bool){
    	HashData storage currHash = trades[ hashFromHash(hash) ];
    	return currHash.isInChain;
    }
    
    function hashFromHash(string hash) private returns (bytes32) {
        return sha3(hash);
    }
    
    function get_value_by_hash(string hash) public returns(string hashData, uint timeUploaded, bool isInChain){
        require(check_hash_exist_in_chain(hash));
        
        bytes32 hash_from_hash = hashFromHash(hash);
        return ( trades[hash_from_hash].hashData, trades[hash_from_hash].timeUploaded, trades[hash_from_hash].isInChain);
    }
    
}