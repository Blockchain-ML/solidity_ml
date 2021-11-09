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
contract StudentFactory is Ownable {
    using SafeMath for uint;

    struct Status {
        string studentId;  
        string majorId; 
        uint8 length; 
        uint8 eduType; 
        uint8 eduForm; 
        uint8 level; 
        uint8 state; 
        uint16 schoolId; 
        uint16 class; 
        uint64 admissionDate; 
        uint64 departureDate; 
    }

    struct CET {
        uint64 examId; 
        uint64 examNumber; 
        uint64 time;  
        uint16 schoolId; 
        uint16 deptId; 
        uint8 listening; 
        uint8 reading; 
        uint8 writing; 
    }

    CET[] CET4List;  
    CET[] CET6List;  

    mapping(uint => uint32) internal CET4IndexToId;  
    mapping(uint => uint32) internal CET6IndexToId;  

    mapping(uint32 => uint) internal idCET4Count;  
    mapping(uint32 => uint) internal idCET6Count;  

    mapping(uint32 => Status) public idToUndergraduate; 
    mapping(uint32 => Status) public idToMaster; 
    mapping(uint32 => Status) public idToDoctor; 


    function addUndergraduate(uint32 _id, string _studentId, uint16 _schoolId, string _majorId, uint8 _length, uint8 _eduType, uint8 _eduForm, uint8 _level, uint8 _state, uint16 _class, uint64 _admissionDate, uint64 _departureDate)
    public onlyOwner {
        idToUndergraduate[_id] = Status(_studentId, _majorId, _length, _eduType, _eduForm, _level, _state, _schoolId, _class, _admissionDate, _departureDate);
    }

    function addMaster(uint32 _id, string _studentId, uint16 _schoolId, string _majorId, uint8 _length, uint8 _eduType, uint8 _eduForm, uint8 _level, uint8 _state, uint16 _class, uint64 _admissionDate, uint64 _departureDate)
    public onlyOwner {
        idToMaster[_id] = Status(_studentId, _majorId, _length, _eduType, _eduForm, _level, _state, _schoolId, _class, _admissionDate, _departureDate);
    }

    function addDoctor(uint32 _id, string _studentId, uint16 _schoolId, string _majorId, uint8 _length, uint8 _eduType, uint8 _eduForm, uint8 _level, uint8 _state, uint16 _class, uint64 _admissionDate, uint64 _departureDate)
    public onlyOwner {
        idToDoctor[_id] = Status(_studentId, _majorId, _length, _eduType, _eduForm, _level, _state, _schoolId, _class, _admissionDate, _departureDate);
    }

     
    function addCET4(uint32 _id, uint64 _examId, uint64 _examNumber, uint64 _time, uint16 _schoolId, uint16 _deptId, uint8 _listening, uint8 _reading, uint8 _writing) public onlyOwner {
        uint index = CET4List.push(CET(_examId, _examNumber, _time, _schoolId, _deptId, _listening, _reading, _writing)) - 1;
        CET4IndexToId[index] = _id;
        idCET4Count[_id]++;
    }

     
    function addCET6(uint32 _id, uint64 _examId, uint64 _examNumber, uint64 _time, uint16 _schoolId, uint16 _deptId, uint8 _listening, uint8 _reading, uint8 _writing) public onlyOwner {
        uint index = CET6List.push(CET(_examId, _examNumber, _time, _schoolId, _deptId, _listening, _reading, _writing)) - 1;
        CET4IndexToId[index] = _id;
        idCET4Count[_id]++;
    }

     
    function getCET4ScoreById(uint32 _id) view public returns (uint64[], uint8[], uint8[], uint8[]) {
        uint64[] memory examIdList = new uint64[](idCET4Count[_id]);
        uint8[] memory listeningList = new uint8[](idCET4Count[_id]);
        uint8[] memory readingList = new uint8[](idCET4Count[_id]);
        uint8[] memory writingList = new uint8[](idCET4Count[_id]);
        uint counter = 0;
        for (uint i = 0; i < CET4List.length; i++) {
            if (CET4IndexToId[i] == _id) {
                examIdList[counter] = CET4List[i].examId;
                listeningList[counter] = CET4List[i].listening;
                readingList[counter] = CET4List[i].reading;
                writingList[counter] = CET4List[i].writing;
                counter++;
            }
        }
        return (examIdList,listeningList, readingList, writingList);
    }

     
    function getCET6ScoreById(uint32 _id) view public returns (uint64[], uint8[], uint8[], uint8[]) {
        uint64[] memory examIdList = new uint64[](idCET6Count[_id]);
        uint8[] memory listeningList = new uint8[](idCET6Count[_id]);
        uint8[] memory readingList = new uint8[](idCET6Count[_id]);
        uint8[] memory writingList = new uint8[](idCET6Count[_id]);
        uint counter = 0;
        for (uint i = 0; i < CET6List.length; i++) {
            if (CET6IndexToId[i] == _id) {
                examIdList[counter] = CET4List[i].examId;
                listeningList[counter] = CET6List[i].listening;
                readingList[counter] = CET6List[i].reading;
                writingList[counter] = CET6List[i].writing;
                counter++;
            }
        }
        return (examIdList,listeningList, readingList, writingList);
    }


     
    function getCET4InfoById(uint32 _id) view public returns (uint64[], uint64[], uint16[], uint16[]) {
        uint64[] memory examNumberList = new uint64[](idCET4Count[_id]);
        uint64[] memory timeList = new uint64[](idCET4Count[_id]);
        uint16[] memory schoolIdList = new uint16[](idCET4Count[_id]);
        uint16[] memory deptIdList = new uint16[](idCET4Count[_id]);
        uint counter = 0;
        for (uint i = 0; i < CET4List.length; i++) {
            if (CET4IndexToId[i] == _id) {
                examNumberList[counter] = CET4List[i].examNumber;
                timeList[counter] = CET4List[i].time;
                schoolIdList[counter] = CET4List[i].schoolId;
                deptIdList[counter] = CET4List[i].deptId;
                counter++;
            }
        }
        return (examNumberList, timeList, schoolIdList, deptIdList);
    }

     
    function getCET6InfoById(uint32 _id) view public returns (uint64[], uint64[], uint16[], uint16[]) {
        uint64[] memory examNumberList = new uint64[](idCET6Count[_id]);
        uint64[] memory timeList = new uint64[](idCET6Count[_id]);
        uint16[] memory schoolIdList = new uint16[](idCET6Count[_id]);
        uint16[] memory deptIdList = new uint16[](idCET6Count[_id]);
        uint counter = 0;
        for (uint i = 0; i < CET6List.length; i++) {
            if (CET6IndexToId[i] == _id) {
                examNumberList[counter] = CET6List[i].examNumber;
                timeList[counter] = CET6List[i].time;
                schoolIdList[counter] = CET6List[i].schoolId;
                deptIdList[counter] = CET6List[i].deptId;
                counter++;
            }
        }
        return (examNumberList, timeList, schoolIdList, deptIdList);
    }
}