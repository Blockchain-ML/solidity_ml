pragma solidity ^0.4.23;
 
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

 
library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        uint256 c = a / b;
         
        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
 
library SafeMath32 {

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {
        if (a == 0) {
            return 0;
       }
        uint32 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {
         
        uint32 c = a / b;
         
        return c;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        assert(b <= a);
        return a - b;
    }

    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        assert(c >= a);
        return c;
    }
}

 
library SafeMath16 {

    function mul(uint16 a, uint16 b) internal pure returns (uint16) {
        if (a == 0) {
            return 0;
        }
        uint16 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint16 a, uint16 b) internal pure returns (uint16) {
         
        uint16 c = a / b;
         
        return c;
    }

    function sub(uint16 a, uint16 b) internal pure returns (uint16) {
        assert(b <= a);
        return a - b;
    }

    function add(uint16 a, uint16 b) internal pure returns (uint16) {
        uint16 c = a + b;
        assert(c >= a);
        return c;
    }
}
contract StudentFactory is Ownable{
    using SafeMath for uint;
    struct Status{
        string studentId;  
        string schoolId; 
        string majorId; 
        uint8 length; 
        uint8 eduType; 
        uint8 eduForm; 
        uint8 level; 
        uint8 state; 
        uint16 class; 
        uint64 admissionDate; 
        uint64 departureDate; 
    }


    struct CET4{
        uint64 time;  
        uint32 grade; 
    }

    struct CET6{
        uint64 time;  
        uint32 grade; 
    }

    CET4[] CET4List;  
    CET6[] CET6List;  

    mapping (uint=>uint32) internal CET4IndexToId;  
    mapping (uint=>uint32) internal CET6IndexToId;  
    mapping (uint32=>uint) internal idCET4Count;  
    mapping (uint32=>uint) internal idCET6Count;  

    mapping (uint32=>Status) public idToUndergraduate; 
    mapping (uint32=>Status) public idToMaster; 
    mapping (uint32=>Status) public idToDoctor; 


    function addUndergraduate(uint32 _id,string _studentId,string _schoolId,string _majorId,uint8 _length,uint8 _eduType,uint8 _eduForm,uint8 _level,uint8 _state,uint16 _class,uint64 _admissionDate,uint64 _departureDate)
    public onlyOwner{
        idToUndergraduate[_id] = Status(_studentId,_schoolId,_majorId,_length,_eduType,_eduForm,_level,_state,_class,_admissionDate,_departureDate);
    }

    function addMaster(uint32 _id,string _studentId,string _schoolId,string _majorId,uint8 _length,uint8 _eduType,uint8 _eduForm,uint8 _level,uint8 _state,uint16 _class,uint64 _admissionDate,uint64 _departureDate)
    public onlyOwner{
        idToMaster[_id] = Status(_studentId,_schoolId,_majorId,_length,_eduType,_eduForm,_level,_state,_class,_admissionDate,_departureDate);
    }

    function addDoctor(uint32 _id,string _studentId,string _schoolId,string _majorId,uint8 _length,uint8 _eduType,uint8 _eduForm,uint8 _level,uint8 _state,uint16 _class,uint64 _admissionDate,uint64 _departureDate)
    public onlyOwner{
        idToDoctor[_id] = Status(_studentId,_schoolId,_majorId,_length,_eduType,_eduForm,_level,_state,_class,_admissionDate,_departureDate);
    }

     
    function addCET4(uint32 _id,uint32 _time,uint32 _grade) public onlyOwner{
        uint index = CET4List.push(CET4(_time,_grade))-1;
        CET4IndexToId[index] = _id;
        idCET4Count[_id]++;
    }

     
    function addCET6(uint32 _id,uint32 _time,uint32 _grade) public onlyOwner{
        uint index = CET6List.push(CET6(_time,_grade))-1;
        CET6IndexToId[index] = _id;
        idCET6Count[_id]++;
    }

     
    function getCET4ById(uint32 _id) view public returns (uint64[],uint32[]) {
        uint64[] memory timeList = new uint64[](idCET4Count[_id]);
        uint32[] memory gradeList = new uint32[](idCET4Count[_id]);
        uint counter = 0;
        for (uint i = 0; i < CET4List.length; i++) {
            if(CET4IndexToId[i]==_id){
                timeList[counter] = CET4List[i].time;
                gradeList[counter] = CET4List[i].grade;
                counter++;
            }
        }
        return(timeList,gradeList);
    }

     
    function getCET6ById(uint32 _id) view public returns (uint64[],uint32[]) {
        uint64[] memory timeList = new uint64[](idCET6Count[_id]);
        uint32[] memory gradeList = new uint32[](idCET6Count[_id]);
        uint counter = 0;
        for (uint i = 0; i < CET6List.length; i++) {
            if(CET6IndexToId[i]==_id){
                timeList[counter] = CET6List[i].time;
                gradeList[counter] = CET6List[i].grade;
                counter++;
            }
        }
        return(timeList,gradeList);
    }
}