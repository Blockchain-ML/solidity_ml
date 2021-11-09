pragma solidity 0.4.25;

contract EthDegreeValidation {
    
    address public owner;
    address public pendingOwner;

    event DegreeAdded(bytes32 indexed _hash, address indexed _by);
    event ModeratorAdded(address _address);
    event ModeratorRemoved(address _address);

    modifier onlyOwner() {
        require(msg.sender == owner, "This function is only available to the \"owner\" address of this contract.");
        _;
    }
    
    modifier onlyMod() {
        require(isMod(msg.sender), "This function is only available to Moderator addresses.");
        _;
    }

    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner, "This function can only be executed by the pending Owner address.");
        _;
    }
    
    struct DegreeOwnership {
        uint date;
        string name;
    }
    
    struct Moderator {
         
        uint index;
         
        string universityName;
    }
    
    mapping (bytes32 => DegreeOwnership) private degrees;
    bytes32[] private sha256HashesOfDegrees;
    
    mapping (address => Moderator) private moderators;
    address[] private moderatorsList;

     
    constructor() public {
        owner = msg.sender;
         
        pendingOwner = msg.sender;
         
        addModerator(msg.sender, "Contract owner");
         
        addNewDegree("Invalid Hash", 0x0);
         
         
         
         
         
    }
    
    function addNewDegree(string _name, bytes32 _sha256ofpdf) onlyMod public {
         
        require(bytes(_name).length < 256, "Provided name is of unrealistic length.");
         
        require(bytes(_name).length > 0, "A name was not provided.");
         
        require(degrees[_sha256ofpdf].date == 0, "This degree is already validated.");
        
        DegreeOwnership storage degree = degrees[_sha256ofpdf];
        
        degree.name = _name;
        degree.date = block.timestamp;
        
        sha256HashesOfDegrees.push(_sha256ofpdf);
        emit DegreeAdded(_sha256ofpdf, msg.sender);
    }
    
     
    function addModerator(address _moderatorAddress, string _uniName) onlyOwner public {
         
        require(_moderatorAddress != address(0x0), "An ethereum address was not provided.");
        require(bytes(_uniName).length > 0, "A university name was not provided.");
         
        require(!isMod(_moderatorAddress), "This is already a moderator address.");
        
         
        Moderator storage moderator = moderators[_moderatorAddress];
         
        moderator.universityName = _uniName;
         
         
         
         
         
        moderator.index = moderatorsList.push(_moderatorAddress)-1;
         
        emit ModeratorAdded(_moderatorAddress);
    }
    
     
    function isMod(address _moderatorAddress) public view returns(bool) {
        if (moderatorsList.length == 0) {
            return false;
        }
        if (moderators[_moderatorAddress].index > (moderatorsList.length - 1)) {
            return false;
        }
        return (moderatorsList[moderators[_moderatorAddress].index] == _moderatorAddress);
    }
    
     
    function removeModerator(address _moderatorAddress) onlyOwner public {
         
        require(isMod(_moderatorAddress), "The provided address does not belong to a moderator.");
        
         
         
        uint rowToDelete = moderators[_moderatorAddress].index;
        address keyToMove = moderatorsList[moderatorsList.length-1];
         
         
        moderatorsList[rowToDelete] = keyToMove;
         
        moderators[keyToMove].index = rowToDelete;
         
        moderatorsList.length--;
        emit ModeratorRemoved(_moderatorAddress);
    }
    
     
    function getDegreeAtIndex(uint _index) public view returns (bytes32) {
        require(_index < sha256HashesOfDegrees.length, "The provided Index is higher than then total number of degrees. There is nothing there.");
        return sha256HashesOfDegrees[_index];
    }
    
    function getDegree(bytes32 _sha256ofpdf) public view returns(bytes32, string, uint) {
        require(degrees[_sha256ofpdf].date != 0, "The provided hash does not belong to any validated degree.");
        return (_sha256ofpdf, degrees[_sha256ofpdf].name, degrees[_sha256ofpdf].date);
    }
    
    function getDegreeCount() public view returns(uint) {
        return sha256HashesOfDegrees.length;
    }
    
    function getModeratorAtIndex(uint _index) public view returns(address) {
        require(_index < moderatorsList.length, "The provided Index is higher than then total number of moderators. There is nothing there.");
        return moderatorsList[_index];
    }
    
    function getModerator(address _moderatorAddress) public view returns(address, uint, string) {
        require(isMod(_moderatorAddress),"The provided address does not belong to a moderator.");
        return (_moderatorAddress, moderators[_moderatorAddress].index, moderators[_moderatorAddress].universityName);
    }
    
    function getModeratorCount() public view returns(uint) {
        return moderatorsList.length;
    }

    function transferOwnership(address _newOwner) onlyOwner public {
        require(_newOwner !=address(0x0), "An ethereum address was not provided.");
        pendingOwner = _newOwner;
    }

    function claimOwnership() onlyPendingOwner public {
        owner = pendingOwner;
    }

}