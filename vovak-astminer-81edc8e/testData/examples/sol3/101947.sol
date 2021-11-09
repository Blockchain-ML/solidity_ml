pragma solidity >=0.5.7 <0.6.0;

 

 
contract ReasoningTree {

    struct Node {  
        string keyIdea;  
        string moreDetail;  
        address author;  
        uint[] pros;  
        uint[] cons;  
    }
    
    mapping(uint => Node) nodes;
    uint nextId;
    event ReturnValue(address indexed _from, uint thisNodeId);

    constructor() public {
        nextId = 1;  
    }

     
    function setNextNodeDetails(uint thisNodeId, string memory newKeyIdea, string memory newMoreDetail, address author) private {
        nodes[thisNodeId].keyIdea = newKeyIdea;
        nodes[thisNodeId].moreDetail = newMoreDetail;
        nodes[thisNodeId].author = author;
    }

     
    function addNewTopic(string memory newKeyIdea, string memory newMoreDetail) public returns (uint thisNodeId) {
        thisNodeId = nextId;
        setNextNodeDetails(thisNodeId, newKeyIdea, newMoreDetail, msg.sender);
        nextId = nextId + 1;
        emit ReturnValue(msg.sender, thisNodeId);
        return thisNodeId;
    }
    
     
    function add(string memory newKeyIdea, string memory newMoreDetail, uint parent, bool supportsParent) public returns (uint thisNodeId) {
        require(parent < nextId, "The given parent must already exist.");
        thisNodeId = nextId;
        setNextNodeDetails(thisNodeId, newKeyIdea, newMoreDetail, msg.sender);
        if (supportsParent)
            nodes[parent].pros.push(thisNodeId);
        else
            nodes[parent].cons.push(thisNodeId);
        nextId = nextId + 1;
        emit ReturnValue(msg.sender, thisNodeId);
        return thisNodeId;
    }
    
     
    function retrieve (uint nodeId) public view returns (string memory, string memory, address, uint[] memory, uint[] memory)  {
        require(nodeId < nextId, "The given node must already exist.");
        return (nodes[nodeId].keyIdea, nodes[nodeId].moreDetail, nodes[nodeId].author, nodes[nodeId].pros, nodes[nodeId].cons);
    }
    
     
    function getKeyIdea(uint nodeId) public view returns (string memory) {
        require(nodeId < nextId, "The given node must already exist.");
        return nodes[nodeId].keyIdea;
    }
    
     
    function nodeCount() public view returns (uint) {
        return nextId - 1;  
    }
}