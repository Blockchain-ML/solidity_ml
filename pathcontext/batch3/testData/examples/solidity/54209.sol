pragma solidity ^0.4.17;

contract Cetification {
    
    struct Course{
        string c_Name;
        uint c_ID;
        string startDate;
        string endDate;
        string Description;
        string Instructor;
    }
    
    struct Student{
        address addressStudent;
        string Email;
        string Phone;
        string s_Name;
        uint CourseID;
    }
    
    address public Educator;
    constructor () public {
        Educator = msg.sender;
    }
    
    modifier hasPermission {
        require(msg.sender == Educator);
        _;
    }
    
    mapping (uint => Course) public courses;
    uint private NumOfCourses = 0; 
    function addCourse (string _c_Name, uint _c_ID, string _startDate,  string _endDate, string _Description, string _Instructor)  public hasPermission {
         
        NumOfCourses++;
         
        courses[NumOfCourses]= Course( _c_Name, _c_ID,  _startDate,  
        _endDate, _Description, _Instructor);
    }


    function coursesLength() public view returns(uint ){
        return  NumOfCourses; 
    }
    
    mapping (uint => Student) public studentRequests;
    uint private requestID = 0; 
    function ApplyForCertification (string _Email, string _Phone, string _s_Name,uint _CourseID) public{
        requestID++;
        address _addressStudent = msg.sender; 
        studentRequests[requestID] = Student(_addressStudent, _Email, _Phone,_s_Name, _CourseID);
    }
    
    function NumOfStudentsRequests() public view returns(uint ){
        return requestID;
    }
    
    mapping (address =>  mapping (uint => bool)) public student2course;
    mapping (uint => Student) public StudentAppoved;
    uint NumOfStudentsApproved;
    function approveCertification(uint _requestID) hasPermission public returns (bool)  {
         
        NumOfStudentsApproved++;
        StudentAppoved[NumOfStudentsApproved] = studentRequests[_requestID];
         
        address _addressStudent = studentRequests[_requestID].addressStudent;
        uint _CourseID =  studentRequests[_requestID].CourseID;
         
        student2course[_addressStudent][_CourseID] = true;
         
        return  student2course[_addressStudent][_CourseID];
    }
    
    function rejectCertification(uint _requestID) hasPermission public returns (bool){
         
        address _addressStudent = studentRequests[_requestID].addressStudent;
        uint _CourseID =  studentRequests[_requestID].CourseID;
         
        student2course[_addressStudent][_CourseID] = false;
         
        return  student2course[_addressStudent][_CourseID];
    }
    
  
     function clearAllRequests() public{
        while (requestID > 0){
            delete studentRequests[requestID];
            requestID--;
        }
    }

   
    function verifyCertification (address _addrStudent, uint _c_ID)   public view returns (string , uint, string, string , string , string) {
        string memory courseName;
        uint  courseID;
        string memory coursestartDate;
        string memory courseendDate;
        string memory courseDescription;
        string memory courseInstructor;
        if (student2course[_addrStudent][_c_ID]) {
            courseName = courses[_c_ID].c_Name;
            courseID = courses[_c_ID].c_ID;
            coursestartDate = courses[_c_ID].startDate;
            courseendDate = courses[_c_ID].endDate;
            courseDescription = courses[_c_ID].Description;
            courseInstructor = courses[_c_ID].Instructor;
        }
        return (courseName, courseID, coursestartDate, courseendDate,  courseDescription, courseInstructor);
    }
    
}