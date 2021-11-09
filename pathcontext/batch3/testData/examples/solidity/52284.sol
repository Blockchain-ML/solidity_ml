pragma solidity ^0.5.0;

 
contract SignatureVerifier {
     
     
     
     
     
     
     
    function isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
        return _isSigned(_address, messageHash, v, r, s) || _isSignedPrefixed(_address, messageHash, v, r, s);
    }

     
    function _isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        internal pure returns (bool)
    {
        return ecrecover(messageHash, v, r, s) == _address;
    }

     
    function _isSignedPrefixed(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        internal pure returns (bool)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return _isSigned(_address, keccak256(abi.encodePacked(prefix, messageHash)), v, r, s);
    }
}

contract StringToLower {
	function lower(string memory _base) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _lower(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

     
    function _lower(bytes1 _b1) internal pure returns (bytes1) {
        if (_b1 >= 0x41 && _b1 <= 0x5A) {
            return bytes1(uint8(_b1) + 32);
        }
        return _b1;
    }
}

contract IPFS is SignatureVerifier, StringToLower {
    
    event NewUser(string username, string hash, address publicKey);
    
    struct User {
        string ipfsHash;
        address publicKey;
    }
    
    mapping(string => User) usernames;
    
    function newUser(string memory username, string memory ipfsHash, address publicKey, uint8 v, bytes32 r, bytes32 s) public {
        require(
            usernames[username].publicKey == address(0), 
            "Username already taken"
        );
        require(
            isSigned(
                publicKey,
                keccak256(
                    abi.encodePacked(
                        lower(username),
                        ipfsHash,
                        publicKey
                    )
                ),
                v, r, s
            ),
            "Permission denied."
        );
            
        usernames[username] = User(ipfsHash, publicKey);
        
        emit NewUser(username, ipfsHash, publicKey);
    }
    
    function newUserNoSigning(string memory username, string memory ipfsHash, address publicKey) public {
        require(
            usernames[username].publicKey == address(0), 
            "Username already taken"
        );
            
        usernames[username] = User(ipfsHash, publicKey);
        
        emit NewUser(username, ipfsHash, publicKey);
    }
    
    function getUser(string memory username) public view returns(string memory, address) {
        return (usernames[username].ipfsHash, usernames[username].publicKey);
    }
    
}