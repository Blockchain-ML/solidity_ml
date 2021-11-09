pragma solidity^0.4.21;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract DiplomaManagement is Ownable {
    using SafeMath for uint256;
    address wallet;
    uint256 searchingFee; 
    
    constructor()public {
        wallet = owner;
        searchingFee = 200000000000000000;  
    }
    
     
    struct Organizer{
        address user;
        string name;
        string symbol;
        bool registration;
        bool activation;
    }
    
    uint256 numOrganizers;  
    uint256 verifyNumOrganizers; 
    
    mapping (uint256 => Organizer) organizers; 
    
    event OrganizerRegistration(address indexed _from, string _name, string _symbol);
    event VerifyNewOrganizer(address indexed _user, bool status);
    
     modifier onlyOrganizer() {
        require(isActivated(msg.sender) == true);
        _;
    }
     
    function organizerRegistration(string _name, string _symbol ) public payable returns (uint256) {
        assert(msg.value == 2 ether);
        require(isRegistered(msg.sender) == false);
        Organizer storage newOrganizer = organizers[numOrganizers++];
        newOrganizer.user = msg.sender; 
        newOrganizer.name = _name;
        newOrganizer.symbol = _symbol;
        newOrganizer.registration = true;
        
        balanceOf[wallet] = balanceOf[wallet].add(msg.value);  
        
        emit OrganizerRegistration(msg.sender, _name, _symbol);
        
        return numOrganizers.sub(1);  
    }
    
     
    function verifyNewOrganizer(bool _activation)public onlyOwner {
        if(_activation) {
            organizers[verifyNumOrganizers].user.transfer(2 ether);
            balanceOf[wallet] = balanceOf[wallet].sub(2000000000000000000); 
            organizers[verifyNumOrganizers++].activation = _activation;  
        }
        else
            organizers[verifyNumOrganizers++].activation = _activation;  
            
        emit VerifyNewOrganizer(organizers[verifyNumOrganizers].user, _activation);
    }
    
     
    function getOrganizerInforById(uint256 _numOrganizer)view public returns(address user, string name, string symbol, bool registration, bool activation) {
        
        Organizer memory o = organizers[_numOrganizer];
        return (o.user, o.name, o.symbol, o.registration, o.activation) ;
    }
    
    function getOrganizerAddress(uint256 _numOrganizer)view public returns(address) {
        return organizers[_numOrganizer].user;
    }
    
    function getOrganizerName(uint256 _numOrganizer)view public returns(string) {
        return organizers[_numOrganizer].name;
    }
    
    function getOrganizerSymbol(uint256 _numOrganizer)view public returns(string) {
        return organizers[_numOrganizer].symbol;
    }
    
    function getOrganizerRegistrationStatus(uint256 _numOrganizer)view public returns(bool) {
        return organizers[_numOrganizer].registration;
    }
    
    function getOrganizerActivationStatus(uint256 _numOrganizer)view public returns(bool) {
        return organizers[_numOrganizer].activation;
    }
    
     
    function getNumOrganizers()view public returns (uint256) {
        return numOrganizers;
    }
     
    function getVerifiedNumOrganizers()view public returns (uint256) {
        return verifyNumOrganizers;
    }
     
    function isRegistered(address _user)view public returns (bool) {
        for(uint256 i = 0; i< numOrganizers; i++)
        {
            if(organizers[i].user == _user)
                return true;
        }
        return false;
    }
     
    function isActivated(address _user)view public returns (bool) {
        if(isRegistered(_user)){
            for(uint256 i = 0; i< numOrganizers; i++)
            {
                if(organizers[i].user == _user)
                    return organizers[i].activation;
            }
        }
        return false;
    }
    
     
    enum DiplomaStatus {Activated, Expired, Destroyed}
    enum DiplomaTypes {Certificate, Bachelor, Master, Doctorate}
    enum DiplomaRanks {Excellent, Good, Fair}
    struct Diploma{
        uint256 id;
        uint256 diplomaId;
        string fullName;
        string birthDay;
        string date;
        DiplomaStatus status;
        DiplomaTypes _type;
        DiplomaRanks rank;
        address organizer;
    }
    
    uint256 numDiplomas;
    mapping (uint256 => Diploma) diplomas;
    
    event AddNewDiploma(uint256 _id, address organizer);
    event UpdateDiploma(uint256 _id, address organizer, DiplomaStatus _newStatus);
    
    function addNewDiploma(uint256 _diplomaId, string _fullName, string _birthDay, string _date, DiplomaStatus _status, DiplomaTypes _type, DiplomaRanks _rank)public onlyOrganizer {
        Diploma storage newDiploma = diplomas[numDiplomas++];
        newDiploma.id = numDiplomas.sub(1); 
        newDiploma.diplomaId = _diplomaId;
        newDiploma.fullName = _fullName;
        newDiploma.birthDay = _birthDay;
        newDiploma.date = _date;
        newDiploma.status = _status;
        newDiploma._type = _type;
        newDiploma.rank = _rank;
        newDiploma.organizer = msg.sender;
        
        emit AddNewDiploma(newDiploma.id, msg.sender);
    }
     
    function updateDiploma(uint256 _id, DiplomaStatus newStatus)public onlyOrganizer {
        require(getDiplomaOrganizerById(_id) == msg.sender);
        
        diplomas[_id].status = newStatus;
        
        emit UpdateDiploma(_id, msg.sender, newStatus);
    }
    
    function getDiplomaOrganizerById(uint256 _id)view internal returns(address) {
        return diplomas[_id].organizer;
    }
    
    event SearchDiplomaByID(uint256 id, uint256 diplomaId, string fullName, string birthDay, string date, DiplomaStatus status, DiplomaTypes _type, DiplomaRanks rank, address organizer);
    
    function searchDiplomaByID(uint256 _id)public returns (uint256 id, uint256 diplomaId, string fullName, string birthDay, string date, DiplomaStatus status, DiplomaTypes _type, DiplomaRanks rank, address organizer) {
        require(_id < numDiplomas);
        require(balanceOf[msg.sender] >= searchingFee); 
        
        Diploma memory d = diplomas[_id];
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(searchingFee); 
        
        balanceOf[wallet] = balanceOf[wallet].add(searchingFee.div(2)); 
        
        balanceOf[d.organizer] = balanceOf[d.organizer].add(searchingFee.div(2));  
        
        emit SearchDiplomaByID(_id, d.diplomaId, d.fullName, d.birthDay, d.date, d.status, d._type, d.rank, d.organizer);
        
        return (_id, d.diplomaId, d.fullName, d.birthDay, d.date, d.status, d._type, d.rank, d.organizer);
    }
    
     
    event UpdateSearchingFee(uint256 _newSearchingFee);
    
    function updateSearchingFee(uint256 newSearchingFee) public onlyOwner {
        require(newSearchingFee >= 0);
        searchingFee = newSearchingFee;
        
        emit UpdateSearchingFee(newSearchingFee);
    }
    
     
    mapping (address => uint256) balanceOf;
    function getBalanceOf(address _user)view public returns(uint256){
        return balanceOf[_user];
    }
     
    event Transfer(address indexed from, address indexed to, uint256 value);
    function claimRemainEth(uint256 _balance) public returns (bool){
        require(balanceOf[msg.sender].sub(_balance) >= 0);
        
        msg.sender.transfer(_balance);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_balance);
        emit Transfer(address(this), msg.sender, _balance);
        return true;
    }
     
    function () public payable {
        require(msg.value >= 0 ether);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(msg.value);
    }
    
}