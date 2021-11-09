pragma solidity 0.4.23;

 
contract Medipedia {
    address public owner;
    
    constructor() public{
        owner = msg.sender;
    }
    
    modifier restricted() {
        require(msg.sender == owner);
        _;
    }
    
    event addMessageRequestEvent(address userAddress, string msgReqst);
    event addMessageReplyEvent(address userAddress, string reply);
    event userStatusUpdated(address userAddress, string eventMsg);
     
    struct Message{
        uint id;
        string messageRequestHash;
        string replyHash;
    }

     
    mapping (address => Message[]) messages;
    
     
    
    mapping (address => uint) userStatus;
     
    function addMessageRequest(address _consumerAddress, address[] _providerAddresses, string _msgRequestHash) public{
        if(userStatus[_consumerAddress] == 1){
            addMessage(_consumerAddress,  _msgRequestHash,  "");
            uint _noOfProviders = _providerAddresses.length;
            for (uint i = 0; i<_noOfProviders; i++) {
                if(userStatus[_providerAddresses[i]] == 1){
                    addMessage(_providerAddresses[i],  _msgRequestHash,  "");
                }
            }
        }
    }
    
    function addReplies(address _consumerAddress, address[] _providerAddresses, string _msgRequestHash, string _repHash) public{
        if(userStatus[_consumerAddress] == 1){
            addMessage(_consumerAddress,  _msgRequestHash,  _repHash);
            uint _noOfProviders = _providerAddresses.length;
            for (uint i = 0; i<_noOfProviders; i++) {
                if(userStatus[_providerAddresses[i]] == 1){
                    addMessage(_providerAddresses[i],  _msgRequestHash,  _repHash);
                }
            }
        }
    }
     
     
    function addMessage(address userAddress, string msgRequestHash, string repHash) private {
        
        Message[] storage msgs = messages[userAddress];

        uint arrayLength = msgs.length;
        Message memory message;
        if(arrayLength == 0){
            uint id = arrayLength + 1;
            message = Message(id, msgRequestHash, repHash);
            msgs.push(message);
            emit addMessageRequestEvent(userAddress, "New Message request added.");
        }else{
            bool isMsgAvailable = false;
            for (uint i = 0; i<arrayLength; i++) {

                if(keccak256(abi.encodePacked(msgs[i].messageRequestHash)) == keccak256(abi.encodePacked(msgRequestHash))){
                    msgs[i].replyHash = repHash;
                    isMsgAvailable = true;
                    break;
                }
            }
            if(!isMsgAvailable){
                id = arrayLength + 1;
                message = Message(id, msgRequestHash, repHash);
                msgs.push(message);
            }
            emit addMessageReplyEvent(userAddress, "A new reply added");
        }

    }

     
    function getNoOfMsgs(address userAddress) public view returns(uint){
        return messages[userAddress].length;
    }

     
    function getMessageCommunicationHash(address userAddress, uint id) public view returns(string){
        Message[] storage msgs = messages[userAddress];
        string storage msgHash = msgs[id-1].replyHash;

        if(bytes(msgHash).length == 0){
            return "";
        }

        return msgHash;
    }
     
    function getMessageRequestHash(address userAddress, uint id) public view returns(string){
        Message[] storage msgs = messages[userAddress];
        return msgs[id-1].messageRequestHash;
    }
    
    function setUserStatus(address userAddress, uint status) public restricted{
        userStatus[userAddress] = status;
        emit userStatusUpdated(userAddress, "User status updated.");
    }

    function getUserStatus(address userAddress) public restricted view returns(uint){
        return userStatus[userAddress];
    }
    
    function kill() public restricted{
        if (msg.sender == owner) selfdestruct(owner);
    }

}