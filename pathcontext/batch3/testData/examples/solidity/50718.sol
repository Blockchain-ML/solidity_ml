pragma solidity ^0.4.24;

contract SoulMate {
    
    mapping(bytes32 => SecretMessage)  secrets;
    mapping(address => uint256) balance;
    
    struct Answer {
        address userAddress;
        bytes32 answer;
    }
    
    mapping(bytes32 => Answer[]) answers;
    
     
    uint256 public hashesLength;
    bytes32[] public secretHashes;
    
    struct SecretMessage {
        uint256 value;
        address owner;
        string content;
        bytes32 answerHash;
        bool hasOpened;
        bool userWin;
    }
    
    uint256 public min_deposit = 2 finney;
    
    mapping(address => bytes32[]) nonPublicSecret;
    
     
    function createNewSecret(string secretMessage, bytes32 hash, bool hide) public payable {        
         
        balance[msg.sender] += msg.value;
        
         
        secrets[hash] = SecretMessage(msg.value, msg.sender, secretMessage, hash, hide, false);
        
        if(hide == false) {
            addNewSecretHash(hash);
        }
        else {
            nonPublicSecret[msg.sender].push(hash);
        }
        
    }
    
     
    
    function getRanomSecret() public view returns (bytes32) {
        uint index = (now + gasleft()) % hashesLength;
        return secretHashes[index];
    }
    
     
    function openSecret(bytes32 hash, bytes32 answer, string randomString) public {
         
        require(hash == sha3(answer, randomString));
        
         
        Answer[] storage userAnswers = answers[hash];
        SecretMessage storage secret = secrets[hash];
        uint256 amountToOwner = secret.value / 2;
        for(uint idx = 0; idx < userAnswers.length; idx++) {
            if(userAnswers[idx].answer == answer) {
                 
                userAnswers[idx].userAddress.transfer(secret.value);
                secrets[hash].userWin = true;
            }
            else {
                amountToOwner += secret.value / 2;
                secrets[hash].userWin = false;
            }
        }
        
        secret.owner.transfer(amountToOwner);
        
        secrets[hash].hasOpened = true;
        removeOneSecret(hash);
    }
    
     
    function postNewAnswer(bytes32 hash, bytes32 answer) public payable {
        SecretMessage secret = secrets[hash];
        
         
        require(secret.hasOpened == false);
        
         
        require(msg.value * 2 >= secret.value);
        
         
        require(answers[hash].length == 0);
        
        answers[hash].push(Answer(msg.sender, answer));
    }
    
     
    function getSecretByHash(bytes32 hash) public view returns (uint256 value, address owner, string content, bool hasOpened, bool userWin) {
        return (secrets[hash].value, secrets[hash].owner, secrets[hash].content, secrets[hash].hasOpened, secrets[hash].userWin);
    }
    
    function removeOneSecret(bytes32 hash) internal {
        for(uint256 idx = 0; idx < hashesLength; idx++) {
            if(secretHashes[idx] == hash) {
                secretHashes[idx] = secretHashes[hashesLength - 1];
                break;
            }
        }
        hashesLength--;
    }
    
    function addNewSecretHash(bytes32 hash) internal {
        if(secretHashes.length == hashesLength) {
            secretHashes.push(hash);
        }
        else {
            secretHashes[hashesLength] = hash;
        }
        
        hashesLength++;
    }
}